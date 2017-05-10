//
//  MNSetNickNameViewController.h
//  mipci
//
//  Created by PC-lizebin on 16/8/8.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNSetNickNameViewController : UIViewController
@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
@property (strong, nonatomic) NSString     *exdevID;
@property (assign, nonatomic) long rtime;
@property (strong, nonatomic) NSMutableArray *exdevs;

@end
