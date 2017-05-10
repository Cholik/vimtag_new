//
//  MNIOAlertlarmViewController.h
//  mipci
//
//  Created by mining on 15/7/27.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNIOAlertlarmViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *statusTiteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *IOAlertSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *snapshotSWitch;
@property (weak, nonatomic) IBOutlet UISwitch *recordSwitch;

@property (weak, nonatomic) IBOutlet UILabel *IOAlertTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *snapshotTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordTiteLable;


@property (weak, nonatomic) IBOutlet UILabel *IOAlertTimeTiteLable;
@property (weak, nonatomic) IBOutlet UITextField *IOAlertTimeTextField;

@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) UINavigationController *rootNavigationController;

@end
