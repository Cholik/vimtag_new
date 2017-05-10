//
//  MNScheduleViewCell.m
//  mipci
//
//  Created by mining on 16/4/15.
//
//

#import "MNScheduleViewCell.h"

@implementation MNScheduleViewCell

- (void)setLabelLayer:(NSInteger)index
{
    CAShapeLayer*maskLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *maskPath;
    if (index == LAYER_STYLE_SQUARE)
    {
        maskPath= [UIBezierPath bezierPathWithRect:_numberLabel.bounds];
    }
    else if (index == LAYER_STYLE_CIRCULAR)
    {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:_numberLabel.bounds cornerRadius:_numberLabel.bounds.size.width/2];
    }
    else if (index == LAYER_STYLE_SEMICIRCLE_LEFT)
    {
        maskPath= [UIBezierPath bezierPathWithRoundedRect:_numberLabel.bounds
                                        byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft
                                              cornerRadii:CGSizeMake(50,50)];
    }
    else if (index == LAYER_STYLE_SEMICIRCLE_RIGHT)
    {
        maskPath= [UIBezierPath bezierPathWithRoundedRect:_numberLabel.bounds
                                        byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight
                                              cornerRadii:CGSizeMake(50,50)];
    }
    maskLayer.frame = _numberLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    _numberLabel.layer.mask = maskLayer;
}

@end
