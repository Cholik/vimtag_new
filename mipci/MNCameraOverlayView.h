//
//  MNCameraOverlayView.h
//  QR code
//
//  Created by mining on 14-7-9.
//  Copyright (c) 2014年 斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNCameraOverlayView : UIView

@property (assign, nonatomic) CGSize scanMaskSize;
@property (strong, nonatomic) NSString *remindContent;

- (void)startAnimate;
- (void)stopAnimate;
@end
