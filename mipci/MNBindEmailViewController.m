//
//  MNBindEmailViewController.m
//  mipci
//
//  Created by mining on 16/11/16.
//
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define EMAILERROR 1000
#define EMAILSEND  1001

#import "MNBindEmailViewController.h"
#import "MNInfoPromptView.h"

#import "AppDelegate.h"
#import "mipc_agent.h"
#import "MNConfiguration.h"
#import "MIPCUtils.h"
#import "MNProgressHUD.h"
#import "MNToastView.h"

@interface MNBindEmailViewController () <UITextFieldDelegate>
{
    unsigned char  _encrypt_pwd[16];
}
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) MNProgressHUD *progressHUD;

@property(strong, nonatomic) NSString* currentLanguage;
@property(assign, nonatomic) BOOL isViewAppearing;

@end

@implementation MNBindEmailViewController

- (mipc_agent *)agent
{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return app.cloudAgent;
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

- (MNProgressHUD *)progressHUD
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

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_binding_email", nil);
    
    _promptLabel.text = NSLocalizedString(@"mcs_bind_email_prompt", nil);
    [_bindEmailButton setTitle:NSLocalizedString(@"mcs_binding", nil) forState:UIControlStateNormal];
    
    _emailTextField.delegate = self;
    _emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailTextField.placeholder = NSLocalizedString(@"mcs_input_email_addr", nil);
    _emailTextField.secureTextEntry = NO;
    _emailTextField.keyboardType = UIKeyboardTypeASCIICapable;
    if (self.app.is_mipc) {
        _emailTextField.textColor = UIColorFromRGB(0x6b7a99);
        [_emailTextField setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
    }
    
    //get currentLanguage
    NSUserDefaults *defaults = [ NSUserDefaults standardUserDefaults ];
    NSArray *languages = [defaults objectForKey : @"AppleLanguages" ];
    _currentLanguage = [languages objectAtIndex:0];
    if ([_currentLanguage rangeOfString:@"zh-Hans"].length) {
        _currentLanguage=@"zh";
    }
    if ([_currentLanguage rangeOfString:@"zh-Hant"].length) {
        _currentLanguage=@"tw";
    }
    
    if (_is_register) {
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_delete.png"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        
        //get email information
        mcall_ctx_email_get *ctx = [[mcall_ctx_email_get alloc] init];
        ctx.target = self;
        ctx.on_event = @selector(bind_email_get_done:);
        [self.agent bind_email_get:ctx];
        [self.progressHUD show:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _isViewAppearing = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _isViewAppearing = NO;
    [MNInfoPromptView hideAll:self.navigationController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)close
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onBeginEditting:(id)sender
{
    if (sender == _emailTextField)
    {
        if (self.app.is_mipc)
        {
            _emailImage.highlighted = YES;
            _emailInputImage.highlighted = YES;
            _emailTextField.textColor = UIColorFromRGB(0x2988cc);
            [_emailTextField setValue:UIColorFromRGB(0x2988cc) forKeyPath:@"_placeholderLabel.textColor"];
        }
    }
}

- (IBAction)onEndExit:(id)sender
{
    [sender resignFirstResponder];

    if (self.app.is_mipc)
    {
        _emailImage.highlighted = NO;
        _emailInputImage.highlighted = NO;
        _emailTextField.textColor = UIColorFromRGB(0x6b7a99);
        [_emailTextField setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
    }
}

- (IBAction)onEndEditting:(id)sender
{
    [sender resignFirstResponder];
    return;
}

- (IBAction)binding:(id)sender
{
    if ([self validateEmail:_emailTextField.text]) {
        mcall_ctx_email_set *ctx = [[mcall_ctx_email_set alloc] init];
        ctx.lang = _currentLanguage;
        ctx.email = _emailTextField.text;
        ctx.mobile = @"";
        ctx.on_event = @selector(bind_email_set_done:);
        ctx.target = self;
        
        struct mipci_conf *conf = MIPC_ConfigLoad();
        if(conf && conf->password_md5.len)
        {
            memcpy(_encrypt_pwd, conf->password_md5.data, sizeof(_encrypt_pwd));
            ctx.encrypt_pwd = _encrypt_pwd;
        }
        ctx.user = _username;
        if (!ctx.user.length) {
            ctx.user = self.agent.user;
        }
        [self.agent email_set:ctx];
        [self.progressHUD show:YES];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil) message:NSLocalizedString(@"mcs_invalid_email_addr", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
        
        alertView.tag = EMAILERROR;
        [alertView show];
    }
}

- (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - Callback
-(void)bind_email_get_done:(mcall_ret_email_get *)ctx
{
    [self.progressHUD hide:YES];
    if (!_isViewAppearing) {
        return;
    }
    if (ctx.email && ctx.active_email)
    {
        _promptLabel.text = NSLocalizedString(@"mcs_binding_email_prompt", nil);
        _emailTextField.text = ctx.email;
        _emailTextField.enabled = NO;
        _bindEmailButton.hidden = YES;
        
        return;
    }
    else if (ctx.email.length)
    {
        _emailTextField.text = ctx.email;
        
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_email_inactive", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_email_inactive", nil)]];
        }
    }
}

- (void)bind_email_set_done:(mcall_ret_email_set *)ctx
{
    [self.progressHUD hide:YES];
    if (!_isViewAppearing) {
        return;
    }
    if ([ctx.result isEqualToString:@"ret.email.binded"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_email_binded", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_email_binded", nil)]];
        }
    }
    else  if ([ctx.result isEqualToString:@"ret.user.binded.byemail"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_user_binded_bymail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_user_binded_bymail", nil)]];
        }
    }
    else if ([ctx.result isEqualToString:@"ret.permission.denied"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_permission_denied", nil)]];
        }
    }
    else if (ctx.result == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)  message:NSLocalizedString(@"mcs_binding_send_prompt",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
        
        alertView.tag = EMAILSEND;
        [alertView show];
    }
    else
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_bind_email_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_bind_email_fail", nil)]];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == EMAILSEND){
        if (_is_register) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Rotate
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
