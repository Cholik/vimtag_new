//
//  AppDelegate.m
//  mipci
//
//  Created by MagicStudio on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MIPCUtils.h"
#import "MNTransitionViewController.h"
#import "CoreDataUtils.h"
#import "MNUncaughtExceptionHandler.h"
#import "MNToastView.h"
#import "MNRootNavigationController.h"
#import "MNUserBehaviours.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "MNMyOrderViewController.h"
#import "MNProductInformationViewController.h"

#define WX_APPID @"wx21bc21761439ae70"

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WXApi registerApp:WX_APPID];
   
#if !TARGET_IPHONE_SIMULATOR
    InstallUncaughtExceptionHandler();
#endif
 
    _cloudAgent = [[mipc_agent alloc] init];
    _localAgent = [[mipc_agent alloc] init];
    _cloudAgent.devs_need_cache = YES;
    _cloudAgent.msgs_need_cache = YES;
    _localAgent.devs_need_cache = NO;
    _localAgent.msgs_need_cache = YES;
    _agent = _cloudAgent;
    //Read default config msg
    _configuration = [MNConfiguration shared_configuration];
    _developerOption = [MNDeveloperOption shared_developerOption];
    _isOpenDeveloperOption = NO;
    
    if (self.developerOption.environmentSwitch) {
        NSString *networkRequestDerectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"NetworkRequest"];
        BOOL isDirectory;
        BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:networkRequestDerectory isDirectory:&isDirectory];
        if (!isFileExist || !isDirectory)
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:networkRequestDerectory withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"download_url:timeout:%@", [error localizedDescription]);
            }
        }
        NSString *printfPath = [NSString stringWithFormat:@"%@/Log", networkRequestDerectory];
        setenv("printf_ex", printfPath.UTF8String, 1);
    }
    if (self.developerOption.printfVaule.length && self.developerOption.printfLevel > 0)
    {
        NSString *value = [self.developerOption.printfVaule copy];
        NSString *level = [NSString stringWithFormat:@"printf_ex_level_%ld", self.developerOption.printfLevel];
        setenv(level.UTF8String, value.UTF8String, 1);
    }
    else if (self.developerOption.printfLevel > 0)
    {
        setenv("printf_ex_level", "2", 1);
    }
    
    NSDictionary *dictionary = MIPC_GetApplicationConfigInfo();
  
    self.is_reg_by_email = [[dictionary objectForKey:@"is_reg_by_email"] boolValue];
    self.is_luxcam = _configuration.is_luxcam;
    self.is_vimtag = _configuration.is_vimtag;
    self.is_ebitcam = _configuration.is_ebitcam;
    self.is_mipc = _configuration.is_mipc;
    self.is_sereneViewer = _configuration.is_SereneViewer;
    self.is_eyedot = _configuration.is_eyedot;
    self.is_itelcamera = _configuration.is_itelcamera;
    self.is_ehawk = _configuration.is_ehawk;
    self.is_avuecam = _configuration.is_avuecam;
    self.is_kean = _configuration.is_kean;
    self.is_prolab = _configuration.is_prolab;
    self.is_eyeview = _configuration.is_eyeview;
    self.is_maxCAM = _configuration.is_maxCAM;
    self.is_bosma = _configuration.is_bosma;
    
    self.is_InfoPrompt = (self.is_vimtag || self.is_ebitcam || self.is_mipc) ? YES : NO;
    
    self.alert_independent = _configuration.alert_independent;
    self.color = _configuration.color;
    self.button_color = _configuration.buttonColor;
    self.button_title_color = _configuration.buttonTitleColor;
    self.startSaveLog = NO;

    _is_firstLaunch = (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) ? YES : NO;
    _is_firstSceneLauch = (![[NSUserDefaults standardUserDefaults] boolForKey:@"everSceneLaunched"]) ? YES : NO;
    _is_firstScheduleLauch = (![[NSUserDefaults standardUserDefaults] boolForKey:@"everScheduleLaunched"]) ? YES : NO;
    
    if (_is_luxcam)
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"LuxcamStoryboard_iPhone" bundle:nil];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
        
        self.window.rootViewController = self.mainStoryboard.instantiateInitialViewController;
    }
    else if (_is_vimtag)
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil];
        self.window.rootViewController = self.mainStoryboard.instantiateInitialViewController;
    }
    else if (_is_ebitcam)
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"EbitcamStoryboard_iPhone" bundle:nil];
        self.window.rootViewController = self.mainStoryboard.instantiateInitialViewController;
    }
    else if (_is_mipc)
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"MIPCStoryboard_iPhone" bundle:nil];
        self.window.rootViewController = self.mainStoryboard.instantiateInitialViewController;
    }
    else if (_is_ehawk)
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *viewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"MNStartScreenViewController"];
        MNRootNavigationController *rootNavigationController = [[MNRootNavigationController alloc] initWithRootViewController:viewController];
        self.window.rootViewController = rootNavigationController;
    }
    else
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        self.window.rootViewController = self.mainStoryboard.instantiateInitialViewController;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        /*code for appearance*/
        if (_is_luxcam) {
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
        }
        else if (_is_vimtag)
        {
            [[UINavigationBar appearance] setBarTintColor:_configuration.navigationBarTintColor];
        }
        else if (_is_ebitcam)
        {
            [[UINavigationBar appearance] setBarTintColor:_configuration.navigationBarTintColor];
        }
        else if (_is_mipc)
        {
            [[UINavigationBar appearance] setBarTintColor:_configuration.navigationBarTintColor];
        }
        else
        {
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
        }
        [[UINavigationBar appearance] setTintColor:_configuration.navigationBarTitleColor];
        NSDictionary *textDictionary = [NSDictionary dictionaryWithObject:_configuration.navigationBarTitleColor forKey:UITextAttributeTextColor];
        [[UINavigationBar appearance] setTitleTextAttributes:textDictionary];
         
        [[UITabBar appearance] setTintColor:_configuration.tabBarTintColor];
        if (_is_ebitcam) {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        }
        /*code for appearance*/
    }
    else
    {
        [[UINavigationBar appearance] setTintColor:_configuration.switchTintColor];
        if (_is_vimtag) {
            [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
        }
    }
  
    //register remote notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0)
    {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSettings];
#endif
        }
        else
        {
            UIRemoteNotificationType remoteNotificationType = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:remoteNotificationType];
        }
        
    }
    else
    {
        UIRemoteNotificationType remoteNotificationType = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:remoteNotificationType];
        
    }
    
    //register Reachability notification
//    _reachCount = 0;
//    _hostReach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    _isNetWorkAvailable = YES;
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    _hostReach = [Reachability reachabilityForInternetConnection];
    [_hostReach startNotifier];
    [self reachabilityChanged:nil];

    
//    NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *filePath = [docPath stringByAppendingPathComponent:@"userBehaviours"];
    
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"firstLaunch"]) {
//        MNUserBehaviours *userbehaviours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        userbehaviours.last_time = [[NSDate date]timeIntervalSince1970];
//        [NSKeyedArchiver archiveRootObject:userbehaviours toFile:filePath];
//    
//    }
//    else{
//        MNUserBehaviours *userbehaviours = [[MNUserBehaviours alloc]init];
//        userbehaviours.start_time = [[NSDate date]timeIntervalSince1970];
//        userbehaviours.last_time = [[NSDate date]timeIntervalSince1970];
//        userbehaviours.login_succ_times = 0;
//        userbehaviours.login_fail_times = 0;
//        userbehaviours.devs_refresh_succ_times = 0;
//        userbehaviours.devs_refresh_fail_times = 0;
//        userbehaviours.dev_play_succ_times = 0;
//        userbehaviours.dev_play_fail_times = 0;
//        userbehaviours.dev_snaps_succ_times  = 0;
//        userbehaviours.dev_snaps_fail_times= 0 ;
//        userbehaviours.dev_replay_succ_times = 0;
//        userbehaviours.dev_replay_fail_tiems = 0;
//        userbehaviours.dev_add_succ_times = 0;
//        userbehaviours.dev_add_fail_times = 0;
//        userbehaviours.dev_add_wfc_succ_times = 0;
//        userbehaviours.dev_add_wfc_fail_times = 0;
//        userbehaviours.last_feedback_time = 0;
//        PlayToken *playToken = [[PlayToken alloc]init];
//        userbehaviours.playToken = playToken;
//        [NSKeyedArchiver archiveRootObject:userbehaviours toFile:filePath];
//        [[NSUserDefaults standardUserDefaults]setObject:@"firstLaunch" forKey:@"firstLaunch"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//    }

    if (self.is_vimtag)
    {
        struct mipci_conf *conf = MIPC_ConfigLoad();
        if (conf && conf->auto_login) {
            //Auto login up the ability
        } else {
            if (conf && conf->user.data)
            {
                //get experience account
                __weak typeof(self) weakSelf = self;
                
                NSString *userName = [NSString stringWithUTF8String:(const char*) conf->user.data];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf.agent mipcGetSrv:nil user:userName cert:nil name:nil pubk:nil];
                });
            }
            else
            {
                __weak typeof(self) weakSelf = self;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf.agent mipcGetSrv:nil user:nil cert:nil name:nil pubk:nil];
                });
            
            }
        }
    }
    
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"userinfo:%@",userInfo);

    NSDictionary *mining_info = [userInfo objectForKey:@"msg"];
    NSString     *dev_id = [mining_info objectForKey:@"sn"];
    NSNumber     *imsg_id = [mining_info objectForKey:@"id"];
    m_dev        *dev = [_agent.devs get_dev_by_sn:dev_id];
    if(dev && imsg_id)
    {
        if([imsg_id longValue]> dev.msg_id_max)
        {
            dev.msg_id_max = [imsg_id longValue];
        }
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"DidFailToRegisterForRemoteNotifications, Error:%@", error.localizedDescription);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"mipci_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //debug local notification
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:%@", token);
}

-(NSString *)directConnectedDevID
{
    if (nil == _directConnectedDevID) {
        _directConnectedDevID = MIPC_GetConnectedIPCDevID();
    }
    
    return _directConnectedDevID;
}

- (long)isLoginByID
{
    struct len_str  s_user = {(_agent && _agent.user)?_agent.user.length:0,
        (_agent && _agent.user)?(char*)_agent.user.UTF8String:(char*)NULL};
    
    BOOL isLogin = (_directConnectedDevID && _directConnectedDevID.length)
    || (_agent && _agent.srv_type && (0 == [_agent.srv_type caseInsensitiveCompare:@"ipc"]))
    || (s_user.len && (s_user.data[0] >= '0')&& (s_user.data[0] <= '9') && ([_agent.user rangeOfString:@"@"].location == NSNotFound));

    return isLogin;
}

- (long)isDevicesAccount:(NSString *)user
{
    struct len_str  s_user = { user ? user.length : 0,
        user ? (char*)user.UTF8String : (char*)NULL};
    
    BOOL isDevicesID = (s_user.len && (s_user.data[0] == '1') && (s_user.data[1] == 'j' || s_user.data[1] == 'J') && (s_user.data[2] == 'f' || s_user.data[2] == 'F') && (s_user.data[3] == 'i' || s_user.data[3] == 'I') && (s_user.data[4] == 'e' || s_user.data[4] == 'E'));
    
    return isDevicesID;
}

- (void)tryCatchException
{
    NSSetUncaughtExceptionHandler(&handleRootException);
}

void handleRootException(NSException* exception)
{
    NSString *name = exception.name;
    NSString *reason = exception.reason;
    NSArray *symbols = exception.callStackSymbols;
    NSMutableString *strSymbols = [[NSMutableString alloc] init];
    for(NSString* item in symbols)
    {
        [strSymbols appendString:item];
        [strSymbols appendString:@"\r\n"];
    }
    NSLog(@"%@\n%@\n%@",name,reason,strSymbols);
}

#pragma mark - reachabilityChanged
- (NetworkStatus)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    if (curReach == nil) {
        curReach = _hostReach;
    }
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
//    NSLog(@"NetworkStatus : %ld",(long)status);
//    if (status == NotReachable)
//    {
//        _isNetWorkAvailable = NO;
//    }
//    else
//    {
//        _isNetWorkAvailable = YES;
//    }
    
    switch (status) {
        case ReachableViaWiFi:
            
            [[NSUserDefaults standardUserDefaults]setObject:@"ReachableViaWiFi" forKey:@"ReachableNetworkStatus"];
             _isNetWorkAvailable = YES;
            break;
        case ReachableViaWWAN:
            [[NSUserDefaults standardUserDefaults]setObject:@"ReachableViaWWAN" forKey:@"ReachableNetworkStatus"];
             _isNetWorkAvailable = YES;
            break;
        case NotReachable:
            [[NSUserDefaults standardUserDefaults]setObject:@"NotReachable" forKey:@"ReachableNetworkStatus"];
            _isNetWorkAvailable = NO;
            break;
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults]synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkStatusChange" object:nil];

    return status;
}

#pragma mark - Utils
-(UIColor*)getColorFromString:(NSString *)string
{
    if ([string isEqualToString:@"red"]) {
        return [UIColor redColor];
    }
    else if([string isEqualToString:@"green"])
    {
        return [UIColor greenColor];
    }
    else if ([string isEqualToString:@"white"])
    {
        return [UIColor whiteColor];
    }
    else if ([string isEqualToString:@"black"])
    {
        return [UIColor blackColor];
    }
    
    return nil;
}

- (NSString *)getParmasFormUrl:(NSURL *)url byKey:(NSString *)key
{
    char *query= url.query?(char*)url.query.UTF8String:NULL;
    struct http_param *value, *params = NULL;
    struct len_str    line = {query?strlen(query):0, query};
    
    http_param_add_line(&params, &line, http_param_flag_type_data);
    struct len_str s_k = {key?strlen(key.UTF8String):0, (char*)key.UTF8String};
    
    NSString *word;
    if((value = http_param_get(params, &s_k)) && value->value.len)
    {
        word = [NSString stringWithUTF8String:value->value.data];
    }
    else
    {
        word = nil;
    }
    
    http_param_destroy(params);
    
    return word;
}


#pragma mark getCurrentRootViewController   
-(UIViewController *)getCurrentRootViewController
{
    UIViewController *result;
    // Try to find the root view controller programmically
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        
        
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    }
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
    {
        result = topWindow.rootViewController;
    }
    else
        NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
    
    return result;
}
#pragma mark - open url

// NOTE:ios9
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webView"] isEqualToString:@"myOrder"]) {
                MNMyOrderViewController *myOrderViewController = [MNMyOrderViewController shared_myOrderViewController];
                myOrderViewController.tabBarController.tabBar.hidden = YES;

                [myOrderViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.get_alipay_mark(\"%@\");", [resultDic objectForKey:@"resultStatus"]]];
            } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webView"] isEqualToString:@"product"]) {
                MNProductInformationViewController *productInformationViewController = [MNProductInformationViewController shared_productInformationViewController];
                productInformationViewController.tabBarController.tabBar.hidden = YES;
                productInformationViewController.customWebView.frame = CGRectMake(productInformationViewController.customWebView.frame.origin.x, productInformationViewController.customWebView.frame.origin.y, productInformationViewController.customWebView.frame.size.width, productInformationViewController.view.frame.size.height + 50);
                [WXApi handleOpenURL:url delegate:productInformationViewController];
                [productInformationViewController.customWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.get_alipay_mark(\"%@\");", [resultDic objectForKey:@"resultStatus"]]];
            }        }];
    } else if ([[url absoluteString] hasPrefix:@"wx21bc21761439ae70"]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webView"] isEqualToString:@"myOrder"]) {
            MNMyOrderViewController *myOrderViewController = [MNMyOrderViewController shared_myOrderViewController];
            myOrderViewController.tabBarController.tabBar.hidden = YES;

            [WXApi handleOpenURL:url delegate:myOrderViewController];
        } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webView"] isEqualToString:@"product"]) {
            MNProductInformationViewController *productInformationViewController = [MNProductInformationViewController shared_productInformationViewController];
            productInformationViewController.tabBarController.tabBar.hidden = YES;
            productInformationViewController.customWebView.frame = CGRectMake(productInformationViewController.customWebView.frame.origin.x, productInformationViewController.customWebView.frame.origin.y, productInformationViewController.customWebView.frame.size.width, productInformationViewController.view.frame.size.height + 50);
            [WXApi handleOpenURL:url delegate:productInformationViewController];
            
        }
   
    } else {
        
        NSString *method = [self getParmasFormUrl:url byKey:@"m"];
        NSString *user = [self getParmasFormUrl:url byKey:@"u"];
        NSString *password = [self getParmasFormUrl:url byKey:@"t"];
        
        self.urlMethod = method;
        
        if (method && user && password) {
            self.is_jump = YES;
            //logout
            mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init];
            ctx.target = self;
            [self.agent sign_out:ctx];
            
            [[self getCurrentRootViewController] dismissViewControllerAnimated:NO completion:nil];
            [[self getCurrentRootViewController].navigationController popToRootViewControllerAnimated:YES];
            if ([method isEqualToString:METHOD_PLAYVIDEOVIEW])
            {
                self.user = user;
                self.password = password;
                
                self.serialNumber = [self getParmasFormUrl:url byKey:@"serialnumber"];
                self.fromTarget = [self getParmasFormUrl:url byKey:@"fromTarget"];
                self.keepLogin = [[self getParmasFormUrl:url byKey:@"keepLogin"] boolValue];
                self.disableAll = [[self getParmasFormUrl:url byKey:@"disableAll"] boolValue];
                
                self.disableVoice = [[self getParmasFormUrl:url byKey:@"disableVoice"] boolValue];
                self.disableMicrophone = [[self getParmasFormUrl:url byKey:@"disableMicrophone"] boolValue];
                self.disableSnapshot = [[self getParmasFormUrl:url byKey:@"disableSnapshot"] boolValue];
                self.disableVideoRecord = [[self getParmasFormUrl:url byKey:@"disableVideoRecord"] boolValue];
                self.disableOtherSetting = [[self getParmasFormUrl:url byKey:@"disableOtherSetting"] boolValue];
                self.disableOtherSettingCam = [[self getParmasFormUrl:url byKey:@"disableOtherSettingCam"] boolValue];
                
                
                self.disableVideo = [[self getParmasFormUrl:url byKey:@"disableVideo"] boolValue];
                self.disableHistory = [[self getParmasFormUrl:url byKey:@"disableHistory"] boolValue];
                self.disableSettings = [[self getParmasFormUrl:url byKey:@"disableSettings"] boolValue];
                
                self.disableSettingsPassword = [[self getParmasFormUrl:url byKey:@"disableSettingsPassword"] boolValue];
                self.disableSettingsNetwork = [[self getParmasFormUrl:url byKey:@"disableSettingsNetwork"] boolValue];
                self.disableSettingsUpgrate = [[self getParmasFormUrl:url byKey:@"disableSettingsUpgrate"] boolValue];
                self.disableSettingsReboot = [[self getParmasFormUrl:url byKey:@"disableSettingsReboot"] boolValue];
                self.disableSettingsReset = [[self getParmasFormUrl:url byKey:@"disableSettingsReset"] boolValue];
                self.shoppingURL = [self getParmasFormUrl:url byKey:@"shoppingURL"];
                self.disableModifyUserSetting = [[self getParmasFormUrl:url byKey:@"disableModifyUserSetting"] boolValue];
                self.disableExit = [[self getParmasFormUrl:url byKey:@"disableExit"] boolValue];
                
                UIViewController *transitionViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"MNTransitionViewController"];
                
                [self.window setRootViewController:transitionViewController];
                
            }
        }
    }
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webView"] isEqualToString:@"myOrder"]) {
                MNMyOrderViewController *myOrderViewController = [MNMyOrderViewController shared_myOrderViewController];
                myOrderViewController.tabBarController.tabBar.hidden = YES;
                
                
                [myOrderViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.get_alipay_mark(\"%@\");", [resultDic objectForKey:@"resultStatus"]]];
            } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webView"] isEqualToString:@"product"]) {
                MNProductInformationViewController *productInformationViewController = [MNProductInformationViewController shared_productInformationViewController];
                [WXApi handleOpenURL:url delegate:productInformationViewController];
                productInformationViewController.tabBarController.tabBar.hidden = YES;
                 productInformationViewController.customWebView.frame = CGRectMake(productInformationViewController.customWebView.frame.origin.x, productInformationViewController.customWebView.frame.origin.y, productInformationViewController.customWebView.frame.size.width, productInformationViewController.view.frame.size.height + 50);
                [productInformationViewController.customWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.get_alipay_mark(\"%@\");", [resultDic objectForKey:@"resultStatus"]]];
            }
        }];
    } else if ([[url absoluteString] hasPrefix:@"wx21bc21761439ae70"]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webView"] isEqualToString:@"myOrder"]) {
            MNMyOrderViewController *myOrderViewController = [MNMyOrderViewController shared_myOrderViewController];
            myOrderViewController.tabBarController.tabBar.hidden = YES;
            [WXApi handleOpenURL:url delegate:myOrderViewController];
        } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webView"] isEqualToString:@"product"]) {
            MNProductInformationViewController *productInformationViewController = [MNProductInformationViewController shared_productInformationViewController];
            productInformationViewController.tabBarController.tabBar.hidden = YES;
            [WXApi handleOpenURL:url delegate:productInformationViewController];
        }
        
    } else {

        NSString *method = [self getParmasFormUrl:url byKey:@"m"];
        NSString *user = [self getParmasFormUrl:url byKey:@"u"];
        NSString *password = [self getParmasFormUrl:url byKey:@"t"];
        
        self.urlMethod = method;

        if (method && user && password) {
            self.is_jump = YES;
            //logout
            mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init];
            ctx.target = self;
            [self.agent sign_out:ctx];
            
            [[self getCurrentRootViewController] dismissViewControllerAnimated:NO completion:nil];
            [[self getCurrentRootViewController].navigationController popToRootViewControllerAnimated:YES];
            if ([method isEqualToString:METHOD_PLAYVIDEOVIEW])
            {
                self.user = user;
                self.password = password;
                
                self.serialNumber = [self getParmasFormUrl:url byKey:@"serialnumber"];
                self.fromTarget = [self getParmasFormUrl:url byKey:@"fromTarget"];
                self.keepLogin = [[self getParmasFormUrl:url byKey:@"keepLogin"] boolValue];
                self.disableAll = [[self getParmasFormUrl:url byKey:@"disableAll"] boolValue];
                
                self.disableVoice = [[self getParmasFormUrl:url byKey:@"disableVoice"] boolValue];
                self.disableMicrophone = [[self getParmasFormUrl:url byKey:@"disableMicrophone"] boolValue];
                self.disableSnapshot = [[self getParmasFormUrl:url byKey:@"disableSnapshot"] boolValue];
                self.disableVideoRecord = [[self getParmasFormUrl:url byKey:@"disableVideoRecord"] boolValue];
                self.disableOtherSetting = [[self getParmasFormUrl:url byKey:@"disableOtherSetting"] boolValue];
                self.disableOtherSettingCam = [[self getParmasFormUrl:url byKey:@"disableOtherSettingCam"] boolValue];
                
                
                self.disableVideo = [[self getParmasFormUrl:url byKey:@"disableVideo"] boolValue];
                self.disableHistory = [[self getParmasFormUrl:url byKey:@"disableHistory"] boolValue];
                self.disableSettings = [[self getParmasFormUrl:url byKey:@"disableSettings"] boolValue];
                
                self.disableSettingsPassword = [[self getParmasFormUrl:url byKey:@"disableSettingsPassword"] boolValue];
                self.disableSettingsNetwork = [[self getParmasFormUrl:url byKey:@"disableSettingsNetwork"] boolValue];
                self.disableSettingsUpgrate = [[self getParmasFormUrl:url byKey:@"disableSettingsUpgrate"] boolValue];
                self.disableSettingsReboot = [[self getParmasFormUrl:url byKey:@"disableSettingsReboot"] boolValue];
                self.disableSettingsReset = [[self getParmasFormUrl:url byKey:@"disableSettingsReset"] boolValue];
                self.shoppingURL = [self getParmasFormUrl:url byKey:@"shoppingURL"];
                self.disableModifyUserSetting = [[self getParmasFormUrl:url byKey:@"disableModifyUserSetting"] boolValue];
                self.disableExit = [[self getParmasFormUrl:url byKey:@"disableExit"] boolValue];

                UIViewController *transitionViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"MNTransitionViewController"];
                
                [self.window setRootViewController:transitionViewController];

            }
        }
    }
    
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.cloudAgent mmqTaskDestory];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.cloudAgent mmqTaskCreate];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    CoreDataUtils *CoreData = [CoreDataUtils deflautMIPCCoreData];
    [CoreData saveContext];
}


@end
