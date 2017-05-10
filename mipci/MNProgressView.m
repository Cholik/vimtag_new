//
//  WEProgressButton.m
//  mipci
//
//  Created by mining on 14-12-17.
//
//

#define CONTENT_INSET 2
#define LINE_WIDTH 4

#import "MNProgressView.h"

@interface MNProgressView()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *outShapeLayer;
@property (nonatomic, strong) CAShapeLayer *inShapeLayer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) float radius;
@property (nonatomic) UIImageView *statusImageView;

@end

@implementation MNProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        _titleLabel.text = @"0%";
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:_titleLabel];
        
        _statusImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_statusImageView setImage:[UIImage imageNamed:@"popview_success.png"]];
        [_statusImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_statusImageView setAlpha:0.0];
        [self addSubview:_statusImageView];
        
        self.backgroundColor = [UIColor clearColor];
        
        int height = CGRectGetHeight(self.bounds);
        int width = CGRectGetWidth(self.bounds);
        self.radius = width<height ? width/2 : height/2 - CONTENT_INSET - LINE_WIDTH;
        
        float outRadius = _radius + LINE_WIDTH / 2;
        _outShapeLayer = [CAShapeLayer layer];
        _outShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _outShapeLayer.strokeColor = [UIColor grayColor].CGColor;
        _outShapeLayer.path = [self arcBezierPath:outRadius].CGPath;
        [self.layer addSublayer:_outShapeLayer];
        
        float inRadius = _radius - LINE_WIDTH / 2;
        _inShapeLayer = [CAShapeLayer layer];
        _inShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _inShapeLayer.strokeColor = [UIColor grayColor].CGColor;
        _inShapeLayer.path = [self arcBezierPath:inRadius].CGPath;
        [self.layer addSublayer:_inShapeLayer];
    }
    
    return self;
}

-(UIBezierPath *)arcBezierPath:(float)radius
{
    CGPoint arcCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *arcBezierPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                 radius:radius
                                                             startAngle:-M_PI_2
                                                               endAngle:M_PI_2 * 3
                                                              clockwise:YES];
    
    return arcBezierPath;
}

-(CAShapeLayer *)shapeLayer
{
     @synchronized(self){
        if (nil == _shapeLayer) {
            _shapeLayer = [CAShapeLayer layer];
            _shapeLayer.fillColor = [UIColor clearColor].CGColor;
            _shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
            _shapeLayer.lineWidth = LINE_WIDTH;
            _shapeLayer.path = [self arcBezierPath:_radius].CGPath;
            [self.layer addSublayer:_shapeLayer];
        }
    };
    
    return _shapeLayer;
}

- (void)setProgressValue:(float)progressValue
{
    _progressValue = progressValue;
    [self updateProgress:progressValue];
    
    if (_progressValue >= 1.0) {
        [UIView animateWithDuration:1.0 animations:^{
            _titleLabel.alpha = 0.0;
//            [_shapeLayer removeFromSuperlayer];
//            [_outShapeLayer removeFromSuperlayer];
//            [_inShapeLayer removeFromSuperlayer];
             _statusImageView.alpha = 1.0;
        }];
    }
    
    if (_progressValue <= 0) {
        [UIView animateWithDuration:1.0 animations:^{
            _titleLabel.alpha = 1.0;
            //            [_shapeLayer removeFromSuperlayer];
            //            [_outShapeLayer removeFromSuperlayer];
            //            [_inShapeLayer removeFromSuperlayer];
            _statusImageView.alpha = 0.0;
        }];
    }
}

- (void)updateProgress:(float)value
{
    NSString *percent = [NSString stringWithFormat:@"%d%%", (int)(value * 100)];
    self.titleLabel.text = percent;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.shapeLayer.strokeEnd = value;
    [CATransaction commit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float outRadius = _radius + LINE_WIDTH / 2;
    UIBezierPath *outBezierPath = [self arcBezierPath:outRadius];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, outBezierPath.CGPath);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextStrokePath(context);
    
    float inRadius = _radius - LINE_WIDTH / 2;
    UIBezierPath *inBezierPath = [self arcBezierPath:inRadius];
    
    CGContextAddPath(context, inBezierPath.CGPath);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextStrokePath(context);
}
*/
@end
