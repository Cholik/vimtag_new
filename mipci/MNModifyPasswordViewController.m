//
//  MNModifyPasswordViewController.m
//  mipci
//
//  Created by mining on 15-1-12.
//
//

#import "MNModifyPasswordViewController.h"
#import "mipc_agent.h"
#import "MNModifyWIFIViewController.h"
#import "MNDeviceListViewController.h"
#import "MNModifyTimezoneViewController.h"
#import "AppDelegate.h"
#import "MNProgressHUD.h"
#import "MNConfiguration.h"
#import "MNDeviceListViewController.h"
#import "MNShowResultViewController.h"
#import "MNInfoPromptView.h"
#import "UserInfo.h"

@interface MNModifyPasswordViewController ()
{
    unsigned char    _encrypt_pwd[16];
    long                                _isSelfOrginFrameActive;
    CGRect                              _selfOrginFrame;
}
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (assign, nonatomic) BOOL is_wifiModule;
@property (strong, nonatomic) NSString *tmpPassword;

@end

@implementation MNModifyPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
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

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_modify_password", nil);
    self.navigationItem.hidesBackButton = YES;
    
    _tmpPassword = @"";
    NSString *name = [NSString stringWithFormat:@"%@ : ", NSLocalizedString(@"mcs_device_id", nil)];
    _deviceIDHintLabel.text = [name stringByAppendingString:_deviceID];

    _deviceIDHintLabel.textColor = self.configuration.labelTextColor;
    
    _changedPasswordTextField.placeholder = NSLocalizedString(@"mcs_modify_password", nil);
    _confirmPasswordTextField.placeholder = NSLocalizedString(@"mcs_confirm_password", nil);
    
    _promptLabel.text = NSLocalizedString(@"mcs_prompt_modify_passwd", nil);
    _promptLabel.textColor = self.configuration.labelTextColor;
    [_applyButton setTitle:NSLocalizedString(@"mcs_change", nil) forState:UIControlStateNormal];
    [_applyButton setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    
    _showPasswordBtn.selected = NO;
    _showComfirmBtn.selected = NO;
    [_showPasswordBtn setImage:[UIImage imageNamed:@"vt_eye_gray.png"] forState:UIControlStateNormal];
    [_showComfirmBtn setImage:[UIImage imageNamed:@"vt_eye_gray.png"] forState:UIControlStateNormal];
    
    if (self.app.is_luxcam) {
        [_changedPasswordInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_confirmPasswordInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_applyButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"password.png"]];
        [_keySecondImage setImage:[UIImage imageNamed:@"password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_red_on.png"] forState:UIControlStateSelected];
        [_showComfirmBtn setImage:[UIImage imageNamed:@"eye_red_on.png"] forState:UIControlStateNormal];
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_applyButton setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"vt_eye.png"] forState:UIControlStateSelected];
        [_showComfirmBtn setImage:[UIImage imageNamed:@"vt_eye.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_ebitcam)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_applyButton setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_keySecondImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_green_on.png"] forState:UIControlStateSelected];
        [_showComfirmBtn setImage:[UIImage imageNamed:@"eye_green_on.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_mipc)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_applyButton setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_keySecondImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"mi_eye.png"] forState:UIControlStateSelected];
        [_showComfirmBtn setImage:[UIImage imageNamed:@"mi_eye.png"] forState:UIControlStateSelected];
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_applyButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_keySecondImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_green_on.png"] forState:UIControlStateSelected];
        [_showComfirmBtn setImage:[UIImage imageNamed:@"eye_green_on.png"] forState:UIControlStateSelected];
    }
}

#pragma mark - Lazy initialization
-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self setDeviceIDHintLabel:nil];
    [self setChangedPasswordTextField:nil];
    [self setConfirmPasswordTextField:nil];
    [self setApplyButton:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MNInfoPromptView hideAll:self.navigationController];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if ([segue.identifier isEqualToString:@"MNModifyWIFIViewController"]) {
        MNModifyWIFIViewController *modifyWIFIViewController = segue.destinationViewController;
        modifyWIFIViewController.deviceID = sender;
        modifyWIFIViewController.isChangePwd = YES;
        modifyWIFIViewController.is_notAdd = _is_notAdd;
        modifyWIFIViewController.is_loginModify = self.is_loginModify;
//        modifyWIFIViewController.is_resetModify = self.is_resetModify;
//        modifyWIFIViewController.deviceListViewController = self.deviceListViewController;
    } else if ([segue.identifier isEqualToString:@"MNShowResultViewController"]){
        MNShowResultViewController  *showResultViewController = segue.destinationViewController;
        showResultViewController.deviceID = _deviceID;
        showResultViewController.is_changePwd = YES;
        showResultViewController.is_connectWiFi = _is_wifiModule ? YES : NO;
        showResultViewController.is_notAdd = _is_notAdd;
        showResultViewController.is_onlyAdd = NO;
        showResultViewController.is_loginModify = self.is_loginModify;
//        showResultViewController.deviceListViewController = self.deviceListViewController;
    }
    else if ([segue.identifier isEqualToString:@"MNModifyTimezoneViewController"])
    {
        MNModifyTimezoneViewController *modifyTimezoneViewController = segue.destinationViewController;
        modifyTimezoneViewController.deviceID = _deviceID;
        modifyTimezoneViewController.isChangePwd = YES;
        modifyTimezoneViewController.is_connectWiFi = _is_wifiModule ? YES : NO;
        modifyTimezoneViewController.is_notAdd = _is_notAdd;
        modifyTimezoneViewController.is_onlyAdd = NO;
        modifyTimezoneViewController.is_loginModify = self.is_loginModify;
    }
}

#pragma mark - Action
- (IBAction)showPassword:(id)sender {
    _showPasswordBtn.selected = !_showPasswordBtn.selected;
    _changedPasswordTextField.secureTextEntry = !_showPasswordBtn.selected;
}

- (IBAction)showComfirm:(id)sender {
    _showComfirmBtn.selected = !_showComfirmBtn.selected;
    _confirmPasswordTextField.secureTextEntry = !_showComfirmBtn.selected;
}

#pragma mark - Action
- (IBAction)editDidExit:(id)sender
{
    [sender resignFirstResponder];
}

//- (IBAction)skipOperation:(id)sender
//{
//    [self performSegueWithIdentifier:@"MNModifyWIFIViewController" sender:_deviceID];
//}

- (IBAction)changePassword:(id)sender
{

    if (_changedPasswordTextField.text.length < 6 || _changedPasswordTextField.text.length > 20)
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_range_hint",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];

        return;
    }
    else if (![_changedPasswordTextField.text isEqualToString:_confirmPasswordTextField.text])
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_two_password_input_inconsistent",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];

        return;
    }
    
    unsigned char current_pwd[16] = {0};
    unsigned char changed_pwd[16] = {0};
    
    [mipc_agent passwd_encrypt:_oldPassword encrypt_pwd:current_pwd];
    [mipc_agent passwd_encrypt:_changedPasswordTextField.text encrypt_pwd:changed_pwd];
    
    mcall_ctx_dev_passwd_set *ctx = [[mcall_ctx_dev_passwd_set alloc] init];
    ctx.sn = _deviceID;
    ctx.old_encrypt_pwd = current_pwd;
    ctx.new_encrypt_pwd = changed_pwd;
    ctx.is_guest = NO;
    ctx.target = self;
    ctx.on_event = @selector(dev_passwd_set_done:);
    
    [self.progressHUD show:YES];
    [self.agent dev_passwd_set:ctx];
    
}


- (void)dev_passwd_set_done:(mcall_ret_dev_passwd_set*)ret
{
    if (nil == ret.result)
    {
        _oldPassword = _changedPasswordTextField.text;
        if (self.app.isLocalDevice) {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(1 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               [mipc_agent passwd_encrypt:_changedPasswordTextField.text encrypt_pwd:_encrypt_pwd];

                               UserInfo *userInfo = [[UserInfo alloc] init];
                               userInfo.name = _deviceID;
                               char *pass_md5 = _encrypt_pwd;
                               NSData *data = [NSData dataWithBytes:pass_md5   length:16];
                               userInfo.password = data;
                               [weakSelf saveUserInfoToLocal:userInfo];
                               
                               mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
                               ctx.srv = MIPC_SrvFix(_localDeviceIP);
                               ctx.user = _deviceID;
                               ctx.passwd = _encrypt_pwd;
                               ctx.target = self;
                               ctx.on_event = @selector(sign_in_done:);

                               [weakSelf.agent local_sign_in:ctx switchMmq:YES];
                               [weakSelf.progressHUD show:YES];
                               
                           });
            
        }
        else if (!self.app.isLoginByID) {
            unsigned char encrypt_pwd[16] = {0};
            [mipc_agent passwd_encrypt:_changedPasswordTextField.text encrypt_pwd:encrypt_pwd];
            
            mcall_ctx_dev_add *ctx = [[mcall_ctx_dev_add alloc] init];
            ctx.sn = _deviceID;
            ctx.passwd = encrypt_pwd;
            ctx.target = self;
            ctx.on_event = @selector(dev_add_done:);
            [self.agent dev_add:ctx];
            [self.progressHUD show:YES];
        }
        else
        {
            if(_changedPasswordTextField.text && _changedPasswordTextField.text.length)
            {
                [mipc_agent passwd_encrypt:_changedPasswordTextField.text encrypt_pwd:_encrypt_pwd];
            }
            
            // save password
            struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
            
            if(conf)
            {
                conf_new        = *conf;
            }
            
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isMemberOfClass:[MNLoginViewController class]]) {
                    if ([((MNLoginViewController *)viewController).swtRememberPassword isOn]) {
                        conf_new.password_md5.data = (char*)_encrypt_pwd;
                        conf_new.password_md5.len = 16;
                        MIPC_ConfigSave(&conf_new);
                        ((MNLoginViewController *)viewController).txtPassword.text = @"**********";
                    }
                 
                }
            }
           
            NSString *connectDevID = MIPC_GetConnectedIPCDevID();
            mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
            ctx.user = _deviceID;
            ctx.passwd = _encrypt_pwd;
            if (connectDevID && connectDevID.length) {
                ctx.srv = @"http://192.168.188.254/ccm";
            }
            ctx.target = self;
            ctx.on_event = @selector(sign_in_done:);
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSString *token = [user objectForKey:@"mipci_token"];
            
            if(token && token.length)
            {
                ctx.token = token;
            }
            
            [self.agent sign_in:ctx];
        }

    }
    else if ([ret.result isEqualToString:@"ret.no.rsp"])
    {
        [self.progressHUD hide:YES];
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_change_password_failed",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else if([ret.result isEqualToString:@"ret.pwd.invalid"])
    {
        //mofify again
        if (![_tmpPassword isEqualToString:@""]) {
            _oldPassword = _tmpPassword;
        }
        [self changePassword:nil];
    }
    else
    {
        if ([_tmpPassword isEqualToString:@""]) {
            _tmpPassword = _changedPasswordTextField.text;
        } else {
            _oldPassword = _tmpPassword;
            _tmpPassword = _changedPasswordTextField.text;
        }
        [self.progressHUD hide:YES];
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_change_password_failed",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

#pragma mark -dev_add_done
- (void)dev_add_done:(mcall_ret_dev_add*)ret
{
    if (nil == ret.result) {
        //connect wifi
//        mcall_ctx_net_get *ctx =[[mcall_ctx_net_get alloc] init];
//        ctx.sn = _deviceID;
//        ctx.target = self;
//        ctx.on_event = @selector(net_get_done:);
//        
//        [self.agent net_get:ctx];
        if ([ret.dev.wifi_status isEqualToString:@"none"] || [ret.dev.wifi_status isEqualToString:@"srvok"]) {
            _is_wifiModule = [ret.dev.wifi_status isEqualToString:@"none"] ? NO : YES;

            mcall_ctx_dev_info_get *ctx = [[mcall_ctx_dev_info_get alloc] init];
            ctx.sn = _deviceID;
            ctx.target = self;
            ctx.on_event = @selector(dev_timezone_get_done:);
            [self.agent dev_info_get:ctx];
        } else {
            [self performSegueWithIdentifier:@"MNModifyWIFIViewController" sender:_deviceID];
        }
    }
    else
    {
        [self.progressHUD hide:YES];
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_change_password_failed",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

#pragma mark - sign_in_done
- (void)sign_in_done:(mcall_ret_sign_in*)ret
{
    if (nil == ret.result) {
        //connect wifi
        mcall_ctx_dev_info_get *ctx =[[mcall_ctx_dev_info_get alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(dev_info_get_done:);
        
        [self.agent dev_info_get:ctx];
    }
}
#pragma mark - dev_info_get_done
- (void)dev_timezone_get_done:(mcall_ret_dev_info_get *)ret
{
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

- (void)dev_info_get_done:(mcall_ret_dev_info_get *)ret
{
    NSString *wifiStatus = ret.wifi_status;
    [self.progressHUD hide:YES];
    if ([wifiStatus isEqualToString:@"srvok"] || [wifiStatus isEqualToString:@"none"])
    {
        _is_wifiModule = [wifiStatus isEqualToString:@"srvok"] ? YES : NO;
        if (ret.timezone.length)
        {
            NSTimeInterval phoneTimezone = [self getTimeIntervalBetweenTimeZoneAndUTC];
            if ([ret.timezone intValue]*60*60 != phoneTimezone) {
                [self performSegueWithIdentifier:@"MNModifyTimezoneViewController" sender:nil];
                return;
            }
        }
        [self performSegueWithIdentifier:@"MNShowResultViewController" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"MNModifyWIFIViewController" sender:_deviceID];
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
        UIView  *checkView = _confirmPasswordTextField;
        
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
    //Handle the mobile event, and set the final state of the view to reach
    
    self.view.frame = newFrame;
    
    [UIView commitAnimations];
}

#pragma mark - Utils
- (void)saveUserInfoToLocal:(UserInfo *)userInfo
{
    NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"local_users"];
    
    NSMutableArray *usersArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:usersData]];
    
    if (userInfo.name && userInfo.password)
    {
        
        if (![usersArray containsObject:userInfo])
        {
            [usersArray insertObject:userInfo atIndex:0];
        }
        else
        {
            for (int i =0; i<usersArray.count; i++) {
                UserInfo *tempInfo = [usersArray objectAtIndex:i];

                if ([tempInfo.name isEqualToString:userInfo.name])
                {
                    [usersArray replaceObjectAtIndex:i withObject:userInfo];
                }
            }
        }
        NSData *usersData = [NSKeyedArchiver archivedDataWithRootObject:usersArray];
        
        [[NSUserDefaults standardUserDefaults] setObject:usersData forKey:@"local_users"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
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
