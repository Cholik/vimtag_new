//
//  UITabBar+badgeValue.h
//  mipci
//
//  Created by mining on 15/9/18.
//
//

#import <UIKit/UIKit.h>

@interface UITabBar (badgeValue)

- (void)showBadgeOnItemIndex:(int)index;   //Show little red dot

- (void)hideBadgeOnItemIndex:(int)index; //Hide little red dot
@end
