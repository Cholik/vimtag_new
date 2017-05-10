//
//  MNCustomAlertView.h
//  mipci
//
//  Created by mining on 15/9/23.
//
//

#import <UIKit/UIKit.h>

@class MNCustomAlertView;
@protocol MNCustomAlertViewDelegate <NSObject>

- (void)customAlertView:(MNCustomAlertView *)customAlertView;

@end

@interface MNCustomAlertView : UIView

@property (weak, nonatomic) id<MNCustomAlertViewDelegate> delegate;

@property (nonatomic, copy)     NSString    *title;
@property (nonatomic, copy)     NSString    *details;
@property (nonatomic, assign)   BOOL        isSave;
@property (nonatomic, assign)   BOOL        isSaveNetwork;

@property (strong, nonatomic)   UIButton    *saveButton;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *circleViewBackground;

- (instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title Details:(NSString *)details isSave:(BOOL)isSave;
- (void)show;

@end
