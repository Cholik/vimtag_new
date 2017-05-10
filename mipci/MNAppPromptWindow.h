//
//  MNAppPromptWindow.h
//  mipci
//
//  Created by mining on 16/4/25.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNAppPromptStyle) {
    MNAppPromptStyleVideo,
};

@interface MNAppPromptWindow : UIWindow

- (instancetype)initWithFrame:(CGRect)frame style:(MNAppPromptStyle)style;

@end
