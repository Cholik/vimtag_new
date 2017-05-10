//
//  MNMdevMsg.h
//  mipci
//
//  Created by mining on 15/8/27.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MNMdevMsg : NSManagedObject

@property (nonatomic, retain) NSNumber * msg_id;
@property (nonatomic, retain) NSString * sn;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSNumber * date;
@property (nonatomic, retain) NSString * format_data;
@property (nonatomic, retain) NSString * img_token;
@property (nonatomic, retain) NSString * thumb_img_token;
@property (nonatomic, retain) NSData * local_thumb_img;
@property (nonatomic, retain) NSString * record_token;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * format_length;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * nick;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSNumber * exsw;
@property (nonatomic, retain) NSString * windSpeed;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) NSString * bp;

@end
