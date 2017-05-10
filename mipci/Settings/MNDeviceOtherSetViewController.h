//
//  UIotherSettingTableViewController.h
//  mining_client
//
//  Created by mining on 14-9-12.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNDeviceOtherSetViewController : UITableViewController

@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
//@property (strong, nonatomic) NSString     *title;

@property (weak, nonatomic) IBOutlet UILabel *speakerValueLable;
@property (weak, nonatomic) IBOutlet UILabel *microphoneValueLable;

@property (weak, nonatomic) IBOutlet UISlider *speakerSlider;
@property (weak, nonatomic) IBOutlet UISlider *microphoneSlider;

@property (weak, nonatomic) IBOutlet UISwitch *overturnSwitch;

@property (weak, nonatomic) IBOutlet UILabel *speakerTiteLable;
@property (weak, nonatomic) IBOutlet UILabel *microphoneTiteLable;
@property (weak, nonatomic) IBOutlet UILabel *overturnTiteLable;;
@property (weak, nonatomic) IBOutlet UISegmentedControl *frequencySegment;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;

@property (weak, nonatomic) IBOutlet UITableViewCell *screenSettingCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *screenSegment;

@end
