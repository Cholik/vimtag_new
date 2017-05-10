//
//  MNWebViewProgressView.h
//  mipci
//
//  Created by mining on 15/11/7.
//
//

#import <UIKit/UIKit.h>

@interface MNWebViewProgressView : UIView

@property (nonatomic) float progress;

@property (nonatomic) UIView *progressBarView;
@property (nonatomic) NSTimeInterval barAnimationDuration; // default 0.1
@property (nonatomic) NSTimeInterval fadeAnimationDuration; // default 0.27
@property (nonatomic) NSTimeInterval fadeOutDelay; // default 0.1

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
