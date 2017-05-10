//
//  MNRecoveryPasswordViewController.m
//  mipci
//
//  Created by mining on 15/11/7.
//
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "MNRecoveryPasswordViewController.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNLoginViewController.h"
#import "MNInfoPromptView.h"
#import "MNProgressHUD.h"
#import "MNSendEmailFinishViewController.h"
#import "MNConfiguration.h"

@interface MNRecoveryPasswordViewController ()

@property (strong, nonatomic) NSString *currentLanguage;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) BOOL isViewAppearing;

@end

@implementation MNRecoveryPasswordViewController

- (mipc_agent *)agent
{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return app.cloudAgent;
}

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
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

#pragma mark - life cycle
- (void)initUI
{
    self.title = NSLocalizedString(@"mcs_forgot_your_password", nil);
    MNConfiguration *configuration = [MNConfiguration shared_configuration];
    
    self.emailTextField.placeholder = NSLocalizedString(@"mcs_input_email_addr", nil);
    self.promptLabel.text = NSLocalizedString(@"mcs_binding_mailbox", nil);
    if (!self.app.is_vimtag && !self.app.is_ebitcam && !self.app.is_mipc)
    {
        self.promptLabel.textColor = configuration.labelTextColor;
        self.emailPromptLabel.textColor = configuration.color;
    }
    if (self.app.is_mipc) {
        _emailTextField.textColor = UIColorFromRGB(0x6b7a99);
        [_emailTextField setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
    }
    [self.sureButton setTitle:NSLocalizedString( @"mcs_ok", nil) forState:UIControlStateNormal];
    [self.sureButton setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    self.emailPromptLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"mcs_prompt", nil), _emailString];
    //get currentLanguage
    NSUserDefaults *defaults = [ NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey : @"AppleLanguages" ];
    
    _currentLanguage = [languages objectAtIndex:0];
    if ([_currentLanguage rangeOfString:@"zh-Hans"].length) {
        _currentLanguage=@"zh";
    }
    if ([_currentLanguage rangeOfString:@"zh-Hant"].length) {
        _currentLanguage=@"tw";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editingBegin:(id)sender
{
    if (self.app.is_mipc)
    {
        _emailImage.highlighted = YES;
        _emailInputImage.highlighted = YES;
        _emailTextField.textColor = UIColorFromRGB(0x2988cc);
        [_emailTextField setValue:UIColorFromRGB(0x2988cc) forKeyPath:@"_placeholderLabel.textColor"];
    }
}

- (IBAction)endOnExit:(id)sender
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

- (IBAction)reset:(id)sender {
    
  if ([self validateEmail:_emailTextField.text]) {
        [MNInfoPromptView hideAll:self.navigationController];

        mcall_ctx_recovery_password *ctx = [[mcall_ctx_recovery_password alloc] init];
        ctx.user = _userName;
        if (self.app.is_avuecam) {
            ctx.user = _emailTextField.text;
        }
        ctx.email = _emailTextField.text;
        ctx.mobile = @"";
        ctx.lang = _currentLanguage;
        ctx.on_event = @selector(reset_done:);
        ctx.target = self;
        
        [self.agent recovery_password:ctx];
        [self.progressHUD show:YES];
    } else {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_email_addr",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

- (void)reset_done:(mcall_ret_recovery_password *)ret
{
    [self.progressHUD hide:YES];
    
    if (!_isViewAppearing) {
        return;
    }
    if ([ret.result isEqualToString: @"ret.user.unknown"] || [ret.result isEqualToString:@"ret.user.invalid"]) {
          [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_user",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else if ([ret.result isEqualToString:@"ret.mail.invalid"])
    {
         [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_email_addr",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else if ([ret.result isEqualToString:@"ret.email.unbind"])
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_email_unbind",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else if ([ret.result isEqualToString:@"ret.email.unmatch"])
    {
         [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_email_unmatch",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else if ([ret.result isEqualToString:@"ret.email.inactive"])
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_email_inactive",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else if ([ret.result isEqualToString:@"ret.other.reason"])
    {
        
    }
    if (ret.result == nil) {
        [self performSegueWithIdentifier:@"MNSendEmailFinishViewController" sender:nil];

//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)  message:NSLocalizedString(@"mcs_password_reset_confirmation",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
//        [alertView show];
    }
}

#pragma mark - private methods
- (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MNSendEmailFinishViewController"]) {
        MNSendEmailFinishViewController *sendEmailFinishViewController = segue.destinationViewController;
        sendEmailFinishViewController.emailString = _emailString;
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
