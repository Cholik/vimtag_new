//
//  MNFeelingViewController.h
//  mipci
//
//  Created by mining on 16/3/31.
//
//

#import <UIKit/UIKit.h>
//#import "MNDeviceListPageViewController.h"
#import "MNPopoverView.h"
#import "MNQRCodeViewController.h"

@interface MNFeelingViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,PopoverViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
