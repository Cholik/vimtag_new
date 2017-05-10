//
//  UserInfo.m
//  mipci
//
//  Created by mining on 14-12-2.
//
//

#import "UserInfo.h"

@implementation UserInfo

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_password forKey:@"password"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
    }
    
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[UserInfo class]]) {
        return NO;
    } else if ([_name isEqualToString:((UserInfo*)other).name]){
        return YES;
    }else{
        return NO;
    }
}

- (NSUInteger)hash
{
    return 1;
}

@end
