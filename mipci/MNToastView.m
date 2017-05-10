//
//  MNToast.m
//  ToastDemo
//
//  Created by weken on 15/3/12.
//  Copyright (c) 2015年 weken. All rights reserved.
//

#import "MNToastView.h"

@interface MNToastView()
{
    CGFloat defaultWidth;
    CGFloat defaultHeight;
}

@end

@implementation MNToastView

- (id)init
{
    if(self = [super init])
    {
        ipad = (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())?2.f:1.f;
        
        self.backgroundColor = [UIColor colorWithWhite:.0f alpha:.7f];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.layer.cornerRadius = 10.f;
        self.alpha = .0f;
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect  bounds = self.superview.bounds;
    CGFloat height = bounds.size.height,
    width = bounds.size.width,
    toastHeight = 130.f*ipad,
    toastWeight = (defaultWidth>(120.f*ipad))?(defaultWidth+40.f):140.f*ipad;
    
    self.frame = CGRectMake(0.f,0.f,toastWeight,toastHeight);
    self.center = CGPointMake(width*.5f,height*.4f);
    
    self.imageView.frame = CGRectMake((toastWeight-40.f*ipad)*.5f,20.f*ipad,40.f*ipad,40.f*ipad);
    self.label.frame = CGRectMake(0.f,55.f*ipad,toastWeight,75.f*ipad);
}

- (MNToastView*)initWithImage:(NSString*)image title:(NSString*)title
{
    self = [self init];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.alpha = 1.f;
    self.imageView.opaque = YES;
    [self addSubview:_imageView];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectZero];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont boldSystemFontOfSize:15.f*ipad];
    self.label.alpha = 1.f;
    self.label.numberOfLines = 0;
    [self addSubview:_label];
    
    self.imageView.image = [UIImage imageNamed:image];
    self.label.text = title;
    
//    defaultWidth = [title sizeWithFont:self.label.font constrainedToSize:CGSizeMake(220.f*ipad, 40.f*ipad)].width;
    CGSize labelSize = [title sizeWithFont:self.label.font constrainedToSize:CGSizeMake(220.f*ipad, 40.f*ipad)];
    defaultWidth = labelSize.width;
    defaultHeight = labelSize.height;
    
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = .9f;
    }];
    return self;
}


- (void)dismissToast
{
    [UIView animateKeyframesWithDuration:1.0f
                                   delay:2.0f
                                 options:UIViewKeyframeAnimationOptionAllowUserInteraction
                              animations:^{
                                  self.alpha = 0.0f;
                              } completion:^(BOOL finished) {
                                  [self removeFromSuperview];
                              }];
}

+ (MNToastView*)successToast:(NSString*)title
{
    MNToastView *toast = [[MNToastView alloc] initWithImage:@"check.png" title:title?title:NSLocalizedString(@"mcs_state_success", nil)];
    [toast dismissToast];
    return toast;
}

+ (MNToastView*)failToast:(NSString*)title
{
    MNToastView *toast = [[MNToastView alloc] initWithImage:@"cross.png" title:title?title:NSLocalizedString(@"mcs_fail", nil)];
    [toast dismissToast];
    return toast;
}

+ (MNToastView*)alertToast:(NSString*)title
{
    MNToastView *toast = [[MNToastView alloc] initWithImage:@"no.png" title:title];
    [toast dismissToast];
    return toast;
}

+ (MNToastView*)promptToast:(NSString*)title
{
    MNToastView *toast = [[MNToastView alloc] initWithImage:@"prompt.png" title:title];
    [toast dismissToast];
    return toast;
}

+ (MNToastView*)connectToast:(NSString *)title
{
    MNToastView *toast = [[MNToastView alloc] initWithImage:@"check.png" title:title?title:NSLocalizedString(@"mcs_state_success", nil)];
    return toast;
}

+ (MNToastView*)promptNoImageToast:(NSString*)title
{
    MNToastView *toast = [[MNToastView alloc] initWithImage:nil title:title];
    [toast dismissToast];
    return toast;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
