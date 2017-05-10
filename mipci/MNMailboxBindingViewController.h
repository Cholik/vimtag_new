//
//  MNMailboxBindingViewController.h
//  mipci
//
//  Created by mining on 15/9/23.
//
//

#import <UIKit/UIKit.h>

@interface MNMailboxBindingViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UITextField *securityCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@property (weak, nonatomic) IBOutlet UILabel *PromptLabel;

@end
