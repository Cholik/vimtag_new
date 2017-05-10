//
//  MNSearchAccessoryViewController.h
//  mipci
//
//  Created by mining on 16/1/13.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNSearchAccessoryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,assign) NSInteger type;
@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;
//@property (nonatomic,assign,getter=isAddRecall) BOOL addRecall;
//@property (nonatomic,strong) mcall_ret_exdev_add *ret;
@property (nonatomic,assign) long exit;
@property (nonatomic,strong) NSString *exdevID;


@end
