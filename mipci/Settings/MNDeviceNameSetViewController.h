//
//  MNDeviceNameSetViewController.h
//  mining_client
//
//  Created by mining on 14-9-9.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNDeviceNameSetViewController : UITableViewController<UITabBarControllerDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (strong, nonatomic) NSString *title;

@property (weak, nonatomic) IBOutlet UILabel *nameHintLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;


@end
