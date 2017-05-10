//
//  UISDcardTableViewController.h
//  mining_client
//
//  Created by mining on 14-9-10.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNDeviceSDcardSetViewController : UITableViewController<UIAlertViewDelegate>

@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
@property (strong, nonatomic) m_dev        *dev;
//@property (strong, nonatomic) NSString     *title;

@property (weak, nonatomic) IBOutlet UILabel *enableTiteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;

@property (weak, nonatomic) IBOutlet UILabel *stateTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLable;

@property (weak, nonatomic) IBOutlet UILabel *roomTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *usedTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableTiteLabel;

@property (weak, nonatomic) IBOutlet UILabel *roomLable;
@property (weak, nonatomic) IBOutlet UILabel *usedLable;
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;

@property (weak, nonatomic) IBOutlet UIButton *formatButton;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@end
