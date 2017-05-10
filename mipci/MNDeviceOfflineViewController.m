
//
//  MNDeviceOfflineViewController.m
//  mipci
//
//  Created by mining on 15/5/12.
//
//

#import "MNDeviceOfflineViewController.h"
#import "MNDeviceGuideViewController.h"
#import "MNWIFIPasswordViewController.h"
#import "MNGuideNavigationController.h"
#import "MNConfiguration.h"
#import "AppDelegate.h"
#import "MNInfoPromptView.h"

#import "mwificode.h"
#import "mios_core_frameworks.h"
#import "mwificode_api.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface MNDeviceOfflineViewController ()

@property (weak, nonatomic) AppDelegate *app;
@end

@implementation MNDeviceOfflineViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MNInfoPromptView hideAll:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_Networking_mode", nil);
    _wifiConnectLabel.text = NSLocalizedString(@"mcs_smart_wifi_setup", nil);
    _ethConnectLabel.text = NSLocalizedString(@"mcs_ethernet_setup", nil);
    _wifiPromptLabel.text = NSLocalizedString(@"mcs_select_wifi_prompt", nil);
    _ethPromptLabel.text = NSLocalizedString(@"mcs_select_ethernet_prompt", nil);
    _deviceOfflineLab.text = NSLocalizedString(@"mcs_prompt_select_device_connection", nil);
    
    _ethPromptLabel.hidden = self.app.is_maxCAM ? YES : NO;

    MNConfiguration *configuration = [MNConfiguration shared_configuration];
    _wifiConnectLabel.textColor = configuration.switchTintColor;
    _ethConnectLabel.textColor = configuration.switchTintColor;
    _deviceOfflineLab.textColor = configuration.switchTintColor;
    _lineView.backgroundColor = configuration.color;

    if (self.app.is_luxcam) {
        [_wifiButton setImage:[UIImage imageNamed:@"circle_red_wifi.png"] forState:UIControlStateNormal];
        [_ethernetButton setImage:[UIImage imageNamed:@"circle_red_eth.png"] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];

    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
    }
    else if (self.app.is_ebitcam)
    {
        [_wifiButton setImage:[UIImage imageNamed:@"circle_green_wifi.png"] forState:UIControlStateNormal];
        [_ethernetButton setImage:[UIImage imageNamed:@"circle_green_eth.png"] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        _wifiPromptLabel.textColor = configuration.labelTextColor;
        _ethPromptLabel.textColor = configuration.labelTextColor;
        _wifiConnectLabel.textColor = configuration.labelTextColor;
        _ethConnectLabel.textColor = configuration.labelTextColor;
        _deviceOfflineLab.textColor = configuration.labelTextColor;
    }
    else if (self.app.is_mipc)
    {
        [_wifiButton setImage:[UIImage imageNamed:@"mi_circle_blue_wifi.png"] forState:UIControlStateNormal];
        [_ethernetButton setImage:[UIImage imageNamed:@"mi_circle_blue_eth.png"] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        _wifiPromptLabel.textColor = configuration.labelTextColor;
        _ethPromptLabel.textColor = configuration.labelTextColor;
        _wifiConnectLabel.textColor = configuration.labelTextColor;
        _ethConnectLabel.textColor = configuration.labelTextColor;
        _deviceOfflineLab.textColor = configuration.labelTextColor;
    }
    else
    {
        [_wifiButton setImage:[UIImage imageNamed:@"circle_green_wifi.png"] forState:UIControlStateNormal];
        [_ethernetButton setImage:[UIImage imageNamed:@"circle_green_eth.png"] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        _wifiPromptLabel.textColor = configuration.labelTextColor;
        _ethPromptLabel.textColor = configuration.labelTextColor;
        _wifiConnectLabel.textColor = configuration.labelTextColor;
        _ethConnectLabel.textColor = configuration.labelTextColor;
        _deviceOfflineLab.textColor = configuration.labelTextColor;
    }
    
    if (self.view.frame.size.height <=480) {
        _deviceOfflineLab.font = [UIFont systemFontOfSize:13];
        _ethConnectLabel.font = [UIFont systemFontOfSize:13];
        _wifiConnectLabel.font = [UIFont systemFontOfSize:13];
    }
    else if (self.view.frame.size.height == 568) {
        self.devOffLabConstrains.constant = 10;
        
    }
    else if (self.view.frame.size.height == 667){
        self.devOffLabConstrains.constant = 20;
    }
    else if(self.view.frame.size.height >= 736){
        self.devOffLabConstrains.constant = 35;
    }
}
 
- (IBAction)setWifi:(id)sender
{
#if TARGET_IPHONE_SIMULATOR
    if (0)
#else
    if ([self get_current_SSID] == nil)
#endif
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_wifi_invalid", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
    else
    {
        [self performSegueWithIdentifier:@"MNWIFIPasswordViewController" sender:nil];
    }
}

- (IBAction)setEtherner:(id)sender
{
 
    [self performSegueWithIdentifier:@"MNDeviceGuideViewController" sender:nil];
}

- (IBAction)back:(id)sender {
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
    else if (self.is_loginModify)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNDeviceGuideViewController"]){
        MNDeviceGuideViewController *deviceGuideViewController = segue.destinationViewController;
        deviceGuideViewController.deviceID = _deviceID;
        deviceGuideViewController.password = _devicePassword;
        deviceGuideViewController.wfc = _wfc;
        deviceGuideViewController.qrc = _qrc;
        deviceGuideViewController.snc = _snc;
        deviceGuideViewController.is_loginModify = _is_loginModify;
    }else if ([segue.identifier isEqualToString:@"MNWIFIPasswordViewController"]){
        MNWIFIPasswordViewController *wifiPasswordViewController = segue.destinationViewController;
        wifiPasswordViewController.deviceID = _deviceID;
        wifiPasswordViewController.devicePassword = _devicePassword;
        wifiPasswordViewController.is_loginModify = _is_loginModify;
    }
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

#pragma mark - UIAlertViewdelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *url = [self.app.fromTarget stringByAppendingString:@"://ret.dev.offline"];
    if (buttonIndex == 1 && url) {
        self.app.is_jump = NO;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return
//    UIInterfaceOrientationMaskAllButUpsideDown;
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
