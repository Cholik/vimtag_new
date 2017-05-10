//
//  MNWiFiConfigProgressView.m
//  mipci
//
//  Created by mining on 16/6/23.
//
//

#import "MNWiFiConfigProgressView.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"

#define PROGRESS_VIEW_HEIGHT            64
#define PROGRESS_VIEW_WIDTH             320
#define DEFAULT_IMAGEVIEW_SIZE          44
#define DEFAULT_CONNECTIMAGE_SIZE       4
#define DEFAULT_LABEL_HEIGHT            20
#define DEFAULT_LABEL_WIDTH             80
#define DEFAULT_LABEL_FONT              [UIFont systemFontOfSize:13.0]
#define DEFAULT_LABEL_NORMAL_COLOR      [UIColor colorWithRed:144./255. green:144./255. blue:144./255. alpha:1.0]
#define DEFAULT_LABEL_FINISH_COLOR      [UIColor colorWithRed:0/255. green:166./255. blue:186./255. alpha:1.0]

@interface MNWiFiConfigProgressView ()

@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) MNConfiguration *configuration;

@property (strong, nonatomic) UIImageView *cameraImageView;
@property (strong, nonatomic) UIImageView *routerImageView;
@property (strong, nonatomic) UIImageView *serverImageView;

@property (strong, nonatomic) UILabel *cameraLabel;
@property (strong, nonatomic) UILabel *routerLabel;
@property (strong, nonatomic) UILabel *serverLabel;

@property (strong, nonatomic) UIImageView *connectRouterFirstImage;
@property (strong, nonatomic) UIImageView *connectRouterSecondImage;
@property (strong, nonatomic) UIImageView *connectRouterthirdImage;
@property (strong, nonatomic) UIImageView *connectRouterFourthImage;

@property (strong, nonatomic) UIImageView *connectServerFirstImage;
@property (strong, nonatomic) UIImageView *connectServerSecondImage;
@property (strong, nonatomic) UIImageView *connectServerthirdImage;
@property (strong, nonatomic) UIImageView *connectServerFourthImage;

@property (assign, nonatomic) long cycleCount;
@property (strong, nonatomic) UIColor *styleColor;

@end

@implementation MNWiFiConfigProgressView

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    
    return _configuration;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUI];
    }
    
    return self;
}

- (void)initUI
{
    if (self.app.is_ebitcam) {
        _styleColor = [UIColor colorWithRed:76/255. green:200./255. blue:110./255. alpha:1.0];
    } else if (self.app.is_mipc){
        _styleColor = self.configuration.switchTintColor;
    } else {
        _styleColor = self.configuration.color;
    }
    
    if (self.app.is_vimtag) {
        _cameraImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_camera_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_camera_active.png"]];
        _routerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_router_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_router_active.png"]];
        _serverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_server_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_server_active.png"]];
        
        _connectRouterFirstImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_progress_active.png"]];
        _connectRouterSecondImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_progress_active.png"]];
        _connectRouterthirdImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_progress_active.png"]];
        _connectRouterFourthImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_progress_active.png"]];

        _connectServerFirstImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_progress_active.png"]];
        _connectServerSecondImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_progress_active.png"]];
        _connectServerthirdImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_progress_active.png"]];
        _connectServerFourthImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"vt_progress_active.png"]];
    } else if (self.app.is_mipc) {
        _cameraImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_camera_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_camera_active.png"]];
        _routerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_router_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_router_active.png"]];
        _serverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_server_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_server_active.png"]];
        
        _connectRouterFirstImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_progress_active.png"]];
        _connectRouterSecondImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_progress_active.png"]];
        _connectRouterthirdImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_progress_active.png"]];
        _connectRouterFourthImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_progress_active.png"]];
        
        _connectServerFirstImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_progress_active.png"]];
        _connectServerSecondImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_progress_active.png"]];
        _connectServerFourthImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_progress_active.png"]];
        _connectServerthirdImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mi_progress_idle.png"] highlightedImage:[UIImage imageNamed:@"mi_progress_active.png"]];
    } else {
        _cameraImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_idle.png"] highlightedImage:[UIImage imageNamed:@"camera_active.png"]];
        _routerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"router_idle.png"] highlightedImage:[UIImage imageNamed:@"router_active.png"]];
        _serverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"server_idle.png"] highlightedImage:[UIImage imageNamed:@"server_active.png"]];
        
        _connectRouterFirstImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_idle.png"] highlightedImage:[UIImage imageNamed:@"progress_active.png"]];
        _connectRouterSecondImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_idle.png"] highlightedImage:[UIImage imageNamed:@"progress_active.png"]];
        _connectRouterthirdImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_idle.png"] highlightedImage:[UIImage imageNamed:@"progress_active.png"]];
        _connectRouterFourthImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_idle.png"] highlightedImage:[UIImage imageNamed:@"progress_active.png"]];
        
        _connectServerFirstImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_idle.png"] highlightedImage:[UIImage imageNamed:@"progress_active.png"]];
        _connectServerSecondImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_idle.png"] highlightedImage:[UIImage imageNamed:@"progress_active.png"]];
        _connectServerFourthImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_idle.png"] highlightedImage:[UIImage imageNamed:@"progress_active.png"]];
        _connectServerthirdImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_idle.png"] highlightedImage:[UIImage imageNamed:@"progress_active.png"]];
    }
    
    _cameraImageView.frame = CGRectMake(28, 0, DEFAULT_IMAGEVIEW_SIZE, DEFAULT_IMAGEVIEW_SIZE);
    _routerImageView.frame = CGRectMake(138, 0, DEFAULT_IMAGEVIEW_SIZE, DEFAULT_IMAGEVIEW_SIZE);
    _serverImageView.frame = CGRectMake(248, 0, DEFAULT_IMAGEVIEW_SIZE, DEFAULT_IMAGEVIEW_SIZE);
    
    //Connect Router
    _connectRouterFirstImage.frame = CGRectMake(82, 20, DEFAULT_CONNECTIMAGE_SIZE, DEFAULT_CONNECTIMAGE_SIZE);
    _connectRouterSecondImage.frame = CGRectMake(96, 20, DEFAULT_CONNECTIMAGE_SIZE, DEFAULT_CONNECTIMAGE_SIZE);
    _connectRouterthirdImage.frame = CGRectMake(110, 20, DEFAULT_CONNECTIMAGE_SIZE, DEFAULT_CONNECTIMAGE_SIZE);
    _connectRouterFourthImage.frame = CGRectMake(124, 20, DEFAULT_CONNECTIMAGE_SIZE, DEFAULT_CONNECTIMAGE_SIZE);
    //Connect Server
    _connectServerFirstImage.frame = CGRectMake(192, 20, DEFAULT_CONNECTIMAGE_SIZE, DEFAULT_CONNECTIMAGE_SIZE);
    _connectServerSecondImage.frame = CGRectMake(206, 20, DEFAULT_CONNECTIMAGE_SIZE, DEFAULT_CONNECTIMAGE_SIZE);
    _connectServerthirdImage.frame = CGRectMake(220, 20, DEFAULT_CONNECTIMAGE_SIZE, DEFAULT_CONNECTIMAGE_SIZE);
    _connectServerFourthImage.frame = CGRectMake(234, 20, DEFAULT_CONNECTIMAGE_SIZE, DEFAULT_CONNECTIMAGE_SIZE);
    
    _cameraLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT)];
    _cameraLabel.font = DEFAULT_LABEL_FONT;
    _cameraLabel.textColor = DEFAULT_LABEL_NORMAL_COLOR;
    _cameraLabel.highlightedTextColor = self.app.is_vimtag ? DEFAULT_LABEL_FINISH_COLOR : _styleColor;
    _cameraLabel.numberOfLines = 1;
    _cameraLabel.textAlignment = NSTextAlignmentCenter;
    _cameraLabel.text =NSLocalizedString(@"mcs_camera", nil);

    _routerLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 44, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT)];
    _routerLabel.font = DEFAULT_LABEL_FONT;
    _routerLabel.textColor = DEFAULT_LABEL_NORMAL_COLOR;
    _routerLabel.highlightedTextColor = self.app.is_vimtag ? DEFAULT_LABEL_FINISH_COLOR : _styleColor;
    _routerLabel.numberOfLines = 1;
    _routerLabel.textAlignment = NSTextAlignmentCenter;
    _routerLabel.text =NSLocalizedString(@"mcs_router", nil);
    
    _serverLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 44, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT)];
    _serverLabel.font = DEFAULT_LABEL_FONT;
    _serverLabel.textColor = DEFAULT_LABEL_NORMAL_COLOR;
    _serverLabel.highlightedTextColor = self.app.is_vimtag ? DEFAULT_LABEL_FINISH_COLOR : _styleColor;
    _serverLabel.numberOfLines = 1;
    _serverLabel.textAlignment = NSTextAlignmentCenter;
    _serverLabel.text =NSLocalizedString(@"mcs_server", nil);
    
    [self addSubview:_cameraImageView];
    [self addSubview:_routerImageView];
    [self addSubview:_serverImageView];
    [self addSubview:_cameraLabel];
    [self addSubview:_routerLabel];
    [self addSubview:_serverLabel];
    [self addSubview:_connectRouterFirstImage];
    [self addSubview:_connectRouterSecondImage];
    [self addSubview:_connectRouterthirdImage];
    [self addSubview:_connectRouterFourthImage];
    [self addSubview:_connectServerFirstImage];
    [self addSubview:_connectServerSecondImage];
    [self addSubview:_connectServerthirdImage];
    [self addSubview:_connectServerFourthImage];
}

#pragma mark - WiFi Config Progress Interface
- (void)initWiFiConfigStatu
{
    _cameraImageView.highlighted = YES;
    _routerImageView.highlighted = NO;
    _serverImageView.highlighted = NO;
    
    _cameraLabel.highlighted = YES;
    _routerLabel.highlighted = NO;
    _serverLabel.highlighted = NO;
    
    _connectRouterFirstImage.highlighted = NO;
    _connectRouterSecondImage.highlighted = NO;
    _connectRouterthirdImage.highlighted = NO;
    _connectRouterFourthImage.highlighted = NO;
    
    _connectServerFirstImage.highlighted = NO;
    _connectServerSecondImage.highlighted = NO;
    _connectServerthirdImage.highlighted = NO;
    _connectServerFourthImage.highlighted = NO;
    
    _cycleCount = 0;
}

//Connect Router
- (void)startConnectRouter
{
    if (_cycleCount == 5) {
        _cycleCount =0;
    }
    _connectRouterFirstImage.highlighted = _cycleCount > 0 ? YES : NO;
    _connectRouterSecondImage.highlighted = _cycleCount > 1 ? YES : NO;
    _connectRouterthirdImage.highlighted = _cycleCount > 2 ? YES : NO;
    _connectRouterFourthImage.highlighted = _cycleCount > 3 ? YES : NO;
    
    _cycleCount++;
}

- (void)finishConnectRouter
{
    _cameraImageView.highlighted = YES;
    _routerImageView.highlighted = YES;
    _serverImageView.highlighted = NO;
    
    _cameraLabel.highlighted = YES;
    _routerLabel.highlighted = YES;
    _serverLabel.highlighted = NO;
    
    _connectRouterFirstImage.highlighted = YES;
    _connectRouterSecondImage.highlighted = YES;
    _connectRouterthirdImage.highlighted = YES;
    _connectRouterFourthImage.highlighted = YES;
    
    _connectServerFirstImage.highlighted = NO;
    _connectServerSecondImage.highlighted = NO;
    _connectServerthirdImage.highlighted = NO;
    _connectServerFourthImage.highlighted = NO;
    
    _cycleCount = 0;
}

//Connect Server
- (void)startConnectServer
{
    if (_cycleCount == 5) {
        _cycleCount =0;
    }
    _connectServerFirstImage.highlighted = _cycleCount > 0 ? YES : NO;
    _connectServerSecondImage.highlighted = _cycleCount > 1 ? YES : NO;
    _connectServerthirdImage.highlighted = _cycleCount > 2 ? YES : NO;
    _connectServerFourthImage.highlighted = _cycleCount > 3 ? YES : NO;
    
    _cycleCount++;
}

- (void)finishConnectServer
{
    _cameraImageView.highlighted = YES;
    _routerImageView.highlighted = YES;
    _serverImageView.highlighted = YES;
    
    _cameraLabel.highlighted = YES;
    _routerLabel.highlighted = YES;
    _serverLabel.highlighted = YES;
    
    _connectRouterFirstImage.highlighted = YES;
    _connectRouterSecondImage.highlighted = YES;
    _connectRouterthirdImage.highlighted = YES;
    _connectRouterFourthImage.highlighted = YES;
    
    _connectServerFirstImage.highlighted = YES;
    _connectServerSecondImage.highlighted = YES;
    _connectServerthirdImage.highlighted = YES;
    _connectServerFourthImage.highlighted = YES;
    
    _cycleCount = 0;
}

@end
