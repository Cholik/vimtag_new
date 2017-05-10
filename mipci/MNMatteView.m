//
//  MNMatteView.m
//  MatteDemo
//
//  Created by weken on 15/3/25.
//  Copyright (c) 2015年 weken. All rights reserved.
//
#define ADD_EDITSTYLE 1
#define DELETE_EDITSTYLE 0

#import "MNMatteView.h"
#import "MNLine.h"

typedef CGPoint MNMatrix;

@interface MNMatteView()
@property (strong, nonatomic) NSMutableArray *horizontalLines;
@property (strong, nonatomic) NSMutableArray *verticalLines;

@property (assign, nonatomic) double widthGap;
@property (assign, nonatomic) double heightGap;

@property (assign, nonatomic) BOOL editStyle;

@end

@implementation MNMatteView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //default value
        _matrixs = [NSMutableArray array];
        
        _matrix_height = 0;
        _matrix_width = 0;
        self.backgroundColor = [UIColor clearColor];
        
        _lineColor = [UIColor grayColor];
        _lineWidth = 1.0;
        
        _widthGap = CGRectGetWidth(frame) / 16;
        _heightGap = CGRectGetHeight(frame) / 9;
    }
    return self;
}

-(NSMutableArray *)horizontalLines
{
    @synchronized(self){
        if (nil == _horizontalLines) {
            _horizontalLines = [NSMutableArray array];
            
            for (int i = 0; i < 9; i++) {
                MNLine *line = [[MNLine alloc] init];
                line.lineWidth = _lineWidth;
                line.lineColor = _lineColor;
                line.startPoint = CGPointMake(0, i*_heightGap);
                line.endPoint = CGPointMake(CGRectGetWidth(self.bounds), i * _heightGap);
                
                [_horizontalLines addObject:line];
            }
        }
        
        return _horizontalLines;
    }
}

-(NSMutableArray *)verticalLines
{
    @synchronized(self){
        if (nil == _verticalLines) {
            _verticalLines = [NSMutableArray array];
            
            for (int i = 0; i < 16; i++) {
                MNLine *line = [[MNLine alloc] init];
                line.lineWidth = _lineWidth;
                line.lineColor = _lineColor;
                line.startPoint = CGPointMake(i * _widthGap, 0);
                line.endPoint = CGPointMake(i * _widthGap, CGRectGetHeight(self.bounds));
                
                [_verticalLines addObject:line];
            }
        }
        
        return _verticalLines;
    }
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)reset
{
    [self.matrixs removeAllObjects];
    [self setNeedsDisplay];
}


-(void)setMatrixs:(NSMutableArray *)matrixs
{
    _matrixs = matrixs;
    [self setNeedsDisplay];
}

#pragma mark - Touch event
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"---------->touch begin");
    CGPoint point = [[touches anyObject] locationInView:self];
    MNMatrix matrix =  [self transformPointToMatrix:point];
    
   if (![self.matrixs containsObject:[NSValue valueWithCGPoint:matrix]])
    {
        self.editStyle = ADD_EDITSTYLE;
        [self.matrixs addObject:[NSValue valueWithCGPoint:matrix]];
    }
    else
    {
        self.editStyle = DELETE_EDITSTYLE;
        [self.matrixs removeObject:[NSValue valueWithCGPoint:matrix]];
    }
    
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    MNMatrix matrix =  [self transformPointToMatrix:point];
    
    if (_editStyle == ADD_EDITSTYLE) {
        if (![self.matrixs containsObject:[NSValue valueWithCGPoint:matrix]]) {
            [self.matrixs addObject:[NSValue valueWithCGPoint:matrix]];
        }
    }
    else if(_editStyle == DELETE_EDITSTYLE)
    {
        if ([self.matrixs containsObject:[NSValue valueWithCGPoint:matrix]]) {
            [self.matrixs removeObject:[NSValue valueWithCGPoint:matrix]];
        }
    }
    
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - Utils
- (MNMatrix)transformPointToMatrix:(CGPoint)point
{
    int rowNumber = 0;
    int lineNumber = 0;
    
    for (int i = 0; i < self.verticalLines.count; i++) {
        MNLine *line = self.verticalLines[i];
        if (point.x >= line.startPoint.x) {
            lineNumber = line.startPoint.x / _widthGap + 0.000001;
        }
    }
    
    for (int i = 0; i < self.horizontalLines.count; i++) {
        MNLine *line = self.horizontalLines[i];
        if (point.y >= line.startPoint.y) {
            rowNumber = line.startPoint.y / _heightGap + 0.000001;
        }
    }
    
    MNMatrix matrix = CGPointMake(lineNumber, rowNumber);
    return matrix;
}

#pragma mark - DrawRect
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (MNLine *line in self.verticalLines) {
        CGContextMoveToPoint(context, line.startPoint.x, line.startPoint.y);
        CGContextAddLineToPoint(context, line.endPoint.x, line.endPoint.y);
        CGContextSetLineWidth(context, line.lineWidth);
        CGContextSetStrokeColorWithColor(context, line.lineColor.CGColor);
        
        CGContextStrokePath(context);
    }
    
    for (MNLine *line in self.horizontalLines) {
        CGContextMoveToPoint(context, line.startPoint.x, line.startPoint.y);
        CGContextAddLineToPoint(context, line.endPoint.x, line.endPoint.y);
        CGContextSetLineWidth(context, line.lineWidth);
        CGContextSetStrokeColorWithColor(context, line.lineColor.CGColor);
        
        CGContextStrokePath(context);
    }

    for (NSValue *value in self.matrixs) {
        
        MNMatrix matrix = [value CGPointValue];
        
        CGPoint point = CGPointMake(matrix.x * _widthGap, matrix.y * _heightGap);
        CGRect arect = CGRectMake(point.x, point.y, _widthGap, _heightGap);
        
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.5].CGColor);
        CGContextFillRect(context, arect);
    }
      
}

@end
