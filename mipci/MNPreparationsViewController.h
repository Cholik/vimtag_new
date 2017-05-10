//
//  MNPreparationsViewController.h
//  mipci
//
//  Created by mining on 15/6/16.
//
//

#import <UIKit/UIKit.h>

@interface MNPreparationsViewController : UIViewController<UIAlertViewDelegate>

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *devicePassword;
@property (assign, nonatomic) BOOL      is_loginModify;

@property (weak, nonatomic) UITextField *wifiNameTextField;
@property (weak, nonatomic) UITextField *wifiPasswordTextField;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIWebView *gifWebView;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIView *centerView;

@end
