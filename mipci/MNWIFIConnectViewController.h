//
//  MNWIFIConnectViewController.h
//  mipci
//
//  Created by mining on 15/6/11.
//
//

#import <UIKit/UIKit.h>
#import "MNWiFiConfigProgressView.h"

@interface MNWIFIConnectViewController : UIViewController
{
    unsigned char    _encrypt_pwd[16];
}

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *devicePassword;
@property (assign, nonatomic) BOOL      is_loginModify;
@property (weak, nonatomic) UITextField *wifiNameTextField;
@property (weak, nonatomic) UITextField *wifiPasswordTextField;
@property (weak, nonatomic) NSString *routeAddress;
@property (assign, nonatomic) BOOL  is_configure;

@property (weak, nonatomic) IBOutlet UIWebView *gifWebView;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeBgImage;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImage;  //QRImage
@property (weak, nonatomic) IBOutlet UILabel *qrPromptLabel;

@property (weak, nonatomic) IBOutlet UIView *retryView;         //Show retry or success view
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UILabel *retryLabel;
@property (weak, nonatomic) IBOutlet UILabel *failLabel;

@property (weak, nonatomic) IBOutlet UIView *soundConfView;     //Sound Conf View
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak, nonatomic) IBOutlet UILabel *soundPromptLabel;

@property (weak, nonatomic) IBOutlet UILabel *connectRouterLabel;

@property (weak, nonatomic) IBOutlet UIView *confView;          //Conf Progress View
@property (weak, nonatomic) IBOutlet UIView *timeCountView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *progressImgView;
@property (weak, nonatomic) IBOutlet MNWiFiConfigProgressView *configProgressView;

@property (weak, nonatomic) IBOutlet UIView *confResultView;    //Result View
@property (weak, nonatomic) IBOutlet UILabel *resultPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectETHLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectETHButton;

@property (weak, nonatomic) IBOutlet UIView *tabbarView;        //Tabbar View
@property (weak, nonatomic) IBOutlet UIButton *normalButton;
@property (weak, nonatomic) IBOutlet UIButton *QRButton;
@property (weak, nonatomic) IBOutlet UILabel *wifiConnectLabel;
@property (weak, nonatomic) IBOutlet UILabel *qrconnectLabel;

@property (weak, nonatomic) IBOutlet UIView *qrcodePromptView;  //QR Code Prompt View
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *promptImage;
@property (weak, nonatomic) IBOutlet UIButton *certainButton;
@property (strong, nonatomic) NSString *langString;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewToTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confResultViewToTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confViewToTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainviewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *QRCodeImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *QRCodeImageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleViewTrailing;


@end
