//
//  MNShareVideoWindow.m
//  mipci
//
//  Created by mining on 16/1/27.
//
//

#import "MNShareVideoWindow.h"
#import "AppDelegate.h"

#import <ifaddrs.h>
#import <arpa/inet.h>

#define SHADOWBGCOLOR       [UIColor blackColor]

#define SHAREVIEWHEIGHT     244
#define SHAREVIEWWIDTH      270
#define TITLEBGHEIGHT       68

#define TITLELABELWIDTH     100
#define TITLELABELHEIGHT    30
#define TITLELABELFONTSIZE  14.0
#define TITLELABELTEXTCOLOR [UIColor colorWithRed:30./255. green:179./255. blue:198./255. alpha:1.0]

#define SHARELABELWIDTH     230
#define SHARELABELHEIGHT    100
#define SHARELABELFONTSIZE  14.0
#define SHARELABELTEXTCOLOR [UIColor blackColor]

#define NOTELABELWIDTH     180
#define NOTELABELHEIGHT    70
#define NOTELABELFONTSIZE  12.0
#define NOTELABELTEXTCOLOR [UIColor redColor]

#define CLOSEBUTTONLENGTH   40
#define HEIGHTPOINT         20

@interface MNShareVideoWindow ()

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSString *http_conf_path;
@property (strong, nonatomic) NSString *ipAddress;

@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIView *shareView;

@end

@implementation MNShareVideoWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    
    return self;
}

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (void)initUI
{
    self.windowLevel = UIWindowLevelAlert;
    [self getIPAddress];
    
    UIViewController *rootViewController = [[UIViewController alloc] init];
    //init
    _shadowView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _shadowView.backgroundColor = SHADOWBGCOLOR;
    _shadowView.alpha = 0.4;
    
    _shareView =[[UIView alloc] initWithFrame:CGRectMake(self.center.x - SHAREVIEWWIDTH/2, self.center.y - SHAREVIEWHEIGHT/2, SHAREVIEWWIDTH, SHAREVIEWHEIGHT)];
    _shareView.backgroundColor = [UIColor whiteColor];
    _shareView.layer.cornerRadius = 5.0;
    
    UIImageView *titleBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.app.is_vimtag ? @"vt_prompt_title" : @"prompt_title"]];
    titleBg.frame = CGRectMake(0, 0, SHAREVIEWWIDTH, TITLEBGHEIGHT);
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleBg.center.x - TITLELABELWIDTH/2, titleBg.center.y - TITLELABELHEIGHT/2, TITLELABELWIDTH, TITLELABELHEIGHT)];
    titleLabel.font = [UIFont systemFontOfSize:TITLELABELFONTSIZE];
    titleLabel.textColor = self.app.is_vimtag ? TITLELABELTEXTCOLOR : [UIColor whiteColor];
    titleLabel.text = NSLocalizedString(@"mcs_share", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake((SHAREVIEWWIDTH - SHARELABELWIDTH)/2, TITLEBGHEIGHT + HEIGHTPOINT - 10, SHARELABELWIDTH, SHARELABELHEIGHT)];
    shareLabel.font = [UIFont systemFontOfSize:SHARELABELFONTSIZE];
    shareLabel.textColor = SHARELABELTEXTCOLOR;
    shareLabel.text = NSLocalizedString(@"mcs_share_prompt_start", nil);
    shareLabel.textAlignment = NSTextAlignmentLeft;
    shareLabel.numberOfLines = 0;
    shareLabel.text = [shareLabel.text stringByAppendingString:[NSString stringWithFormat:@" http://%@:7080 ",_ipAddress]];
    shareLabel.text = [shareLabel.text stringByAppendingString:NSLocalizedString(@"mcs_share_prompt_end", nil)];
    
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(shareLabel.frame.origin.x, TITLEBGHEIGHT + SHARELABELHEIGHT + 2*HEIGHTPOINT - 40, shareLabel.frame.size.width, NOTELABELHEIGHT)];
    noteLabel.font = [UIFont systemFontOfSize:NOTELABELFONTSIZE];
    noteLabel.textColor = NOTELABELTEXTCOLOR;
    noteLabel.text = NSLocalizedString(@"mcs_share_note", nil);
    noteLabel.textAlignment = NSTextAlignmentLeft;
    noteLabel.numberOfLines = 4;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SHAREVIEWWIDTH - CLOSEBUTTONLENGTH, 0, CLOSEBUTTONLENGTH, CLOSEBUTTONLENGTH)];
    [button setImage:[UIImage imageNamed:@"vt_delete"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_shareView addSubview:titleBg];
    [_shareView addSubview:titleLabel];
    [_shareView addSubview:shareLabel];
    [_shareView addSubview:noteLabel];
    [_shareView addSubview:button];
    
    [rootViewController.view addSubview:_shadowView];
    [rootViewController.view addSubview:_shareView];
    
    self.rootViewController = rootViewController;
    [self makeKeyAndVisible];
}

- (void)closeAction
{
    self.hidden = YES;
    self.closeBlock();
}

- (void)closeWindowWithBlock:(CloseBlock)block
{
    self.closeBlock = block;
}

#pragma mark - Get IP Address
- (void)getIPAddress
{
    _ipAddress = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    _ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    NSLog(@"Device IP : %@", _ipAddress);
    
    // Free memory
    freeifaddrs(interfaces);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        frame = self.bounds;
    }
    
    _shadowView.frame = frame;
    _shareView.frame = CGRectMake(self.center.x - SHAREVIEWWIDTH/2, self.center.y - SHAREVIEWHEIGHT/2, SHAREVIEWWIDTH, SHAREVIEWHEIGHT);
}

@end


