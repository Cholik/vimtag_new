//
//  MNDisplayBridge.h
//  mipci
//
//  Created by mining on 16/1/25.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol LFDisplayBridgeTriggering <NSObject>
- (void) refresh;
@end

@interface MNDisplayBridge : NSObject <LFDisplayBridgeTriggering>

+ (instancetype) sharedInstance;

@property (nonatomic, readonly, assign) CFMutableSetRef subscribedViews;
- (void) addSubscribedViewsObject:(UIView<LFDisplayBridgeTriggering> *)object;
- (void) removeSubscribedViewsObject:(UIView<LFDisplayBridgeTriggering> *)object;

@end
