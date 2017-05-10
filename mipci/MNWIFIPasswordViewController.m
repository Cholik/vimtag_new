//
//  MNWIFIConnectViewController.m
//  mipci
//
//  Created by mining on 15/5/12.
//
//

#import "MNWIFIPasswordViewController.h"
#import "MNProgressHUD.h"
#import "mwificode.h"
#import "MNLoginViewController.h"
#import "MNAddDeviceViewController.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNPreparationsViewController.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"
//jc's add code
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MIPCUtils.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <ifaddrs.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <sys/socket.h>
//end
#define PASSWORD_FORCHECK @"lk9ds2*%#%dq"


@interface MNWIFIPasswordViewController ()

@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (strong, nonatomic) mipc_agent *agent;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) MNConfiguration *configuration;

@end

@implementation MNWIFIPasswordViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
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
    self.navigationItem.title = NSLocalizedString(@"mcs_wifi_password", nil);
    
    [_connectButton setTitle:NSLocalizedString(@"mcs_action_next", nil) forState:UIControlStateNormal];
    [_connectButton setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    _wifiNameTextField.placeholder = NSLocalizedString(@"mcs_phone_not_connect_wifi", nil);
    _wifiNameTextField.text =  [self get_current_SSID];
    _wifiPasswordTextField.text = @"";
    _wifiPasswordTextField.placeholder = NSLocalizedString(@"mcs_input_wifi_password", nil);
    _promptLabel.text = NSLocalizedString(@"mcs_wifi_network_prompt", nil);
    self.app.is_vimtag ? nil : (_promptLabel.textColor = self.configuration.labelTextColor);

    [_showPasswordBtn setImage:[UIImage imageNamed:@"vt_eye_gray.png"] forState:UIControlStateNormal];
    _showPasswordBtn.selected = NO;
    if (self.app.is_luxcam) {
        [_wifiInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        [_passwordInputImageView setImage:[[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
        
        [_connectButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
        [_wifiImage setImage:[UIImage imageNamed:@"wifi_icon.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_red_on.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_connectButton setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"vt_eye.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_ebitcam)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_connectButton setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
        [_wifiImage setImage:[UIImage imageNamed:@"icon_wifi.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_green_on.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_mipc)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_connectButton setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
        [_wifiImage setImage:[UIImage imageNamed:@"icon_wifi.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"mi_eye.png"] forState:UIControlStateSelected];
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_connectButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        [_wifiImage setImage:[UIImage imageNamed:@"icon_wifi.png"]];
        [_keyImage setImage:[UIImage imageNamed:@"icon_password.png"]];
        [_showPasswordBtn setImage:[UIImage imageNamed:@"eye_green_on.png"] forState:UIControlStateSelected];
    }
    
    [self.navigationItem.backBarButtonItem setTitle:NSLocalizedString(@"mcs_back", nil)];
}

#pragma mark - viewcycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
//    [_activityIndicatorView startAnimating];
    // Do any additional setup after loading the view.

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MNInfoPromptView hideAll:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action
- (IBAction)editingDidEnd:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)showPassword:(id)sender
{
    _showPasswordBtn.selected = !_showPasswordBtn.selected;
    _wifiPasswordTextField.secureTextEntry = !_showPasswordBtn.selected;
}

- (IBAction)connect:(id)sender {
#if TARGET_IPHONE_SIMULATOR
    if (0)
#else
    if ([self get_current_SSID] == nil)
#endif
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_wifi_invalid", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(delayHidden) userInfo:nil repeats:NO];
    }
//    else if (!_wifiPasswordTextField.text || (_wifiPasswordTextField.text.length) == 0)
//    {
//        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_blank_password",nil) style:MNInfoPromptViewStyleError isModal:NO];
//    }
    else
    {
        [self performSegueWithIdentifier:@"MNPreparationsViewController" sender:nil];
    }
}

- (IBAction)back:(id)sender {

        [self.navigationController popViewControllerAnimated:YES];
    
 }

- (IBAction)close:(id)sender {
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

#pragma mark - delayHidden
- (void)delayHidden
{

}

#pragma mark - getSSID
- (NSString *)get_current_SSID
{
    NSString *wifiName = nil;
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
        }
    }
    NSLog(@"wifiName:%@", wifiName);
    
    return wifiName;
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

#pragma mark -PrepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    MNPreparationsViewController *preparationsViewController = segue.destinationViewController;
    preparationsViewController.deviceID = _deviceID;
    preparationsViewController.devicePassword = _devicePassword;
    preparationsViewController.wifiNameTextField = _wifiNameTextField;
    preparationsViewController.wifiPasswordTextField = _wifiPasswordTextField;
    preparationsViewController.is_loginModify = _is_loginModify;
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
