//
//  MNPostAlertView.m
//  mipci
//
//  Created by mining on 16/1/25.
//
//
#import "MNPostAlertView.h"
#import "MNAlertBackgroundWindow.h"
#import "MNAlertViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MNGlassView.h"
#import "AppDelegate.h"
#import "MNLoginNavigationController.h"
#import "MNDeviceListViewController.h"
#import "MIPCUtils.h"
#import "MNMoreInformationViewController.h"
#import "MNDeviceListSetViewController.h"

#define EXIT @"exit"

static NSMutableArray *__cx_pending_alert_queue;
static BOOL __cx_alert_animating;
static MNAlertBackgroundWindow *__cx_alert_background_window;
static MNPostAlertView *__cx_alert_current_view;

@interface MNPostAlertView ()
{
    BOOL _updateAnimated;
}

@property (nonatomic, strong) UIWindow *oldKeyWindow;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, assign, getter = isVisible) BOOL visible;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) MNGlassView *blurView;
@property (nonatomic, assign, getter = isLayoutDirty) BOOL layoutDirty;
@property (nonatomic, strong) NSMutableArray *startItemArray;
@property (nonatomic, strong) NSMutableArray *loginItemArray;
@property (nonatomic, strong) NSMutableArray *runningItemArray;
@property (nonatomic, assign) BOOL   isLoginSuccess;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (strong, nonatomic) mipc_agent       *agent;
@property (strong, nonatomic) AppDelegate      *app;

+ (NSMutableArray *)sharedQueue;
+ (MNPostAlertView *)currentAlertView;

+ (BOOL)isAnimating;
+ (void)setAnimating:(BOOL)animating;

+ (void)showBackground;
+ (void)hideBackgroundAnimated:(BOOL)animated;
- (CGFloat)preferredHeight;
//
- (void)setup;
- (void)tearDown;
- (void)validateLayout;
- (void)invalidateLayout;
- (void)resetTransition;
// Views
- (void)setupContainerView;
- (void)updateContentScrollView;
- (void)dismissWithCleanup:(BOOL)cleanup;
//transition
- (void)transitionInCompletion:(void(^)(void))completion;
- (void)transitionOutCompletion:(void(^)(void))completion;

// Blur
- (void)updateBlurBackground;
@end

@implementation MNPostAlertView

+ (void)initialize
{
    if (self != [MNPostAlertView class])
        return;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        MNPostAlertView *appearance = [self appearance];
        appearance.viewBackgroundColor = [UIColor whiteColor];
        appearance.cornerRadius = 10;
        appearance.shadowRadius = 10;
    });
}


- (mipc_agent *)agent
{
    if (_agent == nil) {
        _agent = [mipc_agent shared_mipc_agent];
    }
    return _agent;
}

- (AppDelegate *)app
{
    if (_app == nil) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self validateLayout];
}
#pragma mark - CXAlertView PB
- (instancetype)initWithFrame:(CGRect)frame post:(mcall_ret_post_get *)postGetCtx status:(BOOL)isLoginSuccess
{
    
    if (frame.size.width > frame.size.height) {
        self = [super initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.width)];
    }
    else
    {
        self = [super initWithFrame:frame];
    }
    if (self) {
        _isLoginSuccess = isLoginSuccess;
        [self initWithPost:postGetCtx];
    }
    return self;
}
- (void)initWithPost:(mcall_ret_post_get *)ret
{
    post_item *item = [[post_item alloc] init];
    for (int i = 0; i < ret.item.count; i++)
    {
        item = ret.item[i];
        if ([item.num caseInsensitiveCompare:@"once"] == NSOrderedSame)
        {
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *postInfoDerectory = [documentPath stringByAppendingString:@"/postInfo"];
            BOOL isDerectory;
            BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:postInfoDerectory isDirectory:&isDerectory];
            if (!isFileExist || !isDerectory) {
                NSError *error = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:postInfoDerectory withIntermediateDirectories:YES attributes:nil error:&error];
                if (error) {
                    NSLog(@"notification_get_done error:%@", [error localizedDescription]);
                }
            }
            
            NSString *postInfoPath = [postInfoDerectory stringByAppendingFormat:@"/%@.inf", item.key];
            [NSKeyedArchiver archiveRootObject:item toFile:postInfoPath];
        }
        
    }
    
    _startItemArray = [NSMutableArray array];
    _loginItemArray = [NSMutableArray array];
    _runningItemArray = [NSMutableArray array];
    
//    if (ret.item.count == 0) {
//        return;
//    }
    for (post_item *item in ret.item) {
        if (item.time % 100)
        {
            [_startItemArray addObject:item];
        }
        if (item.time / 10 % 10)
        {
            [_loginItemArray addObject:item];
        }
        if (item.time % 10) {
            [_runningItemArray addObject:item];
        }
    }
}


#pragma mark - close post
- (void)postCloseAction:(id)sender
{
    [self dismiss];
    //FIXME
    if (_isLoginSuccess)
    {
        for (post_item *item  in _runningItemArray)
        {
            if ([item.action caseInsensitiveCompare:@"exit"] == NSOrderedSame)
            {
                [self exitApplication];
            }
            else if ([item.action caseInsensitiveCompare:@"logout"] == NSOrderedSame)
            {
                [self logout];
            }
        }
        
    }
    else
    {
        for (post_item *item  in _runningItemArray)
        {
            if ([item.action caseInsensitiveCompare:@"exit"] == NSOrderedSame)
            {
                [self exitApplication];
            }
            else if ([item.action caseInsensitiveCompare:@"logout"] == NSOrderedSame)
            {
                [self logout];
            }
        }
    }
    
}
-(UIViewController *)getCurrentRootViewController
{
    UIViewController *result;
    // Try to find the root view controller programmically
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        
        
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    }
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
    {
        result = topWindow.rootViewController;
    }
    else
        NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
    
    return result;
}

#pragma mark - logout
- (void)logout
{
    mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init];
    ctx.target = self;
    [self.agent sign_out:ctx];
    
    if (self.app.is_vimtag)
    {
        struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
        if(conf)
        {
            conf_new = *conf;
        }
        conf_new.auto_login = 0;
        MIPC_ConfigSave(&conf_new);
        self.app.is_userOnline = NO;

        UITabBarController *tabbarController = (UITabBarController *)[self getCurrentRootViewController];
        
        for (UINavigationController *navigationController in tabbarController.viewControllers) {
            for (UIViewController *viewController in navigationController.viewControllers) {
//                if ([viewController isMemberOfClass:[MNDeviceListPageViewController class]]) {
//                    MNDeviceListViewController *deviceListViewController= [((MNDeviceListPageViewController*)viewController).viewControllerArray firstObject];
//                    [deviceListViewController.navigationController popToRootViewControllerAnimated:YES];
//                    [deviceListViewController dismissViewControllerAnimated:YES completion:nil];
//                    deviceListViewController.navigationController.navigationBarHidden = NO;
//                    deviceListViewController.LoginPromptView.hidden = NO;
//                    
//                }
                if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                    MNDeviceListViewController *deviceListViewController= ((MNDeviceListSetViewController *)viewController).deviceListViewController;
                    [deviceListViewController.navigationController popToRootViewControllerAnimated:YES];
                    [deviceListViewController dismissViewControllerAnimated:YES completion:nil];
                    deviceListViewController.navigationController.navigationBarHidden = NO;
                    deviceListViewController.LoginPromptView.hidden = NO;
                    
                }

                if ([viewController isMemberOfClass: [MNMoreInformationViewController class]])
                    [(MNMoreInformationViewController *)viewController initInterface];
            }
        }
    }
    else
    {
        [[self getCurrentRootViewController] dismissViewControllerAnimated:NO completion:nil];
        [[self getCurrentRootViewController].navigationController popToRootViewControllerAnimated:YES];
        
        NSNotification *exitNotice = [NSNotification notificationWithName:EXIT object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:exitNotice];
    }
    
}

#pragma mark - exit app
- (void)exitApplication
{
    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:10];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_currentViewController.view.window cache:NO];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    _currentViewController.view.window.bounds = CGRectMake(0, 0, 0, 0);
    [UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID compare:@"exitApplication"] == 0) {
        exit(0);
    }
    
}

#pragma mark - webView delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.isLoading)
    {
        return;
    }
    NSString *meta;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom=1.3"];
    }
    else if (self.frame.size.height <= 480)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=0.8, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    else if (self.frame.size.height > 480 && self.frame.size.height <= 568)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, height=%f initial-scale=0.9, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width, webView.frame.size.height];
    }
    else if (self.frame.size.height > 568 && self.frame.size.height <= 667)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    else if(self.frame.size.height > 667)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    
    [webView stringByEvaluatingJavaScriptFromString:meta];
    
    if ((_isLoginSuccess && _runningItemArray.count) || (!_isLoginSuccess && _loginItemArray.count)) {
        self.visible = YES;
        [MNPostAlertView setAnimating:YES];
        [MNPostAlertView setCurrentAlertView:self];
        
        MNAlertViewController *viewController = [[MNAlertViewController alloc] initWithNibName:nil bundle:nil];
        viewController.alertView = self;
        
        //        if (!self.alertWindow) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelAlert;
        window.rootViewController = viewController;
        self.alertWindow = window;
        //        }
        
        [MNPostAlertView showBackground];
        [self.alertWindow makeKeyAndVisible];
        [self validateLayout];
        [self transitionInCompletion:^{
            [MNPostAlertView setAnimating:NO];
            
            for (int index = 0; index < [MNPostAlertView sharedQueue].count; index++)
            {
                MNPostAlertView *alert = [[MNPostAlertView sharedQueue] objectAtIndex:index];
                if (alert != self)
                {
                    alert.visible = NO;
                    [alert tearDown];
                    [[MNPostAlertView sharedQueue] removeObject:alert];
                }
            }
        }];
    }
}

- (BOOL)webView: (UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = [request URL];
    if ([[url absoluteString] isEqualToString:@"http://vimtag.com/download/"] || [[url absoluteString] isEqualToString:@"http://mipcm.com/download/"])
    {
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    return YES;
}
// AlertView action
- (void)show
{
    if (![MNPostAlertView sharedQueue].count) {
        self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
    }
    
    [[MNPostAlertView sharedQueue] addObject:self];
    
    //add webView
    _webView= [[UIWebView alloc] init];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.layer.cornerRadius = 10;
    _webView.layer.masksToBounds = YES;
    //    webView.scrollView.scrollEnabled = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _webView.frame = CGRectMake(0, 0, self.frame.size.width - 300, self.frame.size.height-500);
    }
    else if (self.frame.size.height <= 480)
    {
        _webView.frame = CGRectMake(0, 0, self.frame.size.width - (self.frame.size.width / 15 )* 2, 320);
    }
    else if (self.frame.size.height > 480 && self.frame.size.height <= 568)
    {
        _webView.frame = CGRectMake(0, 0, self.frame.size.width - (self.frame.size.width / 15 )* 2, 340);
    }
    
    else if(self.frame.size.height > 568 && self.frame.size.height <= 667)
    {
        _webView.frame = CGRectMake(0, 0, self.frame.size.width - (self.frame.size.width / 15 )* 2, 380);
        
    }
    else if(self.frame.size.height > 667 && self.frame.size.height <= 736)
    {
        _webView.frame = CGRectMake(0, 0, self.frame.size.width - (self.frame.size.width / 15 )* 2, 410);
    }
    _containerWidth = _webView.frame.size.width;
    _containerHeight = _webView.frame.size.height;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_webView.frame.size.width - 40, 8, 32, 32)];
    [button setImage:[UIImage imageNamed:@"vt_delete"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(postCloseAction:) forControlEvents:UIControlEventTouchUpInside];
    [_webView addSubview:button];
    
    if (_isLoginSuccess){
        for (int i = 0; i < _runningItemArray.count; i++) {
            post_item  *item = _runningItemArray[i];
            if (item.url != nil && item.url.length) {
                NSURL *url = [NSURL URLWithString:item.url];
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
                [_webView loadRequest:request];
            }
        }
    } else{
        for (int i = 0; i < _loginItemArray.count ; i++) {
            
            post_item  *item = _loginItemArray[i];
            if (item.url != nil && item.url.length) {
                NSURL *url = [NSURL URLWithString:item.url];
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
                [_webView loadRequest:request];
            }
        }
    }
    
    _contentScrollViewMaxHeight = _webView.frame.size.height;
    _contentView = _webView;
    
}

- (void)dismiss
{
    [self dismissWithCleanup:YES];
}
// Operation
- (void)cleanAllPenddingAlert
{
    [[MNPostAlertView sharedQueue] removeAllObjects];
}

#pragma mark - AlertView PV
+ (NSMutableArray *)sharedQueue
{
    if (!__cx_pending_alert_queue) {
        __cx_pending_alert_queue = [NSMutableArray array];
    }
    return __cx_pending_alert_queue;
}

+ (MNPostAlertView *)currentAlertView
{
    return __cx_alert_current_view;
}

+ (void)setCurrentAlertView:(MNPostAlertView *)alertView
{
    __cx_alert_current_view = alertView;
}

+ (BOOL)isAnimating
{
    return __cx_alert_animating;
}

+ (void)setAnimating:(BOOL)animating
{
    __cx_alert_animating = animating;
}

+ (void)showBackground
{
    if (!__cx_alert_background_window) {
        __cx_alert_background_window = [[MNAlertBackgroundWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        [__cx_alert_background_window makeKeyAndVisible];
        __cx_alert_background_window.alpha = 0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             __cx_alert_background_window.alpha = 1;
                         }];
    }
}

+ (void)hideBackgroundAnimated:(BOOL)animated
{
    if (!animated) {
        [__cx_alert_background_window removeFromSuperview];
        __cx_alert_background_window = nil;
        return;
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         __cx_alert_background_window.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [__cx_alert_background_window removeFromSuperview];
                         __cx_alert_background_window = nil;
                     }];
}

- (CGFloat)preferredHeight
{
    CGFloat height = 0;
    height += ([self heightForContentScrollView]);
    return height;
}


- (CGFloat)heightForContentScrollView
{
    return MAX(self.contentScrollViewMinHeight, MIN(self.contentScrollViewMaxHeight, CGRectGetHeight(self.contentView.frame)));
}

- (void)setup
{
    [self setupContainerView];
    [self updateContentScrollView];
}

- (void)tearDown
{
    [self.containerView removeFromSuperview];
    [self.blurView removeFromSuperview];
    
    [self.alertWindow removeFromSuperview];
    self.alertWindow = nil;
    self.layoutDirty = NO;
}

- (void)validateLayout
{
    if (!self.isLayoutDirty) {
        return;
    }
    self.layoutDirty = NO;
    
    //    CGFloat height = [self preferredHeight];
    CGFloat height = _containerHeight;
    CGFloat left = (self.bounds.size.width - self.containerWidth) * 0.5;
    CGFloat top = (self.bounds.size.height - height) * 0.5;
    _containerView.transform = CGAffineTransformIdentity;
    _blurView.transform = CGAffineTransformIdentity;
    if (_updateAnimated) {
        _updateAnimated = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _containerView.frame = CGRectMake(left, top, self.containerWidth, height);
            _blurView.frame = CGRectMake(left, top, self.containerWidth, height);
        }];
    }
    else {
        _containerView.frame = CGRectMake(left, top, self.containerWidth, height);
        _blurView.frame = CGRectMake(left, top, self.containerWidth, height);
    }
    _containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_containerView.bounds cornerRadius:_containerView.layer.cornerRadius].CGPath;
    NSLog(@"containerView:%@  _blurView:%@", NSStringFromCGRect(_containerView.frame), NSStringFromCGRect(_blurView.frame));
}

- (void)invalidateLayout
{
    self.layoutDirty = YES;
    [self setNeedsLayout];
}

- (void)resetTransition
{
    [_containerView.layer removeAllAnimations];
}
// Scroll Views
- (void)setupContainerView
{
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.containerView];
    
    _containerView.clipsToBounds = YES;
    
    _containerView.backgroundColor = _viewBackgroundColor ? _viewBackgroundColor : [UIColor whiteColor];
    _containerView.layer.cornerRadius = self.cornerRadius;
    _containerView.layer.shadowOffset = CGSizeZero;
    _containerView.layer.shadowRadius = self.shadowRadius;
    _containerView.layer.shadowOpacity = 0.5;
    
    [self updateBlurBackground];
}

- (void)updateContentScrollView
{
    if (![_containerView.subviews containsObject:_contentView]) {
        [_containerView addSubview:_contentView];
    }
    [self invalidateLayout];
}

- (void)dismissWithCleanup:(BOOL)cleanup
{
    BOOL isVisible = self.isVisible;
    
    void (^dismissComplete)(void) = ^{
        self.visible = NO;
        [self tearDown];
        [MNPostAlertView setCurrentAlertView:nil];
        [MNPostAlertView setAnimating:NO];
        
        if (cleanup) {
            [[MNPostAlertView sharedQueue] removeAllObjects];
        }
        
    };
    
    if (isVisible) {
        [MNPostAlertView setAnimating:YES];
        [self transitionOutCompletion:dismissComplete];
        
        //        if ([MNPostAlertView sharedQueue].count == 1) {
        [MNPostAlertView hideBackgroundAnimated:YES];
        //        }
        
    } else {
        dismissComplete();
        
        //        if ([MNPostAlertView sharedQueue].count == 0) {
        [MNPostAlertView hideBackgroundAnimated:YES];
        //        }
    }
    
    [_oldKeyWindow makeKeyWindow];
    _oldKeyWindow.hidden = NO;
}
// Transition
- (void)transitionInCompletion:(void(^)(void))completion
{
    _containerView.alpha = 0;
    _containerView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    
    _blurView.alpha = 0;
    _blurView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _containerView.alpha = 1.;
                         _containerView.transform = CGAffineTransformMakeScale(1.0,1.0);
                         
                         _blurView.alpha = 1.;
                         _blurView.transform = CGAffineTransformMakeScale(1.0,1.0);
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)transitionOutCompletion:(void(^)(void))completion
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         _containerView.alpha = 0;
                         _containerView.transform = CGAffineTransformMakeScale(0.9,0.9);
                         
                         _blurView.alpha = 0;
                         _blurView.transform = CGAffineTransformMakeScale(0.9,0.9);
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)updateBlurBackground
{
    UIColor *containerBKGColor = _viewBackgroundColor ? _viewBackgroundColor : [UIColor whiteColor];
    self.containerView.backgroundColor = [containerBKGColor colorWithAlphaComponent:_showBlurBackground ? 0.7 : 1.];;
    
    if (_showBlurBackground) {
        if (self.blurView == nil) {
            self.blurView = [[MNGlassView alloc] initWithFrame:self.containerView.frame];
            self.blurView.clipsToBounds = YES;
            self.blurView.layer.cornerRadius = self.cornerRadius;
            self.blurView.blurRadius = 10.;
            self.blurView.scaleFactor = 1.;
            self.blurView.blurSuperView = self.oldKeyWindow.rootViewController.view;
        }
        
        [self insertSubview:self.blurView belowSubview:self.containerView];
    } else {
        [self.blurView removeFromSuperview];
    }
}

- (void)setContentView:(UIView *)contentView
{
    if (_contentView != contentView) {
        _contentView = contentView;
        _updateAnimated = YES;
        [self updateContentScrollView];
        [self invalidateLayout];
    }
}

#pragma mark - UIAppearance setters
- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (_cornerRadius == cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    self.containerView.layer.cornerRadius = cornerRadius;
    self.blurView.layer.cornerRadius = cornerRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    if (_shadowRadius == shadowRadius) {
        return;
    }
    _shadowRadius = shadowRadius;
    self.containerView.layer.shadowRadius = shadowRadius;
}

- (void)setShowBlurBackground:(BOOL)showBlurBackground
{
    if (_showBlurBackground == showBlurBackground) {
        return;
    }
    _showBlurBackground = showBlurBackground;
    [self updateBlurBackground];
}
@end

