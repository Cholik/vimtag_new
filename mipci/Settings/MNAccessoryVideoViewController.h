//
//  MNAccessoryVideoViewController.h
//  mipci
//
//  Created by PC-lizebin on 16/8/6.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNAccessoryVideoViewController : UIViewController
@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
@property (copy,nonatomic) NSString *selectScene;

@property (strong, nonatomic) UINavigationController *rootNavigationController;

@property (weak, nonatomic) IBOutlet UILabel *recordAllDayLabel;
@property (weak, nonatomic) IBOutlet UISwitch *allDaySwitch;
@property (weak, nonatomic) IBOutlet UILabel *recordPromptLabel;

@property (weak, nonatomic) IBOutlet UIView *customRecordView;
@property (weak, nonatomic) IBOutlet UILabel *sceneLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *awaySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *activeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonToLabelLayoutConstraint;

@end
