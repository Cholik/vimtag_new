//
//  MNAccessorySceneViewController.h
//  mipci
//
//  Created by PC-lizebin on 16/8/6.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
@class MNDeviceAccessoryViewController;
@class MNAccessoryVideoViewController;

@interface MNAccessorySceneViewController : UIViewController

@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
@property (weak, nonatomic) MNDeviceAccessoryViewController *deviceAccessoryViewController;
@property (weak,nonatomic) MNAccessoryVideoViewController *accessoryVideoViewController;
@property (copy, nonatomic) NSString *selectScene;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *awayButton;
@property (weak, nonatomic) IBOutlet UIButton *activeButton;
@property (weak, nonatomic) IBOutlet UIButton *calenderButton;

@property (weak, nonatomic) IBOutlet UILabel *activeLabel;
@property (weak, nonatomic) IBOutlet UILabel *activePromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayPromptLabel;

@property (weak, nonatomic) IBOutlet UILabel *autoLabel;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containViewWidth;

@end
