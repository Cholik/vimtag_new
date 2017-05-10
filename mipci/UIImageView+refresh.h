//
//  UIImageView+refresh.h
//  mipci
//
//  Created by mining on 16/5/27.
//
//

#import <UIKit/UIKit.h>

@interface UIImageView (refresh)
-(void)setImageViewFrame:(UICollectionView *)collectionView with:(CGSize)labelSize;
-(void)layoutFrame:(UIView *)view with:(CGSize)labelSize;
-(void)start;
-(void)initRefreshWithLabel:(UILabel *)downRefreshLabel and:(UICollectionView *)collectionView;
-(void)layoutRefreshWithLabel:(UILabel *)downRefreshLabel and:(UICollectionView *)collectionView;
@end
