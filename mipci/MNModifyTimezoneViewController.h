//
//  MNModifyTimezoneViewController.h
//  mipci
//
//  Created by mining on 16/11/7.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNModifyTimezoneViewController : UIViewController

@property (strong, nonatomic) NSString *deviceID;
@property (assign, nonatomic) BOOL      isChangePwd;
@property (assign, nonatomic) BOOL      is_notAdd;
@property (assign, nonatomic) BOOL      is_loginModify;
@property (assign, nonatomic) BOOL      is_exit;
@property (assign, nonatomic) BOOL      is_connectWiFi;
@property (assign, nonatomic) BOOL      is_onlyAdd;

@property (strong, nonatomic) zone_obj   *timezone_obj;
@property (assign, nonatomic) BOOL      is_playModify;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UILabel *phoneTimezoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTimezoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectTimezoneButton;
@property (weak, nonatomic) IBOutlet UIButton *modifyButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (weak, nonatomic) IBOutlet UIView *remindView;
@property (weak, nonatomic) IBOutlet UILabel *remindLabel;
@property (weak, nonatomic) IBOutlet UISwitch *remindSwitch;

@end
