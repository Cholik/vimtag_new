//
//  MNPrepareRecoveryViewController.h
//  mipci
//
//  Created by mining on 16/4/12.
//
//

#import <UIKit/UIKit.h>

@interface MNPrepareRecoveryViewController : UIViewController

@property (strong, nonatomic) NSString              *userName;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UITextField    *userTextField;
@property (weak, nonatomic) IBOutlet UIButton       *nextButton;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIView *userLine;
@property (weak, nonatomic) IBOutlet UIImageView *userInputImage;

@end
