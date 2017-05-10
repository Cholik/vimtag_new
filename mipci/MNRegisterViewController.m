//
//  MNRegisterViewController.m
//  mipci
//
//  Created by mining on 13-5-2.
//
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#import "MNRegisterViewController.h"
#import "MNLoginViewController.h"
#import "AppDelegate.h"
#import "MNProgressHUD.h"
#import "MNInfoPromptView.h"
#import "MNRootNavigationController.h"
#import "MNRegisterSuccessViewController.h"
#import "MNConfiguration.h"

@interface MNRegisterViewController ()
{
    long                                _isLoginning;
    long                                _isSelfOrginFrameActive;
    CGRect                              _selfOrginFrame;
    long                                _active;
    long                                _checkText;
}

@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (assign, nonatomic) BOOL is_showPassword;
@property (assign, nonatomic) BOOL is_showComfirm;
@property (assign, nonatomic) BOOL is_showPrivacyView;

@end

@implementation MNRegisterViewController
@synthesize userText                = _userText;
@synthesize pwdText                 = _pwdText;
@synthesize comfirmText             = _comfirmText;
@synthesize logo                    = _logo;
@synthesize registerBtn             = _registerBtn;
@synthesize statusLable             = _statusLable;
@synthesize loginViewController               = _loginViewController;
@synthesize backBtn                 = _backBtn;
@synthesize agent                   = _agent;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    self.title = NSLocalizedString(@"mcs_sign_up", nil);
    
    self.is_showPrivacyView = NO;
    if (self.app.is_vimtag) {
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"u_privacy"].length) {
            self.is_showPrivacyView = YES;
        }
    }
    
    _userLine.layer.cornerRadius       = 6;
    _userLine.layer.masksToBounds      = YES;
    _pwdLine.layer.cornerRadius       = 6;
    _pwdLine.layer.masksToBounds      = YES;
    _comfirmLine.layer.cornerRadius       = 6;
    _comfirmLine.layer.masksToBounds      = YES;
    _userText.delegate = self;
    _userText.placeholder =  NSLocalizedString(@"mcs_input_username",nil);
    _userText.keyboardType = UIKeyboardTypeASCIICapable;
    _userText.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pwdText.delegate = self;
    _pwdText.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pwdText.placeholder = NSLocalizedString(@"mcs_input_password",nil);
    _pwdText.secureTextEntry = 1;
    _pwdText.keyboardType = UIKeyboardTypeASCIICapable;
    _comfirmText.delegate = self;
    _comfirmText.placeholder = NSLocalizedString(@"mcs_confirm_password",nil);
    _comfirmText.keyboardType = UIKeyboardTypeASCIICapable;
    _comfirmText.secureTextEntry = 1;
    _comfirmText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_registerBtn setTitle:NSLocalizedString(@"mcs_sign_up",nil) forState:UIControlStateSelected];
    [_registerBtn setTitle:NSLocalizedString(@"mcs_sign_up",nil) forState:UIControlStateNormal];
    [_registerBtn setTitle:NSLocalizedString(@"mcs_sign_up",nil) forState:UIControlStateDisabled];
    [_registerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
    [_registerBtn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_backLoginBtn setTitle:NSLocalizedString(@"mcs_sign_in",nil) forState:UIControlStateNormal];
    [_registerBtn setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    _existAccountLabel.text = NSLocalizedString(@"mcs_have_account", nil);
    self.is_showPassword = NO;
    self.is_showComfirm = NO;
    [_showPasswordBtn setImage:[UIImage imageNamed:self.is_showPassword?@"vt_eye.png":@"vt_eye_gray.png"] forState:UIControlStateNormal];
    [_showComfirmBtn setImage:[UIImage imageNamed:self.is_showPassword?@"vt_eye.png":@"vt_eye_gray.png"] forState:UIControlStateNormal];
    _checkUsernameImage.hidden = YES;
    
    if (self.app.is_luxcam) {
        [_userInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_passwordInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_confirmPasswordInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_registerBtn setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    } else if (self.app.is_vimtag) {
        if (_is_showPrivacyView) {
            _privacyView.hidden = NO;

            [_agreeButton setTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"mcs_already_read", nil)] forState:UIControlStateNormal];
            [_agreeButton setTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"mcs_already_read", nil)] forState:UIControlStateSelected];
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", NSLocalizedString(@"mcs_privacy_policy", nil)]];
            NSRange strRange = {0,[str length]};
            [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
            [str addAttribute:NSForegroundColorAttributeName value:self.configuration.switchTintColor range:NSMakeRange(0, str.length)];
            [_privacyButton setAttributedTitle:str forState:UIControlStateNormal];
            
            CGSize agreeButtonSize = [_agreeButton.titleLabel.text boundingRectWithSize:CGSizeMake(320, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_agreeButton.titleLabel.font} context:nil].size;
            _agreeButtonWidth.constant = agreeButtonSize.width+18;
            CGSize privacyButtonSize = [_privacyButton.titleLabel.text boundingRectWithSize:CGSizeMake(320, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_privacyButton.titleLabel.font} context:nil].size;
            _privacyButtonWidth.constant = privacyButtonSize.width+2;
            _privacyButtonLayoutConstraint.constant = _agreeButtonWidth.constant;
            _privacyViewWidth.constant = _agreeButtonWidth.constant+_privacyButtonWidth.constant;
        } else {
            _privacyView.hidden = YES;
        }
    } else if (self.app.is_mipc) {
        _userText.textColor = UIColorFromRGB(0x6b7a99);
        _pwdText.textColor = UIColorFromRGB(0x6b7a99);
        _comfirmText.textColor = UIColorFromRGB(0x6b7a99);
        [_userText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
        [_pwdText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
        [_comfirmText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initUI];
    
    _active = 1;
    _checkText = 0;
    AppDelegate  *appDelegate = [[UIApplication sharedApplication] delegate];
    self.agent   = appDelegate.agent;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillHideNotification object:nil];
    [_backBtn setTitle:NSLocalizedString(@"mcs_back",nil) forState:UIControlStateNormal];
    
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self    action:@selector(backupgroupTap:)];
//    tapGestureRecognizer.numberOfTapsRequired = 1;
//    tapGestureRecognizer.delegate = self;
//    [self.view addGestureRecognizer: tapGestureRecognizer];
//    [tapGestureRecognizer setCancelsTouchesInView:YES];
    
//     UILongPressGestureRecognizer  *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self    action:@selector(onLongPress:)];
//     longPress.minimumPressDuration = 2;
//     [self.view addGestureRecognizer: longPress];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.app.is_vimtag) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _active = 0;
    [MNInfoPromptView hideAll:self.navigationController];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.app.is_vimtag) {
        if (!self.is_toLogin) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
}

// - (void)onLongPress:(UILongPressGestureRecognizer*)recognizer
// {
// if(recognizer.state == UIGestureRecognizerStateEnded)
// {
// static int i = 0;
// //_logo.hidden = ++i%3;
// }
// }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)predicateString:(NSString*)text regex:(NSString*)regex
{
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",regex];
    return [userPredicate evaluateWithObject:text];
}

- (IBAction)onInputEnd:(UITextField*)sender
{
    [sender resignFirstResponder];
    if (self.app.is_ebitcam) {
        _statusTextView.text = @"";
    } else if (self.app.is_mipc) {
        _userImage.highlighted = NO;
        _pwdImage.highlighted = NO;
        _confirmImage.highlighted = NO;
        _userInputImage.highlighted = NO;
        _pwdInputImage.highlighted = NO;
        _confirmInputImage.highlighted = NO;
        _userText.textColor = UIColorFromRGB(0x6b7a99);
        _pwdText.textColor = UIColorFromRGB(0x6b7a99);
        _comfirmText.textColor = UIColorFromRGB(0x6b7a99);
        [_userText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
        [_pwdText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
        [_comfirmText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
        
        _statusTextView.text = @"";
    }
}

- (IBAction)onBeginEditting:(UITextField *)textField
{
    self.statusLable.textColor = [UIColor lightGrayColor];
    if (textField == _userText)
    {
        _checkText = 1;
        if (self.app.is_vimtag) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_user_letter_range_hint",nil) style:MNInfoPromptViewStyleInfo isModal:YES navigation:self.navigationController];
        } else if (self.app.is_ebitcam) {
            _statusTextView.text = NSLocalizedString(@"mcs_user_letter_range_hint",nil);
            _statusTextView.textColor = UIColorFromRGB(0xa1a6b3);
        } else if (self.app.is_mipc) {
            _userImage.highlighted = YES;
            _pwdImage.highlighted = NO;
            _confirmImage.highlighted = NO;
            _userInputImage.highlighted = YES;
            _pwdInputImage.highlighted = NO;
            _confirmInputImage.highlighted = NO;
            _userText.textColor = UIColorFromRGB(0x2988cc);
            _pwdText.textColor = UIColorFromRGB(0x6b7a99);
            _comfirmText.textColor = UIColorFromRGB(0x6b7a99);
            [_userText setValue:UIColorFromRGB(0x2988cc) forKeyPath:@"_placeholderLabel.textColor"];
            [_pwdText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
            [_comfirmText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
            
            _statusTextView.text = NSLocalizedString(@"mcs_user_letter_range_hint",nil);
            _statusTextView.textColor = UIColorFromRGB(0x6b7a99);
        } else {
            self.statusLable.text = NSLocalizedString(@"mcs_user_letter_range_hint",nil);
        }
        return;
    }
    if (textField == _pwdText)
    {
        _checkText = 2;
        if (self.app.is_vimtag) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_range_hint",nil) style:MNInfoPromptViewStyleInfo isModal:YES navigation:self.navigationController];
        } else if (self.app.is_ebitcam) {
            _statusTextView.text = NSLocalizedString(@"mcs_password_range_hint",nil);
            _statusTextView.textColor = UIColorFromRGB(0xa1a6b3);
        } else if (self.app.is_mipc) {
            _userImage.highlighted = NO;
            _pwdImage.highlighted = YES;
            _confirmImage.highlighted = NO;
            _userInputImage.highlighted = NO;
            _pwdInputImage.highlighted = YES;
            _confirmInputImage.highlighted = NO;
            _userText.textColor = UIColorFromRGB(0x6b7a99);
            _pwdText.textColor = UIColorFromRGB(0x2988cc);
            _comfirmText.textColor = UIColorFromRGB(0x6b7a99);
            [_userText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
            [_pwdText setValue:UIColorFromRGB(0x2988cc) forKeyPath:@"_placeholderLabel.textColor"];
            [_comfirmText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
            
            _statusTextView.text = NSLocalizedString(@"mcs_password_range_hint",nil);
            _statusTextView.textColor = UIColorFromRGB(0x6b7a99);
        } else {
            self.statusLable.text = NSLocalizedString(@"mcs_password_range_hint",nil);
        }
        return;
    }
    if (textField == _comfirmText)
    {
        _checkText = 3;
        if (self.app.is_vimtag) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_range_hint",nil) style:MNInfoPromptViewStyleInfo isModal:YES navigation:self.navigationController];
        } else if (self.app.is_ebitcam) {
            _statusTextView.text = NSLocalizedString(@"mcs_password_range_hint",nil);
            _statusTextView.textColor = UIColorFromRGB(0xa1a6b3);
        } else if (self.app.is_mipc) {
            _userImage.highlighted = NO;
            _pwdImage.highlighted = NO;
            _confirmImage.highlighted = YES;
            _userInputImage.highlighted = NO;
            _pwdInputImage.highlighted = NO;
            _confirmInputImage.highlighted = YES;
            _userText.textColor = UIColorFromRGB(0x6b7a99);
            _pwdText.textColor = UIColorFromRGB(0x6b7a99);
            _comfirmText.textColor = UIColorFromRGB(0x2988cc);
            [_userText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
            [_pwdText setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
            [_comfirmText setValue:UIColorFromRGB(0x2988cc) forKeyPath:@"_placeholderLabel.textColor"];
            
            _statusTextView.text = NSLocalizedString(@"mcs_password_range_hint",nil);
            _statusTextView.textColor = UIColorFromRGB(0x6b7a99);
        } else {
            self.statusLable.text = NSLocalizedString(@"mcs_password_range_hint",nil);
        }
    }
}

- (IBAction)onEndEditting:(UITextField*)sender
{
    [sender resignFirstResponder];
    
    if (self.app.is_ebitcam || self.app.is_mipc) {
        if (![self predicateString:self.userText.text regex:@"[A-Za-z]{1}+[A-Za-z0-9]*"])
        {
            _checkUsernameImage.hidden = YES;
        } else if (self.userText.text.length < 6 || self.userText.text.length > 32) {
            _checkUsernameImage.hidden = YES;

        } else {
            _checkUsernameImage.hidden = NO;
        }
    }
    return;
}


- (IBAction)registerBtnClick:(id)sender
{
    self.statusLable.text = @"";
    self.statusLable.textColor = [UIColor redColor];
    if (!self.userText.text.length)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_the_user_name_is_empty",nil) style:MNInfoPromptViewStyleError isModal:self.app.is_vimtag ? YES : NO navigation:self.navigationController];
        } else {
            self.statusLable.text = NSLocalizedString(@"mcs_the_user_name_is_empty",nil);
        }
        return;
    }
    //Repair Username
    if(_userText.text && _userText.text.length && [[NSString stringWithFormat:@"%@",_userText.text] rangeOfString:@" "].length)
    {
        NSString *fixedUser = [[NSString stringWithFormat:@"%@",_userText.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _userText.text = fixedUser;
    }
    
    if (!self.pwdText.text.length || !self.comfirmText.text.length)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_the_password_is_empty",nil) style:MNInfoPromptViewStyleError isModal:self.app.is_vimtag ? YES : NO navigation:self.navigationController];
        } else {
            self.statusLable.text = NSLocalizedString(@"mcs_the_password_is_empty",nil);
        }
        return;
    }

    if (![self predicateString:self.userText.text regex:@"[A-Za-z]{1}+[A-Za-z0-9]*"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_user_letter_range_hint",nil) style:MNInfoPromptViewStyleError isModal:self.app.is_vimtag ? YES : NO navigation:self.navigationController];
        } else {
            self.statusLable.text = NSLocalizedString(@"mcs_user_letter_range_hint",nil);
        }
        return;
    }
    
    if (self.userText.text.length < 6 || self.userText.text.length > 32)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_user_letter_range_hint",nil) style:MNInfoPromptViewStyleError isModal:self.app.is_vimtag ? YES : NO navigation:self.navigationController];
        } else {
            self.statusLable.text = NSLocalizedString(@"mcs_user_letter_range_hint",nil);
        }
        return;
    }

    if (![self.pwdText.text isEqualToString:self.comfirmText.text])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_input_inconsistent",nil) style:MNInfoPromptViewStyleError isModal:self.app.is_vimtag ? YES : NO navigation:self.navigationController];
        } else {
            self.statusLable.text = NSLocalizedString(@"mcs_password_input_inconsistent",nil);
        }
        return;
    }
    if (self.pwdText.text.length < 6 || self.pwdText.text.length > 32)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_range_hint",nil) style:MNInfoPromptViewStyleError isModal:self.app.is_vimtag ? YES : NO navigation:self.navigationController];
        } else {
            self.statusLable.text = NSLocalizedString(@"mcs_password_range_hint",nil);
        }
        return;
    }
    if (self.app.is_vimtag && _is_showPrivacyView) {
        if (!_agreeButton.selected) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_not_agree_privacy_policy",nil) style:MNInfoPromptViewStyleError isModal:self.app.is_vimtag ? YES : NO navigation:self.navigationController];
            return;
        }
    }
    
    if (self.app.is_InfoPrompt) {
        [MNInfoPromptView hideAll:self.navigationController];
    }
    
    mcall_ctx_sign_up *ctx = [[mcall_ctx_sign_up alloc] init];
    ctx.user = _userText.text;
    
    unsigned char *pwd = malloc(16);
    
    [mipc_agent passwd_encrypt:_pwdText.text encrypt_pwd:pwd];
    ctx.passwd = pwd;
    ctx.on_event = @selector(sign_up_done:);
    ctx.target = self;
     
    [_agent sign_up:ctx];
    [self.progressHUD show:YES];
}

- (void)sign_up_done:(mcall_ret_sign_up *)ret
{
    if (!_active)
    {
        return;
    }
    
    [self.progressHUD hide:YES];
    
    if(nil == ret.result)
    {
        if (self.app.is_vimtag) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_successful_sign_up",nil) style:MNInfoPromptViewStyleInfo isModal:self.app.is_vimtag ? YES : NO navigation:self.navigationController];
        } else {
            self.statusLable.textColor = [UIColor lightGrayColor];
            self.statusLable.text = NSLocalizedString(@"mcs_successful_sign_up", nil);
        }
        
        _loginViewController.txtUser.text  = self.userText.text;
        _loginViewController.txtPassword.text  = self.pwdText.text;
        [[NSUserDefaults standardUserDefaults] setObject:self.pwdText.text forKey:@"password"];

         unsigned char    encrypt_pwd[16] = {0};
        [mipc_agent passwd_encrypt:self.pwdText.text encrypt_pwd:encrypt_pwd];
            
    
        struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
        
        if(conf)
        {
            conf_new        = *conf;
        }
        conf_new.password_md5.data = (char*)encrypt_pwd;
        conf_new.password_md5.len = 16;
        if (self.app.is_vimtag && self.is_ListRegister)
        {
            conf_new.user.data = (char*)(self.userText.text?self.userText.text.UTF8String:NULL);
            conf_new.user.len = (uint32_t)(self.userText.text?self.userText.text.length:0);
        }
        MIPC_ConfigSave(&conf_new);

        if (self.app.is_ebitcam || self.app.is_mipc) {
            [self performSegueWithIdentifier:@"MNRegisterSuccessViewController" sender:nil];
        } else {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(1 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               if (self.app.is_vimtag) {
                                   if (self.is_ListRegister) {
                                       self.is_toLogin = YES;
                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil];
                                       MNLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"MNLoginViewController"];
                                       [self.navigationController pushViewController:loginViewController animated:YES];
                                   } else {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   }
                               } else {
                                   [weakSelf.navigationController popViewControllerAnimated:YES];
                               }
                           });
        }
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.user.existed"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_username_already_exists",nil) style:MNInfoPromptViewStyleError isModal:self.app.is_vimtag ? YES : NO navigation:self.navigationController];
            } else {
                self.statusLable.text = NSLocalizedString(@"mcs_username_already_exists", nil);
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_sign_up_failed",nil) style:MNInfoPromptViewStyleError isModal:self.app.is_vimtag ? YES : NO navigation:self.navigationController];
            } else {
                self.statusLable.text = NSLocalizedString(@"mcs_sign_up_failed", nil);
            }
        }
     //   self.statusLable.text = ret.result;
    }
}

#pragma mark - Action
- (IBAction)backLogin:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)agree:(id)sender
{
    _agreeButton.selected = !_agreeButton.selected;
}

- (IBAction)toPrivacyView:(id)sender
{
    [self performSegueWithIdentifier:@"MNPrivacyPolicyViewController" sender:nil];
}

- (IBAction)backBtnClick:(id)sender {
    if (self.is_ListRegister) {
        self.is_toLogin = YES;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil];
        MNLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"MNLoginViewController"];
        [self.navigationController pushViewController:loginViewController animated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];

    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        return;
    }
    
    if (self.presentingViewController)
    {
        UINavigationController *rootNavigationcontroller = (UINavigationController*)self.presentingViewController;
        for (UIViewController *viewController in rootNavigationcontroller.viewControllers)
        {
            if ([viewController isMemberOfClass:[MNLoginViewController class]]) {
                [((MNLoginViewController*)viewController) dismissViewControllerAnimated:NO completion:nil];
            }
        }
    }

}

- (IBAction)showPassword:(id)sender {
    _pwdText.secureTextEntry = self.is_showPassword;
    self.is_showPassword = !(self.is_showPassword);
    [_showPasswordBtn setImage:[UIImage imageNamed:self.is_showPassword?@"vt_eye.png":@"vt_eye_gray.png"] forState:UIControlStateNormal];
}
- (IBAction)showComfirm:(id)sender {
    _comfirmText.secureTextEntry = self.is_showComfirm;
    self.is_showComfirm = !(self.is_showComfirm);
    [_showComfirmBtn setImage:[UIImage imageNamed:self.is_showComfirm?@"vt_eye.png":@"vt_eye_gray.png"] forState:UIControlStateNormal];
}

#pragma mark - Rotate
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self closeKeyBoard];
        
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)closeKeyBoard
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self.view],
    subLocation = [touch locationInView:_regView];
    
    if(CGRectContainsPoint(_backBtn.frame, location)
       || CGRectContainsPoint(_logo.frame, subLocation)
       || CGRectContainsPoint(_registerBtn.frame, subLocation))
    {
        return NO;
    }
    return YES;
}
-(void)backupgroupTap:(id)sender
{
    CGRect  newFrame, selfFrame = self.view.frame;
    UIView  *checkView;
    if (1 == _checkText)
    {
        checkView = _userText;
    }
    else if (2 == _checkText)
    {
        checkView = _pwdText;
    }
    else if (3 == _checkText)
    {
        checkView = _comfirmText;
    }
    else
    {
        return;
    }
    [checkView resignFirstResponder];
    
    if(1 == _isSelfOrginFrameActive)
    {
        _selfOrginFrame = selfFrame;
        _isSelfOrginFrameActive = 0;
    }
    newFrame = _selfOrginFrame;
    
    [UIView beginAnimations:@"anim" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    self.view.frame = newFrame;
    
    [UIView commitAnimations];
    
}
#pragma mark -
#pragma mark Responding to keyboard events
-(void)keyboardWillShow:(NSNotification *)notification
{
    if (self.app.is_ebitcam || self.app.is_mipc) {
        return;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([UIApplication sharedApplication].statusBarOrientation != UIDeviceOrientationLandscapeLeft && [UIApplication sharedApplication].statusBarOrientation != UIDeviceOrientationLandscapeRight) {
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
            UIView  *checkView = _comfirmText;
            
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
            
            newFrame.origin.y = (app_height - offsety) - keyboardBounds.size.height + 15;
        }
        
        //  NSLog(@"offset is %f %f", newFrame.origin.x, newFrame.origin.y);
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        
        self.view.frame = newFrame;
        
        [UIView commitAnimations];
    } else {
        if (self.view.frame.size.height > 568) {
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
            UIView  *checkView = _comfirmText;
            
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
        
        self.view.frame = newFrame;
        
        [UIView commitAnimations];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNRegisterSuccessViewController"]) {
        MNRegisterSuccessViewController *registerSuccessViewController = segue.destinationViewController;
        registerSuccessViewController.username = _userText.text;
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
