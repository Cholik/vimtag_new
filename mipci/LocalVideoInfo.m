//
//  LocalVideoInfo.m
//  mipci
//
//  Created by mining on 14-12-5.
//
//

#import "LocalVideoInfo.h"

@implementation LocalVideoInfo

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.deviceId = [aDecoder decodeObjectForKey:@"deviceId"];
        self.boxId = [aDecoder decodeObjectForKey:@"boxId"];
        self.duration = [aDecoder decodeObjectForKey:@"darution"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.image = [aDecoder decodeObjectForKey:@"image"];
        self.mp4FilePath = [aDecoder decodeObjectForKey:@"data"];
        self.bigImageId = [aDecoder decodeObjectForKey:@"bigImageId"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.start_time = [aDecoder decodeInt64ForKey:@"start_time"];
        self.end_time = [aDecoder decodeInt64ForKey:@"end_time"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.deviceId forKey:@"deviceId"];
    [aCoder encodeObject:self.deviceId forKey:@"boxId"];
    [aCoder encodeObject:self.duration forKey:@"darution"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.mp4FilePath forKey:@"data"];
    [aCoder encodeObject:self.bigImageId forKey:@"bigImageId"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeInt64:self.start_time forKey:@"start_time"];
    [aCoder encodeInt64:self.end_time forKey:@"end_time"];
}

@end
