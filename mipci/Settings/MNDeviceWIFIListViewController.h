//
//  MNDeviceWIFIListViewController.h
//  mipci
//
//  Created by weken on 15/3/17.
//
//

#import <UIKit/UIKit.h>
@class MNDeviceWIFISetViewController;

@interface MNDeviceWIFIListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *deviceID;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITableView *wifiTableView;

@property (strong, nonatomic) MNDeviceWIFISetViewController *deviceWIFISetViewController;
@end
