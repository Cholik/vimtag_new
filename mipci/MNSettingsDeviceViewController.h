//
//  MNDeviceSettingsViewController.h
//  mipci
//
//  Created by weken on 15/2/9.
//
//

#import <UIKit/UIKit.h>

@class MNDeviceListViewController;
@class MNDeviceSettingsViewController;
@interface MNSettingsDeviceViewController : UIViewController<UISplitViewControllerDelegate>
@property (copy, nonatomic) NSString *deviceID;
@property (assign, nonatomic) BOOL isLoginByID;
@property (strong, nonatomic) MNDeviceListViewController *deviceListViewController;
@property (assign, nonatomic) BOOL isBox;
@property (assign, nonatomic) BOOL ver_valid;
@property (strong, nonatomic) MNDeviceSettingsViewController *settingsViewController;



-(void)updateData;

@end
