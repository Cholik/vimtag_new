//
//  MNForgetPasswordViewController.m
//  mipci
//
//  Created by mining on 15/6/19.
//
//

#import "MNForgetPasswordViewController.h"
#import "MNAddDeviceViewController.h"
#import "MNConfiguration.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "MNProgressHUD.h"

@interface MNForgetPasswordViewController ()

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (assign, nonatomic) long      wfcnr;
@property (strong, nonatomic) NSString *deviceID;
@end

@implementation MNForgetPasswordViewController

- (AppDelegate *)app
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

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_forgot_your_password", nil);
    [self.navigationItem setHidesBackButton:YES];

    UINavigationController *navigationController = (UINavigationController *)self.presentingViewController;
    for (UIViewController *viewController in navigationController.viewControllers) {
        if ([viewController isMemberOfClass:[MNAddDeviceViewController class]]) {
            _wfcnr = ((MNAddDeviceViewController *)viewController).wfcnr;
            _deviceID = ((MNAddDeviceViewController *)viewController).nameTextField.text;
        }
    }

    MNConfiguration *configuration = [MNConfiguration shared_configuration];
    
    self.restoreLabel.text = _wfcnr ? NSLocalizedString(@"mcs_forgetpass_action_wizard", nil) : NSLocalizedString(@"mcs_forgetpass_action_wizard_old", nil);
    self.restoreLabel.textColor = configuration.labelTextColor;
    [self.closeButton setTitle:(_wfcnr ? NSLocalizedString(@"mcs_voice_remind_heard", nil) : NSLocalizedString(@"mcs_close", nil)) forState:UIControlStateNormal];
    [self.closeButton setTitleColor:configuration.buttonColor forState:UIControlStateNormal];
    
    if (self.app.is_luxcam) {
        [_closeButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
        [_resetImageView setImage:[UIImage imageNamed:@"reset"]];
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
        [_resetImageView setImage:[UIImage imageNamed:@"vt_reset" ]];
    }
    else if (self.app.is_ebitcam)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
        [_resetImageView setImage:[UIImage imageNamed:@"reset"]];
    }
    else if (self.app.is_mipc)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
        [_resetImageView setImage:[UIImage imageNamed:@"reset"]];
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        [_resetImageView setImage:[UIImage imageNamed:@"reset"]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
    _isViewAppearing = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark -Action
- (IBAction)finish:(id)sender
{
    _isViewAppearing = NO;
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

@end
