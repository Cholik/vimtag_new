//
//  MNModifyTimezoneViewController.m
//  mipci
//
//  Created by mining on 16/11/7.
//
//

#import "MNModifyTimezoneViewController.h"
#import "MNDeviceListSetViewController.h"
#import "MNDeviceListViewController.h"
#import "MNShowResultViewController.h"
#import "MNTimezoneListViewController.h"

#import "AppDelegate.h"
#import "MNProgressHUD.h"
#import "MNToastView.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"
#import "mipc_timezone_manager.h"
#import "DeviceInfo.h"

@interface MNModifyTimezoneViewController ()

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (strong, nonatomic) mcall_ret_time_get *timeRet;
@property (assign, nonatomic) BOOL is_timezoneModify;
@property (strong, nonatomic) DeviceInfo *dev_obj;

@end

@implementation MNModifyTimezoneViewController
- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

- (mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

- (MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_progressHUD];
        _progressHUD.color = [UIColor colorWithWhite:1.0f alpha:0.8f];
        _progressHUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        _progressHUD.labelText = NSLocalizedString(@"mcs_request_send", nil);
        _progressHUD.labelColor = [UIColor grayColor];
        if (self.app.is_vimtag) {
            _progressHUD.activityIndicatorColor = [UIColor colorWithRed:0 green:168.0/255 blue:185.0/255 alpha:1.0f];
        }
        else {
            _progressHUD.activityIndicatorColor = [UIColor grayColor];
        }
        
    }
    
    return  _progressHUD;
}

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_timezone_change", nil);
    self.navigationItem.hidesBackButton = YES;
    
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSDate *currentDate = [NSDate date];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:currentDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:currentDate];
    NSTimeInterval interval = (destinationGMTOffset - sourceGMTOffset)/(60*60);
    NSString *gmtString = [NSString string];
    if (interval >= 10) {
        gmtString = [NSString stringWithFormat:@"(GMT+%d:00)", (int)interval];
    } else if (interval >0) {
        gmtString = [NSString stringWithFormat:@"(GMT+0%d:00)", (int)interval];
    } else if (interval == 0) {
        gmtString = [NSString stringWithFormat:@"(GMT+0%d:00)", (int)interval];

    } else if (interval > -10) {
        gmtString = [NSString stringWithFormat:@"(GMT-0%d:00)", (int)(-interval)];
    } else {
        gmtString = [NSString stringWithFormat:@"(GMT-%d:00)", (int)(-interval)];
    }
    
    _phoneTimezoneLabel.text = [NSString stringWithFormat:@"%@:%@%@", NSLocalizedString(@"mcs_phone_timezone", nil), destinationTimeZone.name, gmtString];
    _promptLabel.text = NSLocalizedString(@"mcs_device_or_phone_time_zone_not_equals_please_select", nil);
    
    [_modifyButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    [_skipButton setTitle:NSLocalizedString(@"mcs_action_skip", nil) forState:UIControlStateNormal];
    
    if (self.app.is_luxcam) {
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
        [_modifyButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_skipButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        _phoneTimezoneLabel.textColor = self.configuration.labelTextColor;
        _promptLabel.textColor = self.configuration.labelTextColor;
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_modifyButton setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
        [_skipButton setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
    }
    else if (self.app.is_ebitcam)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_modifyButton setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
        [_skipButton setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
        _phoneTimezoneLabel.textColor = self.configuration.labelTextColor;
        _promptLabel.textColor = self.configuration.labelTextColor;
    }
    else if (self.app.is_mipc)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_modifyButton setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
        [_skipButton setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
        _phoneTimezoneLabel.textColor = self.configuration.labelTextColor;
        _promptLabel.textColor = self.configuration.labelTextColor;
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_modifyButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        [_skipButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        _phoneTimezoneLabel.textColor = self.configuration.labelTextColor;
        _promptLabel.textColor = self.configuration.labelTextColor;
    }
    
    _skipButton.hidden = _is_playModify ? YES : NO;
    _remindView.hidden = _is_playModify ? NO : YES;
    _remindLabel.text = NSLocalizedString(@"mcs_donot_remind", nil);
    _remindLabel.textColor = self.configuration.labelTextColor;
    _remindSwitch.on = NO;
    _remindSwitch.onTintColor = self.configuration.switchTintColor;
    if (_is_playModify) {
        NSData *deviceData = [[NSUserDefaults standardUserDefaults] dataForKey:[NSString stringWithFormat:@"DeviceInfo_%@",_deviceID]];
        if (deviceData) {
            _dev_obj = [NSKeyedUnarchiver unarchiveObjectWithData:deviceData];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    
    mcall_ctx_time_get *ctx = [[mcall_ctx_time_get alloc] init];
    ctx.sn = _deviceID;
    ctx.on_event = @selector(dev_timezone_get_done:);
    ctx.target = self;
    
    [self.agent dev_timezone_get:ctx];
    [self.progressHUD show:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_is_playModify) {
        DeviceInfo *obj = [[DeviceInfo alloc] init];
        obj.resolution = _dev_obj.resolution;
        obj.hideUpgradeTips = _dev_obj.hideUpgradeTips;
        obj.hideTimezoneTips = _remindSwitch.on;
        NSData *deviceData = [NSKeyedArchiver archivedDataWithRootObject:obj];
        [[NSUserDefaults standardUserDefaults] setObject:deviceData forKey:[NSString stringWithFormat:@"DeviceInfo_%@",_deviceID]];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action
- (IBAction)close:(id)sender
{
    if (_is_playModify) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (self.is_notAdd) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (self.is_loginModify)
    {
        if (self.app.is_luxcam)
        {
            if (self.presentingViewController && !self.app.is_jump)
            {
                UINavigationController *rootNavigationcontroller = (UINavigationController*)self.presentingViewController;
                for (UIViewController *viewController in rootNavigationcontroller.viewControllers)
                {
                    if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                        [((MNDeviceListViewController*)viewController) refreshData];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }
            else
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else if (self.app.is_vimtag)
        {
            UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil];
            MNDeviceListSetViewController *deviceListSetViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceListSetViewController"];
            [self.navigationController pushViewController:deviceListSetViewController animated:YES];
        }
        else
        {
            if (self.presentingViewController && !self.app.is_jump)
            {
                UINavigationController *rootNavigationcontroller = (UINavigationController*)self.presentingViewController;
                for (UIViewController *viewController in rootNavigationcontroller.viewControllers)
                {
                    if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                        [((MNDeviceListViewController*)viewController) refreshData];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }
            else
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    else
    {
        if (self.app.is_vimtag) {
            if (self.presentingViewController) {
                UITabBarController *rootTabBarController = (UITabBarController*)self.presentingViewController;
                for (UINavigationController *navigationController in rootTabBarController.viewControllers) {
                    for (UIViewController *viewController in navigationController.viewControllers) {
                        if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                            MNDeviceListViewController *deviceListViewController = ((MNDeviceListSetViewController *)viewController).deviceListViewController;
                            [deviceListViewController refreshData];
                        }
                    }
                }
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }
        }
        else
        {
            if (self.presentingViewController && !self.app.is_jump)
            {
                UINavigationController *rootNavigationcontroller = (UINavigationController*)self.presentingViewController;
                for (UIViewController *viewController in rootNavigationcontroller.viewControllers)
                {
                    if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                        [((MNDeviceListViewController*)viewController) refreshData];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }
            else
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

- (IBAction)selectTimezone:(id)sender
{
    [self performSegueWithIdentifier:@"MNTimezoneListViewController" sender:nil];
}

- (IBAction)modify:(id)sender
{
    mcall_ctx_time_set *ctx = [[mcall_ctx_time_set alloc] init];
    ctx.target = self;
    ctx.on_event = @selector(time_set_done:);
    ctx.sn      = _deviceID;
    
    ctx.auto_sync = _timeRet.auto_sync;
    ctx.time_zone = _timezone_obj ? (_timezone_obj.city ? [NSString stringWithFormat:@"%@",_timezone_obj.city] : _timezone_obj.utc) : _timeRet.time_zone;
    ctx.ntp_addr = _timeRet.ntp_addr;
    
    [self.agent time_set:ctx];
    [self.progressHUD show:YES];
}

- (IBAction)skip:(id)sender
{
    _is_timezoneModify = NO;
    if (self.app.isLoginByID) {
        UINavigationController *navigationController = (UINavigationController *)self.presentingViewController;
        for (UIViewController *viewController in navigationController.viewControllers) {
            if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                [((MNDeviceListViewController *)viewController) loadingDeviceData];
            }
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"MNShowResultViewController" sender:nil];
    }
}

#pragma mark - Network Callback
- (void)dev_timezone_get_done:(mcall_ret_time_get *)ret
{
    [self.progressHUD hide:YES];
    
    if (ret.result == nil) {
        _timeRet = ret;
        NSString *city = NSLocalizedString(TIMEZONE_CITY[ret.time_zone], nil);
        _deviceTimezoneLabel.text = city.length ? [NSString stringWithFormat:@"%@",city] : ret.time_zone;
    }
}

#pragma mark - time_set_done
- (void)time_set_done:(mcall_ret_time_set *)ret
{
    [self.progressHUD hide:YES];
    
    if (nil == ret.result)
    {
        _is_timezoneModify = YES;
        if (_is_playModify) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self performSegueWithIdentifier:@"MNShowResultViewController" sender:nil];
        }
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
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

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNTimezoneListViewController"]) {
        MNTimezoneListViewController *timezoneListViewController = segue.destinationViewController;
        timezoneListViewController.deviceID = _deviceID;
        timezoneListViewController.modifyTimezoneViewController = self;
        timezoneListViewController.selectedTimetone = _deviceTimezoneLabel.text;
        timezoneListViewController.rootNavigationController = self.navigationController;
    } else if ([segue.identifier isEqualToString:@"MNShowResultViewController"]) {
        MNShowResultViewController *showResultViewController = segue.destinationViewController;
        showResultViewController.deviceID = _deviceID;
        showResultViewController.is_onlyAdd = NO;
        showResultViewController.is_changePwd = _isChangePwd;
        showResultViewController.is_connectWiFi = _is_connectWiFi;
        showResultViewController.is_notAdd = _is_notAdd;
        showResultViewController.is_loginModify = _is_loginModify;
        showResultViewController.is_timezoneModify = _is_timezoneModify;
    }
}

#pragma mark - Rotate
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
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
