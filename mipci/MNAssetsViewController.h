//
//  MNAssetsViewController.h
//  mipci
//
//  Created by mining on 16/9/2.
//
//

#import <UIKit/UIKit.h>
@class ALAssetsGroup;

@interface MNAssetsViewController : UIViewController
@property(nonatomic,strong) ALAssetsGroup *group;
@property(nonatomic,assign) NSInteger maxCount;

@property(nonatomic,strong) UICollectionView *collectionView;

@end
