//
//  MNSynchronizeViewController.h
//  mipci
//
//  Created by mining on 16/6/13.
//
//

#import <UIKit/UIKit.h>
#import "MNDeviceListSetViewController.h"
#import "MIPCUtils.h"
#import "mipc_agent.h"

@interface MNSynchronizeViewController : UIViewController
@property (nonatomic,strong) NSString *selectSceneName;
@property (strong, nonatomic) mdev_devs *devices;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) MNDeviceListSetViewController *deviceListSetViewController;


@end
