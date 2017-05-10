//
//  MNDeviceListSetViewController.h
//  mipci
//
//  Created by mining on 16/3/29.
//
//

#import <UIKit/UIKit.h>
#import "MNDeviceListSetHeaderView.h"
#import "MNDeviceListViewController.h"

@interface MNDeviceListSetViewController : UIViewController 

@property (nonatomic,strong) MNDeviceListSetHeaderView *headerView;
@property (nonatomic,strong) MNDeviceListViewController *deviceListViewController;

- (void)checkUserOnlie;                         //Check user online or not
- (void)refreshCurrentScene;                    //Refresh user's dev scene
- (void)checkSynchronize:(NSString *)sceneName inArray:(NSMutableArray*)sceneSetArray; //Refresh dev scene synchronize status

@end
