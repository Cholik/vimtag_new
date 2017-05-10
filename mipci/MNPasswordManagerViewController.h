//
//  MNPasswordManagerViewController.h
//  mipci
//
//  Created by weken on 15/3/10.
//
//

#import <UIKit/UIKit.h>

@interface MNPasswordManagerViewController : UITableViewController
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *adminName;
@property (assign, nonatomic) BOOL isAdmin;

@property (weak, nonatomic) IBOutlet UILabel *currentPasswordHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *changePasswordHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *commitPasswordHintLabel;

@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *changePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *commitPasswordTextField;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@end
