//
//  MNSpeedAndModelControlView.h
//  mipci
//
//  Created by mining on 15/7/2.
//
//

#import <UIKit/UIKit.h>

@interface MNSpeedAndModelControlView : UIView

@property(copy, nonatomic) void (^valueChanged)(id control, NSInteger value);
@property (assign, nonatomic) NSInteger modeValue;
@property (assign, nonatomic) NSInteger windSpeedValue;
@property (assign, nonatomic) NSInteger bartteyPower;
@end
