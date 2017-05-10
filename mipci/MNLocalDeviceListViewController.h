//
//  MNLocalDeviceListViewController.h
//  mipci
//
//  Created by mining on 15/11/13.
//
//

#import <UIKit/UIKit.h>
//#import "MNDeviceListPageViewController.h"

@interface MNLocalDeviceListViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *emptyPromptView;
@property (weak, nonatomic) IBOutlet UILabel *firstLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLineLabel;

@end
