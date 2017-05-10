//
//  UIdeviceSettingTableViewController.h
//  mining_client
//
//  Created by mining on 14-9-12.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
#import "MNDeviceListViewController.h"

@protocol MNDeviceSettingsViewControllerDelegate <NSObject>

@required

-(void)setViewController:(UIViewController *)viewController;

@end

@interface MNDeviceSettingsViewController : UITableViewController<UIAlertViewDelegate>

@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSString *deviceID;
@property (assign, nonatomic) BOOL isLoginByID;
@property (strong, nonatomic) void (^back)(BOOL isBack);
@property (strong, nonatomic) MNDeviceListViewController *deviceListViewController;
@property (nonatomic, weak) id<MNDeviceSettingsViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *viewControllerKeys;

@property (weak, nonatomic) IBOutlet UITableViewCell *aboutCell;
@property (weak, nonatomic) IBOutlet UIButton *deleteDeviceButton;

@property (assign, nonatomic) BOOL ver_valid;

@end
