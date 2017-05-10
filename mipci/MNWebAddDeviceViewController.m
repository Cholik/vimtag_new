//
//  MNWebAddDeviceViewController.m
//  mipci
//
//  Created by mining on 16/6/22.
//
//

#import "MNWebAddDeviceViewController.h"
#import "MIPCUtils.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "mencrypt/mencrypt.h"
#import "MNDeviceListViewController.h"
#import "MNDeviceListSetViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MNCameraOverlayView.h"
#import "MNGuideNavigationController.h"

#import <SystemConfiguration/CaptiveNetwork.h>
#import "ZBarSDK.h"

//wifi connect
#import "mfsk_api.h"
#import "MNOpenAlDecode.h"
#import "mwificode.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <ifaddrs.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <sys/socket.h>

#import "pack.h"
#import "msg_pack.h"
#import "msg_type.h"
#import "msg_mbc.h"
#import "mipc_def_manager.h"

#define PASSWORD_FORCHECK @"lk9ds2*%#%dq"
#define __ProbeRequest_type_magic 0x2bdbce08
#define mbmc_msg_tmp_size   1024

typedef struct ProbeRequest
{
    struct
    {
        struct pack_ip  remote_ip;      /*  */
        int32_t         remote_port;    /*  */
    }_msysenv;                   /*  */
    struct pack_lenstr  pack_def_pointer(Types);    /*  */
    struct pack_lenstr  pack_def_pointer(Scopes);   /*  */
    struct pack_lenstr  type;                       /*  */
    struct pack_lenstr  sn;                         /*  */
}_ProbeRequest;

static int isClose;

@interface MNWebAddDeviceViewController () <UIWebViewDelegate,AVCaptureMetadataOutputObjectsDelegate, ZBarReaderViewDelegate>
{
    struct mwfc_client_cb *wfcClientCb;
    struct len_str str_param;
    char *buf_con;
    void *mmbc_handle;
}

@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) CGSize scanMaskSize;
//@property (strong, nonatomic) MNCameraOverlayView *cameraOverlayView;
@property (strong, nonatomic) ZBarReaderView *readerView;
@property (assign, nonatomic) BOOL is_scan;
@property (assign, nonatomic) BOOL is_scanSucess;

//代表了物理捕获设备如:摄像机。用于配置等底层硬件设置相机的自动对焦模式
@property (strong, nonatomic) AVCaptureDevice * captureDevice;

//管理输入流
@property (strong, nonatomic) AVCaptureDeviceInput * captureDeviceInput;

//管理输出流
@property (strong, nonatomic) AVCaptureMetadataOutput * captureMetadataOutput;

//管理输入(AVCaptureInput)和输出(AVCaptureOutput)流，包含开启和停止会话方法
@property (strong, nonatomic) AVCaptureSession * captureSession;

//显示捕获到的相机输出流
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

@property (strong, nonatomic) UIImageView * lineImageView;

@property (strong, nonatomic) UIView  *promaptView;

//wifi connect
@property (assign, nonatomic) unsigned char     *pcm_buf;
@property (assign, nonatomic) long              pcm_len;
@property (strong, nonatomic)  MNOpenAlDecode *soundOpen;
@property (assign, nonatomic) BOOL      connect_router;

@end

@implementation MNWebAddDeviceViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

- (mipc_agent *)agent
{
    return self.app.cloudAgent;
}

- (UIView *)promaptView
{
    if (nil == _promaptView) {
        _promaptView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)* 0.5)];
    }
    return _promaptView;
}

+ (instancetype)webAddDeviceViewControllerWithFrame:(CGRect)frame htmlName:(NSString *)name LeftBarButtonItem:(NSString *)leftBarButtonItemType RightBarButtonItem:(NSString *)rightBarButtonItemType
{
    MNWebAddDeviceViewController *webAddDeviceViewController = [[self alloc] init];
    webAddDeviceViewController.webView = [[UIWebView alloc] initWithFrame:frame];
    
    [webAddDeviceViewController.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    webAddDeviceViewController.webView.delegate = webAddDeviceViewController;
    
#if TARGET_IPHONE_SIMULATOR
    NSString *homeDir = NSHomeDirectory();
    NSArray *array = [homeDir componentsSeparatedByString:@"/Library"];
    NSString *userPathName = [[NSString stringWithFormat:@"%@",array[0]] stringByReplacingOccurrencesOfString:@"/Users/" withString:@""];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/Users/%@/project/src/apps/app/ipc/www/%@", userPathName, name]];
//
//    NSString *unzipFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", unzipFilePath, name]];
    
#else
        NSString *unzipFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", unzipFilePath, name]];
#endif

    if ([leftBarButtonItemType isEqualToString:@"back"]) {
        webAddDeviceViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStylePlain target:webAddDeviceViewController action:@selector(pushBack)];
    } else {
        webAddDeviceViewController.navigationItem.hidesBackButton = YES;
    }
    
    if ([rightBarButtonItemType isEqualToString:@"close"]) {
        webAddDeviceViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_delete"] style:UIBarButtonItemStylePlain target:webAddDeviceViewController action:@selector(close)];
    } else if ([rightBarButtonItemType isEqualToString:@"dismiss"]) {
        webAddDeviceViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_delete"] style:UIBarButtonItemStylePlain target:webAddDeviceViewController action:@selector(dismissBack)];
    } else if ([rightBarButtonItemType isEqualToString:@"refresh"]) {
        webAddDeviceViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:webAddDeviceViewController action:@selector(refreshWifiList)];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webAddDeviceViewController.webView loadRequest:request];
    [webAddDeviceViewController.view addSubview:webAddDeviceViewController.webView];
    
    return webAddDeviceViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    if (nil == self.webView)
    {
        self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        
        [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
#if TARGET_IPHONE_SIMULATOR
        NSString *homeDir = NSHomeDirectory();
        NSArray *array = [homeDir componentsSeparatedByString:@"/Library"];
        NSString *userPathName = [[NSString stringWithFormat:@"%@",array[0]] stringByReplacingOccurrencesOfString:@"/Users/" withString:@""];

        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/Users/%@/project/src/apps/app/ipc/www/add_device_html/add_device_choose_device_type.html", userPathName]];
//
//        NSString *unzipFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"];
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/add_device_html/add_device_choose_device_type.html", unzipFilePath]];
//
#else
        NSString *unzipFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/add_device_html/add_device_choose_device_type.html", unzipFilePath]];
#endif

        
        self.webView.delegate = self;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_delete"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        [self.view addSubview:self.webView];
        self.navigationItem.title = NSLocalizedString(@"mcs_choose_device_type", nil);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.navigationItem.title isEqual:NSLocalizedString(@"mcs_qrcode_scan", nil)]) {
        if ([self checkOpenCameraOrNot]) {
            [self openCamera];
            [self setupCamera];
            [self.cameraOverlayView performSelector:@selector(startAnimate) withObject:nil afterDelay:1.0];
        } else {
            [self.view addSubview:self.promaptView];
            if (!self.app.is_vimtag) {
                NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
                NSString *title = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"mcs_please_allow", nil), appName, NSLocalizedString(@"mcs_access_camera", nil)];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:[NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"mcs_ios_privacy_setting_for_camera_prompt", nil),appName, NSLocalizedString(@"mcs_execute_change", nil)]
                                                               delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
                                                      otherButtonTitles: nil];
                [alert show];
            } else {
                    [self.promaptView setHidden:NO];
            }
            
            
        }
    } else if([self.navigationItem.title isEqual:NSLocalizedString(@"mcs_wifi_intelligent_configuration", nil)])
    {
        isClose = false;
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.cameraOverlayView stopAnimate];
    [self.cameraOverlayView removeFromSuperview];
    if (self.pcm_buf) {
        free(self.pcm_buf);
        self.pcm_buf = NULL;
    }
    if (self.soundOpen){
        [self.soundOpen stopSound];
        [self.soundOpen clearOpenAL];
        self.soundOpen = nil;
    }
    mwfc_client_destroy(wfcClientCb);
    if(mmbc_handle)
    {
        mmbc_destroy(mmbc_handle);
        mmbc_handle = NULL;
    }
    
    if([self.navigationItem.title isEqual:NSLocalizedString(@"mcs_wifi_intelligent_configuration", nil)])
    {
        isClose = true;
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
//获取捕获数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    if (!_is_scanSucess) {
        if ([metadataObjects count] >0)
        {
            AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
            NSString *strValue = metadataObject.stringValue;
            
            [self sendQRCode:strValue];
            _is_scanSucess = YES;
        }
        //停止会话
        [_captureSession stopRunning];
    }
}
//变形剪切
- (CGRect)transformCropRect:(CGRect)cropRect
{
//    CGSize size = self.view.bounds.size;
    CGSize size = self.cameraOverlayView.frame.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920.0/1080.0;  //Using the 1080p image output
    
    
    if (p1 < p2) {
        CGFloat fixHeight = self.view.bounds.size.width * 1920.0 / 1080.0;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        return CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                          cropRect.origin.x/size.width,
                          cropRect.size.height/fixHeight,
                          cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = self.view.bounds.size.height * 1080.0 / 1920.0;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        return CGRectMake(cropRect.origin.y/size.height,
                          (cropRect.origin.x + fixPadding)/fixWidth,
                          cropRect.size.height/size.height,
                          cropRect.size.width/fixWidth);
    }
}

- (void)sendQRCode:(NSString *)strValue
{
    
    struct len_str  sID = {0}, sPassword = {0}, sPasswordMD5 = {0}, sWifi = {0},
    sResult = {strValue.length, (char*)[strValue UTF8String]};
    
    if((0 == MIPC_ParseLineParams(&sResult, &sID, &sPassword, &sPasswordMD5, &sWifi))
       && sID.len)
    {
        
            self.deviceID = [[NSString stringWithFormat:@"%*.*s", 0, (int)sID.len, sID.data] lowercaseString];
            self.devicePassword = [NSString stringWithFormat:@"%*.*s", 0, (int)sPassword.len, sPassword.data];
        
        NSData *jsonData = [self.jsParam dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *err;
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                             
                                                            options:NSJSONReadingMutableContainers
                             
                                                              error:&err];
        if(err) {
            NSLog(@"json failure:%@",err);
        } else {
            [dic setValue:self.deviceID forKey:@"device_id"];
            [dic setValue:self.devicePassword forKey:@"device_password"];
        }
        
        
        jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&err];
        
        self.jsParam = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        [self creatNewWebViewControllerWithTitle:NSLocalizedString(@"mcs_add_device", nil) htmlName:@"add_device_html/add_device_input_device_password.html" jumpModel:@"push" LeftBarButtonItem:@"back" RightBarButtonItem:@"close"];
//        [self creatNewWebViewControllerWithTitle:NSLocalizedString(@"mcs_add_device", nil) htmlName:@"add_device_input_device_password.html" jumpModel:MNViewControllerJumpModelDefault NavigationItemRightBarButtonItem:MNNavigationItemLeftBarButtonItemBack NavigationItemRightBarButtonItem:MNNavigationItemRightBarButtonItemClose];
//            _password = [NSString stringWithFormat:@"%*.*s", 0, (int)sPassword.len, sPassword.data];
//            NSString *wifi = [NSString stringWithFormat:@"%*.*s", 0,(int)sWifi.len, sWifi.data];
//            _is_wifiConfig = 0;
//            if (![wifi isEqualToString:@"(null)"])
//            {
//                _is_wifiConfig = 1;
//            }
//            if (self.app.is_luxcam && _addDeviceViewController) {
//                _addDeviceViewController.nameTextField.text = _deviceID;
//                _addDeviceViewController.passwordTextField.text = _password;
//                [[self navigationController] popViewControllerAnimated:YES];
//            }
//            else
//            {
//                self.is_scan = YES;
//                [self performSegueWithIdentifier:@"MNAddDeviceViewController" sender:nil];
//            }
    }
    
}

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image{
    const zbar_symbol_t *symbol = zbar_symbol_set_first_symbol(symbols.zbarSymbolSet);
    NSString *strValue = [NSString stringWithUTF8String: zbar_symbol_get_data(symbol)];
    [self sendQRCode:strValue];
    [self.readerView stop];
}

#pragma mark - UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

{
    NSLog(@"shouldStartLoadWithRequest url:%@", request.URL);
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([requestString hasPrefix:@"iosapp:"])
    {
        [self changeWebRequest:requestString];
        return NO;
    }
    return YES;
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViwDidFinishLoad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error
{
    NSLog(@"didFailLoadWithError");
}

//get param dict
- (NSMutableDictionary*)queryStringToDictionary:(NSString*)string {
    NSString *paramString = [string substringFromIndex:[string rangeOfString:@":"].location + 1];
    NSMutableArray *elements = (NSMutableArray*)[paramString componentsSeparatedByString:@"&"];
    [elements removeObjectAtIndex:0];
    NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:[elements count]];
    for(NSString *e in elements) {
        NSArray *pair = [e componentsSeparatedByString:@"="];
        [retval setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
    }
    return retval;
}

//get current language
- (NSString *)getCurrentLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [allLanguages objectAtIndex:0];
    NSString *langString;
    
    if ([preferredLang rangeOfString:@"en"].length) {
        langString = @"en";
    }
    else if ([preferredLang rangeOfString:@"zh-Hans"].length) {
        langString = @"zh";
    }
    else if ([preferredLang rangeOfString:@"zh-Hant"].length || [preferredLang rangeOfString:@"HK"].length || [preferredLang rangeOfString:@"TW"].length) {
        langString = @"zh";//@"tw";
    }
    else if ([preferredLang rangeOfString:@"ja"].length) {
        langString = @"ja";
    }
    else if ([preferredLang rangeOfString:@"ko"].length) {
        langString = @"ko";
    }
    else if ([preferredLang rangeOfString:@"de"].length) {
        langString = @"de";
    }
    else if ([preferredLang rangeOfString:@"fr"].length) {
        langString = @"fr";
    }
    else if ([preferredLang rangeOfString:@"es"].length) {
        langString = @"es";
    }
    else if ([preferredLang rangeOfString:@"pt"].length) {
        langString = @"pt";
    }
    else if ([preferredLang rangeOfString:@"it"].length) {
        langString = @"it";
    }
    else if ([preferredLang rangeOfString:@"ar"].length) {
        langString = @"ar";
    }
    else if ([preferredLang rangeOfString:@"ru"].length) {
        langString = @"ru";
    }
    else if ([preferredLang rangeOfString:@"hu"].length) {
        langString = @"hu";
    }
    else if ([preferredLang rangeOfString:@"nl"].length) {
        langString = @"nl";
    }
    else {
        langString = @"en";
    }
    
    return langString;
}

- (void)changeWebRequest:(NSString*)requestString
{
    NSMutableDictionary *paramDict = [self queryStringToDictionary:requestString];
    NSString *type = [paramDict objectForKey:@"func"];
    NSLog(@"get param:%@", [paramDict description]);
   
    if ([type isEqualToString:@"get_native_param"]) {
        if (!self.jsParam) {
           
            self.wwwVersion = [paramDict objectForKey:@"wwwVersion"];
//            [[NSUserDefaults standardUserDefaults] setObject:self.wwwVersion forKey:@"wwwVersion"];
            NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:self.agent.srv forKey:@"srv"];
            [dic setValue:self.agent.shareKey forKey:@"share_key"];
            [dic setValue:[NSNumber numberWithLongLong:self.agent.sid]  forKey:@"sid"];
            [dic setValue:[paramDict objectForKey:@"loadweb"] forKey:@"loadweb"];
            [dic setValue:[paramDict objectForKey:@"wwwVersion"] forKey:@"www_version"];
            [dic setValue:[self getCurrentLanguage] forKey:@"language"];
            [dic setValue: infoDic[@"CFBundleVersion"] forKey:@"app_version"];

            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
            self.jsParam = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        } else
        {
           
            NSData *jsonData = [self.jsParam dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            if(err) {
                NSLog(@"json failure:%@",err);
            } else {
                [dic setValue:[paramDict objectForKey:@"loadweb"] forKey:@"loadweb"];
                [dic setValue:self.agent.srv forKey:@"srv"];
                [dic setValue:self.agent.shareKey forKey:@"share_key"];
                [dic setValue:[NSNumber numberWithLongLong:self.agent.sid]  forKey:@"sid"];
                [dic setValue:[NSNumber numberWithInt:[self checkOpenCameraOrNot]] forKey:@"camera"];

#if TARGET_IPHONE_SIMULATOR
                NSLog(@"self.agent.shareKey:%@, self.agent.srv:%@, self.agent.sid:%lld", self.agent.shareKey, self.agent.srv, self.agent.sid);
                [dic setValue:@"simulator" forKey:@"wifi_ssid"];

#else
                [dic setValue:[self get_current_SSID] forKey:@"wifi_ssid"];
#endif
//                jsonData = [NSJSONSerialization dataWithJSONObject:[self getDevicesDic] options:0 error:&err];
//                NSString *deviceDicString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [dic setValue:[self getDevicesDic] forKey:@"devices_dic"];

                //developer mode
                if (self.app.developerOption.QRSwitch || self.app.developerOption.soundsSwitch || self.app.developerOption.normalSwitch) {
                    [dic setValue:[NSNumber numberWithLongLong:self.app.developerOption.normalSwitch] forKey:@"wfc"];
                    [dic setValue:[NSNumber numberWithLongLong:self.app.developerOption.QRSwitch] forKey:@"qrc"];
                    [dic setValue:[NSNumber numberWithLongLong:self.app.developerOption.soundsSwitch]  forKey:@"snc"];
                    
                }
            }
            jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&err];
            self.jsParam = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        NSString *nativeParam = [self.jsParam stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
        [self callJSWithCallback:[paramDict objectForKey:@"callback"] param:nativeParam];

    } else if ([type isEqualToString:@"get_config_mode"]) {
        [self callJSWithCallback:[paramDict objectForKey:@"callback"] param:[NSString stringWithFormat:@"%d", self.isWifiConfig]];
    } else if ([type isEqualToString:@"get_wifi_config_type"]) {
        [self callJSWithCallback:[paramDict objectForKey:@"callback"] param:[NSString stringWithFormat:@"{wfc:\'%ld\', qrc:\'%ld\', snc:\'%ld\'}", self.wfc, self.qrc, self.snc]];
    }  else if ([type isEqualToString:@"add_device_forget_password_close"]) {
        [self dismissBack];
    } else if ([type isEqualToString:@"add_device_wifi_name"]) {
        self.select_wifi = [paramDict objectForKey:@"wifi"];
        unsigned long count = self.navigationController.viewControllers.count;
        MNWebAddDeviceViewController *webAddDeviceViewController = self.navigationController.viewControllers[count - 2];
        [webAddDeviceViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById(\"input_wifi_name\").value = \"%@\";document.getElementById(\"input_wifi_name\").style.color = \"#404040\";", self.select_wifi]];
    } else if ([type isEqualToString:@"refresh_prev_page"]) {
        self.refresh_param = [paramDict objectForKey:@"refreshParam"];
        NSString *nativeParam = [self.refresh_param stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
        unsigned long count = self.navigationController.viewControllers.count;
        MNWebAddDeviceViewController *webAddDeviceViewController = self.navigationController.viewControllers[count - 2];
        
        [webAddDeviceViewController.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.index.%@(\"%@\");", [paramDict objectForKey:@"callback"], nativeParam]];

    }else if ([type isEqualToString:@"return_devices_list"]) {
        [self close];
    } else if ([type isEqualToString:@"soundSetup"]) {
        [self soundSetup];
    } else if ([type isEqualToString:@"soundStop"]) {
        [self soundStop];
    } else if ([type isEqualToString:@"normalWifiConfig"]) {
        [self normalWifiConfig];
    } else if ([type isEqualToString:@"wifiConnect"]) {
            [self wifiConnect];

    } else if ([type isEqualToString:@"wifiConnectStop"]) {
        [self wifiConnectStop];
    } else if ([type isEqualToString:@"searchLANDevice"]) {
        self.callback = [paramDict objectForKey:@"callback"];
        [self searchLANDevice];
    } else if([type isEqualToString:@"StopSearchLANDevice"]){
        [self stopSearchLANDevice];
    }else if ([type isEqualToString:@"backAddDevicePage"]) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[MNWebAddDeviceViewController  class]] && [controller.navigationItem.title isEqual:NSLocalizedString(@"mcs_add_device", nil)]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }  else if ([type isEqualToString:@"creat_new_page"]) {
        self.jsParam = [paramDict objectForKey:@"jsParam"] ? [paramDict objectForKey:@"jsParam"] : self.jsParam;
        
        [self creatNewWebViewControllerWithTitle:[paramDict objectForKey:@"title"] htmlName:[paramDict objectForKey:@"htmlName"] jumpModel:[paramDict objectForKey:@"mode"] LeftBarButtonItem:[paramDict objectForKey:@"leftButton"] RightBarButtonItem:[paramDict objectForKey:@"rightButton"]];
    } else if ([type isEqualToString:@"add_qrcode_capture"]) {
//        [self openCamera];
    } else if ([type isEqualToString:@"send_title"]) {
        self.navigationItem.title = [paramDict objectForKey:@"title"];
    }
}
- (void)creatNewWebViewControllerWithTitle:(NSString *)title htmlName:(NSString *)name jumpModel:(NSString *)jumpModel LeftBarButtonItem:(NSString *)leftBarButtonItemType RightBarButtonItem:(NSString *)rightBarButtonItemType
{
    MNWebAddDeviceViewController *webViewController = [MNWebAddDeviceViewController webAddDeviceViewControllerWithFrame:self.view.frame htmlName:name LeftBarButtonItem:leftBarButtonItemType RightBarButtonItem:rightBarButtonItemType];
    webViewController.jsParam = self.jsParam;
    webViewController.navigationItem.title = title;
    if([jumpModel isEqualToString:@"push"]) {
        [self.navigationController pushViewController:webViewController animated:YES];
    } else {
        MNGuideNavigationController *navigationController = [[MNGuideNavigationController alloc] initWithRootViewController:webViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)callJSWithCallback:(NSString *)callback param:(NSString *)param
{
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.index.%@(\"%@\");", callback, param]];
}

- (void)pushBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshWifiList
{
    [self callJSWithCallback:@"add_device_wifi_list" param:nil];
}

- (void)close
{
    NSData *jsonData = [self.jsParam dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (!dic[@"add_success"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if (self.app.is_vimtag) {
        if (self.presentingViewController) {
            UITabBarController *rootTabBarController = (UITabBarController*)self.presentingViewController;
            for (UINavigationController *navigationController in rootTabBarController.viewControllers) {
                for (UIViewController *viewController in navigationController.viewControllers) {
                    if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                        NSLog(@"MNDeviceListSetViewController");
                        for (UIViewController *deviceListViewController in ((MNDeviceListSetViewController*)viewController).childViewControllers) {
                            if ([deviceListViewController isMemberOfClass:[MNDeviceListViewController class]]) {
                                [(MNDeviceListViewController *)deviceListViewController refreshData];
                                break;
                            }
                        }
                        break;
                    }
                }
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    } else {
        if (self.presentingViewController && !self.app.is_jump)
        {
            UINavigationController *rootNavigationcontroller = (UINavigationController*)self.presentingViewController;
            for (UIViewController *viewController in rootNavigationcontroller.viewControllers)
            {
                if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                    [((MNDeviceListViewController*)viewController) refreshData];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


- (void)selectpromaptImage
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [allLanguages objectAtIndex:0];
    NSLog(@"Current language:%@", preferredLang);
    
    UIImageView *promaptImage = [[UIImageView alloc] init];
//    promaptImage.center = self.view.center;
    CGRect frame = promaptImage.frame;
    frame.size.width = 200;
    frame.size.height = 200;
    frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2.0;
    frame.origin.y = 80;
    promaptImage.frame = frame;
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.frame = CGRectMake(20, CGRectGetHeight(promaptImage.frame) + 90, self.view.frame.size.width - 40, 100);
    promptLabel.numberOfLines = 0;
    promptLabel.font = [UIFont systemFontOfSize:13];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.text = NSLocalizedString(@"mcs_qrscan_prompt", nil);
    
    if ([preferredLang rangeOfString:@"en"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_p"];
    }
    else if ([preferredLang rangeOfString:@"zh-Hans"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_q"];
    }
    else if ([preferredLang rangeOfString:@"zh-Hant"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_g"];
    }
    else if ([preferredLang rangeOfString:@"ja"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_o"];
    }
    else if ([preferredLang rangeOfString:@"ko"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_n"];
    }
    else if ([preferredLang rangeOfString:@"de"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_i"];
    }
    else if ([preferredLang rangeOfString:@"fr"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_f"];
    }
    else if ([preferredLang rangeOfString:@"es"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_e"];
    }
    else if ([preferredLang rangeOfString:@"pt"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_h"];
    }
    else if ([preferredLang rangeOfString:@"it"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_d"];
    }
    else if ([preferredLang rangeOfString:@"ar"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_c"];
    }
    else if ([preferredLang rangeOfString:@"ru"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_a"];
    }
    else if ([preferredLang rangeOfString:@"hu"].length) {
        promaptImage.image = [UIImage imageNamed:@"cut_b"];
    }
    else {
        promaptImage.image = [UIImage imageNamed:@"cut_p"];
    }
    [self.promaptView addSubview:promptLabel];
    [self.promaptView addSubview: promaptImage];
}
- (BOOL)checkOpenCameraOrNot
{
    if (self.app.is_vimtag) {
        if(([[[UIDevice currentDevice] systemVersion] floatValue] < 7.f)
           || [self checkCamera])
        {
            return YES;
        } else {
            [self selectpromaptImage];
            NSString *mediaType = AVMediaTypeVideo;
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                
                NSLog(@"Limited camera access");
                return NO;
            }
            
        }
    } else {
        NSError *error = nil;
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
        if (error) {
            return NO;
        }
        
        return YES;
    }
    
    return YES;
}

- (BOOL)checkCamera
{
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
    if(nil == videoInput)
    {
        if(error.code == -11852)
        {
            if(([[[UIDevice currentDevice] systemVersion] floatValue] < 7.f)
               )
            {
                NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
                NSString *title = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"mcs_please_allow", nil), appName, NSLocalizedString(@"mcs_access_camera", nil)];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:[NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"mcs_ios_privacy_setting_for_camera_prompt", nil),appName, NSLocalizedString(@"mcs_execute_change", nil)]
                                                               delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
                                                      otherButtonTitles: nil];
                [alert show];
            }
        }
        return NO;
    }
    return YES;
}

- (void)setupCamera
{
    _is_scanSucess = NO;
    
#if !TARGET_IPHONE_SIMULATOR
    CGRect cropRect = CGRectMake(self.cameraOverlayView.center.x - _scanMaskSize.width / 2,
                                 CGRectGetHeight(self.cameraOverlayView.frame)/2 - _scanMaskSize.height / 2,
                                 _scanMaskSize.width,
                                 _scanMaskSize.height);
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        self.readerView = [ZBarReaderView new];
        _readerView.frame = self.cameraOverlayView.frame;
        _readerView.torchMode = 0;
        _readerView.tracksSymbols = NO;
        _readerView.readerDelegate = self;
        _readerView.allowsPinchZoom = NO;
        
        float factor,scale;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            factor = 0.60;
        }
        else
        {
            factor = 0.45;
        }
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        scale = CGRectGetWidth(screenRect) / CGRectGetHeight(screenRect) * factor;
        _readerView.scanCrop = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? CGRectMake(0, 0, 1, 1) : CGRectMake((1 - scale) / 2, (1 - scale) / 2,  scale, scale);
        
        //        [self.view insertSubview:_readerView atIndex:0];
        [self.view insertSubview:_readerView belowSubview:_cameraOverlayView];
        [_readerView start];
        
    }
    else
    {
        // Device
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // Input
        _captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:nil];
        // Output
        _captureMetadataOutput = [[AVCaptureMetadataOutput alloc]init];
        [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_captureMetadataOutput setRectOfInterest:[self transformCropRect:cropRect]];
        
        // Session
        _captureSession = [[AVCaptureSession alloc]init];
        [_captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
        
        if ([_captureSession canAddInput:_captureDeviceInput])
        {
            
            [_captureSession addInput:_captureDeviceInput];
        }
        
        if ([_captureSession canAddOutput:_captureMetadataOutput])
        {
            
            [_captureSession addOutput:_captureMetadataOutput];
        }
        
        //
        //        _captureMetadataOutput.metadataObjectTypes = [NSArray arrayWithObject:AVMetadataObjectTypeQRCode];
        if ([_captureMetadataOutput.availableMetadataObjectTypes containsObject:
             AVMetadataObjectTypeQRCode])
        {
            _captureMetadataOutput.metadataObjectTypes = [NSArray arrayWithObject:AVMetadataObjectTypeQRCode];
//            CGRect bounds = self.cameraOverlayView.frame;
            
            // Preview
            _captureVideoPreviewLayer =[AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
            _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//            _captureVideoPreviewLayer.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
            _captureVideoPreviewLayer.frame = self.cameraOverlayView.frame;
            //        [self.view.layer insertSublayer:_captureVideoPreviewLayer atIndex:0];
            [self.view.layer insertSublayer:_captureVideoPreviewLayer below:_cameraOverlayView.layer];
            
            // Start
            [_captureSession startRunning];
            
        } else {
            self.readerView = [ZBarReaderView new];
            _readerView.frame = self.cameraOverlayView.frame;
            _readerView.torchMode = 0;
            _readerView.tracksSymbols = NO;
            _readerView.readerDelegate = self;
            _readerView.allowsPinchZoom = NO;
            
            float factor,scale;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                factor = 0.60;
            }
            else
            {
                factor = 0.45;
            }
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            scale = CGRectGetWidth(screenRect) / CGRectGetHeight(screenRect) * factor;
            _readerView.scanCrop = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? CGRectMake(0, 0, 1, 1) : CGRectMake((1 - scale) / 2, (1 - scale) / 2,  scale, scale);
            
            //        [self.view insertSubview:_readerView atIndex:0];
            [self.view insertSubview:_readerView belowSubview:_cameraOverlayView];
            [_readerView start];
        }
    }
    
#endif
}

#pragma mark - openCamera
- (void)openCamera
{
    
self.cameraOverlayView = [[MNCameraOverlayView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.frame) - 64)/2)];
    
    self.scanMaskSize = CGSizeMake(240, 200);
    self.cameraOverlayView.scanMaskSize = self.scanMaskSize;
    
    UILabel *promaptLabel =  [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.cameraOverlayView.frame), CGRectGetMinY(self.cameraOverlayView.frame) - 115, CGRectGetWidth(self.cameraOverlayView.frame), CGRectGetHeight(self.cameraOverlayView.frame))];
    promaptLabel.font = [UIFont systemFontOfSize:12];
    promaptLabel.textAlignment = NSTextAlignmentCenter;
    promaptLabel.textColor = [UIColor whiteColor];
    
    promaptLabel.text = NSLocalizedString(@"mcs_qrcode_scan_hint", nil);
//
    [self.view addSubview:promaptLabel];
    [self.view addSubview:self.cameraOverlayView];

}

#pragma mark - connect wifi
- (void)wifiConnect {

    str_param.data = nil;
    str_param.len = 0;
    
    NSData *jsonData = [self.jsParam dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];

        const char *routeAddress = [[self routerIp] UTF8String];
        const char *wifiName = [[dic objectForKey:@"wifi_ssid"] UTF8String];
        const char *wifiPassword = [[dic objectForKey:@"wifi_password"] UTF8String];
        const char *deviceID = [[dic objectForKey:@"device_id"] UTF8String];
        long snc = [[dic objectForKey:@"snc"] intValue];
        long wfc = [[dic objectForKey:@"wfc"] intValue];
        NSString *sncf = [dic objectForKey:@"sncf"];
    self.deviceID = [dic objectForKey:@"device_id"];
    
    //Get current langs
        const char *langs = [[dic objectForKey:@"language"] UTF8String];
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
        struct json_object *obj_con = json_create_object(NULL, 0, NULL);
        
        struct json_object *obj_sn = json_create_string(obj_con, strlen("sn"), "sn", strlen(deviceID), (char *)deviceID);
        struct json_object *obj_s = json_create_string(obj_con, strlen("s"), "s", strlen(wifiName), (char *)wifiName);
        struct json_object *obj_l = json_create_string(obj_con, strlen("l"), "l", strlen(langs), (char *)langs);
        struct json_object *obj_p = json_create_string(obj_con, strlen("p"), "p", strlen(wifiPassword), (char *)wifiPassword);
        
        unsigned long buf_size = 20480;
        buf_con = malloc(buf_size);
        json_encode(obj_con, buf_con, buf_size);
        
        struct json_object *obj_param = json_create_object(NULL, 0, NULL);
        
        struct json_object *obj_dst = json_create_string(obj_param, strlen("dst"), "dst", strlen(routeAddress), (char *)routeAddress);
        struct json_object *obj_content = json_create_string(obj_param, strlen("content"), "content", strlen(buf_con), buf_con);
        struct json_object *obj_speed = json_create_string(obj_param, strlen("speed"), "speed", strlen("1024000"), "1024000");
        
        char *buf_param = malloc(buf_size);
        json_encode(obj_param, buf_param, buf_size);
        
        str_param.data = buf_param;
        str_param.len = strlen(buf_param);
#pragma clang diagnostic pop
        
        //mfsk sounds connect wifi
        _pcm_buf = (unsigned char*)malloc(300  * 1024 * sizeof(unsigned char));
        long buf_len = 300 * 1024;
    if (self.app.developerOption.freqhigh) {
        struct mfsk param = {0};
        param.freqhigh = self.app.developerOption.freqhigh;
        param.freqlow = self.app.developerOption.freqlow;
        if (self.app.developerOption.trans_mode) {
            param.trans_mode = 1;
        }
        _pcm_len = mfsk_encode_to_pcm(&param, _pcm_buf, buf_len, buf_con);
    } else if (sncf.length) {
        if ([sncf rangeOfString:@"r"].length) {
            struct mfsk param = {0};
            param.freqhigh = sncf.length > 4 ? [[sncf substringWithRange:NSMakeRange(3,2)] intValue]*100 : 3300;
            param.freqlow = sncf.length > 4 ? [[sncf substringWithRange:NSMakeRange(1,2)] intValue]*100 : 1600;
            param.trans_mode = 1;
            _pcm_len = mfsk_encode_to_pcm(&param, _pcm_buf, buf_len, buf_con);
        } else {
            struct mfsk param = {0};
            param.freqhigh = sncf.length > 3 ? [[sncf substringWithRange:NSMakeRange(2,2)] intValue]*100 : 2300;
            param.freqlow = sncf.length > 3 ? [[sncf substringWithRange:NSMakeRange(0,2)] intValue]*100 : 1600;
            _pcm_len = mfsk_encode_to_pcm(&param, _pcm_buf, buf_len, buf_con);
        }
    } else {
        _pcm_len = mfsk_encode_to_pcm(NULL, _pcm_buf, buf_len, buf_con);
    }
    
    self.configString = [[NSString stringWithUTF8String:buf_con] stringByReplacingOccurrencesOfString:@"\"" withString:@"\'"];
        //sound configue
 
        if (snc) {
            //add OpenAl
            self.soundOpen = [[MNOpenAlDecode alloc] init];
            [self.soundOpen initOpenAl];
            [self.soundOpen openAudio:_pcm_buf length:(unsigned int)_pcm_len+50*1024];
            [self.soundOpen playSound];
//            [self.soundOpen setImage:[UIImage imageNamed:@"vt_sound_conf.png"] forState:UIControlStateNormal];
        }

        if (wfc) {
                wfcClientCb = mwfc_client_create(&str_param);
        }
    
}



- (void)soundSetup
{
    if (self.soundOpen == nil) {
        self.soundOpen = [[MNOpenAlDecode alloc] init];
        [self.soundOpen initOpenAl];
        [self.soundOpen openAudio:_pcm_buf length:(unsigned int)_pcm_len+50*1024];
        [self.soundOpen playSound];
    }
}

- (void)soundStop
{
    if (self.soundOpen)
    {
        [self.soundOpen stopSound];
        [self.soundOpen clearOpenAL];
        self.soundOpen = nil;
    }
}

- (void)normalWifiConfig
{
    wfcClientCb = mwfc_client_create(&str_param);
}

- (void)wifiConnectStop
{
    if (self.soundOpen) {
        [self.soundOpen stopSound];
        [self.soundOpen clearOpenAL];
        self.soundOpen = nil;
    }
}

#pragma mark - get router address
- (NSString *)routerIp {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        //*/
        while(temp_addr != NULL)
        /*/
         int i=255;
         while((i--)>0)
         //*/
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    in_addr_t i =inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    in_addr_t* x =&i;
    
    
    unsigned char *s=getdefaultgateway(x);
    NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
    free(s);
    return ip;
}

#pragma mark - Search LAN Device 
- (void)stopSearchLANDevice
{
    mwfc_client_destroy(wfcClientCb);
    if(mmbc_handle)
    {
        mmbc_destroy(mmbc_handle);
        mmbc_handle = NULL;
    }
}

- (void)searchLANDevice
{
    if (!mmbc_handle) {
        mipc_def_manager *def_manager = [mipc_def_manager shared_def_manager];
        struct mmbc_create_param    param = {0};
        param.broadcast_addr.data = "255.255.255.255";
        param.broadcast_addr.len = strlen( param.broadcast_addr.data );
        param.multicast_addr.data = "239.255.255.0";
        param.multicast_addr.len = strlen( param.multicast_addr.data );
        param.port = 3703;
        //    param.on_recv_msg = on_recv_msg;
        param.on_recv_json_msg = on_recv_json_msg_by_connect_web;
        param.refer = (__bridge void *)(self);
        
        param.def_list = def_manager.new_def_list;
        param.disable_listen = 1;
        mmbc_handle = mmbc_create( &param );
        //        NSLog(@"----- Create handle -----");
    }
    
    if( NULL != mmbc_handle )
    {
        //        NSLog(@"----- Send handle Msg-----");
        
        struct ProbeRequest     *probe = NULL;
        char                    pbuf_data[mbmc_msg_tmp_size] = {0}; /* !!!!!!not good way. */
        struct message          *msg = (struct message*)&pbuf_data[0];
        struct mpack_buf        pbuf = {0};
        
        /* Send probe through mmbc */
        msg_set_size(msg, mbmc_msg_tmp_size);
        msg_set_version(msg, 1 == (*(short*)"\x00\x01"), msg_sizeof_header(sizeof("ProbeRequest") - 1), 0);
        msg_set_type(msg, "ProbeRequest", sizeof("ProbeRequest") - 1);
        msg_set_type_magic(msg, __ProbeRequest_type_magic);
        msg_set_from(msg, 0x1231);
        msg_set_from_handle(msg, 1);
        msg_set_to(msg, 0x20500000);/* !!!!need change  (component id)*/
        msg_set_to_handle(msg, 0);
        mpbuf_init(&pbuf, (unsigned char*)msg_get_data(msg), mbmc_msg_tmp_size - msg_sizeof_header(sizeof("ProbeRequest") - 1));
        
        probe = (struct ProbeRequest*)mpbuf_alloc(&pbuf, sizeof(struct ProbeRequest));
        
        if( probe == NULL )
        {
            NSLog(@"failed when mpbuf_alloc()");
            goto fail_label;
        }
        //        if(NULL == (probe->type.data = mpbuf_save_str(&pbuf, len_str_def_const("IPC"), NULL)))
        if(mpbuf_save_str(&pbuf, len_str_def_const(""), NULL) == NULL)
        {
            NSLog (@"failed when mpbuf_save_str()");
            goto fail_label;
        }
        
        msg_set_data_base_addr(msg, ((char*)(pbuf.index)));
        msg_save_finish(msg);
        if(mmbc_send_msg(mmbc_handle, NULL, msg))
        {
            NSLog (@"failed when mmbc_send_msg()");
            if(mmbc_handle)
            {
                mmbc_destroy(mmbc_handle);
                mmbc_handle = NULL;
            }
            goto fail_label;
        }
        
        
    fail_label:
        if( msg )
        {
            //                mmbc_destroy(mmbc_handle);
        }
    }
}

long on_recv_json_msg_by_connect_web( void *ref, struct len_str *msg_type, struct len_str *msg_json, struct sockaddr_in *remote_addrin )
{
//    
    if (isClose) {
        return 0;
    }
    @try {
        MNWebAddDeviceViewController *referSelf = (__bridge MNWebAddDeviceViewController*)ref;
        NSLog(@"----->%@", [NSString stringWithUTF8String:msg_type->data]);
        
        if(0 == len_str_casecmp_const(msg_type, "ProbeResponse"))
        {
            struct len_str sn = {0}, type = {0};
            m_dev *dev = [[m_dev alloc] init];
            
            NSData *msg_data = [NSData dataWithBytes:msg_json->data length:msg_json->len];
            struct json_object *data_json = MIPC_DataTransformToJson(msg_data);
            
            struct json_object *probe_json = json_get_child_by_name(data_json, NULL, len_str_def_const("ProbeMatch"));
            //        json_get_child_string(data_json, "sn", &sn);
            json_get_child_string(data_json, "type", &type);
            NSLog(@"-------------------ProbeResponse----------------------------");
            
            if(probe_json
               && (probe_json->type == ejot_array)
               && probe_json->v.array.counts)
            {
                struct json_object *obj = probe_json->v.array.list;
                for (int i = 0; i < probe_json->v.array.counts; i++, obj = obj->in_parent.next)
                {
                    struct len_str ip_addr = {0};
                    json_get_child_string(obj, "XAddrs", &ip_addr);
                    
                    struct json_object *Endpoint_json = json_get_child_by_name(obj, NULL, len_str_def_const("EndpointReference"));
                    json_get_child_string(Endpoint_json, "Address", &sn);
                    
                    dev.sn = sn.len ? [NSString stringWithUTF8String:sn.data].lowercaseString : nil;
                    //                NSLog(@"device ID: %@",dev.sn);
                    if (referSelf && [dev.sn isEqualToString:referSelf.deviceID])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            referSelf.connect_router = YES;
                            //                        [referSelf.configProgressView finishConnectRouter];
                            if (referSelf.soundOpen) {
                                [referSelf soundStop];
                            }
                            [referSelf callJSWithCallback:referSelf.callback param:nil];
                        });
                    }
                }
            }
        }

    } @catch (NSException *exception) {
        NSLog(@"exception:%@,", exception);
        return 0;
    } @finally {
        NSLog(@"finally");
    }
    
    return 0;
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

- (NSMutableDictionary *)getDevicesDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    for (int i = 0; i < [self.agent.devs getCounts]; i++) {
        m_dev *dev = [self.agent.devs get_dev_by_index:i];
        [dic setObject:dev.sn forKey:dev.sn];
    }
   
    return dic;
}

#pragma mark - Rotate
-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
