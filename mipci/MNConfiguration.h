//
//  MNConfiguration.h
//  mipci
//
//  Created by mining on 15/8/26.
//
//

#import <Foundation/Foundation.h>

@interface MNConfiguration : NSObject

@property (strong, nonatomic) UIFont  *globalFont;
@property (strong, nonatomic) UIColor *interfaceBackgroundColor;
@property (strong, nonatomic) UIColor *labelTextColor;
@property (strong, nonatomic) UIColor *labelBackgroundColor;
@property (strong, nonatomic) UIColor *buttonTintColor;
@property (strong, nonatomic) UIColor *buttonBackgroundColor;
@property (strong, nonatomic) UIColor *navigationBarTintColor;
@property (strong, nonatomic) UIColor *navigationBarTitleColor;
@property (strong, nonatomic) UIColor *tabBarTintColor;
@property (strong, nonatomic) UIColor *switchTintColor;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *buttonTitleColor;
@property (strong, nonatomic) UIColor *loginButtonTitleColor;
@property (strong, nonatomic) UIColor *buttonColor;

@property (assign, nonatomic) BOOL is_luxcam;
@property (assign, nonatomic) BOOL is_ebitcam;
@property (assign, nonatomic) BOOL is_mipc;
@property (assign, nonatomic) BOOL is_itelcamera;
@property (assign, nonatomic) BOOL is_ehawk;
@property (strong, nonatomic) NSString *alert_independent;
@property (assign, nonatomic) BOOL is_vimtag;
@property (assign, nonatomic) BOOL is_SereneViewer;
@property (assign, nonatomic) BOOL is_eyedot;
@property (assign, nonatomic) BOOL is_avuecam;
@property (assign, nonatomic) BOOL is_kean;
@property (assign, nonatomic) BOOL is_prolab;
@property (assign, nonatomic) BOOL is_eyeview;
@property (assign, nonatomic) BOOL is_maxCAM;
@property (assign, nonatomic) BOOL is_bosma;

@property (assign, nonatomic) BOOL is_whiteBackground;

+ (MNConfiguration *)shared_configuration;

- (void)readConfiguration;

@end
