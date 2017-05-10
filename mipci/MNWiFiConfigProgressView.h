//
//  MNWiFiConfigProgressView.h
//  mipci
//
//  Created by mining on 16/6/23.
//
//

#import <UIKit/UIKit.h>

@interface MNWiFiConfigProgressView : UIView

- (void)initWiFiConfigStatu;
- (void)startConnectRouter;
- (void)finishConnectRouter;
- (void)startConnectServer;
- (void)finishConnectServer;

@end
