//
//  MNNetworkPageViewController.h
//  mipci
//
//  Created by mining on 15/10/9.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"
#import "MNDetailViewController.h"

@interface MNNetworkPageViewController : UIPageViewController <UIPageViewControllerDelegate,MNDetailViewControllerDelegate>
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (strong, nonatomic) NSString *title;

//@property (weak, nonatomic) IBOutlet UISegmentedControl *networkSelect;
- (void)selectIndex:(NSInteger)index;

@end
