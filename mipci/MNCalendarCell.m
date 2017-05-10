//
//  MNCalendarCell.m
//  mipci
//
//  Created by mining on 15/11/2.
//
//

#import "MNCalendarCell.h"
#import "MNCalendar.h"
#import "UIView+MNExtension.h"
#import "NSDate+MNExtension.h"
#import "MNCalendarDynamicHeader.h"

#define kBlue       [UIColor colorWithRed:30/255.0 green:179/255.0 blue:198/255.0 alpha:0.7]
#define kGreen      [UIColor colorWithRed:16/255.0 green:240/255.0 blue:120/255.0 alpha:1]

@interface MNCalendarCell ()
{
    CGFloat  kFSCalendarDefaultBounceAnimationDuration;
}

@property (readonly, nonatomic) UIColor *colorForBackgroundLayer;
@property (readonly, nonatomic) UIColor *colorForTitleLabel;
@property (readonly, nonatomic) UIColor *colorForSubtitleLabel;
@property (readonly, nonatomic) UIColor *colorForCellBorder;
@property (readonly, nonatomic) MNCalendarCellShape cellShape;

@end

@implementation MNCalendarCell

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        kFSCalendarDefaultBounceAnimationDuration = 0.15;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
        backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
        backgroundLayer.hidden = YES;
        [self.contentView.layer insertSublayer:backgroundLayer below:_titleLabel.layer];
        self.backgroundLayer = backgroundLayer;
        
        CAShapeLayer *eventLayer = [CAShapeLayer layer];
        eventLayer.backgroundColor = [UIColor clearColor].CGColor;
        eventLayer.fillColor = [UIColor cyanColor].CGColor;
        eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:eventLayer.bounds].CGPath;
        eventLayer.hidden = YES;
        [self.contentView.layer addSublayer:eventLayer];
        self.eventLayer = eventLayer;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeBottom|UIViewContentModeCenter;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        self.clipsToBounds = NO;
        self.contentView.clipsToBounds = NO;
        
        UIView *flagView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.center.x - 5 , self.contentView.center.y + 5, 10, 2)];
        flagView.backgroundColor = kGreen;
        self.flagView = flagView;
        [self.flagView setHidden:YES];
        [self.contentView addSubview:flagView];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    CGFloat titleHeight = self.bounds.size.height*5.0/6.0;
    CGFloat diameter = MIN(self.bounds.size.height*5.0/6.0,self.bounds.size.width);
    _backgroundLayer.frame = CGRectMake((self.bounds.size.width-diameter)/2,
                                        (titleHeight-diameter)/2,
                                        diameter,
                                        diameter);
    _backgroundLayer.borderWidth = 1.0;
    _backgroundLayer.borderColor = [UIColor clearColor].CGColor;
    
    CGFloat eventSize = _backgroundLayer.frame.size.height/6.0;
    _eventLayer.frame = CGRectMake((_backgroundLayer.frame.size.width-eventSize)/2+_backgroundLayer.frame.origin.x, CGRectGetMaxY(_backgroundLayer.frame)+eventSize*0.2, eventSize*0.8, eventSize*0.8);
    _eventLayer.path = [UIBezierPath bezierPathWithOvalInRect:_eventLayer.bounds].CGPath;
    _imageView.frame = self.contentView.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self configureCell];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [CATransaction setDisableActions:YES];
}

#pragma mark - Public

- (void)performSelecting
{
    _backgroundLayer.hidden = NO;
    _backgroundLayer.path = [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath;
    _backgroundLayer.fillColor = self.colorForBackgroundLayer.CGColor;
    
#define kAnimationDuration kFSCalendarDefaultBounceAnimationDuration
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    CABasicAnimation *zoomOut = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomOut.fromValue = @0.3;
    zoomOut.toValue = @1.2;
    zoomOut.duration = kAnimationDuration/4*3;
    CABasicAnimation *zoomIn = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomIn.fromValue = @1.2;
    zoomIn.toValue = @1.0;
    zoomIn.beginTime = kAnimationDuration/4*3;
    zoomIn.duration = kAnimationDuration/4;
    group.duration = kAnimationDuration;
    group.animations = @[zoomOut, zoomIn];
    [_backgroundLayer addAnimation:group forKey:@"bounce"];
    [self configureCell];
}

#pragma mark - Private

- (void)configureCell
{
    _titleLabel.font = [UIFont systemFontOfSize:_appearance.titleTextSize];
    _titleLabel.text = [NSString stringWithFormat:@"%@",@(_date.fs_day)];
    
#define m_calculateTitleHeight \
CGFloat titleHeight = [[[UIDevice currentDevice] systemVersion] floatValue] >=8.0 ?[_titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].height : [_titleLabel.text sizeWithFont:self.titleLabel.font].height;
#define m_adjustLabelFrame \
if (_subtitle) { \
_subtitleLabel.hidden = NO; \
_subtitleLabel.text = _subtitle; \
_subtitleLabel.font = [UIFont systemFontOfSize:_appearance.subtitleTextSize]; \
CGFloat subtitleHeight = [[[UIDevice currentDevice] systemVersion] floatValue] >=8.0 ?[_subtitleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.subtitleLabel.font}].height : [_subtitleLabel.text sizeWithFont:self.subtitleLabel.font].height;\
CGFloat height = titleHeight + subtitleHeight; \
_titleLabel.frame = CGRectMake(0, \
(self.contentView.fs_height*5.0/6.0-height)*0.5, \
self.fs_width, \
titleHeight); \
\
_subtitleLabel.frame = CGRectMake(0, \
_titleLabel.fs_bottom - (_titleLabel.fs_height-_titleLabel.font.pointSize),\
self.fs_width,\
subtitleHeight);\
_subtitleLabel.textColor = self.colorForSubtitleLabel; \
} else { \
_titleLabel.frame = CGRectMake(0, 0, self.fs_width, floor(self.contentView.fs_height*5.0/6.0)); \
_subtitleLabel.hidden = YES; \
}
    
    if (self.calendar.ibEditing) {
        m_calculateTitleHeight
        m_adjustLabelFrame
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            m_calculateTitleHeight
            dispatch_async(dispatch_get_main_queue(), ^{
                m_adjustLabelFrame
            });
        });
    }
    
    _titleLabel.textColor = self.colorForTitleLabel;
    
    UIColor *borderColor = self.colorForCellBorder;
    _backgroundLayer.hidden = !self.selected && !self.dateIsToday && !self.dateIsSelected && !borderColor;
    if (!_backgroundLayer.hidden) {
        _backgroundLayer.path = self.cellShape == MNCalendarCellShapeCircle ?
        [UIBezierPath bezierPathWithOvalInRect:_backgroundLayer.bounds].CGPath :
        [UIBezierPath bezierPathWithRect:_backgroundLayer.bounds].CGPath;
        _backgroundLayer.fillColor = self.colorForBackgroundLayer.CGColor;
        _backgroundLayer.strokeColor = self.colorForCellBorder.CGColor;
    }
    _imageView.image = _image;
    _imageView.hidden = !_image;
    
    _eventLayer.hidden = !_hasEvent;
    if (!_eventLayer.hidden) {
        _eventLayer.fillColor = self.preferedEventColor.CGColor ?: _appearance.eventColor.CGColor;
    }
    
    self.flagView.frame = CGRectMake(self.contentView.center.x - self.contentView.frame.size.width/10 , self.contentView.center.y + 6, self.contentView.frame.size.width/5, 2);
    //    NSLog(@"%f",self.contentView.frame.size.width);
    
}

- (BOOL)isWeekend
{
    return self.date.fs_weekday == 1 || self.date.fs_weekday == 7;
}

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary
{
    if (self.isSelected || self.dateIsSelected) {
        if (self.dateIsToday) {
            return dictionary[@(MNCalendarCellStateSelected|MNCalendarCellStateToday)] ?: dictionary[@(MNCalendarCellStateSelected)];
        }
        return dictionary[@(MNCalendarCellStateSelected)];
    }
    if (self.dateIsToday && [[dictionary allKeys] containsObject:@(MNCalendarCellStateToday)]) {
        return dictionary[@(MNCalendarCellStateToday)];
    }
    if (self.dateIsPlaceholder && [[dictionary allKeys] containsObject:@(MNCalendarCellStatePlaceholder)]) {
        return dictionary[@(MNCalendarCellStatePlaceholder)];
    }
    if (self.isWeekend && [[dictionary allKeys] containsObject:@(MNCalendarCellStateWeekend)]) {
        return dictionary[@(MNCalendarCellStateWeekend)];
    }
    return dictionary[@(MNCalendarCellStateNormal)];
}

#pragma mark - Properties

- (UIColor *)colorForBackgroundLayer
{
    if (self.dateIsSelected || self.isSelected) {
        return self.preferedSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
    }
    return [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
}

- (UIColor *)colorForTitleLabel
{
    if (self.dateIsSelected || self.isSelected) {
        return self.preferedTitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
    }
    return self.preferedTitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
}

- (UIColor *)colorForCellBorder
{
    if (self.dateIsSelected || self.isSelected) {
        return _preferedBorderSelectionColor ?: _appearance.borderSelectionColor;
    }
    return _preferedBorderDefaultColor ?: _appearance.borderDefaultColor;
}

- (MNCalendarCellShape)cellShape
{
    return _preferedCellShape ?: _appearance.cellShape;
}

@end




