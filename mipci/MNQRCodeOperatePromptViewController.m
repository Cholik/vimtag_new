
//
//  MNQRCodeOperatePromptViewController.m
//  mipci
//
//  Created by mining on 15/12/26.
//
//

#import "MNQRCodeOperatePromptViewController.h"
#import "MNConfiguration.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNWIFIConnectViewController.h"
#import "MNDeviceOfflineViewController.h"

@interface MNQRCodeOperatePromptViewController ()
{
    long         _longPressCounts;
}

@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic)   AppDelegate *app;
@property (assign, nonatomic) BOOL      wifiConfig;

@end

@implementation MNQRCodeOperatePromptViewController

-(mipc_agent *)agent
{
    return self.app.cloudAgent;
}

- (AppDelegate *)app
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_operation_prompt", nil);
    _operatePromptLabel.text = NSLocalizedString(@"mcs_operate_prompt", nil);
    _promptContentLabel.text = NSLocalizedString(@"mcs_qrcode_camera_distance", nil);
    [_nextButton setTitle:NSLocalizedString(@"mcs_action_next", nil) forState:UIControlStateNormal];
    [_nextButton setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    _operatePromptLabel.textColor = self.configuration.labelTextColor;
    _promptContentLabel.textColor = self.configuration.labelTextColor;
    if (self.app.is_luxcam) {
        [_nextButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
    }
    else if (self.app.is_vimtag)
    {
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"vt_determine"] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_promptImage setImage:[UIImage imageNamed:@"vt_wifiQRcodePrompt.png"]];
    }
    else
    {
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_promptImage setImage:[UIImage imageNamed:@"wifiQRcodePrompt"]];
    }
    
    //adaptation device
    if (self.view.frame.size.height == 568)
    {
        _operatePromptTopConstraint.constant = 16;
        _promptContentVerticalConstraint.constant = 8;
        _promptImageTopConstraint.constant = 20;
        _nextButtonVerticalConstraint.constant = 50;
    }
    else if (self.view.frame.size.height == 667)
    {
        _operatePromptTopConstraint.constant = 26;
        _promptContentVerticalConstraint.constant = 8;
        _promptImageTopConstraint.constant = 30;
        _nextButtonVerticalConstraint.constant = 60;
    }
    else if (self.view.frame.size.height >= 736)
    {
        _operatePromptTopConstraint.constant = 31;
        _promptContentVerticalConstraint.constant = 10;
        _promptImageTopConstraint.constant = 35;
        _nextButtonVerticalConstraint.constant = 70;
    }
    
     [self.navigationItem.backBarButtonItem setTitle:NSLocalizedString(@"mcs_back", nil)];
    
    _wifiConfig = YES;
    _SelectConfigStyleView.hidden = YES;
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 1;
    [self.view addGestureRecognizer:longPressGestureRecognizer];
}

#pragma mark - Action
- (IBAction)nextAction:(id)sender
{
    [self performSegueWithIdentifier:@"MNWIFIConnectViewController" sender:nil];
}
- (IBAction)close:(id)sender
{
    if (self.app.is_jump && self.app.isLoginByID)
    {
        NSString  *message = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"mcs_device_offline",nil), NSLocalizedString(@"mcs_will_back",nil), self.app.fromTarget];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
        [alertView show];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

- (IBAction)back:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)wifiConfig:(id)sender
{
    UISwitch *wifiConfigSwitch = sender;
    _wifiConfig = wifiConfigSwitch.on;
    for (UIViewController *viewControllr in self.navigationController.viewControllers)
    {
        if ([viewControllr isMemberOfClass:[MNDeviceOfflineViewController class]])
        {
            (((MNDeviceOfflineViewController *)viewControllr).wfc) = wifiConfigSwitch.on;
        }
    }
}

- (IBAction)qrcodeConfig:(id)sender
{
    UISwitch *wifiConfigSwitch = sender;
    for (UIViewController *viewControllr in self.navigationController.viewControllers)
    {
        if ([viewControllr isMemberOfClass:[MNDeviceOfflineViewController class]])
        {
            (((MNDeviceOfflineViewController *)viewControllr).qrc) = wifiConfigSwitch.on;
        }
    }
}

- (IBAction)soundConfig:(id)sender
{
    UISwitch *wifiConfigSwitch = sender;
    for (UIViewController *viewControllr in self.navigationController.viewControllers)
    {
        if ([viewControllr isMemberOfClass:[MNDeviceOfflineViewController class]])
        {
            
            (((MNDeviceOfflineViewController *)viewControllr).snc) = wifiConfigSwitch.on;
        }
    }
}

- (IBAction)closeView:(id)sender {
    _SelectConfigStyleView.hidden = YES;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        ++_longPressCounts;
        if (3 <= _longPressCounts)
        {
            _SelectConfigStyleView.hidden = NO;
            _longPressCounts = 0;
        }
    }
}
#pragma mark - prepareForSegue

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqual: @"MNWIFIConnectViewController"]) {
        MNWIFIConnectViewController *wifiConnectViewController  = segue.destinationViewController;
        wifiConnectViewController.deviceID = _deviceID;
        wifiConnectViewController.devicePassword = _devicePassword;
        wifiConnectViewController.wifiNameTextField = _wifiNameTextField;
        wifiConnectViewController.wifiPasswordTextField = _wifiPasswordTextField;
        wifiConnectViewController.is_loginModify = _is_loginModify;
//        wifiConnectViewController.wifiConfig = _wifiConfig;
    }
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

#pragma mark - UIAlertViewdelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *url = [self.app.fromTarget stringByAppendingString:@"://ret.dev.offline"];
    if (buttonIndex == 1 && url) {
        self.app.is_jump = NO;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end
