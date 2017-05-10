//
//  MNControlBoardView.h
//  mipci
//
//  Created by weken on 15/4/13.
//
//

#import <UIKit/UIKit.h>
#import "UISlider+MNAddition.h"

@protocol MNControlBoardViewDelegate <NSObject>

- (void)didSelectedPresetPoint:(NSInteger)index;
- (void)didSelectedStyle:(NSInteger)index;

@end

@interface MNControlBoardView : UIView

@property (assign, nonatomic) float brightness;
@property (assign, nonatomic) float contrast;
@property (assign, nonatomic) float saturation;
@property (assign, nonatomic) float sharpness;
@property (assign, nonatomic) CGFloat allowPosition;
@property (strong, nonatomic) NSString *HDString;

@property (copy, nonatomic) void (^valueChanged)(id control, float[]);
@property (copy, nonatomic) void (^selectedStyle)(id sender);
@property (copy, nonatomic) void (^selectedPreset)(NSInteger index);
@property (copy, nonatomic) void (^setupPreset)(NSInteger index, BOOL enable);
@end
