//
//  MNModifyPasswordViewController.h
//  mipci
//
//  Created by mining on 15-1-12.
//
//

#import <UIKit/UIKit.h>
#import "MNLoginViewController.h"
#import "MNDeviceListViewController.h"

@interface MNModifyPasswordViewController : UIViewController
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *oldPassword;
@property (assign, nonatomic) BOOL      is_notAdd;

@property (weak, nonatomic) IBOutlet UILabel *deviceIDHintLabel;
@property (weak, nonatomic) IBOutlet UITextField *changedPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UIImageView *changedPasswordInputImageView;
@property (weak, nonatomic) IBOutlet UIImageView *confirmPasswordInputImageView;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@property (weak, nonatomic) IBOutlet UIButton *showPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *showComfirmBtn;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIImageView *keyImage;
@property (weak, nonatomic) IBOutlet UIImageView *keySecondImage;

@property (assign, nonatomic) BOOL      is_loginModify;
@property (strong, nonatomic) NSString *localDeviceIP;

@end
