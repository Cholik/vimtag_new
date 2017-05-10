//
//  MNToast.h
//  ToastDemo
//
//  Created by weken on 15/3/12.
//  Copyright (c) 2015年 weken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNToastView : UIView
{
@private
    CGFloat           ipad;
}
@property(nonatomic,strong) UIImageView       *imageView;
@property(nonatomic,strong) UILabel           *label;

- (void)dismissToast;

+ (MNToastView*)successToast:(NSString*)title;
+ (MNToastView*)failToast:(NSString*)title;
+ (MNToastView*)promptToast:(NSString*)title;
+ (MNToastView*)alertToast:(NSString*)title;
+ (MNToastView*)connectToast:(NSString *)title;
+ (MNToastView*)promptNoImageToast:(NSString*)title;

@end
