//
//  MNPlayProgressView.h
//  mipci
//
//  Created by mining on 15/12/8.
//
//

#import <UIKit/UIKit.h>

@class MNPlayProgressView;

@protocol MNPlayProgressViewDelegate <NSObject>

//- (void)sliderStatusChange;
- (void)sliderValueChange:(CGFloat)value;
- (void)showThumbnailImageOrNot:(BOOL)is_show;
- (void)sliderShowThumbnailValue:(CGFloat)value;

@end

@interface MNPlayProgressView : UIView

@property (weak, nonatomic) id<MNPlayProgressViewDelegate>delegate;

@property (strong, nonatomic) UIImageView   *handleImageView;

@property (assign, nonatomic) CGFloat maxValue;
@property (assign, nonatomic) CGFloat minValue;
@property (assign, nonatomic) CGFloat value;

@property (assign, nonatomic) long long startTime;
@property (assign, nonatomic) long long endTime;

@property (strong, nonatomic) NSMutableArray *segsArray;
@property (strong, nonatomic) NSMutableArray *flagArray;
@property (assign, nonatomic) BOOL isSlide;

- (void)progressValueChange:(long long)value;
- (void)updateViewConstraint;

@end
