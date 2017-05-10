//
//  DeviceInfo.m
//  mipci
//
//  Created by mining on 16/11/4.
//
//

#import "DeviceInfo.h"

@implementation DeviceInfo

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.resolution = [aDecoder decodeObjectForKey:@"resolution"];
        self.hideUpgradeTips = [aDecoder decodeBoolForKey:@"hideUpgradeTips"];
        self.hideTimezoneTips = [aDecoder decodeBoolForKey:@"hideTimezoneTips"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.resolution forKey:@"resolution"];
    [aCoder encodeBool:self.hideUpgradeTips forKey:@"hideUpgradeTips"];
    [aCoder encodeBool:self.hideTimezoneTips forKey:@"hideTimezoneTips"];
}

@end
