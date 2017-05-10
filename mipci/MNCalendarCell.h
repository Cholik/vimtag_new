//
//  MNCalendarCell.h
//  mipci
//
//  Created by mining on 15/11/2.
//
//

#import <UIKit/UIKit.h>
#import "MNCalendar.h"

@interface MNCalendarCell : UICollectionViewCell

@property (weak, nonatomic) MNCalendar *calendar;
@property (weak, nonatomic) MNCalendarAppearance *appearance;

@property (weak, nonatomic) UILabel  *titleLabel;
@property (weak, nonatomic) UILabel  *subtitleLabel;
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UIView   *flagView;

@property (weak, nonatomic) CAShapeLayer *backgroundLayer;
@property (weak, nonatomic) CAShapeLayer *eventLayer;

@property (strong, nonatomic) NSDate   *date;
@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) UIImage  *image;

@property (assign, nonatomic) BOOL hasEvent;

@property (assign, nonatomic) BOOL dateIsPlaceholder;
@property (assign, nonatomic) BOOL dateIsSelected;
@property (assign, nonatomic) BOOL dateIsToday;

@property (readonly, nonatomic) BOOL weekend;

@property (strong, nonatomic) UIColor *preferedSelectionColor;
@property (strong, nonatomic) UIColor *preferedTitleDefaultColor;
@property (strong, nonatomic) UIColor *preferedTitleSelectionColor;
@property (strong, nonatomic) UIColor *preferedSubtitleDefaultColor;
@property (strong, nonatomic) UIColor *preferedSubtitleSelectionColor;
@property (strong, nonatomic) UIColor *preferedEventColor;
@property (strong, nonatomic) UIColor *preferedBorderDefaultColor;
@property (strong, nonatomic) UIColor *preferedBorderSelectionColor;
@property (assign, nonatomic) MNCalendarCellShape preferedCellShape;

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary;
- (void)performSelecting;

@end
