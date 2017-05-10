//
//  CVKHierarchySearcher.h
//  mipci
//
//  Created by mining on 15/8/29.
//
//

#import "MNViewControllerHierarchy.h"

@interface MNHierarchySearcher : NSObject <MNViewControllerHierarchy>

@property (nonatomic, readonly) UIViewController *topmostViewController;
@property (nonatomic, readonly) UIViewController *topmostNonModalViewController;
@property (nonatomic, readonly) UINavigationController *topmostNavigationController;

@end
