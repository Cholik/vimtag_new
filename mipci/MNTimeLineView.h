//
//  MNTimeLineView.h
//  WETimeLineDemo
//
//  Created by weken on 15/4/4.
//  Copyright (c) 2015年 weken. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum MNTimeLineStyle
{
    MNTimeLineStyleTwentyFourHour,
    MNTimeLineStyleOneHour,
    MNTimeLineStyleFiveMinute
}MNTimeLineStyle;

@class MNTimeLineView;
@protocol MNTimeLineViewDelegate <NSObject>
- (void)timeLineView:(MNTimeLineView*)timeLineView didSelectTimeSliceAtIndex:(NSInteger)index;
- (void)timeLineView:(MNTimeLineView *)timeLineView didScrollToDate:(NSDate*)date;

@end

@interface MNTimeLineView : UIView<UIScrollViewDelegate>
@property (assign, nonatomic) MNTimeLineStyle timeLineStyle;
@property (strong, nonatomic) NSMutableArray *timeSliceArray;
@property (strong, nonatomic) NSMutableArray *dateSliceArray;
@property (assign, nonatomic) BOOL isDraggingTimeScrollView;
@property (assign, nonatomic) BOOL isDraggingDateScrollView;
@property (assign, nonatomic) id<MNTimeLineViewDelegate> delegate;


-(void)scrollToDate:(NSDate*)date;
-(void)scrollToIndex:(NSInteger)index;
@end
