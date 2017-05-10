//
//  UIViewController+loading.m
//  mipci
//
//  Created by mining on 16/5/10.
//
//

#import "UIViewController+loading.h"

@implementation UIViewController (loading)
- (void)loading:(BOOL)visible
{
    UIView *loadingView = [self.view viewWithTag:1123002];
    if (loadingView==nil){
        loadingView = [self createLoadingView];
    }
    
    loadingView.frame = self.view.frame;
    self.view.userInteractionEnabled = !visible;
    
    if (visible)
    {
        loadingView.hidden = NO;
    }
    
    loadingView.alpha = visible ? 0 : 1;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         loadingView.alpha = visible ? 1 : 0;
                     }
                     completion: ^(BOOL  finished) {
                         if (!visible) {
                             loadingView.hidden = YES;
                         }
                     }];
}

- (UIView *)createLoadingView
{
    UIView *loadingView = [[UIView alloc] init];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
    loadingView.tag = 1123002;
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity startAnimating];
    [activity sizeToFit];
    activity.center = CGPointMake(loadingView.center.x, loadingView.frame.size.height/3);
    activity.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
    
    [loadingView addSubview:activity];
    [self.view addSubview:loadingView];
    [self.view bringSubviewToFront:loadingView];
    
    return loadingView;
}


@end
