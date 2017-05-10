//
//  MNTransitionViewController.m
//  mipci
//
//  Created by weken on 15/6/6.
//
//

#import "MNTransitionViewController.h"
#import "MNProgressHUD.h"
#import "mipc_agent.h"
#import "MIPCUtils.h"
#import "AppDelegate.h"
#import "MNDeviceTabBarController.h"
#import "MNGuideNavigationController.h"
#import "MNDeviceOfflineViewController.h"
#import "MNDeviceGuideViewController.h"
#import "MNRootNavigationController.h"
#import "MNAddDeviceViewController.h"
#import "MNDevicePlayViewController.h"

#define DEVICEOFFLINE 100

@interface MNTransitionViewController()
{
    unsigned char                       _encrypt_pwd[16];
    long                                _encrypt_pwd_len;
}

@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (assign, nonatomic) BOOL isNotAdd;
@property (assign, nonatomic) BOOL isLoginAgain;
@property (strong, nonatomic) NSString *retResult;
@end

@implementation MNTransitionViewController

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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _isViewAppearing = YES;
    if (_isNotAdd || _isDevicesRefresh) {
        mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
        ctx.target = self;
        ctx.on_event = @selector(devs_refresh_done:);
        
        //获得设备列表刷新
        [self.agent devs_refresh:ctx];
//         [self performSegueWithIdentifier:@"MNDeviceTabBarController" sender:nil];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _isViewAppearing = YES;
    
    NSString *server = nil;
    NSString *user = self.app.user;
    NSString *password = self.app.password;
    
    [mipc_agent passwd_encrypt:password encrypt_pwd:_encrypt_pwd];
    
    struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
    
    if(conf)
    {
        conf_new        = *conf;
    }
    
    conf_new.server.data = (char*)(server?server.UTF8String:NULL);
    conf_new.server.len = (uint32_t)(server?server.length:0);
    
    if (self.app.keepLogin)
    {
        conf_new.user.data = (char*)(user?user.UTF8String:NULL);
        conf_new.user.len = (uint32_t)(user?user.length:0);
        conf_new.password_md5.data = (char*)_encrypt_pwd;
        conf_new.password_md5.len = 16;
    }
//    else
//    {
//        conf_new.password_md5.data = NULL;
//        conf_new.password_md5.len = 0;
//    }
    
    MIPC_ConfigSave(&conf_new);
    
    mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
    ctx.srv = nil;
    ctx.user = user;
    ctx.passwd = _encrypt_pwd;
    ctx.target = self;
    ctx.on_event = @selector(sign_in_done:);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults objectForKey:@"mipci_token"];
    
    if(token && token.length)
    {
        ctx.token = token;
    }
    
    [self.agent sign_in:ctx];
    [self.progressHUD show:YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(jumpToBackApplication:)
//                                                 name:@"ApplicationWillOpenURL"
//                                               object:nil];

}

//- (void)jumpToBackApplication:(NSNotification*)notification
//{
//
//    mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init] ;
//    ctx.target = self;
//    ctx.on_event = @selector(sign_out_done:);
//    
//    [self.agent sign_out:ctx];
//    
//    NSString *url = self.app.fromTarget;
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//}

//#pragma mark - sign_out_done
//
//-(void)sign_out_done:(mcall_ret_sign_out*)ret
//{
//    NSLog(@"----->logout");
//}

#pragma mark - sign_in_done
- (void)sign_in_done:(mcall_ret_sign_in*)ret
{
    if (!_isViewAppearing)
    {
        return;
    }
    self.retResult = ret.result;
    if(nil == ret.result)
    {
        //jump to video play view
        //
        if (!self.app.isLoginByID && ([self.app.serialNumber isEqualToString:@"(null)"] || [self.app.serialNumber isEqualToString:@""] || !self.app.serialNumber))
        {
            MNRootNavigationController *rootNavigationController = [self.app.mainStoryboard instantiateViewControllerWithIdentifier:@"MNRootNavigationController"];
            [self presentViewController:rootNavigationController animated:YES completion:nil];
        }
        else
        {
            mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
            ctx.target = self;
            ctx.on_event = @selector(devs_refresh_done:);
            
            //get devcieList refresh
            [self.agent devs_refresh:ctx];
        }
      
    }
    else
    {
        if([ret.result isEqualToString:@"ret.dev.offline"])
        {
            if (self.app.serialNumber && self.app.serialNumber.length)
            {
                NSString  *message = [NSString stringWithFormat:@"%@ %@ %@.", NSLocalizedString(@"mcs_device_offline",nil), NSLocalizedString(@"mcs_will_back",nil), self.app.fromTarget];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)
                                                                    message:message
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil)
                                                          otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                mcall_ctx_cap_get *ctx = [[mcall_ctx_cap_get alloc] init];
                ctx.sn = self.app.user;
                ctx.filter = nil;
                ctx.target = self;
                ctx.on_event = @selector(cap_get_done:);
                [self.agent cap_get:ctx];
            }
         
        }
        else if([ret.result isEqualToString:@"ret.user.unknown"])
        {
            [self.progressHUD hide:YES];
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
            [self.progressHUD hide:YES];
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
            [self.progressHUD hide:YES];
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


- (void)devs_refresh_done:(mcall_ret_devs_refresh*)ret
{

    if (!_isViewAppearing)
    {
        [self.progressHUD hide:YES];
        return;
    }
    self.retResult = ret.result;
    if (nil == ret.result)
    {
        [self.progressHUD hide:YES];
        if (self.app.isLoginByID) {
            //jump to
            if ([self.app.toTarget isEqualToString:@"vimtag"]) {
                [self performSegueWithIdentifier:@"MNDevicePlayViewController" sender:nil];
            }
            else
            {
                [self performSegueWithIdentifier:@"MNDeviceTabBarController" sender:nil];
            }
        }
        else
        {
            m_dev *dev = [self.agent.devs get_dev_by_sn:self.app.serialNumber];
            if (!dev)
            {
                NSString  *message =  [NSString stringWithFormat:@"%@:%@,%@ ?", NSLocalizedString(@"mcs_account_no_contain",nil), self.app.serialNumber, NSLocalizedString(@"mcs_is_add", nil)];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil) message:message delegate:self cancelButtonTitle:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"mcs_back", nil), self.app.fromTarget] otherButtonTitles:NSLocalizedString(@"mcs_add", nil), nil];
                alertView.tag = DEVICEOFFLINE;
                [alertView show];
            }
            else
            {
                if ([dev.status isEqualToString:@"Online"] ) {
                    //jump to
                    if ([self.app.toTarget isEqualToString:@"vimtag"]) {
                        [self performSegueWithIdentifier:@"MNDevicePlayViewController" sender:nil];
                    }
                    else
                    {
                        [self performSegueWithIdentifier:@"MNDeviceTabBarController" sender:nil];
                    }
                }
                else
                {
                   NSString  *message = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"mcs_device_offline",nil), NSLocalizedString(@"mcs_will_back",nil), self.app.fromTarget];
                  
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)
                                                                        message:message
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil)
                                                              otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }

        }
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
            
            [self.agent sign_in:ctx];
            _isLoginAgain = YES;
        }
        else
        {
            [self.progressHUD hide:YES];
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

- (void)cap_get_done:(mcall_ret_cap_get *)ret
{
    if (nil == ret.result) {
        if (ret.wfc == 1 || ret.qrc == 1 || ret.snc == 1) {
            UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
            MNDeviceOfflineViewController *deviceOfflineViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceOfflineViewController"];
            MNGuideNavigationController *offlineNavigationController = [[MNGuideNavigationController alloc] initWithRootViewController:deviceOfflineViewController];
            deviceOfflineViewController.deviceID = self.app.user;
            deviceOfflineViewController.devicePassword = self.app.password;

            deviceOfflineViewController.wfc = ret.wfc;
            deviceOfflineViewController.qrc = ret.qrc;
            deviceOfflineViewController.snc = ret.snc;
            deviceOfflineViewController.sncf = ret.sncf;
            deviceOfflineViewController.wfcnr = ret.wfcnr;
            [self presentViewController:offlineNavigationController animated:YES completion:nil];
        }
        else {
            UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
            MNDeviceGuideViewController *deviceGuideViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceGuideViewController"];
            MNGuideNavigationController *guideNavigationController = [[MNGuideNavigationController alloc] initWithRootViewController:deviceGuideViewController];
            deviceGuideViewController.deviceID = self.app.user;

            [self presentViewController:guideNavigationController animated:YES completion:nil];
        }
    }
}
#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNDeviceTabBarController"]) {
        MNDeviceTabBarController *deviceTabBarViewController = segue.destinationViewController;
        deviceTabBarViewController.deviceID = self.app.isLoginByID ? self.app.user : self.app.serialNumber;
        deviceTabBarViewController.isLoginByID = self.app.isLoginByID;
    } else if ([segue.identifier isEqualToString:@"MNDevicePlayViewController"])
    {
        MNDevicePlayViewController *devicePlayViewController = segue.destinationViewController;
        devicePlayViewController.deviceID = self.app.isLoginByID ? self.app.user : self.app.serialNumber;
//        devicePlayViewController.isLoginByID = self.app.isLoginByID;
    }
}

#pragma mark -
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
     NSString *url = [self.app.fromTarget stringByAppendingFormat:@"://%@", self.retResult];
    if (alertView.tag == DEVICEOFFLINE)
    {
        if (buttonIndex == 0 && url)
        {
            mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init] ;
            ctx.target = self;
            ctx.on_event = nil;
            
            [self.agent sign_out:ctx];
            self.app.is_jump = NO;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        else
        {
            _isNotAdd = YES;
            UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
            MNAddDeviceViewController *addDeviceViewcontroller = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNAddDeviceViewController"];
            addDeviceViewcontroller.deviceID = self.app.serialNumber;
            MNGuideNavigationController *addDeviceNavigationController = [[MNGuideNavigationController alloc] initWithRootViewController:addDeviceViewcontroller];
            [self presentViewController:addDeviceNavigationController animated:YES completion:nil];
        }
      
    }
    else if (url)
    {
        self.app.is_jump = NO;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//        [self exitApplication];

    }
 
}


@end
