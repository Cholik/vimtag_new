//
//  RecordViewController.h
//  mipci
//
//  Created by mining on 13-11-13.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
#import "MNShareVideoWindow.h"

@class MNProgressView;
@class LocalVideoInfo;

@interface MNRecordViewController : UIViewController
@property (strong ,nonatomic) NSString                          *url;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer   *replayTap;
@property (strong, nonatomic) IBOutlet UIView                 *toolbar;
@property (strong, nonatomic) NSTimer                           *timer;
@property (strong, nonatomic) NSString                          *deviceID;
@property (strong, nonatomic) IBOutlet UILabel                           *lblSpeed;
@property (strong, nonatomic) IBOutlet UILabel                           *lblSpeedStatus;

//
@property (nonatomic, strong) UIImageView * videoImageView;
@property (nonatomic, strong) UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (nonatomic, strong) MNProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actindStatusView;

@property (nonatomic) BOOL isDownloading;
@property (assign, nonatomic) BOOL isLocalVideo;
@property (nonatomic) long long totalDuration;
@property (strong, nonatomic) UIButton *voiceButton;


@property (strong, nonatomic) mipc_agent                        *agent;
@property (strong, nonatomic) mdev_msg                            *msg;
@property (strong, nonatomic) LocalVideoInfo                    *localVideoInfo;
@property (strong, nonatomic) NSString                          *boxID;

@end
