//
//  MNWIFIConnectViewController.h
//  mipci
//
//  Created by mining on 15/5/12.
//
//

#import <UIKit/UIKit.h>

@interface MNWIFIPasswordViewController : UIViewController<UIAlertViewDelegate>

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *devicePassword;
@property (assign, nonatomic) BOOL      is_loginModify;
@property (weak, nonatomic) NSString *routeAddress;

@property (weak, nonatomic) IBOutlet UITextField *wifiNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *wifiPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIImageView *wifiInputImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordInputImageView;
@property (weak, nonatomic) IBOutlet UIButton *showPasswordBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIImageView *wifiImage;
@property (weak, nonatomic) IBOutlet UIImageView *keyImage;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@end
