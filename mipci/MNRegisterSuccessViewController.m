//
//  MNRegisterSuccessViewController.m
//  mipci
//
//  Created by mining on 16/11/16.
//
//

#import "MNRegisterSuccessViewController.h"
#import "MNBindEmailViewController.h"

#import "AppDelegate.h"
#import "mipc_agent.h"
#import "MNConfiguration.h"


@interface MNRegisterSuccessViewController ()

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) MNConfiguration *configuration;

@end

@implementation MNRegisterSuccessViewController

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

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_sign_up", nil);
    self.navigationItem.hidesBackButton = YES;
    
    _successLabel.text = NSLocalizedString(@"mcs_successful_sign_up", nil);
    _promptLabel.text = NSLocalizedString(@"mcs_bind_email_prompt", nil);
    [_bindEmailButton setTitle:NSLocalizedString(@"mcs_binding_email", nil) forState:UIControlStateNormal];
    [_loginButton setTitle:[NSString stringWithFormat:@"- %@ -", NSLocalizedString(@"mcs_login_now", nil)] forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)bindEmail:(id)sender
{
    [self performSegueWithIdentifier:@"MNBindEmailViewController" sender:nil];
}

- (IBAction)loginNow:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNBindEmailViewController"]) {
        MNBindEmailViewController *bindEmailViewController = segue.destinationViewController;
        bindEmailViewController.username = self.username;
        bindEmailViewController.is_register = YES;
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
