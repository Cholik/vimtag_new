//
//  MNFeedbackViewController.h
//  mipci
//
//  Created by mining on 15/11/11.
//
//

#import <UIKit/UIKit.h>
#import "MNWebViewProgress.h"
#import "MNWebViewProgressView.h"

@interface MNFeedbackViewController : UIViewController <UIWebViewDelegate>


@property (strong,nonatomic) UIWebView *feedbackWebview;


@end

