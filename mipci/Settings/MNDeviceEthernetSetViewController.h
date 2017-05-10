//
//  MNDeviceEthernetSetViewController.h
//  mining_client
//
//  Created by mining on 14-9-12.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNDeviceEthernetSetViewController : UITableViewController<UITextFieldDelegate>

@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (strong, nonatomic) NSString *title;

@property (weak, nonatomic) IBOutlet UILabel *enableTiteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;

@property (weak, nonatomic) IBOutlet UILabel *MACAddressTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkStatusTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *MACAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *autoIPTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *IPAddressTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *gatewayTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *maskTiteLabel;

@property (weak, nonatomic) IBOutlet UISwitch *autoIPSwitch;
@property (weak, nonatomic) IBOutlet UITextField *IPAddressText;
@property (weak, nonatomic) IBOutlet UITextField *gatewayText;
@property (weak, nonatomic) IBOutlet UITextField *maskText;

@property (weak, nonatomic) IBOutlet UILabel *autoDNSTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstDNSTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *standbyDNSTiteLabel;

@property (weak, nonatomic) IBOutlet UISwitch *autoDNSSwitch;
@property (weak, nonatomic) IBOutlet UITextField *firstDNSText;
@property (weak, nonatomic) IBOutlet UITextField *standbyDNSText;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@end
