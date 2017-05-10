//
//  MNWIFIConnectViewController.m
//  mipci
//
//  Created by mining on 15/6/11.
//
//

#import "MNWIFIConnectViewController.h"
#import "MNProgressHUD.h"
#import "mwificode.h"
#import "MNLoginViewController.h"
#import "MNAddDeviceViewController.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNModifyPasswordViewController.h"
#import "MNDeviceListViewController.h"
#import "MNConfiguration.h"
//#import "MNInfoPromptView.h"
#import "MNDeviceOfflineViewController.h"
#import "MNDeviceTabBarController.h"
#import "MNDeviceGuideViewController.h"

#import <SystemConfiguration/CaptiveNetwork.h>
#import "MIPCUtils.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <ifaddrs.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <sys/socket.h>
#import "QRCodeGenerator.h"
#import "mfsk_api.h"
#import "MNOpenAlDecode.h"
#import "MNUserBehaviours.h"

#import "pack.h"
#import "msg_pack.h"
#import "msg_type.h"
#import "msg_mbc.h"
#import "mipc_def_manager.h"

//end
#define PASSWORD_FORCHECK @"lk9ds2*%#%dq"
#define COUNTDOWM_TIME   180
#define HALORADIUS       120
#define EMPTY_PCM_LENGTH    50*1024
#define QRCODEPROMPT      @"qrcodePreatePrompt"

#define TABBARTEXTCOLOR [UIColor colorWithRed:142/255.0 green:142/255.0 blue:142/255.0 alpha:1.0]

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

struct mwfc_client_cb *cb;


@interface MNWIFIConnectViewController ()
{
    void *mmbc_handle;
}
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) MNOpenAlDecode *testOpen;
@property (strong, nonatomic) NSTimer *timeOutTimer;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (assign, nonatomic) BOOL isLoginAgain;

@property (assign, nonatomic) unsigned char     *pcm_buf;
@property (assign, nonatomic) long              pcm_len;

@property (assign, nonatomic) long      qrc;
@property (assign, nonatomic) long      snc;
@property (assign, nonatomic) long      wfc;
@property (strong, nonatomic) NSString  *sncf;
@property (assign, nonatomic) BOOL      is_selectNormal;

@property (assign, nonatomic) long      countdown;
@property (assign, nonatomic) BOOL      connect_router;

@property (strong, nonatomic) NSData *gifData;
@property (strong, nonatomic) UIColor   *styleColor;

@end


@implementation MNWIFIConnectViewController

- (mipc_agent *)agent
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

- (MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_progressHUD];
        _progressHUD.color = [UIColor colorWithWhite:1.0f alpha:0.8f];
        _progressHUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        _progressHUD.labelText = NSLocalizedString(@"mcs_loading", nil);
        _progressHUD.labelColor = [UIColor grayColor];
        _progressHUD.activityIndicatorColor = [UIColor grayColor];
    }
    return  _progressHUD;
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_wifi_intelligent_configuration", nil);
    //Get ability level
    for (UIViewController *viewControllr in self.navigationController.viewControllers)
    {
        if ([viewControllr isMemberOfClass:[MNDeviceOfflineViewController class]])
        {
            _snc = ((MNDeviceOfflineViewController *)viewControllr).snc;
            _qrc = ((MNDeviceOfflineViewController *)viewControllr).qrc;
            _wfc = ((MNDeviceOfflineViewController *)viewControllr).wfc;
            _sncf = ((MNDeviceOfflineViewController *)viewControllr).sncf;
        }
    }
    //Get current langs
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [allLanguages objectAtIndex:0];
    if ([preferredLang rangeOfString:@"en"].length) {
        _langString = @"en";
    }
    else if ([preferredLang rangeOfString:@"zh-Hans"].length) {
        _langString = @"zh";
    }
    else if ([preferredLang rangeOfString:@"zh-Hant"].length || [preferredLang rangeOfString:@"HK"].length || [preferredLang rangeOfString:@"TW"].length) {
        _langString = @"zh";//@"tw";
    }
    else if ([preferredLang rangeOfString:@"ja"].length) {
        _langString = @"ja";
    }
    else if ([preferredLang rangeOfString:@"ko"].length) {
        _langString = @"ko";
    }
    else if ([preferredLang rangeOfString:@"de"].length) {
        _langString = @"de";
    }
    else if ([preferredLang rangeOfString:@"fr"].length) {
        _langString = @"fr";
    }
    else if ([preferredLang rangeOfString:@"es"].length) {
        _langString = @"es";
    }
    else if ([preferredLang rangeOfString:@"pt"].length) {
        _langString = @"pt";
    }
    else if ([preferredLang rangeOfString:@"it"].length) {
        _langString = @"it";
    }
    else if ([preferredLang rangeOfString:@"ar"].length) {
        _langString = @"ar";
    }
    else if ([preferredLang rangeOfString:@"ru"].length) {
        _langString = @"ru";
    }
    else if ([preferredLang rangeOfString:@"hu"].length) {
        _langString = @"hu";
    }
    else if ([preferredLang rangeOfString:@"nl"].length) {
        _langString = @"nl";
    }
    else {
        _langString = @"en";
    }
//    NSLog(@"%@ %@", preferredLang,_langString);
    if (self.app.is_ebitcam) {
        _styleColor = [UIColor colorWithRed:76/255. green:200./255. blue:110./255. alpha:1.0];
    } else if (self.app.is_mipc){
        _styleColor = self.configuration.switchTintColor;
    } else {
        _styleColor = self.configuration.color;
    }
    
    _is_configure = NO;
    _countdown = COUNTDOWM_TIME;
    //Gif play
    self.gifWebView.userInteractionEnabled = NO;
    self.gifWebView.scalesPageToFit = YES;
    self.gifWebView.backgroundColor = [UIColor clearColor];
    self.gifWebView.opaque = 0;
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"gif" ofType:nil];
    
    //Tabbar view
    _wifiConnectLabel.text = NSLocalizedString(@"mcs_wifi_intelligent_configuration", nil);
    _qrconnectLabel.text = NSLocalizedString(@"mcs_qrcode_connect", nil);
    
    _retryLabel.text = NSLocalizedString(@"mcs_action_click_retry", nil);
    _failLabel.text = NSLocalizedString(@"mcs_wifi_config_failure", nil);
    _connectETHLabel.text = NSLocalizedString(@"mcs_wifi_config_failure_detail", nil);
    if (_connectETHLabel.text.length > 20) {
        [_connectETHLabel setFont:[UIFont systemFontOfSize:12.0]];
    }
    [_connectETHButton setTitle:NSLocalizedString(@"mcs_ethernet_connect", nil) forState:UIControlStateNormal];
    [_connectETHButton setTitleColor:_styleColor forState:UIControlStateNormal];
    _connectETHButton.layer.cornerRadius = 4;
    _connectETHButton.layer.borderColor = _styleColor.CGColor;
    _connectETHButton.layer.borderWidth = 1;

    //QR config prompt
    _soundPromptLabel.text = NSLocalizedString(@"mcs_close_sound_prompt", nil);
    _detailLabel.text = NSLocalizedString(@"mcs_qrcode_prompt_detail", nil);
    _qrPromptLabel.text = NSLocalizedString(@"mcs_qrcode_prompt_detail", nil);
    _connectRouterLabel.text = NSLocalizedString(@"mcs_connect_server_prompt", nil);
    [_certainButton setTitle:NSLocalizedString(@"mcs_i_know", nil) forState:UIControlStateNormal];
    [_certainButton setTitleColor:_styleColor forState:UIControlStateNormal];
    _certainButton.layer.cornerRadius = 4;
    _certainButton.layer.borderColor = _styleColor.CGColor;
    _certainButton.layer.borderWidth = 1;
    
    _progressView.progressTintColor = _styleColor;
    _countLabel.backgroundColor = _styleColor;
    _countLabel.layer.cornerRadius = 10;
    _countLabel.layer.masksToBounds = YES;
    _countLabel.text = [NSString stringWithFormat:@"%lds",_countdown];
    
    if (self.app.is_luxcam) {
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
        [_QRCodeBgImage setImage:[UIImage imageNamed:@"QRCode_bg.png"]];
        [_retryButton setImage:[UIImage imageNamed:@"retry_connect.png"] forState:UIControlStateNormal];
        [_promptImage setImage:[UIImage imageNamed:@"model361.png"]];
        _progressImgView.image = [UIImage imageNamed:@"cricle"];
        NSString *gifDataPath = [NSString stringWithFormat:@"%@/mipc_wifi_conf_prompt.gif",gifPath];
        self.gifData = [NSData dataWithContentsOfFile:gifDataPath];
        
        [_normalButton setImage:[UIImage imageNamed:@"wifi_tabbar.png"] forState:UIControlStateNormal];
        [_normalButton setImage:[UIImage imageNamed:@"wifi_tabbar_select.png"] forState:UIControlStateSelected];
        [_QRButton setImage:[UIImage imageNamed:@"qr_tabbar.png"] forState:UIControlStateNormal];
        [_QRButton setImage:[UIImage imageNamed:@"qr_tabbar_select.png"] forState:UIControlStateSelected];
        _wifiConnectLabel.textColor = TABBARTEXTCOLOR;
        _wifiConnectLabel.highlightedTextColor = _styleColor;
        _qrconnectLabel.textColor = TABBARTEXTCOLOR;
        _qrconnectLabel.highlightedTextColor = _styleColor;
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_QRCodeBgImage setImage:[UIImage imageNamed:@"vt_qr_code_bg"]];
        _progressImgView.image = [UIImage imageNamed:@"vt_cricle"];
        NSString *gifDataPath = [NSString stringWithFormat:@"%@/wifi_conf_prompt.gif",gifPath];
        self.gifData = [NSData dataWithContentsOfFile:gifDataPath];
        
        [_normalButton setImage:[UIImage imageNamed:@"vt_wifi_tabbar.png"] forState:UIControlStateNormal];
        [_normalButton setImage:[UIImage imageNamed:@"vt_wifi_tabbar_select.png"] forState:UIControlStateSelected];
        [_QRButton setImage:[UIImage imageNamed:@"vt_qr_tabbar.png"] forState:UIControlStateNormal];
        [_QRButton setImage:[UIImage imageNamed:@"vt_qr_tabbar_select.png"] forState:UIControlStateSelected];
        _wifiConnectLabel.textColor = TABBARTEXTCOLOR;
        _wifiConnectLabel.highlightedTextColor = _styleColor;
        _qrconnectLabel.textColor = TABBARTEXTCOLOR;
        _qrconnectLabel.highlightedTextColor = _styleColor;
    }
    else if (self.app.is_ebitcam)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_QRCodeBgImage setImage:[UIImage imageNamed:@"QRCode_bg.png"]];
        [_retryButton setImage:[UIImage imageNamed:@"retry_connect.png"] forState:UIControlStateNormal];
        [_promptImage setImage:[UIImage imageNamed:@"model361.png"]];
        _progressImgView.image = [UIImage imageNamed:@"cricle"];
        NSString *gifDataPath = [NSString stringWithFormat:@"%@/mipc_wifi_conf_prompt.gif",gifPath];
        self.gifData = [NSData dataWithContentsOfFile:gifDataPath];
        
        [_normalButton setImage:[UIImage imageNamed:@"wifi_tabbar.png"] forState:UIControlStateNormal];
        [_normalButton setImage:[UIImage imageNamed:@"wifi_tabbar_select.png"] forState:UIControlStateSelected];
        [_QRButton setImage:[UIImage imageNamed:@"qr_tabbar.png"] forState:UIControlStateNormal];
        [_QRButton setImage:[UIImage imageNamed:@"qr_tabbar_select.png"] forState:UIControlStateSelected];
        _wifiConnectLabel.textColor = TABBARTEXTCOLOR;
        _wifiConnectLabel.highlightedTextColor = _styleColor;
        _qrconnectLabel.textColor = TABBARTEXTCOLOR;
        _qrconnectLabel.highlightedTextColor = _styleColor;
    }
    else if (self.app.is_mipc)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_QRCodeBgImage setImage:[UIImage imageNamed:@"QRCode_bg.png"]];
        [_retryButton setImage:[UIImage imageNamed:@"mi_retry_connect.png"] forState:UIControlStateNormal];
        [_promptImage setImage:[UIImage imageNamed:@"model361.png"]];
        _progressImgView.image = [UIImage imageNamed:@"mi_cricle"];
        NSString *gifDataPath = [NSString stringWithFormat:@"%@/mipc_wifi_conf_prompt.gif",gifPath];
        self.gifData = [NSData dataWithContentsOfFile:gifDataPath];
        
        [_normalButton setImage:[UIImage imageNamed:@"mi_wifi_tabbar.png"] forState:UIControlStateNormal];
        [_normalButton setImage:[UIImage imageNamed:@"mi_wifi_tabbar_select.png"] forState:UIControlStateSelected];
        [_QRButton setImage:[UIImage imageNamed:@"mi_qr_tabbar.png"] forState:UIControlStateNormal];
        [_QRButton setImage:[UIImage imageNamed:@"mi_qr_tabbar_select.png"] forState:UIControlStateSelected];
        _wifiConnectLabel.textColor = TABBARTEXTCOLOR;
        _wifiConnectLabel.highlightedTextColor = _styleColor;
        _qrconnectLabel.textColor = TABBARTEXTCOLOR;
        _qrconnectLabel.highlightedTextColor = _styleColor;
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_QRCodeBgImage setImage:[UIImage imageNamed:@"QRCode_bg.png"]];
        [_retryButton setImage:[UIImage imageNamed:@"retry_connect.png"] forState:UIControlStateNormal];
        [_promptImage setImage:[UIImage imageNamed:@"model361.png"]];
        _progressImgView.image = [UIImage imageNamed:@"cricle"];
        NSString *gifDataPath = [NSString stringWithFormat:@"%@/mipc_wifi_conf_prompt.gif",gifPath];
        self.gifData = [NSData dataWithContentsOfFile:gifDataPath];
        
        [_normalButton setImage:[UIImage imageNamed:@"wifi_tabbar.png"] forState:UIControlStateNormal];
        [_normalButton setImage:[UIImage imageNamed:@"wifi_tabbar_select.png"] forState:UIControlStateSelected];
        [_QRButton setImage:[UIImage imageNamed:@"qr_tabbar.png"] forState:UIControlStateNormal];
        [_QRButton setImage:[UIImage imageNamed:@"qr_tabbar_select.png"] forState:UIControlStateSelected];
        _wifiConnectLabel.textColor = TABBARTEXTCOLOR;
        _wifiConnectLabel.highlightedTextColor = _styleColor;
        _qrconnectLabel.textColor = TABBARTEXTCOLOR;
        _qrconnectLabel.highlightedTextColor = _styleColor;
    }
    [self.gifWebView loadData:self.gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    
    //refresh UI
    _is_selectNormal = YES;
    [self refreshTabbarColor];
    _confView.hidden = NO;
    _confResultView.hidden = YES;
    _retryView.hidden = YES;

    if ((_wfc || _snc) && _qrc) {
        _tabbarView.hidden = NO;
        _gifWebView.hidden = NO;
        _soundConfView.hidden = _snc ? NO : YES;
        _QRCodeImage.hidden = YES;
        _QRCodeBgImage.hidden = YES;
        _qrPromptLabel.hidden = YES;
        _qrcodePromptView.hidden = YES;
    }
    else if (_qrc)
    {
        _tabbarView.hidden = YES;
        _gifWebView.hidden = YES;
        _soundConfView.hidden = YES;
        _QRCodeImage.hidden = NO;
        _QRCodeBgImage.hidden = NO;
        _qrPromptLabel.hidden = NO;
        _qrcodePromptView.hidden = NO;
    }
    else
    {
        _tabbarView.hidden = YES;
        _gifWebView.hidden = NO;
        _soundConfView.hidden = _snc ? NO : YES;
        _QRCodeImage.hidden = YES;
        _QRCodeBgImage.hidden = YES;
        _qrPromptLabel.hidden = YES;
        _qrcodePromptView.hidden = YES;
    }
    [_soundButton setImage:[UIImage imageNamed:@"vt_sound_conf_off.png"] forState:UIControlStateNormal];
    [_soundButton setImage:[UIImage imageNamed:@"vt_sound_conf.png"] forState:UIControlStateSelected];
    
    //adaptation device
    if (self.is_loginModify && self.view.frame.size.height < 568) {
        _mainViewToTopConstraint.constant = _mainViewToTopConstraint.constant - 64;
        _confViewToTopConstraint.constant = _confViewToTopConstraint.constant - 64;
        _confResultViewToTopConstraint.constant = _confResultViewToTopConstraint.constant - 64;
    }
    else if (self.view.frame.size.height == 568)
    {
        _mainViewToTopConstraint.constant = self.is_loginModify ? 15 : 79;
        _confViewToTopConstraint.constant = self.is_loginModify ? 354 : 418;
        _confResultViewToTopConstraint.constant = self.is_loginModify ? 354 : 418;
        _mainViewHeight.constant = 330;
        _QRCodeImageWidth.constant = 320;
        _QRCodeImageHeight.constant = 320;
    }
    else if (self.view.frame.size.height == 667)
    {
        _mainViewToTopConstraint.constant = self.is_loginModify ? 26 : 90;
        _confViewToTopConstraint.constant = self.is_loginModify ? 396 : 460;
        _confResultViewToTopConstraint.constant = self.is_loginModify ? 396 : 460;
        _mainViewHeight.constant = 350;
        _mainviewWidth.constant = 320;
        _QRCodeImageWidth.constant = 350;
        _QRCodeImageHeight.constant = 350;
    }
    else if (self.view.frame.size.height >= 736)
    {
        _mainViewToTopConstraint.constant = self.is_loginModify ? 36 : 100;
        _confViewToTopConstraint.constant = self.is_loginModify ? 486 : 550;
        _confResultViewToTopConstraint.constant = self.is_loginModify ? 486 : 550;
        _mainViewHeight.constant = 390;
        _mainviewWidth.constant = 360;
        _QRCodeImageWidth.constant = 390;
        _QRCodeImageHeight.constant = 390;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self  initUI];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self wifiConnect:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [MNInfoPromptView hideAll:self.navigationController];

    if (_pcm_buf) {
        free(_pcm_buf);
        _pcm_buf = NULL;
    }

    if (_testOpen) {
        [_testOpen stopSound];
        [_testOpen clearOpenAL];
        _testOpen = nil;
    }
    
    if(mmbc_handle)
    {
        mmbc_destroy(mmbc_handle);
        mmbc_handle = NULL;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    mwfc_client_destroy(cb);
    if (_timeOutTimer) {
        [_timeOutTimer invalidate];
        _timeOutTimer = nil;
    }

    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Action
- (IBAction)wifiConnect:(id)sender {
    
    if (!_is_configure) {
        _is_configure = YES;
        _connect_router = NO;
        _connectRouterLabel.hidden = YES;

        _confResultView.hidden = YES;
        _retryView.hidden = YES;

        _confView.hidden = NO;
        [_configProgressView initWiFiConfigStatu];
        
        struct len_str str_param = {0, nil};
        
        const char *routeAddress = [[self routerIp] UTF8String];
        const char *wifiName = [self.wifiNameTextField.text UTF8String];
        const char *wifiPassword = [self.wifiPasswordTextField.text UTF8String];
        const char *deviceID = [self.deviceID UTF8String];
        const char *langs = [self.langString UTF8String];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
        struct json_object *obj_con = json_create_object(NULL, 0, NULL);
        
        struct json_object *obj_sn = json_create_string(obj_con, strlen("sn"), "sn", strlen(deviceID), (char *)deviceID);
        struct json_object *obj_l = json_create_string(obj_con, strlen("l"), "l", strlen(langs), (char *)langs);
        struct json_object *obj_s = json_create_string(obj_con, strlen("s"), "s", strlen(wifiName), (char *)wifiName);
        struct json_object *obj_p = json_create_string(obj_con, strlen("p"), "p", strlen(wifiPassword), (char *)wifiPassword);
        
        unsigned long buf_size = 20480;
        char *buf_con = malloc(buf_size);
        json_encode(obj_con, buf_con, buf_size);
        
        struct json_object *obj_param = json_create_object(NULL, 0, NULL);
        
        struct json_object *obj_dst = json_create_string(obj_param, strlen("dst"), "dst", strlen(routeAddress), (char *)routeAddress);
        struct json_object *obj_content = json_create_string(obj_param, strlen("content"), "content", strlen(buf_con), buf_con);
        if (self.app.developerOption.wifiSpeed) {
            const char *speed = [NSString stringWithFormat:@"%ld",self.app.developerOption.wifiSpeed].UTF8String;
            struct json_object *obj_speed = json_create_string(obj_param, strlen("speed"), "speed", strlen(speed), (char*)speed);
        } else {
            struct json_object *obj_speed = json_create_string(obj_param, strlen("speed"), "speed", strlen("1024000"), "1024000");
        }
        if (self.app.developerOption.magic_loop_segs) {
            const char *loop_segs = [NSString stringWithFormat:@"%ld",self.app.developerOption.magic_loop_segs].UTF8String;
            struct json_object *obj_loop_segs = json_create_string(obj_param, strlen("magic_loop_segs"), "magic_loop_segs", strlen(loop_segs), (char*)loop_segs);
        } else {
            struct json_object *obj_loop_segs = json_create_string(obj_param, strlen("magic_loop_segs"), "magic_loop_segs", strlen("0"), "0");
        }
        if (self.app.developerOption.start_magic_counts) {
            const char *start_counts = [NSString stringWithFormat:@"%ld",self.app.developerOption.start_magic_counts].UTF8String;
            struct json_object *obj_start_counts = json_create_string(obj_param, strlen("start_magic_counts"), "start_magic_counts", strlen(start_counts), (char*)start_counts);
        } else {
            struct json_object *obj_start_counts = json_create_string(obj_param, strlen("start_magic_counts"), "start_magic_counts", strlen("8"), "8");
        }
        
        char *buf_param = malloc(buf_size);
        json_encode(obj_param, buf_param, buf_size);
        
        str_param.data = buf_param;
        str_param.len = strlen(buf_param);
#pragma clang diagnostic pop
        
        //mfsk sounds connect wifi
        if (_pcm_buf) {
            free(_pcm_buf);
            _pcm_buf = NULL;
        }
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
        } else if (_sncf.length) {
            if ([_sncf rangeOfString:@"r"].length) {
                struct mfsk param = {0};
                param.freqhigh = _sncf.length > 4 ? [[_sncf substringWithRange:NSMakeRange(3,2)] intValue]*100 : 3300;
                param.freqlow = _sncf.length > 4 ? [[_sncf substringWithRange:NSMakeRange(1,2)] intValue]*100 : 1600;
                param.trans_mode = 1;
                _pcm_len = mfsk_encode_to_pcm(&param, _pcm_buf, buf_len, buf_con);
            } else {
                struct mfsk param = {0};
                param.freqhigh = _sncf.length > 3 ? [[_sncf substringWithRange:NSMakeRange(2,2)] intValue]*100 : 2300;
                param.freqlow = _sncf.length > 3 ? [[_sncf substringWithRange:NSMakeRange(0,2)] intValue]*100 : 1600;
                _pcm_len = mfsk_encode_to_pcm(&param, _pcm_buf, buf_len, buf_con);
            }
        } else {
            _pcm_len = mfsk_encode_to_pcm(NULL, _pcm_buf, buf_len, buf_con);
        }
        
        //sound configue
        if (_snc && !_soundConfView.hidden &&_pcm_len) {
            //add OpenAl
            _testOpen = [[MNOpenAlDecode alloc] init];
            [_testOpen initOpenAl];
            [_testOpen openAudio:_pcm_buf length:(unsigned int)(_pcm_len+EMPTY_PCM_LENGTH)];
            [_testOpen playSound];
        }
        _soundButton.selected = YES;

        //qrcode configue
        if (_qrc) {
            //QRCode configure
            _QRCodeImage.image = [QRCodeGenerator qrImageForString:[NSString stringWithUTF8String:buf_con] imageSize:_QRCodeImage.frame.size.width];
        }
        //wifi configure
        if (_wfc) {
            cb = mwfc_client_create(&str_param);
            NSLog(@"wfc");
        }
        
        [self checkDeviceLink];
        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeOutStop:) userInfo:nil repeats:YES];
    }
    else{
        if (self.app.isLoginByID)
        {
            if (self.is_loginModify)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                for (UIViewController *controller in self.navigationController.viewControllers)
                {
                    if ([controller isKindOfClass:[MNLoginViewController class]])
                    {
                        ((MNLoginViewController *)controller).lblStatus.text = NSLocalizedString(@"mcs_state_device_online",nil);
                        ((MNLoginViewController *)controller).lblStatus.hidden = NO;
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }
            }
            
        } else
        {
            for (UIViewController *controller in self.navigationController.viewControllers)
            {
                if ([controller isKindOfClass:[MNAddDeviceViewController class]])
                {
                    [((MNAddDeviceViewController *)controller).addDeviceButton setTitle:NSLocalizedString(@"mcs_action_add", nil) forState:UIControlStateNormal];
                    [(MNAddDeviceViewController *)controller updateConstraint];
                    ((MNAddDeviceViewController *)controller).is_add = YES;
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
        }
    }
}

- (IBAction)soundControl:(id)sender
{
    if (_testOpen == nil && _pcm_len) {
        _testOpen = [[MNOpenAlDecode alloc] init];
        [_testOpen initOpenAl];
        [_testOpen openAudio:_pcm_buf length:(unsigned int)(_pcm_len+EMPTY_PCM_LENGTH)];
        [_testOpen playSound];
        _soundButton.selected = YES;
    }
    else
    {
        [_testOpen stopSound];
        [_testOpen clearOpenAL];
        _testOpen = nil;
        _soundButton.selected = NO;
    }
}

- (IBAction)selectNormaConflStyle:(id)sender
{
    
    if (_is_selectNormal) {
        return;
    }
    _is_selectNormal = YES;
    [self refreshTabbarColor];
    if (!_connect_router) {
        _soundConfView.hidden = _snc ? NO : YES;
    }
    if (!_timeOutTimer && _gifWebView.hidden) {
        [self wifiConnect:nil];
    } else {
        if (_snc && !_connect_router && _soundButton.selected &&_pcm_len) {
            _testOpen = [[MNOpenAlDecode alloc] init];
            [_testOpen initOpenAl];
            [_testOpen openAudio:_pcm_buf length:(unsigned int)(_pcm_len+EMPTY_PCM_LENGTH)];
            [_testOpen playSound];
        }
    }
    _QRCodeImage.hidden = YES;
    _QRCodeBgImage.hidden = YES;
    _qrPromptLabel.hidden = YES;
    _qrcodePromptView.hidden = YES;
    _gifWebView.hidden = NO;
}

- (IBAction)selectQRConfStyle:(id)sender
{
    if (!_is_selectNormal) {
        return;
    }
    _is_selectNormal = NO;
    [self refreshTabbarColor];

    _soundConfView.hidden = YES;
    if (!_timeOutTimer && _QRCodeImage.hidden) {
        [self wifiConnect:nil];
    } else {
        if (_testOpen) {
            [_testOpen stopSound];
            [_testOpen clearOpenAL];
            _testOpen = nil;
        }
    }
    _QRCodeImage.hidden = NO;
    _QRCodeBgImage.hidden = NO;
    if (!_connect_router) {
        _qrPromptLabel.hidden = NO;
        _qrcodePromptView.hidden = NO;
    }
    _gifWebView.hidden = YES;
}

- (IBAction)toGuideVC:(id)sender
{
    UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
    MNDeviceGuideViewController *deviceGuideViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceGuideViewController"];
    deviceGuideViewController.deviceID = _deviceID;
    [self.navigationController pushViewController:deviceGuideViewController animated:YES];
}

- (IBAction)closePrompt:(id)sender
{
    [_qrcodePromptView removeFromSuperview];
    _qrcodePromptView = nil;
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

#pragma mark - TimerAction
- (void)checkDeviceLink
{
    unsigned char encrypt_pwd[16] = {0};
    [mipc_agent passwd_encrypt:PASSWORD_FORCHECK encrypt_pwd:encrypt_pwd];
    if (self.app.isLoginByID) {
        mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
        ctx.sn = _deviceID;
        ctx.passwd = encrypt_pwd;
        ctx.user = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(sign_in_done:);
        
        [self.agent sign_in:ctx];
    }
    else
    {
        mcall_ctx_dev_add *ctx = [[mcall_ctx_dev_add alloc] init];
        ctx.sn = _deviceID;
        ctx.passwd = encrypt_pwd;
        ctx.target = self;
        ctx.on_event = @selector(dev_add_done:);
        
        [self.agent dev_add:ctx];
    }
}

- (void)timeOutStop:(NSTimer *)timer
{
    if (_countdown == COUNTDOWM_TIME) {
        self.progressView.progress = 1.0;
    }
    _countdown--;
    _countLabel.text = [NSString stringWithFormat:@"%lds",_countdown];
    self.progressView.progress -= (1.0 / COUNTDOWM_TIME);
    self.circleViewTrailing.constant = (self.progressView.progress - 1) * self.progressView.frame.size.width + 9;
    self.countLabel.center = self.progressImgView.center;

    if (_countdown > 0.0) {
        if (self.connect_router) {
            [_configProgressView startConnectServer];
        } else {
            [_configProgressView startConnectRouter];
        }
    }
    if (!self.connect_router && !(_countdown%3)) {
        //Check Lan Device
        [self searchLANDevice];
    }
    if (_countdown <= 0) {
        _is_configure = NO;
        _countdown = COUNTDOWM_TIME;
        _countLabel.text = [NSString stringWithFormat:@"%lds",_countdown];
        if (_timeOutTimer) {
            [_timeOutTimer invalidate];
            _timeOutTimer = nil;
        }
        
        _confResultView.hidden = NO;
        _resultPromptLabel.text =  [NSString stringWithFormat:NSLocalizedString(@"mcs_failure_prompt", nil)];
        if (_resultPromptLabel.text.length > 90) {
            [_resultPromptLabel setFont:[UIFont systemFontOfSize:12.0]];
        }
        _retryView.hidden = NO;
        _confView.hidden = YES;
        
        mwfc_client_destroy(cb);
        [_testOpen stopSound];
        [_testOpen clearOpenAL];
        _testOpen = nil;
    }
}
- (void)connectSuccess
{
    if (self.app.isLoginByID)
    {
        if (self.is_loginModify)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            for (UIViewController *controller in self.navigationController.viewControllers)
            {
                if ([controller isKindOfClass:[MNLoginViewController class]])
                {
                    ((MNLoginViewController *)controller).lblStatus.text = NSLocalizedString(@"mcs_state_device_online",nil);
                    ((MNLoginViewController *)controller).lblStatus.hidden = NO;
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
        }
        
    }
    else
    {
        for (UIViewController *controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[MNAddDeviceViewController class]])
            {
                [((MNAddDeviceViewController *)controller).addDeviceButton setTitle:NSLocalizedString(@"mcs_action_add", nil) forState:UIControlStateNormal];
                [(MNAddDeviceViewController *)controller updateConstraint];
                ((MNAddDeviceViewController *)controller).is_add = YES;
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
    
}

#pragma mark - Call Back Done
- (void)dev_add_done:(mcall_ret_dev_add*)ret
{
//    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
    
    if ([ret.result isEqualToString:@"ret.pwd.invalid"] && _timeOutTimer)
    {
//        MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaViours.dev_add_wfc_succ_times += 1;
//        BOOL isRight = [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
        
        _confResultView.hidden = YES;
        _retryView.hidden = NO;
        _retryLabel.hidden = YES;
        [_retryButton setImage:[UIImage imageNamed:self.app.is_vimtag ? @"vt_connect_wifi_success.png" : (self.app.is_mipc ? @"mi_connect_wifi_success.png" : @"connect_wifi_success.png")] forState:UIControlStateNormal];
        _retryButton.enabled = NO;
        _failLabel.text = NSLocalizedString(@"mcs_wifi_config_success", nil);
        _confView.hidden = NO;
        [_configProgressView finishConnectServer];
        
        [self performSelector:@selector(connectSuccess) withObject:nil afterDelay:3.0];
        if (_timeOutTimer) {
            [_timeOutTimer invalidate];
            _timeOutTimer = nil;
        }
        
        mwfc_client_destroy(cb);
    }
    else if(_timeOutTimer)
    {
//        MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaViours.dev_add_wfc_fail_times += 1;
//        BOOL isRight = [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
        
        if ([ret.result isEqualToString:@"ret.nid.invalid"]) {
            [self performSelector:@selector(checkDeviceLink) withObject:nil afterDelay:5.0];
        } else {
            [self performSelector:@selector(checkDeviceLink) withObject:nil afterDelay:3.0];
        }
    }
}

- (void)sign_in_done:(mcall_ret_sign_in*)ret
{
//    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
    
    if ([ret.result isEqualToString:@"ret.pwd.invalid"] && _timeOutTimer)
    {
        //is jump, auto login
        if (self.app.is_jump && self.app.isLoginByID) {
            [mipc_agent passwd_encrypt:@"admin" encrypt_pwd:_encrypt_pwd];
            
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
//            MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//            behaViours.dev_add_wfc_succ_times += 1;
//            BOOL isRight = [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
            _confResultView.hidden = YES;
            _retryView.hidden = NO;
            _retryLabel.hidden = YES;
            [_retryButton setImage:[UIImage imageNamed:self.app.is_vimtag ? @"vt_connect_wifi_success.png" : (self.app.is_mipc ? @"mi_connect_wifi_success.png" : @"connect_wifi_success.png")] forState:UIControlStateNormal];
            _retryButton.enabled = NO;
            _failLabel.text = NSLocalizedString(@"mcs_wifi_config_success", nil);
            _confView.hidden = NO;
            [_configProgressView finishConnectServer];

            [self performSelector:@selector(connectSuccess) withObject:nil afterDelay:3.0];

            if (_timeOutTimer) {
                [_timeOutTimer invalidate];
                _timeOutTimer = nil;
            }
            mwfc_client_destroy(cb);
        }
    }
    else if (self.app.is_jump && self.app.is_jump && nil == ret.result)
    {
        mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
        ctx.target = self;
        ctx.on_event = @selector(devs_refresh_done:);
        
        [self.agent devs_refresh:ctx];
    }
    else if(_timeOutTimer)
    {
//        MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaViours.dev_add_wfc_fail_times += 1;
//        BOOL isRight = [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
        
        if ([ret.result isEqualToString:@"ret.nid.invalid"]) {
            [self performSelector:@selector(checkDeviceLink) withObject:nil afterDelay:5.0];
        } else {
            [self performSelector:@selector(checkDeviceLink) withObject:nil afterDelay:3.0];
        }
    }
}

- (void)auto_sign_in_done:(mcall_ret_sign_in*)ret
{
    if (ret.result == nil) {
        mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
        ctx.target = self;
        ctx.on_event = @selector(devs_refresh_done:);
        
        [self.agent devs_refresh:ctx];
    }   
}

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

#pragma mark - UIAlertViewdelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *url = [self.app.fromTarget stringByAppendingString:@"://ret.dev.offline"];
    if (buttonIndex == 1 && url) {
        self.app.is_jump = NO;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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

#pragma mark - Refresh Tabbar Color
- (void)refreshTabbarColor
{
    _normalButton.selected = _is_selectNormal;
    _QRButton.selected = !_normalButton.selected;
    _wifiConnectLabel.highlighted = _normalButton.selected;
    _qrconnectLabel.highlighted = _QRButton.selected;
}

#pragma mark - Search LAN Device
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
        param.on_recv_json_msg = on_recv_json_msg_by_connect;
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

long on_recv_json_msg_by_connect( void *ref, struct len_str *msg_type, struct len_str *msg_json, struct sockaddr_in *remote_addrin )
{
    @try {
        MNWIFIConnectViewController *referSelf = (__bridge MNWIFIConnectViewController*)ref;
        
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
                    if ([dev.sn isEqualToString:referSelf.deviceID])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            referSelf.connect_router = YES;
                            [referSelf.configProgressView finishConnectRouter];
                            if (referSelf.testOpen) {
                                [referSelf soundControl:nil];
                            }
                            referSelf.connectRouterLabel.hidden = NO;
                            referSelf.soundConfView.hidden = YES;
                            referSelf.qrPromptLabel.hidden = YES;
                            
                        });
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"exception:%@", exception);
    } @finally {
        
    }
    
    return 0;
}

@end
