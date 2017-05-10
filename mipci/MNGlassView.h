//
//  MNGlassView.h
//  mipci
//
//  Created by mining on 16/1/25.
//
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>

@interface MNGlassView : UIView

@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) UIView *blurSuperView;

@end
