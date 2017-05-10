//
//  MNAlertButtonContainerView.m
//  mipci
//
//  Created by mining on 16/1/28.
//
//

#import "MNAlertButtonContainerView.h"



@interface MNAlertButtonContainerView ()

@end

@implementation MNAlertButtonContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _buttons = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _buttons = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (_defaultTopLineVisible) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, self.bounds);
        
//        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.671 green:0.675 blue:0.694 alpha:1.000].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1.0].CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, 0,0);
        CGContextAddLineToPoint(context, CGRectGetWidth(self.frame), 0);
        CGContextStrokePath(context);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - PB
- (void)addButtonWithTitle:(NSString *)title type:(MNAlertViewButtonType)type handler:(MNAlertButtonHandler)handler
{
    
}

#pragma mark - PV

@end
