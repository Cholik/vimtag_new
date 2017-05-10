//
//  MNPlayProgressView.m
//  mipci
//
//  Created by mining on 15/12/8.
//
//

#define UIColorFromRGB(rgbValue,alphaValue) [UIColor colorWithRed:((((rgbValue) & 0xFF0000) >> 16))/255.f \
green:((((rgbValue) & 0xFF00) >> 8))/255.f \
blue:(((rgbValue) & 0xFF))/255.f alpha:alphaValue]

#define THUMBCOLOR  [UIColor colorWithRed:30./255. green:179./255. blue:198./255. alpha:0.8]
#define EVENTCOLOR  [UIColor colorWithRed:255./255. green:80./255. blue:80./255. alpha:1.0]
#define SNAPCOLOR  [UIColor yellowColor]

#define TIMELINEVIEWHEIGHT      1.0
#define HANDLEVIEWLONGTH        36.0
#define PROGRESSBARSIZE         20.0

#define DEFAULTLINEWIDTH        0.5
#define DEFAULTLINEXIELS        0

#import "MNPlayProgressView.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "mipc_agent.h"

@interface MNPlayProgressView ()

@property (strong, nonatomic) UIView        *timeLineView;
@property (strong, nonatomic) UIView        *progressView;
@property (strong, nonatomic) CAShapeLayer  *timeLineLayer;

@end

@implementation MNPlayProgressView

#pragma mark - Init
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUI];
    }
    
    return self;
}

- (void)initUI
{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //Init Control
    _timeLineView = [[UIView alloc] initWithFrame:CGRectMake(DEFAULTLINEXIELS, 0, CGRectGetWidth(self.frame) - 2*DEFAULTLINEXIELS, TIMELINEVIEWHEIGHT)];
    _timeLineView.center = self.center;
    
    _progressView = [[UIView alloc] initWithFrame:CGRectMake(DEFAULTLINEWIDTH, 0, 0, TIMELINEVIEWHEIGHT)];

    _handleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DEFAULTLINEXIELS, 0, HANDLEVIEWLONGTH, HANDLEVIEWLONGTH)];
    _handleImageView.center = CGPointMake(DEFAULTLINEXIELS,CGRectGetHeight(self.frame)/2);
    [_handleImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    _handleImageView.contentMode =  UIViewContentModeCenter;
    _handleImageView.clipsToBounds  = YES;

    if (app.is_vimtag) {
        _timeLineView.backgroundColor = UIColorFromRGB(0x808080, 1.0); //Define default slider color
        _progressView.backgroundColor = UIColorFromRGB(0x00a6ba, 1.0);
        _handleImageView.image = [UIImage imageNamed:@"vt_progress_bar.png"];
        _handleImageView.highlightedImage = [UIImage imageNamed:@"vt_progress_bar_select.png"];
    } else if (app.is_ebitcam) {
        _timeLineView.backgroundColor = UIColorFromRGB(0xa1a6b3, 1.0); //Define default slider color
        _progressView.backgroundColor = UIColorFromRGB(0xff781f, 1.0);
        _handleImageView.image = [UIImage imageNamed:@"eb_progress_bar.png"];
        _handleImageView.highlightedImage = [UIImage imageNamed:@"eb_progress_bar_select.png"];
    } else if (app.is_mipc) {
        _timeLineView.backgroundColor = UIColorFromRGB(0xc2c5cc, 1.0); //Define default slider color
        _progressView.backgroundColor = UIColorFromRGB(0x2988cc, 1.0);
        _handleImageView.image = [UIImage imageNamed:@"mi_progress_bar.png"];
        _handleImageView.highlightedImage = [UIImage imageNamed:@"mi_progress_bar_select.png"];
    } else {
        _timeLineView.backgroundColor = UIColorFromRGB(0x808080, 1.0); //Define default slider color
        _progressView.backgroundColor = UIColorFromRGB(0xffffff, 1.0);
        _handleImageView.image = [UIImage imageNamed:@"vt_progress_bar.png"];
        _handleImageView.highlightedImage = [UIImage imageNamed:@"vt_progress_bar_select.png"];
    }
    
    [self addSubview:_timeLineView];
    [self addSubview:_progressView];
    [self addSubview:_handleImageView];
}

#pragma mark - Draw Event Line
- (void)setSegsArray:(NSMutableArray *)segsArray
{
    _segsArray = segsArray;
    
    //Init Param
    _minValue = 0;
    _value = 0;
    if (_segsArray.lastObject) {
        _maxValue = (float)((((seg_obj *)_segsArray.lastObject).end_time - ((seg_obj *)_segsArray.firstObject).start_time)/1000);
        _startTime = ((seg_obj *)_segsArray.firstObject).start_time;
        _endTime = ((seg_obj *)_segsArray.lastObject).end_time;
        [self setEventLine];
    }
}

- (void)setEventLine
{
    NSArray *subLayers = [NSArray arrayWithArray:_timeLineView.layer.sublayers];
    for (CALayer* layer in subLayers) {
        if ([layer isMemberOfClass:[CAShapeLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
    
    float length = CGRectGetWidth(_timeLineView.frame);
    for (seg_obj *seg in _flagArray)
    {
//        if (obj.flag) {
            float x = ((seg.start_time - _startTime)/1000)/(_maxValue ? _maxValue : 1)*length;
            float y = 0;
            float width = ((seg.end_time - seg.start_time)/1000)/(_maxValue ? _maxValue : 1)*length;
            float height = TIMELINEVIEWHEIGHT;
            
            CAShapeLayer *rectLayer = [CAShapeLayer layer];
            rectLayer.frame = CGRectMake( x, y, width, height);
            rectLayer.backgroundColor = EVENTCOLOR.CGColor;
            [_timeLineView.layer addSublayer:rectLayer];
//        }
    }
}

//#pragma mark - Layout View
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _timeLineView.frame = CGRectMake(DEFAULTLINEXIELS, (CGRectGetHeight(self.frame) - TIMELINEVIEWHEIGHT)/2, CGRectGetWidth(self.frame) - DEFAULTLINEXIELS*2, TIMELINEVIEWHEIGHT);
}

- (void)updateViewConstraint
{
    _timeLineView.frame = CGRectMake(DEFAULTLINEXIELS, (CGRectGetHeight(self.frame) - TIMELINEVIEWHEIGHT)/2, CGRectGetWidth(self.frame) - DEFAULTLINEXIELS*2, TIMELINEVIEWHEIGHT);
    CGFloat x = _value * (CGRectGetWidth(self.frame) - 2*DEFAULTLINEXIELS) / (_maxValue ? _maxValue : 1) + DEFAULTLINEXIELS;
    _handleImageView.center = CGPointMake(x,CGRectGetHeight(self.frame)/2);
    _progressView.frame = CGRectMake(DEFAULTLINEWIDTH, (CGRectGetHeight(self.frame) - TIMELINEVIEWHEIGHT)/2, _handleImageView.center.x, TIMELINEVIEWHEIGHT);
    if (_segsArray.lastObject)
    {
        [self setEventLine];
    }
}

#pragma mark - Touch Events

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"moving.........");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
//    [self.delegate sliderStatusChange];
    _isSlide = YES;
    _handleImageView.highlighted = YES;
    if (point.x >= DEFAULTLINEXIELS && point.x <= CGRectGetWidth(self.frame) - 2*DEFAULTLINEXIELS)
    {
        _handleImageView.center = CGPointMake(point.x,CGRectGetHeight(self.frame)/2);
        _progressView.frame = CGRectMake(DEFAULTLINEWIDTH, (CGRectGetHeight(self.frame) - TIMELINEVIEWHEIGHT)/2, point.x, TIMELINEVIEWHEIGHT);
        _value = point.x/CGRectGetWidth(self.frame)*_maxValue;
        if ([self.delegate respondsToSelector:@selector(sliderShowThumbnailValue:)]) {
            [self.delegate sliderShowThumbnailValue:_value];
        }
    }
    if ([self.delegate respondsToSelector:@selector(showThumbnailImageOrNot:)]) {
        [self.delegate showThumbnailImageOrNot:YES];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _isSlide = NO;
    _handleImageView.highlighted = NO;
    if (point.x >= DEFAULTLINEXIELS && point.x <= CGRectGetWidth(self.frame) - 2*DEFAULTLINEXIELS)
    {
        _value = point.x/CGRectGetWidth(self.frame)*_maxValue;
        //        NSLog(@"max:%lf",_maxValue);
        //        NSLog(@"value:%lf",_value);
        
        _handleImageView.center = CGPointMake(point.x,CGRectGetHeight(self.frame)/2);
        //        _progressView.frame = CGRectMake(DEFAULTLINEWIDTH, (CGRectGetHeight(self.frame) - TIMELINEVIEWHEIGHT)/2, _handleImageView.center.x, TIMELINEVIEWHEIGHT);
        [self.delegate sliderValueChange:_value];
    }
    if ([self.delegate respondsToSelector:@selector(showThumbnailImageOrNot:)]) {
        [self.delegate showThumbnailImageOrNot:YES];
    }
   
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _isSlide = NO;
    _handleImageView.highlighted = NO;
    if (point.x >= DEFAULTLINEXIELS && point.x <= CGRectGetWidth(self.frame) - 2*DEFAULTLINEXIELS)
    {
        _value = point.x/CGRectGetWidth(self.frame)*_maxValue;
//        NSLog(@"max:%lf",_maxValue);
//        NSLog(@"value:%lf",_value);
        
        _handleImageView.center = CGPointMake(point.x,CGRectGetHeight(self.frame)/2);
//        _progressView.frame = CGRectMake(DEFAULTLINEWIDTH, (CGRectGetHeight(self.frame) - TIMELINEVIEWHEIGHT)/2, _handleImageView.center.x, TIMELINEVIEWHEIGHT);
        [self.delegate sliderValueChange:_value];
    }
    if ([self.delegate respondsToSelector:@selector(showThumbnailImageOrNot:)]) {
        [self.delegate showThumbnailImageOrNot:YES];
    }
    
}

#pragma mark - Get Time Label
- (NSString *)getStringTime:(long long)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time / 1000];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [currentCalendar components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    NSInteger hour = [weekdayComponents hour];
    NSInteger min = [weekdayComponents minute];
    NSInteger sec = [weekdayComponents second];
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];
}

#pragma mark - Value Change
- (void)progressValueChange:(long long)value
{
    _value = value/1000;
    CGFloat x = _value * (CGRectGetWidth(self.frame) - 2*DEFAULTLINEXIELS) / (_maxValue ? _maxValue : 1) + DEFAULTLINEXIELS;
    _handleImageView.center = CGPointMake(x,CGRectGetHeight(self.frame)/2);
    _progressView.frame = CGRectMake(DEFAULTLINEWIDTH, (CGRectGetHeight(self.frame) - TIMELINEVIEWHEIGHT)/2, _handleImageView.center.x, TIMELINEVIEWHEIGHT);
    
//    if ([self.flagArray lastObject]) {
//        for (seg_obj *seg in _flagArray) {
//            
//        }
//    }
}

@end
