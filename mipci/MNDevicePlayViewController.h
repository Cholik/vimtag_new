//
//  MNVideoLiveViewController.h
//  ipcti
//
//  Created by MagicStudio on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "MNVideoPixelsView.h"
#import "MNAppPromptWindow.h"
#import "MNVideoPlayFailPromptView.h"

@interface MNDevicePlayViewController : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate,MFMailComposeViewControllerDelegate, MNVideoPixelsView, MNVideoPlayFailPromptViewDelegate, CAAnimationDelegate>
@property (strong, nonatomic) NSTimer                           *timer;
//jc's add code
@property (strong, nonatomic) NSTimer                           *recordTimer;
@property (strong, nonatomic) NSString                           *showDateString;
@property (strong, nonatomic) NSString                          *ShareDateString;
//end
@property (strong, nonatomic) NSString                          *deviceID;
@property (assign, nonatomic) long                              standSpeedBytes;
@property (assign)            int                               ctrl_play_check_counts;

@property (strong, nonatomic) NSString                          *protocol;

@property (assign, nonatomic) BOOL                              isExperienceAccount;
@property (assign, nonatomic) BOOL                              is_viewAppear;

@property (strong, nonatomic) IBOutlet UILabel                  *lblSpeed;
@property (strong, nonatomic) IBOutlet UILabel                  *lblSpeedStatus;
@property (strong, nonatomic) IBOutlet UIImageView *wifiView;

@property (weak, nonatomic) IBOutlet UIView *optionSelectView;
@property (weak, nonatomic) IBOutlet UIButton *optionButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionButtonToLeftLayoutConstraint;


@property (weak, nonatomic) IBOutlet UIToolbar *navigationToolbar;
@property (weak, nonatomic) IBOutlet UIButton *speakerButton;
@property (weak, nonatomic) IBOutlet UIButton *microphoneButton;
@property (weak, nonatomic) IBOutlet UIButton *snapshotButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *lightButton;
@property (weak, nonatomic) IBOutlet UIButton *videoPixelSetButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (assign, nonatomic) BOOL ver_valid;
//luxcam back
@property (weak, nonatomic) IBOutlet UIButton *backButton;

//jc's add code
@property(strong) NSString *recordUrl;
@property(strong) NSString *recordMp4FilePath;
@property(assign, nonatomic) BOOL      isDownloading;
@property (nonatomic) double   recordTimeDuration;
@property (nonatomic) NSDate   *recordStartTime;
@property (nonatomic) UIImage  *local_thumb_img;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *speakerButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *microphoneButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *snapshotButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *recordButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lightButtonItem;
@property (weak, nonatomic) IBOutlet UIView *batteryView;

@property (weak, nonatomic) IBOutlet UIView *batteryHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *batteryNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarToTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewToTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UILabel *snapshotAndRecordpromptLabel;

@property (weak, nonatomic) IBOutlet UIView *promptView;

//Vimtag
@property (weak, nonatomic) IBOutlet UIView *videoPixelsView;

@property (weak, nonatomic) IBOutlet UIButton *autoSizeButton;
@property (weak, nonatomic) IBOutlet UIButton *highClearSizeButton;
@property (weak, nonatomic) IBOutlet UIButton *StandardSizeButton;
@property (weak, nonatomic) IBOutlet UIButton *fluentSizeButton;
@property (weak, nonatomic) IBOutlet UIButton *sizeSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;

@property (weak, nonatomic) IBOutlet UIView *sizeView;
@property (weak, nonatomic) IBOutlet UIView *sizeControlView;
@property (weak, nonatomic) IBOutlet UIView *selectControlView;
@property (weak, nonatomic) IBOutlet UIView *volumeControlView;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

@property (weak, nonatomic) IBOutlet UIView *recordTimerView;
@property (weak, nonatomic) IBOutlet UILabel *recordTimerLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ptzActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backitem;

@property (weak, nonatomic) IBOutlet UIView *setTimezoneView;
@property (weak, nonatomic) IBOutlet UILabel *setTimezoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *setTimezoneButton;

@property (weak, nonatomic) IBOutlet UIView *viewRecordPromptView;
@property (weak, nonatomic) IBOutlet UIImageView *viewRecordPromptImage;
@property (weak, nonatomic) IBOutlet UILabel *viewRecordPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewRecordPromptButton;

- (void)showUpdatePromptView;


//end
@end
