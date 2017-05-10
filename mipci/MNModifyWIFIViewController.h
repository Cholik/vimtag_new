//
//  MNModifyWIFIViewController.h
//  mipci
//
//  Created by mining on 15-1-16.
//
//

#import <UIKit/UIKit.h>

@interface MNModifyWIFIViewController : UIViewController

@property (strong, nonatomic) NSString *deviceID;
@property(nonatomic,assign) BOOL       isChangePwd;
@property (assign, nonatomic) BOOL      is_notAdd;
@property (weak, nonatomic) IBOutlet UILabel *deviceIDHintLabel;
@property (weak, nonatomic) IBOutlet UITextField *WIFINameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIImageView *wifiInputImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordInputImageView;

@property (weak, nonatomic) IBOutlet UIButton *showPasswordBtn;
@property (weak, nonatomic) IBOutlet UILabel *promaptLabel;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIImageView *wifiImage;
@property (weak, nonatomic) IBOutlet UIImageView *keyImage;
@property (weak, nonatomic) IBOutlet UIButton *selectWiFiBtn;

@property (assign, nonatomic) BOOL      is_loginModify;
@property (assign, nonatomic) BOOL      is_exit;

@end
