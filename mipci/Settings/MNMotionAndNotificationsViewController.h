//
//  MNMotionAndNotificationsViewController.h
//  mipci
//
//  Created by mining on 15/7/27.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNMotionAndNotificationsViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *motionDetectionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *IOAlarmtiTleLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationCenter;
@property (weak, nonatomic) IBOutlet UIButton *turnAlertOnButton;

//@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) UINavigationController *rootNavigationController;

@end
