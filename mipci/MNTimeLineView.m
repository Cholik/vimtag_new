//
//  MNTimeLineView.m
//  WETimeLineDemo
//
//  Created by weken on 15/4/4.
//  Copyright (c) 2015年 weken. All rights reserved.
//

#define DEFAULTTHEIGHT 40.0f
#define DEFAULTLINEWIDTH 1.0f
#define DEFAULTGAPLINEHEIGHT 5.0f
#define scorelength 5

#define TIMESCROLLVIEWTAG 1000
#define DATESCROLLVIEWTAG 1001

#import "MNTimeLineView.h"
#import "mipc_data_object.h"

@interface MNTimeLineView()
@property (strong, nonatomic) CAShapeLayer *timeLineLayer;
@property (strong, nonatomic) CAShapeLayer *dateLineLayer;

@property (strong, nonatomic) NSMutableArray *timeRectLayerArray;
@property (strong, nonatomic) NSMutableArray *dateRectLayerArray;
@property (strong, nonatomic) NSMutableArray *alarmRectLayerArray;

@property (strong, nonatomic) UIScrollView *timeScrollView;
@property (strong, nonatomic) UIScrollView *dateScrollView;
@property (strong, nonatomic) UIImageView *cursorImageView;
@property (strong, nonatomic) UILabel *timeLabel;

@property (assign, nonatomic) int timeInterval;
@property (assign, nonatomic) int dateInterval;
@property (assign, nonatomic) int segmentNumber;
@property (assign, nonatomic) float timeGap;
@property (assign, nonatomic) float dateGap;
@property (assign, nonatomic) float screenWidth;

@property (strong, nonatomic) NSArray *dates;
@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSCalendar *currentCalendar;
@end

@implementation MNTimeLineView


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initParameter];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initParameter];
    }
    
    return self;
}

#pragma mark - Init
- (void)initParameter
{
    //default value
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)/2 - 120/2, 5, 120, 10)];
    _timeLabel.font = [UIFont systemFontOfSize:10];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_timeLabel];
    
    self.backgroundColor = [UIColor clearColor];
//    self.backgroundColor = [UIColor colorWithRed:40.0/255 green:39.0/255 blue:34.0/255 alpha:0.5];
    _timeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 15, CGRectGetWidth(self.bounds), DEFAULTTHEIGHT)];
    _timeScrollView.delegate = self;
    _timeScrollView.showsHorizontalScrollIndicator = NO;
    _timeScrollView.showsVerticalScrollIndicator = NO;
    _timeScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _timeScrollView.tag = TIMESCROLLVIEWTAG;
    _timeScrollView.backgroundColor = [UIColor colorWithRed:40.0/255 green:39.0/255 blue:34.0/255 alpha:0.5];
    [self addSubview:_timeScrollView];
    
    _timeLineLayer = [[CAShapeLayer alloc] init];
    _timeLineLayer.lineWidth = DEFAULTLINEWIDTH;
    _timeLineLayer.strokeColor = [UIColor grayColor].CGColor;
    _timeLineLayer.lineJoin = kCALineJoinRound;
    _timeLineLayer.lineCap = kCALineCapSquare;
    [_timeScrollView.layer addSublayer:_timeLineLayer];
    
    _dateScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds)/2 + 10, CGRectGetWidth(self.bounds), DEFAULTTHEIGHT)];
    _dateScrollView.delegate = self;
    _dateScrollView.showsHorizontalScrollIndicator = NO;
    _dateScrollView.showsVerticalScrollIndicator = NO;
    _dateScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _dateScrollView.tag = DATESCROLLVIEWTAG;
    _dateScrollView.backgroundColor = [UIColor colorWithRed:40.0/255 green:39.0/255 blue:34.0/255 alpha:0.5];
    [self addSubview:_dateScrollView];
    
    _dateLineLayer = [[CAShapeLayer alloc] init];
    _dateLineLayer.lineWidth = DEFAULTLINEWIDTH;
    _dateLineLayer.strokeColor = [UIColor grayColor].CGColor;
    _dateLineLayer.lineJoin = kCALineJoinRound;
    _dateLineLayer.lineCap = kCALineCapSquare;
    [_dateScrollView.layer addSublayer:_dateLineLayer];
    
    [self drawLayerForYear];
    
    _cursorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)/2 - 15, 15, 30, 75)];
    [_cursorImageView setImage:[UIImage imageNamed:@"center_cursor.png"]];
    [self addSubview:_cursorImageView];
}

-(NSCalendar *)currentCalendar
{
    if (nil == _currentCalendar) {
        _currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    return _currentCalendar;
}

- (void)updateConstraint
{
    CGRect bound = self.bounds;
    CGRect timeFrame = _timeLabel.frame;
    CGRect cursorFrame = _cursorImageView.frame;
    _timeLabel.frame = CGRectMake(CGRectGetWidth(bound)/2 - CGRectGetWidth(timeFrame)/2, timeFrame.origin.y, timeFrame.size.width, timeFrame.size.height);
    _cursorImageView.frame = CGRectMake(bound.size.width/2 - cursorFrame.size.width/2, cursorFrame.origin.y, cursorFrame.size.width, cursorFrame.size.height);
}

-(NSArray *)dates
{
    if (nil == _dates) {
        NSDate *today = [NSDate date];
        
        NSDate *fromDate;
        NSTimeInterval length;
        [self.currentCalendar rangeOfUnit:NSCalendarUnitYear startDate:&fromDate interval:&length forDate:today];
        NSDate *endDate = [fromDate dateByAddingTimeInterval:length-1];
        
        NSMutableArray *dates = [[NSMutableArray alloc] init];
        NSDateComponents *dayComponents = [[NSDateComponents alloc] init];
        
//        NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:0.0];
        NSInteger dayCount = 0;
        while(YES){
            [dayComponents setDay:dayCount++];
            NSDate *date = [self.currentCalendar dateByAddingComponents:dayComponents toDate:fromDate options:0];
            NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
            NSDate *localeDate = [date dateByAddingTimeInterval:[timeZone secondsFromGMTForDate:date]];
            [dates addObject:localeDate];
            if([date compare:endDate] == NSOrderedDescending) break;
        }

        _dates = dates;
    }
    
    return _dates;
}

-(float)screenWidth
{
    if (0 == _screenWidth) {
        _screenWidth = CGRectGetWidth(self.bounds);
    }
    
    return _screenWidth;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateConstraint];
}

-(NSMutableArray *)timeRectLayerArray
{
    @synchronized(self){
        if (nil == _timeRectLayerArray) {
            _timeRectLayerArray = [NSMutableArray array];
        }
        
        return _timeRectLayerArray;
    }
}

-(NSMutableArray *)dateRectLayerArray
{
    @synchronized(self)
    {
        if (nil == _dateRectLayerArray) {
            _dateRectLayerArray = [NSMutableArray array];
        }
        
        return  _dateRectLayerArray;
    }
}

-(NSMutableArray *)alarmRectLayerArray
{
    @synchronized(self)
    {
        if (nil == _alarmRectLayerArray) {
            _alarmRectLayerArray = [NSMutableArray array];
        }
        
        return _alarmRectLayerArray;
    }
}

-(void)setTimeSliceArray:(NSMutableArray *)timeSliceArray
{
    _timeSliceArray = timeSliceArray;
    
    for (CAShapeLayer *layer in self.timeRectLayerArray) {
        [layer removeFromSuperlayer];
    }
    
    for (CAShapeLayer *layer in self.alarmRectLayerArray) {
        [layer removeFromSuperlayer];
    }
    
    [self.timeRectLayerArray removeAllObjects];
    [self.alarmRectLayerArray removeAllObjects];
    
    for (seg_obj *seg in _timeSliceArray)
    {
        NSDate *sDate = [NSDate dateWithTimeIntervalSince1970:seg.start_time / 1000];
        NSDate *eDate = [NSDate dateWithTimeIntervalSince1970:seg.end_time / 1000];
        
        long stime = [self transformDate:sDate];
        long etime = [self transformDate:eDate];
        
        float x = stime * 1.0 /_timeInterval * _timeGap;
        float width = (etime-stime) * 1.0/_timeInterval * _timeGap;
        float y = 15;
//        float y = DEFAULTTHEIGHT / 2;
        float height =DEFAULTTHEIGHT/2 - 15;
        
        if (seg.flag) {
            CAShapeLayer *rectLayer = [CAShapeLayer layer];
            rectLayer.frame = CGRectMake(x, y - 10, width, height + 10);
            rectLayer.backgroundColor = [UIColor orangeColor].CGColor;
            [_timeScrollView.layer addSublayer:rectLayer];
            
            [self.alarmRectLayerArray addObject:rectLayer];
        }
        
        CAShapeLayer *rectLayer = [CAShapeLayer layer];
        rectLayer.frame = CGRectMake(x, y, width, height);
        rectLayer.backgroundColor =  [UIColor colorWithRed:125.0/255 green:207.0/255 blue:66.0/255 alpha:1].CGColor;
        [_timeScrollView.layer addSublayer:rectLayer];
        
        [self.timeRectLayerArray addObject:rectLayer];
    }
}

-(void)setDateSliceArray:(NSMutableArray *)dateSliceArray
{
    _dateSliceArray = dateSliceArray;
    
    for (CAShapeLayer *layer in self.dateRectLayerArray) {
        [layer removeFromSuperlayer];
    }
    
    [self.dateRectLayerArray removeAllObjects];
    
    NSDate *sdate = [self.dates firstObject];
    NSInteger slength = [sdate timeIntervalSince1970];
    
    for (date_info_obj *date_info in _dateSliceArray)
    {
        NSInteger elength = date_info.date - slength;
        float x = elength * 1.0 /_dateInterval * _dateGap;
        
        CAShapeLayer *rectLayer = [CAShapeLayer layer];
        rectLayer.frame = CGRectMake(x, DEFAULTTHEIGHT / 2 - 10, _dateGap / 24, 5);
        rectLayer.backgroundColor = [UIColor colorWithRed:125.0/255 green:207.0/255 blue:66.0/255 alpha:1].CGColor;
        [_dateScrollView.layer addSublayer:rectLayer];
        
        [self.dateRectLayerArray addObject:rectLayer];
    }
}

-(void)setTimeLineStyle:(MNTimeLineStyle)timeLineStyle
{
    _timeLineStyle = timeLineStyle;
    
    switch (_timeLineStyle)
    {
        case MNTimeLineStyleTwentyFourHour:
        {
            [self drawLayerForTwentyFourHourDuration];
            break;
        }
        case MNTimeLineStyleOneHour:
        {
            [self drawLayerForOneHourDuration];
            break;
        }
        case MNTimeLineStyleFiveMinute:
        {
            [self drawLayerForFiveMinuteDuration];
            break;
        }
        default:
            break;
    }
    
    [self setTimeSliceArray:_timeSliceArray];
}

#pragma mark - draw layer
-(void)drawLayerForTwentyFourHourDuration
{
    _timeInterval = 1800;//s
    _segmentNumber = 24 * 60 * 60 / _timeInterval;
    
    _timeScrollView.contentSize = CGSizeMake(/*CGRectGetWidth(self.bounds) + */CGRectGetWidth(self.bounds), CGRectGetHeight(_timeScrollView.bounds));
    _timeGap = (_timeScrollView.contentSize.width /*- CGRectGetWidth(self.bounds)*/)/ _segmentNumber;
    int longGap = 2;
    
    //remove textlayer
    [self removeAllTextlayers];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, DEFAULTTHEIGHT / 2)];
    [bezierPath addLineToPoint:CGPointMake(_timeScrollView.contentSize.width, DEFAULTTHEIGHT / 2)];
    
    for (int i =0 ; i <= _segmentNumber; i++)
    {
        CGPoint point = CGPointMake(/*CGRectGetWidth(self.bounds)/2 +*/ i * _timeGap, DEFAULTTHEIGHT / 2);
        if (0 == i % longGap)
        {
            [bezierPath moveToPoint:point];
            [bezierPath addLineToPoint: CGPointMake(point.x, point.y + DEFAULTGAPLINEHEIGHT + 5)];
            
            //add text
            if (0 == i % (longGap * 4)) {
                CGRect rect = (CGRect){{point.x - 5, point.y + DEFAULTGAPLINEHEIGHT + 5}, {10, 10}};
                NSString *timeString = [NSString stringWithFormat:@"%d", i%48/2];
                
                CATextLayer *textLayer = [self createTimeTextLayer:rect withText:timeString];
                [_timeScrollView.layer addSublayer:textLayer];
            }
            
        }
        else
        {
            [bezierPath moveToPoint:point];
            [bezierPath addLineToPoint:CGPointMake(point.x, point.y + DEFAULTGAPLINEHEIGHT)];
        }
        
    }
    
    _timeLineLayer.path = bezierPath.CGPath;
    [_timeLineLayer setNeedsDisplay];
}

-(void)drawLayerForOneHourDuration
{
    _timeInterval = 60;//s
    _segmentNumber = 24 * 60 * 60 / _timeInterval;

    _timeScrollView.contentSize = CGSizeMake(24 * CGRectGetWidth(_timeScrollView.bounds) + CGRectGetWidth(self.bounds), CGRectGetHeight(_timeScrollView.bounds));
    _timeGap = _timeScrollView.contentSize.width / _segmentNumber;
    int longGap = 5;
    
    //remove textlayer
    [self removeAllTextlayers];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, DEFAULTTHEIGHT / 2)];
    [bezierPath addLineToPoint:CGPointMake(_timeScrollView.contentSize.width, DEFAULTTHEIGHT / 2)];
    
    for (int i =0 ; i <= _segmentNumber; i++)
    {
        CGPoint point = CGPointMake(/*CGRectGetWidth(self.bounds)/2 + */i * _timeGap, DEFAULTTHEIGHT / 2);
        
        if (0 == i % longGap)
        {
            [bezierPath moveToPoint:point];
            [bezierPath addLineToPoint:CGPointMake(point.x, point.y + DEFAULTGAPLINEHEIGHT + 5)];
            
            //add text
            if (0 == i % (longGap * 3)) {
                CGRect rect = (CGRect){{point.x - 15, point.y + DEFAULTGAPLINEHEIGHT + 5}, {30, 10}};
                NSString *timeString = [NSString stringWithFormat:@"%.2d:%.2d", i*_timeInterval/60/60, i*_timeInterval/60%60];
                
                CATextLayer *textLayer = [self createTimeTextLayer:rect withText:timeString];
                [_timeScrollView.layer addSublayer:textLayer];
            }
            
        }
        else
        {
            [bezierPath moveToPoint:point];
            [bezierPath addLineToPoint:CGPointMake(point.x, point.y + DEFAULTGAPLINEHEIGHT)];
        }
        
    }
    
    _timeLineLayer.path = bezierPath.CGPath;
    [_timeLineLayer setNeedsDisplay];
    
}

- (void)drawLayerForFiveMinuteDuration
{
    _timeInterval = 5;//s
    _segmentNumber = 24 * 60 * 60 / _timeInterval;

    _timeScrollView.contentSize = CGSizeMake(24 * 12 * CGRectGetWidth(self.bounds) /*+ CGRectGetWidth(self.bounds)*/, CGRectGetHeight(_timeScrollView.bounds));
    _timeGap = _timeScrollView.contentSize.width / _segmentNumber;

    int longGap = 12;
    
    //remove textlayer
    [self removeAllTextlayers];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, DEFAULTTHEIGHT / 2)];
    [bezierPath addLineToPoint:CGPointMake(_timeScrollView.contentSize.width, DEFAULTTHEIGHT / 2)];
    
    for (int i =0 ; i < _segmentNumber; i++)
    {
        CGPoint point = CGPointMake(/*CGRectGetWidth(self.bounds)/2 +*/ i * _timeGap, DEFAULTTHEIGHT / 2);

        if (0 == i % longGap)
        {
            [bezierPath moveToPoint:point];
            [bezierPath addLineToPoint:CGPointMake(point.x, point.y + DEFAULTGAPLINEHEIGHT + 5)];
            
            CGRect rect = (CGRect){{point.x - 15, point.y + DEFAULTGAPLINEHEIGHT + 5}, {30, 10}};
            NSString *timeString = [NSString stringWithFormat:@"%.2d:%.2d", (i*_timeInterval)/60/60, (i*_timeInterval)/60%60];
             CATextLayer *textLayer = [self createTimeTextLayer:rect withText:timeString];
            [_timeScrollView.layer addSublayer:textLayer];
        }
        else
        {
            [bezierPath moveToPoint:point];
            [bezierPath addLineToPoint: CGPointMake(point.x, point.y + DEFAULTGAPLINEHEIGHT)];
        }
        
    }
    
    _timeLineLayer.path = bezierPath.CGPath;
    [_timeLineLayer setNeedsDisplay];
}

- (void)drawLayerForYear
{
    _dateInterval = 24 * 60 * 60; //s
    int segmentNumber = 365;
    
    _dateScrollView.contentSize = CGSizeMake(365 / 7 * CGRectGetWidth(_dateScrollView.bounds), CGRectGetHeight(_dateScrollView.bounds));
    _dateGap = _dateScrollView.contentSize.width / segmentNumber;
    
    NSArray *subLayers = [NSArray arrayWithArray:_dateScrollView.layer.sublayers];
    for (CALayer* layer in subLayers) {
        if ([layer isMemberOfClass:[CATextLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, DEFAULTTHEIGHT / 2 - 10)];
    [bezierPath addLineToPoint:CGPointMake(_dateScrollView.contentSize.width, DEFAULTTHEIGHT / 2 - 10)];
    
    for (int i = 0; i < segmentNumber; i++)
    {
        CGPoint point = CGPointMake(i * _dateGap, DEFAULTTHEIGHT / 2 - 10);
        
        [bezierPath moveToPoint:point];
        [bezierPath addLineToPoint:CGPointMake(point.x, point.y + DEFAULTGAPLINEHEIGHT)];
        
        NSDate *date = self.dates[i];
        NSDateComponents *dateCompoments = [self.currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:date];
        
        NSInteger weekNumber = [dateCompoments weekday];
        NSInteger day=[dateCompoments day];
        NSInteger month=[dateCompoments month];
        
        NSString *dayFormattedString = [NSString stringWithFormat:@"%ld", (long)day];
        NSString *monthFormattedString = [NSString stringWithFormat:@"%ld", (long)month];

  
        NSString *weekFormattedDay;
        switch (weekNumber) {
            case 1:
                weekFormattedDay=@"Sun";
                break;
            case 2:
                weekFormattedDay=@"Mon";
                break;
            case 3:
                weekFormattedDay=@"Tue";
                break;
            case 4:
                weekFormattedDay=@"Wed";
                break;
            case 5:
                weekFormattedDay=@"Thu";
                break;
            case 6:
                weekFormattedDay=@"Fri";
                break;
            case 7:
                weekFormattedDay=@"Sat";
                break;
                
            default:
                break;
        }
        
        CATextLayer *dayTextLayer = [self createTimeTextLayer:CGRectMake(point.x - 15, point.y + DEFAULTGAPLINEHEIGHT, 30, 10) withText:dayFormattedString];
        CATextLayer *dayInWeekLayer = [self createTimeTextLayer:CGRectMake(point.x - 15, point.y + DEFAULTGAPLINEHEIGHT + 10, 30, 10) withText:weekFormattedDay];
        
        if (i%7 == 0) {
            CATextLayer *monthTextLayer = [self createTimeTextLayer:CGRectMake(point.x - 15, point.y - 10, 30, 10) withText:monthFormattedString];
            [_dateScrollView.layer addSublayer:monthTextLayer];
        }
        
        [_dateScrollView.layer addSublayer:dayTextLayer];
        [_dateScrollView.layer addSublayer:dayInWeekLayer];
        
    }
    
    _dateLineLayer.path = bezierPath.CGPath;
    [_dateLineLayer setNeedsDisplay];
}

//- (void)drawLayerForYearBeginDistance:(float)beginDistance endDistance:(float)endDistance
//{
//    int timeInterval = 24; //h
//    int segmentNumber = 365;
//    
//    _dateScrollView.contentSize = CGSizeMake(365 / 7 * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) / 2);
//    float width = CGRectGetWidth(self.bounds);
//    float gap = width / 7;
//    
//    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
//    [bezierPath moveToPoint:CGPointMake(0, DEFAULTTHEIGHT / 2)];
//    [bezierPath addLineToPoint:CGPointMake(_dateScrollView.contentSize.width, DEFAULTTHEIGHT / 2)];
//    
//    for (int i = beginDistance/gap ; i < endDistance/gap; i++)
//    {
//        CGPoint point = CGPointMake(i * gap, DEFAULTTHEIGHT / 2);
//        
//        [bezierPath moveToPoint:point];
//        [bezierPath addLineToPoint:CGPointMake(point.x, point.y + DEFAULTGAPLINEHEIGHT + 5)];
//        
//        //date
//        NSDate *date = self.dates[i];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        
//        [dateFormatter setDateFormat:@"dd"];
//        NSString *dayFormattedString = [dateFormatter stringFromDate:date];
//        
//        [dateFormatter setDateFormat:@"EEE"];
//        NSString *dayInWeekFormattedString = [dateFormatter stringFromDate:date];
//        
//        [dateFormatter setDateFormat:@"MMM"];
//        NSString *monthFormattedString = [[dateFormatter stringFromDate:date] uppercaseString];
//        
//        CATextLayer *dayTextLayer = [self createTimeTextLayer:CGRectMake(point.x - 15, point.y + DEFAULTGAPLINEHEIGHT + 5, 30, 10) withText:dayFormattedString];
//        CATextLayer *dayInWeekLayer = [self createTimeTextLayer:CGRectMake(point.x - 15, point.y + DEFAULTGAPLINEHEIGHT + 15, 30, 10) withText:dayInWeekFormattedString];
//        
//        if (i%7 == 0) {
//            CATextLayer *monthTextLayer = [self createTimeTextLayer:CGRectMake(point.x - 15, point.y - 15, 30, 10) withText:monthFormattedString];
//            [_dateScrollView.layer addSublayer:monthTextLayer];
//        }
//        
//        [_dateScrollView.layer addSublayer:dayTextLayer];
//        [_dateScrollView.layer addSublayer:dayInWeekLayer];
//
//    }
//    
//    _dateLineLayer.path = bezierPath.CGPath;
//    [_dateLineLayer setNeedsDisplay];
//}

//- (void)drawTimeSliceLayer
//{
//    for (CAShapeLayer *layer in self.timeRectLayerArray) {
//        [layer removeFromSuperlayer];
//    }
//    
//    [self.timeRectLayerArray removeAllObjects];
//    
//    
//    for (seg_obj *seg in _timeSliceArray)
//    {
//        NSDate *sDate = [NSDate dateWithTimeIntervalSince1970:seg.start_time / 1000];
//        NSDate *eDate = [NSDate dateWithTimeIntervalSince1970:seg.end_time / 1000];
//        
//        long stime = [self transformDate:sDate];
//        long etime = [self transformDate:eDate];
//        
//        float x = stime * 1.0 /_timeInterval * _timeGap;
//        float width = (etime-stime) * 1.0/_timeInterval * _timeGap;
//        float y = seg.flag ? 5 :10;
//        float height = seg.flag ? DEFAULTTHEIGHT/2 - 5 : DEFAULTTHEIGHT/2 - 10;
//        
//        CAShapeLayer *rectLayer = [CAShapeLayer layer];
//        rectLayer.frame = CGRectMake(x, y, width, height);
//        rectLayer.backgroundColor = seg.flag ?[UIColor orangeColor].CGColor : [UIColor colorWithRed:50.0/255 green:176.0/255 blue:173.0/255 alpha:1].CGColor;
//        [_timeScrollView.layer addSublayer:rectLayer];
//        
//        [self.timeRectLayerArray addObject:rectLayer];
//    }
//}

//- (void)drawDateSliceLayer
//{
//    for (CAShapeLayer *layer in self.dateRectLayerArray) {
//        [layer removeFromSuperlayer];
//    }
//    
//    [self.dateRectLayerArray removeAllObjects];
//    
//    NSDate *sdate = [self.dates firstObject];
//    NSInteger slength = [sdate timeIntervalSince1970];
//    
//    for (date_info_obj *date_info in _dateSliceArray)
//    {
//        NSInteger elength = date_info.date - slength;
//        float x = elength * 1.0 /_dateInterval * _dateGap;
//        
//        CAShapeLayer *rectLayer = [CAShapeLayer layer];
//        rectLayer.frame = CGRectMake(x, DEFAULTTHEIGHT / 2 - 10, _dateGap / 24, 5);
//        rectLayer.backgroundColor = [UIColor colorWithRed:50.0/255 green:176.0/255 blue:173.0/255 alpha:1].CGColor;
//        [_dateScrollView.layer addSublayer:rectLayer];
//        
//        [self.dateRectLayerArray addObject:rectLayer];
//    }
//}

- (CATextLayer*)createTimeTextLayer:(CGRect)rect withText:(NSString*)text
{
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = rect;
    //set text attributes
    textLayer.foregroundColor = [UIColor grayColor].CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.wrapped = YES;
    //choose a font
    UIFont *font = [UIFont systemFontOfSize:8];
    //set layer font
//    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
//    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
//    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
//    CGFontRelease(fontRef);
    //set layer text
    textLayer.string = text;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    return textLayer;
}

- (void)removeAllTextlayers
{
    NSArray *subLayers = [NSArray arrayWithArray:_timeScrollView.layer.sublayers];
    for (CALayer* layer in subLayers) {
        if ([layer isMemberOfClass:[CATextLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
}

#pragma mark - Utils
- (long)transformDate:(NSDate*)date
{
    NSDateComponents *weekdayComponents = [self.currentCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    NSInteger hour = [weekdayComponents hour];
    NSInteger min = [weekdayComponents minute];
    NSInteger sec = [weekdayComponents second];
    
    return hour*60*60 + min*60 + sec;
}

-(void)scrollToDate:(NSDate*)date
{
    NSDate *fromDate;
    NSTimeInterval length;
    [self.currentCalendar rangeOfUnit:NSCalendarUnitYear startDate:&fromDate interval:&length forDate:date];
    NSTimeInterval duration = [date timeIntervalSinceDate:fromDate];
    
    //scroll
    float x = duration / _dateInterval * _dateGap - CGRectGetWidth(self.bounds) / 2;
    [_dateScrollView setContentOffset:CGPointMake(x, 0) animated:NO];
    [self checkScrollDate];
}

-(void)scrollToIndex:(NSInteger)index
{
    seg_obj *seg = [self.timeSliceArray objectAtIndex:index];
    
    NSDate *sDate = [NSDate dateWithTimeIntervalSince1970:seg.start_time / 1000];
    long stime = [self transformDate:sDate];
    float x = stime * 1.0 /_timeInterval * _timeGap - self.bounds.size.width / 2;
    
    [_timeScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

- (void)cleanTimeSlice
{
    [self.timeSliceArray removeAllObjects];
    for (CAShapeLayer *layer in self.timeRectLayerArray) {
        [layer removeFromSuperlayer];
    }
    [self.timeRectLayerArray removeAllObjects];
}

- (void)updateTime
{
    float length = _timeScrollView.contentOffset.x + self.bounds.size.width/2;
    int seconds = ceilf(length / _timeGap) * _timeInterval;
    
    NSString *time = [NSString stringWithFormat:@"%02d:%02d:%02d", seconds/60/60, (seconds%(60*60))/60, seconds%60];
    NSDateComponents *components = [self.currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:_currentDate];
    
    long day=[components day];
    long year=[components year];
    long month=[components month];
    
    NSString *date = [NSString stringWithFormat:@"%ld-%02ld-%02ld", year, month, day];
    _timeLabel.text = [NSString stringWithFormat:@"%@ %@", date, time];
}

#pragma mark - Data check
- (void)checkScrollTime
{
    float length = _timeScrollView.contentOffset.x + self.bounds.size.width/2;
    
    for (CAShapeLayer* rectLayer in self.timeRectLayerArray) {
        if (length - 5 <= rectLayer.frame.origin.x && rectLayer.frame.origin.x <= length + 5) {
            NSInteger index = [self.timeRectLayerArray indexOfObject:rectLayer];
            if (self.delegate && [self.delegate respondsToSelector:@selector(timeLineView:didSelectTimeSliceAtIndex:)]) {
                [self.delegate timeLineView:self didSelectTimeSliceAtIndex:index];
            }
            break;
        }
    }
}

- (void)checkScrollDate
{
    float length = _dateScrollView.contentOffset.x + self.bounds.size.width/2;
    float scale = (length - floor(length / _dateGap) * _dateGap)/_dateGap;
    float x = (_timeScrollView.contentSize.width - _timeScrollView.bounds.size.width) * scale;
    
    int index = floor(length / _dateGap);
    
    NSDate *selectedDate = self.dates[index];
    if (selectedDate != _currentDate)
    {
        _currentDate = selectedDate;
        [self cleanTimeSlice];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(timeLineView:didScrollToDate:)]) {
            [self.delegate timeLineView:self didScrollToDate:_currentDate];
        }
    }
    
    //linkage
    [_timeScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
    
}
#pragma mark - UIScrollView delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView.tag == TIMESCROLLVIEWTAG) {
        [self updateTime];
        if (!scrollView.dragging
            && !scrollView.tracking
            && !scrollView.decelerating)
        {
            _isDraggingTimeScrollView = YES;
        }
    }
//    NSLog(@"---------------------------->%f", scrollView.contentOffset.x);
//    if (scrollView.tag == TIMESCROLLVIEWTAG) {
//        float scale = _timeScrollView.contentOffset.x / _timeScrollView.contentSize.width;
//        float x = floor(_dateScrollView.contentOffset.x / _dateGap) * _dateGap + _dateGap * scale;
//        
//        [_dateScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
//    }
//    float width = self.screenWidth;
//    float beginDistance = scrollView.contentOffset.x - 2 * width;
//    float endDistance = scrollView.contentOffset.x + 3 * width;
//
//    [self drawLayerForYearBeginDistance:beginDistance endDistance:endDistance];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == TIMESCROLLVIEWTAG) {
        [self checkScrollTime];
//        float scale = _timeScrollView.contentOffset.x / _timeScrollView.contentSize.width;
//        float length = _dateScrollView.contentOffset.x;
//        float x = floor(length / _dateGap) * _dateGap + _dateGap * scale;
//        
//        [_dateScrollView setContentOffset:CGPointMake(x, 0) animated:NO];
    }
    else if (scrollView.tag == DATESCROLLVIEWTAG)
    {
        [self checkScrollDate];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        if (scrollView.tag == TIMESCROLLVIEWTAG) {
            [self checkScrollTime];
//            float scale = _timeScrollView.contentOffset.x / _timeScrollView.contentSize.width;
//            float length = _dateScrollView.contentOffset.x;
//            float x = floor(length / _dateGap) * _dateGap + _dateGap * scale;
//            
//            [_dateScrollView setContentOffset:CGPointMake(x, 0) animated:NO];
        }
        else if(scrollView.tag == DATESCROLLVIEWTAG)
        {
            [self checkScrollDate];
        }
    }
}

//-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    if (scrollView.tag == TIMESCROLLVIEWTAG) {
//        [self checkScrollTime];
//    }
//    else if(scrollView.tag == DATESCROLLVIEWTAG)
//    {
//        [self checkScrollDate];
//    }
//}


@end
