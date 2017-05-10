//
//  MNVideoPlayFailPromptView.h
//  mipci
//
//  Created by 谢跃聪 on 17/1/7.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNVideoPlayFailPromptStyle) {
    MNVideoPlayFailPromptOffline,
    MNVideoPlayFailPromptError
};

@protocol MNVideoPlayFailPromptViewDelegate <NSObject>

- (void)videoReplay;

@end



@interface MNVideoPlayFailPromptView : UIView

@property (weak, nonatomic) id<MNVideoPlayFailPromptViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame Style:(MNVideoPlayFailPromptStyle)style;
- (void)refreshPromptTextWithStyle:(MNVideoPlayFailPromptStyle)style;

@end
