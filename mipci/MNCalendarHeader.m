//
//  MNCalendarHeader.m
//  mipci
//
//  Created by mining on 15/11/2.
//
//

#import "MNCalendarHeader.h"
#import "MNCalendar.h"
#import "UIView+MNExtension.h"
#import "NSDate+MNExtension.h"
#import "AppDelegate.h"

#define kBlue [UIColor colorWithRed:30/255.0 green:179/255.0 blue:198/255.0 alpha:1.0]
#define kRed           [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
#define kBlack           [UIColor colorWithRed:61/255.0 green:61/255.0 blue:61/255.0 alpha:1.0]
#define kEbit           [UIColor colorWithRed:252./255. green:120./255. blue:48./255. alpha:1.0]
#define kMIPC           [UIColor colorWithRed:41./255. green:136./255. blue:204./255. alpha:1.0]

@interface MNCalendarHeader ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (copy, nonatomic) NSDateFormatter            *dateFormatter;
@property (weak, nonatomic) UICollectionView           *collectionView;
@property (weak, nonatomic) UICollectionViewFlowLayout *collectionViewFlowLayout;

@property (assign, nonatomic) BOOL needsAdjustingMonthPosition;

@property (readonly, nonatomic) MNCalendar *calendar;
@property (weak  , nonatomic) AppDelegate                *app;

@end

@implementation MNCalendarHeader

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setCalendar:calendar];
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _scrollEnabled = YES;
    
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//水平滚动
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    collectionViewFlowLayout.sectionInset = UIEdgeInsetsZero;
    collectionViewFlowLayout.itemSize = CGSizeMake(1, 1);
    self.collectionViewFlowLayout = collectionViewFlowLayout;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewFlowLayout];
    collectionView.scrollEnabled = NO;
    collectionView.userInteractionEnabled = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.contentInset = UIEdgeInsetsZero;
    collectionView.scrollsToTop = NO;
    [self addSubview:collectionView];
    [collectionView registerClass:[MNCalendarHeaderCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView = collectionView;
    
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
    self.backgroundColor = styleColor;
}

- (void)certainOperation
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_collectionView) {
        _collectionView.frame = CGRectMake(0, self.fs_height*0.1, self.fs_width, self.fs_height*0.9);
        _collectionView.contentInset = UIEdgeInsetsZero;
        _collectionViewFlowLayout.itemSize = CGSizeMake(
                                                        _collectionView.fs_width*((_scrollDirection==UICollectionViewScrollDirectionHorizontal)?0.5:1),
                                                        _collectionView.fs_height
                                                        );
    }
    
    if (_needsAdjustingMonthPosition) {
        _needsAdjustingMonthPosition = NO;
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            _collectionView.contentOffset = CGPointMake((_scrollOffset+0.5)*_collectionViewFlowLayout.itemSize.width, 0);
        } else {
            _collectionView.contentOffset = CGPointMake(0, _scrollOffset * _collectionViewFlowLayout.itemSize.height);
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (self.calendar.scope) {
        case MNCalendarScopeMonth: {
            switch (_scrollDirection) {
                case UICollectionViewScrollDirectionVertical: {
                    NSInteger count = [self.calendar.maximumDate fs_monthsFrom:self.calendar.minimumDate.fs_firstDayOfMonth] + 1;
                    return count;
                }
                case UICollectionViewScrollDirectionHorizontal: {
                    // There is a need to default more than two, otherwise when the contentOffset is negative, the switch to other pages will automatically return to zero
                    // 2 more pages to prevent scrollView from auto bouncing while push/present to other UIViewController
                    NSInteger count = [self.calendar.maximumDate fs_monthsFrom:self.calendar.minimumDate.fs_firstDayOfMonth] + 1;
                    return count + 2;
                }
                default: {
                    break;
                }
            }
            break;
        }
        case MNCalendarScopeWeek: {
            NSInteger count = [self.calendar.maximumDate fs_weeksFrom:self.calendar.minimumDate.fs_firstDayOfWeek] + 1;
            return count + 2;
        }
        default: {
            break;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNCalendarHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.font = [UIFont systemFontOfSize:_appearance.headerTitleTextSize];
    cell.titleLabel.textColor = _appearance.headerTitleColor;
    _dateFormatter.dateFormat = _appearance.headerDateFormat;
    switch (self.calendar.scope) {
        case MNCalendarScopeMonth: {
            if (_scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                // Two more to the air
                if ((indexPath.item == 0 || indexPath.item == [collectionView numberOfItemsInSection:0] - 1)) {
                    cell.titleLabel.text = nil;
                } else {
                    NSDate *date = [self.calendar.minimumDate fs_dateByAddingMonths:indexPath.item - 1].fs_dateByIgnoringTimeComponents;
                    cell.titleLabel.text = [_dateFormatter stringFromDate:date];
                }
            } else {
                NSDate *date = [self.calendar.minimumDate fs_dateByAddingMonths:indexPath.item].fs_dateByIgnoringTimeComponents;
                cell.titleLabel.text = [_dateFormatter stringFromDate:date];
            }
            break;
        }
        case MNCalendarScopeWeek: {
            if ((indexPath.item == 0 || indexPath.item == [collectionView numberOfItemsInSection:0] - 1)) {
                cell.titleLabel.text = nil;
            } else {
                NSDate *date = [self.calendar.minimumDate.fs_firstDayOfWeek fs_dateByAddingWeeks:indexPath.item - 1].fs_dateByIgnoringTimeComponents;
                cell.titleLabel.text = [_dateFormatter stringFromDate:date];
            }
            break;
        }
        default: {
            break;
        }
    }
    [cell setNeedsLayout];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setNeedsLayout];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

#pragma mark - Properties

- (void)setScrollOffset:(CGFloat)scrollOffset
{
    if (_scrollOffset != scrollOffset) {
        _scrollOffset = scrollOffset;
    }
    _needsAdjustingMonthPosition = YES;
    [self setNeedsLayout];
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        _collectionViewFlowLayout.scrollDirection = scrollDirection;
        CGPoint newOffset = CGPointMake(
                                        scrollDirection == UICollectionViewScrollDirectionHorizontal ? (_scrollOffset-0.5)*_collectionViewFlowLayout.itemSize.width : 0,
                                        scrollDirection == UICollectionViewScrollDirectionVertical ? _scrollOffset * _collectionViewFlowLayout.itemSize.height : 0
                                        );
        _collectionView.contentOffset = newOffset;
        [_collectionView reloadData];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    if (_scrollEnabled != scrollEnabled) {
        _scrollEnabled = scrollEnabled;
        [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

#pragma mark - Public

- (void)reloadData
{
    [_collectionView reloadData];
}


#pragma mark - Private

- (MNCalendar *)calendar
{
    return (MNCalendar *)self.superview.superview;
}

@end


@implementation MNCalendarHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    _titleLabel.frame = bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = self.contentView.bounds;
    
    if (self.header.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat position = [self.contentView convertPoint:CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds)) toView:self.header].x;
        CGFloat center = CGRectGetMidX(self.header.bounds);
        if (self.header.scrollEnabled) {
            self.contentView.alpha = 1.0 - (1.0-self.header.appearance.headerMinimumDissolvedAlpha)*ABS(center-position)/self.fs_width;
        } else {
            self.contentView.alpha = (position > 0 && position < self.header.fs_width*0.75);
        }
    } else if (self.header.scrollDirection == UICollectionViewScrollDirectionVertical) {
        CGFloat position = [self.contentView convertPoint:CGPointMake(CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds)) toView:self.header].y;
        CGFloat center = CGRectGetMidY(self.header.bounds);
        self.contentView.alpha = 1.0 - (1.0-self.header.appearance.headerMinimumDissolvedAlpha)*ABS(center-position)/self.fs_height;
    }
    if (self.contentView.alpha < 0.5) {
        self.contentView.alpha = 0;
    }
}

- (MNCalendarHeader *)header
{
    UIView *superview = self.superview;
    while (superview && ![superview isKindOfClass:[MNCalendarHeader class]]) {
        superview = superview.superview;
    }
    return (MNCalendarHeader *)superview;
}

@end


