//
//  LoginViewController.m
//  ipcti
//
//  Created by MagicStudio on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "MNLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNModifyPasswordViewController.h"
#import "UserInfo.h"
#import "MNDeviceGuideViewController.h"
#import "MNDeviceOfflineViewController.h"
#import "MNModifyWIFIViewController.h"
#import "MNQRCodeViewController.h"
#import "MNProgressHUD.h"
#import "MIPCUtils.h"
#import "MNDeviceListViewController.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"
#import "MNGuideNavigationController.h"
#import "MNRootNavigationController.h"
#import "MNProductInformationViewController.h"
#import "MNToastView.h"
#import "MNPostAlertView.h"
#import "MNPrepareRecoveryViewController.h"
#import "MNDeviceListSetViewController.h"
#import "MNDeveloperTableViewController.h"
#import "MNUserBehaviours.h"
#import "MNMoreInformationViewController.h"
#import "MNLoginNavigationController.h"

@interface MNLoginViewController()<UIAlertViewDelegate>
{
    unsigned char                       _encrypt_pwd[16];
    long                                _encrypt_pwd_len;
    long                                _isLoginning;
    CGRect                              _selfOrginFrame;
    long                                _longPressCounts;
    long                                active;
}
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSArray *usersArray;
@property (strong, nonatomic) UITableView *usersTableView;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (assign, nonatomic) BOOL is_showPassword;
@property (assign, nonatomic) BOOL toRegister;
@property (assign, nonatomic) BOOL toMore;
@property (strong, nonatomic) NSString      *serverString;

@property (strong, nonatomic) UIWindow      *alertLevelWindow;
@property (assign, nonatomic) BOOL isExcutePost;
@property (strong, nonatomic) NSMutableArray *startItemArray;
@property (strong, nonatomic) NSMutableArray *loginItemArray;
@property (strong, nonatomic) NSMutableArray *runningItemArray;
@property (strong, nonatomic) UIPageControl  *pageControl;
@property (strong, nonatomic) NSTimer        *randomTimer;
@property (strong, nonatomic) mcall_ctx_post_get *postGetCtx;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@end

@implementation MNLoginViewController

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
        _progressHUD.labelText = NSLocalizedString(@"mcs_sign_ining", nil);
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        
    }
    
    return self;
}

- (void)initUI
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _logoViewVerticalSpaceToTop.constant = 250;
    }
    
    /* set radius bounds */
    _viewServerLine.layer.cornerRadius     = 6;
    _viewServerLine.layer.masksToBounds    = YES;
    _viewUserLine.layer.cornerRadius       = 6;
    _viewUserLine.layer.masksToBounds      = YES;
    _viewPasswordLine.layer.cornerRadius   = 6;
    _viewPasswordLine.layer.masksToBounds  = YES;
    _lblRememberPassword.text              = NSLocalizedString(@"mcs_remember_password",nil);
    _txtUser.placeholder                   = NSLocalizedString(@"mcs_input_username",nil);
    _txtUser.keyboardType                  = UIKeyboardTypeASCIICapable;
    _txtUser.clearButtonMode               = UITextFieldViewModeWhileEditing;
    _txtPassword.clearButtonMode           = UITextFieldViewModeWhileEditing;
    [_recoveryPasswordButton setTitle:NSLocalizedString(@"mcs_forgot_your_password",nil) forState:UIControlStateNormal];
    _registerLabel.text = NSLocalizedString(@"mcs_signup_prompt", nil);
    _recoveryPasswordButton.hidden = (self.app.is_vimtag || self.app.is_avuecam || self.app.is_ebitcam || self.app.is_mipc) ? NO : YES;
    if (!self.app.is_vimtag) {
        [_registerBtn setTitleColor:self.configuration.labelTextColor forState:UIControlStateNormal];
        [_recoveryPasswordButton setTitleColor:self.configuration.labelTextColor forState:UIControlStateNormal];
    }
    _swtRememberPassword.onTintColor    = self.app.is_sereneViewer ? [UIColor colorWithRed:137./255. green:140./255. blue:145./255. alpha:1.0] : self.configuration.switchTintColor;
    _lblRememberPassword.textColor      = self.configuration.labelTextColor;

    [_txtPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];


    
    struct mipci_conf  *conf = MIPC_ConfigLoad();
    if (conf)
    {
        //        _remenberPasswordButton.selected = conf->password_md5.data ? 1 : 0;
        _swtRememberPassword.on = conf->password_md5.data ? 1 : 0;
        _rememberPwdButton.selected = conf->password_md5.data ? 1 : 0;
    }
    [_btnLogin setTitle:NSLocalizedString(@"mcs_sign_in",nil) forState:UIControlStateNormal];
    [_btnLogin setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_btnLogin setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    [_registerBtn setTitle:NSLocalizedString(@"mcs_sign_up",nil) forState:UIControlStateNormal];
    [_registerButton setTitle:NSLocalizedString(@"mcs_sign_up",nil) forState:UIControlStateNormal];
    [_SereneViewerRegisterBtn setTitle:NSLocalizedString(@"mcs_sign_up",nil) forState:UIControlStateNormal];
    
    if (self.app.is_luxcam) {
        [_serverInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_userInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_passwordInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_btnLogin setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
    {
        if (self.app.is_vimtag) {
            _accountLabel.text = NSLocalizedString(@"mcs_new_user", nil);
            _viewServerLine.hidden = YES;
            [self checkBackgroundImage];
        }
        
        if (self.app.is_ebitcam || self.app.is_mipc) {
            CGSize titleSize = [_lblRememberPassword.text boundingRectWithSize:CGSizeMake(320, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_lblRememberPassword.font} context:nil].size;
            _checkFrameLayoutConstraint.constant = titleSize.width + 25;
        }
        if (self.app.is_mipc) {
            _txtUser.textColor = UIColorFromRGB(0x6b7a99);
            _txtPassword.textColor = UIColorFromRGB(0x6b7a99);
            [_txtUser setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
            [_txtPassword setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
        }
    }
    else
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    if (self.app.is_bosma) {
        _detailLogo.hidden = NO;
        _btnLogin.layer.borderWidth = 1.0;
        _btnLogin.layer.borderColor = [UIColor colorWithRed:99./255. green:99./255. blue:99./255. alpha:1.0].CGColor;
        _btnLogin.layer.cornerRadius = 5.0;
    }
    
    //Develop option Entrance
    _imgLogo.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 1;
    [_imgLogo addGestureRecognizer:longPressGestureRecognizer];
}

- (void)checkBackgroundImage
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
        {
            _loginBackground.image = [UIImage imageNamed:@"vt_ipad_background_landscape.png"];
        }
        else
        {
            _loginBackground.image = [UIImage imageNamed:@"vt_ipad_background.png"];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    
    self.agent = self.app.agent;
    
    memset(_encrypt_pwd, 0, sizeof(_encrypt_pwd));
    struct mipci_conf *conf = MIPC_ConfigLoad();
    if(conf && conf->server.len)
    {
        _txtServer.text = nil;
        _viewServerLine.hidden = YES;
    }
    if(conf && conf->user.len)
    {
        _txtUser.text = [NSString stringWithUTF8String:(const char*) conf->user.data];
    }
    _txtPassword.placeholder   = (conf && (conf->password_md5.len  || conf->password.len))?NSLocalizedString(@"",nil):NSLocalizedString(@"mcs_input_password",nil);
    
    /* try auto login */
    if(((nil == _txtServer.text) || (0 == _txtServer.text.length))
       && ((NULL == self.sConnectedDevID) || (0 == self.sConnectedDevID.length))
       && conf && conf->user.len && (conf->password.len || conf->password_md5.len))
    {
        if (!self.app.is_vimtag && conf->auto_login) {
            [self performSelector:@selector(onLogin:) withObject:_btnLogin afterDelay:0.1];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.app.isLocalDevice = NO;
    active   = 1;
    _lblStatus.hidden = YES;
    self.toRegister = NO;
    self.toMore = NO;
    self.is_showPassword = NO;
    _txtPassword.secureTextEntry = YES;
    
    if (self.app.is_luxcam || self.app.is_mipc) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [_showPasswordBtn setImage:[UIImage imageNamed:self.is_showPassword?@"vt_eye.png":@"vt_eye_gray.png"] forState:UIControlStateNormal];

    if(nil == self.timerSrvCheck )
    {
        self.timerSrvCheck = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onSrvCheckTimer:) userInfo:nil repeats:YES];
    }
    
    struct mipci_conf *conf = MIPC_ConfigLoad();
    if(conf && conf->password_md5.len && ! [_txtPassword.text isEqualToString:@"admin"])
    {
        _txtPassword.text = @"**********";
        _showPasswordBtn.hidden = YES;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.app.is_luxcam || self.app.is_mipc) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    if (self.app.is_InfoPrompt) {
        [MNInfoPromptView hideAll:self.navigationController];
    }
    if (self.app.is_vimtag && self.toRegister) {
        
    } else if ((self.app.is_ebitcam || self.app.is_mipc) && self.toMore) {
        
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    if(self.timerSrvCheck)
    {
        [self.timerSrvCheck invalidate];
        self.timerSrvCheck = nil;
    }
}

- (void)viewDidUnload
{
    NSLog(@"login view unload");
    
    [super viewDidUnload];
    // Release any stronged subviews of the main view.
}

-(void)updateSrvDisplayInfo
{
    if(((nil == _txtServer.text) || (0 == _txtServer.text.length))
       && self.sConnectedDevID && self.sConnectedDevID.length)
    {
        /* _txtServer.placeholder = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Linked:",nil), self.sConnectedDevID]; */
        _txtUser.text      = self.sConnectedDevID;
        _txtUser.enabled   = FALSE;
        _viewUserLine.backgroundColor = [UIColor grayColor];
    }
}

-(void)onSrvCheckTimer:(NSTimer *)timer
{
    NSString *connectDevID = MIPC_GetConnectedIPCDevID();
    if((((nil == connectDevID) || (0 == connectDevID.length))
        &&((nil == self.sConnectedDevID) || (0 == self.sConnectedDevID.length)))
       ||(connectDevID && [connectDevID isEqualToString:self.sConnectedDevID]))
    {
        return;
    }
    self.sConnectedDevID = connectDevID;
    [self updateSrvDisplayInfo];
}

#pragma mark - Action
- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showPassword:(id)sender {
    _txtPassword.secureTextEntry = self.is_showPassword;
    self.is_showPassword = !(self.is_showPassword);
    [_showPasswordBtn setImage:[UIImage imageNamed:self.is_showPassword?@"vt_eye.png":@"vt_eye_gray.png"] forState:UIControlStateNormal];
}

- (IBAction)rememberPassword:(id)sender
{
    _rememberPwdButton.selected = !_rememberPwdButton.selected;
}

- (IBAction)getMore:(id)sender
{
    _toMore = YES;
    [self performSegueWithIdentifier:@"MNMoreOptionsTableViewController" sender:nil];
}

- (IBAction)recoveryPassword:(id)sender
{
    [self performSegueWithIdentifier:@"MNPrepareRecoveryViewController"sender:nil];
}

- (IBAction)setupRememberPassword:(id)sender {
}

- (IBAction)selectUserName:(id)sender
{
    NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"users"];
    self.usersArray = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
    
    CGRect userLineRect = _viewUserLine.frame;
    
    if (self.usersTableView != nil) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = self.usersTableView.frame;
            frame.size.height = 0;
            [self.usersTableView setFrame:frame];
        } completion:nil];
        
        [_usersTableView removeFromSuperview];
        self.usersTableView = nil;
    }
    else
    {
        self.usersTableView = [[UITableView alloc] initWithFrame:CGRectMake(userLineRect.origin.x, userLineRect.origin.y + CGRectGetHeight(userLineRect), CGRectGetWidth(userLineRect), 0)];
        _usersTableView.delegate = self;
        _usersTableView.dataSource = self;
        
        _usersTableView.layer.masksToBounds = NO;
        _usersTableView.layer.cornerRadius = 5;
        _usersTableView.layer.shadowOffset = CGSizeMake(-5, 5);
        _usersTableView.layer.shadowRadius = 5;
        _usersTableView.layer.shadowOpacity = 0.5;
        
        _usersTableView.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
        _usersTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _usersTableView.separatorColor = [UIColor grayColor];
        _usersTableView.separatorInset = UIEdgeInsetsZero;
        
        [self.contentView addSubview:_usersTableView];
    }
}

- (IBAction)onRegisterBtn:(id)sender
{
    if(_isLoginning)
    {
        return;
    };
    
    _toRegister = YES;
    [self performSegueWithIdentifier:@"MNRegisterViewController" sender:nil];
}

- (IBAction)onInputEnd:(UITextField*)sender
{
    [sender resignFirstResponder];
    
    if (self.app.is_mipc) {
        _userImage.highlighted = NO;
        _userInputImage.highlighted = NO;
        _pwdImage.highlighted = NO;
        _pwdInputImage.highlighted = NO;
        _txtUser.textColor = UIColorFromRGB(0x6b7a99);
        _txtPassword.textColor = UIColorFromRGB(0x6b7a99);
        [_txtUser setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
        [_txtPassword setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
    }
}

- (IBAction)onBeginEditting:(UITextField*)sender
{
    if (self.app.is_mipc) {
        if (sender == _txtUser) {
            _userImage.highlighted = YES;
            _userInputImage.highlighted = YES;
            _pwdImage.highlighted = NO;
            _pwdInputImage.highlighted = NO;
            _txtUser.textColor = UIColorFromRGB(0x2988cc);
            _txtPassword.textColor = UIColorFromRGB(0x6b7a99);
            [_txtUser setValue:UIColorFromRGB(0x2988cc) forKeyPath:@"_placeholderLabel.textColor"];
            [_txtPassword setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
        } else {
            _userImage.highlighted = NO;
            _userInputImage.highlighted = NO;
            _pwdImage.highlighted = YES;
            _pwdInputImage.highlighted = YES;
            _txtUser.textColor = UIColorFromRGB(0x6b7a99);
            _txtPassword.textColor = UIColorFromRGB(0x2988cc);
            [_txtUser setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
            [_txtPassword setValue:UIColorFromRGB(0x2988cc) forKeyPath:@"_placeholderLabel.textColor"];
        }
    }
    
    _lblStatus.hidden = YES;
}

- (IBAction)onEndEditting:(UITextField*)sender
{
    if(sender == _txtServer)
    {
        // [self updateSrvDisplayInfo];
    }
    //[sender resignFirstResponder];
}

- (void)textFieldDidChange:(id)sender
{
    if (self.app.is_vimtag) {
        _showPasswordBtn.hidden = NO;
    }
    if (0 == _txtPassword.text.length) {
        _txtPassword.placeholder = NSLocalizedString(@"mcs_input_password",nil);
        struct mipci_conf *conf = MIPC_ConfigLoad(), new_conf = {0};
        if(conf && conf->password_md5.len) {
            new_conf = *conf;
        } else {
            return;
        }
        new_conf.password.len = (new_conf.password_md5.len = 0);
        MIPC_ConfigSave(&new_conf);
    }
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer*)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        ++_longPressCounts;
        if (self.app.isOpenDeveloperOption) {
            MNDeveloperTableViewController *developerVC = [[MNDeveloperTableViewController alloc] init];
            MNLoginNavigationController *nav = [[MNLoginNavigationController alloc] initWithRootViewController:developerVC];
            [self presentViewController:nav animated:YES completion:nil];
        } else {
#if TARGET_IPHONE_SIMULATOR
            if(1 <= _longPressCounts)
#else
            if(3 <= _longPressCounts)
#endif
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Developer password" message:nil delegate:nil cancelButtonTitle:@"Cancle" otherButtonTitles:@"Login", nil];
                alert.delegate = self;
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *loginText = [alert textFieldAtIndex:0];
                [loginText setPlaceholder:@"Developer password"];
                [alert show];

                _longPressCounts = 0;
            }
        }
    }
}

- (IBAction)onLogin:(id)sender
{
    //Repair Username
    if(_txtUser.text && _txtUser.text.length && [[NSString stringWithFormat:@"%@",_txtUser.text] rangeOfString:@" "].length)
    {
        NSString *fixedUser = [[NSString stringWithFormat:@"%@",_txtUser.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _txtUser.text = fixedUser;
    }

    
    struct mipci_conf *conf = MIPC_ConfigLoad();
    _longPressCounts = 0;
    
    if(_isLoginning)
    {
        return;
    };
    
    
    if (self.app.is_vimtag) {
        //Add device's data
        UITabBarController *rootTabBarController = (UITabBarController*)self.presentingViewController;
        for (UINavigationController *navigationController in rootTabBarController.viewControllers) {
            for (UIViewController *viewController in navigationController.viewControllers) {
                if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                    MNDeviceListSetViewController *deviceListSetViewController = (MNDeviceListSetViewController *)viewController;
                    MNDeviceListViewController *deviceListViewController = deviceListSetViewController.deviceListViewController;
                    [deviceListViewController getNotification:_txtUser.text];
                }
            }
        }
    } else {
        //get notification
        unsigned int random = arc4random() % 60;
        _postGetCtx = [[mcall_ctx_post_get alloc] init];
        _postGetCtx.start = 0;
        _postGetCtx.counts = 6;
        _postGetCtx.target = self;
        _postGetCtx.user = _txtUser.text;
        
        _randomTimer = [NSTimer scheduledTimerWithTimeInterval:random - 10 target:self selector:@selector(postAction:) userInfo:nil repeats:NO];
        _postGetCtx.on_event = @selector(notification_get_done:);
        [_agent performSelector:@selector(post_get:) withObject:_postGetCtx afterDelay:random];
    }

    /* update password */
    
    if(_txtPassword.text && _txtPassword.text.length)
    {
        if ( conf && conf->password_md5.len && [_txtPassword.text isEqualToString: @"**********"]) {
            memcpy(_encrypt_pwd, conf->password_md5.data, sizeof(_encrypt_pwd));
            _encrypt_pwd_len = sizeof(_encrypt_pwd);
            
        }
        else
        {
            if ([_txtPassword.text isEqualToString:@"amdin"]) {
                _txtPassword.text = @"admin";
            }
            if (self.app.is_luxcam) {
                NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"users"];
                self.usersArray = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];

                for (UserInfo *userInfo in self.usersArray) {
                    if ([userInfo.name isEqual:_txtUser.text]) {
                        if ([userInfo.password isKindOfClass:[NSString class]]) {
                            [mipc_agent passwd_encrypt:[NSString stringWithFormat:@"%@", userInfo.password] encrypt_pwd:_encrypt_pwd];
                            //                            char *pass_md5 = _encrypt_pwd;
                            //                            NSData *data = [NSData dataWithBytes:pass_md5   length:strlen(pass_md5)];
                            //                            userInfo.password = data;
                        }
                        else if ([userInfo.password isKindOfClass:[NSData class]]) {
                            const char *pass_md5 = [userInfo.password bytes];
                            memcpy(_encrypt_pwd, pass_md5, 16);
                        }
                        break;
                    }
                }
                if(strlen(_encrypt_pwd)==0 || _encrypt_pwd_len == 0)
                {
                    [mipc_agent passwd_encrypt:_txtPassword.text encrypt_pwd:_encrypt_pwd];
                }
            }
            else{
                [mipc_agent passwd_encrypt:_txtPassword.text encrypt_pwd:_encrypt_pwd];
            }
            _encrypt_pwd_len = sizeof(_encrypt_pwd);
            
        }
    }
    else if(conf && conf->password.len)
    {
        [mipc_agent passwd_encrypt:_txtPassword.text encrypt_pwd:_encrypt_pwd];
        _encrypt_pwd_len = sizeof(_encrypt_pwd);
    }
    else
    {
        _encrypt_pwd_len = 0;
    }
    
    /* check data and sign in */
    if((nil == _txtUser.text) || (0 == _txtUser.text.length))
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_please_input_username",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            _lblStatus.text = NSLocalizedString(@"mcs_please_input_username",nil);
            _lblStatus.hidden = NO;
        }
    }
    else if(0 == _encrypt_pwd_len)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_please_input_password",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            _lblStatus.text = NSLocalizedString(@"mcs_please_input_password",nil);
            _lblStatus.hidden = NO;
        }
    }
    else if ((self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc )&& [self.app isDevicesAccount:_txtUser.text])
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_register_prompt", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else if (_txtUser.text.length > 128)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_user_letter_range_hint",nil) style:MNInfoPromptViewStyleError isModal:YES navigation:self.navigationController];
        } else {
            _lblStatus.text = NSLocalizedString(@"mcs_user_letter_range_hint",nil);
            _lblStatus.hidden = NO;
        }
    }
    else if (_txtPassword.text.length > 128)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_range_hint",nil) style:MNInfoPromptViewStyleError isModal:YES navigation:self.navigationController];
        } else {
            _lblStatus.text = NSLocalizedString(@"mcs_password_range_hint",nil);
            _lblStatus.hidden = NO;
        }
    }
    else
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView hideAll:self.navigationController];
        }
        
        _lblStatus.text = NSLocalizedString(@"mcs_sign_ining",nil);
        _lblStatus.hidden = YES;
        _isLoginning = 1;
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        if(self.timerSrvCheck)
        {
            [self.timerSrvCheck invalidate];
            self.timerSrvCheck = nil;
        }
        
        self.app.directConnectedDevID = _sConnectedDevID;
        
        NSString  *sServer = _txtServer.text, *sUser = _txtUser.text;
        struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
        
        if(conf)
        {
            conf_new        = *conf;
        }
        
        conf_new.server.data = (char*)(sServer?sServer.UTF8String:NULL);
        conf_new.server.len = (uint32_t)(sServer?sServer.length:0);
        conf_new.user.data = (char*)(sUser?sUser.UTF8String:NULL);
        conf_new.user.len = (uint32_t)(sUser?sUser.length:0);
        
        if (([_swtRememberPassword isOn] || self.app.is_vimtag || _rememberPwdButton.selected) && ![_txtPassword.text isEqualToString:@"admin"])
        {
            conf_new.password_md5.data = (char*)_encrypt_pwd;
            conf_new.password_md5.len = 16;
        }
        else
        {
            conf_new.password_md5.data = NULL;
            conf_new.password_md5.len = 0;
//            _txtPassword.text = nil;
        }
    
        MIPC_ConfigSave(&conf_new);
        _encrypt_password = _encrypt_pwd;
        
        mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
        ctx.srv = (_sConnectedDevID && _sConnectedDevID.length)?@"http://192.168.188.254/ccm":MIPC_SrvFix(_serverString);
        ctx.user = _txtUser.text;
        ctx.passwd = _encrypt_pwd;
        ctx.target = self;
        ctx.on_event = @selector(sign_in_done:);
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *token = [user objectForKey:@"mipci_token"];
        
        if(token && token.length)
        {
            ctx.token = token;
        }
        
        [_agent sign_in:ctx];
        [self.progressHUD show:YES];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_txtUser.text forKey:@"username"];
    if (![_txtPassword.text isEqualToString: @"**********"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:_txtPassword.text forKey:@"password"];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){}
    else
    {
        UITextField *loginText = [alertView textFieldAtIndex:0];
        if ([loginText.text isEqualToString:@"Vimtag@2016"]) {
            self.app.isOpenDeveloperOption = YES;
            MNDeveloperTableViewController *developerVC = [[MNDeveloperTableViewController alloc] init];
            MNLoginNavigationController *nav = [[MNLoginNavigationController alloc] initWithRootViewController:developerVC];
            [self presentViewController:nav animated:YES completion:nil];
        }else if (loginText.text.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"please input screat" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [alert show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:buttonIndex == 1 animated:YES];
            });
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"password wrong" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [alert show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:buttonIndex == 1 animated:YES];
            });
        }
    }
}

#pragma mark - Network callback
- (void)sign_in_done:(mcall_ret_sign_in*)ret
{
    if (!active)
    {
        return;
    }
    
    _isLoginning = 0;
    
//    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
    
    if(nil == ret.result)
    {
       
//        MNUserBehaviours *behaviours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaviours.login_succ_times += 1;
//        BOOL isright =  [NSKeyedArchiver archiveRootObject:behaviours toFile:filePath];
        
        if (self.app.is_luxcam) {
            [self saveUserInfoToLocal];
        }
        
        if (self.app.isLoginByID) {
            struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
            if(conf)
            {
                conf_new        = *conf;
            }
            conf_new.auto_login = 1;
            MIPC_ConfigSave(&conf_new);
            
            if (_txtPassword.text.length > 0 && _txtPassword.text.length < 6)
            {
                [self.progressHUD hide:YES];
      
                UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
                MNModifyPasswordViewController *modifyPasswordViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNModifyPasswordViewController"];
                modifyPasswordViewController.deviceID = _txtUser.text.lowercaseString;
                modifyPasswordViewController.oldPassword = _txtPassword.text;
              
                modifyPasswordViewController.is_loginModify = YES;
            
                [self.navigationController pushViewController:modifyPasswordViewController animated:YES];
            }
            else
            {
                if (![[NSUserDefaults standardUserDefaults] boolForKey:_txtUser.text]) {
                    //connect wifi
                    mcall_ctx_dev_info_get *ctx =[[mcall_ctx_dev_info_get alloc] init];
                    ctx.sn = _txtUser.text.lowercaseString;
                    ctx.target = self;
                    ctx.on_event = @selector(dev_info_get_done:);
                    
                    [_agent dev_info_get:ctx];
                } else {
                    [self.progressHUD hide:YES];
                    UINavigationController *navigationController = (UINavigationController *)self.presentingViewController;
                    for (UIViewController *viewController in navigationController.viewControllers) {
                        if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                            [((MNDeviceListViewController *)viewController) loadingDeviceData];
                        }
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }
        else
        {
            [self.progressHUD hide:YES];
            if(_swtRememberPassword.isOn || self.app.is_vimtag || self.app.is_eyedot || _rememberPwdButton.selected)
            {
                //                _txtPassword.placeholder = NSLocalizedString(@"mcs_password_remembered",nil);
            }
            else
            {
                _txtPassword.placeholder = NSLocalizedString(@"mcs_input_password",nil);
            }
            
            
            /* save user password */
            NSString  *sServer = _txtServer.text, *sUser = _txtUser.text;
            
            struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
            if(conf)
            {
                conf_new        = *conf;
            }
            conf_new.server.data = (char*)(sServer?sServer.UTF8String:NULL);
            conf_new.server.len = (uint32_t)(sServer?sServer.length:0);
            conf_new.user.data = (char *)((char*)(sUser?sUser.UTF8String:NULL));
            conf_new.user.len = (uint32_t)(sUser?sUser.length:0);
            conf_new.auto_login = 1;
            if (_swtRememberPassword.isOn || self.app.is_vimtag || self.app.is_eyedot || _rememberPwdButton.selected)
            {
                conf_new.password_md5.data = (char*)_encrypt_pwd;
                conf_new.password_md5.len = 16;
            }
            else
            {
                conf_new.password_md5.data = NULL;
                conf_new.password_md5.len = 0;
                _txtPassword.text = nil;
            }
            

            MIPC_ConfigSave(&conf_new);

            //jump to
            if (self.app.is_vimtag) {
                //Add device's data
                UITabBarController *rootTabBarController = (UITabBarController*)self.presentingViewController;
                for (UINavigationController *navigationController in rootTabBarController.viewControllers) {
                    for (UIViewController *viewController in navigationController.viewControllers) {
                        if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                            MNDeviceListViewController *deviceListViewController = ((MNDeviceListSetViewController*)viewController).deviceListViewController;
                            [deviceListViewController loadingDeviceData];
                            [deviceListViewController performSelector:@selector(webVersionGet) withObject:nil afterDelay:60];
                        }
                    }
                }

                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                UITabBarController *tabbarController = (UITabBarController *)[self getCurrentRootViewController];
                
                for (UINavigationController *navigationController in tabbarController.viewControllers) {
                    for (UIViewController *viewController in navigationController.viewControllers) {
                        
                        if ([viewController isMemberOfClass: [MNProductInformationViewController class]])
                        {
                            if (self.isMallLogin)
                            {
                                [(MNProductInformationViewController *)viewController loadWeb];
                            }

                        }                         
                    }
                }
                
            } else {
                UINavigationController * navigationController = (UINavigationController *)self.presentingViewController;
                for (UIViewController *viewController  in navigationController.viewControllers) {
                    if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                        [((MNDeviceListViewController*) viewController) loadingDeviceData];
                        if (self.app.is_ebitcam || self.app.is_mipc) {
                            [((MNDeviceListViewController*) viewController) performSelector:@selector(webVersionGet) withObject:nil afterDelay:60];
                        }
                    }
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    else
    {
        [self.progressHUD hide:YES];
        if([ret.result isEqualToString:@"ret.dev.offline"])
        {
            if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc ) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                _lblStatus.text = NSLocalizedString(@"mcs_device_offline",nil);
                if (_is_wifiConfig) {
                    UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
                    MNDeviceOfflineViewController *deviceOfflineViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceOfflineViewController"];
                    MNGuideNavigationController *offlineNavigationController = [[MNGuideNavigationController alloc] initWithRootViewController:deviceOfflineViewController];
                    deviceOfflineViewController.deviceID = _txtUser.text.lowercaseString;
                    deviceOfflineViewController.devicePassword = _txtPassword.text;
                    
                    deviceOfflineViewController.is_loginModify = YES;
                    [self presentViewController:offlineNavigationController animated:YES completion:nil];
                } else {
                    mcall_ctx_cap_get *ctx = [[mcall_ctx_cap_get alloc] init];
                    ctx.sn = _txtUser.text.lowercaseString;
                    ctx.filter = nil;
                    ctx.target = self;
                    ctx.on_event = @selector(cap_get_done:);
                    [self.agent cap_get:ctx];
                }
            }
        }
        else if([ret.result isEqualToString:@"ret.user.unknown"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_user",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                _lblStatus.text = NSLocalizedString(@"mcs_invalid_user",nil);
            }
            _encrypt_pwd_len = 0;
            _txtPassword.text = nil;
            _txtPassword.placeholder = NSLocalizedString(@"mcs_input_password",nil);
            
            struct mipci_conf *conf = MIPC_ConfigLoad(), new_conf = {0};
            
            if(conf)
            {
                new_conf = *conf;
            };
            
            new_conf.password.len = (new_conf.password_md5.len = 0);
            MIPC_ConfigSave(&new_conf);
        }
        else if([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            _encrypt_pwd_len = 0;
            _txtPassword.text = nil;
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_user_or_password_invalid",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                _lblStatus.text = NSLocalizedString(@"mcs_user_or_password_invalid",nil);
            }
            _txtPassword.placeholder = NSLocalizedString(@"mcs_input_password",nil);
            struct mipci_conf *conf = MIPC_ConfigLoad(), new_conf = {0};
            if(conf){ new_conf = *conf; };
            new_conf.password.len = (new_conf.password_md5.len = 0);
            MIPC_ConfigSave(&new_conf);
        }
        else if([ret.result isEqualToString:@"ret.user.inactive"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_user_inactive",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                _lblStatus.text = NSLocalizedString(@"mcs_user_inactive",nil);
            }
        }
        else
        {
//            MNUserBehaviours *behaviours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//            behaviours.login_fail_times += 1;
//            BOOL isright =  [NSKeyedArchiver archiveRootObject:behaviours toFile:filePath];
          
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_login_faided",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                _lblStatus.text = NSLocalizedString(@"mcs_login_faided",nil);
            }
        }
        
        _lblStatus.hidden = NO;
    }
}


#pragma mark - dev_info_get_done
- (void)dev_info_get_done:(mcall_ret_dev_info_get *)ret
{
    NSString *wifiStatus = ret.wifi_status;
    
    [self.progressHUD hide:YES];
    _txtPassword.text = nil;
    if ([wifiStatus isEqualToString:@"srvok"] || [wifiStatus isEqualToString:@"none"])
    {
//        [self performSegueWithIdentifier:@"MNDeviceListViewController" sender:nil];
        UINavigationController *navigationController = (UINavigationController *)self.presentingViewController;
        for (UIViewController *viewController in navigationController.viewControllers) {
            if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                [((MNDeviceListViewController *)viewController) loadingDeviceData];
            }
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        //        if (self.app.is_vimtag) {
        //            [self performSegueWithIdentifier:@"MNDeviceListViewController" sender:nil];
        //        } else {
        //            [self performSegueWithIdentifier:@"MNModifyWIFIViewController" sender:nil];
        //        }
        UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
        
        MNModifyWIFIViewController *modifyWIFIViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNModifyWIFIViewController"];
        modifyWIFIViewController.deviceID = _txtUser.text.lowercaseString;
       
        modifyWIFIViewController.is_loginModify = YES;
        [self.navigationController pushViewController:modifyWIFIViewController animated:YES];
    }
}

- (void)cap_get_done:(mcall_ret_cap_get *)ret
{
    if (nil == ret.result) {
        __weak typeof (self) weakSelf = self;
        if (ret.wfc == 1 || ret.qrc == 1 || ret.snc == 1) {
            UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
            MNDeviceOfflineViewController *deviceOfflineViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceOfflineViewController"];
            MNGuideNavigationController *offlineNavigationController = [[MNGuideNavigationController alloc] initWithRootViewController:deviceOfflineViewController];
            deviceOfflineViewController.deviceID = _txtUser.text.lowercaseString;
            deviceOfflineViewController.devicePassword = _txtPassword.text;
            
            deviceOfflineViewController.is_loginModify = YES;
            
            deviceOfflineViewController.wfc = ret.wfc;
            deviceOfflineViewController.qrc = ret.qrc;
            deviceOfflineViewController.snc = ret.snc;
            deviceOfflineViewController.sncf = ret.sncf;
            deviceOfflineViewController.wfcnr = ret.wfcnr;
            [weakSelf presentViewController:offlineNavigationController animated:YES completion:nil];
        }
        else {
            UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
            MNDeviceGuideViewController *deviceGuideViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceGuideViewController"];
            MNGuideNavigationController *guideNavigationController = [[MNGuideNavigationController alloc] initWithRootViewController:deviceGuideViewController];
            deviceGuideViewController.deviceID = _txtUser.text.lowercaseString;
            
            deviceGuideViewController.is_loginModify = YES;
            
        
            [weakSelf presentViewController:guideNavigationController animated:YES completion:nil];
        }
    }
    
    
}

- (void)notification_get_done:(mcall_ret_post_get *)ret
{
    if (ret.result != nil || ret.item.count == 0)
    {
        return;
    }
    MNPostAlertView *postAlerView = [[MNPostAlertView alloc] initWithFrame:self.view.frame post:ret status:self.app.is_userOnline];
    [postAlerView show];
}

- (NSTimer *)postAction:(id)sender
{
    _isExcutePost = YES;
    return nil;
}

#pragma for qrcode
- (IBAction)onQRCodeBtn:(id)sender
{
    if(_isLoginning)
    {
        return;
    }
    
    if ([self checkCamera])
    {
        UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
        MNQRCodeViewController *QRCodeViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNQRCodeViewController"];
        QRCodeViewController.loginViewController = self;
        //        QRCodeViewController.deviceID = _txtUser.text;
        //        deviceGuideViewController.loginViewController = weakSelf;
        [self.navigationController pushViewController:QRCodeViewController animated:YES];
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
            _txtUser.text = [NSString stringWithFormat:@"%*.*s", 0, (int)sID.len, sID.data];
            //self.sPassword = [NSString stringWithFormat:@"%*.*s", 0, (int)sPassword.len, sPassword.data];
            _txtPassword.text = [NSString stringWithFormat:@"%*.*s", 0, (int)sPassword.len, sPassword.data];
            [controller dismissViewControllerAnimated:YES completion:nil];
            return;
        }
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (self.app.is_InfoPrompt) {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_qrcode",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    } else {
        _lblStatus.text = NSLocalizedString(@"mcs_invalid_qrcode",nil);
        _lblStatus.hidden = NO;
    }
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Rotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation = UIInterfaceOrientationPortrait;
}

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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.app.is_vimtag) {
        [self checkBackgroundImage];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"MNRegisterViewController"])
    {
        MNRegisterViewController *registerViewController = segue.destinationViewController;
        registerViewController.loginViewController = self;
    }
    else if ([segue.identifier isEqualToString:@"MNModifyPasswordViewController"])
    {
        MNModifyPasswordViewController *modifyPasswordViewController = segue.destinationViewController;
        modifyPasswordViewController.deviceID = _txtUser.text.lowercaseString;
        modifyPasswordViewController.oldPassword = _txtPassword.text;
    }
    else if ([segue.identifier isEqualToString:@"MNDeviceGuideViewController"])
    {
        MNDeviceGuideViewController *deviceGuideViewController = segue.destinationViewController;
        deviceGuideViewController.deviceID = _txtUser.text.lowercaseString;
    }
    else if ([segue.identifier isEqualToString:@"MNQRCodeViewController"])
    {
        MNQRCodeViewController *QRCodeViewController = segue.destinationViewController;
        QRCodeViewController.loginViewController = self;
        QRCodeViewController.navigationItem.rightBarButtonItem = nil;
    }
    else if ([segue.identifier isEqualToString:@"MNDeviceOfflineViewController"])
    {
        MNDeviceOfflineViewController *deviceOfflineViewController = segue.destinationViewController;
        deviceOfflineViewController.deviceID = _txtUser.text.lowercaseString;
        deviceOfflineViewController.devicePassword = _txtPassword.text;
    }
    else if ([segue.identifier isEqualToString:@"MNModifyWIFIViewController"])
    {
        MNModifyWIFIViewController *modifyWIFIViewController = segue.destinationViewController;
        modifyWIFIViewController.deviceID = _txtUser.text.lowercaseString;
    }
    else if ([segue.identifier isEqualToString:@"MNPrepareRecoveryViewController"])
    {
        MNPrepareRecoveryViewController *prepareRecoveryViewController = segue.destinationViewController;
        prepareRecoveryViewController.userName = _txtUser.text.length ? _txtUser.text.lowercaseString : nil;
    }
}

#pragma mark - Keyboard
- (void)keyboardDidShow:(NSNotification*)notification
{
    if (self.app.is_eyedot || self.app.is_eyeview)
    {
        if (self.view.frame.origin.y <= -100) {
            return;
        }
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.view.frame;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                rect.origin.y = rect.origin.y - 180;
            }
            else
            {
                rect.origin.y = rect.origin.y - 100;
            }
            self.view.frame = rect;
        }];
    }
    else
    {
        // ipad horizontal screen
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)) && self.view.frame.origin.y >= 0 && !self.app.is_vimtag && !self.app.is_luxcam) {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect rect = self.view.frame;
                rect.origin.y = rect.origin.y - 70;
                self.view.frame = rect;
            }];
        }
        else if (self.view.frame.size.height > 480 || self.app.is_vimtag || self.app.is_luxcam || self.view.frame.origin.y <= -70) {
            return;
        }
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y = rect.origin.y - 70;
            self.view.frame = rect;
        }];
    }
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    if (self.app.is_eyedot || self.app.is_eyeview)
    {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.view.frame;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                rect.origin.y = 0;
            }
            else
            {
                rect.origin.y = 0;
            }
            self.view.frame = rect;
        }];
    }
    else
    {
        // ipad horizontal screen
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)) && self.view.frame.origin.y <= -70 && !self.app.is_luxcam && !self.app.is_vimtag) {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect rect = self.view.frame;
                rect.origin.y = rect.origin.y + 70;
                self.view.frame = rect;
            }];
        }
        else if (self.view.frame.size.height > 480 || self.app.is_vimtag || self.app.is_luxcam || self.view.frame.origin.y >= 0) {
            return;
        }
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y = rect.origin.y + 70;
            self.view.frame = rect;
        }];
    }
}

#pragma mark - Utils
- (void)saveUserInfoToLocal
{
    NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"users"];
    
    NSMutableArray *usersArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:usersData]];
    
    NSString *userName = _txtUser.text;
    //    NSString *password = _txtPassword.text;
    char *pass_md5 = _encrypt_pwd;
    NSData *data_pass = [NSData dataWithBytes:pass_md5   length:strlen(pass_md5)];
    
    
    if (userName && data_pass)
    {
        UserInfo *userInfo = [[UserInfo alloc] init];
        userInfo.name = userName;
        userInfo.password = data_pass;
        //        userInfo.password = password;
        
        if (![usersArray containsObject:userInfo])
        {
            [usersArray insertObject:userInfo atIndex:0];
            if (usersArray.count > 4) {
                [usersArray removeLastObject];
            }
            
            NSData *usersData = [NSKeyedArchiver archivedDataWithRootObject:usersArray];
            
            [[NSUserDefaults standardUserDefaults] setObject:usersData forKey:@"users"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        else
        {
            for (int i =0; i<usersArray.count; i++) {
                UserInfo *tempInfo = [usersArray objectAtIndex:i];
                if ([tempInfo.name isEqualToString:userInfo.name])
                {
                    [usersArray replaceObjectAtIndex:i withObject:userInfo];
                    NSData *usersData = [NSKeyedArchiver archivedDataWithRootObject:usersArray];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:usersData forKey:@"users"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
    }
    
}

-(UIViewController *)getCurrentRootViewController
{
    UIViewController *result;
    // Try to find the root view controller programmically
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        
        
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    }
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
    {
        result = topWindow.rootViewController;
    }
    else
        NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
    
    return result;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    [UIView animateWithDuration:0.5 animations:^{
        NSInteger count = [self.usersArray count];
        CGRect frame = tableView.frame;
        frame.size.height = count * 44;
        [tableView setFrame:frame];
    } completion:nil];
    
    return [self.usersArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    UserInfo *userInfo = [_usersArray objectAtIndex:indexPath.row];
    cell.textLabel.text = userInfo.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfo *userInfo = [self.usersArray objectAtIndex:[indexPath row]];
    [_txtUser setText:userInfo.name];
    if ([userInfo.password isKindOfClass:[NSString class]]) {
        [_txtPassword setText:[NSString stringWithFormat:@"%@", userInfo.password]];
    }
    else{
        [_txtPassword setText:@"*********"];
    }
    [tableView removeFromSuperview];
    self.usersTableView = nil;
    
}
#pragma mark - ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage =  scrollView.contentOffset.x / _alertLevelWindow.frame.size.width;
}

#pragma mark - webView
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *meta;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom=1.3"];
    }
    else if (self.view.frame.size.height <= 480)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=0.8, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    else if (self.view.frame.size.height > 480 && self.view.frame.size.height <= 568)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=0.9, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    else if (self.view.frame.size.height > 568 && self.view.frame.size.height <= 667)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    else if(self.view.frame.size.height > 667)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    
    [webView stringByEvaluatingJavaScriptFromString:meta];
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (BOOL)webView: (UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = [request URL];
    if ([[url absoluteString] isEqualToString:@"http://vimtag.com/download/"] || [[url absoluteString] isEqualToString:@"http://mipcm.com/download/"])
    {
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    return YES;
}


@end
