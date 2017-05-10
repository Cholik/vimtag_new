//
//  MNAlertBackgroundWindow.m
//  mipci
//
//  Created by mining on 16/1/25.
//
//

#import "MNAlertBackgroundWindow.h"

const UIWindowLevel UIWindowLevelCXAlert = 1999.0;
const UIWindowLevel UIWindowLevelCXAlertBackground = 1998.0;

@implementation MNAlertBackgroundWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = UIWindowLevelAlert - 1;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor colorWithWhite:0 alpha:0.5] set];
    CGContextFillRect(context, self.bounds);
}
@end
