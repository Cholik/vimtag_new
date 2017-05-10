//
//  MNDeviceListViewController.h
//  mipci
//
//  Created by weken on 15/2/5.
//
//

#import <UIKit/UIKit.h>
#import "MNQRCodeViewController.h"
#import "MNPopoverView.h"

@class MNLoginViewController;
@class MNDeviceListSetViewController;
@interface MNDeviceListViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, PopoverViewDelegate,UIWebViewDelegate>

@property (strong, nonatomic) MNLoginViewController *loginViewController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *LoginPromptView;
@property (weak, nonatomic) IBOutlet UIImageView *iphoneLogo;
@property (weak, nonatomic) IBOutlet UIImageView *ipadLogo;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *userPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *feelingButton;

@property (weak, nonatomic) IBOutlet UIView *emptyPromptView;
@property (weak, nonatomic) IBOutlet UILabel *firstLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLineLabel;
@property (weak, nonatomic) IBOutlet UIButton *networkUnavailableButton;

@property (weak, nonatomic) IBOutlet UIView *networkExceptionView;
@property (weak, nonatomic) IBOutlet UILabel *detailDiagnosisLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishDiagnosisButton;
@property (weak, nonatomic) IBOutlet UIButton *networkFailButton;

@property (strong, nonatomic) mdev_devs *devices;
@property (strong ,nonatomic) NSString *selectSceneName;
@property (weak, nonatomic) MNDeviceListSetViewController *deviceListSetViewController;


- (void)refreshData;
- (void)loadingDeviceData;
- (void)getNotification:(NSString *)userName;
- (void)removeAllData;
- (void)webVersionGet;

@end
