//
//  UITabBar+badgeValue.m
//  mipci
//
//  Created by mining on 15/9/18.
//
//

#import "UITabBar+badgeValue.h"
#define TabbarItemNums 3.0 

@implementation UITabBar (badgeValue)

//Show little red dot
- (void)showBadgeOnItemIndex:(int)index{
    //Remove before the red dot
    [self removeBadgeOnItemIndex:index];
    
    //New little red dot
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 5;//
    badgeView.backgroundColor = [UIColor redColor];//
    CGRect tabFrame = self.frame;
    
    //Determine the location of the red dot
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || (self.frame.size.width == 736) )
    {
        if (index == 1) { //BOX
            badgeView.frame = CGRectMake(tabFrame.size.width /2 + 65, ceilf(0.1 * tabFrame.size.height), 10, 10);
            [self addSubview:badgeView];
        }
        else
        {
            badgeView.frame = CGRectMake(tabFrame.size.width /2 + 120, ceilf(0.1 * tabFrame.size.height), 10, 10);
            [self addSubview:badgeView];
        }
        
    }
    else
    {
        float percentX;
        CGFloat x, y;

        if (index == 1) { // BOX
            if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
            {
                percentX = (index +0.6) / (TabbarItemNums - 1);
                x = ceilf(percentX * tabFrame.size.width);
                y = ceilf(0.1 * tabFrame.size.height);
                badgeView.frame = CGRectMake(x - 20, y, 10, 10);//Round Size 10
                [self addSubview:badgeView];
            }
            else
            {
                percentX = (index +0.6) / (TabbarItemNums - 1);
                x = ceilf(percentX * tabFrame.size.width);
                y = ceilf(0.1 * tabFrame.size.height);
                badgeView.frame = CGRectMake(x - 5, y, 10, 10);//Round Size 10
                [self addSubview:badgeView];
            }
        }
        else
        {
            if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
            {
                percentX = (index +0.6) / TabbarItemNums;
                x = ceilf(percentX * tabFrame.size.width);
                y = ceilf(0.1 * tabFrame.size.height);
                badgeView.frame = CGRectMake(x - 10, y, 10, 10);//Round Size 10
                [self addSubview:badgeView];
            }
            else
            {
                percentX = (index +0.6) / TabbarItemNums;
                x = ceilf(percentX * tabFrame.size.width);
                y = ceilf(0.1 * tabFrame.size.height);
                badgeView.frame = CGRectMake(x, y, 10, 10);//Round Size 10
                [self addSubview:badgeView];
            }
           
        }
       
    }
   
}

//Hide little red dot
- (void)hideBadgeOnItemIndex:(int)index{
    //Remove little red dot
    [self removeBadgeOnItemIndex:index];
}

//Remove little red dot
- (void)removeBadgeOnItemIndex:(int)index{
    //Remove the tag values
    for (UIView *subView in self.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}

@end
