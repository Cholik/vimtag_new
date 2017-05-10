//
//  UIdevicedateTableViewController.h
//  mining_client
//
//  Created by mining on 14-9-11.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
#import "MNCustomDatePicker.h"

@interface MNDeviceDateSetViewController : UITableViewController<UITextFieldDelegate ,MNCustomDatePickerDelegate>

@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
@property (strong, nonatomic) zone_obj     *timezone_obj;

//@property (strong, nonatomic) NSString     *title;

@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger hh;
@property (nonatomic) NSInteger mm;
@property (nonatomic) NSInteger ss;

@property (strong, nonatomic) IBOutlet UILabel *dateLable;
@property (strong, nonatomic) IBOutlet UILabel *timeLable;
@property (strong, nonatomic) IBOutlet UITextField *serverIPTextField;
@property (strong, nonatomic) IBOutlet UILabel *timezoneLabel;

@property (strong, nonatomic) IBOutlet UILabel *dateTiteLable;
@property (strong, nonatomic) IBOutlet UILabel *timeTiteLable;
@property (strong, nonatomic) IBOutlet UILabel *synchronizationTiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *serverIPTiteLable;
@property (strong, nonatomic) IBOutlet UILabel *timezoneTiteLable;

@property (strong, nonatomic) IBOutlet UISwitch *synchronizationSwitch;
@property (strong, nonatomic) IBOutlet UIButton *commitButton;




@end
