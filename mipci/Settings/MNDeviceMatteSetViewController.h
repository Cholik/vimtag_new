//
//  MNDeviceMatteSetViewController.h
//  mipci
//
//  Created by weken on 15/3/24.
//
//

#import <UIKit/UIKit.h>

@interface MNDeviceMatteSetViewController : UIViewController
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIToolbar *navigationToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetBarButtonItem;

@end
