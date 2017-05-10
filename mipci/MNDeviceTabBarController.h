//
//  MNDeviceTabBarController.h
//  mipci
//
//  Created by mining on 15-1-13.
//
//

#import <UIKit/UIKit.h>
@class MNDeviceListViewController;
@interface MNDeviceTabBarController : UITabBarController

@property (strong, nonatomic) NSString *deviceID;
@property (assign, nonatomic) BOOL isLoginByID;
@property (strong, nonatomic) NSString *protocol;
@property (strong, nonatomic) MNDeviceListViewController *deviceListViewController;
@property (assign, nonatomic) BOOL ver_valid;
@end
