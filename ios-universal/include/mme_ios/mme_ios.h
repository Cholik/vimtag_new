/*!
 \file       mmec_ios.h
 \brief      mining media engine ios core unit
 	
 ----history----
 \author     chengzhiyong
 \date       2012-02-18
 \version    0.01
 \desc       create
 */
#if !defined(__mmec_ios_h__)
#define __mmec_ios_h__

#import <UIKit/UIKit.h>

struct MMediaEngineCtx;

@interface MMediaEngineEvent : NSObject
{
@private
    NSString                *m_type;            /*!< event type */
    long                    status;             /*!< integer status */
    NSString                *m_code;            /*!< code string information */
    long                    chl_id;             /*!< chl_id */
    NSString                *m_data;            /*!< additional data */
}
@property (nonatomic, readonly) long status;
@property (nonatomic, readonly) long chl_id;
@property (nonatomic, readonly, retain) NSString* type;
@property (nonatomic, readonly, retain) NSString* code;
@property (nonatomic, readonly, retain) NSString* data;
@end

@interface MMediaEngine : UIView 
{
@private
    struct MMediaEngineCtx *_ctx;
}
@property  (nonatomic)          float scale_max;
@property  (nonatomic)          float scale_min;
@property  (nonatomic)          float scale;

- (long) engine_create:(NSString*) params refer:(id) refer onEvent:(SEL) onEvent/* MMediaEngineEvent* */;
- (long) engine_destroy;
- (long) chl_create: (NSString*) params;
- (long) chl_destroy: (long) chl_id;
- (MMediaEngineEvent*) ctrl: (long) chl_id method:(NSString*) method params:(NSString*) params;
@end

#endif /* !defined(__mmec_ios_h__) */
