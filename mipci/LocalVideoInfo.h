//
//  LocalVideoInfo.h
//  mipci
//
//  Created by mining on 14-12-5.
//
//

#import <Foundation/Foundation.h>

@interface LocalVideoInfo : NSObject <NSCoding>

@property (copy, nonatomic) NSString *deviceId;
@property (copy, nonatomic) NSString *boxId;
@property (copy, nonatomic) NSString *duration;
@property (copy, nonatomic) NSString *date;

@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *mp4FilePath;
@property (copy, nonatomic) NSString *bigImageId;
@property (copy, nonatomic) NSString *type;

@property (assign, nonatomic) long long start_time;
@property (assign, nonatomic) long long end_time;

@property (assign, nonatomic) BOOL isSelect;

@end
