//
//  MNMyOrderViewController.h
//  mipci
//
//  Created by tanjiancong on 16/8/11.
//
//

#import <UIKit/UIKit.h>
#import "WXApi.h"


@interface MNMyOrderViewController : UIViewController<WXApiDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *noNetworkView;
@property (weak, nonatomic) IBOutlet UILabel *noNetworkLabel;
@property (weak, nonatomic) IBOutlet UIButton *noNetworkButton;

+ (MNMyOrderViewController *)shared_myOrderViewController;


@end

