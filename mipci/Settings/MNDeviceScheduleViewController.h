//
//  MNDeviceScheduleViewController.h
//  mipci
//
//  Created by mining on 16/4/15.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
#import "MNDeviceSettingsViewController.h"
#import "MNProgressHUD.h"
#import "AppDelegate.h"
#import "MNScheduleSceneSetView.h"

@interface schedule_obj : NSObject

@property (strong, nonatomic) UIColor *backgroundColor;

@end

@interface MNDeviceScheduleViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource,UIGestureRecognizerDelegate, MNScheduleSceneSetViewDelegate>

@property (strong, nonatomic) mipc_agent   *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (strong, nonatomic) MNDeviceSettingsViewController *deviceSettingsViewController;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
@property (strong, nonatomic) NSString     *deviceID;
@property (assign, nonatomic) CGSize            transitionToSize;
@property (strong, nonatomic) NSMutableArray    *scheduleArray;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@property (weak, nonatomic) IBOutlet UIView *backView;

@end
