//
//  MNInfoPromptView.h
//  mipci
//
//  Created by mining on 15/8/29.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MNInfoPromptViewStyle) {
    MNInfoPromptViewStyleError = 0,
    MNInfoPromptViewStyleInfo,
    MNInfoPromptViewStyleAutomation,
};

@interface MNInfoPromptView : UIView

@property (nonatomic) MNInfoPromptViewStyle style;
@property (nonatomic) NSString *text;

@property (nonatomic) UIFont *font UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *errorBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *infoBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *errorTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *infoTextColor UI_APPEARANCE_SELECTOR;

//- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;

+ (instancetype)showWithText:(NSString *)text
                       style:(MNInfoPromptViewStyle)style
                andHideAfter:(NSTimeInterval)timeout
                     isModal:(BOOL)is_modal;

//+ (instancetype)showAndHideWithText:(NSString *)text
//                              style:(MNInfoPromptViewStyle)style
//                              isModal:(BOOL)is_modal;
//
//+ (void)hideAll;

+ (instancetype)showAndHideWithText:(NSString *)text
                              style:(MNInfoPromptViewStyle)style
                            isModal:(BOOL)is_modal
                         navigation:(UINavigationController *)nav;

+ (void)hideAll:(UINavigationController *)nav;



@end
