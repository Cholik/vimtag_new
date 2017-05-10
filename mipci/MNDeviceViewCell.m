//
//  MNDeviceViewCell.m
//  mipci
//
//  Created by weken on 15/2/5.
//
//

#import "MNDeviceViewCell.h"
#import "AppDelegate.h"
#import "UIImageView+MNNetworking.h"
#import "MNCache.h"
#import "MIPCUtils.h"
#import "UserInfo.h"

#define total_bytes_statistic_counts    3

@interface MNDeviceViewCell()
{
    long            _chl_id;
    long            _in_audio_outing;
    long            _chl_id_audio_out;
    long            _speaker_is_mute;
    long            _total_bytes[total_bytes_statistic_counts];
    unsigned long   _total_bytes_tick[total_bytes_statistic_counts];
    
    unsigned char _encrypt_pwd[16];
}
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) BOOL isOnline;
//@property (strong, nonatomic) NSOperation *downloadImageOperation;
@property (strong, nonatomic) mipc_agent *loginAgent;

@end

@implementation MNDeviceViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    
    return self;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

-(mipc_agent *)loginAgent
{
    if (nil == _loginAgent) {
        _loginAgent = [[mipc_agent alloc] init];
    }
    return _loginAgent;
}

#pragma mark - Setup
-(void)setStatus:(NSString *)status
{
    _status = status;
    
    if (NSOrderedSame == [status caseInsensitiveCompare:@"online"])
    {
        if (self.app.is_luxcam)
        {
            _statusImageView.image = [UIImage imageNamed:@"green_dot.png"];
        }
        else if (self.app.is_vimtag)
        {
            _statusImageView.image = nil;
        }
        else if (self.app.is_ebitcam)
        {
            _statusImageView.image = nil;
        }
        else if (self.app.is_mipc)
        {
            _statusImageView.image = nil;
        }
        else
        {
            _statusImageView.image = [UIImage imageNamed:@"green_status.png"];

        }
    }
    else if (NSOrderedSame == [status caseInsensitiveCompare:@"offline"])
    {
        if (self.app.is_luxcam)
        {
            _statusImageView.image = [UIImage imageNamed:@"red_dot.png"];
        }
        else if (self.app.is_vimtag)
        {
            _statusImageView.image = [UIImage imageNamed:@"vt_offline.png"];
        }
        else if (self.app.is_ebitcam)
        {
            _statusImageView.image = [UIImage imageNamed:@"eb_offline.png"];
        }
        else if (self.app.is_mipc)
        {
            _statusImageView.image = [UIImage imageNamed:@"mi_offline.png"];
        }
        else
        {
            _statusImageView.image = [UIImage imageNamed:@"red_status.png"];
            
        }
    }
    else
    {
        if (self.app.is_luxcam)
        {
            _statusImageView.image = [UIImage imageNamed:@"yellow_dot.png"];
        }
        else if (self.app.is_vimtag)
        {
            _statusImageView.image = [UIImage imageNamed:@"vt_lock_camera.png"];
        }
        else if (self.app.is_ebitcam)
        {
            _statusImageView.image = [UIImage imageNamed:@"eb_invalid.png"];
        }
        else if (self.app.is_mipc)
        {
            _statusImageView.image = [UIImage imageNamed:@"mi_invalid.png"];
        }
        else
        {
            _statusImageView.image = [UIImage imageNamed:@"yellow_status.png"];
            
        }
    }
    
    _isOnline =(NSOrderedSame == [_status caseInsensitiveCompare:@"online"]) ? YES : NO;
}

-(void)imageNil
{
    self.backgroundImageView.image = nil;
}
-(void)loadWebImage
{
//    self.downloadImageOperation = [[NSOperation alloc] init];
//    if (self.app.is_vimtag)
//    {
//        self.backgroundImageView.image = [UIImage imageNamed:@"vt_cellBg.png"];
//        
//    }
//    else
//    {
//        self.backgroundImageView.image = [UIImage imageNamed:self.app.is_luxcam ? @"placeholder.png" : @"camera_placeholder.png"];
//    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            NSString *imagePath = [weakSelf localImagePathByDeviceID:_deviceID];
            UIImage *image = [[[MNCache class ] mn_sharedCache] objectForKey:imagePath];
            if (!image){
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    weakSelf.backgroundImageView.image = image;
                    //                } else {
                    //                    weakSelf.backgroundImageView.image = [UIImage imageNamed:self.app.is_luxcam ? @"placeholder.png" :   @"camera_placeholder.png"];
//                    [weakSelf ]
                }
                
            });
        }
        else
        {
            if (_isOnline) {
                NSString *imagePath = [weakSelf localImagePathByDeviceID:_deviceID];
                UIImage *image = [[[MNCache class ] mn_sharedCache] objectForKey:imagePath];
                if (!image){
                    image = [UIImage imageWithContentsOfFile:imagePath];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image && _isOnline) {
                        weakSelf.backgroundImageView.image = image;
                        
    //                } else {
    //                    weakSelf.backgroundImageView.image = [UIImage imageNamed:self.app.is_luxcam ? @"placeholder.png" :   @"camera_placeholder.png"];
                    }
                    
                });

            }
        }
    });
    
//    NSString *server = [self.agent.devs get_dev_by_sn:_deviceID].ip_addr;
    
    mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
    ctx.type = mdev_pic_thumb;
    ctx.sn = _deviceID;
    //        ctx.size = @"qcif";

    
    
    if (_isOnline) {
        __weak typeof(self) weakSelf = self;
        NSURL *downloadImageURL = [NSURL URLWithString:[self.agent pic_url_create:ctx]];
        [self.backgroundImageView setImageWithURLRequest:[NSURLRequest requestWithURL:downloadImageURL]
                                        placeholderImage:weakSelf.backgroundImageView.image
                                                   token:nil
                                                deviceID:_deviceID
                                                    flag:0
//                                                success:nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image, NSString *deviceID, NSString *token) {
         
                                                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                                                     
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        if (deviceID == strongSelf.deviceID && image) {
                                                                       strongSelf.backgroundImageView.image = image;
                                                                                                                   }
                                                    });
                                                    NSString *imagePath = [weakSelf localImagePathByDeviceID:deviceID];
                                                     if (imagePath && image)
                                                     {
                                                            [[[MNCache class] mn_sharedCache]  setObject:image forKey:imagePath];
                                                     }
                                         
                   
                                                    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
                                                     
                                                 }
                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                    NSLog(@"err[%@]", [error localizedDescription]);
                                                 }];
//        [self loadMediaPlay];
    }
    
}

#pragma mark - Media
- (void)loadMediaPlay
{
    mcall_ctx_play *ctx = [[mcall_ctx_play alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(play_done:);
    
    ctx.token = @"p3";
    ctx.protocol = @"rtdp";
    [self.loginAgent play:ctx];
    
    [_progressActivityIndicato startAnimating];
    _progressActivityIndicato.hidden = NO;
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
        self.isPlay = NO;
    }
}

#pragma mark - play_done
- (void)play_done:(mcall_ret_play*)ret
{
    if (self.app.is_luxcam) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    if(ret.result == nil && ret.url.length)
    {
        [self MIPC_EngineCreate:ret.url];
    }
    else
    {
        [_progressActivityIndicato stopAnimating];
        _progressActivityIndicato.hidden = YES;
        _playButton.selected = NO;
        _backgroundPlayView.hidden = YES;
        _playButton.hidden = YES;
        self.status = @"Offline";
        if ([self.delegate respondsToSelector:@selector(updateCellOfflineWithDev:)]) {
            [self.delegate updateCellOfflineWithDev:_device];
        }
    }
    
}

#pragma mark - Engine create
- (void)MIPC_EngineCreate:(NSString*)url
{
    if(nil != _engine)
    {
        [_engine removeFromSuperview];
        _engine = nil;
    }
    self.isPlay = YES;
    //
//    CGRect rect = CGRectMake(0, 0, 160, 90);
    _engine = [[MMediaEngine alloc] initWithFrame:self.backgroundPlayView.bounds];
//        _engine = [[MMediaEngine alloc] initWithFrame:rect];
    _engine.backgroundColor = [UIColor whiteColor];
    _engine.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
    
    [self.backgroundPlayView insertSubview:_engine atIndex:0];
    //    [self.containerView addSubview:_engine];
    //
    NSString *engineKey = MIPC_GetEngineKey();
    if([_engine engine_create:engineKey refer:self onEvent:@selector(onMediaEvent:)])
    {
        [self mediaEndPlay];
    }
    else
    {
        _speaker_is_mute = 1;
        struct mipci_conf *conf = MIPC_ConfigLoad();
        NSString   *live_flow_ctrl = [NSString stringWithFormat:@"flow_ctrl:\"jitter\",jitter:{max:%d}",(conf && 0 != conf->buf)?conf->buf:3000];
        NSString   *params = [NSString stringWithFormat:@"{src:[{url:\"%@\"}], dst:[{url:\"data:/\",thread:\"istream\"}],trans:[{%@,thread:\"istream\"}],speaker:{mute:%ld}, thread:\"channel\"}", url, live_flow_ctrl, _speaker_is_mute];   //?
        memset(_total_bytes, 0, sizeof(_total_bytes));
        memset(_total_bytes_tick, 0, sizeof(_total_bytes_tick));
        
        //
        if(0 >= (_chl_id = [_engine chl_create:params]))
        {
            [_progressActivityIndicato stopAnimating];
            _progressActivityIndicato.hidden = YES;
            [self mediaEndPlay];
        }
        else
        {
            NSLog(@"media engine create succeed and chl-create.");
            if ([self.delegate respondsToSelector:@selector(recordVideoPlay:with:)]) {
                [self.delegate recordVideoPlay:_device with:_playButton.selected];
            }
        }
    }
}


- (long)onMediaEvent:(MMediaEngineEvent *)evt
{
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
    //jc's add code
    //end
    [_progressActivityIndicato stopAnimating];
    _progressActivityIndicato.hidden = YES;
}

-(void)cancelNetworkRequest
{
    [self.backgroundImageView cancelImageRequestOperation];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - prepareForReuse
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    _status = nil;
    _deviceID = nil;
    
    _statusImageView.image = nil;
    _nickLabel.text = nil;
    self.backgroundImageView.image = nil;
    _alarmImageView.image = nil;
    
    _loginAgent = nil;
    [_progressActivityIndicato stopAnimating];
    _progressActivityIndicato.hidden = YES;
    
    [_backgroundImageView cancelImageRequestOperation];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - pic_get_done
- (void)pic_get_done:(mcall_ret_pic_get*)ret
{
    //the normal operation is that cancel the thread of downloading the picture
    //FIXME:need to be changed
    if (nil != ret.img && _deviceID == ret.sn)
    {
        self.backgroundImageView.image = ret.img;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //save image
            NSString *imagePath = [self localImagePathByDeviceID:ret.sn];
            [UIImagePNGRepresentation(ret.img) writeToFile:imagePath atomically:YES];
        });
    }
}

#pragma mark - Utils
- (NSString*)localImagePathByDeviceID:(NSString *)deviceID
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    NSString *imageDirectory  = [path stringByAppendingPathComponent:@"photos/deviceCell"];
    NSString *imagePath = [imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", deviceID]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDirectory])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            NSLog(@"error:%@", [error localizedDescription]);
        }

    }
    
    return imagePath;
}

- (IBAction)videoPlayOrPause:(id)sender {
    _playButton.selected = !_playButton.selected;
    _backgroundPlayView.hidden = !_playButton.selected;
    if (_playButton.selected) {
        if (self.app.isLocalDevice) {
//            if ([self.delegate respondsToSelector:@selector(signInDev:)]) {
//                [self.delegate signInDev:_device];
//            }
            
            NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"local_users"];
            NSArray *usersArray = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
            UserInfo *userInfo = [[UserInfo alloc] init];
            for (UserInfo *tempInfo in usersArray) {
                if ([tempInfo.name isEqual:_device.sn]) {
                    userInfo = tempInfo;
                    if(userInfo.name && userInfo.password)
                    {
                        if ([self.delegate respondsToSelector:@selector(getAgentWithDev:)]) {
                            _loginAgent = [self.delegate getAgentWithDev:_device];
                            if (_loginAgent) {
                                [self loadMediaPlay];
                                return;
                            }
                        }
                        //                [mipc_agent passwd_encrypt:userInfo.password encrypt_pwd:_encrypt_pwd];
//                        NSString *currentDevicePassword = @"*******";
                        strncpy(_encrypt_pwd, [userInfo.password bytes], 16);
                        mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
                        ctx.srv = MIPC_SrvFix(_device.ip_addr);
                        ctx.user = _device.sn;
                        ctx.passwd = _encrypt_pwd;
                        ctx.target = self;
                        ctx.ref = _device;
                        ctx.on_event = @selector(sign_in_done:);
                        
                        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                        NSString *token = [user objectForKey:@"mipci_token"];
                        
                        if(token && token.length)
                        {
                            ctx.token = token;
                        }
                        
                        [self.loginAgent local_sign_in:ctx switchMmq:NO];
                        [_progressActivityIndicato startAnimating];
                        _progressActivityIndicato.hidden = NO;
                        return;
                    }
                }
            }
            _playButton.selected = NO;
            _backgroundPlayView.hidden = YES;
            _playButton.hidden = YES;
            self.status = @"InvalidAuth";
            [_progressActivityIndicato stopAnimating];
            _progressActivityIndicato.hidden = YES;
            
            if ([self.delegate respondsToSelector:@selector(updateCellInvalidWithDev:)]) {
                [self.delegate updateCellInvalidWithDev:_device];
            }
        }else {
            [self loadMediaPlay];
        }
    }else {
        [_progressActivityIndicato stopAnimating];
        _progressActivityIndicato.hidden = YES;
        [self mediaEndPlay];
        if ([self.delegate respondsToSelector:@selector(recordVideoPlay:with:)]) {
            [self.delegate recordVideoPlay:_device with:_playButton.selected];
        }
    }
}

- (void)sign_in_done:(mcall_ret_sign_in*)ret
{
    if (ret.result == nil) {
        if (nil == _loginAgent) {
            return;
        }
        if ([self.delegate respondsToSelector:@selector(managerLocalAgent:withDev:)]) {
            [self.delegate managerLocalAgent:_loginAgent withDev:_device];
        }
        [self loadMediaPlay];
    }
    else if([ret.result isEqualToString:@"ret.pwd.invalid"])
    {
        [_progressActivityIndicato stopAnimating];
        _progressActivityIndicato.hidden = YES;
        _playButton.selected = NO;
        _backgroundPlayView.hidden = YES;
        _playButton.hidden = YES;
        self.status = @"InvalidAuth";

        if ([self.delegate respondsToSelector:@selector(updateCellInvalidWithDev:)]) {
            [self.delegate updateCellInvalidWithDev:_device];
        }
    }
    else
    {
        [_progressActivityIndicato stopAnimating];
        _progressActivityIndicato.hidden = YES;
        _playButton.selected = NO;
        _backgroundPlayView.hidden = YES;
        _playButton.hidden = YES;
        self.status = @"Offline";
        if ([self.delegate respondsToSelector:@selector(updateCellOfflineWithDev:)]) {
            [self.delegate updateCellOfflineWithDev:_device];
        }
    }
}

-(void)resetMediaPlay:(BOOL)isPlay withAgent:(mipc_agent *)agent
{
    if (agent) {
        _loginAgent = agent;
    }
    _playButton.selected = isPlay;
    _backgroundPlayView.hidden = !isPlay;
    [self mediaEndPlay];
    
    if ([_device.type isEqualToString:@"IPC"] && [_device.status isEqualToString:@"Online"] && [_device.status caseInsensitiveCompare:@"InvalidAuth"]) {
        _playButton.hidden = NO;
    }else {
        _playButton.hidden = YES;
        _backgroundPlayView.hidden = YES;
    }
    if (isPlay) {
        [self loadMediaPlay];
    }
}
@end
