//
//  MNSetMotionTableViewController.m
//  mipci
//
//  Created by mining on 16/6/24.
//
//

#import "MNSetMotionTableViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MNInfoPromptView.h"

@interface MNSetMotionTableViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *nightLabel;
@property (weak, nonatomic) IBOutlet UILabel *daySensitivityLabel;
@property (weak, nonatomic) IBOutlet UILabel *nightSensitivityLabel;
@property (weak, nonatomic) IBOutlet UISlider *daySensitivitySlider;
@property (weak, nonatomic) IBOutlet UISlider *nightSensitivitySlider;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
//@property (weak, nonatomic) AppDelegate *app;
//@property (strong, nonatomic) NSString *src;

@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;

@property (weak, nonatomic) IBOutlet UILabel *awayLabel;
@property (weak, nonatomic) IBOutlet UIButton *awayAlertBtn;
@property (weak, nonatomic) IBOutlet UIButton *awayVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *awayPhotoBtn;
@property (weak, nonatomic) IBOutlet UILabel *activeLabel;
@property (weak, nonatomic) IBOutlet UIButton *activeAlertBtn;
@property (weak, nonatomic) IBOutlet UIButton *activeVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *activePhotoBtn;
@property (copy, nonatomic) NSString *exdevID;

@end

@implementation MNSetMotionTableViewController

#pragma mark - initUI
-(void)initUI
{
    self.dayLabel.text = NSLocalizedString(@"mcs_daytime", nil);
    self.nightLabel.text = NSLocalizedString(@"mcs_night", nil);
    [self.applyButton setTitle:NSLocalizedString(@"mcs_action_apply", nil) forState:UIControlStateNormal];
    _awayLabel.text = NSLocalizedString(@"mcs_away_home_mode", nil);
    _activeLabel.text = NSLocalizedString(@"mcs_home_mode", nil);
    
    mScene_obj *obj = _sceneArray[1];
    sceneExdev_obj *exdev = obj.exDevs[0];
    _idLabel.text = [NSString stringWithFormat:@"ID:%@",exdev.exdev_id];
    _exdevID = exdev.exdev_id;
    _typeImageView.image = [UIImage imageNamed:@"vt_move"];
    _typeLabel.text = NSLocalizedString(@"mcs_motion", nil);
    _idLabel.text = [NSString stringWithFormat:@"ID:%@",exdev.exdev_id];
    for (mScene_obj *obj in _sceneArray) {
        if ([obj.name isEqualToString:@"out"]) {
            mExDev_obj *exdev = obj.exDevs[0];
            _awayAlertBtn.selected = (exdev.flag & 4) ? YES : NO;
            _awayPhotoBtn.selected = (exdev.flag & 2) ? YES : NO;
            _awayVideoBtn.selected = (exdev.flag & 1) ? YES : NO;
        }
        if ([obj.name isEqualToString:@"in"]) {
            mExDev_obj *exdev = obj.exDevs[0];
            _activeAlertBtn.selected = (exdev.flag & 4) ? YES : NO;
            _activePhotoBtn.selected = (exdev.flag & 2) ? YES : NO;
            _activeVideoBtn.selected = (exdev.flag & 1) ? YES : NO;
        }
    }
    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    [self initUI];
    
    mcall_ctx_trigger_action_get *triggerCtx = [[mcall_ctx_trigger_action_get alloc] init];
    triggerCtx.sn = _deviceID;
    triggerCtx.on_event = @selector(alarm_trigger_get_done:);
    triggerCtx.target = self;
    [_agent alarm_trigger_get:triggerCtx];
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

#pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSString *headerTitle;
    
    switch (section) {
        case 1:
            headerTitle = NSLocalizedString(@"mcs_motion_detection_sensitivity", nil);
            break;
        case 2:
            headerTitle = NSLocalizedString(@"mcs_Scene_set", nil);
            break;
        default:
            headerTitle = nil;
            break;
    }
    return headerTitle;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else {
        return 30;
    }
}

#pragma mark - Action
- (IBAction)daySensitivitySliderChange:(id)sender {
    UISlider *slider = sender;
    int daySensitivity = (int)slider.value;
    self.daySensitivityLabel.text = [NSString stringWithFormat:@"%d",daySensitivity];
}

- (IBAction)nightSensitivitySliderChange:(id)sender {
    UISlider *slider = sender;
    int nightSensitivity = (int)slider.value;
    self.nightSensitivityLabel.text = [NSString stringWithFormat:@"%d",nightSensitivity];
}

- (IBAction)apply:(id)sender {
    
    for (mScene_obj *obj in _sceneArray) {
        if ([obj.name isEqualToString:@"out"]) {
            mExDev_obj *exdev = obj.exDevs[0];
            exdev.flag = _awayAlertBtn.selected * 4 + _awayPhotoBtn.selected * 2 + _awayVideoBtn.selected;
        }
        if ([obj.name isEqualToString:@"in"]) {
            mExDev_obj *exdev = obj.exDevs[0];
            exdev.flag = _activeAlertBtn.selected * 4 + _activePhotoBtn.selected * 2 + _activeVideoBtn.selected;
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

- (IBAction)eventSet:(id)sender {
    UIButton *button = sender;
    button.selected = !button.selected;
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Call & ReCall
-(void)scene_set_done:(mcall_ret_scene_set *)ret
{
    if (ret.result == nil) {
        mcall_ctx_trigger_action_set *triggerCtx = [[mcall_ctx_trigger_action_set alloc] init];
        triggerCtx.sn =_deviceID;
        triggerCtx.target = self;
        triggerCtx.on_event = @selector(alarm_trigger_set_done:);
        triggerCtx.sensitivity = [_daySensitivityLabel.text intValue];
        triggerCtx.night_sensitivity = [_nightSensitivityLabel.text intValue];
        [_agent alarm_trigger_set:triggerCtx];
    } else {
        [self loading:NO];
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}
- (void)alarm_trigger_get_done:(mcall_ret_trigger_action_get*)ret
{
    [self loading:NO];
    
    if(nil != ret.result)
    {
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
            return;
        }
    }
    
    self.daySensitivitySlider.value = ret.sensitivity ;
    self.daySensitivityLabel.text = [NSString stringWithFormat:@"%d",ret.sensitivity];
    [_daySensitivitySlider sendActionsForControlEvents:UIControlEventValueChanged];
    
    self.nightSensitivitySlider.value = ret.night_sensitivity;
    self.nightSensitivityLabel.text = [NSString stringWithFormat:@"%d",ret.sensitivity];
    [_nightSensitivitySlider sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)alarm_trigger_set_done:(mcall_ret_trigger_action_set *)ret
{
    [self loading:NO];
    
    if (nil == ret.result)
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
        [_deviceAccessoryViewController refreshData];
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
    }
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
