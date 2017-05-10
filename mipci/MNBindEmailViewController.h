//
//  MNBindEmailViewController.h
//  mipci
//
//  Created by mining on 16/11/16.
//
//

#import <UIKit/UIKit.h>

@interface MNBindEmailViewController : UIViewController

@property (strong, nonatomic) NSString  *username;
@property (assign, nonatomic) BOOL      is_register;

@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIImageView *emailImage;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIView *emailLine;
@property (weak, nonatomic) IBOutlet UIButton *bindEmailButton;
@property (weak, nonatomic) IBOutlet UIImageView *emailInputImage;

@end
