//
//  RegisterViewController.h
//  mipci
//
//  Created by mining on 13-5-2.
//
//

#import <UIKit/UIKit.h>
#import "MIPCUtils.h"
#import "AppDelegate.h"

@class MNLoginViewController;
@interface MNRegisterViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate, UIAlertViewDelegate>

- (IBAction)registerBtnClick:(id)sender;
- (IBAction)onInputEnd:(UITextField*)sender;
- (IBAction)onBeginEditting:(UITextField *)textField;
- (IBAction)onEndEditting:(UITextField*)sender;

@property (weak, nonatomic) IBOutlet UIView *userLine;
@property (weak, nonatomic) IBOutlet UIView *pwdLine;
@property (weak, nonatomic) IBOutlet UIView *comfirmLine;
@property (strong, nonatomic) IBOutlet UITextField              *userText;
@property (strong, nonatomic) IBOutlet UITextField              *pwdText;
@property (strong, nonatomic) IBOutlet UITextField              *comfirmText;

@property (strong, nonatomic) IBOutlet UILabel                  *statusLable;
@property (strong, nonatomic) IBOutlet UIButton                 *registerBtn;
@property (strong, nonatomic) IBOutlet UIImageView              *logo;
@property (strong, nonatomic) IBOutlet UIButton                 *backBtn;
@property (nonatomic, strong) IBOutlet UIView                   *regView;
@property (strong, nonatomic) MNLoginViewController             *loginViewController;
@property (strong, nonatomic) mipc_agent                        *agent;

//////
@property (weak, nonatomic) IBOutlet UIImageView *userInputImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordInputImageView;
@property (weak, nonatomic) IBOutlet UIImageView *confirmPasswordInputImageView;

@property (weak, nonatomic) IBOutlet UIButton *showPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *showComfirmBtn;

@property (weak, nonatomic) IBOutlet UIButton *backLoginBtn;

@property (weak, nonatomic) IBOutlet UILabel *existAccountLabel;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *agreeButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *privacyButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *privacyViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *privacyButtonLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *privacyView;

//Ebit
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIImageView *pwdImage;
@property (weak, nonatomic) IBOutlet UIImageView *confirmImage;
@property (weak, nonatomic) IBOutlet UIImageView *checkUsernameImage;
@property (weak, nonatomic) IBOutlet UIView *userLineView;
@property (weak, nonatomic) IBOutlet UIView *pwdLineView;
@property (weak, nonatomic) IBOutlet UIView *confirmLineView;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;
@property (weak, nonatomic) IBOutlet UIImageView *userInputImage;
@property (weak, nonatomic) IBOutlet UIImageView *pwdInputImage;
@property (weak, nonatomic) IBOutlet UIImageView *confirmInputImage;


@property (assign, nonatomic) BOOL  is_ListRegister;
@property (assign, nonatomic) BOOL  is_toLogin;

@end
