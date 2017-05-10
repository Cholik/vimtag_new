//
//  MNAddDeviceViewController.m
//  mipci
//
//  Created by mining on 15-1-14.
//
//
#import "MNAddDeviceViewController.h"
#import "mipc_agent.h"
#import "MNModifyPasswordViewController.h"
#import "MNModifyWIFIViewController.h"
#import "MNDeviceGuideViewController.h"
#import "MNModifyTimezoneViewController.h"
#import "AppDelegate.h"
#import "MIPCUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "MNQRCodeViewController.h"
#import "MNProgressHUD.h"
#import "MNDeviceListViewController.h"
#import "MNDeviceOfflineViewController.h"
#import "MNConfiguration.h"
#import "MNShowResultViewController.h"
#import "MNInfoPromptView.h"
#import "MNUserBehaviours.h"

@interface MNAddDeviceViewController ()

@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (assign, nonatomic) BOOL isViewAppearing;

@property (assign, nonatomic) long      wfc;
@property (assign, nonatomic) long      qrc;
@property (assign, nonatomic) long      snc;
@property (strong, nonatomic) NSString  *sncf;

@end

@implementation MNAddDeviceViewController

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

-(mipc_agent *)agent
{
    return self.app.cloudAgent;
}

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

-(MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_progressHUD];
        _progressHUD.color = [UIColor colorWithWhite:1.0f alpha:0.8f];
        _progressHUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        _progressHUD.labelText = NSLocalizedString(@"mcs_loading", nil);
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

#pragma mark - InitUI
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_add_device", nil);

    [_addDeviceButton setTitle:NSLocalizedString(@"mcs_action_next", nil) forState:UIControlStateNormal];
    [_addDeviceButton setTitleColor:self.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    _nameTextField.text = _deviceID;
    _passwordTextField.text = _devicePassword;
    _nameTextField.placeholder = NSLocalizedString(@"mcs_input_device_id", nil);
    _passwordTextField.placeholder = NSLocalizedString(@"mcs_input_password", nil);
    
    _devicePasswordView.hidden = YES;
    [_forgetPasswordButton setTitle:NSLocalizedString(@"mcs_forgot_your_password", nil) forState:UIControlStateNormal];
    [_forgetPasswordButton setTitleColor:self.app.is_vimtag || self.app.is_mipc ? self.app.configuration.switchTintColor : self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    _forgetPasswordButton.hidden = YES;
    [self initConstraint];
    if (self.is_scan || self.app.is_jump) {
        [self updateConstraint];
        _is_add = YES;
        [_addDeviceButton setTitle:NSLocalizedString(@"mcs_add", nil) forState:UIControlStateNormal];
    }
    
    _showPasswordBtn.selected = NO;
    [_showPasswordBtn setImage:[UIImage imageNamed:@"vt_eye_gray.png"] forState:UIControlStateNormal];
    if (self.app.is_luxcam) {
        [_userInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_passwordInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        
        [_addDeviceButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
        [_forgetPasswordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_cameraImage setImage:[UIImage imageNamed:@"user.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_red_on.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_addDeviceButton setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"vt_eye.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_ebitcam)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_addDeviceButton setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
        [_cameraImage setImage:[UIImage imageNamed:@"icon_camera.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_green_on.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_mipc)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_addDeviceButton setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
        [_cameraImage setImage:[UIImage imageNamed:@"icon_camera.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"mi_eye.png"] forState:UIControlStateSelected];
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_addDeviceButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        [_forgetPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cameraImage setImage:[UIImage imageNamed:@"icon_camera.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_green_on.png"] forState:UIControlStateSelected];
    }
}

-(void)initConstraint
{
    self.spaceToUserViewLayoutConstraint.constant = 15;
}

-(void)updateConstraint
{
    self.spaceToUserViewLayoutConstraint.constant = 74;
    
    _devicePasswordView.hidden = NO;
//    _forgetPasswordButton.hidden = NO;
}

#pragma mark - Viewlifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [self setNameTextField:nil];
    [self setPasswordTextField:nil];
    [self setAddDeviceButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _isViewAppearing = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [MNInfoPromptView hideAll:self.navigationController];
    _isViewAppearing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    if (self.app.is_jump)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)editingDidExit:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)addDevice:(id)sender
{
    m_dev *dev = [self.agent.devs get_dev_by_sn:_nameTextField.text];
    if (!_nameTextField.text || (_nameTextField.text.length == 0))
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_blank_device_id",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        
        return;
    }
    else if (dev)
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_existed",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        
        return;
    }
    if (_is_add && (!_passwordTextField.text || (_passwordTextField.text.length == 0)))
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_blank_password",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];

        return;
    }
    
    if ([_passwordTextField.text isEqualToString:@"amdin"]) {
        _passwordTextField.text = @"admin";
    }
    unsigned char encrypt_pwd[16] = {0};
    [mipc_agent passwd_encrypt:_passwordTextField.text encrypt_pwd:encrypt_pwd];
    mcall_ctx_dev_add *ctx = [[mcall_ctx_dev_add alloc] init];
    ctx.sn = _nameTextField.text.lowercaseString;
    ctx.passwd = encrypt_pwd;
    ctx.target = self;
    ctx.on_event = @selector(dev_add_done:);
    
    [self.agent dev_add:ctx];
    [self.progressHUD show:YES];
}

- (IBAction)qrcode:(id)sender
{
    if ([self checkCamera])
    {
        [self performSegueWithIdentifier:@"MNQRCodeViewController" sender:nil];
    }
}

- (BOOL)checkCamera
{
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
    if(nil == videoInput)
    {
        if(error.code == -11852)
        {
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
            NSString *title = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"mcs_please_allow", nil), appName, NSLocalizedString(@"mcs_access_camera", nil)];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:[NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"mcs_ios_privacy_setting_for_camera_prompt", nil),appName, NSLocalizedString(@"mcs_execute_change", nil)]
                                                           delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
                                                  otherButtonTitles: nil];
            [alert show];
        }
        return NO;
    }
    return YES;
}

- (IBAction)showPassword:(id)sender
{
    _showPasswordBtn.selected = !_showPasswordBtn.selected;
    _passwordTextField.secureTextEntry = !_showPasswordBtn.selected;
}

- (IBAction)forgotPassword:(id)sender
{
    [self performSegueWithIdentifier:@"MNForgetPasswordViewController" sender:nil];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNModifyPasswordViewController"]) {
        MNModifyPasswordViewController *modifyPasswordViewController = segue.destinationViewController;
        modifyPasswordViewController.deviceID = _nameTextField.text.lowercaseString;
        modifyPasswordViewController.oldPassword = _passwordTextField.text;
    }
    else if ([segue.identifier isEqualToString:@"MNDeviceOfflineViewController"])
    {
        MNDeviceOfflineViewController *deviceOfflineViewController = segue.destinationViewController;
        deviceOfflineViewController.deviceID = _nameTextField.text.lowercaseString;
        deviceOfflineViewController.wfc = _wfc;
        deviceOfflineViewController.qrc = _qrc;
        deviceOfflineViewController.snc = _snc;
        deviceOfflineViewController.sncf = _sncf;
        deviceOfflineViewController.wfcnr = _wfcnr;
    }
    else if ([segue.identifier isEqualToString:@"MNDeviceGuideViewController"])
    {
        MNDeviceGuideViewController *deviceGuideViewController = segue.destinationViewController;
        deviceGuideViewController.deviceID = _nameTextField.text.lowercaseString;
    }
    else if ([segue.identifier isEqualToString:@"MNModifyWIFIViewController"])
    {
        MNModifyWIFIViewController *modifyWIFIViewController = segue.destinationViewController;
        modifyWIFIViewController.deviceID = _nameTextField.text.lowercaseString;
    }
    else if ([segue.identifier isEqualToString:@"MNModifyTimezoneViewController"])
    {
        MNModifyTimezoneViewController *modifyTimezoneViewController = segue.destinationViewController;
        modifyTimezoneViewController.deviceID = _nameTextField.text.lowercaseString;
    }
    else if ([segue.identifier isEqualToString:@"MNQRCodeViewController"])
    {
        MNQRCodeViewController *qRCodeViewController = segue.destinationViewController;
        qRCodeViewController.addDeviceViewController = self;
    }else if ([segue.identifier isEqualToString:@"MNShowResultViewController"])
    {
        MNShowResultViewController *showResultViewController = segue.destinationViewController;
        showResultViewController.deviceID = _nameTextField.text.lowercaseString;
        showResultViewController.is_onlyAdd = YES;
    }
}

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
    print_log1(debug, "zxingController() is main thread:%d.", [NSThread isMainThread]);
    if(result && (result.length > 0))
    {
        struct len_str  sID = {0}, sPassword = {0}, sPasswordMD5 = {0}, sWifi = {0},
        sResult = {result.length, (char*)[result UTF8String]};
        if((0 == MIPC_ParseLineParams(&sResult, &sID, &sPassword, &sPasswordMD5, &sWifi))
           && sID.len)
        {
            //self.sUser = [NSString stringWithFormat:@"%*.*s", 0, (int)sID.len, sID.data];
            _nameTextField.text = [NSString stringWithFormat:@"%*.*s", 0, (int)sID.len, sID.data];
            //self.sPassword = [NSString stringWithFormat:@"%*.*s", 0, (int)sPassword.len, sPassword.data];
            _passwordTextField.text = [NSString stringWithFormat:@"%*.*s", 0, (int)sPassword.len, sPassword.data];
            [controller dismissViewControllerAnimated:YES completion:nil];
            return;
        }
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_qrcode",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Network callback
- (void)dev_add_done:(mcall_ret_dev_add*)ret
{
    if (!_isViewAppearing) {
        return;
    }
//    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
    if (nil == ret.result)
    {
//        MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaViours.dev_add_succ_times += 1;
//        BOOL isRight = [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
        
        if (_passwordTextField.text.length) {

           if (self.passwordTextField.text.length > 0 && self.passwordTextField.text.length < 6)
           {
               [self performSegueWithIdentifier:@"MNModifyPasswordViewController" sender:nil];
           }
           else
           {
               if ([ret.dev.wifi_status isEqualToString:@"none"] || [ret.dev.wifi_status isEqualToString:@"srvok"]) {
                   mcall_ctx_dev_info_get *ctx = [[mcall_ctx_dev_info_get alloc] init];
                   ctx.sn = _nameTextField.text.lowercaseString;
                   ctx.target = self;
                   ctx.on_event = @selector(dev_info_get_done:);
                   [self.agent dev_info_get:ctx];
               } else {
                   [self performSegueWithIdentifier:@"MNModifyWIFIViewController" sender:nil];
               }
//               //check connect wifi
//               mcall_ctx_net_get *ctx =[[mcall_ctx_net_get alloc] init];
//               ctx.sn = _nameTextField.text;
//               ctx.target = self;
//               ctx.on_event = @selector(net_get_done:);
//               
//               [self.agent net_get:ctx];
               
           }
        }
    }
    else if([ret.result isEqualToString:@"ret.user.unknown"])
    {
        [self.progressHUD hide:YES];
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_dev",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else if([ret.result isEqualToString:@"ret.dev.offline"])
    {
        if (_is_wifiConfig) {
            [self performSegueWithIdentifier:@"MNDeviceOfflineViewController" sender:nil];
        } else {
            mcall_ctx_cap_get *ctx = [[mcall_ctx_cap_get alloc] init];
            ctx.sn = _nameTextField.text.lowercaseString;
            ctx.filter = nil;
            ctx.target = self;
            ctx.on_event = @selector(cap_get_done:);
            [self.agent cap_get:ctx];
        }
    }
    else if([ret.result isEqualToString:@"ret.pwd.invalid"])
    {
        [self updateConstraint];

        [_addDeviceButton setTitle:NSLocalizedString(@"mcs_action_add", nil) forState:UIControlStateNormal];
        if (_is_add) {
            mcall_ctx_cap_get *ctx = [[mcall_ctx_cap_get alloc] init];
            ctx.sn = _nameTextField.text.lowercaseString;
            ctx.filter = nil;
            ctx.target = self;
            ctx.on_event = @selector(cap_get_prompt_done:);
            [self.agent cap_get:ctx];
        } else {
            [self.progressHUD hide:YES];
            [MNInfoPromptView hideAll:self.navigationController];
        }
        _is_add = YES;
    }
    else if([ret.result isEqualToString:@"ret.permission.denied"])
    {
        [self.progressHUD hide:YES];
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else if ([ret.result isEqualToString:@"ret.subdev.exceed"])
    {
        [self.progressHUD hide:YES];
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_devices_in_the_account_overrun", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else
    {
//        MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaViours.dev_add_fail_times += 1;
//        BOOL isRight = [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
 
        [self.progressHUD hide:YES];
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_add_device_failed",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

- (void)dev_info_get_done:(mcall_ret_dev_info_get *)ret
{
    if (!_isViewAppearing)
    {
        return;
    }
    
    if (nil == ret.result && ret.timezone.length)
    {
        NSTimeInterval phoneTimezone = [self getTimeIntervalBetweenTimeZoneAndUTC];
        if ([ret.timezone intValue]*60*60 != phoneTimezone) {
            [self performSegueWithIdentifier:@"MNModifyTimezoneViewController" sender:nil];
            return;
        }
    }
    [self performSegueWithIdentifier:@"MNShowResultViewController" sender:nil];
}

#pragma mark - cap_get_done
- (void)cap_get_done:(mcall_ret_cap_get *)ret
{
    if (!_isViewAppearing) {
        return;
    }
    [self.progressHUD hide:YES];
    if (nil == ret.result) {
        __weak typeof (self) weakSelf = self;
        //        if (1) {
        if (ret.wfc == 1 || ret.qrc == 1 || ret.snc == 1 || self.app.developerOption.QRSwitch || self.app.developerOption.soundsSwitch || self.app.developerOption.normalSwitch) {
            if (self.app.developerOption.QRSwitch || self.app.developerOption.soundsSwitch || self.app.developerOption.normalSwitch) {
                _wfc = self.app.developerOption.normalSwitch;
                _qrc = self.app.developerOption.QRSwitch;
                _snc = self.app.developerOption.soundsSwitch;
            } else {
                _wfc = ret.wfc;
                _qrc = ret.qrc;
                _snc = ret.snc;
            }
            
            _sncf = ret.sncf;
            _wfcnr = ret.wfcnr;
            [weakSelf performSegueWithIdentifier:@"MNDeviceOfflineViewController" sender:nil];
        }
        else {
            [weakSelf performSegueWithIdentifier:@"MNDeviceGuideViewController" sender:nil];
        }
    }
}

- (void)cap_get_prompt_done:(mcall_ret_cap_get *)ret
{
    if (!_isViewAppearing) {
        return;
    }
    [self.progressHUD hide:YES];
    if (nil == ret.result) {
        _wfc = ret.wfc;
        _qrc = ret.qrc;
        _snc = ret.snc;
        _sncf = ret.sncf;
        _wfcnr = ret.wfcnr;
    }
    [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_password",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    _forgetPasswordButton.hidden = NO;
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
