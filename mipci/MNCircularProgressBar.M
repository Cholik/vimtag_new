//
//  RMDownloadIndicator.m
//  BezierLoaders
//
//  Created by Mahesh on 1/30/14.
//  Copyright (c) 2014 Mahesh. All rights reserved.
//

#import "MNCircularProgressBar.h"
#import "MNPulsingHaloLayer.h"

@interface MNCircularProgressBar()

// this contains list of paths to be animated through
@property(nonatomic, strong)NSMutableArray *paths;

// the shaper layers used for display
@property(nonatomic, strong)CAShapeLayer *indicateShapeLayer;
@property(nonatomic, strong)CAShapeLayer *coverLayer;

// this is the layer used for animation
@property(nonatomic, strong)CAShapeLayer *animatingLayer;

// the type of indicator
@property(nonatomic, assign)RMIndicatorType type;



// the last updatedPath
@property(nonatomic, strong)UIBezierPath *lastUpdatedPath;
@property(nonatomic, assign)CGFloat lastSourceAngle;

// this the animation duration (default: 0.5)
@property(nonatomic, assign)CGFloat animationDuration;

@end

@implementation MNCircularProgressBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = kRMFilledIndicator;
        [self initAttributes];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame type:(RMIndicatorType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = type;
        [self initAttributes];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)initAttributes
{
    // first set the radius percent attribut
    self.radiusPercent = 0.5;
    _coverLayer = [CAShapeLayer layer];
    _animatingLayer = _coverLayer;
    
    // set the fill color
    _fillColor = [UIColor clearColor];
    _strokeColor = [UIColor whiteColor];
    //    _closedIndicatorBackgroundStrokeColor = [UIColor colorWithRed:99./255 green:204./255 blue:102./255 alpha:1.0];
    _closedIndicatorBackgroundStrokeColor = [UIColor clearColor];
    _coverWidth = 2.0;
    
    //[self addDisplayLabel];
    _animatingLayer.frame = self.bounds;
    [self.layer addSublayer:_animatingLayer];
    
    // path array
    _paths = [NSMutableArray array];
    
    // animation duration
    _animationDuration = 0.5;
    
    //add pulsinghalolayer
    self.halo = [MNPulsingHaloLayer layer];
    self.halo.position =  CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    ;
    [self.layer insertSublayer:self.halo below:self.layer];
    //
    self.halo.radius = 0;
    
    
}

- (void)loadIndicator
{
    // set the initial Path
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    UIBezierPath *initialPath = [UIBezierPath bezierPath]; //empty path
    
    [initialPath addArcWithCenter:center radius:(MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))) startAngle:degreeToRadian(-90) endAngle:degreeToRadian(-90) clockwise:YES]; //add the arc
    _animatingLayer.path = initialPath.CGPath;
    _animatingLayer.strokeColor = _strokeColor.CGColor;
    _animatingLayer.fillColor = _fillColor.CGColor;
    _animatingLayer.lineWidth = _coverWidth;
    self.lastSourceAngle = degreeToRadian(-90);
}

#pragma mark -
#pragma mark Helper Methods
- (NSArray *)keyframePathsWithDuration:(CGFloat) duration sourceStartAngle:(CGFloat)sourceStartAngle sourceEndAngle:(CGFloat)sourceEndAngle destinationStartAngle:(CGFloat)destinationStartAngle destinationEndAngle:(CGFloat)destinationEndAngle centerPoint:(CGPoint)centerPoint size:(CGSize)size sourceRadiusPercent:(CGFloat)sourceRadiusPercent destinationRadiusPercent:(CGFloat)destinationRadiusPercent type:(RMIndicatorType)type
{
    NSUInteger frameCount = ceil(duration * 60);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:frameCount + 1];
    for (int frame = 0; frame <= frameCount; frame++)
    {
        CGFloat startAngle = sourceStartAngle + (((destinationStartAngle - sourceStartAngle) * frame) / frameCount);
        CGFloat endAngle = sourceEndAngle + (((destinationEndAngle - sourceEndAngle) * frame) / frameCount);
        CGFloat radiusPercent = sourceRadiusPercent + (((destinationRadiusPercent - sourceRadiusPercent) * frame) / frameCount);
        CGFloat radius = (MIN(size.width, size.height) * radiusPercent) - self.coverWidth;
        
        [array addObject:(id)([self slicePathWithStartAngle:startAngle endAngle:endAngle centerPoint:centerPoint radius:radius type:type].CGPath)];
    }
    
    return [NSArray arrayWithArray:array];
}

- (UIBezierPath *)slicePathWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle centerPoint:(CGPoint)centerPoint radius:(CGFloat)radius type:(RMIndicatorType)type
{
    BOOL clockwise = startAngle < endAngle;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if(type == kRMClosedIndicator)
    {
        [path addArcWithCenter:centerPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
    }
    else
    {
        [path moveToPoint:centerPoint];
        [path addArcWithCenter:centerPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
        [path closePath];
    }
    return path;
}

- (void)drawRect:(CGRect)rect
{
    if(_type == kRMMixedIndictor)
    {
        CGFloat radius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2 - self.coverWidth;
        
        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        UIBezierPath *coverPath = [UIBezierPath bezierPath]; //empty path
        [coverPath setLineWidth:_coverWidth];
        [coverPath addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES]; //add the arc
        
        [_strokeColor set];
        [coverPath stroke];
    }
    else if (_type == kRMClosedIndicator)
    {
        CGFloat radius = (MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2) - self.coverWidth;
        
        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        UIBezierPath *coverPath = [UIBezierPath bezierPath]; //empty path
        [coverPath setLineWidth:_coverWidth];
        [coverPath addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES]; //add the arc
        [_closedIndicatorBackgroundStrokeColor set];
        [coverPath setLineWidth:self.coverWidth];
        [coverPath stroke];
    }
}

#pragma mark - update indicator
- (void)updateWithTotalBytes:(CGFloat)bytes downloadedBytes:(CGFloat)downloadedBytes
{
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _lastUpdatedPath = [UIBezierPath bezierPathWithCGPath:_animatingLayer.path];
    
    [_paths removeAllObjects];
    
    CGFloat destinationAngle = [self destinationAngleForRatio:(downloadedBytes/bytes)];
    [_paths addObjectsFromArray:[self keyframePathsWithDuration:self.animationDuration sourceStartAngle:degreeToRadian(-90) sourceEndAngle:self.lastSourceAngle destinationStartAngle:degreeToRadian(-90) destinationEndAngle:destinationAngle centerPoint:center size:CGSizeMake(self.bounds.size.width, self.bounds.size.width) sourceRadiusPercent:_radiusPercent destinationRadiusPercent:_radiusPercent type:_type]];
    
    _animatingLayer.path = (__bridge CGPathRef)((id)_paths[(_paths.count -1)]);
    self.lastSourceAngle = destinationAngle;
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    [pathAnimation setValues:_paths];
    [pathAnimation setDuration:self.animationDuration];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [pathAnimation setRemovedOnCompletion:YES];
    [_animatingLayer addAnimation:pathAnimation forKey:@"path"];
    
    //[self.displayLabel updateValue:downloadedBytes/bytes];
}

- (CGFloat)destinationAngleForRatio:(CGFloat)ratio
{
    return (degreeToRadian((360*ratio) - 90));
}

float degreeToRadian(float degree)
{
    return ((degree * M_PI)/180.0f);
}

#pragma mark -
#pragma mark Setter Methods
- (void)setFillColor:(UIColor *)fillColor
{
    if(_type == kRMClosedIndicator)
        _fillColor = [UIColor clearColor];
    else
        _fillColor = fillColor;
}

- (void)setRadiusPercent:(CGFloat)radiusPercent
{
    if(_type == kRMClosedIndicator)
    {
        _radiusPercent = 0.5;
        return;
    }
    
    if(radiusPercent > 0.5 || radiusPercent < 0)
        return;
    else
        _radiusPercent = radiusPercent;
    
}

- (void)setIndicatorAnimationDuration:(CGFloat)duration
{
    self.animationDuration = duration;
}

@end
