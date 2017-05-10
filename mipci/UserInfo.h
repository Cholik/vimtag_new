//
//  UserInfo.h
//  mipci
//
//  Created by mining on 14-12-2.
//
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject <NSCoding>
@property (copy, nonatomic) NSString *name;
@property(copy, nonatomic) NSData *password;

@end
