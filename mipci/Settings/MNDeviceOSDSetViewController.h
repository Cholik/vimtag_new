//
//  UIdeviceOSDTableViewController.h
//  mining_client
//
//  Created by mining on 14-9-10.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNDeviceOSDSetViewController : UITableViewController<UITextFieldDelegate>

@property (strong, nonatomic) mipc_agent              *agent;
@property (strong, nonatomic) NSString                *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (strong, nonatomic) NSString                *title;

@property (weak, nonatomic  ) IBOutlet UILabel                 *nameShowTiteLabel;
@property (weak, nonatomic  ) IBOutlet UILabel                 *nameTiteLabel;
@property (weak, nonatomic  ) IBOutlet UISwitch                *nameSwitch;
@property (weak, nonatomic  ) IBOutlet UITextField             *nameTextField;

@property (weak, nonatomic  ) IBOutlet UILabel                 *dateShowTiteLabel;
@property (weak, nonatomic  ) IBOutlet UISwitch                *dateSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateStyleSegmented;

@property (weak, nonatomic  ) IBOutlet UILabel                 *timeShowTiteLabel;
@property (weak, nonatomic  ) IBOutlet UISwitch                *timeSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeStyleSegmented;

@property (weak, nonatomic  ) IBOutlet UISwitch                *weekShowSwitch;
@property (weak, nonatomic  ) IBOutlet UILabel                 *weekShowTiteLabel;

@property (weak, nonatomic  ) IBOutlet UIButton                *commitButton;

@property (nonatomic        ) BOOL                    nameagree;
@property (nonatomic        ) BOOL                    dateagree;
@property (nonatomic        ) BOOL                    timeagree;
@property (nonatomic        ) BOOL                    weekagree;

@end
