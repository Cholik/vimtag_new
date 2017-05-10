//
//  MNPrepareRecoveryViewController.m
//  mipci
//
//  Created by mining on 16/4/12.
//
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "MNPrepareRecoveryViewController.h"
#import "MNRecoveryPasswordViewController.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNLoginViewController.h"
#import "MNInfoPromptView.h"
#import "MNProgressHUD.h"
#import "MNConfiguration.h"

@interface MNPrepareRecoveryViewController ()

@property (strong, nonatomic) NSString *currentLanguage;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) BOOL isViewAppearing;

@end

@implementation MNPrepareRecoveryViewController

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
    self.navigationItem.title = NSLocalizedString(@"mcs_forgot_your_password", nil);

    MNConfiguration *configuration = [MNConfiguration shared_configuration];
    self.userTextField.placeholder = NSLocalizedString(@"mcs_input_username", nil);
    self.promptLabel.text = NSLocalizedString(@"mcs_valid_user_name", nil);
    if (!self.app.is_vimtag && !self.app.is_ebitcam && !self.app.is_mipc)
    {
        self.promptLabel.textColor = configuration.labelTextColor;
    }
    if (self.app.is_mipc) {
        _userTextField.textColor = UIColorFromRGB(0x6b7a99);
        [_userTextField setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
    }
    
    self.userTextField.text = _userName;
    [self.nextButton setTitle:NSLocalizedString( @"mcs_action_next", nil) forState:UIControlStateNormal];
    [self.nextButton setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    
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
    // Do any additional setup after loading the view.
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

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editingBegin:(id)sender
{
    if (self.app.is_mipc)
    {
        _userImage.highlighted = YES;
        _userInputImage.highlighted = YES;
        _userTextField.textColor = UIColorFromRGB(0x2988cc);
        [_userTextField setValue:UIColorFromRGB(0x2988cc) forKeyPath:@"_placeholderLabel.textColor"];
    }
}

- (IBAction)endOnExit:(id)sender
{
    [sender resignFirstResponder];
    
    if (self.app.is_mipc)
    {
        _userImage.highlighted = NO;
        _userInputImage.highlighted = NO;
        _userTextField.textColor = UIColorFromRGB(0x6b7a99);
        [_userTextField setValue:UIColorFromRGB(0x6b7a99) forKeyPath:@"_placeholderLabel.textColor"];
    }
}

- (IBAction)next:(id)sender
{
    if(!self.app.is_avuecam && ((nil == _userTextField.text) || (0 == _userTextField.text.length)))
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_please_input_username",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
    }
    else
    {
        [MNInfoPromptView hideAll:self.navigationController];

        //Repair Username
        if(_userTextField.text && _userTextField.text.length && [[NSString stringWithFormat:@"%@",_userTextField.text] rangeOfString:@" "].length)
        {
            NSString *fixedUser = [[NSString stringWithFormat:@"%@",_userTextField.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            _userTextField.text = fixedUser;
        }
        
        mcall_ctx_email_get *ctx = [[mcall_ctx_email_get alloc] init];
        ctx.target = self;
        ctx.user = _userTextField.text;
        ctx.on_event = @selector(bind_email_get_done:);
        [self.agent email_get:ctx];
        [self.progressHUD show:YES];
    }
}

- (void)bind_email_get_done:(mcall_ret_email_get*)ret
{
    [self.progressHUD hide:YES];

    if (!_isViewAppearing) {
        return;
    }
    if (nil == ret.result)
    {
        if (ret.active_email)
        {
            [self performSegueWithIdentifier:@"MNRecoveryPasswordViewController" sender:ret.email];
        }
        else
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_email_unbind",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
    }
    else if ([ret.result isEqualToString:@"ret.user.unknown"])
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_user",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else if ([ret.result isEqualToString:@"ret.email.unbind"])
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_email_unbind",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

#pragma mark - prepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNRecoveryPasswordViewController"]) {
        MNRecoveryPasswordViewController *recoveryPasswordViewController = segue.destinationViewController;
        recoveryPasswordViewController.emailString = sender;
        recoveryPasswordViewController.userName = _userTextField.text;
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
