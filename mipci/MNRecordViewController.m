//
//  RecordViewController.m
//  mipci
//
//  Created by mining on 13-11-13.
//
//

#import "MNRecordViewController.h"
#import "mme_ios.h"
#import "mcore/mcore.h"
#import "mme_ios.h"
#import "MIPCUtils.h"
#import "MNProgressView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LocalVideoInfo.h"
#import "AppDelegate.h"
#import "UIImageView+MNNetworking.h"
#import "MNCache.h"
#import "MNMessagePageViewController.h"
#import "MNInfoPromptView.h"

#import "msg_http.h"
#import "http_param.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

#define total_bytes_statistic_counts    3
#define one_trillion                    (1024.0*1024.0)
#define SHARE_TAG                       1001
#define DOWNLOAD_TAG                    1002
#define DOWNLOAD_NON_NETWORK_TAG        1003

@interface MNRecordViewController ()
{
    MMediaEngine    *_engine;
    long            _chl_id;
    long            _in_audio_outing;
    long            _chl_id_audio_out;
    long            _speaker_is_mute;
    long            _total_bytes[total_bytes_statistic_counts];
    unsigned long   _total_bytes_tick[total_bytes_statistic_counts];
    long            _last_speed_status;
    long            _progressCounts;
    long            _ptzMoveStepX;
    long            _ptzMoveStepY;
    int             _ctrl_play_check_counts;
    long            _onRecord;
    int             _isHandleRecord;
    CGFloat         _initialZoom;
    long            _active;
    BOOL            _isHid;
    long            _speedBytes;
    
    struct mhttp_module *module_handle;
    long            lastDuration;
}

@property (assign, nonatomic) BOOL isViewAppearing;
@property (nonatomic, strong) NSString *mp4FilePath;

@property (nonatomic) BOOL isDownloadOperation;
@property (nonatomic) BOOL isReplayOperation;
@property (nonatomic) double downloadDuration;
@property (weak, nonatomic) AppDelegate *app;

@property (strong, nonatomic) MNShareVideoWindow *shareVideoWindow;

//@property (strong, nonatomic) NSTimer *mhttp_timer;
@property (strong, nonatomic) NSString *http_conf_path;
@property (strong, nonatomic) NSString *ipAddress;
@property (strong, nonatomic) NSThread *mhttp_wait_thread;
@end

@implementation MNRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

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

-(NSThread *)mhttp_wait_thread
{
    if (nil == _mhttp_wait_thread) {
        _mhttp_wait_thread = [[NSThread alloc] initWithTarget:self selector:@selector(run_mhttp_wait) object:nil];
    }
    
    return _mhttp_wait_thread;
}

#pragma mark - View lifecycle
- (void)initUI
{
    self.extendedLayoutIncludesOpaqueBars = YES;

    CGRect rect = self.view.frame;
    
    if (_isLocalVideo) {
        if (self.app.is_vimtag) {
            [_downloadButton setImage:[UIImage imageNamed:@"vt_share.png"] forState:UIControlStateNormal];
        } else if (self.app.is_ebitcam) {
            [_downloadButton setImage:[UIImage imageNamed:@"eb_share.png"] forState:UIControlStateNormal];
        } else if (self.app.is_mipc) {
            [_downloadButton setImage:[UIImage imageNamed:@"mi_share.png"] forState:UIControlStateNormal];
        } else {
            [_downloadButton setImage:[UIImage imageNamed:@"vt_share.png"] forState:UIControlStateNormal];
        }
        
        _lblSpeedStatus.hidden = YES;
        [_actindStatusView stopAnimating];
    }

    self.videoImageView = [[UIImageView alloc] initWithFrame:rect];
    _videoImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_videoImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_videoImageView setUserInteractionEnabled:YES];

    _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height / 2 + 60, 24, 24)];
    [_voiceButton addTarget:self action:@selector(setSpeaker:) forControlEvents:UIControlEventTouchUpInside];
    if (self.app.is_vimtag)
    {
        [_voiceButton setImage:[UIImage imageNamed:@"vt_voice_off.png"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"vt_voice.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_luxcam)
    {
        [_voiceButton setImage:[UIImage imageNamed:@"voice_off.png"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"voice_on.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_ebitcam)
    {
        [_voiceButton setImage:[UIImage imageNamed:@"eb_sound_off.png"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"eb_sound_on.png"] forState:UIControlStateSelected];
    }
    else if (self.app.is_mipc)
    {
        [_voiceButton setImage:[UIImage imageNamed:@"mi_sound_off.png"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"mi_sound_on.png"] forState:UIControlStateSelected];
    }
    else
    {
        [_voiceButton setImage:[UIImage imageNamed:@"speaker_mute.png"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"speaker_on2.png"] forState:UIControlStateSelected];
    }
    [self.view addSubview:_voiceButton];
    _voiceButton.hidden = YES;
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_videoImageView.frame) / 2 - 64 / 2, CGRectGetHeight(_videoImageView.frame) / 2 - 64 / 2, 64, 64)];
    _playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    if (self.app.is_vimtag) {
        [_playButton setImage:[UIImage imageNamed:@"pu_play"] forState:UIControlStateNormal];
    } else {
        [_playButton setImage:[UIImage imageNamed:@"pu_play"] forState:UIControlStateNormal];
    }
    [_videoImageView addSubview:_playButton];
    
    _progressView = [[MNProgressView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_videoImageView.frame) / 2 - 64 / 2, CGRectGetHeight(_videoImageView.frame) / 2 - 64 / 2, 64, 64)];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    _progressView.userInteractionEnabled = YES;
    _progressView.hidden = YES;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(progressViewDismiss:)];
    [_progressView addGestureRecognizer:singleTapGestureRecognizer];
    
    [_videoImageView addSubview:_progressView];
    
    [self.view insertSubview:_videoImageView belowSubview:[self.view.subviews firstObject]];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _active = 1;
    _speaker_is_mute = 1;
    _voiceButton.selected = !_speaker_is_mute;
    _url = _localVideoInfo.mp4FilePath;
    [self checkFilePath];
    [self initUI];
    
    long long minute = [[[_msg.format_length componentsSeparatedByString:@":"] objectAtIndex:([_msg.format_length componentsSeparatedByString:@":"].count - 2)] longLongValue];
    long long second = [[[_msg.format_length componentsSeparatedByString:@":"] lastObject] longLongValue];
    self.totalDuration = minute * 60 + second;

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
    if ( _msg.local_thumb_img) {
        _videoImageView.image = _msg.local_thumb_img;
    }
    else
    {
        if (self.app.is_vimtag) {
            _videoImageView.image = [UIImage imageNamed:@"vt_cellBg.png"];
        }
        else if (self.app.is_ebitcam)
        {
            _videoImageView.image = [UIImage imageNamed:@"eb_cellBg.png"];
        }
        else if (self.app.is_mipc)
        {
            _videoImageView.image = [UIImage imageNamed:@"mi_cellBg.png"];
        }
        else
        {
            _videoImageView.image = [UIImage imageNamed:self.app.is_luxcam ? @"placeholder.png" : @"camera_placeholder.png"];
        }
    }

    if (_isLocalVideo) {
        _videoImageView.image = _localVideoInfo.image ? _localVideoInfo.image : self.app.is_vimtag ? [UIImage imageNamed:@"vt_cellBg.png"] : (self.app.is_ebitcam ? [UIImage imageNamed:@"eb_cellBg.png"]: (self.app.is_mipc ? [UIImage imageNamed:@"mi_cellBg.png"] : [UIImage imageNamed:self.app.is_luxcam ? @"placeholder.png" : @"camera_placeholder.png"]));
    }
    else if (_msg) {

        NSString *imagePath = [self localMessageRecordPathByMsgSn:_msg.sn withMsgImgToken:_msg.img_token];
        UIImage *image = [[[MNCache class] mn_sharedCache] objectForKey:imagePath];
        if(!image)
        {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
        
        if (image) {
            __strong __typeof(self)strongSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.videoImageView.image = image;
                [_actindStatusView stopAnimating];
            });
        }
        
        mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
        ctx.sn = _msg.sn;
//        ctx.target = self;
//        ctx.on_event = @selector(pic_get_done:);
        ctx.type = mdev_pic_album;
        ctx.token = _msg.img_token;
        
        m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];

//        [_actindStatusView startAnimating];
        __weak typeof(self) weakSelf = self;
        NSURL *downloadImageURL = [NSURL URLWithString:[self.agent pic_url_create:ctx]];
        [_videoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:downloadImageURL]
                               placeholderImage:nil
                                token:ctx.token
                                       deviceID:_deviceID
                                           flag:dev.spv
                                        success:^(NSURLRequest * request, NSHTTPURLResponse * response, UIImage * image, NSString *deviceID, NSString *token) {
                                            __strong typeof(weakSelf) strongSelf = weakSelf;
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [strongSelf.actindStatusView stopAnimating];
                                                if (image)
                                                {
                                                    strongSelf.videoImageView.image = image;
                                                }
                                            });
                                            NSString *imagePath = [weakSelf localMessageRecordPathByMsgSn:ctx.sn  withMsgImgToken:ctx.token];
                                            if (image && imagePath) {
                                                [[[MNCache class] mn_sharedCache] setObject:image forKey:imagePath];
                                            }
                                            [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath atomically:YES];
                                        }
                                        failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
                                            [weakSelf.actindStatusView stopAnimating];
                                        }];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(_toolbar)
    {
        [_toolbar removeFromSuperview];
        _toolbar = nil;
    }
    
    [self destroyHandle];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
    if (_isDownloading) {
        [self saveMp4ToLocalDirectory];
    }

    [self mediaEndPlay];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)play:(id)sender
{
    _isReplayOperation = YES;
    [_actindStatusView startAnimating];
    _downloadButton.hidden = YES;
    _isDownloadOperation = NO;
    _playButton.hidden = YES;
    if (_isLocalVideo) {
//        _lblSpeedStatus.hidden = YES;
//        _lblSpeed.hidden = YES;
        [self MIPC_EngineCreate:_url];
    }
    else{
        [self mediaBeginPlay];
    }
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

- (IBAction)download:(id)sender
{
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    NetworkStatus status = [self.app reachabilityChanged:nil];
    if (!_isLocalVideo) {
        if (ReachableViaWiFi == status)
        {
            [_playButton setHidden:YES];
            _progressView.progressValue = 0;
            [_progressView setHidden:NO];
            //        [sender setHidden:YES];
            _isDownloadOperation = YES;
            _isReplayOperation = NO;
            _downloadButton.hidden = YES;
            _voiceButton.hidden = YES;
            [_actindStatusView startAnimating];
            
            mcall_ctx_playback *ctx = [[mcall_ctx_playback alloc] init];
            ctx.sn = _msg.sn;
            ctx.token = _msg.record_token;
            ctx.protocol = @"rtdp";
            ctx.target = self;
            ctx.on_event = @selector(playback_done:);
            
            [self.agent playback:ctx];
            if (self.app.is_vimtag) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_record_prompt", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
            } else {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_record_download_prompt", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
            }
        }
        else if (ReachableViaWWAN == status)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString(@"mcs_download_video_prompt", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"mcs_continue", nil)
                                                      otherButtonTitles: NSLocalizedString(@"mcs_close", nil), nil];
            alertView.tag = DOWNLOAD_TAG;
            [alertView show];
        }
        else if (NotReachable == status)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:NSLocalizedString(@"mcs_available_network", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"mcs_settings", nil)
                                                      otherButtonTitles: NSLocalizedString(@"mcs_close", nil), nil];
            alertView.tag = DOWNLOAD_NON_NETWORK_TAG;
            [alertView show];
        }

    }
    else
    {
        if (ReachableViaWiFi == status)
        {
            BOOL successFlag = [self pendingLocalServer];
            
            if (successFlag) {
                if (_shareVideoWindow) {
                    _shareVideoWindow.hidden = NO;
                } else {
                    _shareVideoWindow = [[MNShareVideoWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    
                    __weak typeof(self) weakSelf = self;
                    [_shareVideoWindow closeWindowWithBlock:^{
                        [weakSelf.mhttp_wait_thread cancel];
                        [UIApplication sharedApplication].idleTimerDisabled = NO;
                    }];
                }
            } else {
                NSLog(@"share fail");
                [UIApplication sharedApplication].idleTimerDisabled = NO;
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"mcs_share_video_prompt", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_settings", nil)
                                                  otherButtonTitles: NSLocalizedString(@"mcs_close", nil), nil];
            alertView.tag = SHARE_TAG;
            [alertView show];
        }
    }
}



- (void)downloadMp4WithURL:(NSString *)url
{
    if(nil != _engine)
    {
        _engine = nil;
    }
    
    _engine = [[MMediaEngine alloc] initWithFrame:CGRectNull];
     NSString *engineKey = MIPC_GetEngineKey();
    long failed = [_engine engine_create:engineKey refer:self onEvent:nil];
    if (failed) {
        NSLog(@"engine_create failed");
        return;
    }
    
    //video connection
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *videoDirectory =[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@", _msg.sn]];
    
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:videoDirectory isDirectory:&isDirectory];
    if (!isFileExist || !isDirectory) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    NSString *mp4File = [_msg.sn stringByAppendingFormat:@"_%@.mp4", _msg.record_token];
    self.mp4FilePath = [videoDirectory stringByAppendingPathComponent:mp4File];
    
    NSString   *params = [NSString stringWithFormat:@"{src:[{url:\"%@\"}], dst:[{url:\"file://%@\",thread:\"channel\"}],speaker:{mute:1},audio:{type:\"none\"}, thread:\"channel\",canvas:\"none\"}", url, _mp4FilePath];
    
    if(0 >= (_chl_id = [_engine chl_create:params]))
    {
        NSLog(@"download failed");
    }
    else
    {
        _ctrl_play_check_counts = 0;
        _isDownloading = YES;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(networkSpeedStatus:) userInfo:_engine  repeats:YES];
    }
    
}
- (IBAction)handleSingleTap:(id)sender {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView animateWithDuration:.2f animations:^{
        BOOL isHid = self.navigationController.navigationBar.hidden;
        [self.navigationController setNavigationBarHidden:!isHid animated:YES];
        self.toolbar.hidden = !isHid;
        self.voiceButton.hidden = !isHid;
    }completion:^(BOOL finish){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
    }];
}

#pragma mark - save Mp4
- (void)saveMp4ToLocalDirectory
{
//    NSString *duration = [NSString stringWithFormat:@"%02d:%02d", (int)_downloadDuration/60, (int)fmod(_downloadDuration, 60)] ;
    
    LocalVideoInfo *videoInfo = [[LocalVideoInfo alloc] init];
    videoInfo.deviceId = _msg.sn;
    videoInfo.image = _msg.local_thumb_img;
 //   videoInfo.duration = duration;
    videoInfo.duration = _msg.format_length;
    videoInfo.mp4FilePath = _mp4FilePath;
    videoInfo.date = _msg.format_data;
    videoInfo.bigImageId = _msg.img_token;
    videoInfo.type = _msg.type;
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *videoDirectory =[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@", _msg.sn]];
    
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:videoDirectory isDirectory:&isDirectory];
    if (!isFileExist || !isDirectory) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    NSString *videoInfoPath = [videoDirectory stringByAppendingPathComponent:[_msg.sn stringByAppendingFormat:@"_%@.inf", _msg.record_token]];
    [NSKeyedArchiver archiveRootObject:videoInfo toFile:videoInfoPath];
    
    _downloadButton.hidden = NO;
     [UIApplication sharedApplication].idleTimerDisabled = NO;
}


#pragma mark - GestureRecognizer
- (void)progressViewDismiss:(UITapGestureRecognizer *)gestureRecognizer
{
    if (_progressView.progressValue >= 1.0) {
        gestureRecognizer.view.hidden = YES;
        _downloadButton.hidden = NO;
        _playButton.hidden = NO;
        _progressView.progressValue = 0;
    }
}

#pragma mark - playback_done
- (void)playback_done:(mcall_ret_playback *)ret
{
    if(nil == _toolbar)
    {
        [self createToolBar];
    }
    [_actindStatusView stopAnimating];
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil != ret.result) {
        _playButton.hidden = NO;
        return;
    }
    
    if (_isReplayOperation) {
        //record play
    
        [self MIPC_EngineCreate:ret.url];
        
    }
    else if (_isDownloadOperation)
    {
        [self downloadMp4WithURL:ret.url];
    }
    
}

- (void)pic_get_done:(mcall_ret_pic_get*)ret
{
    [_actindStatusView stopAnimating];
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil != ret.result) {
        return;
    }
    
    _videoImageView.image = ret.img;
}

#pragma mark -
- (void)createToolBar
{
    CGRect rect = self.navigationController.navigationBar.frame;
    CGFloat height = rect.origin.y + rect.size.height; //hiddened
    if (height < 1 )
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
        {
            height = 44.0;
        }
        else
        {
            height = 64.0;
        }
    }

    _toolbar = [[UIView alloc] initWithFrame:(CGRect){{0,height},{self.navigationController.view.bounds.size.width,25}}];
    
    _toolbar.backgroundColor = [UIColor clearColor];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
 
    [self.navigationController.view addSubview:_toolbar];

    
    _lblSpeed = [[UILabel alloc] initWithFrame:CGRectMake(self.navigationController.view.bounds.size.width- 77, 0, 77, 30)];
    _lblSpeed.textAlignment = NSTextAlignmentRight;
    _lblSpeedStatus = [[UILabel alloc] initWithFrame:CGRectMake(self.navigationController.view.bounds.size.width-90, 9.f, 12, 12)];
    _last_speed_status = 0;
    _lblSpeed.text = @"";
    _lblSpeed.textColor = [UIColor grayColor];
    _lblSpeed.backgroundColor = [UIColor clearColor];
    _lblSpeed.font = [UIFont systemFontOfSize:12];
    _lblSpeed.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    _lblSpeedStatus.backgroundColor = [UIColor redColor];
    _lblSpeedStatus.layer.cornerRadius = 6;
    _lblSpeedStatus.layer.masksToBounds = YES;
    _lblSpeedStatus.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [_toolbar addSubview:_lblSpeed];
    [_toolbar addSubview:_lblSpeedStatus];
    if (_isLocalVideo) {
        _lblSpeedStatus.hidden = YES;
    }
}

#pragma mark - Media
- (void)mediaBeginPlay
{
    mcall_ctx_playback *ctx = [[mcall_ctx_playback alloc] init];
    ctx.sn = _msg.sn;
    ctx.token = _msg.record_token;
    ctx.protocol = @"rtdp";
    ctx.target = self;
    ctx.on_event = @selector(playback_done:);
    
    [self.agent playback:ctx];
    
}

- (void)mediaEndPlay
{
//    if(_toolbar)
//    {
//        [_toolbar removeFromSuperview];
//        _toolbar = nil;
//    }
    
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
    _downloadButton.hidden = NO;
    _playButton.hidden = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark - MIPC_EngineCreate
- (void)MIPC_EngineCreate:(NSString *)url
{
    _engine = [[MMediaEngine alloc] initWithFrame:self.view.frame];
    _engine.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_engine atIndex:0];
    
    NSString *engineKey =  MIPC_GetEngineKey();
    if([_engine engine_create:engineKey refer:self onEvent:@selector(onMediaEvent:)])
    {
        [self mediaEndPlay];
    }
    else
    {
        struct mipci_conf *conf = MIPC_ConfigLoad();
        NSString   *replay_flow_ctrl = [NSString stringWithFormat:@"flow_ctrl:\"delay\",delay:{buf:{min:%d}}",(conf && 0 != conf->buf)?conf->buf:1000];
        
        NSString   *urlparams = [NSString stringWithFormat:@"{src:[{url:\"%@\"}], dst:[{url:\"data:/\",thread:\"istream\"}],trans:[{%@,thread:\"istream\"}],speaker:{mute:%ld}, thread:\"channel\"}", url, replay_flow_ctrl, _speaker_is_mute];
        
        NSString   *fileparams = [NSString stringWithFormat:@"{src:[{url:\"file:/%@\"}], dst:[{url:\"data:/\",thread:\"istream\"}],trans:[{thread:\"istream\"}],speaker:{mute:%ld}, thread:\"channel\"}", url,  _speaker_is_mute];
        memset(_total_bytes, 0, sizeof(_total_bytes));
        memset(_total_bytes_tick, 0, sizeof(_total_bytes_tick));
        if(0 >= (_chl_id = [_engine chl_create:  _isLocalVideo ? fileparams:urlparams]))
        {
            [self mediaEndPlay];
        }
        else
        {
            NSLog(@"media engine create succeed and chl-create.");
            _ctrl_play_check_counts = 0;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(networkSpeedStatus:) userInfo:_engine  repeats:YES];
        }
    }
}

- (void)resignActive:(NSNotification*)notification
{
    if(_engine)
    {
        //replay the video
        [self mediaEndPlay];
        _isReplayOperation = NO;
        [_actindStatusView stopAnimating];
        _downloadButton.hidden = NO;
        _isDownloadOperation = NO;
        _playButton.hidden = NO;
        _voiceButton.hidden = YES;
        [_videoImageView setHidden:NO];
        _toolbar.hidden = YES;
        _lblSpeed.text = nil;
    }
    [self mediaEndPlay];
    
    [self.mhttp_wait_thread cancel];
    if (_shareVideoWindow) {
        _shareVideoWindow.hidden = YES;
    }
}

- (void)networkSpeedStatus:(NSTimer *)timer
{
    if(_chl_id && _engine)
    {
        MMediaEngineEvent *evt = [_engine ctrl:_chl_id method:@"query" params:@"{}"];
        //hold replay
        [_engine ctrl:_chl_id method:@"play"  params:@"{}"];
        
        if(evt)
        {
            NSString            *data = evt.data;
            struct json_object  *obj = json_decode([data length], (char*)[data UTF8String]);
            long                speed_bytes, total_bytes = 0, is_buffering = 0, buffer_percent = 0, is_p2ping = 0, played_duration = 0;
            unsigned long       tick = mtime_tick();
            
            json_get_child_long(obj, "buffering", &is_buffering);
            json_get_child_long(obj, "buffer_percent", &buffer_percent);
            json_get_child_long(obj, "p2ping", &is_p2ping);
            json_get_child_long(obj, "played_duration", &played_duration);
            
            if (_isLocalVideo && lastDuration != 0 && lastDuration == played_duration)
            {
                //replay the video
                [self mediaEndPlay];
                _isReplayOperation = NO;
                [_actindStatusView stopAnimating];
                _downloadButton.hidden = NO;
                _isDownloadOperation = NO;
                _playButton.hidden = NO;
                _voiceButton.hidden = YES;
                [_videoImageView setHidden:NO];
                _toolbar.hidden = YES;
                _lblSpeed.text = nil;

                return;
            }
            NSLog(@"%ld",played_duration);
            lastDuration = played_duration;
            
            if(0 == json_get_child_long(obj, "total_bytes", &total_bytes))
            {
                long new_status, sub_bytes = total_bytes - _total_bytes[0];
                speed_bytes = (sub_bytes * 1000)/((_total_bytes_tick[0] && (tick != _total_bytes_tick[0]))?(tick - _total_bytes_tick[0]):1000);
                new_status = (speed_bytes * 3) / (40*1024);
                
                /*downloading*/
                if (!_isLocalVideo && _isDownloading) {
                    _downloadDuration = played_duration / 1000.0;
                    double persent = ((double)played_duration)/1000.0/_totalDuration;
                    if (persent > 1.0 || (speed_bytes == 0 && ((_totalDuration * 1000.0 - played_duration) < 300))) {
                        persent = 1.0;
                        //                        [self.downLoadButton setHidden:NO];
                        _isDownloading = NO;
                        [self mediaEndPlay];
                        [self saveMp4ToLocalDirectory];
                    }
                    _progressView.progressValue = persent;
                }
                else if (!_isLocalVideo) {
                    if (((double)played_duration)/1000.0/_totalDuration > 1.0 || (speed_bytes == 0 && ((_totalDuration * 1000.0 - played_duration) < 300))) {
                        [self mediaEndPlay];
                        _isReplayOperation = NO;
                        [_actindStatusView stopAnimating];
                        _downloadButton.hidden = NO;
                        _isDownloadOperation = NO;
                        _playButton.hidden = NO;
                        _videoImageView.hidden = NO;
                        
                        return;
                    }
                }
                
                if(is_buffering
                   && buffer_percent && speed_bytes/* \todo:kugle xxxxxxxxxx, just for unknown ending, if 0 maybe ending */)
                {
                    _lblSpeed.text = [NSString stringWithFormat:@"%ld%%", buffer_percent];
                    // [self startProgress];
                }
                else
                {
                    NSString    *nsDuration = @"";
                     long        duration_sec = played_duration / 1000;
                     if(duration_sec < 60)
                     {
                     nsDuration = [NSString stringWithFormat:@"(0:%ld)", duration_sec];
                     }
                     else if(duration_sec < (60*60))
                     {
                     nsDuration = [NSString stringWithFormat:@"(%ld:%ld)", duration_sec/60, duration_sec % 60];
                     }
                     else
                     {
                     nsDuration = [NSString stringWithFormat:@"(%ld:%ld:%ld)", duration_sec/3600, (duration_sec % 3600)/60, duration_sec % 60];
                     }
                    
                    if (_isLocalVideo) {
                        _lblSpeed.hidden = NO;
                        _lblSpeed.text =  nsDuration;
                    } else {
                        _lblSpeed.text = [NSString stringWithFormat:@"%@%ld%@B", nsDuration, speed_bytes/1024, is_p2ping?@"k":@"K"];
                    }
                }

                if (_lblSpeed.text.length < 5) {
                    _lblSpeed.frame = CGRectMake(self.navigationController.view.bounds.size.width- 30, 0, 30, 30);
                    _lblSpeedStatus.frame = CGRectMake(self.navigationController.view.bounds.size.width-45, 9.f, 12, 12);
                }
                else if (_lblSpeed.text.length < 11)
                {
                    _lblSpeed.frame = CGRectMake(self.navigationController.view.bounds.size.width- 70, 0, 70, 30);
                    _lblSpeedStatus.frame = CGRectMake(self.navigationController.view.bounds.size.width-75, 9.f, 12, 12);
                }
                else
                {
                    _lblSpeed.frame = CGRectMake(self.navigationController.view.bounds.size.width- 77, 0, 77, 30);
                    _lblSpeedStatus.frame = CGRectMake(self.navigationController.view.bounds.size.width-90, 9.f, 12, 12);
                }
                
                if(new_status != _last_speed_status)
                {
                    UIColor *colors[] = {[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor]};
                    _lblSpeedStatus.backgroundColor = colors[(new_status < (sizeof(colors)/sizeof(colors[0])))?new_status:((sizeof(colors)/sizeof(colors[0])) - 1)];
                    _last_speed_status = new_status;
                }
                
                if((0 == _total_bytes_tick) || (0 == _total_bytes))
                {
                    for(long i = 0; i < (sizeof(_total_bytes_tick)/sizeof(_total_bytes_tick[0])); ++i)
                    {
                        _total_bytes_tick[i] = tick;
                        _total_bytes[i] = total_bytes;
                    }
                }
                else
                {
                    for(long i = 1; i < (sizeof(_total_bytes_tick)/sizeof(_total_bytes_tick[0])); ++i)
                    {
                        _total_bytes_tick[i - 1] = _total_bytes_tick[i];
                        _total_bytes[i - i] = _total_bytes[i];
                    }
                    _total_bytes_tick[(sizeof(_total_bytes_tick)/sizeof(_total_bytes_tick[0])) - 1] = tick;
                    _total_bytes[(sizeof(_total_bytes_tick)/sizeof(_total_bytes_tick[0])) - 1] = total_bytes;
                }
            }
            //[evt release];
        }
    }
    else
    {
        [self mediaEndPlay];
    }
}

- (long)onMediaEvent:(MMediaEngineEvent *)evt
{
    if(!_active) return 0;
    NSLog(@"onMediaEvent(evt[%p{type[%@],code[%@],chl_id[%ld]}].", evt, evt.type, evt.code, evt.chl_id);
    if(evt
       && evt.type && [evt.type isEqualToString:@"link"]
       && evt.code && [evt.code isEqualToString:@"active"]
       && evt.data && (evt.data.length > 0) && (0 <= strstr([evt.data UTF8String], "video")))
    {
        [self performSelectorOnMainThread:@selector(onVideoArrived:) withObject:nil waitUntilDone:NO];
    }
    if(evt && evt.type && [evt.type isEqualToString:@"close"])
    {
        if(evt.chl_id == _chl_id)
        {
            NSLog(@"play chl[%ld] be closed.", _chl_id);
            _chl_id = 0;
        }
        else if(evt.chl_id == _chl_id_audio_out)
        {
            NSLog(@"audio out chl[%ld] be closed.", _chl_id_audio_out);
            _chl_id_audio_out = 0;
            _in_audio_outing = 0;
        }
    }
    return 0;
}

- (void)onVideoArrived:(id)sender
{
    if(nil == _toolbar)
    {
        [self createToolBar];
    } else {
        _toolbar.hidden = NO;
    }
    
    _voiceButton.hidden = NO;
    _videoImageView.hidden = YES;
    [_actindStatusView stopAnimating];
}

- (void)setSpeaker:(id)sender
{
    if(_chl_id)
    {
        _speaker_is_mute = !_speaker_is_mute;
        MMediaEngineEvent *evt = [_engine ctrl:_chl_id method:@"speaker.mute"  params:_speaker_is_mute?@"{value:1}":@"{value:0}"];  //?
        
        if((nil == evt) || evt.status)
        {
            NSLog(@"ctrl chl[%ld] mute[%ld] failed.", _chl_id, _speaker_is_mute);
        }
    }
    else
    {
        _speaker_is_mute = 1;
    }
    _voiceButton.selected = !_speaker_is_mute;
}

#pragma mark - Rotate
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect rect = self.navigationController.navigationBar.frame;
    CGFloat height = rect.origin.y + rect.size.height;
    _toolbar.frame = (CGRect){{0,height},{self.navigationController.view.bounds.size.width,25}};
    _voiceButton.frame = CGRectMake(10, self.view.frame.size.height / 2 + 60, 24, 24);
    if (_shareVideoWindow) {
        CGRect frame = [UIScreen mainScreen].bounds;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            frame = self.view.bounds;
        }
        _shareVideoWindow.frame = frame;
    }
}

- (void)hiddenControlView
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView animateWithDuration:.2f animations:^{
        _isHid = ![UIApplication sharedApplication].statusBarHidden;
        

        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f)
        {
            [self setNeedsStatusBarAppearanceUpdate];
        }
        else
        {
            [[UIApplication sharedApplication] setStatusBarHidden:_isHid withAnimation:YES];
        }
        
        [self.navigationController setNavigationBarHidden:_isHid animated:YES];
        
        CGRect rect = self.navigationController.navigationBar.frame;
        CGFloat height = rect.origin.y + rect.size.height ;
        
        _toolbar.frame = (CGRect){{0,height},{self.navigationController.view.bounds.size.width,25}};
        
    }completion:^(BOOL finish){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
     ];
}


- (BOOL)prefersStatusBarHidden
{
    return _isHid;
}

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        if (alertView.tag == SHARE_TAG)
        {
            NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        else if (alertView.tag == DOWNLOAD_TAG)
        {
            [_playButton setHidden:YES];
            _progressView.progressValue = 0;
            [_progressView setHidden:NO];
            //        [sender setHidden:YES];
            _isDownloadOperation = YES;
            _isReplayOperation = NO;
            _downloadButton.hidden = YES;
            _voiceButton.hidden = YES;
            [_actindStatusView startAnimating];
            
            mcall_ctx_playback *ctx = [[mcall_ctx_playback alloc] init];
            ctx.sn = _msg.sn;
            ctx.token = _msg.record_token;
            ctx.protocol = @"rtdp";
            ctx.target = self;
            ctx.on_event = @selector(playback_done:);
            
            [self.agent playback:ctx];
        }
        else if (alertView.tag == DOWNLOAD_NON_NETWORK_TAG)
        {
            NSURL *url = [NSURL URLWithString:@"prefs:root"];
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

#pragma mark - Local messageSnapshot
- (NSString *)localMessageRecordPathByMsgSn:(NSString *)msg_sn withMsgImgToken:(NSString *)msg_imgtoken
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *messageRecordPath = [[path stringByAppendingPathComponent:@"photos/messageRecord"] stringByAppendingPathComponent:msg_sn];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:messageRecordPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager]
         createDirectoryAtPath:messageRecordPath withIntermediateDirectories:YES attributes:nil
         error:&error];
        if (error) {
            NSLog(@"errer:%@", [error localizedDescription]);
        }
    }
    NSString *imagePath = [messageRecordPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", msg_imgtoken]];
    
    return imagePath;
}

#pragma mark - Pending Local Server
- (BOOL)pendingLocalServer
{
    if ([self createHttpConfXMLFile])
    {
        [self getIPAddress];
        if ([self createIndexHtmlFile]) {
            
            [self destroyHandle];
            
            struct mhttp_create_param param = {0};
            param.conf_file = (char*)_http_conf_path.UTF8String;           //http conf file
            param.mqlst = (__bridge struct mmq_list *)(self);   //Any object address
            param.fwd_req = fwd_req;                            //Empty function
            param.fwd_cancel = fwd_cancel;                      //Empty function
            param.get_def = get_def;                            //Empty function
            param.refer = (__bridge struct component *)(self);  //Any object address
            param.log_enable = 0;
            
            module_handle = mhttp_create(&param);
            
            if (_mhttp_wait_thread) {
                self.mhttp_wait_thread = nil;
            }
            if (module_handle) {
                [self.mhttp_wait_thread start];
            }
            
            return YES;
        }
    }
    return NO;
}

-(void)run_mhttp_wait
{
    NSLog(@"Start Share");
    while (!_mhttp_wait_thread.isCancelled) {
        
        if (module_handle) {
            long waitValue = mhttp_wait(module_handle, 10);
            
            if (0 == waitValue) {
//                NSLog(@"succeed");
            } else {
                NSLog(@"error : %ld",waitValue);
            }
        }
        
    }
    NSLog(@"End Share");
}

long fwd_req( struct component* comp, struct message *msg, struct in_addr *ip, long port, long handle, void *refer, long *new_handle )
{
    return 1;
}

long fwd_cancel( struct component* comp, long handle )
{
    return 1;
}

struct pack_def* get_def( void *refer, struct len_str *type, unsigned long magic )
{
    return NULL;
}

- (void)destroyHandle
{
    if(module_handle)
    {
        mhttp_destroy(module_handle);
        module_handle = NULL;
    }
}

- (BOOL)createHttpConfXMLFile
{
    //    NSString *videoInfoDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"video-mp4"];
    //    NSLog(@"video path:%@",videoInfoDirectory);
    //    BOOL isDirectory;
    //    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:videoInfoDirectory isDirectory:&isDirectory];
    //    if (isDirectory && isFileExist)
    //    {
    //create http conf xml file
    NSString *saveDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *saveFileName=@"http_conf.xml";
    NSString *filepath=[saveDirectory stringByAppendingPathComponent:saveFileName];
    
    NSMutableString *xmlString = [[NSMutableString alloc]initWithString:@"<http_conf>"];
    [xmlString appendString:@"<addr>"];
    [xmlString appendString:@"<ip>0.0.0.0</ip>"];
    [xmlString appendString:@"<port>7080</port>"];
    [xmlString appendString:@"</addr>"];
    [xmlString appendString:@"<vhosts>"];
    [xmlString appendString:@"<mapping>"];
    [xmlString appendString:@"<vpath>/</vpath>"];
    [xmlString appendString:[NSString stringWithFormat:@"<local_path>%@</local_path>",[self getFilePath]]];
    [xmlString appendString:@"<cid></cid>"];
    [xmlString appendString:@"<msg_type></msg_type>"];
    [xmlString appendString:@"</mapping>"];
    [xmlString appendString:@"</vhosts>"];
    [xmlString appendString:@"</http_conf>"];
    
    //save html to local
    if ([xmlString  writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        _http_conf_path = filepath;
        return YES;
    }
    //    }
    
    return NO;
}

- (BOOL)createIndexHtmlFile
{
    NSString *saveDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:(![_boxID isEqualToString:_deviceID]) ? [NSString stringWithFormat:@"video-mp4/%@/%@",_boxID,_deviceID] : [NSString stringWithFormat:@"video-mp4/%@",_deviceID]];
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:saveDirectory isDirectory:&isDirectory];
    if (isDirectory && isFileExist)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *mobileCssFilePath = [saveDirectory stringByAppendingPathComponent:@"mobile.css"];
        NSString *pcCssFilePath = [saveDirectory stringByAppendingPathComponent:@"pc.css"];
        NSString *btnImageFilePath = [saveDirectory stringByAppendingPathComponent:@"button_ico.png"];
        NSString *downloadImageFilePath = [saveDirectory stringByAppendingPathComponent:@"download.png"];
        
        if(![fileManager fileExistsAtPath:mobileCssFilePath])
        {
            NSString *mobileCssPath = [[NSBundle mainBundle] pathForResource:self.app.is_vimtag ? @"vimtag_mobile" : @"mobile" ofType:@"css"];
            if (![fileManager copyItemAtPath:mobileCssPath toPath:[saveDirectory stringByAppendingPathComponent:@"mobile.css"] error:nil])
            {
                return NO;
            }
        }
        if(![fileManager fileExistsAtPath:pcCssFilePath])
        {
            NSString *pcCssPath = [[NSBundle mainBundle] pathForResource:self.app.is_vimtag ? @"vimtag_pc" : @"pc" ofType:@"css"];
            if (![fileManager copyItemAtPath:pcCssPath toPath:[saveDirectory stringByAppendingPathComponent:@"pc.css"] error:nil])
            {
                return NO;
            }
        }
        
        [UIImagePNGRepresentation([UIImage imageNamed:@"button_ico.png"]) writeToFile:btnImageFilePath atomically:YES];
        [UIImagePNGRepresentation([UIImage imageNamed:self.app.is_vimtag ? @"vimtag_download.png" : @"download.png"]) writeToFile:downloadImageFilePath atomically:YES];
        //        if(![fileManager fileExistsAtPath:btnImageFilePath])
        //        {
        //            NSString *btnImagePath = [[NSBundle mainBundle] pathForResource:@"button_ico" ofType:@"png"];
        //            if (![fileManager copyItemAtPath:btnImagePath toPath:[saveDirectory stringByAppendingPathComponent:@"button_ico.png"] error:nil])
        //            {
        //                return NO;
        //            }
        //        }
        //
        //        if(![fileManager fileExistsAtPath:downloadImageFilePath])
        //        {
        //            NSString *downloadImagePath = [[NSBundle mainBundle] pathForResource:@"download" ofType:@"png"];
        //            if (![fileManager copyItemAtPath:downloadImagePath toPath:[saveDirectory stringByAppendingPathComponent:@"download.png"] error:nil])
        //            {
        //                return NO;
        //            }
        //        }
        
        //Write html file
        NSString *filepath = [saveDirectory stringByAppendingPathComponent:@"index.htm"];
        NSLog(@"%@",filepath);
        NSMutableString *htmlstring=[[NSMutableString alloc]initWithString:@"<!doctype html><html lang=\"en\"><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=2.0\" /><title>download</title>"];
        [htmlstring appendFormat:@"<link id=\"mobile_css\" rel=\"stylesheet\" href=\"mobile.css\"><link id=\"pc_css\" rel=\"stylesheet\" href=\"pc.css\">"];
        [htmlstring appendString:@"	<script type=\"text/javascript\" >var data={"];
        
        [htmlstring appendString:[NSString stringWithFormat:@"\"info_id\":\"ID：%@\",",_localVideoInfo.deviceId]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"info_size\":\"%@：%.1lfM\",",NSLocalizedString(@"mcs_video_size",nil),[self fileSizeAtPath]]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"info_time\":\"%@: %@\",",NSLocalizedString(@"mcs_video_duration", nil),_localVideoInfo.duration]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"info_date\":\"%@：%@\",",NSLocalizedString(@"mcs_time", nil),_localVideoInfo.date]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"download_text\":\"%@\",",NSLocalizedString(@"mcs_download", nil)]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"download_url\":\"http://%@:7080/%@\",", _ipAddress, [self getFileName:_url]]];
        [htmlstring appendString:[NSString stringWithFormat:@"\"download_name\":\"%@_%@.mp4\"",_localVideoInfo.deviceId, _localVideoInfo.date]];
        
        [htmlstring appendString:@" };"];
        [htmlstring appendString:@"function start(){var m_userAgent = navigator.userAgent;document.getElementById(\"main\").innerHTML=\"<div id='download_img'>\"+\"	<img src='download.png'>\"+\"</div>\"+\"<div id='download_info'>\"+\"	<div id='info_id'>\"+data[\"info_id\"]+\"</div>\"+\"	<div id='info_size'>\"+data[\"info_size\"]+\"</div>\"+\"	<div id='info_time'>\"+data[\"info_time\"]+\"</div>\"+\"	<div id='info_date'>\"+data[\"info_date\"]+\"</div>\"+\"</div>\"+\"<div id='download_button'>\"+\"    <img id='buttom_ico' src='button_ico.png'>\"+\"    <span id='download_text'>\"+data[\"download_text\"]+\"</span>\"+\"  </div>\"+\"<a id='download_a' href='\"+data[\"download_url\"]+\"' download='\"+data[\"download_name\"]+\"' style='visibility: hidden;'></a>\";"];
        [htmlstring appendString:@"if (m_userAgent.indexOf('iPhone') > -1 || m_userAgent.indexOf('iPad') > -1 || m_userAgent.indexOf('Android') > -1){document.getElementsByTagName('head')[0].removeChild(document.getElementById(\"pc_css\"));}else{document.getElementsByTagName('head')[0].removeChild(document.getElementById(\"mobile_css\"));}document.getElementById(\"download_button\").onclick = function(){document.getElementById(\"download_a\").click();}}"];
        [htmlstring appendString:@"</script></head><body onload=\"start()\"><div id=\"main\"></div></body></html>"];
        
        //save html to local
        if ([htmlstring  writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Get IP Address
- (void)getIPAddress
{
    _ipAddress = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    _ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    NSLog(@"Device IP : %@", _ipAddress);
    
    // Free memory
    freeifaddrs(interfaces);
}

#pragma mark - Get File Size
- (float)fileSizeAtPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:(![_boxID isEqualToString:_deviceID]) ? [NSString stringWithFormat:@"video-mp4/%@/%@/%@",_boxID,_deviceID,[self getFileName:_url]] : [NSString stringWithFormat:@"video-mp4/%@/%@",_deviceID,[self getFileName:_url]]];
    
    NSLog(@"%@",filePath);
    if ([fileManager fileExistsAtPath:filePath])
    {
        return ([[fileManager attributesOfItemAtPath:filePath error:nil] fileSize]/one_trillion);
    }
    return 0;
}

#pragma mark - Get File Name
- (NSString *)getFileName:(NSString *)filePath
{
    NSString *fileString = filePath;
    NSString *fileName = nil;
    unsigned long location = 0;
    
    for(int i =0; i < [fileString length]; i++)
    {
        fileName = [fileString substringWithRange:NSMakeRange(i, 1)];
        if ([fileName isEqualToString:@"/"]) {
            location = i;
        }
    }
    
    return [fileString substringWithRange:NSMakeRange(location + 1,[fileString length] - location -1)];
}

#pragma mark - Get File Path
- (NSString *)getFilePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:(![_boxID isEqualToString:_deviceID]) ? [NSString stringWithFormat:@"video-mp4/%@/%@", _boxID, _deviceID] : [NSString stringWithFormat:@"video-mp4/%@",_deviceID]];
    
    NSLog(@"%@",filePath);
    if ([fileManager fileExistsAtPath:filePath])
    {
        return filePath;
    }
    return _url;
}

#pragma mark - Check URL
- (BOOL)checkFilePath
{
    NSString *fileString = [self getFileName:_url];
    fileString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:(![_boxID isEqualToString:_deviceID]) ? [NSString stringWithFormat:@"video-mp4/%@/%@/%@", _boxID, _deviceID,fileString] : [NSString stringWithFormat:@"video-mp4/%@/%@",_deviceID,fileString]];
    
    NSString *tmpString = [NSString string];
    //Change String
    tmpString = [fileString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    _url = tmpString;
    if ([fileString rangeOfString:@" "].length) {
        //Rename
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        if ([fileManager moveItemAtPath:fileString toPath:tmpString error:&error])
        {
            NSLog(@"success");
            NSString *infoFilePath = [[fileString stringByDeletingPathExtension] stringByAppendingPathExtension:@"inf"];
            NSString *tmpInfoFilePath = [infoFilePath stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            if ([fileManager moveItemAtPath:infoFilePath toPath:tmpInfoFilePath error:&error]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
