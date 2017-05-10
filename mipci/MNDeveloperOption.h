//
//  MNDeveloperOption.h
//  mipci
//
//  Created by mining on 16/5/26.
//
//

#import <Foundation/Foundation.h>

@interface MNDeveloperOption : NSObject

@property (strong, nonatomic) NSString *playAgreement;
@property (strong, nonatomic) NSString *portalServer;
@property (strong, nonatomic) NSString *signalServer;
@property (assign, nonatomic) BOOL environmentSwitch;
@property (strong, nonatomic) NSString *printfVaule;
@property (assign, nonatomic) long printfLevel;

@property (assign, nonatomic) BOOL sceneSwitch;
@property (assign, nonatomic) BOOL ipcSwitch;
@property (assign, nonatomic) BOOL QRSwitch;
@property (assign, nonatomic) BOOL soundsSwitch;
@property (assign, nonatomic) BOOL normalSwitch;
@property (assign, nonatomic) BOOL webSwitch;
@property (assign, nonatomic) BOOL webMobileOriginSwitch;
@property (assign, nonatomic) BOOL nativeSwitch;
@property (assign, nonatomic) BOOL printLogSwitch;
@property (assign, nonatomic) BOOL saveLogSwitch;
@property (assign, nonatomic) BOOL multiScreenSwitch;
@property (assign, nonatomic) BOOL automationSwitch;
@property (assign, nonatomic) long freqhigh;
@property (assign, nonatomic) long freqlow;
@property (assign, nonatomic) long trans_mode;
@property (assign, nonatomic) long wifiSpeed;
@property (assign, nonatomic) long magic_loop_segs;
@property (assign, nonatomic) long start_magic_counts;
@property (strong, nonatomic) NSString *homeUrl;

@property (assign, nonatomic) BOOL getaddrinfoSwitch;
@property (assign, nonatomic) BOOL getifaddrSwitch;
@property (strong, nonatomic) NSString *getaddrinfo_ip;
@property (strong, nonatomic) NSString *getaddrinfo_port;
@property (assign, nonatomic) long getaddrinfo_ai_flag;
@property (assign, nonatomic) long getaddrinfo_ai_family;
@property (assign, nonatomic) long getaddrinfo_ai_sock;
@property (assign, nonatomic) long getaddrinfo_ai_proto;


+ (MNDeveloperOption *)shared_developerOption;
- (void)saveDeveloperOption;
- (void)clearDeveloperOption;

@end
