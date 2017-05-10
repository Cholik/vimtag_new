//
//  MNMotionDetectionViewController.h
//  mipci
//
//  Created by mining on 15/7/27.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNMotionDetectionViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *statusTiteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;
@property (weak, nonatomic) IBOutlet UILabel *daytimeLable;
@property (weak, nonatomic) IBOutlet UISlider *daytimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *nightLable;
@property (weak, nonatomic) IBOutlet UISlider *nightSlider;


@property (weak, nonatomic) IBOutlet UILabel *daytimeTiteLable;
@property (weak, nonatomic) IBOutlet UILabel *nightTiteLable;

@property (weak, nonatomic) IBOutlet UILabel *maskSettingTiteLabel;

@property (weak, nonatomic) IBOutlet UILabel *IOAlertTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *snapshotTiteLabel;

@property (weak, nonatomic) IBOutlet UILabel *recordTiteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *IOAlertSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *snapshotSWitch;
@property (weak, nonatomic) IBOutlet UISwitch *recordSwitch;

@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) UINavigationController *rootNavigationController;

@end
