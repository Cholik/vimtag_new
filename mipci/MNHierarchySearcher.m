//
//  CVKHierarchySearcher.m
//  mipci
//
//  Created by mining on 15/8/29.
//
//

#import <UIKit/UIKit.h>

#import "MNHierarchySearcher.h"
#import "MNDeviceListViewController.h"
#import "MNDeviceListSetViewController.h"
//#import "MNDeviceListPageViewController.h"

@implementation MNHierarchySearcher

- (UIViewController *)topmostViewController
{
    return [self topmostViewControllerFrom:[[self baseWindow] rootViewController]
                              includeModal:YES];
}

- (UIViewController *)topmostNonModalViewController
{
    return [self topmostViewControllerFrom:[[self baseWindow] rootViewController]
                              includeModal:NO];
}

- (UINavigationController *)topmostNavigationController
{
    return [self topmostNavigationControllerFrom:[self topmostViewController]];
}

- (UINavigationController *)topmostNavigationControllerFrom:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UINavigationController class]])
        return (UINavigationController *)vc;
    if ([vc navigationController])
        return [vc navigationController];
    //Mine Add:modify rootVC is tabbar's question
    if ([vc isKindOfClass:[UITabBarController class]])
    {
        for (UINavigationController *navigationController in vc.childViewControllers)
        {
            for (UIViewController *viewController in navigationController.viewControllers) {
//                if ([viewController isMemberOfClass:[MNDeviceListPageViewController class]]) {
//                    return navigationController;
//                }
                if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                    return navigationController;
                }
//                if ([viewController isKindOfClass:[MNDeviceListViewController class]]) {
//                    return navigationController;
//                }
            }
        }
    }
    
    if (vc.presentingViewController)
        return [self topmostNavigationControllerFrom:vc.presentingViewController];
    else
        return nil;
}

- (UIViewController *)topmostViewControllerFrom:(UIViewController *)viewController
                                   includeModal:(BOOL)includeModal
{
    if (includeModal && viewController.presentedViewController)
        return [self topmostViewControllerFrom:viewController.presentedViewController
                                  includeModal:includeModal];
    
    if ([viewController respondsToSelector:@selector(topViewController)])
        return [self topmostViewControllerFrom:[(id)viewController topViewController]
                                  includeModal:includeModal];
    
    return viewController;
}

- (UIWindow *)baseWindow
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (!window)
        window = [[UIApplication sharedApplication] keyWindow];
    
    NSAssert(window != nil, @"No window to calculate hierarchy from");
    return window;
}
@end
