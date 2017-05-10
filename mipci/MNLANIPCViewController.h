//
//  MNLANIPCViewController.h
//  mipci
//
//  Created by mining on 15/10/12.
//
//

#import <UIKit/UIKit.h>

@interface MNLANIPCViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *deviceList;
@property (strong, nonatomic) NSString *selectedDeviceID;
@property (strong, nonatomic) NSString *selectedDeviceIP;

@end
