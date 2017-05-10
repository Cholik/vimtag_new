//
//  MNModifyWIFIViewController.m
//  mipci
//
//  Created by mining on 15-1-16.
//
//

#import "MNModifyWIFIViewController.h"
#import "MNWIFIListViewController.h"
#import "AppDelegate.h"
#import "MNDeviceListViewController.h"
#import "MNProgressHUD.h"
#import "MNToastView.h"
#import "MNConfiguration.h"
#import "MNShowResultViewController.h"
#import "MNModifyTimezoneViewController.h"
#import "MNInfoPromptView.h"
#import "MIPCUtils.h"
#import "MNDeviceListSetViewController.h"

#define PASSWORD_FORCHECK @"lk9ds2*%#%dq"

@interface MNModifyWIFIViewController ()
{
    long                                _isSelfOrginFrameActive;
    CGRect                              _selfOrginFrame;
}
@property (assign, nonatomic) int overTime;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (strong, nonatomic) NSTimer *wifiConnectTimer;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (assign, nonatomic) BOOL      is_connectWiFi;
@property (assign, nonatomic) BOOL modifyTimezone;

@end

@implementation MNModifyWIFIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

-(MNProgressHUD *)progressHUD
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

-(void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_action_config_wifi", nil);
    self.navigationItem.hidesBackButton = YES;
    
    NSString *name = [NSString stringWithFormat:@"%@ : ", NSLocalizedString(@"mcs_device_id", nil)];
    _deviceIDHintLabel.text = [name stringByAppendingString:_deviceID];

    _deviceIDHintLabel.textColor = self.configuration.labelTextColor;
    
    _promaptLabel.text = NSLocalizedString(@"mcs_wifi_network_prompt", nil);
    self.app.is_vimtag ? nil : (_promaptLabel.textColor = self.configuration.labelTextColor);
    
    _WIFINameTextField.placeholder = NSLocalizedString(@"mcs_input_wifi_name", nil);
    _passwordTextField.placeholder = NSLocalizedString(@"mcs_input_password", nil);
    
    _showPasswordBtn.selected = NO;
    [_showPasswordBtn setImage:[UIImage imageNamed:@"vt_eye_gray.png"] forState:UIControlStateNormal];
    
    [_applyButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    [_skipButton setTitle:NSLocalizedString(@"mcs_action_skip", nil) forState:UIControlStateNormal];
    [_applyButton setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    [_skipButton setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    if (self.app.is_luxcam) {
        [_wifiInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_passwordInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_applyButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_skipButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
        [_wifiImage setImage:[UIImage imageNamed:@"wifi_icon.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"password.png"]];
        [_selectWiFiBtn setImage:[UIImage imageNamed:@"vt_chosen_Wi-Fi.png"] forState:UIControlStateNormal];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_red_on.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_applyButton setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
        [_skipButton setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"vt_eye.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_ebitcam)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_applyButton setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
        [_skipButton setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
        [_wifiImage setImage:[UIImage imageNamed:@"icon_wifi.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_selectWiFiBtn setImage:[UIImage imageNamed:@"btn_right_arrow.png"] forState:UIControlStateNormal];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_green_on.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_mipc)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_applyButton setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
        [_skipButton setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
        [_wifiImage setImage:[UIImage imageNamed:@"icon_wifi.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_selectWiFiBtn setImage:[UIImage imageNamed:@"btn_right_arrow.png"] forState:UIControlStateNormal];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"mi_eye.png"] forState:UIControlStateSelected];
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_applyButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        [_skipButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        [_wifiImage setImage:[UIImage imageNamed:@"icon_wifi.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_selectWiFiBtn setImage:[UIImage imageNamed:@"btn_right_arrow.png"] forState:UIControlStateNormal];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_green_on.png"] forState:UIControlStateSelected];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillHideNotification object:nil];
    
    mcall_ctx_dev_info_get *ctx = [[mcall_ctx_dev_info_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(dev_info_get_done:);
    [self.agent dev_info_get:ctx];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_is_exit) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [MNInfoPromptView hideAll:self.navigationController];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
    if (_wifiConnectTimer != nil) {
        [_wifiConnectTimer invalidate];
        _wifiConnectTimer = nil;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)showPassword:(id)sender {
    _showPasswordBtn.selected = !_showPasswordBtn.selected;
    _passwordTextField.secureTextEntry = !_showPasswordBtn.selected;
}

- (IBAction)close:(id)sender {
    if (self.is_notAdd) {
        //        [self.navigationController popToViewController:self.deviceListViewController animated:YES];
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
//            MNDeviceListPageViewController *deviceListPageViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceListPageViewController"];
//            [self.navigationController pushViewController:deviceListPageViewController animated:YES];
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
//                        if ([viewController isMemberOfClass:[MNDeviceListPageViewController class]]) {
//                            MNDeviceListViewController *deviceListViewController= [((MNDeviceListPageViewController*)viewController).viewControllerArray firstObject];
//                            [deviceListViewController refreshData];
//                        }
                        if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                            MNDeviceListViewController *deviceListViewController = ((MNDeviceListSetViewController *)viewController).deviceListViewController;
                            [deviceListViewController refreshData];
                        }
                    }
                }
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }
        } else 
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

- (IBAction)btnCheck:(id)sender {
//    _promptSwitch.on = _promptSwitch.on ? 0 : 1;
}

- (IBAction)modify:(id)sender
{
    if (nil == _WIFINameTextField.text
        || 0 == _WIFINameTextField.text.length)
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_input_wifi_name", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];

        return;
    }
    
    net_obj *net_o          = [[net_obj alloc] init];
    net_o.enable            =   YES;
    net_o.token             = @"ra0";
    
    net_info_obj *info      = [[net_info_obj alloc] init];
    
    net_o.use_wifi_ssid     =  _WIFINameTextField.text;
    net_o.use_wifi_passwd   = _passwordTextField.text;
    info.mode               = @"wificlient";
    net_o.info              = info;
    
    ip_obj *ip_o = [[ip_obj alloc] init] ;
    ip_o.enable = YES;
    ip_o.dhcp = YES;
    ip_o.ip = @"0:0:0:0";
    ip_o.gateway = @"0:0:0:0";;
    ip_o.mask = @"0:0:0:0";
    net_o.ip = ip_o;
    
    dns_obj *dns_o = [[dns_obj alloc] init];
    dns_o.dns = @"0:0:0:0";
    dns_o.secondary_dns = @"0:0:0:0";
    dns_o.enable = YES;
    dns_o.dhcp = YES;
    
    mcall_ctx_net_set *ctx = [[mcall_ctx_net_set alloc] init];
    ctx.sn = _deviceID;
    ctx.dns = dns_o;
    ctx.networks = @[net_o];
    ctx.on_event = @selector(net_set_done:);
    ctx.target = self;
    
    [self.agent net_set:ctx];
    [self.progressHUD show:YES];
}

- (IBAction)skipOperation:(id)sender
{
    if (self.app.isLoginByID) {
        if (!_isChangePwd && !_is_connectWiFi) {
            if (_modifyTimezone) {
                [self performSegueWithIdentifier:@"MNModifyTimezoneViewController" sender:nil];
            } else {
                UINavigationController *navigationController = (UINavigationController *)self.presentingViewController;
                for (UIViewController *viewController in navigationController.viewControllers) {
                    if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                        [((MNDeviceListViewController *)viewController) loadingDeviceData];
                    }
                }
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else {
            if (_modifyTimezone) {
                [self performSegueWithIdentifier:@"MNModifyTimezoneViewController" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"MNShowResultViewController" sender:nil];
            }
        }
    }
    else
    {
        if (_modifyTimezone) {
            [self performSegueWithIdentifier:@"MNModifyTimezoneViewController" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"MNShowResultViewController" sender:nil];
        }
    }
}

- (IBAction)WIFISelect:(id)sender
{
    [self performSegueWithIdentifier:@"MNWIFIListViewController" sender:nil];
}

- (IBAction)editingDidEnd:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - dev_info_get_done
- (void)dev_info_get_done:(mcall_ret_dev_info_get *)ret
{    
    if (nil == ret.result && ret.timezone.length)
    {
        NSTimeInterval phoneTimezone = [self getTimeIntervalBetweenTimeZoneAndUTC];
        if ([ret.timezone intValue]*60*60 != phoneTimezone) {
            _modifyTimezone = YES;
            return;
        }
    }
}

#pragma mark - net_set_done
- (void)net_set_done:(mcall_ret_net_set*)ret
{
    if (nil == ret.result) {
        _progressHUD.labelText = NSLocalizedString(@"mcs_connecting", nil);
        _wifiConnectTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timeOut) userInfo:nil repeats:YES];
        [self checkDeviceLink];
        
    }
    else
    {
        [self.progressHUD hide:YES];
    }
}

#pragma mark - net_get_done
- (void)net_get_done:(mcall_ret_net_get *)ret
{
    if (!_isViewAppearing)
    {
        return;
    }
    
    if(nil != ret.result || nil == ret.networks)
    {
        [self.progressHUD hide:YES];

        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];

        if (_wifiConnectTimer != nil) {
            [_wifiConnectTimer invalidate];
            _wifiConnectTimer = nil;
        }
        return;
    }
//
    net_obj *netObj = ret.networks[1];
    NSString *wifiStatus = netObj.use_wifi_status;
    
    if ([wifiStatus isEqualToString:@"ok"])
    {
        [self.progressHUD hide:YES];
//        _connectStatusLabel.text = NSLocalizedString(@"mcs_wifi_config_success", nil);
        _is_connectWiFi = YES;
        if (_wifiConnectTimer != nil) {
            [_wifiConnectTimer invalidate];
            _wifiConnectTimer = nil;
        }
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_modifyTimezone) {
                [weakSelf performSegueWithIdentifier:@"MNModifyTimezoneViewController" sender:nil];
            } else {
                [weakSelf performSegueWithIdentifier:@"MNShowResultViewController" sender:nil];
            }
        });
    } else {
        [self performSelector:@selector(checkDeviceLink) withObject:nil afterDelay:5.0];
         _is_connectWiFi = NO;
    }
    
}

#pragma mark - TimerAction
- (void)checkDeviceLink
{
    
    mcall_ctx_net_get *ctx =[[mcall_ctx_net_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(net_get_done:);
    
    [self.agent net_get:ctx];
}

#pragma mark - connectTimeOut
- (void)timeOut
{
    [self.progressHUD hide:YES];
    [_wifiConnectTimer invalidate];
    self.view.userInteractionEnabled = YES;
    [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_state_config_wifi_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];

    return ;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNWIFIListViewController"]) {
        MNWIFIListViewController *WIFIListViewController = segue.destinationViewController;
        WIFIListViewController.deviceID = _deviceID;
        WIFIListViewController.modifyWIFIViewController = self;
    } else if ([segue.identifier isEqualToString:@"MNShowResultViewController"]){
        MNShowResultViewController *showResultViewController = segue.destinationViewController;
        showResultViewController.deviceID = _deviceID;
        showResultViewController.is_onlyAdd = NO;
        showResultViewController.is_changePwd = _isChangePwd;
        showResultViewController.is_connectWiFi = _is_connectWiFi;
        showResultViewController.is_notAdd = _is_notAdd;
        showResultViewController.is_loginModify = _is_loginModify;
//        showResultViewController.deviceListViewController = self.deviceListViewController;
    } else if ([segue.identifier isEqualToString:@"MNModifyTimezoneViewController"]) {
        MNModifyTimezoneViewController *modifyTimezoneViewController = segue.destinationViewController;
        modifyTimezoneViewController.deviceID = _deviceID;
        modifyTimezoneViewController.is_onlyAdd = NO;
        modifyTimezoneViewController.isChangePwd = _isChangePwd;
        modifyTimezoneViewController.is_connectWiFi = _is_connectWiFi;
        modifyTimezoneViewController.is_notAdd = _is_notAdd;
        modifyTimezoneViewController.is_loginModify = _is_loginModify;
    }
}

#pragma mark Responding to keyboard events
-(void)keyboardWillShow:(NSNotification *)notification
{
    if (self.view.frame.size.height > 500) {
        return;
    }
    
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
    
    CGRect  newFrame, selfFrame = self.view.frame;
    if([notification.name isEqualToString:@"UIKeyboardWillHideNotification"])
    {
        newFrame = _selfOrginFrame;
        _isSelfOrginFrameActive = 0;
    }
    else
    {
        UIView  *checkView = _passwordTextField;
        
        CGRect  appRect = [[UIScreen mainScreen] applicationFrame];
        int app_width = appRect.size.width,
        app_height = appRect.size.height,
        offsetx = checkView.frame.origin.x + checkView.frame.size.width,
        offsety = checkView.frame.origin.y + checkView.frame.size.height;
        
        checkView = checkView.superview;
        while(checkView && (checkView != self.view))
        {
            offsety += checkView.frame.origin.y;
            offsetx += checkView.frame.origin.x;
            checkView = checkView.superview;
        }
        
        
        if(0 == _isSelfOrginFrameActive)
        {
            _selfOrginFrame = selfFrame;
            _isSelfOrginFrameActive = 1;
        }
        newFrame = selfFrame;
        
        
        switch(self.interfaceOrientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
            {
                newFrame.origin.x = (app_width - offsety) - keyboardBounds.size.width - 10;
                break;
            }
            case UIInterfaceOrientationLandscapeRight:
            {
                newFrame.origin.x = keyboardBounds.size.width - (app_width - offsety) + 30;
                break;
            }
            default /* case UIInterfaceOrientationPortrait */:
            {
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                    newFrame.origin.y = (app_height - offsety) - keyboardBounds.size.height + 15;
                break;
            }
        }
    }
    
    //  NSLog(@"offset is %f %f", newFrame.origin.x, newFrame.origin.y);
    [UIView beginAnimations:@"anim" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    //处理移动事件，将各视图设置最终要达到的状态
    
    self.view.frame = newFrame;
    
    [UIView commitAnimations];
}

- (NSTimeInterval)getTimeIntervalBetweenTimeZoneAndUTC
{
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSDate *currentDate = [NSDate date];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:currentDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:currentDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    return interval;
}

@end
