//
//  MNWebAddDeviceViewController.h
//  mipci
//
//  Created by mining on 16/6/22.
//
//

#import <UIKit/UIKit.h>

@class MNCameraOverlayView;
@interface MNWebAddDeviceViewController : UIViewController
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) MNCameraOverlayView *cameraOverlayView;
@property (strong, nonatomic) NSString *wwwVersion;
@property (strong, nonatomic) NSString *deviceType;
@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *devicePassword;
@property (assign, nonatomic) BOOL      isConnectWiFi;
@property (strong, nonatomic) NSString *select_wifi;
@property (strong, nonatomic) NSString *refresh_param;
@property (strong, nonatomic) NSString *ssid;
@property (strong, nonatomic) NSString *wifiPassword;
@property (assign, nonatomic) BOOL      isWifiConfig;
@property (assign, nonatomic) long      qrc;
@property (assign, nonatomic) long      snc;
@property (assign, nonatomic) long      wfc;
@property (assign, nonatomic) long      snfc;
@property (strong, nonatomic) NSString *configString;
@property (strong, nonatomic) NSString *callback;
@property (strong, nonatomic) NSString *jsParam;

+ (instancetype)webAddDeviceViewControllerWithFrame:(CGRect)frame htmlName:(NSString *)name LeftBarButtonItem:(NSString *)leftBarButtonItemType RightBarButtonItem:(NSString *)rightBarButtonItemType;
- (void)close;
@end
