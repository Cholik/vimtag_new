//
//  MNFeelingViewController.m
//  mipci
//
//  Created by mining on 16/3/31.
//
//

#define DEFAULT_LINE_COUNTS       2
#define DEFAULT_CELL_MARGIN       4
#define DEFAULT_EDGE_MARGIN       5
#define EXIT_TAG                  1003
#define SCORE_TAG                 1004
#define PROFILE_ID_MAX            3

#import "MNFeelingViewController.h"
#import "MNDeviceViewCell.h"
#import "AppDelegate.h"
#import "MNProgressHUD.h"
#import "MIPCUtils.h"
#import "MNInfoPromptView.h"
#import "MNPostAlertView.h"
#import "MNDevicePlayViewController.h"
#import "MNBoxListViewController.h"
#import "MNBoxTabBarController.h"
#import "MNConfiguration.h"
#import "MNMessagePageViewController.h"
#import "MNMessageViewCell.h"
#import "MNModifyPasswordViewController.h"
#import "MNQRCodeViewController.h"
#import "MNSettingsDeviceViewController.h"
#import "MNDeviceListSetViewController.h"
#import "UIImageView+refresh.h"

@interface MNFeelingViewController ()
{
    unsigned char login_encry_pwd[16];
}

@property(nonatomic,strong)mdev_devs *devices;
@property(nonatomic,weak)AppDelegate *app;
@property(nonatomic,strong)NSMutableArray *deviceArray;
@property(nonatomic,strong)mipc_agent *agent;
@property(nonatomic,strong)NSString *currentDeviceID;
@property(nonatomic,strong)MNProgressHUD *progressHUD;
@property(nonatomic,assign)BOOL isViewAppearing;
@property(nonatomic,assign)BOOL isRefreshing;
@property(nonatomic,assign)BOOL isScrollerViewRelease;
@property(nonatomic,assign)CGSize transitionToSize;
@property(nonatomic,strong)UILabel *downRefreshLabel;
@property(nonatomic,strong)UIActivityIndicatorView *pullUpActivityView;
@property(nonatomic,weak)MNConfiguration *configration;
@property (strong ,nonatomic) UIImageView *refreshImageView;
@property (strong, nonatomic) NSTimer *refreshTimer;

@end

@implementation MNFeelingViewController

-(void)dealloc
{
    [self removeObserve];
}

-(NSMutableArray *)deviceArray
{
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray array];
    }
    return _deviceArray;
}

-(AppDelegate *)app
{
    if (!_app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

-(mipc_agent *)agent
{
    return self.app.cloudAgent;
}

-(MNConfiguration *)configration
{
    if (!_configration) {
        _configration = [MNConfiguration shared_configuration];
    }
    return _configration;
}
-(MNProgressHUD *)progressHUD
{
    if (!_progressHUD) {
        _progressHUD = [[MNProgressHUD alloc]initWithView:self.view];
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
    return _progressHUD;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
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

-(void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_device_list", nil);
    
    UIButton *leftbutton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [leftbutton setImage:[UIImage imageNamed:@"item_back"] forState:UIControlStateNormal];
    [leftbutton addTarget:self action:@selector(exit_feel) forControlEvents:UIControlEventTouchUpInside];
    leftbutton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftbutton];
    
    self.collectionView.alwaysBounceVertical = YES;
    
    _downRefreshLabel = [[UILabel alloc]init];
    CGRect dowmRefreshLabelFrame ;
    dowmRefreshLabelFrame = CGRectMake(0, -35, 300, 40);
    _downRefreshLabel.frame = dowmRefreshLabelFrame;
    CGPoint downrefreshLabelPoint = _downRefreshLabel.center ;
    downrefreshLabelPoint.x = self.collectionView.center.x;
    _downRefreshLabel.center = downrefreshLabelPoint;
    
    _downRefreshLabel.font = [UIFont systemFontOfSize:16];
    _downRefreshLabel.textAlignment = NSTextAlignmentCenter;
    _downRefreshLabel.textColor = self.configration.labelTextColor;
    _downRefreshLabel.hidden = YES;
    
    //get _downLable.text   width
    NSString *downRefreshText = NSLocalizedString(@"mcs_refreshing", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice]systemVersion]floatValue] > 7.0) {
        NSMutableParagraphStyle *paragraPhstyle = [[NSMutableParagraphStyle alloc]init];
        paragraPhstyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:16],NSParagraphStyleAttributeName : paragraPhstyle.copy};
        labelSize = [downRefreshText boundingRectWithSize:CGSizeMake(0, 0)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                               attributes:attributes
                                                  context:nil].size;
        labelSize.width = ceil(labelSize.width);
    }
    
    //activity for refresh
    if (self.app.is_vimtag) {
        
        [self.refreshImageView setImageViewFrame:self.collectionView with:labelSize];
    }
    else {
        //activity for refresh
        _pullUpActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _pullUpActivityView.color = self.configration.labelTextColor;
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

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    _isRefreshing = NO;
    _isViewAppearing = YES;

    //auto login demo account
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"t_a"];
    NSString *passWord = [[NSUserDefaults standardUserDefaults] stringForKey:@"t_p"];
    
    [mipc_agent passwd_encrypt:passWord encrypt_pwd:login_encry_pwd];
    
    //login
    mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc]init];
    ctx.srv = MIPC_SrvFix(@"");
    ctx.user = userName;
    ctx.passwd = login_encry_pwd;
    ctx.target = self;
    ctx.on_event = @selector(sign_in_account_done:);
    
    [self.agent local_sign_in:ctx switchMmq:NO];
    [self.progressHUD show:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    if (self.app.is_vimtag) {
        MNDeviceListSetViewController *deviceListSetViewController = self.navigationController.viewControllers.firstObject;
        deviceListSetViewController.navigationController.navigationBarHidden = NO;
    }
    self.app.isLocalDevice = NO;
    self.agent = self.app.cloudAgent;

    _transitionToSize = self.view.bounds.size;
    _isViewAppearing = YES;
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    
    UIMenuController *popMenucontroller = [UIMenuController sharedMenuController];
    [popMenucontroller setMenuVisible:NO animated:YES];
    
    if (self.app.is_vimtag)
    {
        [MNInfoPromptView hideAll:self.navigationController];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _isViewAppearing = NO;
    [self cancelNetWorkRequest];
}

#pragma mark - view Did Laout subViews
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGPoint downRefrshLabelCenter = _downRefreshLabel.center;
    downRefrshLabelCenter.x = self.collectionView.center.x;
    _downRefreshLabel.center = downRefrshLabelCenter;
    [self.collectionView addSubview:_downRefreshLabel];
    
    //get _downRefreshLabel.text width
    NSString *downRefrshLabelText = NSLocalizedString(@"mcs_refrshing", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice]systemVersion]floatValue] > 7.0) {
        NSMutableParagraphStyle *paregraphStyle = [[NSMutableParagraphStyle alloc]init];
        paregraphStyle.lineBreakMode =NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:paregraphStyle.copy};
        labelSize = [downRefrshLabelText boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
        labelSize.width = ceil(labelSize.width);
    }
    //activity for refresh
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

-(void)cancelNetWorkRequest
{
    for (UIView *view in self.collectionView.subviews) {
        if ([view isMemberOfClass:[MNDeviceViewCell class]]) {
            MNDeviceViewCell *cell = (MNDeviceViewCell *)view;
            if ([cell respondsToSelector:@selector(cancelNetWorkRequest)]) {
                [cell performSelector:@selector(cancelNetWorkRequest)];
            }
        }
    }
}

#pragma mark - login done
-(void)sign_in_account_done:(mcall_ret_sign_in *)ret
{
    //test
    NSLog(@"Sign in success!");
    self.progressHUD.labelText = NSLocalizedString(@"mcs_loading", nil);
    
    if (!ret.result) {
        //loading success reloadData
        mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc]init];
        ctx.target = self;
        ctx.on_event = @selector(devs_refresh_done:);
        
        //get device list refresh
        [self.agent devs_refresh:ctx];
        [self.progressHUD show:YES];
    }
}

-(void)refreshData
{
    if(!_isRefreshing){
        [self removeObserve];
        mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc]init];
        ctx.target = self;
        ctx.on_event = @selector(devs_refresh_done:);
        
        //get device list  refresh
        [self.agent devs_refresh:ctx];
        _isRefreshing = YES;
    }
}

-(void)removeObserve
{
    [self.deviceArray removeAllObjects];
}

#pragma mark- exit_action
-(void)exit_feel
{
    mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc]init];
    ctx.target = self;
    ctx.on_event = @selector(sign_out_done:);
    
    [self.agent sign_out:ctx];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sign_out_done:(mcall_ret_sign_out*)ret
{
    if (ret.result) {
        return ;
    }
}

#pragma mark- Utils
-(MNDeviceViewCell *)getCollectionViewCell:(NSString *)deviceID
{
    NSArray *subViews = self.collectionView.subviews;
    for (UIView *view in subViews) {
        if ([view isMemberOfClass:[MNDeviceViewCell class]]) {
            if ([((MNDeviceViewCell *)view).deviceID isEqualToString:deviceID] ){
                return (MNDeviceViewCell *)view;
            }
        }
    }
    return nil;
}

#pragma mark-NetWork callBack
-(void)devs_refresh_done:(mcall_ret_devs_refresh *)ret
{
    _isRefreshing = NO;
    [self.progressHUD hide:YES];
    if (_isScrollerViewRelease) {
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    if (ret.result) {
        if (self.app.is_jump && !self.isRefreshing) {
            [self performSelector:@selector(refreshData) withObject:nil afterDelay:1.0f];
            
        }else{
        
            //FIME
            [self.progressHUD hide:YES];
            if ([ret.result isEqualToString:@"ret.no.rsp"]) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_access_server_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
            }
        }
        return ;
    }
    
    self.devices = ret.devs;
    [self.collectionView reloadData];
}

#pragma mark -Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNDeviceTabBarController"]) {
        
    } else if ([segue.identifier isEqualToString:@"MNDevicePlayViewController"]){
        MNDevicePlayViewController *deviceViewController = segue.destinationViewController;
        deviceViewController.deviceID = _currentDeviceID;
        deviceViewController.isExperienceAccount = YES;
    } else if ([segue.identifier isEqualToString:@"MNBoxListViewController"]){
        MNBoxListViewController *boxListviewcontroller = segue.destinationViewController;
        boxListviewcontroller.boxID = sender;
    } else if ([segue.identifier isEqualToString:@"MNBoxTabBarController"]){
        MNBoxTabBarController *boxTabbarcontroller = segue.destinationViewController;
        boxTabbarcontroller.boxID = _currentDeviceID;
        boxTabbarcontroller.selectedIndex = [sender integerValue];
    
    } else if ([segue.identifier isEqualToString:@"MNSettingsDeviceViewController"]){
        MNSettingsDeviceViewController *settingViewcontroller = segue.destinationViewController;
        settingViewcontroller.deviceID = _currentDeviceID;
    } else if ([segue.identifier isEqualToString:@"MNMessagePageViewController"]){
        MNMessagePageViewController *messagePageViewController = segue.destinationViewController;
        messagePageViewController.deviceID = _currentDeviceID;
    }
}
#pragma mark - scrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -20 && !_isScrollerViewRelease) {
        _downRefreshLabel.hidden = NO;
        _downRefreshLabel.text = NSLocalizedString(@"mcs_down_refresh", nil);
        self.refreshImageView.hidden = YES;
    }
    if (scrollView.contentOffset.y < - 50 && !_isScrollerViewRelease) {
        _downRefreshLabel.hidden = NO;
        _downRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
        self.refreshImageView.hidden = YES;
    }
    
}
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
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
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == 0) {
        _isScrollerViewRelease = NO;
        if (self.app.is_vimtag) {
            [self.refreshTimer invalidate];
            self.refreshImageView.hidden = YES;
        }
        else {
            [_pullUpActivityView stopAnimating];
        }
    }
}

#pragma mark - collectionViewDelegate&DataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.devices.counts;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNDeviceViewCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    m_dev *dev = [self.devices get_dev_by_index:indexPath.row];
    cell.status = dev.status;
    cell.deviceID = dev.sn;
    cell.nickLabel.text = dev.nick.length ? dev.nick : dev.sn;
    [self.deviceArray addObject:dev];
    
    //load image for netWork
    if (NSOrderedSame == [dev.type caseInsensitiveCompare:@"BOX"]) {
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
    }else{
    
        if (self.app.is_vimtag) {
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
    
    //addlongPress
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    [cell addGestureRecognizer:longPressGesture];
    [cell setNeedsLayout];
    
    return cell;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    m_dev *dev = [self.agent.devs get_dev_by_index:indexPath.row];
    NSString *deviceID = dev.sn;
    _currentDeviceID = deviceID;
    
    if (NSOrderedSame == [dev.status caseInsensitiveCompare:@"online"])
    {
        if (NSOrderedSame == [dev.type caseInsensitiveCompare:@"IPC"]) {
            if (self.app.is_vimtag || self.app.is_luxcam) {
                [self performSegueWithIdentifier:@"MNDevicePlayViewController" sender:deviceID];
            }else
            {
                [self performSegueWithIdentifier:@"MNDeviceTabBarController" sender:[NSNumber numberWithInt:0]];
            }
        }
        else{
        
            if (self.app.is_luxcam || self.app.is_vimtag) {
                [self performSegueWithIdentifier:@"MNBoxListViewController" sender:deviceID];
            }else{
                [self performSegueWithIdentifier:@"MNBoxTabBarController" sender:[NSNumber numberWithInt:0]];
            }
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
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
            
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? width : height;
            
            if (self.app.is_luxcam) {
                
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else if (self.app.is_vimtag) {
                int lineCounts = DEFAULT_LINE_COUNTS;
                NSInteger cellWidth = (screenWidth - 6 * 2 - (lineCounts - 1) * 6) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 3 / 5 + 16);
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
            
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? height : width;
            
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

#pragma mark -longPressGuesture
-(void)handleLongPress:(UILongPressGestureRecognizer *)longPressGuesture
{

    if(longPressGuesture.state == UIGestureRecognizerStateBegan){
        _currentDeviceID = ((MNDeviceViewCell *)longPressGuesture.view).deviceID ;
        m_dev *dev = [self.agent.devs get_dev_by_sn:_currentDeviceID];
        
        [longPressGuesture.view becomeFirstResponder];
        CGPoint point = [longPressGuesture locationInView:longPressGuesture.view];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *playItem = [[UIMenuItem alloc]initWithTitle:NSLocalizedString(@"mcs_play", nil) action:@selector(playMenuItem:)];
        UIMenuItem *messageItem = [[UIMenuItem alloc]initWithTitle:NSLocalizedString(@"mcs_messages", nil) action:@selector(messageMenuItem:)];
        UIMenuItem *settingItem = [[UIMenuItem alloc]initWithTitle:NSLocalizedString(@"mcs_settings", nil) action:@selector(settingMenuItem:)];
        
        NSArray *menuITemArray;
        if (dev && (NSOrderedSame == [dev.status caseInsensitiveCompare:@"online"])) {
            if (dev.img_ver && (NSOrderedAscending != [dev.img_ver caseInsensitiveCompare:MIPC_MIN_VERSION_DEVICE_PICK])) {
                menuITemArray = [NSArray arrayWithObjects:playItem,messageItem,settingItem, nil];
            }else{
            
                menuITemArray = [NSArray arrayWithObjects:playItem,settingItem, nil];
            }
            
        }else{
        
            menuITemArray = [NSArray arrayWithObjects:settingItem, nil];
        }
        if (dev && (NSOrderedSame == [dev.type caseInsensitiveCompare:@"box"])) {
            menuITemArray = [NSArray arrayWithObjects:settingItem, nil];
        }
        
        [menuController setMenuItems:menuITemArray];
        [menuController setArrowDirection:UIMenuControllerArrowDown];
        [menuController setTargetRect:CGRectMake(point.x, point.y, 0, 0) inView:longPressGuesture.view];
        [menuController setMenuVisible:YES animated:YES];
    }
}

-(void)playMenuItem:(id)sender
{
    [self performSegueWithIdentifier:@"MNDevicePlayViewController" sender:nil];
}

-(void)messageMenuItem:(id)sender
{
    [self performSegueWithIdentifier:@"MNMessagePageViewController" sender:nil];
}

-(void)settingMenuItem:(id)sender
{
    [self performSegueWithIdentifier:@"MNSettingsDeviceViewController" sender:nil];
}

#pragma mark - InterfaceOrientation
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView reloadData];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    _transitionToSize = size;
    [self.collectionView reloadData];
}

@end
