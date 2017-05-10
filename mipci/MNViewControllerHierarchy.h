//
//  ViewControllerHierarchy.h
//  mipci
//
//  Created by mining on 15/8/29.
//
//

#import <Foundation/Foundation.h>

@class UIViewController;
@class UINavigationController;

@protocol MNViewControllerHierarchy <NSObject>

@property (nonatomic, readonly) UIViewController *topmostViewController;
@property (nonatomic, readonly) UIViewController *topmostNonModalViewController;
@property (nonatomic, readonly) UINavigationController *topmostNavigationController;

@end
