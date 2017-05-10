//
//  MNProductInformationViewController.h
//  mipci
//
//  Created by mining on 15/11/6.
//
//

#import <UIKit/UIKit.h>
#import "MNWebViewProgress.h"
#import "MNWebViewProgressView.h"
#import "WXApi.h"


@interface MNProductInformationViewController : UIViewController <UIWebViewDelegate, MNWebViewProgressDelegate, WXApiDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *customWebView;
@property (weak, nonatomic) IBOutlet UIView *noNetworkView;
@property (weak, nonatomic) IBOutlet UILabel *noNetworkLabel;
@property (weak, nonatomic) IBOutlet UIButton *noNetworkButton;

@property(strong, nonatomic) NSString *jsParam;

@property (strong, nonatomic) MNWebViewProgressView *progressView;
@property (strong, nonatomic) MNWebViewProgress *progressProxy;
@property (strong, nonatomic) UIBarButtonItem *backButton;

- (void)loadWeb;
+ (MNProductInformationViewController *)shared_productInformationViewController;

@end
