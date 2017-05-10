//
//  MNAlertButtonItem.m
//  mipci
//
//  Created by mining on 16/1/28.
//
//

#import "MNAlertButtonItem.h"

@implementation MNAlertButtonItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (_defaultRightLineVisible) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, self.bounds);
        
//        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.671 green:0.675 blue:0.694 alpha:1.000].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1.0].CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, CGRectGetWidth(self.frame),0);
        CGContextAddLineToPoint(context, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        CGContextStrokePath(context);
    }
}

@end