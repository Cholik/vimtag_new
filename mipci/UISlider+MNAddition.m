//
//  UISlider+Addition.m
//  mipci
//
//  Created by weken on 15/2/4.
//
//

#import "UISlider+MNAddition.h"

@implementation UISlider (MNAddition)

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:self];
    CGFloat scale  = point.x / self.bounds.size.width;
    [self setValue:(scale * self.maximumValue) animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
