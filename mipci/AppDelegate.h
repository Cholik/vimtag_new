//
//  AppDelegate.h
//  mipci
//
//  Created by MagicStudio on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#define METHOD_ACTIVATE @"aa"
#define METHOD_PASSWORDRESET @"pr"
#define METHOD_PLAYVIDEOVIEW @"pv"

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
#import "MNConfiguration.h"
#import "Reachability.h"
#import "MNDeveloperOption.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *mainStoryboard;

@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) mipc_agent *localAgent;
@property (strong, nonatomic) mipc_agent *cloudAgent;
@property (strong, nonatomic) NSString *directConnectedDevID;

@property (assign, nonatomic) BOOL is_userOnline;
@property (assign, nonatomic) BOOL is_itelcamera;
@property (assign, nonatomic) BOOL is_luxcam;
@property (assign, nonatomic) BOOL is_ebitcam;
@property (assign, nonatomic) BOOL is_mipc;
@property (assign, nonatomic) BOOL is_avuecam;
@property (assign, nonatomic) BOOL is_reg_by_email;
@property (assign, nonatomic) BOOL is_vimtag;
@property (assign, nonatomic) BOOL is_sereneViewer;
@property (assign, nonatomic) BOOL is_eyedot;
@property (assign, nonatomic) BOOL is_ehawk;
@property (assign, nonatomic) BOOL is_kean;
@property (assign, nonatomic) BOOL is_prolab;
@property (assign, nonatomic) BOOL is_eyeview;
@property (assign, nonatomic) BOOL is_maxCAM;
@property (assign, nonatomic) BOOL is_bosma;
@property (assign, nonatomic) BOOL is_InfoPrompt;

@property (assign, nonatomic) BOOL isLocalDevice;
@property (assign, nonatomic) BOOL is_jump;
@property (assign, nonatomic) BOOL is_firstLaunch;
@property (assign, nonatomic) BOOL is_firstSceneLauch;
@property (assign, nonatomic) BOOL is_firstScheduleLauch;

@property (strong, nonatomic) NSString *alert_independent;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *button_color;
@property (strong, nonatomic) UIColor *button_title_color;

/*parameter for url jump*/
@property (nonatomic, strong) NSString *urlMethod;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *fromTarget;
@property (nonatomic, strong) NSString *toTarget;

@property (nonatomic) BOOL keepLogin;
@property (nonatomic) BOOL disableAll;

@property (nonatomic) BOOL disableVoice;
@property (nonatomic) BOOL disableMicrophone;
@property (nonatomic) BOOL disableSnapshot;
@property (nonatomic) BOOL disableVideoRecord;
@property (nonatomic) BOOL disableOtherSetting;
@property (nonatomic) BOOL disableOtherSettingCam;

@property (nonatomic) BOOL disableVideo;
@property (nonatomic) BOOL disableHistory;
@property (nonatomic) BOOL disableSettings;

@property (nonatomic) BOOL disableSettingsPassword;
@property (nonatomic) BOOL disableSettingsNetwork;
@property (nonatomic) BOOL disableSettingsUpgrate;
@property (nonatomic) BOOL disableSettingsReboot;
@property (nonatomic) BOOL disableSettingsReset;
@property (nonatomic) BOOL disableModifyUserSetting;
@property (nonatomic) BOOL disableExit;
@property (nonatomic, strong) NSString *shoppingURL;

@property (strong, nonatomic)MNConfiguration *configuration;
@property (strong, nonatomic) MNDeveloperOption *developerOption;

@property (strong,nonatomic) Reachability *hostReach;
//@property (assign,nonatomic) int reachCount;
@property (assign, nonatomic) BOOL isNetWorkAvailable;

@property (assign, nonatomic) BOOL isOpenDeveloperOption;
@property (assign, nonatomic) BOOL startSaveLog;


-(long) isLoginByID;
-(long) isDevicesAccount:(NSString *)user;
- (NetworkStatus)reachabilityChanged:(NSNotification *)note;

@end
