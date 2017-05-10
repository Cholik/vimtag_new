//
//  MNNotificationCenterViewController.h
//  mipci
//
//  Created by weken on 15/3/24.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNNotificationCenterViewController : UITableViewController
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (strong, nonatomic) NSString *title;

@property (weak, nonatomic) IBOutlet UILabel *recordTintLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertTintLabel;
@property (weak, nonatomic) IBOutlet UISwitch *recordSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *alertSwitch;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@end
