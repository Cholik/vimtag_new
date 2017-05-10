//
//  MNCalendar.h
//  mipci
//
//  Created by mining on 15/11/2.
//
//

#import <UIKit/UIKit.h>
#import "MNCalendarAppearance.h"

@class MNCalendar;

MNCalendarDeprecated("use \'MNCalendarScrollDirection\' instead")
typedef NS_ENUM(NSInteger, MNCalendarFlow) {
    MNCalendarFlowVertical,
    MNCalendarFlowHorizontal
};

typedef NS_ENUM(NSInteger, MNCalendarScope) {
    MNCalendarScopeMonth,
    MNCalendarScopeWeek
};

typedef NS_ENUM(NSInteger, MNCalendarScrollDirection) {
    MNCalendarScrollDirectionVertical,
    MNCalendarScrollDirectionHorizontal
};

typedef NS_ENUM(NSInteger, MNCalendarCellState) {
    MNCalendarCellStateNormal      = 0,
    MNCalendarCellStateSelected    = 1,
    MNCalendarCellStatePlaceholder = 1 << 1,
    MNCalendarCellStateDisabled    = 1 << 2,
    MNCalendarCellStateToday       = 1 << 3,
    MNCalendarCellStateWeekend     = 1 << 4
};

@protocol MNCalendarDelegate <NSObject>

@required
- (void)calendarSelectedDate:(NSDate *)date;
- (void)hiddenCalendar;

@optional
- (BOOL)calendar:(MNCalendar *)calendar shouldSelectDate:(NSDate *)date;
- (void)calendar:(MNCalendar *)calendar didSelectDate:(NSDate *)date;
- (BOOL)calendar:(MNCalendar *)calendar shouldDeselectDate:(NSDate *)date;
- (void)calendar:(MNCalendar *)calendar didDeselectDate:(NSDate *)date;
- (void)calendarCurrentPageDidChange:(MNCalendar *)calendar;
- (void)calendarCurrentScopeWillChange:(MNCalendar *)calendar animated:(BOOL)animated;

- (void)calendarCurrentMonthDidChange:(MNCalendar *)calendar MNCalendarDeprecated("use \'calendarCurrentPageDidChange\' instead");

@end

@protocol MNCalendarDataSource <NSObject>

@optional
- (NSString *)calendar:(MNCalendar *)calendar subtitleForDate:(NSDate *)date;
- (UIImage *)calendar:(MNCalendar *)calendar imageForDate:(NSDate *)date;
- (BOOL)calendar:(MNCalendar *)calendar hasEventForDate:(NSDate *)date;
- (NSDate *)minimumDateForCalendar:(MNCalendar *)calendar;
- (NSDate *)maximumDateForCalendar:(MNCalendar *)calendar;

@end

@protocol MNCalendarDelegateAppearance <NSObject>

@optional
- (UIColor *)calendar:(MNCalendar *)calendar appearance:(MNCalendarAppearance *)appearance selectionColorForDate:(NSDate *)date;
- (UIColor *)calendar:(MNCalendar *)calendar appearance:(MNCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date;
- (UIColor *)calendar:(MNCalendar *)calendar appearance:(MNCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date;
- (UIColor *)calendar:(MNCalendar *)calendar appearance:(MNCalendarAppearance *)appearance subtitleDefaultColorForDate:(NSDate *)date;
- (UIColor *)calendar:(MNCalendar *)calendar appearance:(MNCalendarAppearance *)appearance subtitleSelectionColorForDate:(NSDate *)date;
- (UIColor *)calendar:(MNCalendar *)calendar appearance:(MNCalendarAppearance *)appearance eventColorForDate:(NSDate *)date;
- (UIColor *)calendar:(MNCalendar *)calendar appearance:(MNCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date;
- (UIColor *)calendar:(MNCalendar *)calendar appearance:(MNCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date;
- (MNCalendarCellShape)calendar:(MNCalendar *)calendar appearance:(MNCalendarAppearance *)appearance cellShapeForDate:(NSDate *)date;

- (MNCalendarCellStyle)calendar:(MNCalendar *)calendar appearance:(MNCalendarAppearance *)appearance cellStyleForDate:(NSDate *)date MNCalendarDeprecated("use \'calendar:appearance:cellShapeForDate:\' instead");

@end


@interface MNCalendar : UIView

@property (weak, nonatomic) IBOutlet id<MNCalendarDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<MNCalendarDataSource> dataSource;

@property (strong, nonatomic) NSDate *today;
@property (strong, nonatomic) NSDate *currentPage;
@property (strong, nonatomic) NSLocale *locale;

@property (assign, nonatomic) MNCalendarScrollDirection scrollDirection;
@property (assign, nonatomic) MNCalendarScope scope;
@property (assign, nonatomic) NSUInteger firstWeekday;
@property (assign, nonatomic) CGFloat headerHeight;
@property (assign, nonatomic) BOOL allowsSelection;
@property (assign, nonatomic) BOOL allowsMultipleSelection;
@property (assign, nonatomic) BOOL pagingEnabled;
@property (assign, nonatomic) BOOL scrollEnabled;

@property (readonly, nonatomic) MNCalendarAppearance *appearance;
@property (readonly, nonatomic) NSDate *minimumDate;
@property (readonly, nonatomic) NSDate *maximumDate;

@property (readonly, nonatomic) NSDate *selectedDate;
@property (readonly, nonatomic) NSArray *selectedDates;
@property (copy, nonatomic) NSMutableArray *allDatesArray;

- (void)reloadData;
- (CGSize)sizeThatFits:(CGSize)size;

- (void)setScope:(MNCalendarScope)scope animated:(BOOL)animated;

- (void)selectDate:(NSDate *)date;
- (void)selectDate:(NSDate *)date scrollToDate:(BOOL)scrollToDate;
- (void)deselectDate:(NSDate *)date;

- (void)setCurrentPage:(NSDate *)currentPage animated:(BOOL)animated;

- (BOOL)isDateInRange:(NSDate *)date;   //Judge date in calendar

@end


@interface MNCalendar (Deprecated)

@property (strong, nonatomic) NSDate *currentMonth MNCalendarDeprecated("use \'currentPage\' instead");
@property (assign, nonatomic) MNCalendarFlow flow MNCalendarDeprecated("use \'scrollDirection\' instead");

- (void)setSelectedDate:(NSDate *)selectedDate MNCalendarDeprecated("use \'selectDate:\' instead");
- (void)setSelectedDate:(NSDate *)selectedDate animate:(BOOL)animate MNCalendarDeprecated("use \'selectDate:scrollToDate:\' instead");

@end

@interface calendar_info_obj : NSObject

@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) long   flag;

@end
