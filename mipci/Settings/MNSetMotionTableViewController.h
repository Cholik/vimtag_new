//
//  MNSetMotionTableViewController.h
//  mipci
//
//  Created by mining on 16/6/24.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
#import "MNDeviceAccessoryViewController.h"


@interface MNSetMotionTableViewController : UITableViewController
@property (nonatomic,weak) MNDeviceAccessoryViewController *deviceAccessoryViewController;
@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
@property (nonatomic,strong) NSMutableArray *sceneArray;
@property (nonatomic,copy) NSString *selectScene;
@end
