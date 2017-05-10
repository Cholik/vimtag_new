//
//  MNQRCodeOperatePromptViewController.h
//  mipci
//
//  Created by mining on 15/12/26.
//
//

#import <UIKit/UIKit.h>

@interface MNQRCodeOperatePromptViewController : UIViewController<UIAlertViewDelegate>
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *devicePassword;
@property (assign, nonatomic) BOOL      is_loginModify;
@property (weak, nonatomic) UITextField *wifiNameTextField;
@property (weak, nonatomic) UITextField *wifiPasswordTextField;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UILabel *operatePromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *promptContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *promptImage;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promptImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *promptContentVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *operatePromptTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *SelectConfigStyleView;

@end
