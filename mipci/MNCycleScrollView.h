//
//  MNCycleScrollView.h
//  mipci
//
//  Created by mining on 16/1/22.
//
//

#import <UIKit/UIKit.h>

@interface MNCycleScrollView : UIView

@property (nonatomic , readonly) UIScrollView *scrollView;
@property (nonatomic , copy) NSInteger (^totalPagesCount)(void);
@property (nonatomic , copy) UIView *(^fetchContentViewAtIndex)(NSInteger pageIndex);
@property (nonatomic , copy) void (^TapActionBlock)(NSInteger pageIndex);

/**
 *  init
 *
 *  @param frame
 *  @param animationDuration
 *
 *  @return instance
 */
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;
- (void)stopAnimationDuration;

@end
