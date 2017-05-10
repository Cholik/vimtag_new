//
//  MNMessagePageViewController.h
//  mipci
//
//  Created by mining on 15/9/24.
//
//

#import <UIKit/UIKit.h>

@interface MNMessagePageViewController : UIPageViewController

@property (copy, nonatomic) NSString *deviceID;
@property (weak, nonatomic) IBOutlet UISegmentedControl *messageStyleSegmented;
@property (weak, nonatomic) IBOutlet UIView *itemBtnView;

@end
