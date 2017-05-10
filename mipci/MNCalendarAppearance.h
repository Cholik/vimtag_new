//
//  MNCalendarAppearance.h
//  mipci
//
//  Created by mining on 15/11/2.
//
//

#define MNCalendarDeprecated(message) __attribute((deprecated(message)))

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MNCalendarCellShape) {
    MNCalendarCellShapeCircle    = 0,
    MNCalendarCellShapeRectangle = 1
};

@class MNCalendar;

@interface MNCalendarAppearance : NSObject

@property (weak  , nonatomic) MNCalendar *calendar;

@property (assign, nonatomic) CGFloat  titleTextSize;
@property (assign, nonatomic) CGFloat  subtitleTextSize;
@property (assign, nonatomic) CGFloat  weekdayTextSize;
@property (assign, nonatomic) CGFloat  headerTitleTextSize;

@property (strong, nonatomic) UIColor  *eventColor;
@property (strong, nonatomic) UIColor  *weekdayTextColor;

@property (strong, nonatomic) UIColor  *headerTitleColor;
@property (strong, nonatomic) NSString *headerDateFormat;
@property (assign, nonatomic) CGFloat  headerMinimumDissolvedAlpha;

@property (strong, nonatomic) UIColor  *titleDefaultColor;
@property (strong, nonatomic) UIColor  *titleSelectionColor;
@property (strong, nonatomic) UIColor  *titleTodayColor;
@property (strong, nonatomic) UIColor  *titlePlaceholderColor;
@property (strong, nonatomic) UIColor  *titleWeekendColor;

@property (strong, nonatomic) UIColor  *subtitleDefaultColor;
@property (strong, nonatomic) UIColor  *subtitleSelectionColor;
@property (strong, nonatomic) UIColor  *subtitleTodayColor;
@property (strong, nonatomic) UIColor  *subtitlePlaceholderColor;
@property (strong, nonatomic) UIColor  *subtitleWeekendColor;

@property (strong, nonatomic) UIColor  *selectionColor;
@property (strong, nonatomic) UIColor  *todayColor;
@property (strong, nonatomic) UIColor  *todaySelectionColor;

@property (strong, nonatomic) UIColor *borderDefaultColor;
@property (strong, nonatomic) UIColor *borderSelectionColor;

@property (assign, nonatomic) MNCalendarCellShape cellShape;
@property (assign, nonatomic) BOOL autoAdjustTitleSize;
@property (assign, nonatomic) BOOL useVeryShortWeekdaySymbols;

// For preview only
@property (assign, nonatomic) BOOL      fakeSubtitles;
@property (assign, nonatomic) NSInteger fakedSelectedDay;

- (void)invalidateAppearance;

@end


MNCalendarDeprecated("use \'MNCalendarCellShape\' instead")
typedef NS_OPTIONS(NSInteger, MNCalendarCellStyle) {
    MNCalendarCellStyleCircle      = 0,
    MNCalendarCellStyleRectangle   = 1
};

@interface MNCalendarAppearance (Deprecated)

@property (assign, nonatomic) MNCalendarCellStyle cellStyle MNCalendarDeprecated("use \'cellShape\' instead");

@end