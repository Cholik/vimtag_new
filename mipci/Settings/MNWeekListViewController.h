//
//  MNWeekListViewController.h
//  mipci
//
//  Created by weken on 15/3/20.
//
//

#import <UIKit/UIKit.h>
@class MNDevicePlanRecordSetViewController;
@class MNDevicePlanDefenceSetViewController;

@interface MNWeekListViewController : UITableViewController
@property (assign, nonatomic) int wday_byte;
@property (assign, nonatomic) int index;
@property (strong, nonatomic) MNDevicePlanRecordSetViewController *devicePlanRecordSetViewController;
@property (strong, nonatomic) MNDevicePlanDefenceSetViewController *devicePlanDefenceSetViewController;
@end
