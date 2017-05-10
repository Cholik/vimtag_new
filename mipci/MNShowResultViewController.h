//
//  MNShowResultViewController.h
//  mipci
//
//  Created by mining on 15/9/9.
//
//

#import <UIKit/UIKit.h>

@interface MNShowResultViewController : UIViewController
@property (strong, nonatomic) NSString *deviceID;
@property (assign, nonatomic) BOOL      is_onlyAdd;
@property (assign, nonatomic) BOOL      is_changePwd;
@property (assign, nonatomic) BOOL      is_connectWiFi;
@property (assign, nonatomic) BOOL      is_notAdd;
@property (assign, nonatomic) BOOL      is_loginModify;
@property (assign, nonatomic) BOOL      is_timezoneModify;

@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyLabel;
@property (weak, nonatomic) IBOutlet UILabel *setWiFILabel;
@property (weak, nonatomic) IBOutlet UILabel *timezoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *addSuccessLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifySuccessLabel;
@property (weak, nonatomic) IBOutlet UILabel *setSuccessLabel;
@property (weak, nonatomic) IBOutlet UILabel *timezoneSuccessLabel;

@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UIView *modifyView;
@property (weak, nonatomic) IBOutlet UIView *setView;
@property (weak, nonatomic) IBOutlet UIView *timezoneView;

@property (weak, nonatomic) IBOutlet UIButton *certainButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *modifyLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *setLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certainLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timezoneLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

//@property (retain, nonatomic) MNDeviceListPageViewController *deviceListViewController;

@end
