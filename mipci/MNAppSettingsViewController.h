//
//  MNAppSettingsViewController.h
//  mipci
//
//  Created by weken on 15/3/5.
//
//

#import <UIKit/UIKit.h>

@interface MNAppSettingsViewController : UITableViewController<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *soundTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *vibrationTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *ringtoneTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *bufferTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bindingEmaiLabel;

@property (weak, nonatomic) IBOutlet UILabel *adminPasswordTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *guestPasswordTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareVersionTiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *webMobileSoftwareVersionTitelabel;
@property (weak, nonatomic) IBOutlet UILabel *webMobileSoftwareVersionLabel;
@property (weak, nonatomic) IBOutlet UIButton *cleanCacheButton;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *vibrationSwitch;

@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *exitTableViewCell;

@end
