//
//  MNCache.m
//  mipci
//
//  Created by mining on 15/8/13.
//
//

#import "MNCache.h"

@implementation MNCache

+ (NSCache *)mn_sharedCache
{
    static NSCache *_mn_sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mn_sharedCache = [[NSCache alloc] init];
    });
    
    return _mn_sharedCache;
}

@end
