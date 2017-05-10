//
//  MNCheckNetworkViewController.h
//  mipci
//
//  Created by mining on 16/11/2.
//
//

#import <UIKit/UIKit.h>

@interface MNCheckNetworkViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *promptTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *firstPromptText;
@property (weak, nonatomic) IBOutlet UITextView *firstContentText;
@property (weak, nonatomic) IBOutlet UITextView *secondContentText;

@property (weak, nonatomic) IBOutlet UITextView *secondPromptText;
@property (weak, nonatomic) IBOutlet UITextView *thirdContentText;

@property (weak, nonatomic) IBOutlet UIView *firstCircleView;
@property (weak, nonatomic) IBOutlet UIView *secondCircleView;
@property (weak, nonatomic) IBOutlet UIView *thirdCircleView;

@end
