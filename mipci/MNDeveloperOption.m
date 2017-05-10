//
//  MNDeveloperOption.m
//  mipci
//
//  Created by mining on 16/5/26.
//
//

#import "MNDeveloperOption.h"

@interface developer_option : NSObject

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

@property (assign, nonatomic) BOOL getaddrinfoSwitch;
@property (assign, nonatomic) BOOL getifaddrSwitch;
@property (strong, nonatomic) NSString *getaddrinfo_ip;
@property (strong, nonatomic) NSString *getaddrinfo_port;
@property (assign, nonatomic) long getaddrinfo_ai_flag;
@property (assign, nonatomic) long getaddrinfo_ai_family;
@property (assign, nonatomic) long getaddrinfo_ai_sock;
@property (assign, nonatomic) long getaddrinfo_ai_proto;

@property (strong, nonatomic) NSString *homeUrl;

@end

@implementation developer_option

- (id)initWithCoder:(NSCoder *)aDecoder
{
    //------ Modify flag ------
    self = [super init];
    if (self) {
        self.playAgreement = [aDecoder decodeObjectForKey:@"playAgreement"];
        self.portalServer = [aDecoder decodeObjectForKey:@"portalServer"];
        self.signalServer = [aDecoder decodeObjectForKey:@"signalServer"];
        self.homeUrl = [aDecoder decodeObjectForKey:@"homeUrl"];
        self.environmentSwitch = [aDecoder decodeBoolForKey:@"environmentSwitch"];
        self.printfVaule = [aDecoder decodeObjectForKey:@"printfVaule"];

        self.sceneSwitch = [aDecoder decodeBoolForKey:@"sceneSwitch"];
        self.ipcSwitch = [aDecoder decodeBoolForKey:@"ipcSwitch"];
        self.QRSwitch = [aDecoder decodeBoolForKey:@"QRSwitch"];
        self.soundsSwitch = [aDecoder decodeBoolForKey:@"soundsSwitch"];
        self.normalSwitch = [aDecoder decodeBoolForKey:@"normalSwitch"];
        self.webSwitch = [aDecoder decodeBoolForKey:@"webSwitch"];
        self.webMobileOriginSwitch = [aDecoder decodeBoolForKey:@"webMobileOriginSwitch"];
        self.nativeSwitch = [aDecoder decodeBoolForKey:@"nativeSwitch"];
        self.printLogSwitch = [aDecoder decodeBoolForKey:@"printLogSwitch"];
        self.saveLogSwitch = [aDecoder decodeBoolForKey:@"saveLogSwitch"];
        self.multiScreenSwitch = [aDecoder decodeBoolForKey:@"multiScreenSwitch"];
        self.automationSwitch = [aDecoder decodeBoolForKey:@"automationSwitch"];
        
        self.freqhigh = [aDecoder decodeInt64ForKey:@"freqhigh"];
        self.freqlow = [aDecoder decodeInt64ForKey:@"freqlow"];
        self.trans_mode = [aDecoder decodeInt64ForKey:@"trans_mode"];
        self.wifiSpeed = [aDecoder decodeInt64ForKey:@"wifiSpeed"];
        self.magic_loop_segs = [aDecoder decodeInt64ForKey:@"magic_loop_segs"];
        self.start_magic_counts = [aDecoder decodeInt64ForKey:@"start_magic_counts"];
        self.printfLevel = [aDecoder decodeInt64ForKey:@"printfLevel"];

        self.getaddrinfoSwitch = [aDecoder decodeBoolForKey:@"getaddrinfoSwitch"];
        self.getifaddrSwitch = [aDecoder decodeBoolForKey:@"getifaddrSwitch"];
        self.getaddrinfo_ip = [aDecoder decodeObjectForKey:@"getaddrinfo_ip"];
        self.getaddrinfo_port = [aDecoder decodeObjectForKey:@"getaddrinfo_port"];
        self.getaddrinfo_ai_flag = [aDecoder decodeInt64ForKey:@"getaddrinfo_ai_flag"];
        self.getaddrinfo_ai_family = [aDecoder decodeInt64ForKey:@"getaddrinfo_ai_family"];
        self.getaddrinfo_ai_sock = [aDecoder decodeInt64ForKey:@"getaddrinfo_ai_sock"];
        self.getaddrinfo_ai_proto = [aDecoder decodeInt64ForKey:@"getaddrinfo_ai_proto"];

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //------ Modify flag ------
    [aCoder encodeObject:self.playAgreement forKey:@"playAgreement"];
    [aCoder encodeObject:self.portalServer forKey:@"portalServer"];
    [aCoder encodeObject:self.signalServer forKey:@"signalServer"];
    [aCoder encodeObject:self.homeUrl forKey:@"homeUrl"];
    [aCoder encodeBool:self.environmentSwitch forKey:@"environmentSwitch"];
    [aCoder encodeObject:self.printfVaule forKey:@"printfVaule"];

    [aCoder encodeBool:self.sceneSwitch forKey:@"sceneSwitch"];
    [aCoder encodeBool:self.ipcSwitch forKey:@"ipcSwitch"];
    [aCoder encodeBool:self.QRSwitch forKey:@"QRSwitch"];
    [aCoder encodeBool:self.soundsSwitch forKey:@"soundsSwitch"];
    [aCoder encodeBool:self.normalSwitch forKey:@"normalSwitch"];
    [aCoder encodeBool:self.webSwitch forKey:@"webSwitch"];
    [aCoder encodeBool:self.webMobileOriginSwitch forKey:@"webMobileOriginSwitch"];
    [aCoder encodeBool:self.nativeSwitch forKey:@"nativeSwitch"];
    [aCoder encodeBool:self.printLogSwitch forKey:@"printLogSwitch"];
    [aCoder encodeBool:self.saveLogSwitch forKey:@"saveLogSwitch"];
    [aCoder encodeBool:self.multiScreenSwitch forKey:@"multiScreenSwitch"];
    [aCoder encodeBool:self.automationSwitch forKey:@"automationSwitch"];
    
    [aCoder encodeInt64:self.freqhigh forKey:@"freqhigh"];
    [aCoder encodeInt64:self.freqlow forKey:@"freqlow"];
    [aCoder encodeInt64:self.trans_mode forKey:@"trans_mode"];
    [aCoder encodeInt64:self.wifiSpeed forKey:@"wifiSpeed"];
    [aCoder encodeInt64:self.magic_loop_segs forKey:@"magic_loop_segs"];
    [aCoder encodeInt64:self.start_magic_counts forKey:@"start_magic_counts"];
    [aCoder encodeInt64:self.printfLevel forKey:@"printfLevel"];

    [aCoder encodeBool:self.getaddrinfoSwitch forKey:@"getaddrinfoSwitch"];
    [aCoder encodeBool:self.getifaddrSwitch forKey:@"getifaddrSwitch"];
    [aCoder encodeObject:self.getaddrinfo_ip forKey:@"getaddrinfo_ip"];
    [aCoder encodeObject:self.getaddrinfo_port forKey:@"getaddrinfo_port"];
    [aCoder encodeInt64:self.getaddrinfo_ai_flag forKey:@"getaddrinfo_ai_flag"];
    [aCoder encodeInt64:self.getaddrinfo_ai_family forKey:@"getaddrinfo_ai_family"];
    [aCoder encodeInt64:self.getaddrinfo_ai_sock forKey:@"getaddrinfo_ai_sock"];
    [aCoder encodeInt64:self.getaddrinfo_ai_proto forKey:@"getaddrinfo_ai_proto"];
}


@end

@implementation MNDeveloperOption

static MNDeveloperOption *developerOption;

+ (MNDeveloperOption *)shared_developerOption
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        developerOption = [[super allocWithZone:nil] init];
    });
    return developerOption;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self shared_developerOption];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [MNDeveloperOption shared_developerOption];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self loadDeveloperOption];
    }
    
    return self;
}

#pragma mark - Save && Load Developer Option
- (void)loadDeveloperOption
{
    //------ Modify flag ------
    NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"developer_option"];
    if (usersData) {
        developer_option *obj = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
        
        self.playAgreement = obj.playAgreement;
        self.portalServer = obj.portalServer;
        self.signalServer = obj.signalServer;
        self.environmentSwitch = obj.environmentSwitch;
        self.printfVaule = obj.printfVaule;
        self.printfLevel = obj.printfLevel;
        
        self.sceneSwitch = obj.sceneSwitch;
        self.ipcSwitch = obj.ipcSwitch;
        
        self.QRSwitch = obj.QRSwitch ;
        self.soundsSwitch = obj.soundsSwitch;
        self.normalSwitch = obj.normalSwitch;
        
        self.webSwitch = obj.webSwitch;
        self.webMobileOriginSwitch = obj.webMobileOriginSwitch;
        self.nativeSwitch = obj.nativeSwitch;
        
        self.printLogSwitch = obj.printLogSwitch;
        self.saveLogSwitch = obj.saveLogSwitch;
        self.multiScreenSwitch = obj.multiScreenSwitch;
        self.automationSwitch = obj.automationSwitch;
        
        self.freqhigh = obj.freqhigh ;
        self.freqlow = obj.freqlow;
        self.trans_mode = obj.trans_mode;
        self.wifiSpeed = obj.wifiSpeed;
        self.magic_loop_segs = obj.magic_loop_segs;
        self.start_magic_counts = obj.start_magic_counts;
        
        self.getaddrinfoSwitch = obj.getaddrinfoSwitch;
        self.getifaddrSwitch = obj.getifaddrSwitch;
        self.getaddrinfo_ip = obj.getaddrinfo_ip;
        self.getaddrinfo_port = obj.getaddrinfo_port;
        self.getaddrinfo_ai_flag = obj.getaddrinfo_ai_flag;
        self.getaddrinfo_ai_family = obj.getaddrinfo_ai_family;
        self.getaddrinfo_ai_sock = obj.getaddrinfo_ai_sock;
        self.getaddrinfo_ai_proto = obj.getaddrinfo_ai_proto;

        self.homeUrl = obj.homeUrl;
    }
}

- (void)saveDeveloperOption
{
    //------ Modify flag ------
    developer_option *obj = [[developer_option alloc] init];
    
    obj.playAgreement = self.playAgreement;
    obj.portalServer = self.portalServer;
    obj.signalServer = self.signalServer;
    obj.environmentSwitch = self.environmentSwitch;
    obj.printfVaule = self.printfVaule;
    obj.printfLevel = self.printfLevel;
    
    obj.sceneSwitch = self.sceneSwitch;
    obj.ipcSwitch = self.ipcSwitch;
    
    obj.QRSwitch = self.QRSwitch;
    obj.soundsSwitch = self.soundsSwitch;
    obj.normalSwitch = self.normalSwitch;
    obj.webSwitch = self.webSwitch;
    obj.webMobileOriginSwitch = self.webMobileOriginSwitch;
    obj.nativeSwitch = self.nativeSwitch;
    
    obj.printLogSwitch = self.printLogSwitch;
    obj.saveLogSwitch = self.saveLogSwitch;
    obj.multiScreenSwitch = self.multiScreenSwitch;
    obj.automationSwitch = self.automationSwitch;
    
    obj.freqhigh = self.freqhigh;
    obj.freqlow = self.freqlow;
    obj.trans_mode = self.trans_mode;
    obj.wifiSpeed = self.wifiSpeed;
    obj.magic_loop_segs = self.magic_loop_segs;
    obj.start_magic_counts = self.start_magic_counts;
    
    obj.getaddrinfoSwitch = self.getaddrinfoSwitch;
    obj.getifaddrSwitch = self.getifaddrSwitch;
    obj.getaddrinfo_ip = self.getaddrinfo_ip;
    obj.getaddrinfo_port = self.getaddrinfo_port;
    obj.getaddrinfo_ai_flag = self.getaddrinfo_ai_flag;
    obj.getaddrinfo_ai_family = self.getaddrinfo_ai_family;
    obj.getaddrinfo_ai_sock = self.getaddrinfo_ai_sock;
    obj.getaddrinfo_ai_proto = self.getaddrinfo_ai_proto;
    
    obj.homeUrl = self.homeUrl;
    
    NSData *usersData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [[NSUserDefaults standardUserDefaults] setObject:usersData forKey:@"developer_option"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearDeveloperOption
{
    //------ Modify flag ------
    self.playAgreement = nil;
    self.portalServer = nil;
    self.signalServer = nil;
    self.environmentSwitch = NO;
    self.printfVaule = nil;
    self.printfLevel = 0;
    self.freqhigh      = 0;
    self.freqlow      = 0;
    self.trans_mode    = 0;
    self.wifiSpeed     = 0;
    self.magic_loop_segs = 0;
    self.start_magic_counts = 0;
    self.sceneSwitch = NO;
    self.ipcSwitch = NO;
    self.QRSwitch = NO;
    self.soundsSwitch = NO;
    self.normalSwitch = NO;
    self.webSwitch = NO;
    self.webMobileOriginSwitch = NO;
    self.nativeSwitch = NO;
    self.printLogSwitch = NO;
    self.saveLogSwitch = NO;
    self.homeUrl = nil;
    self.multiScreenSwitch = NO;
    self.automationSwitch = NO;
    
    self.getaddrinfoSwitch = NO;
    self.getifaddrSwitch = NO;
    self.getaddrinfo_ip = nil;
    self.getaddrinfo_port = nil;
    self.getaddrinfo_ai_flag = 0;
    self.getaddrinfo_ai_family = 0;
    self.getaddrinfo_ai_sock = 0;
    self.getaddrinfo_ai_proto = 0;
    
    [self saveDeveloperOption];
}

@end
