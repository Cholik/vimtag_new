//
//  MNWIFIListViewController.h
//  mipci
//
//  Created by weken on 15/3/16.
//
//

#import <UIKit/UIKit.h>
@class MNModifyWIFIViewController;

@interface MNWIFIListViewController : UITableViewController
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) MNModifyWIFIViewController *modifyWIFIViewController;
@end
