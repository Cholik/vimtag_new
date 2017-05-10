//
//  MNGuestPasswordManagerViewController.h
//  mining_client
//
//  Created by mining on 14-9-9.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNGuestPasswordManagerViewController : UITableViewController<UITextFieldDelegate>

@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
@property (strong, nonatomic) NSString *adminName;
//@property (strong, nonatomic) NSString *title;

@property (weak, nonatomic) IBOutlet UILabel *adminPasswordHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *visitorPasswordHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *commitPasswordHintLabel;

@property (weak, nonatomic) IBOutlet UITextField *adminPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *visitorPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *commitPasswordTextField;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@end
