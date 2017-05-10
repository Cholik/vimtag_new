//
//  MNMyOrderViewController.m
//  mipci
//
//  Created by tanjiancong on 16/8/11.
//
//

#import "MNMyOrderViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "MNWebViewProgress.h"
#import "MNWebViewProgressView.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "UIImageView+refresh.h"
#import "MNDeveloperOption.h"

#define PULL_AREA_HEIGTH 60.0f
#define PULL_TRIGGER_HEIGHT (PULL_AREA_HEIGTH + 5.0f)
#define PULL_DISTANCE_TO_VIEW 10.0f


@interface MNMyOrderViewController ()<UIWebViewDelegate, MNWebViewProgressDelegate, NSURLConnectionDataDelegate, UIScrollViewDelegate>


@property (strong, nonatomic) MNWebViewProgressView *progressView;
@property (strong, nonatomic) MNWebViewProgress *progressProxy;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) MNConfiguration *configuration;

@property (strong, nonatomic) NSString                *jsParam;

@property (strong, nonatomic) NSMutableDictionary     *paramDict;
@property (assign, nonatomic) BOOL                    isOrderPage;
@property (assign, nonatomic) BOOL                    isRefreshing;
@property (assign, nonatomic) BOOL                    downFinishReloadData;
@property (assign, nonatomic) BOOL                    isScrollerViewRelease;
@property (assign, nonatomic) BOOL                    isPreviosRefresh;
@property (assign, nonatomic) BOOL                    upFinishReloadData;
@property (assign, nonatomic) BOOL                    isFinishLoad;


@property (assign, nonatomic) CGFloat                 contentOffsetY;

@property (strong, nonatomic) UILabel                 *downRefreshLabel;
@property (strong, nonatomic) UILabel                 *upRefreshLabel;

@property (strong, nonatomic) UIView                  *upRefreshView;
@property (strong, nonatomic) UIActivityIndicatorView *pullDownActivityView;
@property (strong, nonatomic) UIActivityIndicatorView *pullUpActivityView;

@property (strong, nonatomic) UIImageView             *refreshDownImageView;
@property (strong, nonatomic) UIImageView             *refreshUpImageView;
@property (strong, nonatomic) NSTimer                 *refreshUpTimer;
@property (strong, nonatomic) NSTimer                 *refreshDownTimer;
@property (assign, nonatomic) BOOL                    authenticated;
@property (assign, nonatomic) BOOL                    isPaypalPage;
@property (strong, nonatomic) NSURLRequest            *currentRequest;
@property (strong, nonatomic) NSURLConnection         *currentConnection;
@property (assign, nonatomic) BOOL                    isGohome;
@property (assign, nonatomic) BOOL                    isClose;
@property (weak, nonatomic) MNDeveloperOption       *developerOption;
@property (strong, nonatomic) NSString                *home_url;
@property (strong, nonatomic) NSString                *backUrl;

@end

@implementation MNMyOrderViewController

static MNMyOrderViewController *myOrderViewController;

+ (MNMyOrderViewController *)shared_myOrderViewController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myOrderViewController = [[super allocWithZone:nil] init];
    });
    return myOrderViewController;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self shared_myOrderViewController];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [MNMyOrderViewController shared_myOrderViewController];
}

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


-(UIImageView *)refreshUpImageView
{
    if (_refreshUpImageView == nil) {
        _refreshUpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_vimtagRefresh"]];
    }
    return _refreshUpImageView;
}

-(UIImageView *)refreshDownImageView
{
    if (_refreshDownImageView == nil) {
        _refreshDownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_vimtagRefresh"]];
    }
    return _refreshDownImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    if (self.developerOption.homeUrl.length) {
        self.home_url = self.developerOption.homeUrl;
    } else {
        self.home_url = [[NSUserDefaults standardUserDefaults] stringForKey:@"u_home"];
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&o=my_order", self.home_url]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
    
    [self performSelector:@selector(homePageRefresh) withObject:nil afterDelay:5];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:_progressView];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.app.is_vimtag) {
        if (self.refreshUpTimer) {
            [self.refreshUpTimer invalidate];
            self.refreshUpTimer = nil;
        }
        
        if (self.refreshDownTimer) {
            [self.refreshDownTimer invalidate];
            self.refreshDownTimer = nil;
        }
    }
    else {
        [_pullDownActivityView stopAnimating];
        [_pullUpActivityView stopAnimating];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_progressView removeFromSuperview];
    [_refreshUpImageView removeFromSuperview];
    [_refreshDownImageView removeFromSuperview];
    _refreshDownImageView = nil;
    _refreshUpImageView = nil;
    [_upRefreshLabel removeFromSuperview];
    [_upRefreshView removeFromSuperview];

}

- (void)dealloc
{
    NSLog(@"MNMyOrderViewControllr:dealloc");
}
#pragma mark - layoutSubViews
- (void)viewDidLayoutSubviews
{
    //layout refresh
    
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.webView.scrollView.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    _downRefreshLabel.hidden = YES;
    _upRefreshLabel.hidden = YES;
    
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
        [self.refreshDownImageView layoutFrame:self.webView.scrollView with:labelSize];
        
        CGRect frame = _upRefreshView.frame;
        frame.size.width = self.webView.scrollView.frame.size.width;
        if (self.webView.scrollView.contentSize.height > self.webView.scrollView.frame.size.height) {
            frame.origin.y = self.webView.scrollView.contentSize.height + 5;
        }
        else{
            frame.origin.y = self.webView.scrollView.frame.size.height +5;
        }
        _upRefreshView.frame = frame;
        if ([self collectionViewAddRefreshView]) {
            [_upRefreshView removeFromSuperview];
        }
        [self collectionViewAddRefreshView];
        
        CGPoint labelCenter = _upRefreshLabel.center;
        labelCenter.x = _upRefreshView.frame.size.width / 2;
        _upRefreshLabel.center = labelCenter;
        
        self.refreshUpImageView.center = self.refreshDownImageView.center;
    }
    else {
        //activity for refresh
        CGPoint center =_pullDownActivityView.center;
        center.x = self.webView.scrollView.center.x - labelSize.width / 2.0 - 15;
        _pullDownActivityView.center = center;
        [self.webView.scrollView addSubview:_pullDownActivityView];
        
        CGRect frame = _upRefreshView.frame;
        frame.size.width = self.webView.scrollView.frame.size.width;
        if (self.webView.scrollView.contentSize.height > self.webView.scrollView.frame.size.height) {
            frame.origin.y = self.webView.scrollView.contentSize.height + 5;
        }
        else{
            frame.origin.y = self.webView.scrollView .frame.size.height +5;
        }
        _upRefreshView.frame = frame;
        if ([self collectionViewAddRefreshView]) {
            [_upRefreshView removeFromSuperview];
        }
        [self collectionViewAddRefreshView];
        
        CGPoint labelCenter = _upRefreshLabel.center;
        labelCenter.x = _upRefreshView.frame.size.width / 2;
        _upRefreshLabel.center = labelCenter;
        
        _pullUpActivityView.center = center;
    }
    
}

- (void)initUI
{
    //No Network
    _noNetworkLabel.text = NSLocalizedString(@"mcs_available_network", nil);
    [_noNetworkButton setTitle:NSLocalizedString(@"mcs_reload", nil) forState:UIControlStateNormal];
    [_noNetworkButton addTarget:self action:@selector(downPullRefresh) forControlEvents:UIControlEventTouchUpInside];
    _noNetworkButton.layer.borderWidth = 1.0;
    _noNetworkButton.layer.cornerRadius = 2.0;
    _noNetworkButton.layer.borderColor = [UIColor colorWithRed:161./255. green:166./255. blue:179./255. alpha:1.0].CGColor;
    _noNetworkView.hidden = self.app.isNetWorkAvailable;
    
    _progressProxy = [[MNWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    _webView.scrollView.delegate = self;
    
//    _webView.scrollView.subviews[0].backgroundColor = [UIColor blueColor];
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[MNWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    //Refresh prompt
    _downRefreshLabel = [[UILabel alloc] init];
    CGRect downRefreshLabelFrame = _downRefreshLabel.frame;
    downRefreshLabelFrame = CGRectMake(0, -35, 300, 40);
    //    downRefreshLabelFrame.origin.y = -35;
    _downRefreshLabel.frame = downRefreshLabelFrame;
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.webView.scrollView.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    
    _downRefreshLabel.font = [UIFont systemFontOfSize:16];
    _downRefreshLabel.textAlignment = NSTextAlignmentCenter;
    _downRefreshLabel.textColor = self.configuration.labelTextColor;
    _downRefreshLabel.hidden = YES;
    
    [self.webView.scrollView addSubview:_downRefreshLabel];

    
    _upRefreshLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
    
    _upRefreshLabel.font = [UIFont systemFontOfSize:16];
    _upRefreshLabel.textColor = self.configuration.labelTextColor;
    _upRefreshLabel.textAlignment = NSTextAlignmentCenter;
    
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
        
        [self.refreshDownImageView setImageViewFrame:self.webView.scrollView with:labelSize];
        
        CGPoint upCenter = self.refreshUpImageView.center;
        upCenter.x = self.webView.scrollView.center.x - labelSize.width / 2.0 - 15;
        self.refreshUpImageView.center = upCenter;
        self.refreshUpImageView.hidden = YES;
        self.refreshDownImageView.hidden = YES;
    }
    else {
        //activity for refresh
        _pullDownActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _pullDownActivityView.color = self.configuration.labelTextColor;
        CGRect frame = _pullDownActivityView.frame;
        frame.origin.y =  -25;
        _pullDownActivityView.frame = frame;
        _pullDownActivityView.hidesWhenStopped = YES;
        CGPoint center =_pullDownActivityView.center;
        center.x = self.webView.scrollView.center.x - labelSize.width / 2.0 - 15;
        _pullDownActivityView.center = center;
        
        
        _pullUpActivityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _pullUpActivityView.color = self.configuration.labelTextColor;
        _pullUpActivityView.hidesWhenStopped = YES;
        CGPoint upCenter = _pullUpActivityView.center;
        upCenter.x = self.webView.scrollView.center.x - labelSize.width / 2.0 - 15;
        _pullUpActivityView.center = upCenter;
    }

}

#pragma mark Action
- (IBAction)back:(id)sender {
    _noNetworkView.hidden = self.app.isNetWorkAvailable;

    if (self.isPaypalPage) {
        self.isPaypalPage = NO;
        [self.webView goBack];
        [self.webView goBack];
    } else if (self.isGohome) {
        self.isGohome = NO;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&o=my_order", self.home_url]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [self.webView loadRequest:request];
    } else if (self.isClose) {
        self.isClose = NO;
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.backUrl && self.backUrl.length) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.backUrl]]) {
            NSURL *url =[[NSURL alloc] initWithString:self.backUrl];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            [self.webView loadRequest:request];
        }
        self.backUrl = nil;
    } else if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


//down refresh
- (void)downPullRefresh {
    _noNetworkView.hidden = self.app.isNetWorkAvailable;
    if ([[UIApplication sharedApplication] canOpenURL:self.webView.request.URL]) {
        [self.webView reload];
    } else {
        if (![self.home_url isEqualToString:@""])
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&o=my_order", self.home_url]];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
                [self.webView loadRequest:request];
            }
        }
    }
}

// up refresh
- (void)topPullLoad {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.top_pull_loading(\"\");"]];
    
}

-(void)startUp
{
    CGAffineTransform transform = CGAffineTransformRotate(self.refreshUpImageView.transform, M_PI / 6.0);
    self.refreshUpImageView.transform = transform;
}

-(void)startDown
{
    CGAffineTransform transform = CGAffineTransformRotate(self.refreshDownImageView.transform, M_PI / 6.0);
    self.refreshDownImageView.transform = transform;
    
}

- (void)homePageRefresh
{
    if (!self.isFinishLoad) {
        _noNetworkView.hidden = self.app.isNetWorkAvailable;
        if ([[UIApplication sharedApplication] canOpenURL:self.webView.request.URL]) {
            [self.webView reload];
        } else {
            if (![self.home_url isEqualToString:@""])
            {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&o=my_order", self.home_url]];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
                    [self.webView loadRequest:request];
                }
            }
        }
    }
}

#pragma mark - WebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    _noNetworkView.hidden = self.app.isNetWorkAvailable;

    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:@"myOrder" forKey:@"webView"];
    
    if (!self.authenticated && [requestString rangeOfString:@"https://www"].location != NSNotFound) {
        self.authenticated = NO;
        self.isPaypalPage = YES;
        self.currentRequest = request;
        self.currentConnection = [[NSURLConnection alloc]initWithRequest:self.currentRequest delegate:self startImmediately:YES];
        return NO;
    }
    if ([requestString hasPrefix:@"iosapp:"]) {
        [self changeWebRequest:requestString];
        
    } else if ([requestString hasPrefix:@"weixin:"]) {
        [self weixinPay:requestString];
        
    } else if([requestString hasPrefix:@"alipay:"]){
        [self aliPay:requestString];
       
    } else if([requestString hasPrefix:@"back"]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([requestString rangeOfString:@"htm"].location != NSNotFound) {
        if ([requestString rangeOfString:@"all_orders.htm"].location != NSNotFound) {
            self.isOrderPage = YES;
        } else {
            self.isOrderPage = NO;
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.isFinishLoad = YES;
    self.isScrollerViewRelease = NO;
    self.downRefreshLabel.hidden = YES;
    self.refreshDownImageView.hidden = YES;
    if (self.app.is_vimtag) {
        [self.refreshUpTimer invalidate];
        [self.refreshDownTimer invalidate];
    }
    else {
        [_pullDownActivityView stopAnimating];
        [_pullUpActivityView stopAnimating];
    }

    _isRefreshing = NO;
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _authenticated = YES;
    [self.webView loadRequest:_currentRequest];
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollView.contentOffset.y:%lf", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < -64 ) {
        _upFinishReloadData = NO;
        _downRefreshLabel.hidden = NO;
        if (!_isRefreshing) {
            _isPreviosRefresh = NO;
        }
        if (_downFinishReloadData) {
            _downRefreshLabel.hidden = NO;
            self.refreshDownImageView.hidden = YES;
            _downRefreshLabel.text = NSLocalizedString(@"mcs_load_end", nil);
            if (_pullDownActivityView.isAnimating) {
                [_pullDownActivityView stopAnimating];
            }
            return;
        }
        if (scrollView.contentOffset.y < -84 && !_isScrollerViewRelease ) {
            _downRefreshLabel.hidden = NO;
            self.refreshDownImageView.hidden = YES;
            _downRefreshLabel.text = NSLocalizedString(@"mcs_down_refresh", nil);
        }
        if (scrollView.contentOffset.y  < -114 && !_isScrollerViewRelease){
            _downRefreshLabel.hidden = NO;
            self.refreshDownImageView.hidden = YES;
            _downRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
        }
    }
    if (scrollView.contentOffset.y > -64 && self.isOrderPage) {
        _upRefreshLabel.hidden = NO;
        if (!_isRefreshing) {
            _isPreviosRefresh = YES;
            
        }
        [self collectionViewAddRefreshView];
        
        if (_upFinishReloadData) {
            self.refreshUpImageView.hidden = YES;
            _upRefreshLabel.text = NSLocalizedString(@"mcs_load_end", nil);
            if ([_pullUpActivityView isAnimating]) {
                [_pullUpActivityView stopAnimating];
            }
            return ;
        }
        
        
        if (self.webView.scrollView.contentSize.height > self.webView.scrollView.frame.size.height) {
            if ((self.webView.scrollView.contentSize.height - self.webView.scrollView.frame.size.height) < scrollView.contentOffset.y && !_isScrollerViewRelease) {
                self.refreshUpImageView.hidden = YES;
                _upRefreshLabel .text = NSLocalizedString(@"mcs_pull_refresh_hint", nil);
            }
            if ((self.webView.scrollView.contentSize.height - self.webView.scrollView.frame.size.height + 50) < scrollView.contentOffset.y && !_isScrollerViewRelease) {
                self.refreshUpImageView.hidden = YES;
                _upRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
            }
        }
        else{
            if (scrollView.contentOffset.y > 0 && !_isScrollerViewRelease) {
                self.refreshUpImageView.hidden = YES;
                _upRefreshLabel.text = NSLocalizedString(@"mcs_pull_refresh_hint", nil);
            }
            if (scrollView.contentOffset.y > 50 && !_isScrollerViewRelease) {
                self.refreshUpImageView.hidden = YES;
                _upRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
            }
            
        }
    }
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (_isPreviosRefresh && !_upFinishReloadData && _isOrderPage) {
        if (self.webView.scrollView.contentSize.height > self.webView.scrollView.frame.size.height) {
            
            if ((self.webView.scrollView.contentSize.height - self.webView.scrollView.frame.size.height + 50) < scrollView.contentOffset.y) {
                _isRefreshing = YES;
                _upRefreshLabel.text = NSLocalizedString(@"mcs_refreshing", nil);
                if (self.app.is_vimtag) {
                    [self.refreshUpTimer invalidate];
                    self.refreshUpImageView.hidden = NO;
                    self.refreshUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(startUp) userInfo:nil repeats:YES];
                }else {
                    [_pullUpActivityView startAnimating];
                }
                _isScrollerViewRelease = YES;
                [scrollView setContentOffset:CGPointMake(0, self.webView.scrollView.contentSize.height - self.webView.scrollView.frame.size.height + 40) animated:YES];
                [self performSelector:@selector(topPullLoad) withObject:nil afterDelay:0.3f];
            }
        }
        else{
            if (scrollView.contentOffset.y > 50) {
                _isRefreshing = YES;
                _upRefreshLabel.text = NSLocalizedString(@"mcs_refreshing", nil);
                if (self.app.is_vimtag) {
                    [self.refreshUpTimer invalidate];
                    self.refreshUpImageView.hidden = NO;
                    self.refreshUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(startUp) userInfo:nil repeats:YES];
                }else {
                    [_pullUpActivityView startAnimating];
                }
                _isScrollerViewRelease = YES;
                [scrollView setContentOffset:CGPointMake(0, 40) animated:YES];
                [self performSelector:@selector(topPullLoad) withObject:nil afterDelay:0.3f];
            }
        }
        
    }
    else{
        if (scrollView.contentOffset.y < -114 && !_downFinishReloadData) {
            _isRefreshing = YES;
            _downRefreshLabel.text = NSLocalizedString(@"mcs_refreshing", nil);
            if (self.app.is_vimtag) {
                [self.refreshDownTimer invalidate];
                self.refreshDownImageView.hidden = NO;
                self.refreshDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(startDown) userInfo:nil repeats:YES];
            }else {
                [_pullDownActivityView startAnimating];
            }
            _isScrollerViewRelease = YES;
            [scrollView setContentOffset:CGPointMake(0, -104) animated:YES];
            [self performSelector:@selector(downPullRefresh) withObject:nil afterDelay:0.3f];
        }
    }
    
}

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    if (scrollView.contentOffset.y == _contentOffsetY) {
//        _isScrollerViewRelease = NO;
//        if (self.app.is_vimtag) {
//            [self.refreshUpTimer invalidate];
//            [self.refreshDownTimer invalidate];
//        }
//        else {
//            [_pullDownActivityView stopAnimating];
//            [_pullUpActivityView stopAnimating];
//        }
//    }
//}


#pragma mark - collection add refreshView
-(BOOL)collectionViewAddRefreshView
{
    if (!_upRefreshView) {
        _upRefreshView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    }
    CGRect frame = _upRefreshView.frame;
    if (self.webView.scrollView.contentSize.height > self.webView.scrollView.frame.size.height) {
        frame.origin.y = self.webView.scrollView.contentSize.height + 5;
    }
    else{
        frame.origin.y = self.webView.scrollView .frame.size.height +5;
    }
    _upRefreshView.frame = frame;
    [self.webView.scrollView addSubview:_upRefreshView];
    
    CGPoint labelCentert = _upRefreshLabel.center;
    labelCentert.x = _upRefreshView.frame.size.width / 2;
    _upRefreshLabel.center = labelCentert;
    [_upRefreshView addSubview:_upRefreshLabel];
    if (self.app.is_vimtag) {
        CGPoint activityCenter = self.refreshUpImageView.center;
        activityCenter.y = _upRefreshView.frame.size.height / 2;
        self.refreshUpImageView.center = activityCenter;
        [_upRefreshView addSubview:self.refreshUpImageView];
    }
    else {
        CGPoint activityCenter = _pullUpActivityView.center;
        activityCenter.y = _upRefreshView.frame.size.height / 2;
        _pullUpActivityView.center = activityCenter;
        [_upRefreshView addSubview:_pullUpActivityView];
    }
    return YES;
}


#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(MNWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

#pragma util

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
            
            
            NSString *nativeParam = [[self.jsParam stringByReplacingOccurrencesOfString:@"\"" withString:@"'"]stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.%@(\"%@\");", [self.paramDict objectForKey:@"callback"], nativeParam]];
        }
    } else if([type isEqualToString:@"send_title"]){
        _upFinishReloadData = NO;
        self.navigationItem.title = [self.paramDict objectForKey:@"title"];
     
    } else if ([type isEqualToString:@"get_page_param"]) {
        _upFinishReloadData = NO;
        NSString *back = [self.paramDict objectForKey:@"back_flag"];
        
        if ([back isEqualToString:@"order"]) {
            self.isGohome = YES;
            self.isClose = NO;
        } else if ([back isEqualToString:@"close"]) {
            self.isClose = YES;
            self.isGohome = NO;
        } else if ([back isEqualToString:@"no"]) {
            self.isGohome = NO;
            self.isClose = NO;
        } else if ([back isEqualToString:@"yes"]) {
            self.isGohome = NO;
            self.isClose = NO;
        }
    }
    else if ([type isEqualToString:@"topPullLoadFinish"]) {
         if (_isPreviosRefresh) {
            if (self.webView.scrollView.contentSize.height > self.webView.scrollView.frame.size.height) {
                _contentOffsetY = self.webView.scrollView.contentSize.height - self.webView.scrollView.frame.size.height;
            }else{
                _contentOffsetY = 0;
            }
        }else{
            _contentOffsetY = 0;
        }
        if (_isScrollerViewRelease)
        {
            [self.webView.scrollView setContentOffset:CGPointMake(0, _contentOffsetY) animated:YES];
            
        }
        _isRefreshing = NO;
        
        _isScrollerViewRelease = NO;
        _downRefreshLabel.hidden = YES;
        _upFinishReloadData = NO;
        self.refreshDownImageView.hidden = YES;
        if (self.app.is_vimtag) {
            [self.refreshUpTimer invalidate];
            [self.refreshDownTimer invalidate];
        }
        else {
            [_pullDownActivityView stopAnimating];
            [_pullUpActivityView stopAnimating];
        }

    } else if ([type isEqualToString:@"topPullLoadAllDataFinish"]) {
        if (_isPreviosRefresh) {
            if (self.webView.scrollView.contentSize.height > self.webView.scrollView.frame.size.height) {
                _contentOffsetY = self.webView.scrollView.contentSize.height - self.webView.scrollView.frame.size.height;
            }else{
                _contentOffsetY = 0;
            }
        }else{
            _contentOffsetY = 0;
        }
        if (_isScrollerViewRelease)
        {
            [self.webView.scrollView setContentOffset:CGPointMake(0, _contentOffsetY) animated:YES];
            
        }
        _isRefreshing = NO;
        
        _upFinishReloadData = YES;
        _downRefreshLabel.hidden = YES;
        self.refreshDownImageView.hidden = YES;
        
        _isScrollerViewRelease = NO;
        if (self.app.is_vimtag) {
            [self.refreshUpTimer invalidate];
            [self.refreshDownTimer invalidate];
        }
        else {
            [_pullDownActivityView stopAnimating];
            [_pullUpActivityView stopAnimating];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"no installed weixin" message:@"please install weixin" delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
        [alert show];
    } else if (![WXApi isWXAppSupportApi]){
        NSLog(@"this version don't support");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"this version don't support" message:@"please update new version" delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
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
            [weakSelf.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.get_alipay_mark(\"%@\");", [resultDic objectForKey:@"resultStatus"]]];
        }];
    }
}


#pragma call back
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
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.product.get_wx_mark(\"%d\");", resp.errCode]];

    
}

#pragma mark - Rotate
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
@end

@implementation NSURLRequest(DataController)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end
