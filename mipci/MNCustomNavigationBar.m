//
//  MNCustomNavigationBar.m
//  mipci
//
//  Created by mining on 15/9/16.
//
//

#import "MNCustomNavigationBar.h"

@implementation MNCustomNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
                [view removeFromSuperview];
            }
        }
    }
    return self;
}

@end
