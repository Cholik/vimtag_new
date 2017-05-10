//
//  MNCalendarDynamicHeader.h
//  mipci
//
//  Created by mining on 15/11/2.
//  动感头文件，仅供框架内部使用。
//  Private header, don't use it.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "MNCalendar.h"
#import "MNCalendarCell.h"
#import "MNCalendarHeader.h"


@interface MNCalendar (Dynamic)

@property (readonly, nonatomic) MNCalendarHeader *header;
@property (readonly, nonatomic) UICollectionView *collectionView;
@property (readonly, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (readonly, nonatomic) NSArray *weekdays;
@property (readonly, nonatomic) CGFloat rowHeight;
@property (readonly, nonatomic) NSCalendar *calendar;
@property (readonly, nonatomic) BOOL ibEditing;
@property (readonly, nonatomic) BOOL floatingMode;
@property (readonly, nonatomic) NSArray *visibleStickyHeaders;

- (void)invalidateWeekdaySymbols;
- (void)invalidateAppearanceForCell:(MNCalendarCell *)cell;

@end

@interface MNCalendarAppearance (Dynamic)

@property (readonly, nonatomic) NSDictionary *backgroundColors;
@property (readonly, nonatomic) NSDictionary *titleColors;
@property (readonly, nonatomic) NSDictionary *subtitleColors;
@property (readonly, nonatomic) NSDictionary *borderColors;

- (void)adjustTitleIfNecessary;

@end



@interface MNCalendarHeader (Dynamic)

@property (readonly, nonatomic) UICollectionView *collectionView;
@property (readonly, nonatomic) NSDateFormatter *dateFormatter;

@end
