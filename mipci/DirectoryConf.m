//
//  DirectoryConf.m
//  mipci
//
//  Created by mining on 16/3/16.
//
//

#import "DirectoryConf.h"

@implementation DirectoryConf

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.directoryId = [aDecoder decodeObjectForKey:@"directoryId"];
        self.nick = [aDecoder decodeObjectForKey:@"nick"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.directoryId forKey:@"directoryId"];
    [aCoder encodeObject:self.nick forKey:@"nick"];
}

@end
