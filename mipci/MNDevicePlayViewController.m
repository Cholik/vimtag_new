//
//  MNVideoLiveViewController.m
//  ipcti
//
//  Created by MagicStudio on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MNDevicePlayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MNDeviceTabBarController.h"
#import "MNSnapshotViewController.h"
#import "MNDeviceSystemSetViewController.h"
#import "MNModifyTimezoneViewController.h"
#import "MNGuideNavigationController.h"
#import "MNMessagePageViewController.h"
#import "MNSettingsDeviceViewController.h"
#import "MNDeviceListViewController.h"
#import "MNSpeedAndModelControlView.h"
#import "MNCacheDirectoryViewController.h"
#import "MNControlBoardView.h"
#import "MNToastView.h"
#import "MNProgressHUD.h"
#import "MNInfoPromptView.h"
#import "MNUserBehaviours.h"
#import "LocalVideoInfo.h"
#import "DeviceInfo.h"

#import "mme_ios.h"
#import "MIPCUtils.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import "sdc_api.h"
#import "mh264_jpg/mh264_jpg_api.h"
#import "DirectoryConf.h"

#define SHARPNESS_TAG 1001
#define PRESETPOINT_TAG 1002
#define total_bytes_statistic_counts    3
#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0

#define CON_ALERT_TAG 1001
#define NONET_ALERT_TAG 1002
#define FIRST_CON 1003
#define FIRST_NOTNET 1004

#define UPGRADE_TAG     2001

@interface MNDevicePlayViewController ()
{
    MMediaEngine    *_engine;
    long            _chl_id;
    //jc's add code
    MMediaEngine    *_recordEngine;
    long            _recordChl_id;
    //end
    long            _in_audio_outing;
    long            _chl_id_audio_out;
    long            _speaker_is_mute;
    long            _light_is_on;
    long            _total_bytes[total_bytes_statistic_counts];
    unsigned long   _total_bytes_tick[total_bytes_statistic_counts];
    long            _last_speed_status;
    long            _ptzMoveStepX;
    long            _ptzMoveStepY;
    int            _onRecord;
    int             _isHandleRecord;
    int             _onsnapshot;
    CGFloat         _initialZoom;
    long            _active;
    BOOL            _isHid;
    long            _curProfileID;
    BOOL            wifiFlag;
    int             wifiImgNum;
    NSInteger       recordTotalTimes;
    NSInteger       micTotalTimes;
}

@property (strong, nonatomic) MNSnapshotViewController   *photoView;
@property (strong, nonatomic) UIButton          *micButton;
@property (strong, nonatomic) MNControlBoardView     *controlBoard;
@property (strong, nonatomic) NSTimer           *keepRecord;
@property (strong, nonatomic) mcall_ret_cam_get *cam_get;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSArray *curise_points;
//save swipe point
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (strong, nonatomic) MNSpeedAndModelControlView *speedAndModelControlView;
@property (strong, nonatomic) UIButton      *buttonUp;
@property (strong, nonatomic) UIButton      *buttonDown;
@property (strong, nonatomic) MNVideoPixelsView *videoView;
@property (retain, nonatomic) NSTimer       *recordTime;
@property (strong, nonatomic) NSTimer       *pollingTimer;
@property (assign, nonatomic) BOOL          is_play;
@property (strong, nonatomic) MNAppPromptWindow *appPromptWindow;
@property (copy, nonatomic)  NSString *resolution;
@property (assign, nonatomic) BOOL  hideUpgradeTips;
@property (assign, nonatomic) BOOL  hideTimezoneTips;
@property (weak, nonatomic) IBOutlet UIImageView *msgImageView;
//Automation
@property (assign, nonatomic) BOOL automationMode;
@property (strong, nonatomic) UILabel *automationLabel;
@property (strong, nonatomic) MNVideoPlayFailPromptView *videoPlayFailPromptView;

@end

@implementation MNDevicePlayViewController

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
        if (self.app.is_luxcam) {
            [self.view insertSubview:_progressHUD belowSubview:_backButton];
        }
        else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
        {
            [self.view insertSubview:_progressHUD belowSubview:_sizeControlView];
        }
        else
        {
            [self.view insertSubview:_progressHUD belowSubview:_navigationToolbar];
        }
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

- (MNVideoPlayFailPromptView *)videoPlayFailPromptView
{
    if (nil == _videoPlayFailPromptView) {
        _videoPlayFailPromptView = [[MNVideoPlayFailPromptView alloc] initWithFrame:self.view.frame Style:MNVideoPlayFailPromptError];
        _videoPlayFailPromptView.delegate = self;
        [self.view addSubview:_videoPlayFailPromptView];

        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_videoPlayFailPromptView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_videoPlayFailPromptView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_videoPlayFailPromptView attribute:NSLayoutAttributeTop  relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop  multiplier:1.0f constant:0.0f];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_videoPlayFailPromptView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
        NSArray *array = @[leftConstraint,rightConstraint,topConstraint,bottomConstraint];
        [self.view addConstraints:array];
        _videoPlayFailPromptView.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return _videoPlayFailPromptView;
}

-(void)dealloc
{
    
}

#pragma mark - Life Cycle
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //        [self initUI];
        [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"mcs_play", nil)];
        if (self.app.is_sereneViewer) {
            self.navigationController.tabBarItem.image = [[UIImage imageNamed:@"tab_video_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
       [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_video_selected.png"]];
      
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        _is_viewAppear = NO;
        if (self.app.is_vimtag)
        {
            self.hidesBottomBarWhenPushed = YES;
        }
    }
    
    return self;
}

- (void)initUI
{
    _lblSpeed.textColor = (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) ? [UIColor whiteColor] : [UIColor grayColor];
    _lblSpeed.backgroundColor = [UIColor clearColor];
    _lblSpeed.font = [UIFont systemFontOfSize:12];
    _lblSpeedStatus.backgroundColor = [UIColor redColor];
    _lblSpeedStatus.layer.cornerRadius = 6;
    _lblSpeedStatus.layer.masksToBounds = YES;
    _promptView.layer.cornerRadius = 5;
    _promptView.layer.masksToBounds = YES;
    
    _setTimezoneView.hidden = YES;
    [_setTimezoneButton addTarget:self action:@selector(setTimezone) forControlEvents:UIControlEventTouchUpInside];
    
    if (!self.app.is_luxcam && !self.app.is_vimtag && !self.app.is_ebitcam && !self.app.is_mipc)
    {
        MNDeviceTabBarController *deviceTabBarViewController = (MNDeviceTabBarController*)self.tabBarController;
        
        self.deviceID = deviceTabBarViewController.deviceID;
        self.protocol = deviceTabBarViewController.protocol;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
        }
        
        [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"mcs_play", nil)];
        [_navigationToolbar setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        
        if (self.app.is_sereneViewer) {
            self.navigationController.tabBarItem.image = [[UIImage imageNamed:@"tab_video_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    
        [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_video_selected.png"]];
    }
    else
    {
        if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            self.videoPlayFailPromptView.hidden = YES;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                self.navigationItem.title = _deviceID;
            }
            //Rotation slider
            _volumeSlider.transform = CGAffineTransformMakeRotation(M_PI*1.5);
            [_volumeSlider setThumbImage:[UIImage imageNamed: @"vt_outer.png"] forState:UIControlStateNormal];
            [_volumeSlider setHidden:YES];
            
            [_recordTimerLabel setText:@"00:00:00"];
            [_recordTimerView setHidden:YES];
            
            [_autoSizeButton setTitle:NSLocalizedString(@"mcs_auto", nil) forState:UIControlStateNormal];
            
            [_StandardSizeButton setTitle:NSLocalizedString(@"mcs_standard_clear", nil) forState:UIControlStateNormal];
            [_fluentSizeButton setTitle:NSLocalizedString(@"mcs_fluent_clear", nil) forState:UIControlStateNormal];
            [_sizeSelectButton setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
            [_highClearSizeButton setTitle:NSLocalizedString(@"mcs_hd_720P", nil) forState:UIControlStateNormal];
            
            _videoView = [[MNVideoPixelsView alloc] init];
            NSArray *view = [[NSBundle mainBundle] loadNibNamed:self.app.is_vimtag ? @"MNVideoPixelsView" : @"MNVideoParamView" owner:nil options:nil];
            _videoView = [view lastObject];
            [self.videoPixelsView addSubview:_videoView];
            _videoView.delegate = self;
            
            if (self.app.is_vimtag) {
                _sizeSelectButton.backgroundColor = [UIColor colorWithRed:0./255. green:0./255. blue:0./255. alpha:0.4];
                _sizeSelectButton.layer.cornerRadius = 14.0;
                //View Record Prompt View
                _viewRecordPromptView.hidden = YES;
                _viewRecordPromptImage.layer.borderColor = [UIColor whiteColor].CGColor;
                _viewRecordPromptImage.layer.borderWidth = 1.0;
                _viewRecordPromptImage.layer.cornerRadius = 1.0;
                _viewRecordPromptLabel.text = NSLocalizedString(@"mcs_record_save_to_my_file", nil);
                [_viewRecordPromptButton setTitle:NSLocalizedString(@"mcs_view_now", nil) forState:UIControlStateNormal];
                [_viewRecordPromptButton addTarget:self action:@selector(viewRecord) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        //update prompt
        mcall_ctx_upgrade_get *ctx = [[mcall_ctx_upgrade_get alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(upgrade_get_done:);
        
        [self.agent upgrade_get:ctx];
    }
    
    //First Use App Prompt
    if (self.app.is_firstLaunch)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        self.app.is_firstLaunch = NO;
        _appPromptWindow = [[MNAppPromptWindow alloc] initWithFrame:[UIScreen mainScreen].bounds style:MNAppPromptStyleVideo];
    }
    
    //Local IPC dev info
    NSData *deviceData = [[NSUserDefaults standardUserDefaults] dataForKey:[NSString stringWithFormat:@"DeviceInfo_%@",_deviceID]];
    if (deviceData) {
        DeviceInfo *obj = [NSKeyedUnarchiver unarchiveObjectWithData:deviceData];
        self.resolution = [NSString stringWithFormat:@"%@",obj.resolution];
        self.hideUpgradeTips = obj.hideUpgradeTips;
        self.hideTimezoneTips = obj.hideTimezoneTips;
    }
    if (_resolution != nil && [_resolution respondsToSelector:@selector(rangeOfString:)]) {
        if ([_resolution rangeOfString:@"1080"].length) {
            [_highClearSizeButton setTitle: NSLocalizedString(@"mcs_hd_1080P", nil) forState:UIControlStateNormal];
        } else if ([_resolution rangeOfString:@"960"].length) {
            [_highClearSizeButton setTitle:NSLocalizedString(@"mcs_hd_960P", nil) forState:UIControlStateNormal];
        } else if ([_resolution rangeOfString:@"720"].length) {
            [_highClearSizeButton setTitle:NSLocalizedString(@"mcs_hd_720P", nil) forState:UIControlStateNormal];
        } else {
            _resolution = nil;
        }
    }
    if (_resolution == nil) {
        m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
        if (dev.p0.length) {
            _resolution = [NSString stringWithFormat:@"%@",dev.p0];
            if ([_resolution respondsToSelector:@selector(rangeOfString:)] && ([_resolution rangeOfString:@"1080"].length || [_resolution rangeOfString:@"960"].length || [_resolution rangeOfString:@"720"].length)) {
                [_highClearSizeButton setTitle:([_resolution rangeOfString:@"1080"].length ? NSLocalizedString(@"mcs_hd_1080P", nil) : ([_resolution rangeOfString:@"960"].length ? NSLocalizedString(@"mcs_hd_960P", nil) : NSLocalizedString(@"mcs_hd_720P", nil))) forState:UIControlStateNormal];
                DeviceInfo *obj = [[DeviceInfo alloc] init];
                obj.resolution = _resolution;
                obj.hideUpgradeTips = _hideUpgradeTips;
                obj.hideTimezoneTips = _hideTimezoneTips;
                NSData *deviceData = [NSKeyedArchiver archivedDataWithRootObject:obj];
                [[NSUserDefaults standardUserDefaults] setObject:deviceData forKey:[NSString stringWithFormat:@"DeviceInfo_%@",_deviceID]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                _resolution = nil;
            }
        }
    }
    //Automation Test
    _automationMode = NO;
    if (self.app.developerOption.automationSwitch) {
        _automationMode = YES;
        _automationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 20, 10)];
        _automationLabel.font = [UIFont systemFontOfSize:8];
        _automationLabel.text = nil;
        _automationLabel.isAccessibilityElement = YES;
        _automationLabel.accessibilityLabel = @"VideoPlayData";
        [self.view addSubview:_automationLabel];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initUI];
    
    _isHandleRecord = 0;
    _active = 1;
    _speaker_is_mute = 1;
    _onRecord        = 0;

    if (!self.app.is_luxcam && !self.app.is_vimtag && !self.app.is_ebitcam && !self.app.is_mipc)
    {
        if (_ver_valid) {
            //Show upgrade prompt
            if (_active &&(!_isExperienceAccount) && (!self.app.isLocalDevice) && (!_hideUpgradeTips)) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_camera_found_new_version_y_n_upgrade", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_donot_remind", nil) otherButtonTitles:NSLocalizedString(@"mcs_yes_verif", nil), NSLocalizedString(@"mcs_no_verif", nil), nil];
                alertView.tag = UPGRADE_TAG;
                [alertView show];
            }
        }
    }
    else if (self.app.is_vimtag || (self.app.is_luxcam && !self.app.isLocalDevice))
    {
        mcall_ctx_dev_msg_listener_add *add = [[mcall_ctx_dev_msg_listener_add alloc] init];
        add.target = self;
        add.on_event = @selector(dev_msg_listener:);
        add.type = @"device,io,motion,alert,snapshot,record,exdev";
        [self.agent dev_msg_listener_add:add];
    }
    
    mcall_ctx_dev_info_get *ctx = [[mcall_ctx_dev_info_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(dev_timezone_get_done:);
    [self.agent dev_info_get:ctx];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _active = 1;
    _isHid  = 0;
    _is_viewAppear = YES;
    
    if (self.app.is_luxcam) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    } else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.selectControlView setHidden:NO];
        [self.sizeControlView setHidden:NO];
        [self.volumeControlView setHidden:NO];
        [self.videoPixelsView setHidden:YES];
        [self.sizeView setHidden:YES];
        
        _snapshotButton.selected = NO;
        [_snapshotButton setImage:[UIImage imageNamed:self.app.is_vimtag ? @"vt_btn_camera_off.png" : self.app.is_ebitcam ? @"eb_camera_off.png" : @"mi_camera_off.png"] forState:UIControlStateNormal];
        
        _recordButton.selected = NO;
        _microphoneButton.selected = NO;
        _videoPixelSetButton.selected = NO;
        _speakerButton.selected = NO;
        
        [_videoPixelsView setHidden:YES];
        [_sizeView setHidden:YES];
        //[_soundSlider setValue:0];
        
        [_recordTimerLabel setText:@"00:00:00"];
        [_recordTimerView setHidden:YES];
        
        [self stopActivityIndicator];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [_speakerButtonItem setImage:[UIImage imageNamed:@"speaker_mute.png"]];
        [_microphoneButtonItem setImage:[UIImage imageNamed: @"micphone_mute.png"]];
        [_snapshotButtonItem setImage:[UIImage imageNamed:@"camera.png"]];
        [_recordButtonItem setImage:[UIImage imageNamed:@"video-record1.png"]];
    }
    
    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if (dev.ubx) {
        _lightButtonItem.enabled = YES;
        [_lightButtonItem setImage:[UIImage imageNamed:@"ubx_settings.png"]];
        _batteryHeaderView.hidden = NO;
        _batteryNumber.hidden = NO;
        _batteryView.hidden = NO;
        float grade = 1;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, _batteryView.frame.size.height * (1 - grade), _batteryView.frame.size.width, _batteryView.frame.size.height * grade)];
        view.backgroundColor = [UIColor greenColor];
        
        if (1 <= grade) {
            _batteryHeaderView.backgroundColor = [UIColor greenColor];
        }
        _batteryNumber.text = [NSString stringWithFormat:@"%d", (int)(grade >= 1 ? 100:(grade*100)) ];
        [_batteryView addSubview:view];
    } else {
        _lightButtonItem.enabled = NO;
        [_lightButtonItem setImage:[UIImage imageNamed: @""]];
    }
    
    if (dev.exsw) {
        //jc's add code
        _lightButtonItem.enabled = YES;
        mcall_ctx_exsw_get *ctx_get = [[mcall_ctx_exsw_get alloc] init];
        ctx_get.sn = _deviceID;
        ctx_get.target = self;
        ctx_get.on_event = @selector(exsw_get_done:);
        [self.agent exsw_get:ctx_get];
        //end
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.app.is_luxcam) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].idleTimerDisabled = NO;   //lock screen automate
    
    _active = 0;
    _is_viewAppear = NO;
    _speaker_is_mute = 1;
    _is_play = 0;
    _promptView.hidden = YES;
    
    if (self.app.is_vimtag) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@""] forBarMetrics:UIBarMetricsDefault];
        _viewRecordPromptView.hidden = YES;
    }
    [MNInfoPromptView hideAll:self.navigationController];
    if (_onRecord) {
        [self endTakeRecord];
    }
    
    [self mediaEndPlay];
    
    if (_recordTime) {
        [_recordTime invalidate];
        _recordTime = nil;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;   //not lock screen automate
    if (!_resolution.length) {
        mcall_ctx_dev_info_get *ctx = [[mcall_ctx_dev_info_get alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(dev_info_get_done:);
        [self.agent dev_info_get:ctx];
        [self.progressHUD show:YES];
    } else {
        [self mediaBeginPlay];
        _is_play = 1;
    }

    if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        [self checkNavigationAlpha];
    }
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    CGRect rect = self.view.bounds;
    float width = CGRectGetWidth(rect);
    
    if (self.app.is_luxcam) {
        if ([UIDevice currentDevice].orientation != UIDeviceOrientationPortrait
            && [UIDevice currentDevice].orientation != UIDeviceOrientationFaceUp) {
            _optionButtonToLeftLayoutConstraint.constant = 20.0f;
        }
        else
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                _optionButtonToLeftLayoutConstraint.constant = width/2-25;
            }
            else
            {
                _optionButtonToLeftLayoutConstraint.constant = width/2-25;
            }
        }
    } else {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ){
            
            if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)){
                _toolbarToTopLayoutConstraint.constant = 0;
                _ViewToTopLayoutConstraint.constant = 64;
            } else {
                _toolbarToTopLayoutConstraint.constant = 20;
                _ViewToTopLayoutConstraint.constant = 64;
            }
        }
    }
}

#pragma mark - Action
- (IBAction)backTo:(id)sender
{
    if (self.app.is_vimtag) {
        if ([[UIDevice currentDevice] orientation] != UIDeviceOrientationPortrait) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
    if (self.app.is_vimtag) {
        if (self.app.isLocalDevice) {
            
            mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init];
            ctx.target = self;
            [self.agent sign_out:ctx];
            
            mcall_ctx_dev_msg_listener_del *del = [[mcall_ctx_dev_msg_listener_del alloc] init];
            del.target = self;
            [self.agent dev_msg_listener_del:del];
        }else {
            mcall_ctx_dev_msg_listener_del *del = [[mcall_ctx_dev_msg_listener_del alloc] init];
            del.target = self;
            [self.agent dev_msg_listener_del:del];
        }
    }
    else if (self.app.is_ebitcam || self.app.is_mipc)
    {
        if (self.app.isLocalDevice) {
            mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init];
            ctx.target = self;
            [self.agent sign_out:ctx];
        }
    }
}

- (IBAction)back:(id)sender
{
    [self mediaEndPlay];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSString *url = [self.app.fromTarget stringByAppendingString:@"://"];
    if (url) {
        if (!self.app.isLoginByID && ([self.app.serialNumber isEqualToString:@"(null)"] || [self.app.serialNumber isEqualToString:@""] || !self.app.serialNumber))
        {
            [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init] ;
            ctx.target = self;
            ctx.on_event = nil;
            
            [self.agent sign_out:ctx];
            self.app.is_jump = NO;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
    
    else
    {
        [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setTimezone
{
    _setTimezoneView.hidden = YES;
    MNModifyTimezoneViewController *modifyTimezoneViewController = [[UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MNModifyTimezoneViewController"];
    MNGuideNavigationController *navigationController = [[MNGuideNavigationController alloc] initWithRootViewController:modifyTimezoneViewController];
    modifyTimezoneViewController.is_playModify = YES;
    modifyTimezoneViewController.deviceID = _deviceID;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)showOrHideOptionView:(id)sender
{
    [UIView animateWithDuration:1.0 animations:^{
        if (_optionSelectView.alpha == 0) {
            [_optionSelectView setAlpha:1.0];
        }
        else
        {
            [_optionSelectView setAlpha:0.0];
        }
    } completion:nil];
    
}

- (IBAction)createVideoSettingsView:(id)sender
{
    if (_controlBoard.superview)
    {
        [self hiddenControlView];
    }
    else
    {
        [self createControlBoard];
    }
}

- (IBAction)setupMicrophone:(id)sender
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        
        if(0 == _chl_id_audio_out)
        {
            if (self.app.is_vimtag) {
                [self stopPollingHideToolBar];
            }
            _in_audio_outing = 1;
            
            mcall_ctx_pushtalk *ctx = [[mcall_ctx_pushtalk alloc] init];
            ctx.sn = _deviceID;
            ctx.target = self;
            ctx.protocol = [self.app.developerOption.playAgreement isEqualToString:@"rtmp"] || [self.app.developerOption.playAgreement isEqualToString:@"rtdp"] ? self.app.developerOption.playAgreement : @"rtdp";
            ctx.on_event = @selector(pushtalk_done:);
            [self.agent pushtalk:ctx];
        }
        else
        {
            _speaker_is_mute = 1;
            MMediaEngineEvent *evt = [_engine ctrl:_chl_id method:@"speaker.mute"  params:_speaker_is_mute?@"{value:1}":@"{value:0}"];
            if (self.app.is_luxcam) {
                _speakerButton.selected = _speaker_is_mute ? NO : YES;
            }
            else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
            {
                _speakerButton.selected = !_speaker_is_mute;
                if (self.app.is_vimtag) {
                    [self startPollingHideToolBar];
                }
            }
            else
            {
                [_speakerButtonItem setImage:[UIImage imageNamed:(_speaker_is_mute?@"speaker_mute.png":@"speaker_on2.png")]];
            }
            [_engine chl_destroy:_chl_id_audio_out];
            _chl_id_audio_out = 0;
            _in_audio_outing = 0;
            
        }
        
        if (self.app.is_luxcam) {
            UIButton *button = sender;
            button.selected = _in_audio_outing ? YES : NO;
        }
        else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
        {
            [_sizeView setHidden:YES];
            [_videoPixelsView setHidden:YES];
            _microphoneButton.selected = _in_audio_outing ? YES : NO;
        }
        else
        {
            UIBarButtonItem *buttonItem = sender;
            [buttonItem setImage:[UIImage imageNamed:(_in_audio_outing ? @"micphone_on3.png" : @"micphone_mute.png")] ];
        }
    }
    else
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                if(0 == _chl_id_audio_out)
                {
                    if (self.app.is_vimtag) {
                        [self stopPollingHideToolBar];
                    }
                    _in_audio_outing = 1;
                    
                    mcall_ctx_pushtalk *ctx = [[mcall_ctx_pushtalk alloc] init];
                    ctx.sn = _deviceID;
                    ctx.target = self;
                    ctx.protocol = [self.app.developerOption.playAgreement isEqualToString:@"rtmp"] || [self.app.developerOption.playAgreement isEqualToString:@"rtdp"] ? self.app.developerOption.playAgreement : @"rtdp";
                    ctx.on_event = @selector(pushtalk_done:);
                    [self.agent pushtalk:ctx];
                }
                else
                {
                    _speaker_is_mute = 1;
                    MMediaEngineEvent *evt = [_engine ctrl:_chl_id method:@"speaker.mute"  params:_speaker_is_mute?@"{value:1}":@"{value:0}"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.app.is_luxcam) {
                            _speakerButton.selected = _speaker_is_mute ? NO : YES;
                        }
                        else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
                        {
                            _speakerButton.selected = !_speaker_is_mute;
                            if (self.app.is_vimtag) {
                                [self startPollingHideToolBar];
                            }
                        }
                        else
                        {
                            [_speakerButtonItem setImage:[UIImage imageNamed:(_speaker_is_mute?@"speaker_mute.png":@"speaker_on2.png")]];
                        }
                    });
                    
                    [_engine chl_destroy:_chl_id_audio_out];
                    _chl_id_audio_out = 0;
                    _in_audio_outing = 0;
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.app.is_luxcam) {
                        UIButton *button = sender;
                        button.selected = _in_audio_outing ? YES : NO;
                    }
                    else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
                    {
                        [_sizeView setHidden:YES];
                        [_videoPixelsView setHidden:YES];
                        _microphoneButton.selected = _in_audio_outing ? YES : NO;
                    }
                    else
                    {
                        UIBarButtonItem *buttonItem = sender;
                        [buttonItem setImage:[UIImage imageNamed:(_in_audio_outing ? @"micphone_on3.png" : @"micphone_mute.png")] ];
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.app.is_vimtag) {
                        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_fail_microphone", nil) message:NSLocalizedString(@"mcs_microphone_prompt", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil) otherButtonTitles:nil] show];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_fail_microphone", nil) message:NSLocalizedString(@"", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil) otherButtonTitles:nil] show];
                    }
                });
            }
        }];
    }
}

- (IBAction)setupSpeaker:(id)sender
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
    
    if (!_speaker_is_mute)
    {
        if (![self isHeadsetPluggedIn]) {
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        }
    }
    
    if (self.app.is_luxcam) {
        UIButton *button = sender;
        button.selected = _speaker_is_mute ? NO : YES;
    }
    else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
    {
        [_speakerButton setImage:[UIImage imageNamed:(_speaker_is_mute? @"vt_voice_off.png":@"vt_voice.png")] forState:UIControlStateNormal];
        _speakerButton.selected = !_speaker_is_mute;
    }
    else
    {
        UIBarButtonItem *buttonItem = sender;
        [buttonItem setImage:[UIImage imageNamed:(_speaker_is_mute?@"speaker_mute.png":@"speaker_on2.png")]];
        //        [button setImage:[UIImage imageNamed:(_speaker_is_mute?@"speaker_mute.png":@"speaker_on2.png")] forState:UIControlStateNormal];
    }
}

//jc's add code
- (IBAction)setupLight:(id)sender
{
    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if (dev.ubx) {
        if (_speedAndModelControlView) {
            [self closeSpeedAndModelControlView];
        } else {
            [self speedAndModelCreateControlBoard];
        }
    } else {
        _light_is_on = !_light_is_on;
        
        mcall_ctx_exsw_set *ctx = [[mcall_ctx_exsw_set alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.enable = _light_is_on;
        ctx.on_event = @selector(exsw_set_done:);
        [self.agent exsw_set:ctx];
        
        NSLog(@"1========%ld %ld", _light_is_on,ctx.enable);
        
        if (!self.app.is_luxcam)
        {
            UIBarButtonItem *buttonItem = sender;
            [buttonItem setImage:[UIImage imageNamed:(_light_is_on ? @"battery_on.png":@"batterty_off.png")]];
        }
    }
}
//end

- (IBAction)setupTakePicture:(id)sender
{
    _snapshotButton.enabled = NO;
    if (!(self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)) {
        _snapshotButton.selected = YES;
    } else {
        [_sizeView setHidden:YES];
        [_videoPixelsView setHidden:YES];
    }
    if (_onsnapshot) {
        return;
    } else {
        _promptView.hidden = NO;
        _onsnapshot = YES;
        if (_onRecord) {
            _onRecord = NO;
            [_recordButtonItem setImage:[UIImage imageNamed:(_onRecord ? @"video-record.png":@"video-record1.png")]];
            if(_recordEngine)
            {
                if(_recordChl_id > 0)
                {
                    [_recordEngine chl_destroy:_chl_id];
                    _recordChl_id = 0;
                }
                [_recordEngine engine_destroy];
                _recordEngine = nil;
            }
            _recordTimeDuration = [[NSDate date] timeIntervalSinceDate:_recordStartTime];
            [self saveRecordToLocalDirectory];
        }
        if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            _snapshotButton.selected = _onsnapshot ? YES : NO;
            [_snapshotButton setImage:[UIImage imageNamed:self.app.is_vimtag ? @"vt_btn_camera_on.png" : (self.app.is_ebitcam ? @"eb_camera_on.png" : @"mi_camera_on.png")] forState:UIControlStateNormal];
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_snapshoting", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
            if (self.app.is_vimtag) {
                [self stopPollingHideToolBar];
            }
        }
        m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
        _snapshotAndRecordpromptLabel.text = NSLocalizedString(@"mcs_snapshoting", nil);
        mcall_ctx_snapshot *ctx = [[mcall_ctx_snapshot alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.type = mdev_pic_snapshot;
        ctx.size = @"720p";
        ctx.spv = dev.spv;
        ctx.on_event = @selector(snapshot_done:);
        [self.agent snapshot:ctx];
    }
}

//jc's add code
- (void)record_setupTakePicture
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
        ctx.type = mdev_pic_thumb;
        ctx.sn = _deviceID;
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.agent pic_url_create:ctx]]];
        
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        //        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"record_setupTakePicture:err[%@]", [error localizedDescription]);
            }
            else
            {
                _local_thumb_img = [UIImage imageWithData:data];
            }
        });
    });
}

- (IBAction)setupTakeRecord:(id)sender
{
    if (_isHandleRecord)
        return;
    if(0 == _onRecord)
    {
        if (self.app.is_vimtag) {
            [self stopPollingHideToolBar];
//            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_record_prompt", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
            _viewRecordPromptView.hidden = YES;
        } else {
             [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_record_download_prompt", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
        }
        [self beginTakeRecord];
    }
    else
    {
        [self endTakeRecord];

        if (self.app.is_vimtag) {
            [self startPollingHideToolBar];
            _viewRecordPromptView.hidden = NO;
        } else {
            [MNInfoPromptView hideAll:self.navigationController];
        }
    }
    if (self.app.is_luxcam)
    {
        UIButton *button = sender;
        [button setImage:[UIImage imageNamed:(_onRecord ? @"take_recording.png":@"take_record.png")] forState:UIControlStateNormal];
       
    }
    else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
    {
        [_sizeView setHidden:YES];
        [_videoPixelsView setHidden:YES];
        _recordButton.selected = _onRecord ? YES : NO;
    }
    else
    {
        UIBarButtonItem *buttonItem = sender;
        [buttonItem setImage:[UIImage imageNamed:(_onRecord ? @"video-record.png":@"video-record1.png")]];
    }
}
//end
- (IBAction)setupBrightness:(id)sender
{
    if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        [_sizeView setHidden:YES];
        [_videoPixelsView setHidden:!_videoPixelsView.isHidden];
        _videoPixelSetButton.selected = _videoPixelsView.isHidden ? NO : YES;
        //hide other view when brightness is no hide
        [self.navigationController setNavigationBarHidden:!_videoPixelsView.isHidden animated:YES];
        [self.selectControlView setHidden:!_videoPixelsView.isHidden];
        [self.sizeControlView setHidden:!_videoPixelsView.isHidden];
        [self.volumeControlView setHidden:!_videoPixelsView.isHidden];
        [self.sizeView setHidden:!_videoPixelsView.isHidden];
        
        if (_videoPixelsView.isHidden == NO) {
            [self refresh_cam_get];
            if (self.app.is_vimtag) {
                [self stopPollingHideToolBar];
            }
        } else {
            if (self.app.is_vimtag) {
                [self startPollingHideToolBar];
            }
        }
        
    } else {
        if(_controlBoard)
        {
            [self closeControlBoard];
        }
        else
        {
            [self createControlBoard];
            [self showOrHideOptionView:nil];
        }
    }
}

- (void)buttonUp:(id)sender
{
    mcall_ctx_ptz_ctrl *ctx = [[mcall_ctx_ptz_ctrl alloc] init];
    ctx.x = 0;
    ctx.y = 0;
    ctx.z = 1;
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(ptz_ctrl_done:);
    [self.agent ptz_ctrl:ctx];
}

- (void)buttonDown:(id)sender
{
    mcall_ctx_ptz_ctrl *ctx = [[mcall_ctx_ptz_ctrl alloc] init];
    ctx.x = 0;
    ctx.y = 0;
    ctx.z = -1;
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(ptz_ctrl_done:);
    [self.agent ptz_ctrl:ctx];
}

#pragma mark - Engine create
- (void)MIPC_EngineCreate:(NSString*)url
{
    if(nil != _engine)
    {
        [_engine removeFromSuperview];
        _engine = nil;
    }
    //
    // CGRect rect = CGRectMake(0, 0, 320, 200);
    _engine = [[MMediaEngine alloc] initWithFrame:self.view.bounds];
    
    //    _engine = [[MMediaEngine alloc] initWithFrame:rect];
    _engine.backgroundColor = [UIColor whiteColor];
    //_engine.backgroundColor = [UIColor redColor];
    
    _engine.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
    
    [self.view insertSubview:_engine atIndex:0];
    //    [self.containerView addSubview:_engine];
    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if (dev.ubx) {
        _buttonUp = [[UIButton alloc] initWithFrame:CGRectMake(5, _engine.frame.size.height / 2 - 30, 20, 30)];
        [_buttonUp setImage:[UIImage imageNamed:@"zmotor_up_bg.png"] forState:UIControlStateNormal];
        
        [_buttonUp addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchUpInside];
        _buttonDown = [[UIButton alloc] initWithFrame:CGRectMake(5, _engine.frame.size.height / 2, 20, 30)];
        [_buttonDown setImage:[UIImage imageNamed:@"zmotor_down_bg.png"] forState:UIControlStateNormal];
        [_buttonDown addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchUpInside];
        [_engine addSubview:_buttonUp];
        [_engine addSubview:_buttonDown];
    }
    //Create video engine
    NSString *engineKey = MIPC_GetEngineKey();
    if([_engine engine_create:engineKey refer:self onEvent:@selector(onMediaEvent:)])
    {
        [self mediaEndPlay];
        if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            self.videoPlayFailPromptView.hidden = NO;
            [_videoPlayFailPromptView refreshPromptTextWithStyle:MNVideoPlayFailPromptError];
        }
    }
    else
    {
        struct mipci_conf *conf = MIPC_ConfigLoad();
        NSString   *live_flow_ctrl = [NSString stringWithFormat:@"flow_ctrl:\"jitter\",jitter:{max:%d}",(conf && 0 != conf->buf)?conf->buf:3000];

        NSString   *params = [NSString stringWithFormat:@"{src:[{url:\"%@\"}], dst:[{url:\"data:/\",thread:\"istream\"}],trans:[{%@,thread:\"istream\"}],pic:{position:\"fit\"},speaker:{mute:%ld}, thread:\"channel\"}", url, live_flow_ctrl,_speaker_is_mute];   //?
        memset(_total_bytes, 0, sizeof(_total_bytes));
        memset(_total_bytes_tick, 0, sizeof(_total_bytes_tick));
        
        //Create channel
        if(0 >= (_chl_id = [_engine chl_create:params]))
        {
            [self mediaEndPlay];
            if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
                self.videoPlayFailPromptView.hidden = NO;
                [_videoPlayFailPromptView refreshPromptTextWithStyle:MNVideoPlayFailPromptError];
            }
        }
        else
        {
            
            NSLog(@"media engine create succeed and chl-create.");
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(networkSpeedStatus:) userInfo:_engine  repeats:YES];
            if (self.app.is_vimtag) {
                self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(pollingHideToolbar:) userInfo:nil repeats:YES];
                if (_sizeView.isHidden == NO)
                {
                    [self stopPollingHideToolBar];
                }
            }
            if (!(self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)) {
                [self startRecognizer:_engine];
            }
        }
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
        if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            self.videoPlayFailPromptView.hidden = NO;
            [_videoPlayFailPromptView refreshPromptTextWithStyle:MNVideoPlayFailPromptError];
        }
    }
    return 0;
}

- (void)onVideoArrived:(id)sender
{
    if(_active)
    {
        [self.progressHUD hide:YES];
    }
    
    _navigationToolbar.hidden = NO;
    
    //jc's add code
    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if(dev.exsw && !dev.ubx)
    {
        _lightButtonItem.enabled = YES;
        [_lightButton setImage:[UIImage imageNamed:(_light_is_on ? @"battery_on.png":@"batterty_off.png")] forState:UIControlStateNormal];
    }
    
    //end
    if (_automationMode &&_active) {
        [MNInfoPromptView hideAll:self.navigationController];
        [MNInfoPromptView showAndHideWithText:@"Video play Success" style:MNInfoPromptViewStyleAutomation isModal:NO navigation:self.navigationController];
    }
}

- (void)networkSpeedStatus:(NSTimer *)timer
{
    if(_engine && _chl_id)
    {
        @try{
            MMediaEngineEvent *evt = [_engine ctrl:_chl_id method:@"query" params:@"{}"];
            if(evt)
            {
                NSString            *data = evt.data;
                //                NSLog(@"%@",data);
                struct json_object  *obj = json_decode([data length], (char*)[data UTF8String]);
                long                speed_bytes, total_bytes = 0, is_buffering = 0, buffer_percent = 0, is_p2ping = 0, played_duration = 0, video_bytes = 0;
                unsigned long       tick = mtime_tick();
                json_get_child_long(obj, "buffering", &is_buffering);
                json_get_child_long(obj, "buffer_percent", &buffer_percent);
                json_get_child_long(obj, "p2ping", &is_p2ping);
                json_get_child_long(obj, "played_duration", &played_duration);
                if (_automationMode) {
                    json_get_child_long(obj, "video_bytes", &video_bytes);
                    NSLog(@"video bytes:%ld",video_bytes);
                    _automationLabel.accessibilityValue = [NSString stringWithFormat:@"%ld",video_bytes];
                }
                
                if(0 == json_get_child_long(obj, "total_bytes", &total_bytes))
                {
                    long new_status, sub_bytes = total_bytes - _total_bytes[0];
                    speed_bytes = (sub_bytes * 1000)/((_total_bytes_tick[0] && (tick != _total_bytes_tick[0]))?((tick - _total_bytes_tick[0])>0 ? (tick - _total_bytes_tick[0]):1000):1000);
                    new_status = (speed_bytes * 3) / (_standSpeedBytes?_standSpeedBytes:(40*1024));
                    {
                        NSString    *nsDuration = @"";
                        _lblSpeed.text = [NSString stringWithFormat:@"%@%ld%@B", nsDuration, speed_bytes/1024, is_p2ping?@"k":@"K"];
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
        @catch (NSException *e){
            NSLog(@"%@~%@",e.name,e.reason);
            [self mediaEndPlay];
            if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
                self.videoPlayFailPromptView.hidden = NO;
                [_videoPlayFailPromptView refreshPromptTextWithStyle:MNVideoPlayFailPromptError];
            }
        }
    }
}

- (void)pollingHideToolbar:(NSTimer *)timer
{
    BOOL isHid = self.navigationController.navigationBar.hidden;
    if (!isHid && _active) {
        [self.navigationController setNavigationBarHidden:!isHid animated:YES];
        [self.selectControlView setHidden:!isHid];
        [self.sizeControlView setHidden:!isHid];
        [self.volumeControlView setHidden:!isHid];
        [self.videoPixelsView setHidden:YES];
        [self.sizeView setHidden:YES];
    }
    
    [self checkNavigationAlpha];
}

- (void)startPollingHideToolBar
{
    if(_pollingTimer)
    {
        [self.pollingTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    }
}

- (void)stopPollingHideToolBar
{
    if (_pollingTimer) {
        [self.pollingTimer setFireDate:[NSDate distantFuture]];
    }
}

#pragma mark - Media
- (void)mediaBeginPlay
{
    [self.progressHUD show:YES];
    if (_videoPlayFailPromptView) {
        self.videoPlayFailPromptView.hidden = YES;
    }
    
    struct mipci_conf *conf = MIPC_ConfigLoad();
    if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        _curProfileID = (conf && conf->profile_id<5)?conf->profile_id:1;
        if (2 == _curProfileID)
        {
            [_sizeSelectButton setTitle:NSLocalizedString(@"mcs_fluent_clear", nil) forState:UIControlStateNormal];
        }
        else if (1 == _curProfileID)
        {
            [_sizeSelectButton setTitle:NSLocalizedString(@"mcs_standard_clear", nil) forState:UIControlStateNormal];
        }
        else if (_curProfileID == 0) {
            [_sizeSelectButton setTitle:_highClearSizeButton.titleLabel.text forState:UIControlStateNormal];
        } else {
            [_sizeSelectButton setTitle:NSLocalizedString(@"mcs_auto", nil) forState:UIControlStateNormal];
        }
    } else {
        _curProfileID = (conf && conf->profile_id<3)?conf->profile_id:1;
    }
    
    mcall_ctx_play *ctx = [[mcall_ctx_play alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    //
    ctx.on_event = @selector(play_done:);
    NSString *size = nil;
    
//    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *filePAth = [homePath stringByAppendingPathComponent:@"userBehaviours"];
//    MNUserBehaviours *behaviors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePAth];
//    PlayToken *playToken = behaviors.playToken;

    if (self.app.is_vimtag) {
        switch (_curProfileID) {
            case 0:
                size = @"p0";
//                playToken.p0_token ++;
                break;
            case 2:
                size = @"p2";
//                playToken.p2_token ++;
                break;
            default:
                size = @"p1";
//                playToken.p1_token ++;
                break;
        }
    } else {
        switch (_curProfileID) {
            case 0:
                size = @"p0";
//                playToken.p0_token ++;
                break;
            case 2:
                size = @"p2";
//                playToken.p2_token ++;
                break;
            case 3:
                size = @"p3";
//                playToken.p3_token ++;
                break;
            default:
                size = @"p1";
//                playToken.p1_token ++;
                break;
        }
    }
//    behaviors.playToken = playToken;
//    [NSKeyedArchiver archiveRootObject:behaviors toFile:filePAth];
    
    ctx.token = size;
    ctx.protocol = [self.app.developerOption.playAgreement isEqualToString:@"rtmp"] || [self.app.developerOption.playAgreement isEqualToString:@"rtdp"] ? self.app.developerOption.playAgreement : @"rtdp";
    [self.agent play:ctx];
 
}

- (void)mediaEndPlay
{
    _lblSpeed.text = nil;
    
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    if (_pollingTimer)
    {
        [_pollingTimer invalidate];
        _pollingTimer = nil;
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
    
    if (_automationMode) {
        _automationLabel.accessibilityValue = @"";
    }
    
    [self.progressHUD hide:YES];
}

//show times
- (void)showRecordTime:(NSTimer *)timer
{
    NSString *nshh,*nsmm,*nsss;
    NSInteger hh,mm,ss;
    hh = recordTotalTimes/3600;
    mm = (recordTotalTimes%3600)/60;
    ss =recordTotalTimes%60;
    nshh = [NSString stringWithFormat:hh<10? @"0%d" : @"%d",(int)hh];
    nsmm = [NSString stringWithFormat:mm<10? @"0%d" : @"%d",(int)mm];
    nsss = [NSString stringWithFormat:ss<10? @"0%d" : @"%d",(int)ss];
    
    recordTotalTimes ++;
    _recordTimerLabel.text = [NSString stringWithFormat:@"%@:%@:%@",nshh,nsmm,nsss];
}

- (void)beginTakeRecord
{
    _onRecord = 1;
    //get a picture
    if (self.app.is_vimtag) {
        recordTotalTimes = 0;
        self.recordTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showRecordTime:) userInfo:nil repeats:YES];
        [self.recordTimer fire];
        [_recordTimerView setHidden:NO];
    } else {
        _promptView.hidden = NO;
        _snapshotAndRecordpromptLabel.text = NSLocalizedString(@"mcs_recording", nil);
    }
    [self record_setupTakePicture];
    //create engine
    [self downloadMp4WithURL:_recordUrl];
}

- (void)endTakeRecord
{
    //    if(_keepRecord)
    //    {
    //        [_keepRecord invalidate];
    //        _keepRecord = nil;
    //    }
    _onRecord = 0;
    _promptView.hidden = YES;
    if (self.app.is_vimtag) {
        [_recordTimerView setHidden:YES];
        [self.recordTimer setFireDate:[NSDate distantFuture]];
        if ([self.recordTimer isValid] == YES) {
            [self.recordTimer invalidate];
            self.recordTimer = nil;
            [_recordTimerLabel setText:@"00:00:00"];
        }
    }
    NSLog(@"endTakeRecord");
    if(_recordEngine)
    {
        if(_recordChl_id > 0)
        {
            [_recordEngine chl_destroy:_chl_id];
            _recordChl_id = 0;
        }
        [_recordEngine engine_destroy];
        _recordEngine = nil;
    }
    _recordTimeDuration = [[NSDate date] timeIntervalSinceDate:_recordStartTime];
    [self saveRecordToLocalDirectory];
}

#pragma mark - Network Callback
- (void)play_done:(mcall_ret_play*)ret
{
    if (self.app.is_luxcam) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
//    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
    
    if(_active && ret.result == nil && ret.url.length)
    {
//        MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaViours.dev_play_succ_times += 1;
//        [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
        
        [self MIPC_EngineCreate:ret.url];
    }
    else if (_active && ret.result != nil && [ret.result isEqualToString:@"ret.dev.offline"])
    {
//        MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaViours.dev_play_fail_times += 1;
//        [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
        
        if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            self.videoPlayFailPromptView.hidden = NO;
            [_videoPlayFailPromptView refreshPromptTextWithStyle:MNVideoPlayFailPromptOffline];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_device_offline", nil)]];
        }
        [self.progressHUD hide:YES];
    }
    else
    {
        if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            self.videoPlayFailPromptView.hidden = NO;
            [_videoPlayFailPromptView refreshPromptTextWithStyle:MNVideoPlayFailPromptError];
        }
        [self.progressHUD hide:YES];
    }
    //jc's add code
    _recordUrl = ret.url;
    //end
}

- (void)upgrade_get_done:(mcall_ret_upgrade_get *)ret
{
    if ((ret.ver_valid.length != 0 && ret.ver_current.length != 0 && ![ret.ver_valid isEqualToString:ret.ver_current])
        || (ret.hw_ext.length != 0 && ![ret.hw_ext isEqualToString:ret.prj_ext])){
        UIView *badgeView = [[UIView alloc]init];
        badgeView.layer.cornerRadius = 7;//
        badgeView.backgroundColor = [UIColor redColor];//
        badgeView.frame = CGRectMake( 22, 3, 14, 14); //(_settingButton.center.x +15,);
        [_settingButton addSubview:badgeView];
        
        _ver_valid = YES;
        
        //Show upgrade prompt
        if (_active &&(!_isExperienceAccount) && (!self.app.isLocalDevice) && (!_hideUpgradeTips)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_camera_found_new_version_y_n_upgrade", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_donot_remind", nil) otherButtonTitles:NSLocalizedString(@"mcs_yes_verif", nil), NSLocalizedString(@"mcs_no_verif", nil), nil];
            alertView.tag = UPGRADE_TAG;
            [alertView show];
        }
    }
}

- (void)dev_msg_listener:(mdev_msg *)msg
{
    m_dev *device = [self.agent.devs get_dev_by_sn:msg.sn];
    //    NSLog(@"%@",msg.type);
    if ([msg.type isEqualToString:@"snapshot"] || [msg.type isEqualToString:@"record"])
    {
        if(msg.msg_id > device.msg_id_max)
        {
            device.msg_id_max = msg.msg_id;
        }
    }
    if (msg.exsw) {
        msg.exsw ? (_light_is_on = YES) : (_light_is_on = NO);
        [_lightButtonItem setImage:[UIImage imageNamed:(_light_is_on ? @"battery_on.png":@"batterty_off.png")]];
    } else  if(device.ubx){
        [self speedAndModelCreateControlBoard];
        if ([msg.mode isEqualToString:@"smart"]) {
            _speedAndModelControlView.modeValue = 1;
        } else if([msg.mode isEqualToString:@"plan"]){
            _speedAndModelControlView.modeValue = 2;
        } else if ([msg.mode isEqualToString:@"mute"]){
            _speedAndModelControlView.modeValue = 3;
        }
        _speedAndModelControlView.windSpeedValue = [msg.windSpeed integerValue];
        
        _speedAndModelControlView.bartteyPower = [msg.bp floatValue];
        
        float grade = _speedAndModelControlView.bartteyPower/ 100.0;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, _batteryView.frame.size.height * (1 - grade), _batteryView.frame.size.width, _batteryView.frame.size.height * grade)];
        view.backgroundColor = [UIColor greenColor];
        
        if (1 <= grade) {
            _batteryHeaderView.backgroundColor = [UIColor greenColor];
        }
        _batteryNumber.text = [NSString stringWithFormat:@"%d", (int)(grade >= 1 ? 100:(grade*100)) ];
        _batteryNumber.text = @"74";
        [_batteryView addSubview:view];
    }
    if (self.app.is_vimtag) {
        if ([msg.sn isEqualToString:_deviceID]) {
            if (device.support_scene) {
                if ([msg.type isEqualToString:@"alert"]) {
                    if ([msg.code isEqualToString:@"motion_alert"] && [msg.event isEqualToString:@"start"]) {
                        _msgImageView.image =[UIImage imageNamed:@"vt_play_move"];
                    } else if ([msg.code isEqualToString:@"motion_alert"] && [msg.event isEqualToString:@"stop"]) {
                        _msgImageView.image = [UIImage imageNamed:@""];
                    }
                    if ([msg.code isEqualToString:@"sos"]) {
                        _msgImageView.image = [UIImage imageNamed:@"vt_play_sos"];
                    }
                    if ([msg.code isEqualToString:@"door"]) {
                        _msgImageView.image = [UIImage imageNamed:@"vt_play_door"];
                    }
                }
            } else {
                if ([msg.alert isEqualToString:@"start"] && [device.img_ver compare:@"v3"] ==  NSOrderedDescending) {
                    _msgImageView.image =[UIImage imageNamed:@"vt_play_move"];
                }else if ([msg.alert isEqualToString:@"stop"]) {
                    _msgImageView.image = [UIImage imageNamed:@""];
                }
                
                if ([msg.type isEqualToString:@"alert"]) {
                    if ([msg.code isEqualToString:@"sos"]) {
                        _msgImageView.image = [UIImage imageNamed:@"vt_play_sos"];
                    }
                }
                if ([msg.type isEqualToString:@"alert"]) {
                    if ([msg.code isEqualToString:@"door"]) {
                        _msgImageView.image = [UIImage imageNamed:@"vt_play_door"];
                    }
                }
            }
        }
    }
}

- (void)dev_info_get_done:(mcall_ret_dev_info_get *)ret
{
    if (ret.result == nil) {
        if (ret.p0.length) {
            _resolution = [NSString stringWithFormat:@"%@",ret.p0];
            if ([_resolution respondsToSelector:@selector(rangeOfString:)] && ([_resolution rangeOfString:@"1080"].length || [_resolution rangeOfString:@"960"].length || [_resolution rangeOfString:@"720"].length)) {
                [_highClearSizeButton setTitle:([_resolution rangeOfString:@"1080"].length ? NSLocalizedString(@"mcs_hd_1080P", nil) : ([_resolution rangeOfString:@"960"].length ? NSLocalizedString(@"mcs_hd_960P", nil) : NSLocalizedString(@"mcs_hd_720P", nil))) forState:UIControlStateNormal];
                DeviceInfo *obj = [[DeviceInfo alloc] init];
                obj.resolution = _resolution;
                obj.hideUpgradeTips = _hideUpgradeTips;
                obj.hideTimezoneTips = _hideTimezoneTips;
                NSData *deviceData = [NSKeyedArchiver archivedDataWithRootObject:obj];
                [[NSUserDefaults standardUserDefaults] setObject:deviceData forKey:[NSString stringWithFormat:@"DeviceInfo_%@",_deviceID]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        [self mediaBeginPlay];
        _is_play = 1;
    }else {
        [self.progressHUD hide:YES];
        if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_ebitcam) {
            self.videoPlayFailPromptView.hidden = NO;
            [_videoPlayFailPromptView refreshPromptTextWithStyle:MNVideoPlayFailPromptError];
        }
    }
}

- (void)dev_timezone_get_done:(mcall_ret_dev_info_get *)ret
{
    if (ret.result != nil) {
        return;
    }
    if (_active && !_hideTimezoneTips) {
        NSTimeInterval phoneTimezone = [self getTimeIntervalBetweenTimeZoneAndUTC];
        if ([ret.timezone intValue]*60*60 != phoneTimezone) {
            _setTimezoneView.hidden = NO;
            _setTimezoneLabel.text = [NSString stringWithFormat:@"%@%@, %@", NSLocalizedString(@"mcs_set_timezone_prompt_start", nil), [NSTimeZone localTimeZone].name, NSLocalizedString(@"mcs_set_timezone_prompt_end", nil)];
        }
    }
}

//jc's add code
#pragma mark - DownLoad Engine Create
- (void)get_location_time
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *hms_formatter = [[NSDateFormatter alloc] init];
    [hms_formatter setCalendar:calendar];
    [hms_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _showDateString = [hms_formatter stringFromDate:[NSDate date]];
    
    [hms_formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    _ShareDateString = [hms_formatter stringFromDate:[NSDate date]];
    
}

- (void)downloadMp4WithURL:(NSString *)url
{
    [self get_location_time];
    if(nil != _recordEngine)
    {
        _recordEngine = nil;
    }
    
    _recordEngine = [[MMediaEngine alloc] initWithFrame:CGRectNull];
    NSString *engineKey = MIPC_GetEngineKey();
    long failed = [_recordEngine engine_create:engineKey refer:self onEvent:nil];
    if (failed) {
        NSLog(@"engine_create failed");
        return;
    }
    
    //video connection
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *videoDirectory =[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@", _deviceID]];
    
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:videoDirectory isDirectory:&isDirectory];
    if (!isFileExist || !isDirectory) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
    NSString *mp4File = [_deviceID stringByAppendingFormat:@"_%@.mp4", _ShareDateString];
    
    self.recordMp4FilePath = [videoDirectory stringByAppendingPathComponent:mp4File];
    
    NSString   *params = [NSString stringWithFormat:@"{src:[{url:\"%@\"}], dst:[{url:\"file://%@\",thread:\"channel\"}],speaker:{mute:1},audio:{type:\"none\"}, thread:\"channel\",canvas:\"none\"}", url, _recordMp4FilePath];
    
    if(0 >= (_recordChl_id = [_recordEngine chl_create:params]))
    {
        NSLog(@"recordEngine create failed!");
        
    }
    else
    {
        NSLog(@"record engine create succeed and chl-create.");
        _recordStartTime = [NSDate date];
//        if (self.app.is_vimtag) {
//            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_record_prompt", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
//        }
        //        self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordNetworkSpeedStatus:) userInfo:_recordEngine  repeats:YES];
    }
    
}

- (void)saveRecordToLocalDirectory
{
    
    NSString *duration = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)_recordTimeDuration/3600,(int)_recordTimeDuration/60, (int)_recordTimeDuration % 60];
    
    LocalVideoInfo *videoInfo = [[LocalVideoInfo alloc] init];
    videoInfo.deviceId = _deviceID;
    videoInfo.image = _local_thumb_img;
    videoInfo.duration = duration;
    videoInfo.mp4FilePath = _recordMp4FilePath;
    videoInfo.date = _showDateString;
    videoInfo.type = @"record";
    
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *videoDirectory =[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@", _deviceID]];
    
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:videoDirectory isDirectory:&isDirectory];
    if (!isFileExist || !isDirectory) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    NSString *videoInfoPath = [videoDirectory stringByAppendingPathComponent:[_deviceID stringByAppendingFormat:@"_%@.inf", _ShareDateString]];
    
    [NSKeyedArchiver archiveRootObject:videoInfo toFile:videoInfoPath];
    
    //test
    DirectoryConf *directoryConf = [[DirectoryConf alloc] init];
    directoryConf.directoryId = _deviceID;
    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    directoryConf.nick = dev.nick;
    
    NSString *directoryConfPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@.conf", directoryConf.directoryId]];
    [NSKeyedArchiver archiveRootObject:directoryConf toFile:directoryConfPath];
    //test
    if (self.app.is_vimtag) {
        _viewRecordPromptImage.image = _local_thumb_img;
    }

}
//end

#pragma mark - Create view
- (void)createControlBoard
{
    CGFloat width = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?300.f:300.f,
    x = (self.view.bounds.size.width - width)*.5f;
    
    _controlBoard = [[MNControlBoardView alloc] initWithFrame:CGRectMake(x, -150, width, 260.f)];
    _controlBoard.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
    |UIViewAutoresizingFlexibleBottomMargin;
    if ([_resolution respondsToSelector:@selector(rangeOfString:)]) {
        _controlBoard.HDString = [_resolution rangeOfString:@"1080"].length ? NSLocalizedString(@"mcs_hd_1080P", nil) : ([_resolution rangeOfString:@"960"].length ? NSLocalizedString(@"mcs_hd_960P", nil) : NSLocalizedString(@"mcs_hd_720P", nil));
    } else {
        _controlBoard.HDString = NSLocalizedString(@"mcs_hd_720P", nil);
    }
    __weak typeof(self) weakself = self;
    __weak typeof(_controlBoard) weakControlBoard = _controlBoard;
    
    _controlBoard.valueChanged = ^(id sender ,float value[]){
        mcall_ctx_cam_set *ctx = [[mcall_ctx_cam_set alloc] init];
        if (1001 == ((UIView*)sender).tag) {
            [weakself mediaEndPlay];
            [weakself mediaBeginPlay];
        }
        else
        {
            if(999 == ((UIView*)sender).tag)
            {
                ((UISlider*)[weakControlBoard viewWithTag:1100]).value = 50.f;
                ((UISlider*)[weakControlBoard viewWithTag:1101]).value = 60.f;
                ((UISlider*)[weakControlBoard viewWithTag:1102]).value = 70.f;
                ((UISlider*)[weakControlBoard viewWithTag:1103]).value = 6.f;
                ((UISegmentedControl*)[weakControlBoard viewWithTag:888]).selectedSegmentIndex = 0;
                ctx.brightness = 50;
                ctx.contrast = 60;
                ctx.saturation = 70;
                ctx.sharpness = 6;
                ctx.flip = weakself.cam_get ? weakself.cam_get.flip : 0;
                ctx.flicker_freq = weakself.cam_get ? weakself.cam_get.flicker_freq : 1;
                ctx.resolute = weakself.cam_get ? weakself.cam_get.resolute : nil;
            }
            else
            {
                ctx.brightness = value[0];
                ctx.contrast = value[1];
                ctx.saturation = value[2];
                ctx.sharpness = value[3];
                ctx.flip = weakself.cam_get ? weakself.cam_get.flip : 0;
                ctx.flicker_freq = weakself.cam_get ? weakself.cam_get.flicker_freq : 1;
                ctx.resolute = weakself.cam_get ? weakself.cam_get.resolute : nil;
                
                NSString *mode = @"auto";
                int index =  value[4];
                if(1 == index)
                {
                    mode = @"day";
                }
                else if (2 == index)
                {
                    mode = @"night";
                }
                else
                {
                    mode = @"auto";
                }
                
                ctx.day_night = mode;
            }
            
            ctx.on_event = @selector(cam_set_done:);
            ctx.target = weakself;
            ctx.sn = weakself.deviceID;
            [weakself.agent cam_set:ctx];
        }
    };
    
    mcall_ctx_cam_get *ctx = [[mcall_ctx_cam_get alloc] init];
    ctx.on_event = @selector(cam_get_done:);
    ctx.target = weakself;
    ctx.sn = weakself.deviceID;
    [weakself.agent cam_get:ctx];
    _controlBoard.selectedStyle = ^(id sender){
        if (((UIButton*)sender).tag == SHARPNESS_TAG)
        {
            mcall_ctx_cam_get *ctx = [[mcall_ctx_cam_get alloc] init];
            ctx.on_event = @selector(cam_get_done:);
            ctx.target = weakself;
            ctx.sn = weakself.deviceID;
            [weakself.agent cam_get:ctx];
            
        }
        else if (((UIButton*)sender).tag == PRESETPOINT_TAG)
        {
            mcall_ctx_cursise_get *ctx = [[mcall_ctx_cursise_get alloc] init];
            ctx.sn = weakself.deviceID;
            ctx.target = weakself;
            ctx.on_event = @selector(cursise_get_done:);
            
            [weakself.agent alarm_curise_get:ctx];
        }
    };
    
    _controlBoard.selectedPreset = ^(NSInteger index)
    {
        for (curise_point *point in weakself.curise_points) {
            if (point.index == index) {
                mcall_ctx_cursise_set *ctx = [[mcall_ctx_cursise_set alloc] init];
                ctx.sn = weakself.deviceID;
                ctx.target = weakself;
                ctx.on_event = @selector(curise_set_done:);
                ctx.index = (int)index;
                ctx.type = @"move";
                
                [weakself.agent alarm_curise_set:ctx];
                break;
            }
        }
    };
    
    _controlBoard.setupPreset = ^(NSInteger index, BOOL enable){
        mcall_ctx_cursise_set *ctx = [[mcall_ctx_cursise_set alloc] init];
        ctx.sn = weakself.deviceID;
        ctx.target = weakself;
        ctx.on_event = @selector(curise_set_done:);
        ctx.index = (int)index;
        ctx.type = enable?@"store":@"delete";
        
        [weakself.agent alarm_curise_set:ctx];
    };
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_controlBoard.frame) - 30, 5, 25, 25)];
    [cancelButton setImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(closeControlBoard) forControlEvents:UIControlEventTouchUpInside];
    
    [_controlBoard addSubview:cancelButton];
    
    [self.view addSubview:_controlBoard];
    
    [UIView animateWithDuration:0.3 animations:^{
        _controlBoard.center = self.view.center;
    }];
}

- (void)speedAndModelCreateControlBoard
{
    CGFloat width = 300.f;
    CGFloat x = (self.view.bounds.size.width - width)*.5f;
    _speedAndModelControlView = [[MNSpeedAndModelControlView alloc]initWithFrame:CGRectMake(x , 150, width, 140.f)];
    UIButton *cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_speedAndModelControlView.frame) - 30, 5, 25, 25)];
    [cancleButton  setImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(setupLight:) forControlEvents:UIControlEventTouchUpInside];
    [_speedAndModelControlView addSubview:cancleButton];
    _speedAndModelControlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    
    mcall_ctx_uart_set *ctx = [[mcall_ctx_uart_set alloc] init];
    ctx.code = @"query";
    ctx.filter = @"filter";
    ctx.value = @"stat";
    ctx.on_event = @selector(uart_get_done:);
    ctx.target = self;
    ctx.sn = _deviceID;
    [self.agent uart_set:ctx];
    
    __weak typeof(self) weakSelf = self;
//    __weak typeof(_speedAndModelControlView) weakspeedAndModelControlView =  _speedAndModelControlView;
    _speedAndModelControlView.valueChanged = ^(id sender, NSInteger value){
        mcall_ctx_uart_set *ctx = [[mcall_ctx_uart_set alloc] init];
        ctx.filter = @"value";
        if (888 == ((UIView *)sender).tag) {
            ctx.code = @"purify_mode";
            switch ((int)value) {
                case 0:
                    ctx.value = @"smart";
                    break;
                case 1:
                    ctx.value = @"plan";
                    break;
                case 2:
                    ctx.value = @"mute";
                default:
                    break;
            }
            
        } else if (999 == ((UIView *)sender).tag){
            ctx.code = @"fan";
            ctx.value = [NSString stringWithFormat:@"%d", (int)value + 1];
        }
        ctx.on_event = @selector(uart_set_done:);
        ctx.target = weakSelf;
        ctx.sn = weakSelf.deviceID;
        [weakSelf.agent uart_set:ctx];
    };
    
    [self.view addSubview:_speedAndModelControlView];
    [UIView animateWithDuration:0.3 animations:^{
        _speedAndModelControlView.center = self.view.center;
    }];
    
    
}

- (void)closeControlBoard
{
    if(_controlBoard)
    {
        [UIView animateWithDuration:0.2 animations:^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(closeControlBoard) object:nil];
            _controlBoard.alpha = 0.2f;
        }completion:^(BOOL finished){
            [_controlBoard removeFromSuperview];
            _controlBoard = nil;
        }];
    }
    else
    {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:.5f
                         animations:^{
                             _optionSelectView.alpha = _optionSelectView.alpha?0:1;
                         }
                         completion:^(BOOL finish){
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         }
         ];
        
    }
}

- (void)closeSpeedAndModelControlView
{
    if(_speedAndModelControlView)
    {
        [_speedAndModelControlView removeFromSuperview];
        _speedAndModelControlView = nil;
    }
    else
    {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:.5f
                         animations:^{
                             _optionSelectView.alpha = _optionSelectView.alpha?0:1;
                         }
                         completion:^(BOOL finish){
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         }
         ];
        
    }
    
}

- (void)hiddenControlView
{
    if(_controlBoard)
    {
        [self closeControlBoard];
    }
    else
    {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [UIView animateWithDuration:.2f animations:^{
            if (self.app.is_vimtag) {
                BOOL isHid = self.navigationController.navigationBar.hidden;
                if (!isHid) {
                    if (_onRecord || _onsnapshot || _in_audio_outing) {
                        
                    } else {
                        [self stopPollingHideToolBar];
                    }
                }
                [self.navigationController setNavigationBarHidden:!isHid animated:YES];
                [self.selectControlView setHidden:!isHid];
                [self.sizeControlView setHidden:!isHid];
                [self.volumeControlView setHidden:!isHid];
                [self.videoPixelsView setHidden:YES];
                [self.sizeView setHidden:YES];
                _videoPixelSetButton.selected = _videoPixelsView.isHidden ? NO : YES;
                
                [self checkNavigationAlpha];
            } else if (self.app.is_ebitcam || self.app.is_mipc) {
                BOOL isHid = self.navigationController.navigationBar.hidden;

                [self.navigationController setNavigationBarHidden:!isHid animated:YES];
                [self.selectControlView setHidden:!isHid];
                [self.sizeControlView setHidden:!isHid];
                [self.videoPixelsView setHidden:YES];
                [self.sizeView setHidden:YES];
                _videoPixelSetButton.selected = _videoPixelsView.isHidden ? NO : YES;
                
                [self checkNavigationAlpha];
            } else {
                BOOL isHid = self.tabBarController.tabBar.hidden;
                [self.tabBarController.tabBar setHidden:!isHid];
                
                if (self.app.is_luxcam) {
                    _optionSelectView.alpha = _optionSelectView.alpha?0:1;
                    [self.navigationController setNavigationBarHidden:!isHid animated:YES];
                    
                }
                else
                {
                    _navigationToolbar.hidden = !isHid;
                    if (_onsnapshot || _onRecord) {
                        _promptView.hidden = !isHid;
                    }
                    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
                        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
                            !isHid ? (_ViewToTopLayoutConstraint.constant = 0 ): (_ViewToTopLayoutConstraint.constant = 44);
                        } else {
                            !isHid ? (_ViewToTopLayoutConstraint.constant = 20 ): (_ViewToTopLayoutConstraint.constant = 64);
                        }
                    }
                }
            }
        }completion:^(BOOL finish){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            if (self.app.is_vimtag) {
                if (_onRecord || _onsnapshot || _in_audio_outing) {
                    
                } else {
                    [self startPollingHideToolBar];
                }
            }
        }];
    }
}

#pragma mark - Luxcam action
- (IBAction)gotoMessagesView:(id)sender
{
    if (self.app.is_vimtag && _pollingTimer)
    {
        [_pollingTimer invalidate];
        _pollingTimer = nil;
    }
    if (self.app.is_vimtag) {
        if ([[UIDevice currentDevice] orientation] != UIDeviceOrientationPortrait) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        }
    }
    [self performSegueWithIdentifier:@"MNMessagePageViewController" sender:nil];
}

- (IBAction)gotoSettingsView:(id)sender
{
    if (self.app.is_vimtag && _pollingTimer)
    {
        [_pollingTimer invalidate];
        _pollingTimer = nil;
    }
    if (self.app.is_vimtag) {
        if ([[UIDevice currentDevice] orientation] != UIDeviceOrientationPortrait) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        }
    }
    [self performSegueWithIdentifier:@"MNSettingsDeviceViewController" sender:nil];
}

- (IBAction)Luxcam_back:(id)sender {
    UIViewController *viewController = [[UIViewController alloc] init];
    BOOL isLanIPC = YES;
    for (viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[MNDeviceListViewController class]]) {
            isLanIPC = NO;
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    if (isLanIPC) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark- GestureRecognizer & TouchEvent
- (void)startRecognizer:(UIView*)view
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenControlView)];
    tap.numberOfTapsRequired = 1;
   
    [view addGestureRecognizer:tap];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.startPoint = [touch locationInView:self.view];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    self.endPoint = [touch locationInView:self.view];
    
    float distanceX = self.endPoint.x - self.startPoint.x;
    float distanceY = self.endPoint.y - self.startPoint.y;
    
    long moveStepX = 0;
    long moveStepY = 0;
    
    if (fabsf(distanceX) > fabsf(distanceY) ) {
        moveStepX = -distanceX;
    }else{
        moveStepY = distanceY;
    }
    
    //get the video scale of camera
    float currentScale = _engine.scale;
    
    int viewWidth = self.view.bounds.size.width;
    int viewHeight = self.view.bounds.size.height;
    
    double angleX = moveStepX * 50 /viewWidth;
    double angleY = moveStepY * 28.125 /viewHeight;
    int stepX = (int) (angleX * 3.11/currentScale);
    int stepY = (int) (angleY * 1.6/currentScale);
    //    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    mcall_ctx_ptz_ctrl *ctx = [[mcall_ctx_ptz_ctrl alloc] init];
    ctx.x = stepX;
    ctx.y = stepY;
    
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(ptz_ctrl_done:);
    [self.agent ptz_ctrl:ctx];
    if (self.app.is_vimtag) {
        [self startActivityIndicator];
        if (_onRecord || _onsnapshot || _in_audio_outing) {
            
        } else {
            [self stopPollingHideToolBar];
        }
    }
}

-(void)ptz_ctrl_done:(mcall_ret_ptz_ctrl*)ret
{
    if (self.app.is_vimtag) {
        [self stopActivityIndicator];
        if (_onRecord || _onsnapshot || _in_audio_outing) {
            
        } else {
            [self startPollingHideToolBar];
        }
    }
}

- (void)startActivityIndicator
{
    _ptzActivityIndicatorView.hidden = NO;
    [_ptzActivityIndicatorView startAnimating];
}

- (void)stopActivityIndicator
{
    _ptzActivityIndicatorView.hidden = YES;
    [_ptzActivityIndicatorView stopAnimating];
}

#pragma mark- Callback done
-(void)pushtalk_done:(mcall_ret_pushtalk *)ret
{
    if (!_active)
    {
        return;
    }
    NSLog(@"ipc view get audio out url ret");
    if(ret && 0 == ret.url.length)
    {
        NSLog(@"get out audio url failed.");
        _speaker_is_mute = 1;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.app.is_luxcam) {
                _microphoneButton.selected = NO;
                _speakerButton.selected = _speaker_is_mute ? NO : YES;
            }
            else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
            {
                if ([ret.result isEqualToString:@"ret.permission.denied"]) {
                    [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
                }
                _microphoneButton.selected = NO;
                _speakerButton.selected = !_speaker_is_mute;
            }
            else
            {
                [_microphoneButtonItem setImage:[UIImage imageNamed:@"micphone_mute.png"]];
                [_speakerButtonItem setImage:[UIImage imageNamed:(_speaker_is_mute?@"speaker_mute.png":@"speaker_on2.png")]];
            }
        });
        
        return;
    }
    
    _chl_id_audio_out = [_engine chl_create:[NSString stringWithFormat:@"{dst:[{url:\"%@\"}]}",ret.url]];
    
    if(0 >= _chl_id_audio_out)
    {
        NSLog(@"create out audio failed.");
        _chl_id_audio_out = 0;
        _speaker_is_mute = 1;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.app.is_luxcam) {
                _microphoneButton.selected = NO;
                _speakerButton.selected = _speaker_is_mute ? NO : YES;
            }
            else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
            {
                _microphoneButton.selected = NO;
                if (self.app.is_vimtag) {
                    [self stopPollingHideToolBar];
                }
                _speakerButton.selected = !_speaker_is_mute;
            }
            else
            {
                [_micButton setImage:[UIImage imageNamed:@"micphone_mute.png"] forState:UIControlStateNormal];
                [_speakerButtonItem setImage:[UIImage imageNamed:(_speaker_is_mute?@"speaker_mute.png":@"speaker_on2.png")]];
            }
        });
    }
    else
    {
        NSLog(@"create out audio chl[%ld].", _chl_id_audio_out);
        if (_speaker_is_mute) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _speaker_is_mute = !_speaker_is_mute;
                MMediaEngineEvent *evt = [_engine ctrl:_chl_id method:@"speaker.mute"  params:_speaker_is_mute?@"{value:1}":@"{value:0}"];  //?
                if((nil == evt) || evt.status)
                {
                    NSLog(@"ctrl chl[%ld] mute[%ld] failed.", _chl_id, _speaker_is_mute);
                }
                if (self.app.is_luxcam) {
                    _speakerButton.selected = _speaker_is_mute ? NO : YES;
                }
                else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
                {
                    _speakerButton.selected = !_speaker_is_mute;
                }
                else
                {
                    [_speakerButtonItem setImage:[UIImage imageNamed:(_speaker_is_mute?@"speaker_mute.png":@"speaker_on2.png")]];
                }
                if (!_speaker_is_mute)
                {
                    if (![self isHeadsetPluggedIn]) {
                        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
                    }
                }
            });
        }
    }
}


//jc's add code

- (void)exsw_set_done:(mcall_ret_exsw_set *)ret
{
    if (nil != ret.result)
    {
        _light_is_on = !_light_is_on;
    }
    else
        NSLog(@"right==========right");
}


- (void)exsw_get_done:(mcall_ret_exsw_get *)ret
{
    if (nil != ret.result)
    {
        NSLog(@"===========exsw_get_done error:%@", ret.result);
        return ;
    }
    
    ret.enable ? (_light_is_on = YES ): (_light_is_on = NO);
    
    NSLog(@"_light_is_on: %ld",_light_is_on);
    NSLog(@"exsw_get_done==========================:%ld", ret.enable);
    [_lightButtonItem setImage:[UIImage imageNamed:(_light_is_on ? @"battery_on.png":@"batterty_off.png")]];
}
//end

- (void)uart_set_done:(mcall_ret_uart_set *)ctx
{
    
}
- (void)uart_get_done:(mcall_ret_uart_set *)ctx
{
    if (nil == ctx.result) {
        
    }
}

- (void)cam_get_done:(mcall_ret_cam_get *)ret;
{
    if(_active && ret.result == nil)
    {
        self.cam_get = ret;
        ((UISlider*)[_controlBoard viewWithTag:1100]).value = ret.brightness;
        ((UISlider*)[_controlBoard viewWithTag:1101]).value = ret.contrast;
        ((UISlider*)[_controlBoard viewWithTag:1102]).value = ret.saturation;
        ((UISlider*)[_controlBoard viewWithTag:1103]).value = ret.sharpness;
        if ([ret.day_night isEqualToString:@"auto"]) {
            ((UISegmentedControl *)[_controlBoard viewWithTag:888]).selectedSegmentIndex = 0;
            
        } else if ([ret.day_night isEqualToString:@"day"]) {
            ((UISegmentedControl *)[_controlBoard viewWithTag:888]).selectedSegmentIndex = 1;
        } else if ([ret.day_night isEqualToString:@"night"]) {
            ((UISegmentedControl *)[_controlBoard viewWithTag:888]).selectedSegmentIndex = 2;
        }
    }
}

- (void)cursise_get_done:(mcall_ret_curise_get*)ret
{
    if (!_active) {
        return;
    }
    
    if (nil != ret.result) {
        return;
    }
    
    for (curise_point *curise in ret.curise_points){
        ((UIButton*)[_controlBoard viewWithTag:curise.index]).selected = YES;
    }
    
    self.curise_points = ret.curise_points;
    
}

- (void)cam_set_done:(mcall_ret_cam_set *)ret
{
    if ([ret.result isEqualToString:@"ret.permission.denied"]) {
        if (self.app.is_vimtag) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_permission_denied", nil)]];
        }
    }
}

- (void)snapshot_done:(mcall_ret_pic_get *)ret
{
    
    if(0 == _active)return;
    _snapshotButton.enabled = YES;
    if (!(self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)) {
        _snapshotButton.selected = NO;
    }
    
//    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
    
    if (nil == ret.img)
    {
//        MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaViours.dev_snaps_fail_times += 1;
//        [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
        
        _snapshotAndRecordpromptLabel.text = NSLocalizedString(@"mcs_snapshot_failed",nil);
        _onsnapshot = NO;
        if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_snapshot_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(2 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               _promptView.hidden = YES;
                           });
        }
    }
    else
    {
//        MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaViours.dev_snaps_succ_times += 1;
//        [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
        
        [self setupAnimation];
        if (self.app.is_vimtag && _pollingTimer)
        {
            [_pollingTimer invalidate];
            _pollingTimer = nil;
        }
        _promptView.hidden = YES;
        _onsnapshot = NO;
        
        if (self.app.is_vimtag) {
            if ([[UIDevice currentDevice] orientation] != UIDeviceOrientationPortrait) {
                [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
            }
        }
        [self performSegueWithIdentifier:NSStringFromClass([MNSnapshotViewController class]) sender:ret.img];
    }
    if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        _snapshotButton.selected = _onsnapshot ? YES : NO;
        [_snapshotButton setImage:[UIImage imageNamed:self.app.is_vimtag ? @"vt_btn_camera_off.png" : (self.app.is_ebitcam ? @"eb_camera_off.png" : @"mi_camera_off.png")] forState:UIControlStateNormal];

        if (self.app.is_vimtag) {
            [self startPollingHideToolBar];
        }
    }
}

//end
- (void)curise_set_done:(mcall_ret_curise_set*)ret
{
    if (nil == ret.result)
    {
        mcall_ctx_cursise_get *ctx = [[mcall_ctx_cursise_get alloc] init];
        ctx.sn = self.deviceID;
        ctx.target = self;
        ctx.on_event = @selector(cursise_get_done:);
        
        [self.agent alarm_curise_get:ctx];
    }
}

#pragma mark - vimtag Video set
- (void)refresh_cam_get
{
    mcall_ctx_cam_get *ctx = [[mcall_ctx_cam_get alloc] init];
    ctx.on_event = @selector(vimtag_cam_get_done:);
    ctx.target = self;
    ctx.sn = _deviceID;
    [self.agent cam_get:ctx];
}

- (void)vimtag_cam_get_done:(mcall_ret_cam_get *)ret
{
    if (_active && ret.result == nil) {
        self.cam_get = ret;
//        NSLog(@"now print-----------\n%d\n%d\n%d\n%d\n%@\n-------",self.cam_get.sharpness,self.cam_get.saturation,self.cam_get.contrast,self.cam_get.brightness,self.cam_get.day_night);
        
        [_videoView.sharpnessSlider setValue:self.cam_get.sharpness];
        [_videoView.saturationSlider setValue:self.cam_get.saturation];
        [_videoView.contrastSlider setValue:self.cam_get.contrast];
        [_videoView.brightnessSlider setValue:self.cam_get.brightness];
        
        [_videoView.sharpnessLabel setText:[NSString stringWithFormat:@"%d",self.cam_get.sharpness]];
        [_videoView.saturationLabel setText:[NSString stringWithFormat:@"%d",self.cam_get.saturation]];
        [_videoView.contrastLabel setText:[NSString stringWithFormat:@"%d",self.cam_get.contrast]];
        [_videoView.brightnessLabel setText:[NSString stringWithFormat:@"%d",self.cam_get.brightness]];
        
        int currentIndex = [self.cam_get.day_night isEqualToString:@"auto"] ? 0 : ([self.cam_get.day_night isEqualToString:@"day"] ? 1 : 2);
        _videoView.modalSegment.selectedSegmentIndex = currentIndex;
        
    }
}

- (void)refreshCamSize
{
    [self mediaEndPlay];
    
    if(nil == _engine)
    {
        [self mediaBeginPlay];
    }
    
}

- (void)refreshCamMessage
{
    mcall_ctx_cam_set *ctx = [[mcall_ctx_cam_set alloc] init];
    ctx.sharpness = _videoView.sharpness;
    ctx.saturation = _videoView.saturation;
    ctx.contrast = _videoView.contrast;
    ctx.brightness = _videoView.brightness;
    ctx.day_night = _videoView.day_night;
    ctx.flip = _cam_get?_cam_get.flip:0;
    ctx.flicker_freq = _cam_get?_cam_get.flicker_freq:1;
    ctx.resolute = _cam_get?_cam_get.resolute:nil;
    ctx.on_event = @selector(vimtag_cam_set_done:);
    ctx.target = self;
    ctx.sn = _deviceID;
    [self.agent cam_set:ctx];
}

- (void)vimtag_cam_set_done:(mcall_ret_cam_set *)ret
{
    if ([ret.result isEqualToString:@"ret.permission.denied"]) {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

- (void)closeVideoView
{
    [_videoPixelsView setHidden:!_videoPixelsView.isHidden];
    _videoPixelSetButton.selected = _videoPixelsView.isHidden ? NO : YES;
    if (self.app.is_vimtag) {
        [self startPollingHideToolBar];
    }
}

#pragma mark - Vimtag Action
- (IBAction)touchHiddenToolbar:(id)sender {
    CGPoint newPoint = [sender locationInView:self.view];
    if (!_videoPixelsView.hidden && CGRectContainsPoint(_videoPixelsView.frame, newPoint))
    {
        
    } else {
        [self hiddenControlView];
    }
}

- (IBAction)volumeButton:(id)sender {
    if (self.app.is_vimtag) {
        [self stopPollingHideToolBar];
    }
    
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
    
    _speakerButton.selected = !_speaker_is_mute;

    if (self.app.is_vimtag) {
        [self startPollingHideToolBar];
    }
    
    if (!_speaker_is_mute)
    {
        if (![self isHeadsetPluggedIn]) {
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        }
    }
}

- (IBAction)volumeValueChanged:(id)sender {
    
  
}

- (IBAction)selectSize:(id)sender {
    [_sizeView setHidden:!_sizeView.hidden];
    [_videoPixelsView setHidden:YES];
    
    if ((self.app.is_ebitcam || self.app.is_mipc) && !_sizeView.hidden) {
        _autoSizeButton.selected = NO;
        _highClearSizeButton.selected = NO;
        _StandardSizeButton.selected = NO;
        _fluentSizeButton.selected = NO;
        
        if (2 == _curProfileID)
        {
            _fluentSizeButton.selected = YES;
        }
        else if (1 == _curProfileID)
        {
            _StandardSizeButton.selected = YES;
        }
        else if (_curProfileID == 0) {
            _highClearSizeButton.selected = YES;
        } else {
            _autoSizeButton.selected = YES;
        }
    }
    
    if (self.app.is_vimtag) {
        if (_sizeView.isHidden == NO)
        {
            [self stopPollingHideToolBar];
        }
        else
        {
            [self startPollingHideToolBar];
        }
    }
}

- (IBAction)autoSize:(id)sender {
    [self setVideoSize:4];
}

- (IBAction)highClear:(id)sender {
    [self setVideoSize:0];
}

- (IBAction)standerClear:(id)sender {
    [self setVideoSize:1];
    
}

- (IBAction)fluentClear:(id)sender {
    [self setVideoSize:2];
    
}

- (void)setVideoSize:(NSInteger)select
{
    struct mipci_conf *conf = MIPC_ConfigLoad(), new_conf = {0};
    if(conf){ new_conf = *conf; };
    new_conf.profile_id = (uint32_t)select;
    MIPC_ConfigSave(&new_conf);
    
    [self refreshCamSize];
}

- (IBAction)changeVideoSize:(id)sender
{
    UIButton *btn = sender;
    
    _autoSizeButton.selected = (btn.tag == _autoSizeButton.tag ? YES : NO);
    _highClearSizeButton.selected = (btn.tag == _highClearSizeButton.tag ? YES : NO);
    _StandardSizeButton.selected = (btn.tag == _StandardSizeButton.tag ? YES : NO);
    _fluentSizeButton.selected = (btn.tag == _fluentSizeButton.tag ? YES : NO);
    
    struct mipci_conf *conf = MIPC_ConfigLoad(), new_conf = {0};
    if(conf){ new_conf = *conf; };
    new_conf.profile_id = (uint32_t)btn.tag;
    MIPC_ConfigSave(&new_conf);
    
    [self refreshCamSize];
}

- (void)viewRecord
{
    MNCacheDirectoryViewController *cacheDirectoryViewController = [[UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"MNCacheDirectoryViewController"];
    [self.navigationController pushViewController:cacheDirectoryViewController animated:YES];
}

- (IBAction)fullScreen:(id)sender
{
    if ([[UIDevice currentDevice] orientation] != UIDeviceOrientationPortrait) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    } else {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    }
}

#pragma mark - MNVideoPlayFailPromptViewDelegate
- (void)videoReplay
{
    _videoPlayFailPromptView.hidden = YES;
    if(nil == _engine)
    {
        [self mediaBeginPlay];
    }
}

#pragma mark - Interface orientation
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//
//}
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
    {
        [self checkNavigationAlpha];
    }
    [self setControlBoardAllow];
    [self.view setNeedsUpdateConstraints];
}

- (void)setControlBoardAllow
{
    _controlBoard.center = self.view.center;
    _speedAndModelControlView.center = self.view.center;
    _buttonUp.frame = CGRectMake(5, self.view.frame.size.height / 2 - 30, 20, 30);
    _buttonDown.frame = CGRectMake(5, self.view.frame.size.height / 2, 20, 30);
}

- (BOOL)prefersStatusBarHidden
{
    return _isHid;
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNSnapshotViewController"]) {
        MNSnapshotViewController *snapshotViewController = segue.destinationViewController;
        snapshotViewController.snapshotID = _deviceID;
        snapshotViewController.snapshotImage = sender;
    }
    else if ([segue.identifier isEqualToString:@"MNMessagePageViewController"])
    {
        MNMessagePageViewController *messagePageViewController = segue.destinationViewController;
        messagePageViewController.deviceID = _deviceID;
    }
    else if ([segue.identifier isEqualToString:@"MNSettingsDeviceViewController"])
    {
        MNSettingsDeviceViewController *settingsDeviceViewController = segue.destinationViewController;
        settingsDeviceViewController.deviceID = _deviceID;
        settingsDeviceViewController.ver_valid = _ver_valid;
    }
}

#pragma mark - Notification
- (void)resignActiveNotification:(NSNotification *)notification
{
    _active = 0;
    [self mediaEndPlay];
}

- (void)becomeActiveNotification:(NSNotification *)notification
{
    if (_is_play) {
        _active = 1;
        [self mediaBeginPlay];
    }
}

#pragma mark - Custom Func
- (void)checkNavigationAlpha
{
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
    {
        if (self.app.is_vimtag) {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"vt_cross_navigation.png"] forBarMetrics:UIBarMetricsDefault];
        } else if (self.app.is_ebitcam || self.app.is_mipc) {
            _selectControlView.backgroundColor = [UIColor clearColor];
        }
    } else {
        if (self.app.is_vimtag) {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@""] forBarMetrics:UIBarMetricsDefault];
        } else if (self.app.is_ebitcam || self.app.is_mipc) {
            _selectControlView.backgroundColor = self.app.is_ebitcam ? [UIColor colorWithRed:240./255. green:240./255. blue:245./255. alpha:1.0] : [UIColor colorWithRed:230./255. green:233./255. blue:240./255. alpha:1.0];
        }
    }
}

//whether insert the headset
- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]
            || [[desc portType] isEqualToString:AVAudioSessionPortBluetoothHFP]
            || [[desc portType] isEqualToString:AVAudioSessionPortBluetoothLE]
            || [[desc portType] isEqualToString:AVAudioSessionPortBluetoothA2DP])
            return YES;
    }
    return NO;
}

- (NSTimeInterval)getTimeIntervalBetweenTimeZoneAndUTC
{
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSDate *currentDate = [NSDate date];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:currentDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:currentDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    return interval;
}

- (void)setupAnimation
{
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
}

- (void)showUpdatePromptView
{
    //Show upgrade prompt
    if (_active &&(!_isExperienceAccount) && (!self.app.isLocalDevice) && (!_hideUpgradeTips)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_camera_found_new_version_y_n_upgrade", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_donot_remind", nil) otherButtonTitles:NSLocalizedString(@"mcs_yes_verif", nil), NSLocalizedString(@"mcs_no_verif", nil), nil];
        alertView.tag = UPGRADE_TAG;
        [alertView show];
    }
}

#pragma mark -alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CON_ALERT_TAG || alertView.tag == NONET_ALERT_TAG || alertView.tag == FIRST_CON || alertView.tag == FIRST_NOTNET) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"prefs:root"]];
        }
    } else if (alertView.tag == UPGRADE_TAG) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            DeviceInfo *obj = [[DeviceInfo alloc] init];
            obj.resolution = _resolution;
            obj.hideUpgradeTips = YES;
            obj.hideTimezoneTips = _hideTimezoneTips;
            NSData *deviceData = [NSKeyedArchiver archivedDataWithRootObject:obj];
            [[NSUserDefaults standardUserDefaults] setObject:deviceData forKey:[NSString stringWithFormat:@"DeviceInfo_%@",_deviceID]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else if (buttonIndex == alertView.firstOtherButtonIndex) {
            NSLog(@"Yes");
            MNDeviceSystemSetViewController *deviceSystemSetViewController = [[UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MNDeviceSystemSetViewController"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:deviceSystemSetViewController];
            deviceSystemSetViewController.agent = self.agent;
            deviceSystemSetViewController.deviceID = self.deviceID;
            deviceSystemSetViewController.is_videoPlay = YES;
            deviceSystemSetViewController.rootNavigationController = navigationController;
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    }
}

@end
