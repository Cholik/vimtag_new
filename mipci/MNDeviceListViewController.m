//
//  MNDeviceListViewController.m
//  mipci
//
//  Created by weken on 15/2/5.
//
//

#define DEFAULT_LINE_COUNTS       2
#define DEFAULT_CELL_MARGIN       4
#define DEFAULT_EDGE_MARGIN       5
#define DELETE_TAG                1001
#define CHANGEPASSWORD_TAG        1002
#define EXIT_TAG                  1003
#define ADVICE_TAG                1004
#define UPDATE_APP_TAG            1005
#define EXCEPTION_TAG             1006
#define STOP_DIAGNOSIS_TAG        1007
#define ONLINE                    2001
//#define ONLINE_REFRESH          2002
#define EXIT                     @"exit"

#define PROFILE_ID_MAX 2

#import <AudioToolbox/AudioServices.h>
#import "MNDeviceListViewController.h"
#import "MNDeviceViewCell.h"
#import "mipc_agent.h"
#import "MNDeviceTabBarController.h"
#import "MNAddDeviceViewController.h"
#import "MNAppSettingsViewController.h"
#import "MIPCUtils.h"
#import "AppDelegate.h"
#import "MNDevicePlayViewController.h"
#import "MNToastView.h"
#import "MNProgressHUD.h"
#import "MNBoxListViewController.h"
#import "MNSettingsDeviceViewController.h"
#import "MNMessagePageViewController.h"
#import "MNBoxTabBarController.h"
#import "MNModifyPasswordViewController.h"
#import "MNLoginViewController.h"
#import "MNConfiguration.h"
#import "MNGuideNavigationController.h"
#import "MNModifyWIFIViewController.h"
#import "MNInfoPromptView.h"
#import "MNMoreInformationViewController.h"
#import "MNProductInformationViewController.h"
#import "MNRootNavigationController.h"
#import "MNPostAlertView.h"
#import "MNEmptyDevicesListPromptView.h"
#import "MNDeviceListSetViewController.h"
#import "UIImageView+refresh.h"
#import "MNUserBehaviours.h"
#import "MNSynchronizeViewController.h"
#import "MNUncaughtExceptionHandler.h"
#import "MNZipArchive.h"
#import "MNCheckNetworkViewController.h"
#import "MNDiagnosisResultViewController.h"

@interface MNDeviceListViewController ()<NSURLConnectionDataDelegate>
{
    unsigned char encrypt_pwd[16];
    unsigned char login_encrypt_pwd[16];
}

@property (strong, nonatomic) mipc_agent *agent;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (assign, nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) int lastMessageTick;
@property (assign, nonatomic) unsigned int messageSoundID;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSString *currentDeviceID;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (assign, nonatomic) CGSize transitionToSize;
@property (strong, nonatomic) UITextField *devicePasswordTextField;
@property (strong, nonatomic) PopoverView *curVideoSizePopView;
@property (strong, nonatomic) NSArray *settingOptions;
@property (assign, nonatomic) int curProfileID;
@property (strong, nonatomic) NSMutableArray *devicesArray;
@property (weak, nonatomic) MNConfiguration *configuration;

@property (strong, nonatomic) UILabel                 *downRefreshLabel;
@property (strong, nonatomic) UIActivityIndicatorView *pullUpActivityView;
@property (assign, nonatomic) BOOL                    isScrollerViewRelease;

@property (strong, nonatomic) UIWindow      *alertLevelWindow;
@property (assign, nonatomic) BOOL isLoginSuccess;
@property (assign, nonatomic) BOOL isExcutePost;
@property (strong, nonatomic) NSMutableArray *startItemArray;
@property (strong, nonatomic) NSMutableArray *loginItemArray;
@property (strong, nonatomic) NSMutableArray *runningItemArray;
@property (strong, nonatomic) UIPageControl  *pageControl;
@property (strong, nonatomic) NSTimer        *randomTimer;
@property (strong, nonatomic) mcall_ctx_post_get *postGetCtx;
@property (assign, nonatomic) BOOL           isRefreshDataAgain;
@property (strong ,nonatomic) UIImageView *refreshImageView;
@property (strong, nonatomic) NSTimer *refreshTimer;
@property (strong, nonatomic) NSString *appStoreUrl;
@property (strong, nonatomic) NSString *webMobileUrl;
@property (strong, nonatomic) NSString *FilePath;
@property (strong, nonatomic) NSFileHandle *writeHandle;
@property (strong, nonatomic) NSMutableDictionary *playDic;

@end

@implementation MNDeviceListViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)dealloc
{
    [self removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NetworkStatusChange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshDeviceList" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EnterDetailDiagnosis" object:nil];
}

- (NSMutableArray *)devicesArray
{
    if (nil == _devicesArray) {
        _devicesArray = [NSMutableArray array];
    }
    return _devicesArray;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(mipc_agent *)agent
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

-(MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_progressHUD];
        _progressHUD.color = [UIColor colorWithWhite:1.0f alpha:0.8f];
        _progressHUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        _progressHUD.labelText = NSLocalizedString(@"mcs_loading", nil);
        _progressHUD.labelColor = [UIColor grayColor];
        if (self.app.is_vimtag) {
            _progressHUD.activityIndicatorColor = [UIColor colorWithRed:0 green:168.0/255 blue:185.0/255 alpha:1.0f];
        }
        else {
            _progressHUD.activityIndicatorColor = [UIColor grayColor];
        }
    }
    
    return  _progressHUD;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {

    }
    
    return self;
}

-(UIImageView *)refreshImageView
{
    if (_refreshImageView == nil) {
        _refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_vimtagRefresh"]];
    }
    return _refreshImageView;
}

-(NSMutableDictionary *)playDic
{
    if (_playDic == nil) {
        _playDic = [NSMutableDictionary dictionary];
    }
    return _playDic;
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_device_list", nil);
    self.navigationController.navigationBarHidden = NO;
    self.collectionView.alwaysBounceVertical = YES;
    [_emptyPromptView setHidden:YES];
    
    //Init Custom UILabel
    _firstLineLabel.text = NSLocalizedString(@"mcs_empty_cloud_list_first", nil);
    _firstLineLabel.textColor = self.configuration.labelTextColor;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *firstString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"mcs_empty_cloud_list_second", nil)];
    NSMutableAttributedString *secondString= [[NSMutableAttributedString alloc] initWithString:@"\"+\""];
    NSMutableAttributedString *thirdString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"mcs_empty_cloud_list_third", nil)];
    [firstString addAttribute:NSForegroundColorAttributeName value:self.configuration.labelTextColor range:NSMakeRange(0,firstString.length)];
    
    if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        [secondString addAttribute:NSForegroundColorAttributeName value:self.configuration.switchTintColor range:NSMakeRange(0, secondString.length)];
    } else {
        [secondString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:75/255. green:214./255. blue:99./255. alpha:1.0] range:NSMakeRange(0, secondString.length)];
    }
    [thirdString addAttribute:NSForegroundColorAttributeName value:self.configuration.labelTextColor range:NSMakeRange(0, thirdString.length)];
    [attributedString appendAttributedString:firstString];
    [attributedString appendAttributedString:secondString];
    [attributedString appendAttributedString:thirdString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30.0] range:NSMakeRange(firstString.length, secondString.length)];
    _secondLineLabel.attributedText = attributedString;
    _secondLineLabel.numberOfLines = 2;
    _secondLineLabel.textAlignment = NSTextAlignmentCenter;
    
    //NetWork error prompt
    if (self.app.is_vimtag) {
        _detailDiagnosisLabel.hidden = YES;
        _finishDiagnosisButton.hidden = YES;
        self.networkExceptionView.hidden = self.app.isNetWorkAvailable;
        self.networkFailButton.hidden = self.app.isNetWorkAvailable;
        [_networkFailButton setTitle:NSLocalizedString(@"mcs_not_connection_server", nil) forState:UIControlStateNormal];
        _detailDiagnosisLabel.text = NSLocalizedString(@"mcs_detail_diagnosis_stop_prompt", nil);
    } else {
        [_networkUnavailableButton setTitle:NSLocalizedString(@"mcs_available_network", nil) forState:UIControlStateNormal];
        self.networkUnavailableButton.hidden = self.app.isNetWorkAvailable;
    }
    
    //Login interface
    if (self.app.is_vimtag) {
        //Init Custom UIButton
        _userPromptLabel.text = NSLocalizedString(@"mcs_new_user", nil);
        _accountPromptLabel.text = NSLocalizedString(@"mcs_have_account", nil);
        [_registerButton setTitle:NSLocalizedString(@"mcs_sign_up_now", nil) forState:UIControlStateNormal];
        [_feelingButton setTitle:NSLocalizedString(@"mcs_try_it", nil) forState:UIControlStateNormal];
        _feelingButton.layer.cornerRadius = 15.0;
        _feelingButton.layer.borderWidth = 1.0;
        _feelingButton.layer.borderColor = self.configuration.switchTintColor.CGColor;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _ipadLogo.hidden = NO;
            _iphoneLogo.hidden = YES;
        } else {
            _ipadLogo.hidden = YES;
            _iphoneLogo.hidden = NO;
        }
    }
    
    //Refresh
    _downRefreshLabel = [[UILabel alloc] init];
    CGRect downRefreshLabelFrame = _downRefreshLabel.frame;
    downRefreshLabelFrame = CGRectMake(0, -35, 300, 40);
    _downRefreshLabel.frame = downRefreshLabelFrame;
    
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.collectionView.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    
    _downRefreshLabel.font = [UIFont systemFontOfSize:16];
    _downRefreshLabel.textAlignment = NSTextAlignmentCenter;
    _downRefreshLabel.textColor = self.configuration.labelTextColor;
    _downRefreshLabel.hidden = YES;
    
    [_loginButton setTitle:NSLocalizedString(@"mcs_sign_in", nil) forState:UIControlStateNormal];
    
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
        [self.refreshImageView setImageViewFrame:self.collectionView with:labelSize];
    } else {
        //activity for refresh
        _pullUpActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _pullUpActivityView.color = self.configuration.labelTextColor;
        CGRect frame = _pullUpActivityView.frame;
        frame.origin.y =  -25;
        _pullUpActivityView.frame = frame;
        _pullUpActivityView.hidesWhenStopped = YES;
        CGPoint center =_pullUpActivityView.center;
        center.x = self.collectionView.center.x - labelSize.width / 2.0 - 15;
        _pullUpActivityView.center = center;
        //    [self.collectionView addSubview:_pullUpActivityView];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChange:) name:@"NetworkStatusChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"RefreshDeviceList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterDetailDiagnosis:) name:@"EnterDetailDiagnosis" object:nil];
    
    [self initUI];

    if (self.app.is_sereneViewer)
    {
        [self performSegueWithIdentifier:@"MNSereneViewerLoginViewController" sender:nil];
    }
    else if (self.app.is_eyedot)
    {
         [self performSegueWithIdentifier:@"MNEyedotLoginViewController" sender:nil];
    }
    else if (self.app.is_kean || self.app.is_prolab)
    {
        [self performSegueWithIdentifier:@"MNKeanLoginViewController" sender:nil];
    }
    else if (self.app.is_eyeview)
    {
        [self performSegueWithIdentifier:@"MNEyeviewLoginViewController" sender:nil];
    }
    else if (self.app.is_ebitcam || self.app.is_mipc)
    {
    
    }
    else if (!self.app.is_vimtag && !self.app.is_jump)
    {
        [self performSegueWithIdentifier:@"MNLoginViewController" sender:nil];
    }
    else if (!self.app.is_vimtag)
    {
        [self.progressHUD show:YES];
        [self refreshData];
    }
    
    _isViewAppearing = YES;
    _isRefreshing = NO;
    
    if (self.app.is_vimtag) {
        [self autoLogin];
    } else {
        mcall_ctx_dev_msg_listener_add *add = [[mcall_ctx_dev_msg_listener_add alloc] init];
        add.target = self;
        add.on_event = @selector(dev_msg_listener:);
        add.type = @"device,io,motion,alert,snapshot,record";
        [self.agent dev_msg_listener_add:add];
    }
    
    //Unzip web code
    if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
    {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *sourceZipPath = [[[NSBundle mainBundle] pathsForResourcesOfType:@"zip" inDirectory:nil] firstObject];
        NSString * wwwFilePath = [documentPath stringByAppendingPathComponent:[sourceZipPath lastPathComponent]];
        
        if (!((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"wwwFilePath"]) && sourceZipPath) {
            [[NSFileManager defaultManager] copyItemAtPath:sourceZipPath toPath:wwwFilePath error:nil];
            NSString *unzipFilePath = [documentPath stringByAppendingPathComponent:[[wwwFilePath lastPathComponent] stringByDeletingPathExtension]];
            MNZipArchive *zip = [[MNZipArchive alloc]init];
            if ([zip UnzipOpenFile:wwwFilePath])
            {
                [zip UnzipFileTo:unzipFilePath overWrite:YES];
                [zip UnzipCloseFile];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:wwwFilePath forKey:@"wwwFilePath"];
            [[NSUserDefaults standardUserDefaults] setObject:unzipFilePath forKey:@"unzipFilePath"];
            NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
            [[NSUserDefaults standardUserDefaults] setObject:infoDic[@"CFBundleVersion"] forKey:@"webMobileVersion"];
        } else if (sourceZipPath && [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]  caseInsensitiveCompare:[[NSUserDefaults standardUserDefaults] objectForKey:@"webMobileVersion"]] == NSOrderedDescending){
            
            NSString *wwwFilePath = [documentPath stringByAppendingPathComponent: [[[NSUserDefaults standardUserDefaults] objectForKey:@"wwwFilePath"] lastPathComponent]];
            NSString *unzipFilePath = [documentPath stringByAppendingPathComponent: [[[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"] lastPathComponent]];
            
            [[NSFileManager defaultManager] removeItemAtPath:wwwFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:unzipFilePath error:nil];
            
            wwwFilePath = [documentPath stringByAppendingPathComponent:[sourceZipPath lastPathComponent]];
            [[NSFileManager defaultManager] copyItemAtPath:sourceZipPath toPath:wwwFilePath error:nil];
            unzipFilePath = [documentPath stringByAppendingPathComponent:[[wwwFilePath lastPathComponent] stringByDeletingPathExtension]];
            MNZipArchive *zip = [[MNZipArchive alloc]init];
            if ([zip UnzipOpenFile:wwwFilePath])
            {
                [zip UnzipFileTo:unzipFilePath overWrite:YES];
                [zip UnzipCloseFile];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:wwwFilePath forKey:@"wwwFilePath"];
            [[NSUserDefaults standardUserDefaults] setObject:unzipFilePath forKey:@"unzipFilePath"];
            
            NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
            [[NSUserDefaults standardUserDefaults] setObject:infoDic[@"CFBundleVersion"] forKey:@"webMobileVersion"];
        } else {
            NSString *wwwFilePath = [documentPath stringByAppendingPathComponent: [[[NSUserDefaults standardUserDefaults] objectForKey:@"wwwFilePath"] lastPathComponent]];
            NSString *unzipFilePath = [documentPath stringByAppendingPathComponent: [[[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"] lastPathComponent]];
            [[NSUserDefaults standardUserDefaults] setObject:wwwFilePath forKey:@"wwwFilePath"];
            [[NSUserDefaults standardUserDefaults] setObject:unzipFilePath forKey:@"unzipFilePath"];
        }
    }

    //App version get
    if (self.app.is_vimtag || self.app.is_mipc) {
        if ([self isUpDateApp]) {
            [self version_get];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ((self.app.is_ebitcam || self.app.is_mipc) && !self.app.is_userOnline) {
        [self performSegueWithIdentifier:@"MNLoginViewController" sender:nil];
    }
    
    self.app.isLocalDevice = NO;
    self.agent = self.app.cloudAgent;
    struct mipci_conf *conf = MIPC_ConfigLoad();
    [self updateVideoOptions: (conf && ((PROFILE_ID_MAX) >= conf->profile_id))?conf->profile_id:1];
    _transitionToSize = self.view.bounds.size;
    _isViewAppearing = YES;
    [self.collectionView reloadData];
    [_emptyPromptView setHidden:(self.devices.counts || !self.devices ? YES : NO)];

    if (self.app.is_vimtag) {
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"t_a"].length && [[NSUserDefaults standardUserDefaults] stringForKey:@"t_p"].length) {
            _feelingButton.hidden = NO;
        } else {
            _feelingButton.hidden = YES;
        }
        
        [_LoginPromptView setHidden:YES];
        if (self.app.is_userOnline) {
            _LoginPromptView.hidden = YES;            
        }
        else if (conf && !conf->auto_login  && !self.app.is_userOnline)
        {
            _LoginPromptView.hidden = NO;
        }
        else if (!conf)
        {
            _LoginPromptView.hidden = NO;
        }
    }
    
    if (self.app.isLoginByID && !self.app.is_vimtag) {
        [[self.navigationItem.leftBarButtonItems firstObject] setImage:[UIImage imageNamed:@""]];
        [[self.navigationItem.leftBarButtonItems firstObject] setEnabled:NO];
    }
    else if (!self.app.is_vimtag)
    {
        [[self.navigationItem.leftBarButtonItems firstObject] setImage:[UIImage imageNamed:@"item_add"]];
        [[self.navigationItem.leftBarButtonItems firstObject] setEnabled:YES];
    }

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(exitNotice:) name:EXIT object:nil];
    
//    if ([self canFeedback] && self.app.is_vimtag) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"mcs_feedback", nil) message:NSLocalizedString(@"mcs_feedback_des", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) otherButtonTitles:NSLocalizedString(@"mcs_feedback_praise", nil),NSLocalizedString(@"mcs_feedback", nil), nil];
//        alert.tag = ADVICE_TAG;
//        [alert show];
//    }
    
    NSInteger f_log = [[[NSUserDefaults standardUserDefaults] stringForKey:@"f_log"] integerValue];
    NSString *exception = [[NSUserDefaults standardUserDefaults]objectForKey:@"exception"];
    if((f_log > 0) && [exception isEqualToString:@"exception"] ){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"mcs_exception_prompt", nil) message:NSLocalizedString(@"mcs_exception_des", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
        alert.tag = EXCEPTION_TAG;
        [alert show];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIMenuController *popMenuController = [UIMenuController sharedMenuController];
    [popMenuController setMenuVisible:NO animated:YES];

    if (self.app.is_vimtag) {
        [self.refreshTimer invalidate];
    }
    [MNInfoPromptView hideAll:self.navigationController];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
    _isRefreshing = NO;
    
    [self cancelNetworkRequest];
//    [self destoryVideoMegine];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma markviewDidLayoutSubviews
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.collectionView.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    [self.collectionView addSubview:_downRefreshLabel];
    
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
        [self.refreshImageView layoutFrame:self.collectionView with:labelSize];
    }
    else {
        //activity for refresh
        CGPoint center =_pullUpActivityView.center;
        center.x = self.collectionView.center.x - labelSize.width / 2.0 - 15;
        _pullUpActivityView.center = center;
        [self.collectionView addSubview:_pullUpActivityView];
    }
}

#pragma mark -appException
-(void)sendException_log
{
    [self.progressHUD show:YES];
    self.progressHUD.labelText = NSLocalizedString(@"mcs_is_submitting",nil);
    
    NSString *dicPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [dicPath stringByAppendingPathComponent:@"appException"];
    Exception *exception_log = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    mcall_ctx_log_reg *ctx = [[mcall_ctx_log_reg alloc] init];
    ctx.target = self;
    ctx.mode = exception_log.mode;
    ctx.exception_name = exception_log.exception_name;
    ctx.exception_reason = exception_log.exception_reason;
    ctx.call_stack = exception_log.call_stack;
    ctx.log_type = @"iosApp_crash";
    ctx.on_event = @selector(log_req_done:);
    [self.agent log_req:ctx];
}

-(void)log_req_done:(mcall_ret_log_reg *)ret
{

    //if (!ret.result) {
     
        [[NSUserDefaults standardUserDefaults]setObject:@"noException" forKey:@"exception"];
        [[NSUserDefaults standardUserDefaults]synchronize];
//    }
//    else if([ret.result isEqualToString:@"ret.no.rsp"]){
//        NSLog(@"ret.no.rsp");
//    }
    [self.progressHUD hide:YES];
}

#pragma mark -judge can feedback
-(BOOL)canFeedback
{
    //return YES;
    NSUInteger can_feedback = [[[NSUserDefaults standardUserDefaults] stringForKey:@"f_ticket"] integerValue];
    if ((can_feedback <=0) || !(self.app.is_vimtag)) {
        return NO;
    }
    
    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
    MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    float login_succ_ratio;
    float refresh_succ_ratio;
    float play_succ_ratio;
    float snap_succ_ratio;
    float replay_succ_ratio;
    float add_succ_ratio;
    float wfc_succ_ratio;
    if (behaViours.login_succ_times > 0) {
         login_succ_ratio = (float) behaViours.login_succ_times /(behaViours.login_succ_times + behaViours.login_fail_times);
    }
    else{
        login_succ_ratio = 0.0f;
    }
    if (behaViours.devs_refresh_succ_times > 0) {
        refresh_succ_ratio = (float) behaViours.devs_refresh_succ_times /(behaViours.devs_refresh_succ_times + behaViours.devs_refresh_fail_times);
    }
    else{
        refresh_succ_ratio = 0.0f;
    }
    if (behaViours.dev_play_succ_times > 0) {
        play_succ_ratio = (float) (behaViours.dev_play_succ_times )/(behaViours.dev_play_succ_times + behaViours.dev_play_fail_times);
    }
    else{
        play_succ_ratio = 0.0f;
    }
    if (behaViours.dev_snaps_succ_times > 0) {
        snap_succ_ratio =  (float)(behaViours.dev_snaps_succ_times )/(behaViours.dev_snaps_succ_times + behaViours.dev_snaps_fail_times);
    }
    else{
        snap_succ_ratio = 0.0f;
    }
    if (behaViours.dev_replay_succ_times > 0) {
        replay_succ_ratio = (float) behaViours.dev_replay_succ_times /(behaViours.dev_replay_succ_times + behaViours.dev_replay_fail_tiems);
    }
    else{
        replay_succ_ratio = 0.0f;
    }
    if (behaViours.dev_add_succ_times > 0) {
        add_succ_ratio = (float) behaViours.dev_add_succ_times /(behaViours.dev_add_succ_times + behaViours.dev_add_fail_times);
    }
    else{
        add_succ_ratio = 0.0f;
    }
    if (behaViours.dev_add_wfc_succ_times > 0) {
        wfc_succ_ratio = (float) behaViours.dev_add_wfc_succ_times /(behaViours.dev_add_wfc_succ_times + behaViours.dev_add_wfc_fail_times);
    }
    else{
        wfc_succ_ratio = 0.0f;
    }
    
    if (behaViours.last_feedback_time != 0) {
        if ((behaViours.last_time - behaViours.last_feedback_time) >= 24*60*60*30) {
            if ((login_succ_ratio > 0.95) && (refresh_succ_ratio > 0.95) && (play_succ_ratio > 0.95) && (snap_succ_ratio > 0.95) && (replay_succ_ratio > 0.95) && (add_succ_ratio > 0.95) && (wfc_succ_ratio > 0.95)) {
                behaViours.last_feedback_time = [[NSDate date]timeIntervalSince1970];
                [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
                return YES;
            }
        }
    }
    else{
        if ((behaViours.last_time - behaViours.start_time) >= 24*60*60*15) {
            if ((login_succ_ratio > 0.95) && (refresh_succ_ratio > 0.95) && (play_succ_ratio > 0.95) && (snap_succ_ratio > 0.95) && (replay_succ_ratio > 0.95) && (add_succ_ratio > 0.95) && (wfc_succ_ratio > 0.95)) {
                behaViours.last_feedback_time = [[NSDate date]timeIntervalSince1970];
                [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark  -Get App version
-(BOOL)isUpDateApp
{
    NSInteger canUp = [[[NSUserDefaults standardUserDefaults] stringForKey:@"f_ota"] integerValue];
    if (canUp <= 0) {
        return NO;
    }
    
    double lastUpDateTime = [[[NSUserDefaults standardUserDefaults]objectForKey:@"last_update_time"]doubleValue];
    if (!lastUpDateTime) {
        return YES;
    }else if([[NSDate date]timeIntervalSince1970] >= (lastUpDateTime + 7 * 24 * 60 * 60)){
        return YES;
    }
    
    return NO;
}

-(void)version_get
{
    NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
    
    mcall_ctx_version_get *ctx = [[mcall_ctx_version_get alloc]init];
   
    
    if (self.app.is_vimtag) {
        ctx.appid = @"ios_vimtag";
    } else if (self.app.is_mipc) {
        ctx.appid = @"ios_mipc";
    }
    
    //ctx.appid = infoDic[@"CFBundleIdentifier"];
    ctx.appVersion = infoDic[@"CFBundleVersion"];
    ctx.lang = infoDic[@"CFBundleDevelopmentRegion"];
    ctx.target = self;
    ctx.on_event = @selector(app_version_get_done:);
    
    [self.agent version_get:ctx];
}

- (void)webVersionGet
{
    NSString *web_mode = [[NSUserDefaults standardUserDefaults] stringForKey:@"f_web"];
    if ((self.app.developerOption.webSwitch || web_mode.length) && !self.app.developerOption.webMobileOriginSwitch) {
        NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
        mcall_ctx_version_get *ctx = [[mcall_ctx_version_get alloc]init];
        
        ctx.appid = self.app.is_vimtag ? @"web_mobile" : self.app.is_ebitcam ? @"web_mobile_ebit" : @"web_mobile_mipc";
        ctx.appVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"webMobileVersion"]
        ;
        ctx.lang = infoDic[@"CFBundleDevelopmentRegion"];
        ctx.target = self;
        ctx.on_event = @selector(web_mobile_version_get_done:);
        
        [self.agent version_get:ctx];
    }  else if (self.app.developerOption.webMobileOriginSwitch) {
        NSString *wwwFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"wwwFilePath"];
        NSString *unzipFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"];
        [[NSFileManager defaultManager] removeItemAtPath:wwwFilePath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:unzipFilePath error:nil];
        
        NSString *sourceZipPath = [[[NSBundle mainBundle] pathsForResourcesOfType:@"zip" inDirectory:nil] firstObject];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSError *error;
        wwwFilePath = [documentPath stringByAppendingPathComponent:[sourceZipPath lastPathComponent]];
        unzipFilePath = [documentPath stringByAppendingPathComponent:[[sourceZipPath lastPathComponent] stringByDeletingPathExtension]];
        [[NSFileManager defaultManager] copyItemAtPath:sourceZipPath toPath:wwwFilePath error:&error];
        
        MNZipArchive *zip = [[MNZipArchive alloc] init];
        if ([zip UnzipOpenFile:wwwFilePath])
        {
            [zip UnzipFileTo:unzipFilePath overWrite:YES];
            [zip UnzipCloseFile];
        }
        [[NSUserDefaults standardUserDefaults] setObject:wwwFilePath forKey:@"wwwFilePath"];
        [[NSUserDefaults standardUserDefaults] setObject:unzipFilePath forKey:@"unzipFilePath"];
        NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
        [[NSUserDefaults standardUserDefaults] setObject:infoDic[@"CFBundleVersion"] forKey:@"webMobileVersion"];
    }

}

-(void)app_version_get_done:(mcall_ret_version_get *)ret
{
    NSString *appVersion = [NSString stringWithFormat:@"%@",ret.info[@"ver_to"]];
    //    NSString *appDesc = ret.info[@"desc"];
    NSString *currentVersion = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
    
    if (ret.result == nil && appVersion)
    {
        appVersion = [appVersion stringByReplacingOccurrencesOfString:@"v" withString:@""];
        appVersion = [appVersion stringByReplacingOccurrencesOfString:@"V" withString:@""];
        
        NSArray *appArray = [appVersion componentsSeparatedByString:@"."];
        NSArray *curArray = [currentVersion componentsSeparatedByString:@"."];
        
        long count = appArray.count > curArray.count ? curArray.count : appArray.count;
        
        for (int i = 0; i < count - 1; i++)
        {
            NSString *appString = [NSString stringWithFormat:@"%@",[appArray objectAtIndex:i]];
            NSString *curString = [NSString stringWithFormat:@"%@",[curArray objectAtIndex:i]];
            if (appString.intValue > curString.intValue) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ v%@",NSLocalizedString(@"mcs_app_new_version", nil),appVersion]  message:NSLocalizedString(@"mcs_app_new_version_prompt", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) otherButtonTitles: NSLocalizedString(@"mcs_update_new_version", nil),nil];
                alert.tag = UPDATE_APP_TAG;
                [alert show];
                
                [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%lf",[[NSDate date]timeIntervalSince1970] ]forKey:@"last_update_time"];
                break;
            } else if (appString.intValue < curString.intValue) {
                break;
            }
        }
    }
}

-(void)web_mobile_version_get_done:(mcall_ret_version_get *)ret
{
    NSString *webMobileVersion = [NSString stringWithFormat:@"%@", ret.info[@"ver_to"]];
    if (webMobileVersion.length) {
        int i = 0;
        for ( ; i < webMobileVersion.length; i++) {
            NSString *temp = [webMobileVersion substringWithRange:NSMakeRange(i, 1)];
            if ([self predicateString:temp regex:@"^[0-9]*$"]) {
                webMobileVersion = [webMobileVersion substringFromIndex:i];
                break;
            }
        }
    }

    NSString *currentWebMobileVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"webMobileVersion"];
    self.webMobileUrl = ret.info[@"link_url"];
    if (ret.result == nil && ([webMobileVersion caseInsensitiveCompare:currentWebMobileVersion] == NSOrderedDescending))
    {

        NSURL *url = [NSURL URLWithString:self.webMobileUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection connectionWithRequest:request delegate:self];
        
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%lf",[[NSDate date]timeIntervalSince1970] ]forKey:@"last_update_time"];
    }
}

- (BOOL)predicateString:(NSString*)text regex:(NSString*)regex
{
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",regex];
    return [userPredicate evaluateWithObject:text];
}

#pragma mark - Action
-(void)destoryVideoMegine
{
    for (int i = 0; i < self.devices.counts; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        MNDeviceViewCell *cell = (MNDeviceViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell mediaEndPlay];
    }
}
- (IBAction)addDevice:(id)sender
{
    UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
    MNGuideNavigationController *guideNavigationController;
    if (self.app.is_ebitcam) {
        guideNavigationController = [[guideStoryboard instantiateViewControllerWithIdentifier:@"MNGuideNavigationController"] initWithRootViewController:[guideStoryboard instantiateViewControllerWithIdentifier:@"MNWebAddDeviceViewController"]];
    } else if (self.app.is_mipc) {
        NSString *web_mode = [[NSUserDefaults standardUserDefaults] stringForKey:@"f_web"];
        if (self.app.developerOption.webSwitch) {
            guideNavigationController = [[guideStoryboard instantiateViewControllerWithIdentifier:@"MNGuideNavigationController"] initWithRootViewController:[guideStoryboard instantiateViewControllerWithIdentifier:@"MNWebAddDeviceViewController"]];
        } else if (self.app.developerOption.nativeSwitch) {
            guideNavigationController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNGuideNavigationController"];
        } else if (web_mode.length) {
            guideNavigationController = [[guideStoryboard instantiateViewControllerWithIdentifier:@"MNGuideNavigationController"] initWithRootViewController:[guideStoryboard instantiateViewControllerWithIdentifier:@"MNWebAddDeviceViewController"]];
        } else {
            guideNavigationController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNGuideNavigationController"];
        }
    } else {
        guideNavigationController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNGuideNavigationController"];
    }
    [self presentViewController:guideNavigationController animated:YES completion:nil];
}

- (IBAction)setupApp:(id)sender
{
    if (self.app.is_vimtag) {
        [self performSegueWithIdentifier:@"MNAppSettingsViewController" sender:nil];
    } else if (self.app.is_ebitcam || self.app.is_mipc) {
        [self performSegueWithIdentifier:@"MNMoreOptionsTableViewController" sender:nil];
    } else {
        //[self performSegueWithIdentifier:@"MNAppSettingsViewController" sender:nil];
        float screenWidth = self.view.bounds.size.width;
        float itemWidth = ((UIBarButtonItem*)sender).width;
        float itemX = screenWidth - itemWidth ;
        CGPoint point = CGPointMake(itemX + itemWidth / 2,  -8);
        self.curVideoSizePopView = [PopoverView showPopoverAtPoint:point inView:self.view withTitle:NSLocalizedString(@"mcs_set_video_size",nil) withStringArray:_settingOptions delegate:self];
        [self.curVideoSizePopView.helpButton addTarget:self action:@selector(jumpFAQ) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)jumpFAQ
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://pyleaudio.helpshift.com/a/serene-life/"]];
}


- (void)exit
{
    if (self.app.is_jump) {
        
        NSString *url = [self.app.fromTarget stringByAppendingString:@"://"];
        if (url) {
            {
                mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init] ;
                ctx.target = self;
                ctx.on_event = nil;
                
                [self.agent sign_out:ctx];
                self.app.is_jump = NO;
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                
                if (self.app.is_sereneViewer)
                {
                    [self performSegueWithIdentifier:@"MNSereneViewerLoginViewController" sender:nil];
                }
                else if (self.app.is_eyedot)
                {
                    [self performSegueWithIdentifier:@"MNEyedotLoginViewController" sender:nil];
                }
                else if (self.app.is_kean || self.app.is_prolab)
                {
                    [self performSegueWithIdentifier:@"MNKeanLoginViewController" sender:nil];
                }
                else if (self.app.is_eyeview)
                {
                    [self performSegueWithIdentifier:@"MNEyeviewLoginViewController" sender:nil];
                }
                else if (!self.app.is_vimtag)
                {
                    [self performSegueWithIdentifier:@"MNLoginViewController" sender:nil];
                }
            }
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt_exit", nil)
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"mcs_exit", nil), nil];
        alertView.tag = EXIT_TAG;
        [alertView show];
    }
}

-(void)sign_out_done:(mcall_ret_sign_out*)ret
{
    if (ret.result != nil) {
        
        return;
    }
    struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
    
    if(conf)
    {
        conf_new  = *conf;
    }
    conf_new.auto_login = NO;
    MIPC_ConfigSave(&conf_new);
//    [self performSegueWithIdentifier:@"MNLoginViewController" sender:nil];
}

- (void)refreshData
{

//    [self destoryVideoMegine];
    if (!_isRefreshing)
    {
        [self removeObserver];
        
        mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
        ctx.target = self;
        ctx.on_event = @selector(devs_refresh_done:);
        
        //Get device list refresh
        [self.agent devs_refresh:ctx];
        _isRefreshing = YES;
    }
}

- (void)removeAllData
{
    if ([self.devicesArray lastObject]) {
        [self removeObserver];
    }
    self.devices = nil;
    [self.collectionView reloadData];
}

- (void)onMenuItemPlay:(id)sender
{
    if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
//        [self setupAnimation];
        [self performSegueWithIdentifier:@"MNDevicePlayViewController" sender:nil];
    }else{
        [self performSegueWithIdentifier:@"MNDeviceTabBarController" sender:[NSNumber numberWithInt:0]];
    }
}

- (void)onMenuItemMessage:(id)sender
{
    if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        [self performSegueWithIdentifier:@"MNMessagePageViewController" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"MNDeviceTabBarController" sender:[NSNumber numberWithInt:1]];
    }
}

-(void)onMenuItemSetting:(id)sender
{
    m_dev *dev = [self.agent.devs get_dev_by_sn:_currentDeviceID];
    if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
//        [self setupAnimation];
        [self performSegueWithIdentifier:@"MNSettingsDeviceViewController" sender:nil];
    } else if (![dev.type isEqualToString:@"BOX"]){
        [self performSegueWithIdentifier:@"MNDeviceTabBarController" sender:[NSNumber numberWithInt:2]];
    } else {
        [self performSegueWithIdentifier:@"MNBoxTabBarController" sender:[NSNumber numberWithInt:1]];
    }
}

- (void)onMenuItemSettingBox:(id)sender
{
    [self performSegueWithIdentifier:@"MNSettingsDeviceViewController" sender:_currentDeviceID];
}

- (void)onMenuItemBoxList:(id)sender
{
    if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        [self performSegueWithIdentifier:@"MNBoxListViewController" sender:_currentDeviceID];
    } else {
        [self performSegueWithIdentifier:@"MNBoxTabBarController" sender:_currentDeviceID];
    }
}

- (void)onMenuItemDelete:(id)sender
{
    NSString *info = [NSLocalizedString(@"mcs_delete_camera",nil) stringByAppendingFormat:@"%@?", _currentDeviceID];
    UIAlertView *deleteAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                              message:info
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                                    otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
    deleteAlertView.tag = DELETE_TAG;
    [deleteAlertView show];
  
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && !self.app.disableModifyUserSetting)
    {
        _currentDeviceID = ((MNDeviceViewCell*)recognizer.view).deviceID;
        m_dev *dev = [self.agent.devs get_dev_by_sn:_currentDeviceID];
        
        [recognizer.view becomeFirstResponder];
        CGPoint point = [recognizer locationInView:recognizer.view];
        
        UIMenuController *popMenuController = [UIMenuController sharedMenuController];
        
        UIMenuItem *palyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"mcs_play",nil) action:@selector(onMenuItemPlay:)];
        UIMenuItem *messageMuneItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"mcs_messages",nil) action:@selector(onMenuItemMessage:)];
        UIMenuItem *settingMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"mcs_settings",nil) action:@selector(onMenuItemSetting:)];
        UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"mcs_delete",nil) action:@selector(onMenuItemDelete:)];
        
        NSArray *menuItemArray;
        if (dev && (NSOrderedSame == [dev.status caseInsensitiveCompare:@"online"]))
        {
            if (dev.img_ver && (NSOrderedAscending != [dev.img_ver caseInsensitiveCompare:MIPC_MIN_VERSION_DEVICE_PICK]))
            {
                menuItemArray = [NSArray arrayWithObjects:palyMenuItem, messageMuneItem, settingMenuItem, deleteMenuItem, nil];
            }
            else
            {
                menuItemArray = [NSArray arrayWithObjects:palyMenuItem, settingMenuItem, deleteMenuItem, nil];
            }
           
        }
        else
        {
             menuItemArray = [NSArray arrayWithObjects:settingMenuItem, deleteMenuItem, nil];
        }
        
        if(dev && (NSOrderedSame == [dev.type caseInsensitiveCompare:@"BOX"]))
        {
            menuItemArray = [NSArray arrayWithObjects:settingMenuItem, deleteMenuItem, nil];

        }
        
        [popMenuController setMenuItems:menuItemArray];
       
        [popMenuController setArrowDirection:UIMenuControllerArrowDown];
        [popMenuController setTargetRect:CGRectMake(point.x, point.y, 0, 0) inView:recognizer.view];
        [popMenuController setMenuVisible:YES animated:YES];
    }
}


- (void)exitNotice:(id)sender
{
    struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
    
    if(conf)
    {
        conf_new  = *conf;
    }
    conf_new.auto_login = NO;
    MIPC_ConfigSave(&conf_new);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXIT object:nil];
    [self performSegueWithIdentifier:@"MNLoginViewController" sender:nil];
}

- (void)networkStatusChange:(NSNotification *)notificationName
{
    if (self.app.is_vimtag) {
        _detailDiagnosisLabel.hidden = YES;
        _finishDiagnosisButton.hidden = YES;
        self.networkExceptionView.hidden = self.app.isNetWorkAvailable;
        self.networkFailButton.hidden = self.app.isNetWorkAvailable;
        
        if (self.app.isNetWorkAvailable && self.app.startSaveLog)
        {
            _detailDiagnosisLabel.hidden = NO;
            _finishDiagnosisButton.hidden = NO;
            self.networkExceptionView.hidden = NO;
        }
    } else {
        self.networkUnavailableButton.hidden = self.app.isNetWorkAvailable;
    }
}

- (void)enterDetailDiagnosis:(NSNotification *)notificationName
{
    if (self.app.is_vimtag) {
        NSString *string = [NSString stringWithFormat:@"%@",[notificationName object]];
        if ([string isEqualToString:@"StopDetailDiagnosis"]) {
            //End Save Log Flag
            self.app.startSaveLog = NO;
            
            _detailDiagnosisLabel.hidden = YES;
            _finishDiagnosisButton.hidden = YES;
            self.networkExceptionView.hidden = self.app.isNetWorkAvailable;
            self.networkFailButton.hidden = self.app.isNetWorkAvailable;
        } else {
            _networkExceptionView.hidden = NO;
            _detailDiagnosisLabel.hidden = NO;
            _finishDiagnosisButton.hidden = NO;
            _networkFailButton.hidden = YES;
        }
    }
}

- (IBAction)finishDiagnosis:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_exit_detail_diagnosis", nil)
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"mcs_no_verif", nil)
                                              otherButtonTitles:NSLocalizedString(@"mcs_yes_verif", nil), nil];
    alertView.tag = STOP_DIAGNOSIS_TAG;
    [alertView show];
    
//    //End Save Log Flag
//    self.app.startSaveLog = NO;
//    
//    _detailDiagnosisLabel.hidden = YES;
//    _finishDiagnosisButton.hidden = YES;
//    self.networkExceptionView.hidden = self.app.isNetWorkAvailable;
//    self.networkFailButton.hidden = self.app.isNetWorkAvailable;
//    //send log
//    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"NetworkRequest/NetworkRequest.txt"]];
//    
//    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
//    NSString *log = [NSString stringWithContentsOfFile:filePath usedEncoding:nil error:nil];
//    [fileHandle closeFile];
//    
//    mcall_ctx_log_reg *ctx = [[mcall_ctx_log_reg alloc] init];
//    ctx.target = self;
//    ctx.mode = [MNUncaughtExceptionHandler getCurrentDeviceModel];
//    ctx.exception_name = @"ios_request_log";
//    ctx.exception_reason = @"Detail diagnosis";
//    ctx.call_stack = log;
//    ctx.log_type = @"ios_request_log";
//    ctx.on_event = @selector(log_req_send_done:);
//    [self.agent log_req:ctx];
}

//-(void)log_req_send_done:(mcall_ret_log_reg *)ret
//{
//    if (nil == ret.result) {
//        
//    }
//}

- (IBAction)toNetworkFailView:(id)sender
{
    if (!self.app.isNetWorkAvailable) {
        //Show the content ask user to check network
        MNCheckNetworkViewController *checkNetworkViewController = [[UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"MNCheckNetworkViewController"];
        MNGuideNavigationController *navigationController = [[MNGuideNavigationController alloc] initWithRootViewController:checkNetworkViewController];
        //        [self pushViewController:checkNetworkViewController animated:YES];
        [self presentViewController:navigationController animated:YES completion:nil];
    } else if ([[NSUserDefaults standardUserDefaults] stringForKey:@"f_log"].length){
        //Enter diagnosis
        
    }
}

- (IBAction)setNetwork:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"prefs:root"];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - becomeFirstresponer
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (((action == @selector(onMenuItemPlay:))
         || (action == @selector(onMenuItemMessage:))
         || (action == @selector(onMenuItemSetting:))
         || (action == @selector(onMenuItemSettingBox:))
         || (action == @selector(onMenuItemBoxList:))
         || (action == @selector(onMenuItemDelete:)))
        )
    {
        if(self.app.isLoginByID && (action == @selector(onMenuItemDelete:)))
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - InterfaceOrientation

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.app.is_vimtag) {
       return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIDeviceOrientationLandscapeLeft | UIDeviceOrientationLandscapeRight | UIDeviceOrientationPortrait;
//}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    if(_curVideoSizePopView)
    {
        [_curVideoSizePopView dismiss];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //    [self updateCollectionViewFlowLayout];
    [self.collectionView reloadData];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if(_curVideoSizePopView)
    {
        [_curVideoSizePopView dismiss];
    }
    _transitionToSize = size;
    [self.collectionView reloadData];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNDeviceTabBarController"])
    {
        MNDeviceTabBarController *deviceTabBarController = segue.destinationViewController;
        deviceTabBarController.deviceID = _currentDeviceID;
        deviceTabBarController.deviceListViewController = self;
        deviceTabBarController.selectedIndex = [sender integerValue];
    }
    else if ([segue.identifier isEqualToString:@"MNDevicePlayViewController"])
    {
        MNDevicePlayViewController *devicePlayViewController = segue.destinationViewController;
        devicePlayViewController.deviceID = _currentDeviceID;
    }
    else if ([segue.identifier isEqualToString:@"MNBoxListViewController"])
    {
        MNBoxListViewController *boxListViewController = segue.destinationViewController;
        boxListViewController.boxID = sender;
//        self.listPageViewController.navigationController.navigationBarHidden = NO;
    }
    else if ([segue.identifier isEqualToString:@"MNBoxTabBarController"])
    {
        MNBoxTabBarController *boxTabBarController = segue.destinationViewController;
        boxTabBarController.boxID = _currentDeviceID;
        boxTabBarController.selectedIndex = [sender integerValue];
    }
    else if ([segue.identifier isEqualToString:@"MNSettingsDeviceViewController"])
    {
        MNSettingsDeviceViewController *settingsDeviceViewController = segue.destinationViewController;
        settingsDeviceViewController.deviceID = _currentDeviceID;
        settingsDeviceViewController.deviceListViewController = self;
    }
    else if ([segue.identifier isEqualToString:@"MNMessagePageViewController"])
    {
        MNMessagePageViewController *messagePageViewController = segue.destinationViewController;
        messagePageViewController.deviceID = _currentDeviceID;
    }
    else if ([segue.identifier isEqualToString:@"MNQRCodeViewController"])
    {
//        MNQRCodeViewController *qrCodeViewController = segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:@"MNModifyPasswordViewController"])
    {
        MNModifyPasswordViewController *modifyPasswordviewController = segue.destinationViewController;
        modifyPasswordviewController.deviceID = _currentDeviceID;
        modifyPasswordviewController.oldPassword = _devicePasswordTextField.text;
        modifyPasswordviewController.is_notAdd = YES;
    }
    else if ([segue.identifier isEqualToString:@"MNSynchronizeViewController"])
    {
        MNSynchronizeViewController *synchronizeViewController = segue.destinationViewController;
        synchronizeViewController.deviceListSetViewController = self.deviceListSetViewController;
        synchronizeViewController.selectSceneName = self.selectSceneName;
        synchronizeViewController.devices = self.devices;
        synchronizeViewController.agent = self.agent;
    }
}

#pragma mark - Utils
-(MNDeviceViewCell*)getCollectionViewCell:(NSString*)deviceID
{
    NSArray *subviews = self.collectionView.subviews;
    for (UIView *view in subviews) {
        if ([view isMemberOfClass:[MNDeviceViewCell class]]) {
            if ([((MNDeviceViewCell*)view).deviceID isEqualToString:deviceID]) {
                return (MNDeviceViewCell*)view;
            }
        }
    }
    
    return nil;
}

-(void)cancelNetworkRequest
{
    for (UIView *view in self.collectionView.subviews) {
        if ([view isMemberOfClass:[MNDeviceViewCell class]]) {
            MNDeviceViewCell *cell = (MNDeviceViewCell*)view;
            if ([cell respondsToSelector:@selector(cancelNetworkRequest)]) {
                [cell performSelector:@selector(cancelNetworkRequest)];
            }
        }
    }
}

#pragma mark - Network callback
- (void)devs_refresh_done:(mcall_ret_devs_refresh*)ret
{
    _isRefreshing = NO;
    if (_isScrollerViewRelease)
    {
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
//    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
    
    if (nil != ret.result)
    {
        if (self.app.is_jump && !self.isRefreshDataAgain)
        {
             [self performSelector:@selector(refreshData) withObject:nil afterDelay:1.0f];
        }
        else
        {
//            MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//            behaViours.devs_refresh_fail_times += 1;
//            BOOL isRight = [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
            
            //FIXME:
            [self.progressHUD hide:YES];
//            if ([ret.result isEqualToString:@"ret.no.rsp"])
//            {
//                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_access_server_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
//            }
        }
        if (self.app.developerOption.automationSwitch && _isViewAppearing) {
            [MNInfoPromptView showAndHideWithText:ret.result style:MNInfoPromptViewStyleAutomation isModal:NO navigation:self.navigationController];
        }
        
        return;
    }
   [self.progressHUD hide:YES];
    //test
    if (self.app.developerOption.automationSwitch && _isViewAppearing) {
        [MNInfoPromptView showAndHideWithText:@"Refresh success" style:MNInfoPromptViewStyleAutomation isModal:NO navigation:self.navigationController];
    }
    
//    MNUserBehaviours *behaViours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//    behaViours.devs_refresh_succ_times += 1;
//    BOOL isRight = [NSKeyedArchiver archiveRootObject:behaViours toFile:filePath];
    
    self.devices = ret.devs;
    [self.collectionView reloadData];
    [_emptyPromptView setHidden:(self.devices.counts ? YES : NO)];
    if (self.app.is_vimtag) {
        for (UIViewController *viewController in self.navigationController.viewControllers) {
            if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                MNDeviceListSetViewController *deviceListSetViewController = (MNDeviceListSetViewController *)viewController;
                [deviceListSetViewController refreshCurrentScene];
            }
        }
    }
}

- (void)dev_del_done:(mcall_ret_dev_del*)ret
{
    [self.progressHUD hide:YES];
    _progressHUD.labelText = NSLocalizedString(@"mcs_loading", nil);
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil != ret.result) {
        if ([ret.result isEqualToString:@"ret.permission.denied"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_permission_denied", nil)]];
            }
        } else if ([ret.result isEqualToString:@"ret.no.rsp"]){
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_access_server_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_access_server_failed", nil)]];
            }
        } else {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_remove_equipment_failure", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_remove_equipment_failure", nil)]];
            }
        }
    }
    else
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_success_removed_equipment", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_success_removed_equipment", nil)]];
        }
        //refresh cell
        self.devices = ret.devs;
        [self.collectionView reloadData];
        [_emptyPromptView setHidden:(self.devices.counts || !self.devices ? YES : NO)];
    }
}

- (void)dev_add_done:(mcall_ret_dev_add*)ret
{
    [self.progressHUD hide:YES];
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil == ret.result)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           if (weakSelf.devicePasswordTextField.text.length > 0 && weakSelf.devicePasswordTextField.text.length < 6)
                           {
//                               UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
//                               MNModifyPasswordViewController *modifyPasswordViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNModifyPasswordViewController"];
//                               modifyPasswordViewController.deviceID = _currentDeviceID;
//                               modifyPasswordViewController.oldPassword = _devicePasswordTextField.text;
//                               modifyPasswordViewController.is_notAdd = YES;
//                               modifyPasswordViewController.deviceListViewController = self.listPageViewController;
//
//                               [self.navigationController pushViewController:modifyPasswordViewController animated:YES];
                               
                               UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
                               MNModifyPasswordViewController *modifyPasswordViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNModifyPasswordViewController"];
                               MNGuideNavigationController *guideNavigationController = [[MNGuideNavigationController alloc] initWithRootViewController:modifyPasswordViewController];
                               modifyPasswordViewController.deviceID = _currentDeviceID;
                               modifyPasswordViewController.oldPassword = _devicePasswordTextField.text;
                               modifyPasswordViewController.is_notAdd = YES;
//                               modifyPasswordViewController.deviceListViewController = self.listPageViewController;
                               [self presentViewController:guideNavigationController animated:YES completion:nil];
                           }
                           
                       });
        
    }

    if (nil != ret.result) {
        //FIXME:change password
        if ([ret.result isEqualToString:@"ret.permission.denied"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_permission_denied", nil)]];
            }
        }
        if ([ret.result isEqualToString:@"ret.pwd.invalid"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_password", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_invalid_password", nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_failed_to_set_the", nil)]];
            }
        }
        return;
    }
    
    //refresh devices
    [self refreshData];
}

- (void)sign_in_done:(mcall_ret_sign_in*)ret
{
    [self.progressHUD hide:YES];
    if (!_isViewAppearing) {
        return;
    }
    if (nil == ret.result)
    {            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(1 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               if (weakSelf.devicePasswordTextField.text.length > 0 && weakSelf.devicePasswordTextField.text.length < 6)
                               {
//                                   UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
//                                   MNModifyPasswordViewController *modifyPasswordViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNModifyPasswordViewController"];
//                                   modifyPasswordViewController.deviceID = _currentDeviceID;
//                                   modifyPasswordViewController.oldPassword = _devicePasswordTextField.text;
//                                   modifyPasswordViewController.is_notAdd = YES;
//                                   modifyPasswordViewController.deviceListViewController = self;
//                                   [self.navigationController pushViewController:modifyPasswordViewController animated:YES];
                                   
                                   UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
                                   MNModifyPasswordViewController *modifyPasswordViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNModifyPasswordViewController"];
                                   MNGuideNavigationController *guideNavigationController = [[MNGuideNavigationController alloc] initWithRootViewController:modifyPasswordViewController];
                                   modifyPasswordViewController.deviceID = _currentDeviceID;
                                   modifyPasswordViewController.oldPassword = _devicePasswordTextField.text;
                                   modifyPasswordViewController.is_notAdd = YES;
                                   //                               modifyPasswordViewController.deviceListViewController = self.listPageViewController;
                                   [self presentViewController:guideNavigationController animated:YES completion:nil];
                               }
                        
                           });
        
    }
    else  if (nil != ret.result) {
        //FIXME:change password
        [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_failed_to_set_the", nil)]];
        return;
    }
    
    //refresh devices
    [self refreshData];
}

#pragma mark - msg_listener
- (void)dev_msg_listener:(mdev_msg *)msg
{
    MNDeviceViewCell *deviceViewCell = [self getCollectionViewCell:msg.sn];
    if (!deviceViewCell) {
        return;
    }
    NSString *type = [NSString stringWithFormat:@"%@",msg.type];
    if ([type respondsToSelector:@selector(rangeOfString:)]) {
        if ([type rangeOfString:@"snapshot"].length) {
            return;
        }
    }
    
    m_dev *device = [self.agent.devs get_dev_by_sn:msg.sn];
    if ([msg.type isEqualToString:@"device"] && [msg.code isEqualToString:@"info"])
    {
        if ( msg.status && msg.status.length)
        {
            deviceViewCell.status = msg.status;
            device.status = msg.status;
        }
    }
    
   
    device.read_id = device.read_id < device.msg_id_min?device.msg_id_min:device.read_id;
    
    if(msg.msg_id > device.msg_id_max)
    {
        device.msg_id_max = msg.msg_id;
        [deviceViewCell setNeedsLayout];
    }
    else if (msg.msg_id == 1)
    {
        device.msg_id_max = 1;
        device.read_id = 0;
        [deviceViewCell setNeedsLayout];
    }

    
    struct mipci_conf *conf = MIPC_ConfigLoad();
    unsigned int tick = (unsigned int)mtime_tick();
    
    if (msg.msg_id) {
        if((tick - _lastMessageTick) >= 1000)
        {/* max one notification in one seconds */
            if (((NULL == conf) || (0 == conf->dis_audio)))
            {
                int ring_id = 0;
                if(_messageSoundID)
                {
                    AudioServicesDisposeSystemSoundID(_messageSoundID);
                    _messageSoundID = 0;
                }
                
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"msg%ld.mp3", (long)(conf?conf->ring:0)]  ofType:@""];
                NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &_messageSoundID);
                ring_id = _messageSoundID;
                AudioServicesPlaySystemSound(ring_id);

            }
            
            if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                &&  ((NULL == conf) || (0 == conf->dis_vibrate)))
            {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            _messageSoundID = tick;
        }

    }
    
    if (device.support_scene) {
        if ([msg.type isEqualToString:@"alert"]) {
            if ([msg.code isEqualToString:@"motion_alert"] && [msg.event isEqualToString:@"start"]) {
                deviceViewCell.alarmImageView.image = self.app.is_vimtag ? [UIImage imageNamed:@"vt_movePresentation"] : [UIImage imageNamed:@"alarmPresentation"];
                [deviceViewCell setNeedsLayout];
            } else if ([msg.code isEqualToString:@"motion_alert"] && [msg.event isEqualToString:@"stop"]) {
                deviceViewCell.alarmImageView.image = [UIImage imageNamed:@""];
                [deviceViewCell setNeedsLayout];
            }
            if ([msg.code isEqualToString:@"sos"]) {
                deviceViewCell.alarmImageView.image = [UIImage imageNamed:@"vt_event_sos"];
            }
            if ([msg.code isEqualToString:@"door"]) {
                deviceViewCell.alarmImageView.image = [UIImage imageNamed:@"vt_event_magnetic"];
            }
        }
    } else {
        if ([msg.alert isEqualToString:@"start"] && [device.img_ver compare:@"v3"] ==  NSOrderedDescending) {
            deviceViewCell.alarmImageView.image = self.app.is_vimtag ? [UIImage imageNamed:@"vt_movePresentation"] : [UIImage imageNamed:@"alarmPresentation"];
            [deviceViewCell setNeedsLayout];
        }else if ([msg.alert isEqualToString:@"stop"]) {
            deviceViewCell.alarmImageView.image = [UIImage imageNamed:@""];
            [deviceViewCell setNeedsLayout];
        }
        
        if ([msg.type isEqualToString:@"alert"]) {
            if ([msg.code isEqualToString:@"sos"]) {
                deviceViewCell.alarmImageView.image = [UIImage imageNamed:@"vt_event_sos"];
            }
        }
        if ([msg.type isEqualToString:@"alert"]) {
            
            if ([msg.code isEqualToString:@"door"]) {
                deviceViewCell.alarmImageView.image = [UIImage imageNamed:@"vt_event_magnetic"];
            }
        }
        if ([msg.type isEqualToString:@"alert"]) {
            if ([msg.code rangeOfString:@"motion"].length) {
                deviceViewCell.alarmImageView.image = [UIImage imageNamed:@"vt_movePresentation"];
            }
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.devices.counts;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNDeviceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    m_dev *dev = [self.devices get_dev_by_index:indexPath.row];
//    dev.read_id = dev.read_id < dev.msg_id_min?dev.msg_id_min:dev.read_id;
//    cell.device = dev;
    cell.status = dev.status;
    cell.deviceID = dev.sn;
    cell.nickLabel.text = dev.nick.length ? dev.nick : dev.sn;
    if (self.app.is_ebitcam || self.app.is_mipc) {
        cell.nickLabel.text = [NSString stringWithFormat:@"· %@", cell.nickLabel.text];
    }
    
    if ([dev.alert isEqualToString:@"start"] && [dev.img_ver compare:@"v3"] ==  NSOrderedDescending && [cell.status isEqualToString:@"Online"]) {
        cell.alarmImageView.image = self.app.is_vimtag ?  [UIImage imageNamed:@"vt_movePresentation"]: [UIImage imageNamed:@"alarmPresentation"];
        [cell setNeedsLayout];
    }else if ([dev.alert isEqualToString:@"stop"]) {
        cell.alarmImageView.image = [UIImage imageNamed:@""];
        [cell setNeedsLayout];
    }
    
    [dev addObserver:self forKeyPath:@"read_id" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [dev addObserver:self forKeyPath:@"nick" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self.devicesArray addObject:dev];
    
    //load image for network
    if (NSOrderedSame == [dev.type caseInsensitiveCompare:@"BOX"])
    {
        if (self.app.is_vimtag) {
            cell.backgroundImageView.image = [UIImage imageNamed:@"vt_box_placeholder.png"];
        }
        else if (self.app.is_ebitcam)
        {
            cell.backgroundImageView.image = [UIImage imageNamed:@"eb_cellBg.png"];
        }
        else if (self.app.is_mipc)
        {
            cell.backgroundImageView.image = [UIImage imageNamed:@"mi_cellBg.png"];
        }
        else
        {
            cell.backgroundImageView.image = [UIImage imageNamed:@"box_placeholder.png"];
        }
    }
    else
    {
        if (self.app.is_vimtag)
        {
            cell.backgroundImageView.image = [UIImage imageNamed:@"vt_cellBg.png"];
        }
        else if (self.app.is_ebitcam)
        {
            cell.backgroundImageView.image = [UIImage imageNamed:@"eb_cellBg.png"];
        }
        else if (self.app.is_mipc)
        {
            cell.backgroundImageView.image = [UIImage imageNamed:@"mi_cellBg.png"];
        }
        else
        {
            cell.backgroundImageView.image = [UIImage imageNamed:self.app.is_luxcam ? @"placeholder.png" : @"camera_placeholder.png"];
        }
    }
    [cell loadWebImage];

    //add longPress
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [cell addGestureRecognizer:longPressGesture];
    [cell setNeedsLayout];
    
//    cell.delegate = self;
    NSNumber *playNumber = [self.playDic objectForKey:cell.deviceID];
    BOOL isPlay = [playNumber boolValue];
    [cell resetMediaPlay:isPlay withAgent:nil];
    
    cell.playButton.hidden = YES;
    cell.backgroundPlayView.hidden = YES;
    return cell;
}

#pragma mark - MNDeviceViewCellDelagate
-(void)recordVideoPlay:(m_dev *)dev with:(BOOL)isPlay;
{
    NSNumber *playNumber = [NSNumber numberWithBool:isPlay];
    [self.playDic setObject:playNumber forKey:dev.sn];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    m_dev *dev = [self.agent.devs get_dev_by_index:indexPath.row];
    NSString *deviceID = dev.sn;
    _currentDeviceID = deviceID;

    if (NSOrderedSame == [dev.status caseInsensitiveCompare:@"online"])
    {
        
        if (NSOrderedSame == [dev.type caseInsensitiveCompare:@"IPC"])
        {
            if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
                [self performSegueWithIdentifier:@"MNDevicePlayViewController" sender:deviceID];
            }
            else
            {
                [self performSegueWithIdentifier:@"MNDeviceTabBarController" sender:[NSNumber numberWithInt:0]];
            } 
        }
        else
        {
            //coding for segment records
            if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
                [self performSegueWithIdentifier:@"MNBoxListViewController" sender:deviceID];
            } else {
                [self performSegueWithIdentifier:@"MNBoxTabBarController" sender:[NSNumber numberWithInt:0]];
            }
        }
        
    }
    else if (NSOrderedSame == [dev.status caseInsensitiveCompare:@"InvalidAuth"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_password_expired",nil)
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"mcs_cancel",nil)
                                             otherButtonTitles:NSLocalizedString(@"mcs_apply",nil), nil];
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        alertView.tag = CHANGEPASSWORD_TAG;
        [alertView show];
        
        UITextField *userTextField = [alertView textFieldAtIndex:0];
        userTextField.enabled = NO;
        userTextField.text = deviceID;
        UITextField *passTextField = [alertView textFieldAtIndex:1];
        passTextField.secureTextEntry = YES;
        passTextField.placeholder = NSLocalizedString(@"mcs_input_password",nil);
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
   
        //        float height = CGRectGetHeight(self.view.bounds);
//        NSInteger screenWidth = [UIDevice currentDevice].systemVersion.floatValue < 8.0 ? CGRectGetWidth(self.view.bounds) : self.transitionToSize.width;
        //        CGFloat screenWidth = width < height ? width : height;
       NSInteger screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        if (self.app.is_luxcam) {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
        }
        else if (self.app.is_vimtag)
        {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - 6 * 2 - (lineCounts - 1) * 6) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 3 / 5 + 16);
        }
        else if (self.app.is_ebitcam || self.app.is_mipc)
        {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * 6) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
        }
        else
        {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16);
        }
    }
    else
    {
           if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
        {
            //            float height = CGRectGetHeight(self.view.bounds);
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? width : height;
            
//              NSInteger screenWidth = [UIDevice currentDevice].systemVersion.floatValue < 8.0 ? CGRectGetWidth(self.view.bounds) : self.transitionToSize.width;
            if (self.app.is_luxcam) {
                
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else if (self.app.is_vimtag) {
                
                CGSize size = [UIScreen mainScreen].bounds.size;
                int lineCounts = DEFAULT_LINE_COUNTS;
                CGFloat cellWidth = (size.height - 6 * 2 - (lineCounts - 1) * 6) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 3 / 5 + 16);
            }
            else if (self.app.is_ebitcam || self.app.is_mipc)
            {
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * 6) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else
            {
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16);
            }
        }
        else
        {
            //            float height = CGRectGetHeight(self.view.bounds);
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? height : width;
//             NSInteger screenWidth = [UIDevice currentDevice].systemVersion.floatValue < 8.0 ? CGRectGetWidth(self.view.bounds) : self.transitionToSize.width;
            if (self.app.is_luxcam) {
                int lineCounts = DEFAULT_LINE_COUNTS;
                CGFloat cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else if (self.app.is_vimtag)
            {
                int lineCounts = DEFAULT_LINE_COUNTS;
                CGFloat cellWidth = (screenWidth - 6 * 2 - (lineCounts - 1) * 6) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 3 / 5 + 16);
            }
            else if (self.app.is_ebitcam || self.app.is_mipc)
            {
                int lineCounts = DEFAULT_LINE_COUNTS;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * 6) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else
            {
                int lineCounts = DEFAULT_LINE_COUNTS;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16);
            }
        }
        
    }
    
    return itemSize;
}

// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
//	return YES;
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    if ([NSStringFromSelector(@selector(action)) isEqualToString:@"menuItemDelete:"]) {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//}
//
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    NSLog(@"performAction");
//}

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == DELETE_TAG) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            
            mcall_ctx_dev_del *ctx = [[mcall_ctx_dev_del alloc] init];
            ctx.sn = _currentDeviceID;
            ctx.target = self;
            ctx.on_event = @selector(dev_del_done:);
            
            [self.agent dev_del:ctx];
            _progressHUD.labelText = NSLocalizedString(@"mcs_deleting", nil);
            [self.progressHUD show:YES];
        }
        
    }
    else if (alertView.tag == CHANGEPASSWORD_TAG)
    {
        if (buttonIndex != alertView.cancelButtonIndex) {
            UITextField *userTextField = [alertView textFieldAtIndex:0];
            UITextField *pwdTextField = [alertView textFieldAtIndex:1];
            
            _currentDeviceID = userTextField.text;
            _devicePasswordTextField = pwdTextField;
            if(pwdTextField.text.length)
            {
                if([pwdTextField.text isEqualToString:@"amdin"]){
                    pwdTextField.text = @"admin";
                }
                if (self.app.isLoginByID) {
                    if(pwdTextField.text && pwdTextField.text.length)
                    {
                        [mipc_agent passwd_encrypt:pwdTextField.text encrypt_pwd:encrypt_pwd];
                        
                    }
                    
                    mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
                    ctx.user = userTextField.text;
                    ctx.passwd = encrypt_pwd;
                    ctx.target = self;
                    ctx.on_event = @selector(sign_in_done:);
                    
                    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                    NSString *token = [user objectForKey:@"mipci_token"];
                    
                    if(token && token.length)
                    {
                        ctx.token = token;
                    }
                    
                    [_agent sign_in:ctx];
                    [self.progressHUD show:YES];
                }
                else
                {
                    mcall_ctx_dev_add *ctx = [[mcall_ctx_dev_add alloc] init];
                    [mipc_agent passwd_encrypt:pwdTextField.text encrypt_pwd:encrypt_pwd];
                    ctx.sn = userTextField.text;
                    ctx.passwd = encrypt_pwd;
                    ctx.target = self;
                    ctx.on_event = @selector(dev_add_done:);
                    
                    [self.agent dev_add:ctx];
                    [self.progressHUD show:YES];
                }
            }
        }
    }
    else if (alertView.tag == EXIT_TAG)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            
            struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
            
            if(conf)
            {
                conf_new  = *conf;
            }
            conf_new.auto_login = NO;
            MIPC_ConfigSave(&conf_new);
            self.app.is_userOnline = NO;
            
            mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init] ;
            ctx.target = self;
            ctx.on_event = @selector(sign_out_done:);
            
            [self.agent sign_out:ctx];
            //    [self loading:YES];
            
            if (self.app.is_sereneViewer)
            {
                [self performSegueWithIdentifier:@"MNSereneViewerLoginViewController" sender:nil];
            }
            else if (self.app.is_eyedot)
            {
                [self performSegueWithIdentifier:@"MNEyedotLoginViewController" sender:nil];
            }
            else if (self.app.is_kean || self.app.is_prolab)
            {
                [self performSegueWithIdentifier:@"MNKeanLoginViewController" sender:nil];
            }
            else if (self.app.is_eyeview)
            {
                [self performSegueWithIdentifier:@"MNEyeviewLoginViewController" sender:nil];
            }
            else if (!self.app.is_vimtag && !self.app.is_jump)
            {
                [self performSegueWithIdentifier:@"MNLoginViewController" sender:nil];
            }

        }
    }
    else if (alertView.tag == ADVICE_TAG){
        if (buttonIndex == 2) {
            [self performSegueWithIdentifier:@"MNFeedbackViewController" sender:nil];
        }
        else if(buttonIndex == 1){
        
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/vimtag/id1025437540?mt=8"]];
        }
    } else if(alertView.tag == UPDATE_APP_TAG){
        if (buttonIndex != alertView.cancelButtonIndex) {
            
            //https://itunes.apple.com/cn/app/vimtag/id1025437540?mt=8
            //https://itunes.apple.com/cn/app/mipc/id550958838?mt=8
            
            if (self.app.is_vimtag) {
                 [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/vimtag/id1025437540?mt=8"]];
            } else if(self.app.is_mipc){
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/mipc/id550958838?mt=8"]];
            }
        }
    }
    else if (alertView.tag == EXCEPTION_TAG)
    {
        if (alertView.cancelButtonIndex != buttonIndex) {
            [self sendException_log];
        } else {
            [[NSUserDefaults standardUserDefaults]setObject:@"noException" forKey:@"exception"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
    else if (alertView.tag == STOP_DIAGNOSIS_TAG)
    {
        if (alertView.cancelButtonIndex != buttonIndex) {
            //End Save Log Flag
            self.app.startSaveLog = NO;
            
            _detailDiagnosisLabel.hidden = YES;
            _finishDiagnosisButton.hidden = YES;
            self.networkExceptionView.hidden = self.app.isNetWorkAvailable;
            self.networkFailButton.hidden = self.app.isNetWorkAvailable;
            
            MNDiagnosisResultViewController *diagnosisResultViewController = [[UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"MNDiagnosisResultViewController"];
            diagnosisResultViewController.is_detailDiagnosis = YES;
            MNGuideNavigationController *navigationController = [[MNGuideNavigationController alloc] initWithRootViewController:diagnosisResultViewController];
            
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    }
}
#pragma mark - ScrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -20 && !_isScrollerViewRelease ) {
            _downRefreshLabel.hidden = NO;
            _downRefreshLabel.text = NSLocalizedString(@"mcs_down_refresh", nil);
        self.refreshImageView.hidden = YES;
    }
    if (scrollView.contentOffset.y  < -50 && !_isScrollerViewRelease){
        _downRefreshLabel.hidden = NO;
        _downRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
        self.refreshImageView.hidden = YES;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -50) {
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
        [scrollView setContentOffset:CGPointMake(0, -40) animated:YES];
        [self performSelector:@selector(refreshData) withObject:nil afterDelay:1.0f];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == 0) {
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

#pragma mark - NSURLConnectDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.FilePath = [documentPath stringByAppendingPathComponent:response.suggestedFilename];
    
   
    NSFileManager   *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:self.FilePath contents:nil attributes:nil];
    

    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:self.FilePath];

//    self.totalLength = response.expectedContentLength;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.writeHandle seekToEndOfFile];
    
    [self.writeHandle writeData:data];
    
//    self.currentLength += data.length;
    
//    self.myPregress.progress = (double)self.currentLength / self.totalLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    self.currentLength = 0;
//    self.totalLength = 0;
    
    [self.writeHandle closeFile];
    self.writeHandle = nil;
    NSString *wwwFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"wwwFilePath"];
    NSString *unzipFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"];
    [[NSFileManager defaultManager] removeItemAtPath:wwwFilePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:unzipFilePath error:nil];
    

    MNZipArchive *zip = [[MNZipArchive alloc] init];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSLog(@"component:%@", [self.FilePath lastPathComponent]);
    unzipFilePath = [documentPath stringByAppendingPathComponent:[[self.FilePath lastPathComponent] stringByDeletingPathExtension]];
    if ([zip UnzipOpenFile:self.FilePath])
    {
        [zip UnzipFileTo:unzipFilePath overWrite:YES];
        [zip UnzipCloseFile];
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.FilePath forKey:@"wwwFilePath"];
    [[NSUserDefaults standardUserDefaults] setObject:unzipFilePath forKey:@"unzipFilePath"];
    
    NSString *webMobileVersion = [NSString stringWithFormat:@"%@", [unzipFilePath lastPathComponent]];
    if (webMobileVersion.length) {
        int i = 0;
        for ( ; i < webMobileVersion.length; i++) {
            NSString *temp = [webMobileVersion substringWithRange:NSMakeRange(i, 1)];
            if ([self predicateString:temp regex:@"^[0-9]*$"]) {
                webMobileVersion = [webMobileVersion substringFromIndex:i];
                break;
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:webMobileVersion forKey:@"webMobileVersion"];
}

#pragma mark - popoverView updateVideoOptions
- (void)updateVideoOptions:(int)profileID
{
    self.curProfileID = profileID;
    
    if (self.app.disableModifyUserSetting && self.app.disableExit) {
        self.settingOptions =  [NSArray arrayWithObjects:
                                [NSString stringWithFormat:(2 == _curProfileID)?@"√ %@":@"   %@", NSLocalizedString(@"mcs_fluent_clear",nil)],
                                [NSString stringWithFormat:(1 == _curProfileID)?@"√ %@":@"   %@", NSLocalizedString(@"mcs_standard_clear",nil)],
                                [NSString stringWithFormat:(0 == _curProfileID)?@"√ %@":@"   %@", NSLocalizedString(@"mcs_high_clear",nil)],
                                self.app.isLoginByID?NSLocalizedString(@"mcs_my_folder",nil):NSLocalizedString(@"mcs_add_device",nil),
                                self.app.isLoginByID?nil:NSLocalizedString(@"mcs_my_folder",nil),nil];
    } else if (self.app.is_sereneViewer) {
        self.settingOptions =  [NSArray arrayWithObjects:
                                [NSString stringWithFormat:(2 == _curProfileID)?@"√ %@":@"   %@", NSLocalizedString(@"mcs_fluent_clear",nil)],
                                [NSString stringWithFormat:(1 == _curProfileID)?@"√ %@":@"   %@", NSLocalizedString(@"mcs_standard_clear",nil)],
                                [NSString stringWithFormat:(0 == _curProfileID)?@"√ %@":@"   %@", NSLocalizedString(@"mcs_high_clear",nil)],
                                self.app.isLoginByID?NSLocalizedString(@"mcs_settings",nil):NSLocalizedString(@"mcs_add_device",nil),
                                self.app.isLoginByID?NSLocalizedString(@"mcs_my_folder",nil):NSLocalizedString(@"mcs_settings",nil),
                                self.app.isLoginByID?NSLocalizedString(@"mcs_warranty_registration",nil):NSLocalizedString(@"mcs_my_folder",nil),
                                self.app.isLoginByID?NSLocalizedString(@"mcs_get_more_cameras",nil):NSLocalizedString(@"mcs_warranty_registration",nil),
                                self.app.isLoginByID?NSLocalizedString(@"mcs_help_feedback",nil):NSLocalizedString(@"mcs_get_more_cameras",nil),
                                
                                
                                self.app.isLoginByID? NSLocalizedString(@"mcs_exit",nil):
                                [NSString stringWithFormat:@"%@",                            NSLocalizedString(@"mcs_help_feedback", nil)],
                                
                                self.app.isLoginByID?nil: NSLocalizedString(@"mcs_exit",nil),
                                nil];
    }
    else
    {
        self.settingOptions =  [NSArray arrayWithObjects:
                                [NSString stringWithFormat:(2 == _curProfileID)?@"√ %@":@"   %@", NSLocalizedString(@"mcs_fluent_clear",nil)],
                                [NSString stringWithFormat:(1 == _curProfileID)?@"√ %@":@"   %@", NSLocalizedString(@"mcs_standard_clear",nil)],
                                [NSString stringWithFormat:(0 == _curProfileID)?@"√ %@":@"   %@", NSLocalizedString(@"mcs_high_clear",nil)],
                                self.app.isLoginByID?NSLocalizedString(@"mcs_settings",nil):NSLocalizedString(@"mcs_add_device",nil),
                                self.app.isLoginByID?NSLocalizedString(@"mcs_my_folder",nil):NSLocalizedString(@"mcs_settings",nil),
                                self.app.isLoginByID?NSLocalizedString(@"mcs_exit",nil):NSLocalizedString(@"mcs_my_folder",nil),
                                self.app.isLoginByID?nil: NSLocalizedString(@"mcs_exit",nil),
                                nil];
    }
}


#pragma mark - popoverViewDelegate Methods
- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"%s item:%ld", __PRETTY_FUNCTION__, (long)index);
    //Figure out which string was selected, store in "string"
//    NSString *string = [_settingOptions objectAtIndex:index];
    
    //Show a success image, with the string from the array
//    [popoverView showImage:[UIImage imageNamed:@"popview_success"] withMessage:string];
    
    //Dismiss the PopoverView after 0.5 seconds
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.0f];
    if(index <= PROFILE_ID_MAX)
    {
        struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
        if(conf)
        {
            conf_new = *conf;
        }
        conf_new.profile_id = PROFILE_ID_MAX - (uint32_t)index;
        MIPC_ConfigSave(&conf_new);
        [self updateVideoOptions: conf_new.profile_id];
    }
    else if(3 == index)
    {
        UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
        MNGuideNavigationController *guideNavigationController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNGuideNavigationController"];

        self.app.isLoginByID?
            [self performSegueWithIdentifier:@"MNAppSettingsViewController" sender:nil]:
            [self presentViewController:guideNavigationController animated:YES completion:nil];
    }
    else if(4 == index)
    {
        if (self.app.disableModifyUserSetting && self.app.disableExit) {
            [self performSegueWithIdentifier:@"MNCacheDirectoryViewController" sender:nil];
        } else {
            self.app.isLoginByID?[self performSegueWithIdentifier:@"MNCacheDirectoryViewController" sender:nil]:
            [self performSegueWithIdentifier:@"MNAppSettingsViewController" sender:nil];
        }
        
    }
    else if(5 == index)
    {
        if (self.app.is_sereneViewer)
        {
            self.app.isLoginByID?[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.pyleaudio.com/ProductRegistration.aspx"]]:
           [self performSegueWithIdentifier:@"MNCacheDirectoryViewController" sender:nil];
        }
        else
        {
            self.app.isLoginByID?[self exit]:
            [self performSegueWithIdentifier:@"MNCacheDirectoryViewController" sender:nil];
        }
    }
    else if (6 == index)
    {
        if (self.app.is_sereneViewer) {
            self.app.isLoginByID?[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.amazon.com/Serenelife-IP-Cameras/pages/default?pageId=TO1LFI265TI9A2Z"]]:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.pyleaudio.com/ProductRegistration.aspx"]];
        } else {
            [self exit];
        }
    }
    else if (7 == index)
    {
        if (self.app.is_sereneViewer)
        {
            self.app.isLoginByID?[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://pyleaudio.helpshift.com/a/serene-life/"]]:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.amazon.com/Serenelife-IP-Cameras/pages/default?pageId=TO1LFI265TI9A2Z"]];
        }
    }
    else if (8 == index)
    {
        if (self.app.is_sereneViewer)
        {
            self.app.isLoginByID?[self exit]:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://pyleaudio.helpshift.com/a/serene-life/"]];
        }
    }
    else if (9 == index)
    {
        [self exit];
    }

}
 
- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    self.curVideoSizePopView = nil;
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    m_dev *dev = [self.devices get_dev_by_sn:_currentDeviceID];
//    long counts = dev.msg_id_max - dev.read_id;
    MNDeviceViewCell *currentCell = [self getCollectionViewCell:_currentDeviceID];
    currentCell.nickLabel.text = dev.nick.length ? dev.nick : dev.sn;
    [currentCell setNeedsDisplay];
    if (NSOrderedSame == [dev.type caseInsensitiveCompare:@"BOX"])
    {
//        if (self.app.is_vimtag) {
//            currentCell.backgroundImageView.image = [UIImage imageNamed:@"vt_box_placeholder.png"];
//        } else {
//            currentCell.backgroundImageView.image = [UIImage imageNamed:@"box_placeholder.png"];
//        }
    }
    else
    {
        if (self.app.is_vimtag)
        {
            currentCell.backgroundImageView.image = [UIImage imageNamed:@"vt_cellBg.png"];
        }
        else if (self.app.is_ebitcam)
        {
            currentCell.backgroundImageView.image = [UIImage imageNamed:@"eb_cellBg.png"];
        }
        else if (self.app.is_mipc)
        {
            currentCell.backgroundImageView.image = [UIImage imageNamed:@"mi_cellBg.png"];
        }
        else
        {
            currentCell.backgroundImageView.image = [UIImage imageNamed:self.app.is_luxcam ? @"placeholder.png" : @"camera_placeholder.png"];
        }
        [currentCell loadWebImage];
    }
}
#pragma mark - remove Observer
- (void)removeObserver
{
    @try {
        for (m_dev *dev in self.devicesArray) {
            [dev removeObserver:self forKeyPath:@"read_id"];
            [dev removeObserver:self forKeyPath:@"nick"];
        }
        
        [self.devicesArray removeAllObjects];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark -Vimtag
- (IBAction)toLoginInterface:(id)sender
{
    [self performSegueWithIdentifier:@"MNLoginViewController" sender:nil];
}

- (IBAction)toRegisternterface:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil];
    MNRegisterViewController *registerViewController = [storyboard instantiateViewControllerWithIdentifier:@"MNRegisterViewController"];
    MNRootNavigationController *registertNavigationController = [[MNRootNavigationController alloc] initWithRootViewController:registerViewController];
    registerViewController.is_ListRegister = YES;
    [self.navigationController presentViewController:registertNavigationController animated:YES completion:nil];
}

- (void)autoLogin
{
    struct mipci_conf *conf = MIPC_ConfigLoad();
    
    if(conf && conf->user.len && (conf->password.len || conf->password_md5.len) && conf->auto_login && !self.app.is_userOnline)
    {
        NSString *userName = [NSString stringWithUTF8String:(const char*) conf->user.data];
        memset(login_encrypt_pwd, 0, sizeof(login_encrypt_pwd));
        memcpy(login_encrypt_pwd, conf->password_md5.data, sizeof(login_encrypt_pwd));

        //login
        mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
        ctx.srv = MIPC_SrvFix(@"");
        ctx.user = userName;
        ctx.passwd = login_encrypt_pwd;
        ctx.target = self;
        ctx.on_event = @selector(sign_in_account_done:);
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *token = [user objectForKey:@"mipci_token"];
        
        if(token && token.length)
        {
            ctx.token = token;
        }
        
        [self.agent sign_in:ctx];
        self.progressHUD.labelText = NSLocalizedString(@"mcs_sign_ining", nil);
        [self.progressHUD show:YES];
        
        [self getNotification:userName];
    }
    else
    {
//        _listPageViewController.navigationItem.leftBarButtonItem.customView.hidden = YES;
        [_LoginPromptView setHidden:NO];
    }
}

- (void)sign_in_account_done:(mcall_ret_sign_in*)ret
{
    self.progressHUD.labelText = NSLocalizedString(@"mcs_loading", nil);
    
//    NSString *homePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//    NSString *filePath = [homePath stringByAppendingPathComponent:@"userBehaviours"];
    
    if(nil == ret.result)
    {
        [self performSelector:@selector(webVersionGet) withObject:nil afterDelay:6];

//        MNUserBehaviours *behaviours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//        behaviours.login_succ_times += 1;
//        [NSKeyedArchiver archiveRootObject:behaviours toFile:filePath];
        
        [self loadingDeviceData];
        
        //refresh More's data
        UITabBarController *tabBarController = self.tabBarController;
        UINavigationController *navigationController = [tabBarController.viewControllers lastObject];
        for (UIViewController *viewController in navigationController.viewControllers) {
            if ([viewController isMemberOfClass:[MNMoreInformationViewController class]]) {
                [((MNMoreInformationViewController*) viewController) updateInterface];
            }
        }
    }
    else
    {
        [self.progressHUD hide:YES];
        
        if([ret.result isEqualToString:@"ret.user.unknown"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_user",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            
            struct mipci_conf *conf = MIPC_ConfigLoad(), new_conf = {0};
            
            if(conf)
            {
                new_conf = *conf;
            };
            
            new_conf.password.len = (new_conf.password_md5.len = 0);
            new_conf.auto_login = 0;
            MIPC_ConfigSave(&new_conf);
        }
        else if([ret.result isEqualToString:@"ret.pwd.invalid"])
        {

            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_user_or_password_invalid",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];

            struct mipci_conf *conf = MIPC_ConfigLoad(), new_conf = {0};
            if(conf){ new_conf = *conf; };
            new_conf.password.len = (new_conf.password_md5.len = 0);
            new_conf.auto_login = 0;
            MIPC_ConfigSave(&new_conf);
        }
        else
        {
//            MNUserBehaviours *behaviours = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
//            behaviours.login_fail_times += 1;
//            [NSKeyedArchiver archiveRootObject:behaviours toFile:filePath];
            
            struct mipci_conf *conf = MIPC_ConfigLoad(), new_conf = {0};
            if(conf){ new_conf = *conf; };
            new_conf.auto_login = 0;
            MIPC_ConfigSave(&new_conf);
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_login_faided",nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
//        _listPageViewController.navigationItem.leftBarButtonItem.customView.hidden = YES;
        [_LoginPromptView setHidden:NO];
    }
}

- (void)loadingDeviceData
{
    [_LoginPromptView setHidden:YES];

    struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
    if(conf)
    {
        conf_new = *conf;
    }
    self.app.is_userOnline = YES;
    
    MIPC_ConfigSave(&conf_new);

    if (self.app.is_vimtag && !self.app.isLocalDevice) {
        
        for (UIViewController *viewController in self.navigationController.viewControllers) {
            if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                
                MNDeviceListSetViewController *deviceListSetViewController = (MNDeviceListSetViewController *)viewController;
                [deviceListSetViewController checkUserOnlie];
            }
        }
    }
    
    mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
    ctx.target = self;
    ctx.on_event = @selector(devs_refresh_done:);
    
    //Get device list refresh
    [self.agent devs_refresh:ctx];
    [self.progressHUD show:YES];
    
    mcall_ctx_dev_msg_listener_add *add = [[mcall_ctx_dev_msg_listener_add alloc] init];
    add.target = self;
    add.on_event = @selector(dev_msg_listener:);
    add.type = @"device,io,motion,alert,snapshot,record,exdev";
    [self.agent dev_msg_listener_add:add];
}

- (void)getNotification:(NSString *)userName
{
    // add notification
    unsigned int random = arc4random() % 60;
    _postGetCtx = [[mcall_ctx_post_get alloc] init];
    _postGetCtx.start = 0;
    _postGetCtx.counts = 20;
    _postGetCtx.target = self;
    _postGetCtx.user = userName;
    
    _randomTimer = [NSTimer scheduledTimerWithTimeInterval:random - 10 target:self selector:@selector(postAction:) userInfo:nil repeats:NO];
    _postGetCtx.on_event = @selector(notification_get_done:);
    [self.agent performSelector:@selector(post_get:) withObject:_postGetCtx afterDelay:random];
}

//exit App
- (void)exitApplication {
    
    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:10];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view.window cache:NO];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    self.view.window.bounds = CGRectMake(0, 0, 0, 0);
    [UIView commitAnimations];
}

- (void)postSingleTap:(id)sender
{
    _alertLevelWindow.hidden = YES;
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID compare:@"exitApplication"] == 0) {
        exit(0);
    }
}

- (void)notification_get_done:(mcall_ret_post_get *)ret
{
    MNPostAlertView *postAlerView = [[MNPostAlertView alloc] initWithFrame:self.view.frame post:ret status:_isLoginSuccess];
    [postAlerView show];
}

- (void)postCloseAction:(id)sender
{
    _alertLevelWindow.hidden = YES;
    
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
                [self dismissViewControllerAnimated:NO completion:nil];
                [self.navigationController popToRootViewControllerAnimated:NO];
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
                [self dismissViewControllerAnimated:NO completion:nil];
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
        }
    }
    //    [self dismissViewControllerAnimated:NO completion:nil];
    //    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (NSTimer *)postAction:(id)sender
{
    _isExcutePost = YES;
    return nil;
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage =  scrollView.contentOffset.x / _alertLevelWindow.frame.size.width;
}

#pragma mark - webView
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *meta;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom=1.3"];
    }
    else if (self.view.frame.size.height <= 480)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=0.8, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    else if (self.view.frame.size.height > 480 && self.view.frame.size.height <= 568)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=0.9, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    else if (self.view.frame.size.height > 568 && self.view.frame.size.height <= 667)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    else if(self.view.frame.size.height > 667)
    {
        meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=0.5, maximum-scale=2.0, user-scalable=yes\"", webView.frame.size.width];
    }
    
    [webView stringByEvaluatingJavaScriptFromString:meta];
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
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

#pragma mark-go to feeling
- (IBAction)pushToFeeling:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"MNFeelingViewController" sender:nil];
}

@end

