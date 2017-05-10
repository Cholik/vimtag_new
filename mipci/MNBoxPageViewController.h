//
//  MNBoxPageViewController.h
//  mipci
//
//  Created by mining on 15/11/21.
//
//

#import <UIKit/UIKit.h>

@interface MNBoxPageViewController : UIPageViewController

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *boxID;
@property (weak, nonatomic) IBOutlet UISegmentedControl *boxStyleSegmented;
@property (weak, nonatomic) IBOutlet UIView *itemBtnView;


@end
