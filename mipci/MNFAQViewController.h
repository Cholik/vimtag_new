//
//  MNFAQViewController.h
//  mipci
//
//  Created by mining on 15/11/7.
//
//

#import <UIKit/UIKit.h>
#import "MNWebViewProgress.h"
#import "MNWebViewProgressView.h"

@interface MNFAQViewController : UIViewController <UIWebViewDelegate, MNWebViewProgressDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *customWebView;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *selectSegment;
@property (weak, nonatomic) IBOutlet UIView *noNetworkView;
@property (weak, nonatomic) IBOutlet UILabel *noNetworkLabel;
@property (weak, nonatomic) IBOutlet UIButton *noNetworkButton;

@property (strong, nonatomic) MNWebViewProgressView *progressView;
@property (strong, nonatomic) MNWebViewProgress *progressProxy;

@end
