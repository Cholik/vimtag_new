//
//  MNAlipayOrder.h
//  mipci
//
//  Created by tanjiancong on 16/8/11.
//
//

#import <Foundation/Foundation.h>

@interface MNBizContent : NSObject

@property (nonatomic, copy) NSString *body;

@property (nonatomic, copy) NSString *subject;

@property (nonatomic, copy) NSString *out_trade_no;

@property (nonatomic, copy) NSString *timeout_express;

@property (nonatomic, copy) NSString *total_amount;

@property (nonatomic, copy) NSString *seller_id;

@property (nonatomic, copy) NSString *product_code;

@end


@interface MNAlipayOrder : NSObject

@property (nonatomic, copy) NSString *partner;

@property (nonatomic, copy) NSString *seller_id;

@property (nonatomic, copy) NSString *out_trade_no;

@property (nonatomic, copy) NSString *subject;

@property (nonatomic, copy) NSString *body;

@property (nonatomic, copy) NSString *total_fee;

@property (nonatomic, copy) NSString *notify_url;

@property (nonatomic, copy) NSString *service;

@property (nonatomic, copy) NSString *payment_type;

@property (nonatomic, copy) NSString *_input_charset;

@property (nonatomic, copy) NSString *it_b_pay;

@property (nonatomic, copy) NSString *sign;

@property (nonatomic, copy) NSString *sign_type;




- (NSString *)orderInfoEncoded:(BOOL)bEncoded;
@end
