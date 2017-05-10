//
//  MNNotificationTableViewController.h
//  mipci
//
//  Created by mining on 16/11/16.
//
//

#import <UIKit/UIKit.h>

@interface MNNotificationTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *soundLabel;
@property (weak, nonatomic) IBOutlet UILabel *vibration;
@property (weak, nonatomic) IBOutlet UILabel *ringLabel;

@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *vibrationSwitch;

@end
