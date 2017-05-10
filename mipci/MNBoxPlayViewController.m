//
//  MNBoxPlayViewController.m
//  mipci
//
//  Created by mining on 15/10/14.
//
//
#define UIColorFromRGB(rgbValue,alphaValue) [UIColor colorWithRed:((((rgbValue) & 0xFF0000) >> 16))/255.f \
green:((((rgbValue) & 0xFF00) >> 8))/255.f \
blue:(((rgbValue) & 0xFF))/255.f alpha:alphaValue]

#define total_bytes_statistic_counts    3
#define DEFAULT_LINE_COUNTS       3
#define DEFAULT_CELL_MARGIN       4
#define DEFAULT_EDGE_MARGIN       5

#define DOWNLOAD_TAG                    1002
#define DOWNLOAD_NON_NETWORK_TAG        1003

#define CON_ALERT_TAG  2001
#define NONET_ALERT_TAG 2002
#define FIRST_CON 2003
#define FIRST_NOTNET 2004

#import "MNBoxPlayViewController.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNProgressHUD.h"
#import "MNConfiguration.h"
#import "UISlider+MNAddition.h"
#import "UIImageView+MNNetworking.h"
#import "MNProgressView.h"
#import "LocalVideoInfo.h"
#import "MNSnapshotViewController.h"
#import "MNInfoPromptView.h"
#import "MNCache.h"
#import "DirectoryConf.h"

#import "mcore/mcore.h"
#import "mme_ios.h"
#import "MIPCUtils.h"
#import "mios_core_frameworks.h"
#import "MNUserBehaviours.h"

@interface MNBoxPlayViewController ()
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
}
@property (strong, nonatomic)   mipc_agent          *agent;
@property (weak, nonatomic)     AppDelegate         *app;
@property (strong, nonatomic)   MNProgressHUD       *progressHUD;
@property (assign, nonatomic)   BOOL                isViewAppearing;
@property (strong, nonatomic)   NSTimer             *timer;
@property (copy, nonatomic)   NSString            *token;
@property (strong, nonatomic)   seg_obj             *startObj;
//@property (assign, nonatomic)   BOOL                is_slide;
@property (nonatomic, strong)   MNProgressView        *progressView;
@property (assign, nonatomic)   BOOL  isDownloadOperation;
@property (assign, nonatomic)   BOOL  isReplayOperation;
@property (assign, nonatomic)   BOOL  isDownloading;
@property (assign, nonatomic)   long downloadDuration;
@property (copy, nonatomic)   NSString *mp4FilePath;
@property (assign, nonatomic)   long long start_time;
@property (assign, nonatomic)   long long end_time;
@property (copy, nonatomic)   NSString *url;
@property (copy, nonatomic)   NSMutableArray      *flagArray;
@property (strong, nonatomic)   seg_obj             *thumbnailObj;

@end

@implementation MNBoxPlayViewController

-(void)dealloc
{
    
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        [self.view insertSubview:_progressHUD belowSubview:_controlView];
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

- (NSMutableArray *)flagArray
{
    @synchronized(self){
        if (nil == _flagArray) {
            _flagArray = [NSMutableArray array];
        }
        
        return _flagArray;
    }
}

#pragma mark - life cycle
- (void)initUI
{
    //    MNConfiguration *configuration = [MNConfiguration shared_configuration];
    CGRect rect = self.view.frame;
    
    _speedLabel.textColor = [UIColor whiteColor];
    _speedLabel.backgroundColor = [UIColor clearColor];
    _speedStatusLabel.backgroundColor = [UIColor redColor];
    _speedStatusLabel.layer.cornerRadius = 6;
    _speedStatusLabel.layer.masksToBounds = YES;
    
    _startLabel.text = nil;
    _endLabel.text = nil;
    _dateLabel.text = nil;
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0 ) {
    //        _progressSlider.tintColor = configuration.switchTintColor;
    //    }
    //    [_progressSlider setThumbImage:[UIImage imageNamed: @"vt_outer.png"] forState:UIControlStateNormal];
    if ([_segmentArray lastObject]) {
        _start_time = ((seg_obj *)_segmentArray.firstObject).start_time;
        _end_time = ((seg_obj *)_segmentArray.lastObject).end_time;
        _startLabel.text = [self getStringTime:((seg_obj *)_segmentArray.firstObject).start_time];
        _endLabel.text = [self getStringTime:((seg_obj *)_segmentArray.lastObject).end_time];
        _dateLabel.text = [self stringFromLong:((seg_obj *)_segmentArray.firstObject).start_time];
//        _downloadDuration = [self getStringDurationTime:(((seg_obj *)_segmentArray.lastObject).end_time - ((seg_obj *)_segmentArray.firstObject).start_time)];
//        NSLog(@"%@", _downloadDuration);
        _downloadDuration = 0;
        //        _progressSlider.minimumValue = 0;
        //        _progressSlider.maximumValue = (float)((((seg_obj *)_segmentArray.lastObject).end_time - ((seg_obj *)_segmentArray.firstObject).start_time)/1000);
        //        _progressSlider.value = 0;
        //        _progressSlider.continuous = NO;
        for (seg_obj *obj in _segmentArray)
        {
            if (obj.flag) {
                [self.flagArray addObject:obj];
            }
        }
        [_progressSliderView setSegsArray:_segmentArray];
        [_progressSliderView setFlagArray:_flagArray];
        _progressSliderView.delegate = self;
        
        self.token = [NSString stringWithFormat:@"%@_p0_%ld_%ld", _deviceID, ((seg_obj *)_segmentArray.firstObject).cluster_id, ((seg_obj *)_segmentArray.firstObject).seg_id];
    }
    
    self.videoImageView = [[UIImageView alloc] initWithFrame:rect];
    _videoImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_videoImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_videoImageView setUserInteractionEnabled:YES];
    
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_videoImageView.frame) / 2 - 64 / 2, CGRectGetHeight(_videoImageView.frame) / 2 - 64 / 2, 64, 64)];
    _playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [_playButton addTarget:self action:@selector(recordPlay:) forControlEvents:UIControlEventTouchUpInside];
    if (self.app.is_vimtag) {
        [_playButton setImage:[UIImage imageNamed:@"pu_play"] forState:UIControlStateNormal];
    } else {
        [_playButton setImage:[UIImage imageNamed:@"pu_play"] forState:UIControlStateNormal];
    }
    
    [_videoImageView addSubview:_playButton];
    [self.view insertSubview:_videoImageView belowSubview:self.view.subviews.firstObject];
    
    _progressView = [[MNProgressView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_videoImageView.frame) / 2 - 64 / 2, CGRectGetHeight(_videoImageView.frame) / 2 - 64 / 2, 64, 64)];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    _progressView.userInteractionEnabled = YES;
    _progressView.hidden = YES;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(progressViewDismiss:)];
    [_progressView addGestureRecognizer:singleTapGestureRecognizer];
    
    [_videoImageView addSubview:_progressView];
    
    //test
    _thumbnailView.hidden = YES;
    _thumbnailImage.image = [UIImage imageNamed:@"vt_cellBg.png"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    
    _speaker_is_mute = 1;
    _url = _localVideoInfo.mp4FilePath;
    
    if ([_segmentArray lastObject]) {
        NSString *imagePath = [self localMessageSnapshotPathByMsgSn:_boxID withMsgImgToken:_token];
        UIImage *image = [[[MNCache class] mn_sharedCache] objectForKey:imagePath];
        if(!image)
        {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
        
        if (image) {
            __strong __typeof(self)strongSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.videoImageView.image = image;
                [strongSelf.videoImageView setAlpha:0.5];
                [UIView animateWithDuration:0.3 animations:^{
                    [strongSelf.videoImageView setAlpha:1.0];
                }];
            });
        }
        else
        {

            mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
            ctx.sn = _boxID;
            ctx.token = _token;
            ctx.type = mdev_pic_seg_album;
            ctx.flag = 1;
            
            UIImage *placeholderImage;
            placeholderImage = _videoImage;
            
            NSURL *downloadImageURL = [NSURL URLWithString:[self.agent pic_url_create:ctx]];
            __block typeof(self) weakSelf = self;
            [self.videoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:downloadImageURL]            placeholderImage:placeholderImage token:_token deviceID:_deviceID flag:1                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image, NSString *deviceID, NSString *token) {
                
                if (token == self.token && image) {
                    __strong typeof (self) strongSelf = weakSelf;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        strongSelf.videoImageView.image = image;
                        [strongSelf.videoImageView setAlpha:0.5];
                        [UIView animateWithDuration:0.3 animations:^{
                            [strongSelf.videoImageView setAlpha:1.0];
                        }];
                    });
                    NSString *imagePath = [weakSelf localMessageSnapshotPathByMsgSn:ctx.sn  withMsgImgToken:ctx.token];
                    if (image && imagePath) {
                        [[[MNCache class] mn_sharedCache] setObject:image forKey:imagePath];
                    }
                    [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath atomically:YES];
                }
                
            }
                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                    NSLog(@"err[%@]", [error localizedDescription]);
                                                }];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isViewAppearing = YES;

    _voiceButton.selected = _speaker_is_mute ? NO : YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_progressSliderView updateViewConstraint];
    if (self.app.is_vimtag && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        [self checkNavigationAlpha];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.app.is_vimtag) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@""] forBarMetrics:UIBarMetricsDefault];
    }
    [MNInfoPromptView hideAll:self.navigationController];
    _active = 0;
    _speaker_is_mute = 1;
    _isViewAppearing = NO;
    
    if (_isDownloading) {
        [self saveMp4ToLocalDirectory];
    }
    [self mediaEndPlay];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)playOrPause:(id)sender
{
    if (_playButton.hidden) {
        [self mediaEndPlay];
        [self.progressHUD hide:YES];
        _speedStatusLabel.backgroundColor = [UIColor redColor];
        _speedLabel.text = @"0Kb";
        _playButton.hidden = NO;
        _playButton.enabled = YES;
        _controlButton.selected = _playButton.hidden ? YES : NO;
        [_videoImageView setHidden:NO];
    } else {
        [self sliderValueChange:_progressSliderView.value];
    }
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)setupPlayTime:(id)sender
{
    //    _is_slide = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sliderValueChange:) object:sender];
    [self performSelector:@selector(sliderValueChange:) withObject:sender afterDelay:0.5f];
}
-(void)hideThumbnailView
{
    _thumbnailView.hidden = YES;
}
#pragma mark -MNPlayProgressViewDelegate

-(void)showThumbnailImageOrNot:(BOOL)is_show
{
    MMediaEngineEvent *evt = [_engine ctrl:_chl_id method:@"query" params:@"{}"];
    if(evt)
    {
        long long value = (_startObj.start_time - ((seg_obj *)_segmentArray.firstObject).start_time);
        [_progressSliderView progressValueChange:value];
        if (_isReplayOperation && [_flagArray lastObject]) {
            [self showThumbnailImageWithValue:value];
        }
    }
   
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideThumbnailView) withObject:nil afterDelay:3.0f];
    
}

-(void)sliderShowThumbnailValue:(CGFloat)value
{
    long long sliderTime = 0;
    long long tmpStartTime = 0;
    
    if ([self.segmentArray firstObject]) {
        sliderTime = value + [self transformTime:((seg_obj *)_segmentArray.firstObject).start_time];
        seg_obj *lastSeg = _segmentArray.firstObject;
        for (seg_obj *seg in _segmentArray) {
            if (_segmentArray.count == 1) {
                _startObj = lastSeg;
                break;
            }
            tmpStartTime = [self transformTime:seg.start_time];
            if (tmpStartTime >= sliderTime) {
                _startObj = lastSeg;
                break;
            }
            lastSeg = seg;
        }
    }
}
- (void)sliderValueChange:(CGFloat)value
{
    long long sliderTime = 0;
    long long tmpStartTime = 0;
    
    if ([self.segmentArray firstObject]) {
        sliderTime = value + [self transformTime:((seg_obj *)_segmentArray.firstObject).start_time];
        seg_obj *lastSeg = _segmentArray.firstObject;
        for (seg_obj *seg in _segmentArray) {
            if (_segmentArray.count == 1) {
                _startObj = lastSeg;
                _isReplayOperation = YES;
                _isDownloadOperation = NO;
                _downloadButton.enabled = NO;
                [self mediaBeginPlayWithSeg:lastSeg];
                break;
            }
            tmpStartTime = [self transformTime:seg.start_time];
            if (tmpStartTime >= sliderTime) {
                //                _is_slide = 0;
                _startObj = lastSeg;
                _isReplayOperation = YES;
                _isDownloadOperation = NO;
                _downloadButton.enabled = NO;
                [self mediaBeginPlayWithSeg:lastSeg];
                break;
            }
            lastSeg = seg;
        }
    }
}

- (void)showThumbnailImageWithValue:(long long)value
{
    if (_controlView.isHidden) {
        _thumbnailView.hidden = YES;
        return;
    }
    if (_thumbnailObj != nil) {
        if ((_start_time+value) >= _thumbnailObj.start_time && (_start_time+value) <= _thumbnailObj.end_time) {
            _thumbnailView.hidden = NO;
            _thumbnailLayoutConstraint.constant = _progressSliderView.frame.origin.x + _progressSliderView.handleImageView.center.x - CGRectGetWidth(_thumbnailView.frame)/2;
            
            return;
        } else {
            _thumbnailObj =nil;
            _thumbnailView.hidden = YES;
            _thumbnailImage.image = [UIImage imageNamed:@"vt_cellBg.png"];
        }
    }
    
    for (seg_obj *seg in _flagArray) {
        if ((_start_time+value) >= seg.start_time && (_start_time+value) <= seg.end_time) {
            _thumbnailView.hidden = NO;
            _thumbnailLayoutConstraint.constant = _progressSliderView.frame.origin.x + _progressSliderView.handleImageView.center.x - CGRectGetWidth(_thumbnailView.frame)/2;
            _thumbnailTimeLabel.text = [self getStringTime:seg.start_time];
            _thumbnailObj = seg;
            
            NSString *imageToken = [NSString stringWithFormat:@"%@_p3_%ld_%ld", _deviceID, seg.cluster_id, seg.seg_id];
            
            NSString *imagePath = [self localBoxSegmentPathByID:_deviceID withBoxSegmentToken:imageToken];
            UIImage *image = [[[MNCache class] mn_sharedCache] objectForKey:imagePath];
            if (!image) {
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
            
            if (image)
            {
                self.thumbnailImage.image = image;
            }
            else
            {
                mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
                ctx.sn = _boxID;
                ctx.token = imageToken;
                ctx.type = mdev_pic_seg_album;
                ctx.flag = 1;
                
                UIImage *placeholderImage;
                if (self.app.is_luxcam)
                {
                    placeholderImage = [UIImage imageNamed:@"placeholder.png"];
                }
                else if (self.app.is_vimtag)
                {
                    placeholderImage = [UIImage imageNamed:@"vt_cellBg.png"];
                }
                else if (self.app.is_ebitcam)
                {
                    placeholderImage = [UIImage imageNamed:@"eb_cellBg.png"];
                }
                else if (self.app.is_mipc)
                {
                    placeholderImage = [UIImage imageNamed:@"mi_cellBg.png"];
                }
                else
                {
                    placeholderImage = [UIImage imageNamed:@"camera_placeholder.png"];
                }

                NSURL *downloadImageURL = [NSURL URLWithString:[self.agent pic_url_create:ctx]];
                __block typeof(self) weakSelf = self;
                [self.thumbnailImage setImageWithURLRequest:[NSURLRequest requestWithURL:downloadImageURL]            placeholderImage:placeholderImage token:imageToken deviceID:_deviceID flag:1                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image, NSString *deviceID, NSString *token) {
                    
                    if (token == imageToken && image) {
                        __strong typeof (self) strongSelf = weakSelf;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            strongSelf.thumbnailImage.image = image;
                        });
                        NSString *imagePath = [weakSelf localBoxSegmentPathByID:_deviceID withBoxSegmentToken:imageToken];
                        if (image && imagePath) {
                            [[[MNCache class] mn_sharedCache ] setObject:image forKey:imagePath];
                        }
                        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
                    }
                    
                }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                        NSLog(@"err[%@]", [error localizedDescription]);
                                                    }];
            }
        }
    }
}

- (IBAction)setupVoice:(id)sender
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
    
    _voiceButton.selected = _speaker_is_mute ? NO : YES;
}

- (IBAction)handleSingleTap:(id)sender
{
    if (_isDownloadOperation)
    {
        return;
    }
    CGPoint newPoint = [sender locationInView:self.view];
    if ((!_controlView.hidden && CGRectContainsPoint(_controlView.frame, newPoint)))
    {
        return;
    }
    if (!_thumbnailView.hidden && CGRectContainsPoint(_thumbnailView.frame, newPoint)) {
        if (_playButton.hidden) {
            [self playOrPause:nil];
        }
        UIStoryboard *storyboard;
        if (self.app.is_luxcam)
        {
            storyboard = [UIStoryboard storyboardWithName:@"LuxcamStoryboard_iPhone" bundle:nil];
        }
        else if (self.app.is_vimtag)
        {
            storyboard = [UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil];
        }
        else if (self.app.is_ebitcam)
        {
            storyboard = [UIStoryboard storyboardWithName:@"EbitcamStoryboard_iPhone" bundle:nil];
        }
        else if (self.app.is_mipc)
        {
            storyboard = [UIStoryboard storyboardWithName:@"MIPCStoryboard_iPhone" bundle:nil];
        }
        else
        {
            storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        }
        MNSnapshotViewController *snapshotViewController = [storyboard instantiateViewControllerWithIdentifier:@"MNSnapshotViewController"];
        snapshotViewController.snapshotImage = _thumbnailImage.image;
        snapshotViewController.snapshotID = _deviceID;
        snapshotViewController.boxID = _boxID;
        snapshotViewController.token = _thumbnailObj != nil ?[NSString stringWithFormat:@"%@_p0_%ld_%ld", _deviceID, _thumbnailObj.cluster_id, _thumbnailObj.seg_id] : nil;
        [self.navigationController pushViewController:snapshotViewController animated:YES];
        
        return;
    }
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [UIView animateWithDuration:.2f animations:^{
        BOOL isHid = self.navigationController.navigationBar.hidden;
        [self.navigationController setNavigationBarHidden:!isHid animated:YES];
        self.voiceButton.hidden = !isHid;
        self.controlView.hidden = !isHid;
        if (_thumbnailObj != nil) {
            self.thumbnailView.hidden = !isHid;
        }
    }completion:^(BOOL finish){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
    }];
    _thumbnailView.hidden = YES;
}

- (void)recordPlay:(id)sender
{
    _isReplayOperation = YES;
    _isDownloadOperation = NO;
    _downloadButton.enabled = NO;
    _playButton.hidden = YES;
    _controlButton.selected = _playButton.hidden ? YES : NO;
    
    [self.progressHUD show:YES];
    if (_progressSliderView.value) {
        [self sliderValueChange:_progressSliderView.value];
    } else {
        if ([self.segmentArray firstObject]) {
            _startObj = ((seg_obj *)_segmentArray.firstObject);
            [self mediaBeginPlayWithSeg:((seg_obj *)_segmentArray.firstObject)];
        }
    }
}

- (IBAction)download:(id)sender
{
    NetworkStatus status = [self.app reachabilityChanged:nil];
    if (ReachableViaWiFi == status)
    {
        [_playButton setHidden:YES];
        [_progressView setHidden:NO];
        _progressView.progressValue = 0;
        _controlView.hidden         = YES;
        _voiceButton.hidden         = YES;
        _playButton.hidden          = YES;
        _playButton.enabled         = NO;
        _isDownloadOperation        = YES;
        _isReplayOperation          = NO;
        if ([self.segmentArray firstObject]) {
            _startObj = ((seg_obj *)_segmentArray.firstObject);
            [self mediaBeginPlayWithSeg:((seg_obj *)_segmentArray.firstObject)];
        }
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

#pragma mark - GestureRecognizer
- (void)progressViewDismiss:(UITapGestureRecognizer *)gestureRecognizer
{
    if (_progressView.progressValue >= 1.0) {
        gestureRecognizer.view.hidden = YES;
        _playButton.hidden = NO;
        _controlButton.selected = _playButton.hidden ? YES : NO;
        _progressView.progressValue = 0;
    }
}

#pragma mark - Engine
- (void)MIPC_EngineCreateWithURL:(NSString *)url
{
    //end engine
    [self mediaEndPlay];
    
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
//        NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//        NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
//        MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaViours.dev_replay_fail_tiems += 1;
//        BOOL isRight = [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
        
        [self mediaEndPlay];
        [self.progressHUD hide:YES];
    }
    else
    {
        struct mipci_conf *conf = MIPC_ConfigLoad();
        
        NSString   *replay_flow_ctrl = [NSString stringWithFormat:@"flow_ctrl:\"delay\",delay:{buf:{min:%d}}",(conf && 0 != conf->buf)?conf->buf:3000];
        
        NSString   *urlparams = [NSString stringWithFormat:@"{src:[{url:\"%@\"}], dst:[{url:\"data:/\",thread:\"istream\"}],trans:[{%@,thread:\"istream\"}],speaker:{mute:%ld}, thread:\"channel\"}", url, replay_flow_ctrl, _speaker_is_mute];
        
//        NSString   *fileparams = [NSString stringWithFormat:@"{src:[{url:\"file://%@\"}], dst:[{url:\"data:/\",thread:\"istream\"}],trans:[{%@,thread:\"istream\"}],speaker:{mute:%ld}, thread:\"channel\"}", url, replay_flow_ctrl, _speaker_is_mute];
        
        memset(_total_bytes, 0, sizeof(_total_bytes));
        memset(_total_bytes_tick, 0, sizeof(_total_bytes_tick));
        if(0 >= (_chl_id = [_engine chl_create:urlparams]))
        {
            [self mediaEndPlay];
            [self.progressHUD hide:YES];
        }
        else
        {
            NSLog(@"media engine create succeed and chl-create.");
            _ctrl_play_check_counts = 0;
            [UIApplication sharedApplication].idleTimerDisabled = YES;   //not lock screen automate
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(networkSpeedStatus:) userInfo:_engine  repeats:YES];
            if(_chl_id && _engine)
            {
                NSLog(@"engine, child, play recall success!\n");
                [_engine ctrl:_chl_id method:@"play"  params:@"{}"];
            }
        }
    }
}

- (void)mediaEndPlay
{
    [UIApplication sharedApplication].idleTimerDisabled = NO; //lock screen automate

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

- (void)mediaBeginPlayWithSeg:(seg_obj*)obj
{
    mcall_ctx_playback *ctx = [[mcall_ctx_playback alloc] init];
    ctx.sn = _boxID;
    ctx.token = [NSString stringWithFormat:@"%@_%ld_%ld", _deviceID, obj.cluster_id, obj.seg_id];
    ctx.protocol = @"rtdp";
    ctx.target = self;
    ctx.on_event = @selector(playback_done:);
    
    [self.agent playback:ctx];
    _playButton.hidden = YES;
    _controlButton.selected = _playButton.hidden ? YES : NO;
    [self.progressHUD show:YES];
}

- (void)networkSpeedStatus:(NSTimer *)timer
{
    if(_chl_id && _engine)
    {
        MMediaEngineEvent *evt = [_engine ctrl:_chl_id method:@"query" params:@"{}"];
        
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
            if (!_progressSliderView.isSlide) {
                long long value = played_duration + (_startObj.start_time - ((seg_obj *)_segmentArray.firstObject).start_time);
                [_progressSliderView progressValueChange:value];
                //                NSLog(@"max:%lf value:%lf",_progressSliderView.maxValue,value);
                if (_isReplayOperation && [_flagArray lastObject]) {
                   // [self showThumbnailImageWithValue:value];
                }
            }
//            NSLog(@"played_duration:%ld", played_duration);
            _startLabel.text = [self getStringTime:(_startObj.start_time + played_duration)];
            _downloadDuration = played_duration;
            if (_startObj.start_time + played_duration >= (((seg_obj *)_segmentArray.lastObject).end_time - 500))
            {
//                NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//                NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
//                MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//                behaViours.dev_replay_succ_times += 1;
//                BOOL isRight = [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
                
                [self mediaEndPlay];
                [self.progressHUD hide:YES];
                _speedStatusLabel.backgroundColor = [UIColor redColor];
                _speedLabel.text = @"0Kb";
                _playButton.hidden = NO;
                _playButton.enabled = YES;
                _controlButton.selected = _playButton.hidden ? YES : NO;
                //                _progressSliderView.value = 0;
                [_progressSliderView progressValueChange:0];
                _startLabel.text = [self getStringTime:((seg_obj *)_segmentArray.firstObject).start_time];
                _isReplayOperation = NO;
                _isDownloadOperation = NO;
                _downloadButton.enabled = YES;
                [_videoImageView setHidden:NO];
                
                /*downloading*/
                if (_isDownloading) {
                    _isDownloading = NO;
                    [self saveMp4ToLocalDirectory];
                    [self mediaEndPlay];
                    _progressView.progressValue = 1.0;
//                    if (self.app.is_vimtag) {
                        [MNInfoPromptView hideAll:self.navigationController];
//                    }
                }
                else
                {
                    [self mediaEndPlay];
                }
                
                return;
            }
            
            if(0 == json_get_child_long(obj, "total_bytes", &total_bytes))
            {
                long            new_status, sub_bytes = total_bytes - _total_bytes[0];
                speed_bytes = (sub_bytes * 1000)/((_total_bytes_tick[0] && (tick != _total_bytes_tick[0]))?((tick - _total_bytes_tick[0]) > 0 ? (tick - _total_bytes_tick[0]): 1000):1000);
                new_status = (speed_bytes * 3) / (40*1024);
                
                
                /*downloading*/
                if (_isDownloading) {
                    //                    _downloadDuration = played_duration / 1000.0;
                    double persent = _progressSliderView.value / (_progressSliderView.maxValue ? _progressSliderView.maxValue : 1);
                    if (persent > 1.0 || (speed_bytes == 0 && (_startObj.start_time + played_duration > ((seg_obj *)_segmentArray.lastObject).end_time))) {
                        persent = 1.0;
                        //                        [self.downLoadButton setHidden:NO];
                        _isDownloading = NO;
                        [self saveMp4ToLocalDirectory];
                        [self mediaEndPlay];
                    }
                    _progressView.progressValue = persent;
                }
                //
                if(is_buffering
                   && buffer_percent && speed_bytes/* \todo:kugle xxxxxxxxxx, just for unknown ending, if 0 maybe ending */)
                {
                    _speedLabel.text = [NSString stringWithFormat:@"%ld%%", buffer_percent];
                    // [self startProgress];
                }
                else
                {
                    NSString    *nsDuration = @"";
                    _speedLabel.text = [NSString stringWithFormat:@"%@%ld%@B", nsDuration, sub_bytes > 0 ? speed_bytes/1024 : 0, is_p2ping?@"k":@"K"];
                }
                
                if(new_status != _last_speed_status)
                {
                    UIColor *colors[] = {[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor]};
                    _speedStatusLabel.backgroundColor = colors[(new_status < (sizeof(colors)/sizeof(colors[0])))?new_status:((sizeof(colors)/sizeof(colors[0])) - 1)];
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
        [self.progressHUD hide:YES];
    }
}

- (long)onMediaEvent:(MMediaEngineEvent *)evt
{
    if(!_isViewAppearing)
    {
        return 0;
    }
    
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
    [self.progressHUD hide:YES];
    [_videoImageView setHidden:YES];
}
- (void)downloadMp4WithURL:(NSString *)url
{
    [self.progressHUD hide:YES];
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
    NSString *videoDirectory;
    if (![_boxID isEqualToString:_deviceID]) {
        videoDirectory =[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@/%@", _boxID, _deviceID]];
    }else{
        videoDirectory = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@", _deviceID]];
    }
    
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:videoDirectory isDirectory:&isDirectory];
    if (!isFileExist || !isDirectory) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    NSString *mp4File = [_deviceID stringByAppendingFormat:@"_%@.mp4", _token];
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
        [UIApplication sharedApplication].idleTimerDisabled = YES;   //not lock screen automate
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(networkSpeedStatus:) userInfo:_engine  repeats:YES];
        if(_chl_id && _engine)
        {
            NSLog(@"engine, child, play recall success!\n");
            [_engine ctrl:_chl_id method:@"play"  params:@"{}"];
        }
    }
    
}

#pragma mark - save Mp4
- (void)saveMp4ToLocalDirectory
{
    LocalVideoInfo *videoInfo = [[LocalVideoInfo alloc] init];
    videoInfo.deviceId = _deviceID;
    videoInfo.image = _videoImage;
    videoInfo.duration = [self getStringDurationTime:_downloadDuration];
    videoInfo.mp4FilePath = _mp4FilePath;
    videoInfo.date = [[_dateLabel.text stringByAppendingString:@" "] stringByAppendingString:_startLabel.text];
    videoInfo.bigImageId = _token;
    videoInfo.type = @"record";
    videoInfo.start_time = _start_time;
    videoInfo.end_time = _start_time + _downloadDuration;
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *videoDirectory;
    if (![_boxID isEqualToString:_deviceID]) {
        videoDirectory =[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@/%@", _boxID, _deviceID]];
    }else{
        videoDirectory = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@", _deviceID]];
    }
    
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:videoDirectory isDirectory:&isDirectory];
    if (!isFileExist || !isDirectory) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    NSString *videoInfoPath = [videoDirectory stringByAppendingPathComponent:[_deviceID stringByAppendingFormat:@"_%@.inf",_token]];
    [NSKeyedArchiver archiveRootObject:videoInfo toFile:videoInfoPath];
    //test
    DirectoryConf *directoryConf = [[DirectoryConf alloc] init];
    directoryConf.directoryId = ![_boxID isEqualToString:_deviceID] ? _boxID : _deviceID;
    m_dev *dev = [self.agent.devs get_dev_by_sn:directoryConf.directoryId];
    directoryConf.nick = dev.nick;
    
    NSString *directoryConfPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@.conf", directoryConf.directoryId]];
    [NSKeyedArchiver archiveRootObject:directoryConf toFile:directoryConfPath];
    //test
}

#pragma mark - playback_done
- (void)playback_done:(mcall_ret_playback *)ret
{
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil != ret.result) {
        return;
    }
    
    if (_isReplayOperation) {
        //record play
        if (nil != ret.url && 0 != ret.url.length) {
            [self MIPC_EngineCreateWithURL:ret.url];
        }
    }
    else if (_isDownloadOperation)
    {
        [self downloadMp4WithURL:ret.url];
    }
    else
    {
        [self.progressHUD hide:YES];
    }
}

#pragma mark - Notification
- (void)resignActiveNotification:(NSNotification *)notification
{
    _active = 0;
    if (_isDownloading)
    {
        _downloadButton.enabled = YES;
        _isDownloadOperation = NO;
        _isDownloading = NO;
        _progressView.hidden = YES;
        _progressView.progressValue = 0;
        [self saveMp4ToLocalDirectory];
    }
    [self.progressHUD hide:YES];
    _speedStatusLabel.backgroundColor = [UIColor redColor];
    _speedLabel.text = @"0Kb";
    _playButton.hidden = NO;
    _playButton.enabled = YES;
    _controlButton.selected = _playButton.hidden ? YES : NO;
    [_videoImageView setHidden:NO];
    
    [self mediaEndPlay];

}

#pragma mark - InterfaceOrientation

-(BOOL)shouldAutorotate
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_progressSliderView updateViewConstraint];
    if (self.app.is_vimtag && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        [self checkNavigationAlpha];
    }
}

#pragma mark - Get Date&Time Label
- (NSString *)getStringTime:(long long)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time / 1000 + self.timeDifference];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    currentCalendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateComponents *weekdayComponents = [currentCalendar components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    NSInteger hour = [weekdayComponents hour];
    NSInteger min = [weekdayComponents minute];
    NSInteger sec = [weekdayComponents second];
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];
}

- (NSString *)getStringDurationTime:(long long)time
{
    long long durationTime = time / 1000;
    long long hour = durationTime / 3600;
    long long min = (durationTime % 3600) / 60;
    long long sec = durationTime % 60;
    
    if (hour) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)sec];
    }
}

- (NSString *)stringFromLong:(long long)startTime
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:startTime / 1000 + self.timeDifference];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

- (long long)transformTime:(long long)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time / 1000];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [currentCalendar components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    NSInteger hour = [weekdayComponents hour];
    NSInteger min = [weekdayComponents minute];
    NSInteger sec = [weekdayComponents second];
    
    return hour*60*60 + min*60 + sec;
}

- (void)checkNavigationAlpha
{
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"vt_cross_navigation.png"] forBarMetrics:UIBarMetricsDefault];
        [self.controlView setBackgroundColor:UIColorFromRGB(0x282828, 0.3)];
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@""] forBarMetrics:UIBarMetricsDefault];
        [self.controlView setBackgroundColor:UIColorFromRGB(0x333333, 1.0)];
    }
}

#pragma mark -Local messageSnapshot
- (NSString *)localMessageSnapshotPathByMsgSn:(NSString *)msg_sn withMsgImgToken:(NSString *)msg_imgtoken
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *messageSnapshotPath = [[path stringByAppendingPathComponent:@"photos/messageSnapshot"] stringByAppendingPathComponent:msg_sn];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:messageSnapshotPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager]
         createDirectoryAtPath:messageSnapshotPath withIntermediateDirectories:YES attributes:nil
         error:&error];
        if (error) {
            NSLog(@"errer:%@", [error localizedDescription]);
        }
    }
    NSString *imagePath = [messageSnapshotPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", msg_imgtoken]];
    
    return imagePath;
}

#pragma mark - Local message path
- (NSString*)localBoxSegmentPathByID:(NSString*)deviceID withBoxSegmentToken:(NSString*)token
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    NSString *messagePath = [[path stringByAppendingPathComponent:@"photos/boxSegmentCell"] stringByAppendingPathComponent:deviceID];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:messagePath])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:messagePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            NSLog(@"error:%@", [error localizedDescription]);
        }
    }
    
    NSString *imagePath = [messagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", token]];
    
    return imagePath;
}

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        if (alertView.tag == DOWNLOAD_TAG)
        {
            [_playButton setHidden:YES];
            [_progressView setHidden:NO];
            _progressView.progressValue = 0;
            _controlView.hidden         = YES;
            _voiceButton.hidden         = YES;
            _playButton.hidden          = YES;
            _playButton.enabled         = NO;
            _isDownloadOperation        = YES;
            _isReplayOperation          = NO;
            if ([self.segmentArray firstObject]) {
                _startObj = ((seg_obj *)_segmentArray.firstObject);
                [self mediaBeginPlayWithSeg:((seg_obj *)_segmentArray.firstObject)];
            }
            if (self.app.is_vimtag) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_record_prompt", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
            } else {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_record_download_prompt", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
            }
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
    else{
        if ( alertView.tag == CON_ALERT_TAG || alertView.tag == NONET_ALERT_TAG || alertView.tag == FIRST_CON || alertView.tag == FIRST_NOTNET) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"prefs:root"]];
        }
    }
}

@end
