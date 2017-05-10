//
//  MNLoginViewController.h
//  ipcti
//
//  Created by MagicStudio on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXingWidget/Classes/ZXingWidgetController.h"
#import "MNRegisterViewController.h"

@class mipc_agent;

@interface MNLoginViewController : UIViewController <ZXingDelegate,UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) mipc_agent                    *agent;

@property (weak, nonatomic) IBOutlet UIView                 *contentView;
@property (weak, nonatomic) IBOutlet UIImageView            *imgLogo;
@property (weak, nonatomic) IBOutlet UIImageView            *detailLogo;

@property (weak, nonatomic) IBOutlet UIView                 *viewServerLine;
@property (weak, nonatomic) IBOutlet UIView                 *viewUserLine;
@property (weak, nonatomic) IBOutlet UIView                 *viewPasswordLine;
@property (weak, nonatomic) IBOutlet UITextField            *txtServer;
@property (weak, nonatomic) IBOutlet UITextField            *txtUser;
@property (weak, nonatomic) IBOutlet UIButton               *btnQRCode;
@property (weak, nonatomic) IBOutlet UITextField            *txtPassword;
@property (weak, nonatomic) IBOutlet UILabel                *lblRememberPassword;
@property (weak, nonatomic) IBOutlet UISwitch               *swtRememberPassword;
@property (weak, nonatomic) IBOutlet UIButton               *btnLogin;
@property (weak, nonatomic) IBOutlet UILabel                *lblStatus;
@property (weak, nonatomic) IBOutlet UIButton               *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton               *SereneViewerRegisterBtn;
@property (weak, nonatomic) IBOutlet UIButton               *showPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton               *recoveryPasswordButton;
@property (weak, nonatomic) IBOutlet UILabel                *registerLabel;
@property (weak, nonatomic) IBOutlet UIImageView            *serverInputImageView;
@property (weak, nonatomic) IBOutlet UIImageView            *userInputImageView;
@property (weak, nonatomic) IBOutlet UIImageView            *passwordInputImageView;
@property (assign, nonatomic)   unsigned char               *encrypt_password;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *logoViewVerticalSpaceToTop;
@property (weak, nonatomic) IBOutlet UIImageView            *loginBackground;

//Ebitcam
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIImageView *pwdImage;
@property (weak, nonatomic) IBOutlet UIView *userLine;
@property (weak, nonatomic) IBOutlet UIView *pwdLine;
@property (weak, nonatomic) IBOutlet UIButton *rememberPwdButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkFrameLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *userInputImage;
@property (weak, nonatomic) IBOutlet UIImageView *pwdInputImage;


@property (strong, nonatomic) NSTimer                       *timerSrvCheck;
@property (strong, nonatomic) NSString                      *sConnectedDevID;

@property (assign, nonatomic) BOOL                          is_wifiConfig;
@property (assign, nonatomic) BOOL                          isMallLogin;

@end
