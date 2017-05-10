//
//  MNDeviceAccessoryViewController.h
//  mipci
//
//  Created by mining on 16/1/12.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
#import "MNDeviceSettingsViewController.h"

@interface MNDeviceAccessoryViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSString *deviceID;
@property (copy,nonatomic) NSString *selectScene;
@property (strong, nonatomic) NSMutableArray *accessoryArray;
@property (assign,nonatomic) NSInteger index;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
@property (strong, nonatomic) MNDeviceSettingsViewController *deviceSettingsViewController;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *sceneLabel;

- (void)refreshData;

@end
