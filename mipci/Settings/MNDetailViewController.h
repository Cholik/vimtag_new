//
//  MLDetailViewController.h
//  SpliteViewDemo
//
//  Created by mining on 14-10-24.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNDeviceSettingsViewController.h"

@protocol MNDetailViewControllerDelegate <NSObject>

@required
- (IBAction)select:(id)sender;

@end

@interface MNDetailViewController : UIViewController<MNDeviceSettingsViewControllerDelegate>
@property (nonatomic, assign) id<MNDetailViewControllerDelegate> delegate;

@end
