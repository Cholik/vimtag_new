//
//  UIplanRecordTableViewController.h
//  mining_client
//
//  Created by mining on 14-9-11.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
#import "MNCustomDatePicker.h"

@interface MNDevicePlanRecordSetViewController : UITableViewController<MNCustomDatePickerDelegate>

@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (strong, nonatomic) NSString     *title;

@property (strong, nonatomic) IBOutlet UILabel *recordStateTiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *weekStateTiteLabel;

@property (strong, nonatomic) IBOutlet UISwitch *recordStateSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *weekStateSwitch;

@property (strong, nonatomic) IBOutlet UILabel *oneStartTimeLable;
@property (strong, nonatomic) IBOutlet UILabel *oneEndTimeLable;
@property (strong, nonatomic) IBOutlet UILabel *oneDateLable;

@property (strong, nonatomic) IBOutlet UILabel *twoStartTimeLable;
@property (strong, nonatomic) IBOutlet UILabel *twoEndTimeLable;
@property (strong, nonatomic) IBOutlet UILabel *twoDateTimeLable;

@property (strong, nonatomic) IBOutlet UILabel *threeStartTimeLable;
@property (strong, nonatomic) IBOutlet UILabel *threeEndTimeLable;
@property (strong, nonatomic) IBOutlet UILabel *threeDateTimeLable;

@property (strong, nonatomic) IBOutlet UILabel *fourStartTimeLable;
@property (strong, nonatomic) IBOutlet UILabel *fourEndTimeLable;
@property (strong, nonatomic) IBOutlet UILabel *fourDateTimeLable;
/*--------------------------------------------------------------*/
@property (strong, nonatomic) IBOutlet UILabel *oneStartTimeTiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *oneEndTimeTiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *oneDateTimeTiteLabel;

@property (strong, nonatomic) IBOutlet UILabel *twoStartTimeTiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *twoEndTimeTiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *twoDateTimeTiteLabel;

@property (strong, nonatomic) IBOutlet UILabel *threeStartTimeTiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *threeEndTimeTiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *threeDateTimeTiteLabel;

@property (strong, nonatomic) IBOutlet UILabel *fourStartTimeTiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *fourEndTimeTiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *fourDateTimeTiteLabel;

@property (strong, nonatomic) IBOutlet UIButton *applyButton;


/*------------------------------------------------------------------*/
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *startTimeLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *endTimeLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *dateTimeLabels;

@property (strong, nonatomic) UILabel *currentDateLabel;
@property (strong, nonatomic) NSMutableArray *weeks;

@end
