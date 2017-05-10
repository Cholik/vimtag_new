//
//  MNDeviceAboutViewController.h
//  mining_client
//
//  Created by mining on 14-9-9.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNDeviceAboutViewController : UITableViewController

@property (strong, nonatomic) mipc_agent  *agent;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;

@property (weak, nonatomic) IBOutlet UILabel *deviceModelHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareVersionHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceIDHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmHintLabel;

@property (weak, nonatomic) IBOutlet UITextView *deviceIDTextView;
@property (weak, nonatomic) IBOutlet UITextView *versionTextView;
@property (weak, nonatomic) IBOutlet UITextView *deviceModelTextView;
@property (weak, nonatomic) IBOutlet UITextView *firmTextView;

@property (weak, nonatomic) IBOutlet UIImageView *logoImage;

@property (weak, nonatomic) IBOutlet UITableViewCell *sensorStatuCell;
@property (weak, nonatomic) IBOutlet UILabel *breakDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorStatuLabel;

@end
