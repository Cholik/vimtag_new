//
//  MNEbitInputView.h
//  mipci
//
//  Created by 谢跃聪 on 16/12/2.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNEbitInputViewStyle) {
    MNEbitInputViewNormal,
    MNEbitInputViewPassword,
    MNEbitInputViewCheck,
};


@interface MNEbitInputView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                        style:(MNEbitInputViewStyle)style
                    idleImage:(UIImage *)idleImage
                  activeImage:(UIImage *)activeImage
                  placeholder:(NSString *)placeholder;

@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) NSString *text;

@end
