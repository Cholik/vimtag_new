//
//  MNPrivacyPolicyViewController.m
//  mipci
//
//  Created by mining on 16/11/23.
//
//

#import "MNPrivacyPolicyViewController.h"
#import "MIPCUtils.h"
#import "AppDelegate.h"

@interface MNPrivacyPolicyViewController ()

@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNPrivacyPolicyViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}
#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title =  NSLocalizedString(@"mcs_privacy_policy", nil);
    
    //No Network
    _noNetworkLabel.text = NSLocalizedString(@"mcs_available_network", nil);
    [_noNetworkButton setTitle:NSLocalizedString(@"mcs_reload", nil) forState:UIControlStateNormal];
    [_noNetworkButton addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
    _noNetworkButton.layer.borderWidth = 1.0;
    _noNetworkButton.layer.cornerRadius = 2.0;
    _noNetworkButton.layer.borderColor = [UIColor colorWithRed:161./255. green:166./255. blue:179./255. alpha:1.0].CGColor;
    _noNetworkView.hidden = self.app.isNetWorkAvailable;

    _progressProxy = [[MNWebViewProgress alloc] init];
    _customWebView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[MNWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initUI];
    
    //load web view
    NSString *u_privacy = [[NSUserDefaults standardUserDefaults] stringForKey:@"u_privacy"];
    
    if (u_privacy.length)
    {
        NSString *urlString = u_privacy;
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
            NSURL *url =[[NSURL alloc] initWithString:urlString];
            NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
            [_customWebView loadRequest:request];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action
- (IBAction)back:(id)sender
{
    _noNetworkView.hidden = self.app.isNetWorkAvailable;
    if ([self.customWebView canGoBack])
    {
        [self.customWebView goBack];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)refresh:(id)sender
{
    _noNetworkView.hidden = self.app.isNetWorkAvailable;
    if ([[UIApplication sharedApplication] canOpenURL:self.customWebView.request.URL]) {
        [self.customWebView reload];
    } else {
        NSString *u_privacy = [[NSUserDefaults standardUserDefaults] stringForKey:@"u_privacy"];
        if (u_privacy.length)
        {
            NSString *urlString = u_privacy;
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
                NSURL *url =[[NSURL alloc] initWithString:urlString];
                NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
                [_customWebView loadRequest:request];
            }
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(MNWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

@end
