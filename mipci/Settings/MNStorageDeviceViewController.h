//
//  MNStorageDeviceViewController.h
//  mipci
//
//  Created by weken on 15/5/12.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNStorageDeviceViewController : UITableViewController<UITextFieldDelegate>
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (strong, nonatomic) NSString *title;


@property (weak, nonatomic) IBOutlet UILabel *enableTintLabel;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@property (weak, nonatomic) IBOutlet UILabel *deviceIDTintLabel;
@property (weak, nonatomic) IBOutlet UITextField *deviceIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordTintLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *connectStateTintLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectStateShowLabel;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (weak, nonatomic) IBOutlet UITableViewCell *deviceIDCell;
@end
