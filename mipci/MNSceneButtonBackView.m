//
//  MNSceneButtonBackView.m
//  mipci
//
//  Created by mining on 16/6/22.
//
//

#import "MNSceneButtonBackView.h"

#define LINEWIDTH 2
@implementation MNSceneButtonBackView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    float x = self.bounds.size.width * 0.5;
    float y = self.bounds.size.width * 0.5;
    float radious = (self.bounds.size.width - 2 * LINEWIDTH) * 0.5;
    CGContextAddArc(context, x , y, radious, 0, M_PI_2, 0);
    CGContextSetLineWidth(context, LINEWIDTH);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextStrokePath(context);
}

-(void)startLoading
{
//     self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(loading) userInfo:nil repeats:YES];
    self.timer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(loading) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}

-(void)stopLoading
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)loading
{
    CGAffineTransform transform = CGAffineTransformRotate(self.transform, M_PI / 6.0);
    self.transform = transform;
}
@end
