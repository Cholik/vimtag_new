//
//  MNCalendar+IBExtension.h
//  mipci
//
//  Created by mining on 15/11/2.
//
//

#import "MNCalendar.h"
//#import "FSCalendarConstance.h"


@interface MNCalendar (IBExtension)

@property (assign, nonatomic)  BOOL     autoAdjustTitleSize;
@property (assign, nonatomic)  CGFloat  titleTextSize;
@property (assign, nonatomic)  CGFloat  subtitleTextSize;
@property (assign, nonatomic)  CGFloat  weekdayTextSize;
@property (assign, nonatomic)  CGFloat  headerTitleTextSize;

@property (strong, nonatomic)  UIColor  *eventColor;
@property (strong, nonatomic)  UIColor  *weekdayTextColor;

@property (strong, nonatomic)  UIColor  *headerTitleColor;
@property (strong, nonatomic)  NSString *headerDateFormat;
@property (assign, nonatomic)  CGFloat  headerMinimumDissolvedAlpha;

@property (strong, nonatomic)  UIColor  *titleDefaultColor;
@property (strong, nonatomic)  UIColor  *titleSelectionColor;
@property (strong, nonatomic)  UIColor  *titleTodayColor;
@property (strong, nonatomic)  UIColor  *titlePlaceholderColor;
@property (strong, nonatomic)  UIColor  *titleWeekendColor;

@property (strong, nonatomic)  UIColor  *subtitleDefaultColor;
@property (strong, nonatomic)  UIColor  *subtitleSelectionColor;
@property (strong, nonatomic)  UIColor  *subtitleTodayColor;
@property (strong, nonatomic)  UIColor  *subtitlePlaceholderColor;
@property (strong, nonatomic)  UIColor  *subtitleWeekendColor;

@property (strong, nonatomic)  UIColor  *selectionColor;
@property (strong, nonatomic)  UIColor  *todayColor;
@property (strong, nonatomic)  UIColor  *todaySelectionColor;

@property (strong, nonatomic)  UIColor *borderDefaultColor;
@property (strong, nonatomic)  UIColor *borderSelectionColor;

@property (assign, nonatomic)  MNCalendarCellShape cellShape;
@property (assign, nonatomic)  BOOL useVeryShortWeekdaySymbols;

// For IB Preview. Not actually affect.
@property (assign, nonatomic)  BOOL      fakeSubtitles;
@property (assign, nonatomic)  NSInteger fakedSelectedDay;

// Deprecated
@property (assign, nonatomic)  MNCalendarCellStyle cellStyle MNCalendarDeprecated("use \'cellShape\' instead");

@end
