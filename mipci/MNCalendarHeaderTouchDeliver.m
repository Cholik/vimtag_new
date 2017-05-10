//
//  MNCalendarHeaderTouchDeliver.m
//  mipci
//
//  Created by mining on 15/11/2.
//
//

#import "MNCalendarHeaderTouchDeliver.h"
#import "MNCalendar.h"
#import "MNCalendarHeader.h"
#import "MNCalendarDynamicHeader.h"

@implementation MNCalendarHeaderTouchDeliver

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return _calendar.collectionView ?: hitView;
    }
    return hitView;
}

@end
