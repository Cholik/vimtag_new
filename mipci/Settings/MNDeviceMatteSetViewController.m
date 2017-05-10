//
//  MNDeviceMatteSetViewController.m
//  mipci
//
//  Created by weken on 15/3/24.
//
//

#import "MNDeviceMatteSetViewController.h"
#import "mme_ios.h"
#import "MIPCUtils.h"
#import "mipc_agent.h"
#import "MNMatteView.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MNInfoPromptView.h"

typedef CGPoint MNMatrix;

@interface MNDeviceMatteSetViewController ()
@property (strong, nonatomic) MMediaEngine *engine;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) MNMatteView *matteView;
@property (weak, nonatomic) AppDelegate *app;

@property (assign, nonatomic) long chl_id;
@property (assign, nonatomic) long in_audio_outing;
@property (assign, nonatomic) long chl_id_audio_out;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (strong, nonatomic) NSMutableArray *getMasksArray;

@end

@implementation MNDeviceMatteSetViewController

-(mipc_agent *)agent
{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return app.isLocalDevice?app.localAgent:app.cloudAgent;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _saveBarButtonItem.title = NSLocalizedString(@"mcs_save", nil);
    _resetBarButtonItem.title = NSLocalizedString(@"mcs_reset", nil);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
    [self mediaBeginPlay];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MNInfoPromptView hideAll:_rootNavigationController];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self mediaEndPlay];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reset:(id)sender
{
    [_matteView reset];
}

- (IBAction)save:(id)sender
{
    NSMutableArray *matrixs = _matteView.matrixs;
    NSMutableDictionary *masksDictionary = [NSMutableDictionary dictionary];
    
    for (NSValue *value in matrixs) {
        MNMatrix matrix = [value CGPointValue];
        int index = (int)matrix.y;
        [_getMasksArray removeObject:[NSString stringWithFormat:@"%d", index]];
        NSMutableArray *bitArray = [masksDictionary objectForKey:[NSString stringWithFormat:@"%d", index]];
        if (bitArray) {
            [bitArray replaceObjectAtIndex:(int)matrix.x withObject:@1];
        }
        else
        {
            bitArray = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0]];
            
            [bitArray replaceObjectAtIndex:(int)matrix.x withObject:@1];
        }
        
        [masksDictionary setObject:bitArray forKey:[NSString stringWithFormat:@"%d", index]];
    }
    for (NSString *index in _getMasksArray) {
        NSMutableArray *bitArray = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0]];
        [masksDictionary setObject:bitArray forKey:[NSString stringWithFormat:@"%@", index]];
    }
    
    mcall_ctx_alarm_mask_set *ctx = [[mcall_ctx_alarm_mask_set alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.enable = 1;
    ctx.matrix_height = 9;
    ctx.matrix_width = 16;
    ctx.on_event = @selector(alarm_mask_set_done:);
    if (masksDictionary.count < 8) {
        ctx.masks = masksDictionary;
    }else {
        ctx.masks = [NSMutableDictionary dictionary];
        for (NSString *key in masksDictionary) {
            static int i = 1;
            [ctx.masks setObject:[masksDictionary objectForKey:key] forKey:key];
            if (0 == i % 5) {
                [self.agent alarm_mask_set:ctx];
                [ctx.masks removeAllObjects];
            }
            i++;
        }
    }
    [self.agent alarm_mask_set:ctx];
}



- (IBAction)doubleTap:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
    _navigationToolBar.alpha = _navigationToolBar.alpha ? 0 : 1;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Engine create
- (void)MIPC_EngineCreate:(NSString*)url
{
    if(nil != _engine)
    {
        [_engine removeFromSuperview];
        _engine = nil;
    }
    _engine = [[MMediaEngine alloc] initWithFrame:self.view.bounds];
    _engine.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
    
    [self.view insertSubview:_engine atIndex:0];
    
    //创建视频引擎
    NSString *engineKey = MIPC_GetEngineKey();
    if([_engine engine_create:engineKey refer:self onEvent:@selector(onMediaEvent:)])
    {
        [self mediaEndPlay];
    }
    else
    {
        struct mipci_conf *conf = MIPC_ConfigLoad();
        
        NSString   *live_flow_ctrl = [NSString stringWithFormat:@"flow_ctrl:\"jitter\",jitter:{max:%d}",(conf && 0 != conf->buf)?conf->buf:3000];
        NSString   *params = [NSString stringWithFormat:@"{src:[{url:\"%@\"}], dst:[{url:\"data:/\",thread:\"istream\"}],trans:[{%@,thread:\"istream\"}],speaker:{mute:%d}, thread:\"channel\"}", url, live_flow_ctrl, 1];
        
        //创建通道
        if(0 >= (_chl_id = [_engine chl_create:params]))
        {
            [self mediaEndPlay];
        }
        else
        {
            NSLog(@"media engine create succeed and chl-create.");
        }
    }
}

- (long)onMediaEvent:(MMediaEngineEvent *)evt
{
    if(!_isViewAppearing)
    {
        return 0;
    }
    
    NSLog(@"onMediaEvent(evt[%p{type[%@],code[%@],chl_id[%ld]}].", evt, evt.type, evt.code, evt.chl_id);
    
    if(evt
       && evt.type && [evt.type isEqualToString:@"link"]
       && evt.code && [evt.code isEqualToString:@"active"]
       && evt.data && (evt.data.length > 0) && (0 <= strstr([evt.data UTF8String], "video")))
    {
        [self performSelectorOnMainThread:@selector(onVideoArrived:) withObject:nil waitUntilDone:NO];
    }
    
    if(evt && evt.type && [evt.type isEqualToString:@"close"])
    {
        if(evt.chl_id == _chl_id)
        {
            NSLog(@"play chl[%ld] be closed.", _chl_id);
            _chl_id = 0;
        }
        else if(evt.chl_id == _chl_id_audio_out)
        {
            NSLog(@"audio out chl[%ld] be closed.", _chl_id_audio_out);
            _chl_id_audio_out = 0;
            _in_audio_outing = 0;
        }
    }
    return 0;
}

- (void)onVideoArrived:(id)sender
{
    [_activityIndicatorView stopAnimating];
    NSLog(@"video arrived");
    
    _matteView = [[MNMatteView alloc] initWithFrame:self.view.bounds];
       _matteView.lineColor = [UIColor grayColor];
    _matteView.lineWidth = 1.0;
    [self.view insertSubview:_matteView belowSubview:_navigationToolBar];
    
    NSArray *constraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_matteView]-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_matteView)];
    NSArray *constraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_matteView]-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:NSDictionaryOfVariableBindings(_matteView)];
    [self.view addConstraints:constraints1];
    [self.view addConstraints:constraints2];
    
    mcall_ctx_alarm_mask_get *ctx = [[mcall_ctx_alarm_mask_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(alarm_mask_get_done:);
    
    [self.agent alarm_mask_get:ctx];
    
}

#pragma mark - Media
- (void)mediaBeginPlay
{
    [_activityIndicatorView startAnimating];
    
    struct mipci_conf *conf = MIPC_ConfigLoad();
    long profileID = (conf && conf->profile_id<4)?conf->profile_id:1;
    
    mcall_ctx_play *ctx = [[mcall_ctx_play alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(play_done:);
    NSString *size = nil;
    switch (profileID) {
        case 0:
            size = @"720p";
            break;
        case 2:
            size = @"cif";
            break;
        case 3:
            size = @"qcif";
            break;
        default:
            size = @"d1";
            break;
    }
    ctx.token = size;
    ctx.protocol = @"rtdp";
    [self.agent play:ctx];
}

- (void)mediaEndPlay
{
    if(_engine)
    {
        if(_chl_id > 0)
        {
            [_engine chl_destroy:_chl_id];
            _chl_id = 0;
        }
        [_engine engine_destroy];
        [_engine removeFromSuperview];
        _engine = nil;
    }
    
    [_activityIndicatorView stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - play_done
- (void)play_done:(mcall_ret_play*)ret
{
    if(!_isViewAppearing)
    {
        return;
    }
    
    if(ret.result == nil && ret.url.length)
    {
        [self MIPC_EngineCreate:ret.url];
    }
    else
    {
        [_activityIndicatorView stopAnimating];
    }
}

- (void)alarm_mask_get_done:(mcall_ret_alarm_mask_get*)ret
{
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil != ret.result) {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:nil]];
            }
        }
        return;
    }
    
    NSMutableDictionary *masksDictionary = ret.masks;
    _getMasksArray = [NSMutableArray arrayWithArray:masksDictionary.allKeys];
    NSMutableArray *masksArray = [NSMutableArray array];
    
    for (NSString *index in masksDictionary.allKeys)
    {
        NSArray *bitArray = [masksDictionary objectForKey:index];
        for (int i = 0; i < bitArray.count; i++)
        {
            int mark = [[bitArray objectAtIndex:i] intValue];
            if (mark == 1) {
                MNMatrix matrix = CGPointMake(i, [index intValue]  );
                [masksArray addObject:[NSValue valueWithCGPoint:matrix]];
            }
        }
    }
    
    _matteView.matrixs = masksArray;
}

- (void)alarm_mask_set_done:(mcall_ret_alarm_mask_set*)ret
{
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil == ret.result)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        }
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_failed_to_set_the", nil)]];
            }
        }
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
