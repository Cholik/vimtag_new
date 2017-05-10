//
//  MNSelectAccessoryTypeViewController.h
//  mipci
//
//  Created by mining on 16/4/20.
//
//

#import <UIKit/UIKit.h>
#import "MNSearchAccessoryViewController.h"

@interface MNSelectAccessoryTypeViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,assign) NSInteger type;
@property (strong, nonatomic) mipc_agent   *agent;
@property (strong, nonatomic) NSString     *deviceID;

@end
