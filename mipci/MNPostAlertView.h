//
//  MNPostAlertView.h
//  mipci
//
//  Created by mining on 16/1/25.
//
//

#import <UIKit/UIKit.h>
#import "mipc_agent.h"

@interface MNPostAlertView : UIView <UIWebViewDelegate>

@property (nonatomic, copy) UIView *contentView;
@property (nonatomic, readonly, getter = isVisible) BOOL visible;
@property (nonatomic, strong) UIColor *viewBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat cornerRadius NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; // default is 8.0
@property (nonatomic, assign) CGFloat shadowRadius NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; // default is 8.0

@property (nonatomic, assign) CGFloat containerWidth;
@property (nonatomic, assign) CGFloat containerHeight;
@property (nonatomic, assign) CGFloat vericalPadding;
@property (nonatomic, assign) CGFloat contentScrollViewMaxHeight;
@property (nonatomic, assign) CGFloat contentScrollViewMinHeight;
@property (nonatomic, assign) CGFloat bottomScrollViewHeight;
@property (nonatomic, assign) BOOL showBlurBackground;
// AlertView action
- (void)show;
- (void)dismiss;
// Operation
- (void)cleanAllPenddingAlert;

- (void)setup;
- (void)validateLayout;
- (void)invalidateLayout;
- (void)resetTransition;

- (instancetype)initWithFrame:(CGRect)frame post:(mcall_ret_post_get *)postGetCtx status:(BOOL)isLoginSuccess;

@end
