//
//  WECameraOverlayView.m
//  QR code
//
//  Created by mining on 14-7-9.
//  Copyright (c) 2014年 斌. All rights reserved.
//

#import "MNCameraOverlayView.h"

@interface MNCameraOverlayView()
@property (weak, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int moveStep;
@property (strong, nonatomic) UIImageView *scanLineView;

@end

@implementation MNCameraOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.moveStep = 0;
//        self.backgroundColor = [UIColor grayColor];
        self.alpha = 0.5;
        self.scanMaskSize = CGSizeMake(200, 160);
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60 target:self selector:@selector(animateScanLine) userInfo:nil repeats:YES];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.moveStep = 0;
        //        self.backgroundColor = [UIColor grayColor];
        self.alpha = 0.5;
        self.scanMaskSize = CGSizeMake(200, 160);
    }
    
    return self;
}

-(void)startAnimate
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30 target:self selector:@selector(animateScanLine) userInfo:nil repeats:YES];
}

-(void)stopAnimate
{
    [self.timer invalidate];
}

- (void)animateScanLine
{
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    //Conversion coordinate system and drawing
//    CGContextSaveGState(context);
//    
//    //Translation coordinate axis
//    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
//    
//    //Flip Y axis
//    CGContextScaleCTM(context, 1.0, -1.0);
    
    //Draw rectangular background
    CGContextAddRect(context, rect);
    UIColor *customColor = [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:0.5];
    CGContextSetFillColorWithColor(context, customColor.CGColor);
    CGContextFillPath(context);
    
    CGRect scanRect = CGRectMake(self.center.x - _scanMaskSize.width / 2,
                                 CGRectGetHeight(self.frame)/2 - _scanMaskSize.height / 2,
                                 _scanMaskSize.width,
                                 _scanMaskSize.height);
    //Rubber area drawing
    CGContextClearRect(context, scanRect);
    //Draw rectangle
    CGContextAddRect(context, scanRect);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextDrawPath(context, kCGPathStroke);
    
    //Draw scan line
    [self drawScanLineWithContext:context andFrame:scanRect];
    
    //Draw scan edge angle
    [self drawScanFrame:scanRect andContext:context];

//    CGContextRestoreGState(context);
    
    //Draw text
    NSString *content = _remindContent;
    CGRect contentRect = CGRectMake(scanRect.origin.x-40,
                                    scanRect.origin.y - 35,
                                    320, 30);
    UIFont *font = [UIFont systemFontOfSize:16];
    UIColor *contentColor =[UIColor whiteColor];
    [contentColor set];
    [content drawInRect:contentRect withFont:font lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
}

- (void)drawScanLineWithContext:(CGContextRef)context andFrame:(CGRect)rect
{
    //To determine if line is out of the scan frame
    if (self.moveStep >= rect.size.height - 10 ) {
        self.moveStep = 0;
    }else{
        self.moveStep += 3;
    }
    
    UIImage *scanLineImage = [UIImage imageNamed:@"qrcode_scan_line.png"];
    CGRect lineRect = CGRectMake(rect.origin.x,
                                 rect.origin.y + _moveStep,
                                 rect.size.width, 10);
//    CGContextDrawImage(context, lineRect, scanLineImage.CGImage);
    drawImage(context, scanLineImage.CGImage, lineRect);
}

- (void)drawScanFrame:(CGRect)rect andContext:(CGContextRef)context
{
    CGPoint point = rect.origin;
    CGSize size = rect.size;
    //Draw scan edge angle
    //The top left corner
    UIImage *upperLeftImage = [UIImage imageNamed:@"scanqr1.png"];
    CGRect upperLeftFrame = CGRectMake(point.x + 0,
                                       point.y,
                                       upperLeftImage.size.width,
                                       upperLeftImage.size.height);
//    CGContextDrawImage(context, upperLeftFrame, upperLeftImage.CGImage);
    drawImage(context, upperLeftImage.CGImage, upperLeftFrame);
    
    //Upper right corner
    UIImage *upperRightImage = [UIImage imageNamed:@"scanqr2.png"];
    CGRect upperRightFrame = CGRectMake(point.x + size.width - upperRightImage.size.width,
                                        point.y + 0,
                                        upperRightImage.size.width,
                                        upperRightImage.size.height);
//    CGContextDrawImage(context, upperRightFrame, upperRightImage.CGImage);
    drawImage(context, upperRightImage.CGImage, upperRightFrame);
    
    //Left lower corner
    UIImage *bottomLeftImage = [UIImage imageNamed:@"scanqr3.png"];
    CGRect bottonLeftFrame = CGRectMake(point.x + 0,
                                        point.y  + size.height - upperLeftImage.size.height,
                                        bottomLeftImage.size.width,
                                        bottomLeftImage.size.height);
//    CGContextDrawImage(context, bottonLeftFrame, bottomLeftImage.CGImage);
    drawImage(context, bottomLeftImage.CGImage, bottonLeftFrame);
    
    
    //Lower right corner
    UIImage *bottomRightImage = [UIImage imageNamed:@"scanqr4.png"];
    CGRect bottomRightFrame = CGRectMake(point.x + size.width - bottomRightImage.size.width,
                                         point.y + size.height - upperRightImage.size.height,
                                         bottomRightImage.size.width,
                                         bottomRightImage.size.height);
//    CGContextDrawImage(context, bottomRightFrame, bottomRightImage.CGImage);
      drawImage(context, bottomRightImage.CGImage, bottomRightFrame);
}

void drawImage(CGContextRef context, CGImageRef image , CGRect rect)
{
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(context, rect, image);
    
    CGContextRestoreGState(context);
}

-(void)dealloc
{
//    NSLog(@"nnn");
}

@end
