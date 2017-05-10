//
//  MNWebViewProgress.h
//  mipci
//
//  Created by mining on 15/11/7.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#undef njk_weak
#if __has_feature(objc_arc_weak)
#define njk_weak weak
#else
#define njk_weak unsafe_unretained
#endif

extern const float InitialProgressValue;
extern const float InteractiveProgressValue;
extern const float FinalProgressValue;

typedef void (^WebViewProgressBlock)(float progress);
@protocol MNWebViewProgressDelegate;

@interface MNWebViewProgress : NSObject<UIWebViewDelegate>
@property (nonatomic, njk_weak) id<MNWebViewProgressDelegate>progressDelegate;
@property (nonatomic, njk_weak) id<UIWebViewDelegate>webViewProxyDelegate;
@property (nonatomic, copy) WebViewProgressBlock progressBlock;
@property (nonatomic, readonly) float progress; // 0.0..1.0

- (void)reset;
@end

@protocol MNWebViewProgressDelegate <NSObject>
- (void)webViewProgress:(MNWebViewProgress *)webViewProgress updateProgress:(float)progress;

@end
