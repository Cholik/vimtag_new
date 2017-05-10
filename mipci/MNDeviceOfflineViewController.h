//
//  MNDeviceOfflineViewController.h
//  mipci
//
//  Created by mining on 15/5/12.
//
//

#import <UIKit/UIKit.h>

@interface MNDeviceOfflineViewController : UIViewController<UIAlertViewDelegate>

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *devicePassword;
@property (assign, nonatomic) BOOL      is_loginModify;
@property (assign, nonatomic) long      qrc;
@property (assign, nonatomic) long      snc;
@property (assign, nonatomic) long      wfc;
@property (strong, nonatomic) NSString *sncf;
@property (assign, nonatomic) long      wfcnr;

@property (strong, nonatomic) IBOutlet UIButton *wifiButton;
@property (strong, nonatomic) IBOutlet UIButton *ethernetButton;
@property (weak, nonatomic) IBOutlet UILabel *wifiConnectLabel;
@property (weak, nonatomic) IBOutlet UILabel *ethConnectLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *ethPromptLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (weak, nonatomic) IBOutlet UILabel *deviceOfflineLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *devOffLabConstrains;

@end
