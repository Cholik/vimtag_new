//
//  MNSetAccessoryViewController.h
//  mipci
//
//  Created by mining on 16/4/20.
//
//

#import <UIKit/UIKit.h>
#import "MNDeviceAccessoryViewController.h"

@interface MNSetAccessoryViewController : UITableViewController
@property (nonatomic,weak) MNDeviceAccessoryViewController *deviceAccessoryViewController;
@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
//@property (nonatomic,copy) NSString *exdev_id;
//@property (nonatomic,copy) NSString *exdev_nick;
//@property (nonatomic,strong) sceneExdev_obj *dev;
@property (nonatomic,strong) NSMutableArray *sceneArray;
@property (nonatomic,copy) NSString *selectScene;
@property (nonatomic,assign) NSInteger index;

@end
