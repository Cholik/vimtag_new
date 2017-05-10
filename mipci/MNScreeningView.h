//
//  MNScreeningView.h
//  mipci
//
//  Created by mining on 15/9/24.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNScreeningInitStyle) {
    MNScreeningStyleAll,
    MNScreeningStyleFormat
};

typedef NS_ENUM(NSInteger, MNSelectStyle) {
    MNSelectStyleAll,
    MNSelectStyleEvent,
    MNSelectStyleSnapshot
};

@class MNScreeningView;
@protocol  MNScreeningViewDelegate<NSObject>

- (void)filteringResults:(NSInteger)selectResult;

@end

@interface MNScreeningView : UIView

@property (weak, nonatomic) id<MNScreeningViewDelegate> delegate;
@property (assign, nonatomic) MNScreeningInitStyle  screeningInitStyle;
@property (assign, nonatomic) MNSelectStyle         selectStyle;

@property (strong, nonatomic) UILabel               *categoryLabel;
@property (strong, nonatomic) UILabel               *timeLabel;
@property (strong, nonatomic) UILabel               *formatLabel;
@property (strong, nonatomic) UISegmentedControl    *categorySegment;
@property (strong, nonatomic) UISegmentedControl    *formatSegment;
@property (strong, nonatomic) UISegmentedControl    *timeSegment;
@property (strong, nonatomic) UIView                *lineView;

//show select result to history control
@property (assign, nonatomic) NSInteger              selectResult;

- (instancetype)initWithFrame:(CGRect)frame style:(MNScreeningInitStyle)style;

@end
