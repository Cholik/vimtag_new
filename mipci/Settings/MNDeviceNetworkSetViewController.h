//
//  MNDeviceNetworkSetViewController.h
//  mipci
//
//  Created by mining on 15/10/9.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNDeviceNetworkSetViewController : UIViewController

@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (strong, nonatomic) NSString *title;

@property (weak, nonatomic) IBOutlet UISegmentedControl *networkSelectSegment;
@property (weak, nonatomic) IBOutlet UIView *containerNetworkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerLayoutConstraint;

@end
