//
//  MNAccessoryPromptViewController.h
//  mipci
//
//  Created by mining on 16/3/29.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNAccessoryPromptViewController : UIViewController

@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;

@property (strong, nonatomic) NSString *exdev_type;

@property (weak, nonatomic) IBOutlet UIImageView *promptImage;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end
