//
//  MNDiagnosisingViewController.m
//  mipci
//
//  Created by mining on 16/9/19.
//
//

#define DIAGNOSIS_SUCC      1
#define DIAGNOSIS_FAILED    2
#define DIAGNOSIS_CONTINUE  3
#define total_bytes_statistic_counts    3


#import "MNDiagnosisingViewController.h"
#import "MNDiagnosisResultViewController.h"
#import "MNUncaughtExceptionHandler.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "MIPCUtils.h"
#import "msg_download.h"
#import "string_ex.h"
#import "msock.h"
#import "mhttp_client.h"
#import "url.h"
#import "mthread.h"
#import "mme_ios.h"
#import "mios_core_frameworks.h"
#import "mipc_data_object.h"

@interface MNDiagnosisingViewController ()
{
    unsigned char login_encrypt_pwd[16];
    MMediaEngine    *_engine;
    long            _chl_id;
    long            _total_bytes[total_bytes_statistic_counts];
    unsigned long   _total_bytes_tick[total_bytes_statistic_counts];
    //jc's add code
    MMediaEngine    *_recordEngine;
    NSInteger       _playTimes;
    long            _lastVideoBytes;
}
@property (strong, nonatomic) mipc_agent  *diagnosisAgent;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) MNDiagnosisResult diagnosisResult;
@property (assign, nonatomic) BOOL isCheckPlay;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) long count;
@property (assign, nonatomic) BOOL isDiagnosising;

@end

@implementation MNDiagnosisingViewController

- (mipc_agent *)diagnosisAgent
{
    if (nil == _diagnosisAgent) {
        _diagnosisAgent = [[mipc_agent alloc] init];
    }
    return _diagnosisAgent;
}

- (AppDelegate *)app
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_network_diagnostic", nil);
    self.navigationItem.hidesBackButton = YES;
    
    _diagnosisingLabel.text = NSLocalizedString(@"mcs_network_diagnostic", nil);
    _diagnosisingPromptLabel.text = NSLocalizedString(@"mcs_diagnostic_process_prompt", nil);
    
    _diagnosisingWebView.userInteractionEnabled = NO;
    _diagnosisingWebView.scalesPageToFit = YES;
    _diagnosisingWebView.backgroundColor = [UIColor clearColor];
    _diagnosisingWebView.opaque = NO;
    
    _cancelDiagnosisButton.layer.cornerRadius = 4.0f;
    [_cancelDiagnosisButton setTitle:NSLocalizedString(@"mcs_stop_diagnosis", nil) forState:UIControlStateNormal];
    [_cancelDiagnosisButton addTarget:self action:@selector(cancelDiagnosis) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"gif" ofType:nil];
    NSString *gifDataPath = [NSString stringWithFormat:@"%@/diagnosising.gif",gifPath];
    NSData *gifData = [NSData dataWithContentsOfFile:gifDataPath];
    [self.diagnosisingWebView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    _isDiagnosising = YES;
    _isCheckPlay = NO;
    
    //Default result
    self.diagnosisResult = MNDiagnosisContinue;
    //Clean local cache
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmp_log = MIPC_GetFileFullPath(@"NetworkRequest");
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:tmp_log isDirectory:&isDirectory];
    if (isFileExist || isDirectory)
    {
        NSError *logError = nil;
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@",tmp_log] error:&logError];
        if (logError) {
            NSLog(@"download_url:timeout:%@", [logError localizedDescription]);
        }
    }
    
    switch (self.typeIndex) {
        case MNDiagnosisLoginFail:
            [self checkNetworkRequest];
            break;
        case MNDiagnosisPlayFail:
            [self checkNetworkRequest];
            _isCheckPlay = YES;
            break;
        case MNDiagnosisOther:
            [self checkNetworkRequest];
            _isCheckPlay = YES;
            break;
        default:
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _isDiagnosising = NO;
    [self mediaEndPlay];
}

#pragma mark - Action
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelDiagnosis
{
    [self mediaEndPlay];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)checkNetworkRequest
{
    NSString *userName = [NSString string];
    struct mipci_conf *conf = MIPC_ConfigLoad();
    
    if(conf && conf->user.len && (conf->password.len || conf->password_md5.len))
    {
        userName = [NSString stringWithUTF8String:(const char*) conf->user.data];
        memset(login_encrypt_pwd, 0, sizeof(login_encrypt_pwd));
        memcpy(login_encrypt_pwd, conf->password_md5.data, sizeof(login_encrypt_pwd));
    }
    else if ([[NSUserDefaults standardUserDefaults] stringForKey:@"t_a"].length && [[NSUserDefaults standardUserDefaults] stringForKey:@"t_p"].length)
    {
        userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"t_a"];
        NSString *passWord = [[NSUserDefaults standardUserDefaults] stringForKey:@"t_p"];
        [mipc_agent passwd_encrypt:passWord encrypt_pwd:login_encrypt_pwd];
    }
    else
    {
        userName = [NSString stringWithFormat:@"%@",@"lxl"];
        NSString *passWord = [NSString stringWithFormat:@"%@",@"123456"];
        [mipc_agent passwd_encrypt:passWord encrypt_pwd:login_encrypt_pwd];
    }
    //Start Save Log Flag
    self.app.startSaveLog = YES;
    
    mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
    ctx.srv = MIPC_SrvFix(@"");
    ctx.user = userName;
    ctx.passwd = login_encrypt_pwd;
    ctx.target = self;
    ctx.on_event = @selector(sign_in_account_done:);
    
    [self.diagnosisAgent local_sign_in:ctx switchMmq:NO];
}

#pragma mark - Callback
- (void)sign_in_account_done:(mcall_ret_sign_in*)ret
{
    if (!_isDiagnosising) {
        return;
    }
    
    if(nil == ret.result)
    {
        if (_isCheckPlay) {
            //Get account devs
            mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc]init];
            ctx.target = self;
            ctx.on_event = @selector(devs_refresh_done:);
            
            //get device list refresh
            [self.diagnosisAgent devs_refresh:ctx];
        } else {
            [self diagnosisResultReport:NO];
        }
        return;
    }
    [self diagnosisResultReport:YES];
}

-(void)devs_refresh_done:(mcall_ret_devs_refresh *)ret
{
    if (!_isDiagnosising) {
        return;
    }
    
    if (nil == ret.result) {
        //Check video play
        mdev_devs *devs = ret.devs;
        m_dev *dev;
        for (NSInteger i = 0; i < devs.counts; i++) {
            dev = [devs get_dev_by_index:i];
            if ([dev.status isEqualToString:@"Online"] && NSOrderedSame != [dev.type caseInsensitiveCompare:@"BOX"])
            {
                [self mediaBeginPlay:dev.sn];
                return;
            }
        }
    }
    [self diagnosisResultReport:YES];
}

- (void)play_done:(mcall_ret_play*)ret
{
    if (!_isDiagnosising) {
        return;
    }
    
    if(ret.result == nil && ret.url.length)
    {
        [self MIPC_EngineCreate:ret.url];
        return;
    }
    [self diagnosisResultReport:YES];
}

#pragma mark - Media Operation
- (void)mediaBeginPlay:(NSString *)deviceID
{
    mcall_ctx_play *ctx = [[mcall_ctx_play alloc] init];
    ctx.sn = deviceID;
    ctx.target = self;
    //
    ctx.on_event = @selector(play_done:);
    
    ctx.token = @"p0";
    ctx.protocol = @"rtdp";
    [self.diagnosisAgent play:ctx];
}

- (void)mediaEndPlay
{
    //End Save Log Flag
    self.app.startSaveLog = NO;
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    if(_engine)
    {
        if(_chl_id > 0)
        {
            [_engine chl_destroy:_chl_id];
            _chl_id = 0;
        }
        [_engine engine_destroy];
        [_engine removeFromSuperview];
        _engine = nil;
    }
}

#pragma mark Engine create
- (void)MIPC_EngineCreate:(NSString*)url
{
    if(nil != _engine)
    {
        _engine = nil;
    }
    _engine = [[MMediaEngine alloc] initWithFrame:self.view.bounds];
    
    NSString *engineKey = MIPC_GetEngineKey();
    if([_engine engine_create:engineKey refer:self onEvent:@selector(onMediaEvent:)])
    {
        [self writeVideoPlayMessage:[NSString stringWithFormat:@"Create engine fail."]];
        [self mediaEndPlay];
        [self diagnosisResultReport:YES];
    }
    else
    {
        struct mipci_conf *conf = MIPC_ConfigLoad();
        NSString   *live_flow_ctrl = [NSString stringWithFormat:@"flow_ctrl:\"jitter\",jitter:{max:%d}",(conf && 0 != conf->buf)?conf->buf:3000];
        NSString   *params = [NSString stringWithFormat:@"{src:[{url:\"%@\"}], dst:[{url:\"data:/\",thread:\"istream\"}],trans:[{%@,thread:\"istream\"}],pic:{position:\"fit\"},speaker:{mute:%d}, thread:\"channel\"}", url, live_flow_ctrl, 1];   //?
        //        memset(_total_bytes, 0, sizeof(_total_bytes));
        //        memset(_total_bytes_tick, 0, sizeof(_total_bytes_tick));
        
        if(0 >= (_chl_id = [_engine chl_create:params]))
        {
            [self writeVideoPlayMessage:[NSString stringWithFormat:@"Create chl_id fail."]];
            [self mediaEndPlay];
            [self diagnosisResultReport:YES];
        }
        else
        {
            NSLog(@"media engine create succeed and chl-create.");
            _count = 0;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(networkSpeedStatus:) userInfo:_engine  repeats:YES];
        }
    }
}

- (void)writeVideoPlayMessage:(NSString* )content
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormat stringFromDate:[NSDate date]];
    NSString *requestUrl = [currentDateStr stringByAppendingFormat:@"%@, %@, %@", @"Video----->", content, @"\r\n"];
    
    NSString *networkRequestPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"NetworkRequest/NetworkRequest.txt"];

    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:networkRequestPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[requestUrl dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}

- (long)onMediaEvent:(MMediaEngineEvent *)evt
{
    return 0;
}

- (void)networkSpeedStatus:(NSTimer *)timer
{
    _count++;
    if(_engine && _chl_id)
    {
        @try{
            MMediaEngineEvent *evt = [_engine ctrl:_chl_id method:@"query" params:@"{}"];
            if(evt)
            {
                NSString            *data = evt.data;
                
//                NSLog(@"%@",data);
                
                struct json_object  *obj = json_decode([data length], (char*)[data UTF8String]);
                long               video_bytes = 0, is_buffering = 0, buffer_percent = 0, is_p2ping = 0, played_duration = 0;
//                unsigned long       tick = mtime_tick();
                json_get_child_long(obj, "buffering", &is_buffering);
                json_get_child_long(obj, "buffer_percent", &buffer_percent);
                json_get_child_long(obj, "p2ping", &is_p2ping);
                json_get_child_long(obj, "played_duration", &played_duration);
                json_get_child_long(obj, "video_bytes", &video_bytes);
//                NSLog(@"video bytes:%ld",video_bytes);
                [self writeVideoPlayMessage:[NSString stringWithFormat:@"video bytes:%ld", video_bytes]];
                if ((video_bytes - _lastVideoBytes ) > 80 * 1024)
                {
                    _playTimes = 0;
                }
                else if((video_bytes - _lastVideoBytes) < 10 * 1024)
                {
                    _playTimes ++;
                }
                
                _lastVideoBytes = video_bytes;

                //Stop video play
                if (_count >= 120) {
                    [self mediaEndPlay];
                    [self diagnosisResultReport:_playTimes > 60 ? YES : NO];
                }
            }
        }
        @catch (NSException *e){
            //Exception catch
            
            NSLog(@"%@~%@",e.name,e.reason);
            [self mediaEndPlay];
            [self diagnosisResultReport:YES];
        }
    }
}

#pragma mark - Diagnosis Report
- (void)diagnosisResultReport:(BOOL)isFault
{
    //End Save Log Flag
    self.app.startSaveLog = NO;
    
    if (isFault)
    {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"NetworkRequest/NetworkRequest.txt"]];
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        NSString *log = [NSString stringWithContentsOfFile:filePath usedEncoding:nil error:nil];
        [fileHandle closeFile];
        mcall_ctx_log_reg *ctx = [[mcall_ctx_log_reg alloc] init];
        ctx.target = self;
        ctx.mode = [MNUncaughtExceptionHandler getCurrentDeviceModel];
        ctx.exception_name = @"ios_request_log";
        ctx.exception_reason = self.diagnosisProblem;
        ctx.call_stack = log;
        ctx.log_type = @"ios_request_log";
        ctx.on_event = @selector(log_req_done:);
        [self.diagnosisAgent log_req:ctx];
    }
    else
    {
        //Clean local cache
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *tmp_log = MIPC_GetFileFullPath(@"NetworkRequest");
        BOOL isDirectory;
        BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:tmp_log isDirectory:&isDirectory];
        if (isFileExist || isDirectory)
        {
            NSError *logError = nil;
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@",tmp_log] error:&logError];
            if (logError) {
                NSLog(@"download_url:timeout:%@", [logError localizedDescription]);
            }
        }
        
        self.diagnosisResult = MNDiagnosisContinue;
        [self performSegueWithIdentifier:@"MNDiagnosisResultViewController" sender:nil];
    }
    
//    //test
//    mcall_ret_log_reg *ret = [[mcall_ret_log_reg alloc] init];
//    ret.result = @"123";
//    [self log_req_done:ret];
}

- (void)log_req_done:(mcall_ret_log_reg *)ret
{
    if (nil == ret.result) {
        //Clean local cache
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *tmp_log = MIPC_GetFileFullPath(@"NetworkRequest");
        BOOL isDirectory;
        BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:tmp_log isDirectory:&isDirectory];
        if (isFileExist || isDirectory)
        {
            NSError *logError = nil;
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@",tmp_log] error:&logError];
            if (logError) {
                NSLog(@"download_url:timeout:%@", [logError localizedDescription]);
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.diagnosisResult = (nil == ret.result ? MNDiagnosisSuccess : MNDiagnosisFailed);
        [self performSegueWithIdentifier:@"MNDiagnosisResultViewController" sender:nil];
    });
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNDiagnosisResultViewController"]) {
        MNDiagnosisResultViewController *diagnosisResultViewController = segue.destinationViewController;
        diagnosisResultViewController.diagnosisResult = self.diagnosisResult;
        diagnosisResultViewController.diagnosisProblem = self.diagnosisProblem;
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

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIApplication sharedApplication].statusBarOrientation;
    }
    else
    {
        return UIInterfaceOrientationPortrait;
    }
}

@end
