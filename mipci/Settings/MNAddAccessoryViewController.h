//
//  MNAddAccessoryViewController.h
//  mipci
//
//  Created by mining on 16/6/8.
//
//

#import <UIKit/UIKit.h>
#import "MNSearchAccessoryViewController.h"
#import "MNDeviceAccessoryViewController.h"
@interface MNAddAccessoryViewController : UIViewController

@property (nonatomic,strong) MNSearchAccessoryViewController *searchAccessoryViewController;
@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
@property (strong, nonatomic) NSString     *exdevID;


@end
