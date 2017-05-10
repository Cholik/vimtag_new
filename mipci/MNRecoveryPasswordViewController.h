//
//  MNRecoveryPasswordViewController.h
//  mipci
//
//  Created by mining on 15/11/7.
//
//

#import <UIKit/UIKit.h>

@interface MNRecoveryPasswordViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@property (strong, nonatomic) NSString              *emailString;
@property (strong, nonatomic) NSString              *userName;
@property (weak, nonatomic) IBOutlet UIView *inputEmailView;

@property (weak, nonatomic) IBOutlet UITextField    *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton       *sureButton;
@property (weak, nonatomic) IBOutlet UILabel        *emailPromptLabel;

@property (weak, nonatomic) IBOutlet UIImageView *emailImage;
@property (weak, nonatomic) IBOutlet UIView *emailLine;
@property (weak, nonatomic) IBOutlet UIImageView *emailInputImage;

@end
