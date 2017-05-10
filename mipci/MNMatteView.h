//
//  MNMatteView.h
//  MatteDemo
//
//  Created by weken on 15/3/25.
//  Copyright (c) 2015年 weken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNMatteView : UIView
@property (assign, nonatomic) int matrix_height;
@property (assign, nonatomic) int matrix_width;

@property (assign, nonatomic) float lineWidth;
@property (strong, nonatomic) UIColor *lineColor;

@property (strong, nonatomic) NSMutableArray *matrixs;


- (void)reset;

@end
