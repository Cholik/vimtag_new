//
//  MNDeviceGuideViewController.h
//  mipci
//ggg
//  Created by weken on 15/3/14.
//
//

#import <UIKit/UIKit.h>

@interface MNDeviceGuideViewController : UIViewController<UIAlertViewDelegate>

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *password;
@property (assign, nonatomic) long      qrc;
@property (assign, nonatomic) long      snc;
@property (assign, nonatomic) long      wfc;
@property (assign, nonatomic) BOOL      is_loginModify;

@property (weak, nonatomic) IBOutlet UILabel *deviceIDHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstStepHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondStepHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@property (weak, nonatomic) IBOutlet UILabel *waitDeviceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UILabel *assemblyLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
