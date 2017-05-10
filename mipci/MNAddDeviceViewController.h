//
//  MNAddDeviceViewController.h
//  mipci
//
//  Created by mining on 15-1-14.
//
//

#import <UIKit/UIKit.h>
#import "ZXingWidget/Classes/ZXingWidgetController.h"

@class MNDeviceListViewController;

@interface MNAddDeviceViewController : UIViewController<ZXingDelegate>

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *devicePassword;
@property (assign, nonatomic) BOOL      is_scan;
@property (assign, nonatomic) BOOL      is_wifiConfig;
@property (assign, nonatomic) long      wfcnr;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *addDeviceButton;

@property (weak, nonatomic) IBOutlet UIImageView *userInputImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordInputImageView;

@property (weak, nonatomic) IBOutlet UIView *devicePasswordView;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;
@property (assign, nonatomic) BOOL is_add;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceToUserViewLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *showPasswordBtn;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImage;
@property (weak, nonatomic) IBOutlet UIImageView *keyImage;

-(void)initConstraint;
-(void)updateConstraint;

@end
