//
//  MNLine.h
//  mipci
//
//  Created by weken on 15/3/27.
//
//

#import <Foundation/Foundation.h>

@interface MNLine : NSObject
@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGPoint endPoint;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) float lineWidth;

@end
