//
//  MNAccessoryVideoViewController.m
//  mipci
//
//  Created by PC-lizebin on 16/8/6.
//
//

#import "MNAccessoryVideoViewController.h"
#import "UIViewController+loading.h"
#import "MNAccessorySceneViewController.h"
#import "MNInfoPromptView.h"

@interface MNAccessoryVideoViewController ()

@property (nonatomic,strong) NSMutableArray *sceneArray;

@end

@implementation MNAccessoryVideoViewController

#pragma mark - initUI
-(void)initUI
{
    self.title = NSLocalizedString(@"mcs_record", nil);
    
    _recordAllDayLabel.text = NSLocalizedString(@"mcs_all_day_recording", nil);
    _recordPromptLabel.text = NSLocalizedString(@"mcs_7x24_hours_prompt", nil);
    _sceneLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"mcs_scenes", nil),NSLocalizedString(@"mcs_home_mode", nil)];
    _activeLabel.text = NSLocalizedString(@"mcs_home_mode", nil);
    _awayLabel.text = NSLocalizedString(@"mcs_away_home_mode", nil);
    
    _allDaySwitch.on = NO;
    _activeSwitch.on = NO;
    _awaySwitch.on = NO;
    _customRecordView.hidden = NO;
    _buttonToLabelLayoutConstraint.constant = _customRecordView.hidden ? 0 : 190;
    
    [_confirmButton setTitle:NSLocalizedString(@"mcs_ok", nil) forState:UIControlStateNormal];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancle)];
        self.navigationItem.leftBarButtonItem = item;
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    
    mcall_ctx_scene_get *ctx = [[mcall_ctx_scene_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(scene_get_done:);
    [_agent scene_get:ctx];
    [self loading:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MNInfoPromptView hideAll:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
-(void)cancle
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectScene:(id)sender {
    [self performSegueWithIdentifier:@"MNAccessorySceneViewController" sender:nil];
    
}

- (IBAction)confirm:(id)sender {
    if (_allDaySwitch.on) {
        for (mScene_obj *obj in self.sceneArray)
        {
            obj.flag =_allDaySwitch.on;
        }
    } else {
        for (mScene_obj *obj in self.sceneArray)
        {
            if ([obj.name isEqualToString:@"out"]) {
                obj.flag = _awaySwitch.on;
            }
            if ([obj.name isEqualToString:@"in"]) {
                obj.flag = _activeSwitch.on;
            }
        }
    }

    mcall_ctx_scene_set *ctx = [[mcall_ctx_scene_set alloc] init];
    ctx.target = self;
    ctx.on_event = @selector(scene_set_done:);
    ctx.all = 0;
    ctx.sn = _deviceID;
    ctx.sceneArray = self.sceneArray;
    ctx.select = self.selectScene;
    [_agent scene_set:ctx];
    [self loading:YES];
}

- (IBAction)openAllDayRecording:(id)sender
{
    _customRecordView.hidden = _allDaySwitch.on;
    _buttonToLabelLayoutConstraint.constant = _customRecordView.hidden ? 0 : 190;
}

#pragma mark - Call & Recall
-(void)scene_get_done:(mcall_ret_scene_get *)ret
{
    [self loading:NO];
    if (ret.result == nil) {
        _selectScene = ret.select;
        if ([ret.select isEqualToString:@"auto"])
        {
            _sceneLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"mcs_scenes", nil),NSLocalizedString(@"mcs_auto_mode", nil)];
        }
        else if ([ret.select isEqualToString:@"in"])
        {
            _sceneLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"mcs_scenes", nil),NSLocalizedString(@"mcs_home_mode", nil)];
        }
        else
        {
            _sceneLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"mcs_scenes", nil),NSLocalizedString(@"mcs_away_home_mode", nil)];
        }
        
        self.sceneArray = ret.sceneArray;
        for (mScene_obj *obj in self.sceneArray) {
            if ([obj.name isEqualToString:@"out"]) {
                _awaySwitch.on = obj.flag;
            }
            if ([obj.name isEqualToString:@"in"]) {
                _activeSwitch.on = obj.flag;
            }
        }
        if (_activeSwitch.on &&_awaySwitch.on) {
            _allDaySwitch.on = YES;
            _customRecordView.hidden = YES;
            _buttonToLabelLayoutConstraint.constant = _customRecordView.hidden ? 0 : 190;
        }
    }else {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
    }
}

-(void)scene_set_done:(mcall_ret_scene_set *)ret
{
    [self loading:NO];
    if (ret.result == nil) {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
    }else {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
    }
}

#pragma mark - prepareForSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MNAccessorySceneViewController *accessorySceneViewController = segue.destinationViewController;
    accessorySceneViewController.selectScene = _selectScene;
    accessorySceneViewController.agent = _agent;
    accessorySceneViewController.deviceID = _deviceID;
    accessorySceneViewController.accessoryVideoViewController = self;
}

#pragma mark - InterfaceOrientation
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
@end
