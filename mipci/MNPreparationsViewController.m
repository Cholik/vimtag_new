//
//  MNPreparationsViewController.m
//  mipci
//
//  Created by mining on 15/6/16.
//
//

#import "MNPreparationsViewController.h"
#import "MNWIFIConnectViewController.h"
#import "MNConfiguration.h"
#import "AppDelegate.h"
#import "MNDeviceOfflineViewController.h"


@interface MNPreparationsViewController ()

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSData *gifData;
@property (assign, nonatomic) long      wfcnr;

@end

@implementation MNPreparationsViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_wifi_intelligent_configuration", nil);

    for (UIViewController *viewControllr in self.navigationController.viewControllers)
    {
        if ([viewControllr isMemberOfClass:[MNDeviceOfflineViewController class]])
        {
            self.wfcnr = ((MNDeviceOfflineViewController *)viewControllr).wfcnr;
        }
    }
    
    MNConfiguration *configuration = [MNConfiguration shared_configuration];
    
    _promptLabel.text = self.wfcnr ? NSLocalizedString(@"mcs_wifi_config_restore", nil) :NSLocalizedString(@"mcs_enter_config_mode_prompt", nil);
    [_nextButton setTitle:(self.wfcnr ? NSLocalizedString(@"mcs_voice_remind_heard", nil) : NSLocalizedString(@"mcs_action_next", nil)) forState:UIControlStateNormal];
    _centerView.backgroundColor = configuration.color;

    self.gifWebView.userInteractionEnabled = NO;
    self.gifWebView.scalesPageToFit = YES;
    self.gifWebView.backgroundColor = [UIColor clearColor];
    self.gifWebView.opaque = 0;
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"gif" ofType:nil];
    if (self.app.is_luxcam) {
        [_nextButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
        _promptLabel.textColor = configuration.labelTextColor;
        NSString *gifDataPath = self.wfcnr ? [NSString stringWithFormat:@"%@/mipc_wifi_conf_prepare.gif",gifPath] : [NSString stringWithFormat:@"%@/mipc_wifi_conf_prepare_old.gif",gifPath];
        self.gifData = [NSData dataWithContentsOfFile:gifDataPath];
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
        NSString *gifDataPath = self.wfcnr ? [NSString stringWithFormat:@"%@/wifi_conf_prepare.gif",gifPath] : [NSString stringWithFormat:@"%@/wifi_conf_prepare_old.gif",gifPath];
        self.gifData = [NSData dataWithContentsOfFile:gifDataPath];
    }
    else if (self.app.is_ebitcam)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
        _promptLabel.textColor = configuration.labelTextColor;
        NSString *gifDataPath = self.wfcnr ? [NSString stringWithFormat:@"%@/mipc_wifi_conf_prepare.gif",gifPath] : [NSString stringWithFormat:@"%@/mipc_wifi_conf_prepare_old.gif",gifPath];
        self.gifData = [NSData dataWithContentsOfFile:gifDataPath];
    }
    else if (self.app.is_mipc)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
        _promptLabel.textColor = configuration.labelTextColor;
        NSString *gifDataPath = self.wfcnr ? [NSString stringWithFormat:@"%@/mipc_wifi_conf_prepare.gif",gifPath] : [NSString stringWithFormat:@"%@/mipc_wifi_conf_prepare_old.gif",gifPath];
        self.gifData = [NSData dataWithContentsOfFile:gifDataPath];
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        _promptLabel.textColor = configuration.labelTextColor;
        NSString *gifDataPath = self.wfcnr ? [NSString stringWithFormat:@"%@/mipc_wifi_conf_prepare.gif",gifPath] : [NSString stringWithFormat:@"%@/mipc_wifi_conf_prepare_old.gif",gifPath];
        self.gifData = [NSData dataWithContentsOfFile:gifDataPath];
    }
    
    [self.gifWebView loadData:self.gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)bcak:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)next:(id)sender
{
    [self performSegueWithIdentifier:@"MNWIFIConnectViewController" sender:nil];
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

#pragma mark  - prepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqual:@"MNWIFIConnectViewController"]) {
        MNWIFIConnectViewController *wifiConnectViewController  = segue.destinationViewController;
        wifiConnectViewController.deviceID = _deviceID;
        wifiConnectViewController.devicePassword = _devicePassword;
        wifiConnectViewController.wifiNameTextField = _wifiNameTextField;
        wifiConnectViewController.wifiPasswordTextField = _wifiPasswordTextField;
        wifiConnectViewController.is_loginModify = _is_loginModify;
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
