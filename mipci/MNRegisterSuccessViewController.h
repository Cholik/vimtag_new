//
//  MNRegisterSuccessViewController.h
//  mipci
//
//  Created by mining on 16/11/16.
//
//

#import <UIKit/UIKit.h>

@interface MNRegisterSuccessViewController : UIViewController

@property (strong, nonatomic) NSString *username;

@property (weak, nonatomic) IBOutlet UILabel *successLabel;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIButton *bindEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end
