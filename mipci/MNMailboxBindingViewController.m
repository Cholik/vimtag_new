
//
//  MNMailboxBindingViewController.m
//  mipci
//
//  Created by mining on 15/9/23.
//
//

#define EMAILERROR 1000
#define EMAILSEND  1001

#import "MNMailboxBindingViewController.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "UITableViewController+loading.h"
#import "MNLoginViewController.h"
#import "MNToastView.h"
#import "MNInfoPromptView.h"

@interface MNMailboxBindingViewController ()
{
    unsigned char  _encrypt_pwd[16];
}

@property(strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property(strong, nonatomic) NSString* currentLanguage;
@property(assign, nonatomic) BOOL isViewAppearing;
@property(strong, nonatomic) NSMutableArray *relatedArray;

@end

@implementation MNMailboxBindingViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (mipc_agent *)agent
{
    return self.app.cloudAgent;
}

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_binding_email", nil);
    [_commitButton setTitle:NSLocalizedString(@"mcs_binding", nil) forState:UIControlStateNormal];
    _securityCodeTextField.placeholder = NSLocalizedString(@"mcs_input_email_addr", nil);
    _PromptLabel.text = NSLocalizedString(@"mcs_binding_email_prompt", nil);
    _emailAddressLabel.text = NSLocalizedString(@"mcs_email_address", nil);
    
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_commitButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_commitButton setBackgroundColor:app.button_color];
    _relatedArray = [NSMutableArray arrayWithArray:@[@[[NSNull null]]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    
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
    
    //get email information
    _isViewAppearing = YES;
    mcall_ctx_email_get *ctx = [[mcall_ctx_email_get alloc] init];
    ctx.target = self;
    ctx.on_event = @selector(bind_email_get_done:);
    [self.agent bind_email_get:ctx];
    [self loading:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MNInfoPromptView hideAll:self.navigationController];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view date source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _relatedArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataArray = [_relatedArray objectAtIndex:section];
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == EMAILERROR) {
        ;
    } else if (alertView.tag == EMAILSEND){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - event response
- (IBAction)bind:(id)sender {
    if ([self validateEmail:_securityCodeTextField.text]) {
        [MNInfoPromptView hideAll:self.navigationController];

        mcall_ctx_email_set *ctx = [[mcall_ctx_email_set alloc] init];
        ctx.lang = _currentLanguage;
        ctx.email = _securityCodeTextField.text;
        ctx.mobile = @"";
        ctx.on_event = @selector(bind_email_set_done:);
        ctx.target = self;
        
        if (self.app.is_vimtag) {
            struct mipci_conf *conf = MIPC_ConfigLoad();
            if(conf && conf->password_md5.len)
            {
                memcpy(_encrypt_pwd, conf->password_md5.data, sizeof(_encrypt_pwd));
                ctx.encrypt_pwd = _encrypt_pwd;
            }
        } else {
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isMemberOfClass:[MNLoginViewController class]]) {
                    ctx.encrypt_pwd = ((MNLoginViewController *)viewController).encrypt_password;
                }
            }
        }
        ctx.user = self.agent.user;
        //        for (UIViewController *viewController in self.navigationController.viewControllers) {
        //            if ([viewController isMemberOfClass:[MNLoginViewController class]]) {
        //                ctx.user = ((MNLoginViewController *)viewController).txtUser.text;
        //            }
        //        }
        
        [self.agent bind_email_set:ctx];
        [self loading:YES];
    } else {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_email_addr", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_invalid_email_addr", nil)]];
        }
    }
    
}

#pragma mark - private methods
- (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - Callback
- (void)bind_email_set_done:(mcall_ret_email_set *)ctx
{
    [self loading:NO];
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

-(void)bind_email_get_done:(mcall_ret_email_get *)ctx
{
    [self loading:NO];
    if (!_isViewAppearing) {
        return;
    }
    if (ctx.email && ctx.active_email)
    {
        //            NSString *email = [ctx.email substringToIndex:1];
        //            NSArray *array = [ctx.email componentsSeparatedByString:@"@"];
        //            email = [NSString stringWithFormat:@"%@xxxxxx%@", email, array[1]];
        //            _securityCodeTextField.text = email;
        //            _securityCodeTextField.enabled = NO;
        _securityCodeTextField.text = ctx.email;
        _securityCodeTextField.enabled = NO;
        return;
    }
    else if (ctx.email.length)
    {
        _securityCodeTextField.text = ctx.email;

        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_email_inactive", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_email_inactive", nil)]];
        }
    }
    NSMutableArray *datas = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null]]]]];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
    [_relatedArray insertObjects:datas atIndexes:indexSet];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
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
