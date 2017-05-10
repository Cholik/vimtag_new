//
//  MNDeviceGuideViewController.m
//  mipci
//
//  Created by weken on 15/3/14.
//
//

#import "MNDeviceGuideViewController.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNLoginViewController.h"
#import "MNAddDeviceViewController.h"
#import "MNConfiguration.h"
#import "MNDeviceTabBarController.h"

#define PASSWORD_FORCHECK @"lk9ds2*%#%dq"

@interface MNDeviceGuideViewController ()
{
    unsigned char               _encrypt_pwd[16];
    long                        _encrypt_pwd_len;
}
@property (strong, nonatomic) mipc_agent *agent;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (assign, nonatomic) BOOL isLoginAgain;


@end

@implementation MNDeviceGuideViewController


-(AppDelegate *)app
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

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_ethernet_configuration", nil);
    
    NSString *name = [NSString stringWithFormat:@"%@ : ", NSLocalizedString(@"mcs_device_id", nil)];
    _deviceIDHintLabel.text = [name stringByAppendingString:_deviceID];
    _deviceIDHintLabel.textColor = self.configuration.labelTextColor;
    _waitDeviceLabel.text = NSLocalizedString(@"mcs_state_wait_device_online", nil);
    _firstStepHintLabel.text = [NSString stringWithFormat:@"●%@",NSLocalizedString(@"mcs_first_step_ethernet_connect",nil)];
    _secondStepHintLabel.text = [NSString stringWithFormat:@"●%@",NSLocalizedString(@"mcs_second_step_ethernet_connect",nil)];
    _assemblyLabel.text = self.app.is_vimtag ? NSLocalizedString(@"mcs_device_assembly", nil) : NSLocalizedString(@"mcs_device_assembly_mipc", nil);

    _promptLabel.text = NSLocalizedString(@"mcs_prompt_check_device_connection", nil);
    _firstStepHintLabel.textColor = self.configuration.labelTextColor;
    _secondStepHintLabel.textColor = self.configuration.labelTextColor;
    _promptLabel.textColor = self.configuration.labelTextColor;
    _activityIndicatorView.color = self.configuration.labelTextColor;
    _waitDeviceLabel.textColor = self.configuration.labelTextColor;
    _assemblyLabel.textColor = self.configuration.color;
    _lineView.backgroundColor = self.configuration.color;
    
    if (self.app.is_luxcam) {
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
    }
    else if (self.app.is_ebitcam)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
    }
    else if (self.app.is_mipc)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
    [_activityIndicatorView startAnimating];
    [self checkDeviceLink];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkDeviceLink
{
    unsigned char encrypt_pwd[16] = {0};
    [mipc_agent passwd_encrypt:PASSWORD_FORCHECK encrypt_pwd:encrypt_pwd];
    if (self.app.isLoginByID) {
        mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
        ctx.sn = _deviceID;
        ctx.user = _deviceID;
        ctx.passwd = encrypt_pwd;
        ctx.target = self;
        ctx.on_event = @selector(sign_in_done:);
        
        [_activityIndicatorView startAnimating];
        [self.agent sign_in:ctx];

    }
    else
    {
        mcall_ctx_dev_add *ctx = [[mcall_ctx_dev_add alloc] init];
        ctx.sn = _deviceID;
        ctx.passwd = encrypt_pwd;
        ctx.target = self;
        ctx.on_event = @selector(dev_add_done:);
        
        [_activityIndicatorView startAnimating];
        [self.agent dev_add:ctx];

    }
}

#pragma mark - dev_add_done
- (void)dev_add_done:(mcall_ret_dev_add*)ret
{
    if (!_isViewAppearing) {
        return;
    }
    
    if ([ret.result isEqualToString:@"ret.pwd.invalid"])
    {
        _waitDeviceLabel.text = NSLocalizedString(@"mcs_online", nil);
        [_activityIndicatorView stopAnimating];
      
//        if (self.app.is_luxcam) {
//            [self back];
//        }
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[MNAddDeviceViewController  class]]) {
                [((MNAddDeviceViewController *)controller).addDeviceButton setTitle:NSLocalizedString(@"mcs_action_add", nil) forState:UIControlStateNormal];
                [(MNAddDeviceViewController *)controller updateConstraint];
                ((MNAddDeviceViewController *)controller).is_add = YES;
                [self.navigationController popToViewController:controller animated:YES];
            }
            
        }
    }
    else
    {
        [self performSelector:@selector(checkDeviceLink) withObject:nil afterDelay:5];
    }
}

- (void)sign_in_done:(mcall_ret_sign_in*)ret
{
    if (!_isViewAppearing) {
        return;
    }
    
    NSLog(@"sign_in_done=======================================sign_in_done:%@", ret.result);
//    if ([ret.result isEqualToString:@"ret.dev.offline"] == NO)
    if ([ret.result isEqualToString:@"ret.pwd.invalid"])
    {
        
         _waitDeviceLabel.text = NSLocalizedString(@"mcs_online", nil);
        [_activityIndicatorView stopAnimating];
//        if (self.app.is_luxcam) {
//            [self back];
//        }
        //is jump, auto login
        if (self.app.is_jump && self.app.isLoginByID) {
            [mipc_agent passwd_encrypt:self.app.password encrypt_pwd:_encrypt_pwd];

            mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc]init];
            ctx.srv = nil;
            ctx.user = self.app.user;
            ctx.passwd = _encrypt_pwd;
            ctx.target = self;
            ctx.on_event = @selector(auto_sign_in_done:);
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSString *token = [user objectForKey:@"mipci_token"];
            
            if(token && token.length)
            {
                ctx.token = token;
            }
            [self.agent sign_in:ctx];
        }
        else
        {
            if (self.is_loginModify) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[MNLoginViewController class]]) {
                        ((MNLoginViewController *)controller).lblStatus.hidden = NO;
                        ((MNLoginViewController *)controller).lblStatus.text = NSLocalizedString(@"mcs_state_device_online",nil);
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }
            }
        }
    }
    else
    {
        [self performSelector:@selector(checkDeviceLink) withObject:nil afterDelay:5];
    }
}
#pragma mark - auto_sign_in_done
- (void)auto_sign_in_done:(mcall_ret_sign_in*)ret
{
    if (ret.result == nil) {
        mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
        ctx.target = self;
        ctx.on_event = @selector(devs_refresh_done:);
        
        [self.agent devs_refresh:ctx];
    }
}

#pragma mark devs_refresh_done
- (void)devs_refresh_done:(mcall_ret_devs_refresh*)ret
{
    if (nil == ret.result)
    {
        if (self.app.isLoginByID) {
            //jump to
            MNDeviceTabBarController *deviceTabBarController = [self.app.mainStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceTabBarController"];
            deviceTabBarController.deviceID  = self.app.isLoginByID ? self.app.user : self.app.serialNumber;
            deviceTabBarController.isLoginByID = self.app.isLoginByID;
            [self presentViewController:deviceTabBarController animated:YES completion:nil];
        }
    }
    else if([ret.result isEqualToString:@"ret.user.unknown"])
    {
        NSString  *message = [NSString stringWithFormat:@"%@, %@ %@.", NSLocalizedString(@"mcs_invalid_user",nil), NSLocalizedString(@"mcs_will_back",nil), self.app.fromTarget];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if([ret.result isEqualToString:@"ret.pwd.invalid"])
    {
        NSString  *message = [NSString stringWithFormat:@"%@, %@ %@.", NSLocalizedString(@"mcs_invalid_password",nil), NSLocalizedString(@"mcs_will_back",nil), self.app.fromTarget];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        if (!_isLoginAgain)
        {
            mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
            ctx.srv = nil;
            ctx.user = self.app.user;
            ctx.passwd = _encrypt_pwd;
            ctx.target = self;
            ctx.on_event = @selector(sign_in_done:);

            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *token = [userDefaults objectForKey:@"mipci_token"];

            if(token && token.length)
            {
                ctx.token = token;
            }
            _isLoginAgain = YES;
            [self.agent sign_in:ctx];
        }
        else
        {
            NSString  *message = [NSString stringWithFormat:@"%@ %@ %@.", NSLocalizedString(@"mcs_login_faided",nil), NSLocalizedString(@"mcs_will_back",nil), self.app.fromTarget];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil)
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

#pragma mark - Action
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

- (IBAction)back:(id)sender {
    if (self.app.is_jump && !self.wfc && !self.qrc && !self.snc && self.app.isLoginByID)
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
#pragma mark - Action
//- (IBAction)back
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Aoturotate
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
