//
//  UItimezoneListTableViewController.h
//  mining_client
//
//  Created by mining on 14-10-17.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNDeviceDateSetViewController.h"
#import "MNModifyTimezoneViewController.h"

@interface MNTimezoneListViewController : UITableViewController
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *selectedTimetone;
@property (strong, nonatomic) MNDeviceDateSetViewController *deviceDateSetViewController;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
@property (strong, nonatomic) MNModifyTimezoneViewController *modifyTimezoneViewController;

@end
