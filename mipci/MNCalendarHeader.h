//
//  MNCalendarHeader.h
//  mipci
//
//  Created by mining on 15/11/2.
//
//

#import <UIKit/UIKit.h>

@class MNCalendarHeader, MNCalendar, MNCalendarAppearance;

@interface MNCalendarHeader : UIView

@property (assign, nonatomic) CGFloat scrollOffset;
@property (assign, nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (weak, nonatomic) MNCalendarAppearance *appearance;
@property (assign, nonatomic) BOOL scrollEnabled;

- (void)reloadData;

@end

@interface MNCalendarHeaderCell : UICollectionViewCell

@property (weak, nonatomic) UILabel *titleLabel;
@property (readonly, nonatomic) MNCalendarHeader *header;

@end