//
//  UIsystemTableViewController.h
//  mining_client
//
//  Created by mining on 14-9-12.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
#import "MNCustomAlertView.h"

@interface  MNDeviceSystemSetViewController : UITableViewController<UIAlertViewDelegate,MNCustomAlertViewDelegate>

@property (strong, nonatomic)mipc_agent   *agent;
@property (strong, nonatomic)NSString     *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL ver_valid;

@property (assign, nonatomic) BOOL is_videoPlay;

@property (weak, nonatomic) IBOutlet UIButton *rebootButton;
@property (weak, nonatomic) IBOutlet UIButton *recoverButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *updateView;

@end
