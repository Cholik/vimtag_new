//
//  DeviceInfo.h
//  mipci
//
//  Created by mining on 16/11/4.
//
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject

@property (strong, nonatomic) NSString  *resolution;
@property (assign, nonatomic) BOOL      hideUpgradeTips;
@property (assign, nonatomic) BOOL      hideTimezoneTips;

@end
