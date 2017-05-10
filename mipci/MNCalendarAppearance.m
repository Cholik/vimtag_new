//
//  MNCalendarAppearance.m
//  mipci
//
//  Created by mining on 15/11/2.
//
//

//
//  FSCalendarAppearance.m
//  Pods
//
//  Created by DingWenchao on 6/29/15.
//
//

#import "MNCalendarAppearance.h"
#import "MNCalendarDynamicHeader.h"
#import "UIView+MNExtension.h"
#import "AppDelegate.h"

#define kBlueText   [UIColor colorWithRed:30/255.0 green:179/255.0 blue:198/255.0 alpha:1.0]
#define kPink       [UIColor colorWithRed:255/255.0 green:100/255.0  blue:100/255.0     alpha:1.0]
#define kBlue       [UIColor colorWithRed:30/255.0 green:179/255.0 blue:198/255.0 alpha:1.0]
#define kRed        [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
#define kBlack      [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1.0]
#define kGray       [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0]
#define kEbit           [UIColor colorWithRed:252./255. green:120./255. blue:48./255. alpha:1.0]
#define kMIPC           [UIColor colorWithRed:41./255. green:136./255. blue:204./255. alpha:1.0]

@interface MNCalendarAppearance ()

@property (strong, nonatomic) NSMutableDictionary *backgroundColors;
@property (strong, nonatomic) NSMutableDictionary *titleColors;
@property (strong, nonatomic) NSMutableDictionary *subtitleColors;
@property (strong, nonatomic) NSMutableDictionary *borderColors;
@property (weak,   nonatomic) AppDelegate         *app;

- (void)adjustTitleIfNecessary;

@end

@implementation MNCalendarAppearance

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _autoAdjustTitleSize = YES;
        
        UIColor *styleColor;
        if (self.app.is_vimtag) {
            styleColor = kBlue;
        } else if (self.app.is_ebitcam) {
            styleColor = kEbit;
        } else if (self.app.is_mipc) {
            styleColor = kMIPC;
        } else {
            styleColor = kBlack;
        }
        
        _titleTextSize    = 13.5;
        _subtitleTextSize = 10;
        _weekdayTextSize  = 14;
        _headerTitleTextSize = 16;
        _headerTitleColor = [UIColor whiteColor];
        _headerDateFormat = @"MMMM yyyy";
        _headerMinimumDissolvedAlpha = 0.2;
        _weekdayTextColor = styleColor;
        
        _backgroundColors = [NSMutableDictionary dictionaryWithCapacity:4];
        _backgroundColors[@(MNCalendarCellStateNormal)]      = [UIColor clearColor];
        _backgroundColors[@(MNCalendarCellStateSelected)]    = kBlue;
        _backgroundColors[@(MNCalendarCellStateDisabled)]    = [UIColor clearColor];
        _backgroundColors[@(MNCalendarCellStatePlaceholder)] = [UIColor clearColor];
        _backgroundColors[@(MNCalendarCellStateToday)]       = kPink;
        
        _titleColors = [NSMutableDictionary dictionaryWithCapacity:4];
        _titleColors[@(MNCalendarCellStateNormal)]      = [UIColor darkTextColor];
        _titleColors[@(MNCalendarCellStateSelected)]    = [UIColor whiteColor];
        _titleColors[@(MNCalendarCellStateDisabled)]    = [UIColor grayColor];
        _titleColors[@(MNCalendarCellStatePlaceholder)] = kGray;
        _titleColors[@(MNCalendarCellStateToday)]       = [UIColor whiteColor];
        
        _subtitleColors = [NSMutableDictionary dictionaryWithCapacity:4];
        _subtitleColors[@(MNCalendarCellStateNormal)]      = [UIColor darkGrayColor];
        _subtitleColors[@(MNCalendarCellStateSelected)]    = [UIColor whiteColor];
        _subtitleColors[@(MNCalendarCellStateDisabled)]    = [UIColor lightGrayColor];
        _subtitleColors[@(MNCalendarCellStatePlaceholder)] = [UIColor lightGrayColor];
        _subtitleColors[@(MNCalendarCellStateToday)]       = [UIColor whiteColor];
        
        _borderColors[@(MNCalendarCellStateSelected)] = [UIColor clearColor];
        _borderColors[@(MNCalendarCellStateNormal)] = [UIColor clearColor];
        
        _cellShape = MNCalendarCellShapeCircle;
        _eventColor = [styleColor colorWithAlphaComponent:0.75];
        
        _borderColors = [NSMutableDictionary dictionaryWithCapacity:2];
        
    }
    return self;
}



- (void)setTitleDefaultColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(MNCalendarCellStateNormal)] = color;
    } else {
        [_titleColors removeObjectForKey:@(MNCalendarCellStateNormal)];
    }
    
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)titleDefaultColor
{
    return _titleColors[@(MNCalendarCellStateNormal)];
}

- (void)setTitleSelectionColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(MNCalendarCellStateSelected)] = color;
    } else {
        [_titleColors removeObjectForKey:@(MNCalendarCellStateSelected)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)titleSelectionColor
{
    return _titleColors[@(MNCalendarCellStateSelected)];
}

- (void)setTitleTodayColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(MNCalendarCellStateToday)] = color;
    } else {
        [_titleColors removeObjectForKey:@(MNCalendarCellStateToday)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)titleTodayColor
{
    return _titleColors[@(MNCalendarCellStateToday)];
}

- (void)setTitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(MNCalendarCellStatePlaceholder)] = color;
    } else {
        [_titleColors removeObjectForKey:@(MNCalendarCellStatePlaceholder)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)titlePlaceholderColor
{
    return _titleColors[@(MNCalendarCellStatePlaceholder)];
}

- (void)setTitleWeekendColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(MNCalendarCellStateWeekend)] = color;
    } else {
        [_titleColors removeObjectForKey:@(MNCalendarCellStateWeekend)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)titleWeekendColor
{
    return _titleColors[@(MNCalendarCellStateWeekend)];
}

- (void)setSubtitleDefaultColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(MNCalendarCellStateNormal)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(MNCalendarCellStateNormal)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

-(UIColor *)subtitleDefaultColor
{
    return _subtitleColors[@(MNCalendarCellStateNormal)];
}

- (void)setSubtitleSelectionColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(MNCalendarCellStateSelected)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(MNCalendarCellStateSelected)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)subtitleSelectionColor
{
    return _subtitleColors[@(MNCalendarCellStateSelected)];
}

- (void)setSubtitleTodayColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(MNCalendarCellStateToday)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(MNCalendarCellStateToday)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)subtitleTodayColor
{
    return _subtitleColors[@(MNCalendarCellStateToday)];
}

- (void)setSubtitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(MNCalendarCellStatePlaceholder)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(MNCalendarCellStatePlaceholder)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)subtitlePlaceholderColor
{
    return _subtitleColors[@(MNCalendarCellStatePlaceholder)];
}

- (void)setSubtitleWeekendColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(MNCalendarCellStateWeekend)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(MNCalendarCellStateWeekend)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)subtitleWeekendColor
{
    return _subtitleColors[@(MNCalendarCellStateWeekend)];
}

- (void)setSelectionColor:(UIColor *)color
{
    if (color) {
        _backgroundColors[@(MNCalendarCellStateSelected)] = color;
    } else {
        [_backgroundColors removeObjectForKey:@(MNCalendarCellStateSelected)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)selectionColor
{
    return _backgroundColors[@(MNCalendarCellStateSelected)];
}

- (void)setTodayColor:(UIColor *)todayColor
{
    if (todayColor) {
        _backgroundColors[@(MNCalendarCellStateToday)] = todayColor;
    } else {
        [_backgroundColors removeObjectForKey:@(MNCalendarCellStateToday)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)todayColor
{
    return _backgroundColors[@(MNCalendarCellStateToday)];
}

- (void)setTodaySelectionColor:(UIColor *)todaySelectionColor
{
    if (todaySelectionColor) {
        _backgroundColors[@(MNCalendarCellStateToday|MNCalendarCellStateSelected)] = todaySelectionColor;
    } else {
        [_backgroundColors removeObjectForKey:@(MNCalendarCellStateToday|MNCalendarCellStateSelected)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)todaySelectionColor
{
    return _backgroundColors[@(MNCalendarCellStateToday|MNCalendarCellStateSelected)];
}

- (void)setEventColor:(UIColor *)eventColor
{
    if (![_eventColor isEqual:eventColor]) {
        _eventColor = eventColor;
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setBorderDefaultColor:(UIColor *)color
{
    if (color) {
        _borderColors[@(MNCalendarCellStateNormal)] = color;
    } else {
        [_borderColors removeObjectForKey:@(MNCalendarCellStateNormal)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)borderDefaultColor
{
    return _borderColors[@(MNCalendarCellStateNormal)];
}

- (void)setBorderSelectionColor:(UIColor *)color
{
    if (color) {
        _borderColors[@(MNCalendarCellStateSelected)] = color;
    } else {
        [_borderColors removeObjectForKey:@(MNCalendarCellStateSelected)];
    }
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

- (UIColor *)borderSelectionColor
{
    return _borderColors[@(MNCalendarCellStateSelected)];
}

- (void)setTitleTextSize:(CGFloat)titleTextSize
{
    if (_titleTextSize != titleTextSize) {
        _titleTextSize = titleTextSize;
        if (_autoAdjustTitleSize) {
            return;
        }
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setSubtitleTextSize:(CGFloat)subtitleTextSize
{
    if (_subtitleTextSize != subtitleTextSize) {
        _subtitleTextSize = subtitleTextSize;
        if (_autoAdjustTitleSize) {
            return;
        }
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setCellShape:(MNCalendarCellShape)cellShape
{
    if (_cellShape != cellShape) {
        _cellShape = cellShape;
        [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}


- (void)setWeekdayTextSize:(CGFloat)weekdayTextSize
{
    if (_weekdayTextSize != weekdayTextSize) {
        _weekdayTextSize = weekdayTextSize;
        UIFont *font = [UIFont systemFontOfSize:weekdayTextSize];
        [_calendar.weekdays setValue:font forKey:@"font"];
    }
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
    if (![_weekdayTextColor isEqual:weekdayTextColor]) {
        _weekdayTextColor = weekdayTextColor;
        [_calendar.weekdays setValue:weekdayTextColor forKeyPath:@"textColor"];
    }
}

- (void)setHeaderTitleTextSize:(CGFloat)headerTitleTextSize
{
    if (_headerTitleTextSize != headerTitleTextSize) {
        _headerTitleTextSize = headerTitleTextSize;
        [_calendar.header.collectionView reloadData];
    }
}

- (void)setHeaderTitleColor:(UIColor *)color
{
    if (![_headerTitleColor isEqual:color]) {
        _headerTitleColor = color;
        [_calendar.header reloadData];
    }
}
- (void)setAutoAdjustTitleSize:(BOOL)autoAdjustTitleSize
{
    if (_autoAdjustTitleSize != autoAdjustTitleSize) {
        _autoAdjustTitleSize = autoAdjustTitleSize;
        [self adjustTitleIfNecessary];
    }
}

- (void)setUseVeryShortWeekdaySymbols:(BOOL)useVeryShortWeekdaySymbols
{
    if (_useVeryShortWeekdaySymbols != useVeryShortWeekdaySymbols) {
        _useVeryShortWeekdaySymbols = useVeryShortWeekdaySymbols;
        [self.calendar invalidateWeekdaySymbols];
    }
}

- (void)setHeaderMinimumDissolvedAlpha:(CGFloat)headerMinimumDissolvedAlpha
{
    if (_headerMinimumDissolvedAlpha != headerMinimumDissolvedAlpha) {
        _headerMinimumDissolvedAlpha = headerMinimumDissolvedAlpha;
        [_calendar.header.collectionView reloadData];
    }
}

- (void)setHeaderDateFormat:(NSString *)headerDateFormat
{
    if (![_headerDateFormat isEqual:headerDateFormat]) {
        _headerDateFormat = headerDateFormat;
        [_calendar.header reloadData];
    }
}

- (void)adjustTitleIfNecessary
{
    if (!self.calendar.floatingMode) {
        if (_autoAdjustTitleSize) {
            CGFloat factor       = (_calendar.scope==MNCalendarScopeMonth) ? 6 : 1.1;
            _titleTextSize       = _calendar.collectionView.fs_height/3/factor;
            _subtitleTextSize    = _calendar.collectionView.fs_height/4.5/factor;
            _headerTitleTextSize = _titleTextSize + 3;
            _weekdayTextSize     = _titleTextSize;
            
        }
    } else {
        _headerTitleTextSize = 20;
    }
    
    // reload appearance
    [_calendar.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.header.collectionView reloadData];
    [_calendar.weekdays setValue:[UIFont systemFontOfSize:_weekdayTextSize] forKeyPath:@"font"];
}

- (void)invalidateAppearance
{
    [_calendar.collectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_calendar invalidateAppearanceForCell:obj];
    }];
    [_calendar.header.collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    [_calendar.visibleStickyHeaders makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

@end


@implementation MNCalendarAppearance (Deprecated)

- (void)setCellStyle:(MNCalendarCellStyle)cellStyle
{
    self.cellShape = (MNCalendarCellShape)cellStyle;
}

- (MNCalendarCellStyle)cellStyle
{
    return (MNCalendarCellStyle)self.cellShape;
}

@end



