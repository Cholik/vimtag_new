//
//  MNProductInformationViewController.m
//  mipci
//
//  Created by mining on 15/11/6.
//
//

#import "MNProductInformationViewController.h"
#import "MIPCUtils.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "MNDeveloperOption.h"
#import "MNLoginViewController.h"
#import "UIImageView+refresh.h"
#import "MNRootNavigationController.h"

@interface MNProductInformationViewController () <UIAlertViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (weak, nonatomic) MNDeveloperOption *developerOption;

@property (strong, nonatomic) NSMutableDictionary *paramDict;
@property (assign, nonatomic) BOOL      isHideDiv;
@property (strong, nonatomic) NSString  *oldTitle;
@property (strong, nonatomic) NSString  *currentHtml;
@property (strong, nonatomic) NSString  *prevHtml;
@property (assign, nonatomic) BOOL       isCart;
@property (assign, nonatomic) BOOL       isFinishLoad;
@property (assign, nonatomic) BOOL       authenticated;
@property (strong, nonatomic) NSURLRequest  *currentRequest;
@property (strong, nonatomic) NSURLConnection  *currentConnection;

@property (strong, nonatomic) UILabel                 *downRefreshLabel;
@property (strong, nonatomic) UIActivityIndicatorView *pullUpActivityView;
@property (assign, nonatomic) BOOL                    isScrollerViewRelease;
@property (strong ,nonatomic) UIImageView *refreshImageView;
@property (strong, nonatomic) NSTimer *refreshTimer;
@property (assign, nonatomic) BOOL      isPaypalPage;
@property (assign, nonatomic) BOOL      isDisAppear;
@property (strong, nonatomic) NSString  *cartSrc;
@property (strong, nonatomic) NSString  *cartFuntion;
@property (strong, nonatomic) NSString  *backUrl;
@property (strong, nonatomic) NSString  *home_url;
@property (assign, nonatomic) BOOL  isGoHome;
@property (assign, nonatomic) BOOL  isShowTabbar;
@property (strong, nonatomic) NSString        *currentUrl;
@property (strong, nonatomic) NSString        *prevUrl;

@end

@implementation MNProductInformationViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

- (mipc_agent *)agent
{
    return self.app.cloudAgent;
}


- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

- (MNDeveloperOption *)developerOption
{
    if (nil == _developerOption) {
        _developerOption = [MNDeveloperOption shared_developerOption];
    }
    return _developerOption;
}

-(UIImageView *)refreshImageView
{
    if (_refreshImageView == nil) {
        _refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_vimtagRefresh"]];
    }
    return _refreshImageView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
//        self.navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"mcs_product",nil) image:[UIImage imageNamed:@"vt_home_idle"] selectedImage:[UIImage imageNamed:@"vt_home"]];
    }
    
    return self;
}

static MNProductInformationViewController *productInformationViewController;

+ (MNProductInformationViewController *)shared_productInformationViewController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        productInformationViewController = [[super allocWithZone:nil] init];
    });
    return productInformationViewController;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self shared_productInformationViewController];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [MNProductInformationViewController shared_productInformationViewController];
}

#pragma mark - View lifecycle
- (void)initUI
{
    //No Network
    _noNetworkLabel.text = NSLocalizedString(@"mcs_available_network", nil);
    [_noNetworkButton setTitle:NSLocalizedString(@"mcs_reload", nil) forState:UIControlStateNormal];
    [_noNetworkButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
    _noNetworkButton.layer.borderWidth = 1.0;
    _noNetworkButton.layer.cornerRadius = 2.0;
    _noNetworkButton.layer.borderColor = [UIColor colorWithRed:161./255. green:166./255. blue:179./255. alpha:1.0].CGColor;
    _noNetworkView.hidden = self.app.isNetWorkAvailable;
    
    UIButton *leftButton;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    } else {
        leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    }
    leftButton.frame =  CGRectMake(0,0,40,40);
    [leftButton setImage:[UIImage imageNamed:@"item_back.png"]forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(back)forControlEvents:UIControlEventTouchUpInside];
    leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -28, 0, 0);
    _backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = _backButton;
    self.navigationItem.leftBarButtonItem.customView.hidden = YES;

    _progressProxy = [[MNWebViewProgress alloc] init];
    _customWebView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    _customWebView.scrollView.delegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[MNWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    self.customWebView.frame = CGRectMake(self.customWebView.frame.origin.x, self.customWebView.frame.origin.y, self.customWebView.frame.size.width, self.view.frame.size.height + 50);
    
    _customWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    
    _downRefreshLabel = [[UILabel alloc] init];
    CGRect downRefreshLabelFrame = _downRefreshLabel.frame;
    downRefreshLabelFrame = CGRectMake(0, -35, 300, 40);
    //    downRefreshLabelFrame.origin.y = -35;
    _downRefreshLabel.frame = downRefreshLabelFrame;
    
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.view.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    
    _downRefreshLabel.font = [UIFont systemFontOfSize:16];
    _downRefreshLabel.textAlignment = NSTextAlignmentCenter;
    _downRefreshLabel.textColor = self.configuration.labelTextColor;
    _downRefreshLabel.hidden = YES;
    
    //    [self.collectionView addSubview:_downRefreshLabel];
    
    //get _downRefreshLabel.text width
    NSString *downRefreshLabelText = NSLocalizedString(@"mcs_refreshing", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        labelSize = [downRefreshLabelText boundingRectWithSize:CGSizeMake(0, 0)
                                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:attributes
                                                       context:nil].size;
        
        labelSize.width = ceil(labelSize.width);
    }
    if (self.app.is_vimtag) {
        
        [self.refreshImageView setImageViewFrame:self.customWebView.scrollView with:labelSize];
    }
    else {
        //activity for refresh
        _pullUpActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _pullUpActivityView.color = self.configuration.labelTextColor;
        CGRect frame = _pullUpActivityView.frame;
        frame.origin.y =  -25;
        _pullUpActivityView.frame = frame;
        _pullUpActivityView.hidesWhenStopped = YES;
        CGPoint center =_pullUpActivityView.center;
        center.x = self.customWebView.center.x - labelSize.width / 2.0 - 15;
        _pullUpActivityView.center = center;
        //    [self.collectionView addSubview:_pullUpActivityView];
    }

}

#pragma markviewDidLayoutSubviews
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.view.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    [self.customWebView.scrollView addSubview:_downRefreshLabel];
    
    _downRefreshLabel.hidden = YES;
    
    //get _downRefreshLabel.text width
    NSString *downRefreshLabelText = NSLocalizedString(@"mcs_refreshing", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        labelSize = [downRefreshLabelText boundingRectWithSize:CGSizeMake(0, 0)
                                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:attributes
                                                       context:nil].size;
        
        labelSize.width = ceil(labelSize.width);
    }
    if (self.app.is_vimtag) {
//        [self.refreshImageView layoutFrame:self.customWebView.scrollView with:labelSize];
        
        CGPoint center = self.refreshImageView.center;
        center.x = self.customWebView.scrollView.center.x - labelSize.width / 2.0 - 15;
        self.refreshImageView.center = center;
        [self.customWebView.scrollView addSubview:self.refreshImageView];
    }
    else {
        //activity for refresh
        CGPoint center =_pullUpActivityView.center;
        center.x = self.customWebView.scrollView.center.x - labelSize.width / 2.0 - 15;
        _pullUpActivityView.center = center;
        [self.customWebView.scrollView addSubview:_pullUpActivityView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    self.isShowTabbar = YES;
    
    //load web view
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    if (self.developerOption.homeUrl.length) {
        self.home_url = self.developerOption.homeUrl;
    } else {
       self.home_url = [[NSUserDefaults standardUserDefaults] stringForKey:@"u_home"];
    }

//    struct mipci_conf *conf = MIPC_ConfigLoad();
    
    if (![self.home_url isEqualToString:@""])
    {
//        NSString *urlString = [NSString stringWithUTF8String:(const char*) conf->home_url.data];
        NSString *urlString = self.
        home_url;
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
            NSURL *url =[[NSURL alloc] initWithString:urlString];
            NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
            [_customWebView loadRequest:request];
        }
    }
//    self.navigationItem.title = @"Vimtag";
    
    [self performSelector:@selector(homePageRefresh) withObject:nil afterDelay:5];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isDisAppear = NO;

    [self.navigationController.navigationBar addSubview:_progressView];
    if (!self.isDisAppear) {
        [self.tabBarController.tabBar setHidden:!self.isShowTabbar];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [self.refreshTimer invalidate];
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendBack)object:nil];


    [_progressView removeFromSuperview];
    
    self.isDisAppear = YES;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.isDisAppear = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.customWebView.delegate = nil;
    [self.customWebView stopLoading];
}

#pragma mark - Action
- (void)back
{
    _noNetworkView.hidden = self.app.isNetWorkAvailable;

    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendBack)object:nil];
    [self performSelector:@selector(sendBack) withObject:nil afterDelay:0.3f];
}

- (void)sendBack
{
    if (self.isHideDiv) {
        [self.customWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.%@();", [self.paramDict objectForKey:@"callback"]]];
        self.isHideDiv = NO;
        self.navigationItem.title = self.oldTitle;
    }
    else if (self.isGoHome) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.home_url]]) {
            NSURL *url =[[NSURL alloc] initWithString:self.home_url];
            NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
            [_customWebView loadRequest:request];
        }
        self.isGoHome = NO;
    }
    else if (self.backUrl && self.backUrl.length) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.backUrl]]) {
            NSURL *url =[[NSURL alloc] initWithString:self.backUrl];
            NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
            [_customWebView loadRequest:request];
        }
        self.backUrl = nil;
    } else if (self.isPaypalPage) {
        self.isPaypalPage = NO;
        [self.customWebView goBack];
        [self.customWebView goBack];
    }
    else if ([self.customWebView canGoBack]) {
        [self.customWebView goBack];
    }
}

- (void)shoppingCart
{
    if (self.app.is_userOnline)
    {
         [self.customWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.%@();", self.cartFuntion]];
    } else {
        self.isCart = YES;
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_sign_in", nil) message:NSLocalizedString(@"mcs_not_login_prompt", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
//        [alertView show];
        UIStoryboard *storyboard = self.app.mainStoryboard;
        MNLoginViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MNLoginViewController"];
        viewController.isMallLogin = YES;
        MNRootNavigationController *rootNavigationController = [[MNRootNavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:rootNavigationController animated:YES completion:nil];
    }
   
}

- (void)homePageRefresh
{
    if (!self.isFinishLoad) {
        [self refresh:nil];
    }
}

- (void)refresh:(id)sender
{
    _noNetworkView.hidden = self.app.isNetWorkAvailable;
    if ([[UIApplication sharedApplication] canOpenURL:self.customWebView.request.URL]) {
        [self.customWebView reload];
    } else {
        if (![self.home_url isEqualToString:@""])
        {
            NSString *urlString = self.home_url;
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
                NSURL *url =[[NSURL alloc] initWithString:urlString];
                NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
                [_customWebView loadRequest:request];
            }
        }
    }
}


#pragma mark - WebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    if (navigationType == UIWebViewNavigationTypeLinkClicked)
//    {
//        [self.tabBarController.tabBar setHidden:YES];
//    }
    _noNetworkView.hidden = self.app.isNetWorkAvailable;

    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:@"product" forKey:@"webView"];
    
    
    if (!_authenticated && [requestString rangeOfString:@"https://www"].location != NSNotFound) {
        _authenticated = NO;
        self.isPaypalPage = YES;
        _currentRequest = request;
        _currentConnection = [[NSURLConnection alloc]initWithRequest:_currentRequest delegate:self startImmediately:YES];
        return NO;
    }
    
    
    if ([requestString rangeOfString:@"https://www.sandbox.paypal.com"].location != NSNotFound) {
        self.isPaypalPage = YES;
    }
    
//    else if ([requestString rangeOfString:@"http"].location != NSNotFound)
//    {
//        self.prevUrl = self.currentUrl;
//        self.currentUrl = requestString;
//        if (self.prevUrl && self.prevUrl.length) {
//            self.backUrl = self.prevUrl;
//        }
//    }

    if ([requestString isEqualToString:@"about:blank"]) {
        
        if (![self.customWebView canGoBack]) {
            NSString *home_url;
            if (self.developerOption.homeUrl.length) {
                home_url = self.developerOption.homeUrl;
            } else {
                home_url = [[NSUserDefaults standardUserDefaults] stringForKey:@"u_home"];
            }
            
            if (![home_url isEqualToString:@""])
            {
               
                NSString *urlString = home_url;
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
                    NSURL *url =[[NSURL alloc] initWithString:urlString];
                    NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
                    [_customWebView loadRequest:request];
                }
            }
//            if (!self.isDisAppear) {
//                [self.tabBarController.tabBar setHidden:self.customWebView.canGoBack];
//            }
//            self.navigationItem.leftBarButtonItem.customView.hidden = !self.customWebView.canGoBack;
            return YES;

        } else {
            return NO;
        }
        
    }
    
    if ([requestString hasPrefix:@"iosapp:"]) {
         [self changeWebRequest:requestString];
         
     } else if ([requestString hasPrefix:@"weixin:"]) {
         [self weixinPay:requestString];
         
    } else if([requestString hasPrefix:@"alipay:"]){
         [self aliPay:requestString];
        
    }
    
//    self.navigationItem.leftBarButtonItem.customView.hidden = !self.customWebView.canGoBack;
//    if (!self.isDisAppear) {
//        [self.tabBarController.tabBar setHidden:self.customWebView.canGoBack];
//    }
    
    if (self.customWebView.canGoBack) {
        self.customWebView.frame = CGRectMake(self.customWebView.frame.origin.x, self.customWebView.frame.origin.y, self.customWebView.frame.size.width, self.view.frame.size.height + 50);
    } else {
         self.customWebView.frame = CGRectMake(self.customWebView.frame.origin.x, self.customWebView.frame.origin.y, self.customWebView.frame.size.width, self.view.frame.size.height);
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    self.navigationItem.leftBarButtonItem.customView.hidden = !self.customWebView.canGoBack;
//    if (!self.isDisAppear) {
//        [self.tabBarController.tabBar setHidden:self.customWebView.canGoBack];
//    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error
{
//    self.navigationItem.leftBarButtonItem.customView.hidden = !self.customWebView.canGoBack;
//    if (!self.isDisAppear) {
//        [self.tabBarController.tabBar setHidden:self.customWebView.canGoBack];
//    }
    
//    [self.customWebView.scrollView setContentOffset:CGPointMake(0, -64) animated:YES];
    NSString *errorString = [NSString stringWithFormat:@"%@",[error.userInfo objectForKey:@"NSErrorFailingURLKey"]];
    if ([errorString hasPrefix:@"iosapp:"]) {
        NSLog(@"%@", errorString);
        _isScrollerViewRelease = NO;
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.isFinishLoad = YES;
    _isScrollerViewRelease = NO;

    if (self.app.is_vimtag) {
        self.refreshImageView.hidden = YES;
        [self.refreshTimer invalidate];
    }
    else {
        [_pullUpActivityView stopAnimating];
    }

//    self.navigationItem.leftBarButtonItem.customView.hidden = !self.customWebView.canGoBack;
//    if (!self.isDisAppear) {
//        [self.tabBarController.tabBar setHidden:self.customWebView.canGoBack];
//    }
    
    if (self.customWebView.canGoBack) {
        self.customWebView.frame = CGRectMake(self.customWebView.frame.origin.x, self.customWebView.frame.origin.y, self.customWebView.frame.size.width, self.view.frame.size.height + 50);
    } else {
        self.customWebView.frame = CGRectMake(self.customWebView.frame.origin.x, self.customWebView.frame.origin.y, self.customWebView.frame.size.width, self.view.frame.size.height);
    }
    
    [self.customWebView.scrollView setContentOffset:CGPointMake(0, -64) animated:YES];

}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _authenticated = YES;
    [self.customWebView loadRequest:_currentRequest];
    [connection cancel];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge

{
    NSLog(@" willSendRequestForAuthenticationChallenge ");
    if (challenge.previousFailureCount == 0) {
        _authenticated = YES;
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
    else {
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}

#pragma mark - ScrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= -64 && _isScrollerViewRelease ) {
        [scrollView setContentOffset:CGPointMake(0, -64)];
    }
    
    if (scrollView.contentOffset.y < -84 && !_isScrollerViewRelease ) {
        _downRefreshLabel.hidden = NO;
        _downRefreshLabel.text = NSLocalizedString(@"mcs_down_refresh", nil);
        self.refreshImageView.hidden = YES;
    }
    
    if (scrollView.contentOffset.y  < -114 && !_isScrollerViewRelease){
        _downRefreshLabel.hidden = NO;
        _downRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
        self.refreshImageView.hidden = YES;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -114) {
        _downRefreshLabel.text = NSLocalizedString(@"mcs_refreshing", nil);
        if (self.app.is_vimtag) {
            self.refreshImageView.hidden = NO;
            [self.refreshTimer invalidate];
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self.refreshImageView selector:@selector(start) userInfo:nil repeats:YES];
        }
        else {
            [_pullUpActivityView startAnimating];
        }
        _isScrollerViewRelease = YES;
        [scrollView setContentOffset:CGPointMake(0, -104) animated:YES];
        [self performSelector:@selector(refresh:) withObject:nil afterDelay:.2f];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == -64) {
        _isScrollerViewRelease = NO;
        if (self.app.is_vimtag) {
            self.refreshImageView.hidden = YES;
            [self.refreshTimer invalidate];
        }
        else {
            [_pullUpActivityView stopAnimating];
        }
    }
}

#pragma mark - tool
//get param dict
- (NSMutableDictionary*)queryStringToDictionary:(NSString*)string {
    NSString *paramString = [string substringFromIndex:[string rangeOfString:@":"].location + 1];
    NSMutableArray *elements = (NSMutableArray*)[paramString componentsSeparatedByString:@"&"];
    [elements removeObjectAtIndex:0];
    NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:[elements count]];
    for(NSString *e in elements) {
        NSArray *pair = [e componentsSeparatedByString:@"="];
        [retval setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
    }
    return retval;
}

- (UIButton *)addRightItemWithImage:(UIImage *)image action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake(0, 0, image.size.width*0.5, image.size.height*0.5);

    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightItem;
    return button;  
}

- (void)changeWebRequest:(NSString *)requestString
{
    self.paramDict = [self queryStringToDictionary:requestString];
    NSString *type = [self.paramDict objectForKey:@"func"];
    
    if ([type isEqualToString:@"get_native_param"]) {
        
        if (self.app.is_userOnline) {
            
            NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
            NSString *password =[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];

            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:username forKey:@"username"];
            [dic setValue:password forKey:@"password"];
        
            [dic setValue:[self.paramDict objectForKey:@"loadweb"] forKey:@"loadweb"];

            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
        
            self.jsParam = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];


            NSString *nativeParam = [self.jsParam stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];

            [self.customWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.%@(\"%@\");", [self.paramDict objectForKey:@"callback"], nativeParam]];
        }
        else {
//           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_sign_in", nil) message:NSLocalizedString(@"mcs_not_login_prompt", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
//            [alertView show];
            UIStoryboard *storyboard = self.app.mainStoryboard;
            MNLoginViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MNLoginViewController"];
            viewController.isMallLogin = YES;
            MNRootNavigationController *rootNavigationController = [[MNRootNavigationController alloc] initWithRootViewController:viewController];
            [self presentViewController:rootNavigationController animated:YES completion:nil];
        }
        
    } else if([type isEqualToString:@"hide_div"]){
        self.oldTitle = self.navigationItem.title;
        self.navigationItem.title = [self.paramDict objectForKey:@"title"];
        self.isHideDiv = YES;
    } else if([type isEqualToString:@"send_title"]){
        self.navigationItem.title = [self.paramDict objectForKey:@"title"];
    } else if([type isEqualToString:@"send_image_src"]){
        self.cartSrc = [self.paramDict objectForKey:@"src"];
        self.cartFuntion = [self.paramDict objectForKey:@"cart_button"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            //get image
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.cartSrc]]];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self addRightItemWithImage:image action:@selector(shoppingCart)];
                self.navigationItem.rightBarButtonItem.customView.hidden = YES;

            });
        });
    } else if ([type isEqualToString:@"get_page_param"]) {
        NSString *cart    =  [self.paramDict objectForKey:@"cart"];
        NSString *back = [self.paramDict objectForKey:@"back_flag"];
        NSString *tabbar = [self.paramDict objectForKey:@"bottom_bar"];
        
        //tabbar show or hide
        if ([tabbar isEqualToString:@"show"]) {
            if (!self.isDisAppear && self.tabBarController.selectedIndex == 0)  {
                [self.tabBarController.tabBar setHidden:NO];
            }
            self.isShowTabbar = YES;
        } else if ([tabbar isEqualToString:@"hide"]) {
            if (!self.isDisAppear && self.tabBarController.selectedIndex == 0) {
                [self.tabBarController.tabBar setHidden:YES];
            }
            self.isShowTabbar = NO;
        }
        
        if([back isEqualToString:@"hide"]) {
            self.navigationItem.leftBarButtonItem.customView.hidden = YES;
            self.isGoHome = NO;
            self.backUrl = nil;
            
        } else if([back isEqualToString:@"yes"]){
            self.navigationItem.leftBarButtonItem.customView.hidden = NO;
            self.isGoHome = NO;
            
        } else if ([back isEqualToString:@"no"]) {
            self.navigationItem.leftBarButtonItem.customView.hidden = NO;
            
            self.isGoHome = NO;
            self.backUrl = nil;
            
        } else if ([back isEqualToString:@"home"]) {
            self.isGoHome = YES;
            self.backUrl = nil;
            
            self.navigationItem.leftBarButtonItem.customView.hidden = NO;
        }
        
        if ([cart isEqualToString:@"show"]) {
            self.navigationItem.rightBarButtonItem.customView.hidden = NO;
        } else {
            self.navigationItem.rightBarButtonItem.customView.hidden = YES;
        }
    } else if([type rangeOfString:@"get_back_url"].location != NSNotFound){
        NSString *string = [requestString substringFromIndex:@"iosapp:&func=get_back_url".length];
        if ([string rangeOfString:@"&callback="].location != NSNotFound) {
            NSInteger index = [string rangeOfString:@"&callback="].location;
            self.backUrl = [string substringToIndex:index];
        } else {
            self.backUrl = string;
        }
    }

}

//weixin pay
- (void)weixinPay:(NSString *)requestString
{
    if (![WXApi isWXAppInstalled])
    {
        NSLog(@"no installed ");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_please_install_wechat", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil) otherButtonTitles:nil];
        [alert show];
    } else if (![WXApi isWXAppSupportApi]){
        NSLog(@"this version don't support");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_wechat_not_support", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil) otherButtonTitles:nil];
        [alert show];
        
    } else {
        //open weixi
        NSData *payData = [[requestString substringFromIndex:7] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSMutableDictionary *payDic = [NSJSONSerialization JSONObjectWithData:payData options:NSJSONReadingMutableContainers error:&err];
        
        PayReq *request = [[PayReq alloc] init];
        request.partnerId = payDic[@"partnerid"];
        request.prepayId= payDic[@"prepayid"];
        request.package = payDic[@"package"];
        request.nonceStr= payDic[@"noncestr"];
        request.timeStamp = [payDic[@"timestamp"] intValue];
        request.sign= payDic[@"sign"];
        
        [WXApi sendReq: request];
    }
}

//alipay pay
- (void)aliPay:(NSString *)requestString
{
    //open alipay
    NSString *orderString = [requestString substringFromIndex:7];
    NSArray *signArray = [orderString componentsSeparatedByString:@"&sign=\""];
    NSArray *signTypeArray = [signArray[1] componentsSeparatedByString:@"\"&sign_type"];
    
    NSString *sign =(__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,
                                                                                          (__bridge CFStringRef)signTypeArray[0],
                                                                                          NULL,
                                                                                          CFSTR("!*'();:@&=+$,/?%#[]"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *signpreString = [[[signArray[0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]stringByReplacingOccurrencesOfString:@"%22" withString:@"\""] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    
    orderString  = [signpreString stringByAppendingFormat:@"&sign=\"%@\"&sign_type=\"RSA\"",sign];
    
    if (orderString != nil) {
        NSString *appScheme = @"vimtag";
        
        // NOTE: start pay
        __weak typeof(self) weakSelf = self;
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            weakSelf.tabBarController.tabBar.hidden = YES;
            weakSelf.customWebView.frame = CGRectMake(weakSelf.customWebView.frame.origin.x, weakSelf.customWebView.frame.origin.y, weakSelf.customWebView.frame.size.width, weakSelf.view.frame.size.height+50);

            [weakSelf.customWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.get_alipay_mark(\"%@\");", [resultDic objectForKey:@"resultStatus"]]];
        }];
    }
}

- (void)onResp:(BaseResp *)resp
{
    NSString *strMsg = [NSString stringWithFormat:@"pay result"];
    switch (resp.errCode) {
        case WXSuccess:
            strMsg = @"pay success";
            NSLog(@"PaySuccess，retcode = %d", resp.errCode);
            break;
        default:
            strMsg = [NSString stringWithFormat:@"pay failure！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
            NSLog(@"error，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
            break;
    }
    //call web
    self.tabBarController.tabBar.hidden = YES;
    self.customWebView.frame = CGRectMake(self.customWebView.frame.origin.x, self.customWebView.frame.origin.y, self.customWebView.frame.size.width, self.view.frame.size.height+50);
    [self.customWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.get_wx_mark(\"%d\");", resp.errCode]];
}

- (void)loadWeb
{
    if (self.isCart) {
//        NSURL *url = [NSURL URLWithString:@"http://61.147.115.218:10080/new_product/mall/cart.htm"];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        [self.customWebView loadRequest:request];
    } else {
        
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        NSString *password =[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:username forKey:@"username"];
        [dic setValue:password forKey:@"password"];
        
        [dic setValue:[self.paramDict objectForKey:@"loadweb"] forKey:@"loadweb"];
        
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
        
        self.jsParam = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        NSString *nativeParam = [[self.jsParam stringByReplacingOccurrencesOfString:@"\"" withString:@"'"]stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        
        [self.customWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.%@(\"%@\");", [self.paramDict objectForKey:@"callback"], nativeParam]];

    }

}


#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(MNWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        
//        UIStoryboard *storyboard = self.app.mainStoryboard;
//        MNLoginViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MNLoginViewController"];
//        viewController.isMallLogin = YES;
//        [self presentViewController:viewController animated:YES completion:nil];

    }
}

// called when scroll view grinds to a halt
#pragma mark - Screen
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
@end

//https
@implementation NSURLRequest(DataController)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end
