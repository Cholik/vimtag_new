//
//  MNDeviceWIFISetViewController.h
//  mining_client
//
//  Created by mining on 14-9-12.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNDeviceWIFISetViewController : UITableViewController<UITextFieldDelegate>

@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (strong, nonatomic) NSString *title;

@property (weak, nonatomic) IBOutlet UISwitch *enableStatusSwitch;
@property (weak, nonatomic) IBOutlet UILabel *enableStatusTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *faultLabel;

@property (weak, nonatomic) IBOutlet UILabel *MACAddressTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *MACAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkStatusTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkStatusLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *WIFIStyleSegment;

@property (weak, nonatomic) IBOutlet UILabel *networkListTiteLabel;
@property (weak, nonatomic) IBOutlet UITextField *WIFINameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *WIFIlinkStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *WIFIlinkStatusTiteLabel;

@property (weak, nonatomic) IBOutlet UILabel *autoIPTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *IPAddressTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *gatewayTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *maskTiteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *autoIPSwitch;
@property (weak, nonatomic) IBOutlet UITextField *IPAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *gatewayTextField;
@property (weak, nonatomic) IBOutlet UITextField *maskTextField;

@property (weak, nonatomic) IBOutlet UILabel *autoDNSTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstDNSTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *standbyDNSTiteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *autoDNSSwitch;
@property (weak, nonatomic) IBOutlet UITextField *firstDNSTextField;
@property (weak, nonatomic) IBOutlet UITextField *standbyDNSTextField;

@property (weak, nonatomic) IBOutlet UILabel *beginIPTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *endIPTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *hotpotGatewayTiteLabel;
@property (weak, nonatomic) IBOutlet UITextField *beginIPTextField;
@property (weak, nonatomic) IBOutlet UITextField *endIPTextField;
@property (weak, nonatomic) IBOutlet UITextField *hotpotGatewayTextField;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@property (assign, nonatomic)   float wifiStateValue;

@end
