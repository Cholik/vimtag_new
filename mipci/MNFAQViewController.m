//
//  MNFAQViewController.m
//  mipci
//
//  Created by mining on 15/11/7.
//
//

#import "MNFAQViewController.h"
#import "MIPCUtils.h"
#import "AppDelegate.h"

@interface MNFAQViewController ()

@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNFAQViewController

- (void)dealloc
{
    
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

#pragma mark - View lifecycle
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)initUI
{
    self.navigationItem.title =  NSLocalizedString(@"mcs_help_feedback", nil);
    //    _customWebView.scalesPageToFit = YES;
    
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

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    
    //load web view
    NSString *faq_url = [[NSUserDefaults standardUserDefaults] stringForKey:@"faq_url"];
    
//    struct mipci_conf *conf = MIPC_ConfigLoad();

    if (faq_url.length)
    {
        NSString *urlString = faq_url;
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
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)refresh:(id)sender
{
    _noNetworkView.hidden = self.app.isNetWorkAvailable;
    if ([[UIApplication sharedApplication] canOpenURL:self.customWebView.request.URL]) {
        [self.customWebView reload];
    } else {
        NSString *faq_url = [[NSUserDefaults standardUserDefaults] stringForKey:@"faq_url"];
        if (faq_url.length)
        {
            NSString *urlString = faq_url;
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

@end
