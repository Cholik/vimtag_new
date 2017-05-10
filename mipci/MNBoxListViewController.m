//
//  MNBoxListViewController.m
//  mipci
//
//  Created by weken on 15/4/7.
//
//

#define DEFAULT_LINE_COUNTS       2
#define DEFAULT_CELL_MARGIN       4
#define DEFAULT_EDGE_MARGIN       5

#import "MNBoxListViewController.h"
#import "MNDeviceListSetViewController.h"
#import "MNBoxTabBarController.h"
#import "MNBoxRecordsViewController.h"
#import "MNBoxPageViewController.h"
#import "MNSettingsDeviceViewController.h"

#import "MNBoxViewCell.h"
#import "MNInfoPromptView.h"
#import "UIImageView+refresh.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNProgressHUD.h"
#import "MNConfiguration.h"
#import "MIPCUtils.h"
#import "MNToastView.h"

@interface MNBoxListViewController ()

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (strong, nonatomic) UIActivityIndicatorView *pullUpActivityView;
@property (strong ,nonatomic) UIImageView *refreshImageView;
@property (strong, nonatomic) UILabel *downRefreshLabel;

@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSTimer *refreshTimer;
@property (assign, nonatomic) CGSize transitionToSize;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL isScrollerViewRelease;
@property (assign, nonatomic) int lastMessageTick;
@property (assign, nonatomic) int messageSoundID;
@property (strong, nonatomic) NSString *deleteIPCID;
@property (assign, nonatomic) BOOL  isDeleteIPC;

@end

@implementation MNBoxListViewController

static NSString * const reuseIdentifier = @"Cell";

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

- (MNProgressHUD *)progressHUD
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

- (UIImageView *)refreshImageView
{
    if (_refreshImageView == nil) {
        _refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_vimtagRefresh"]];
    }
    return _refreshImageView;
}

#pragma mark - Life Cycle
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"mcs_play", nil)];
        if (self.app.is_sereneViewer) {
            self.navigationController.tabBarItem.image = [[UIImage imageNamed:@"tab_video_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_video_selected.png"]];
        
        if (self.app.is_vimtag)
        {
            self.hidesBottomBarWhenPushed = YES;
        }
    }
    
    return self;
}

- (void)initUI
{
    self.navigationItem.title = [NSString stringWithFormat:@"box:%@", _boxID];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    self.collectionView.alwaysBounceVertical = YES;

    _downRefreshLabel = [[UILabel alloc] init];
    CGRect downRefreshLabelFrame = _downRefreshLabel.frame;
    downRefreshLabelFrame = CGRectMake(0, -35, 300, 40);
    //    downRefreshLabelFrame.origin.y = -35;
    _downRefreshLabel.frame = downRefreshLabelFrame;
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.collectionView.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    
    _downRefreshLabel.font = [UIFont systemFontOfSize:16];
    _downRefreshLabel.textAlignment = NSTextAlignmentCenter;
    _downRefreshLabel.textColor = self.configuration.labelTextColor;
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
        
        [self.refreshImageView setImageViewFrame:self.collectionView with:labelSize];
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
        center.x = self.collectionView.center.x - labelSize.width / 2.0 - 15;
        _pullUpActivityView.center = center;
        //    [self.collectionView addSubview:_pullUpActivityView];
    }

    if (!self.app.is_luxcam && !self.app.is_vimtag && !self.app.is_ebitcam && !self.app.is_mipc) {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
            negativeSpacer.width = -10.0;
        }
        else
        {
            negativeSpacer.width = 0.0;
        }
        
        [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, leftBarButtonItem] animated:YES];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:self.app.is_ebitcam ? @"eb_navbar_bg.png" : (self.app.is_mipc ? @"mi_navbar_bg.png" : @"navbar_bg.png")] forBarMetrics:UIBarMetricsDefault];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.devices = [NSMutableArray array];
    
    if (!self.app.is_luxcam && ! self.app.is_vimtag && !self.app.is_ebitcam && !self.app.is_mipc) {
        MNBoxTabBarController *boxTabBarController = (MNBoxTabBarController*)self.tabBarController;
        _boxID = boxTabBarController.boxID;
    }
    else
    {
        //update prompt
        mcall_ctx_upgrade_get *ctx = [[mcall_ctx_upgrade_get alloc] init];
        ctx.sn = _boxID;
        ctx.target = self;
        ctx.on_event = @selector(upgrade_get_done:);
        
        [self.agent upgrade_get:ctx];
    }
    
    //init UI
    [self initUI];
    
    m_dev *dev = [self.agent.devs get_dev_by_sn:_boxID];
    _isDeleteIPC = NO;
    if (dev) {
        if (dev.del_ipc && dev.timeZone.length) {
            _isDeleteIPC = YES;
        } else {
            mcall_ctx_dev_info_get *ctx = [[mcall_ctx_dev_info_get alloc] init];
            ctx.sn = _boxID;
            ctx.target = self;
            ctx.on_event = @selector(dev_info_get_done:);
            [self.agent dev_info_get:ctx];
        }
    }
    
    mcall_ctx_box_get *ctx = [[mcall_ctx_box_get alloc] init];
    ctx.sn = _boxID;
    ctx.flag = 1;
    ctx.target = self;
    ctx.on_event = @selector(box_get_ipcs_done:);
    
    [self.agent box_get:ctx];
    [self.progressHUD show:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = NO;
    if (self.app.is_vimtag) {
        MNDeviceListSetViewController *deviceListSetViewController = self.navigationController.viewControllers.firstObject;
        deviceListSetViewController.navigationController.navigationBarHidden = NO;
    }
    
    _transitionToSize = self.view.bounds.size;
    _isViewAppearing = YES;
    _isRefreshing = NO;
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MNInfoPromptView hideAll:self.navigationController];
    if (self.app.is_vimtag) {
        [self.refreshTimer invalidate];
    }
    _isViewAppearing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

#pragma mark - Action
- (void)back:(id)sender
{
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backTo:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)settingDevice:(id)sender
{
    [self performSegueWithIdentifier:@"MNSettingsDeviceViewController" sender:_boxID];
}

- (IBAction)settings:(id)sender
{
    [self performSegueWithIdentifier:@"MNSettingsDeviceViewController" sender:_boxID];
}

- (void)refreshData
{
    if (!_isRefreshing) {
        mcall_ctx_box_get *ctx = [[mcall_ctx_box_get alloc] init];
        ctx.sn = _boxID;
        ctx.flag = 1;
        ctx.target = self;
        ctx.on_event = @selector(box_get_ipcs_done:);
        
        [self.agent box_get:ctx];
        _isRefreshing = YES;
    }
}

#pragma mark - InterfaceOrientation
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //    [self updateCollectionViewFlowLayout];
    [self.collectionView reloadData];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    _transitionToSize = size;
    [self.collectionView reloadData];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"MNBoxRecordsViewController"])
    {
        if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            MNBoxRecordsViewController *boxRecordsViewController = segue.destinationViewController;
            boxRecordsViewController.deviceID = sender;
            boxRecordsViewController.boxID = _boxID;
        } else {
            MNBoxRecordsViewController *boxRecordsViewController = [[(UINavigationController *)(segue.destinationViewController) childViewControllers] objectAtIndex:0];
            boxRecordsViewController.deviceID = sender;
            boxRecordsViewController.boxID = _boxID;
        }
        
        
    }
    else if([segue.identifier isEqualToString:@"MNSettingsDeviceViewController"])
    {
        MNSettingsDeviceViewController *settingDeviceViewController = segue.destinationViewController;
        settingDeviceViewController.deviceID = sender;
        settingDeviceViewController.ver_valid = _ver_valid;
    }
    else if ([segue.identifier isEqualToString:@"MNBoxPageViewController"])
    {
        if (self.app.is_vimtag || self.app.is_luxcam  || self.app.is_ebitcam || self.app.is_mipc) {
            MNBoxPageViewController *boxPageViewController = segue.destinationViewController;
            boxPageViewController.boxID = _boxID;
            boxPageViewController.deviceID = sender;
        }
        else{
            MNBoxPageViewController *boxPageViewController = [[(UINavigationController *)(segue.destinationViewController) childViewControllers] objectAtIndex:0];
            boxPageViewController.boxID = _boxID;
            boxPageViewController.deviceID = sender;
        }
    }
}

/*coding for box*/
#pragma mark - Callback
- (void)box_get_ipcs_done:(mcall_ret_box_get*)ret
{
    _isRefreshing = NO;
    
    [self.progressHUD hide:YES];
    if (_isScrollerViewRelease)
    {
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    if (nil != ret.result) {
        if ([ret.result isEqualToString:@"ret.no.rsp"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_access_server_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        return;
    }
    
    self.devices = ret.ipc_array;
    
    [self.collectionView reloadData];
}

- (void)upgrade_get_done:(mcall_ret_upgrade_get *)ret
{
    if ((ret.ver_valid.length != 0 && ret.ver_current.length != 0 && ![ret.ver_valid isEqualToString:ret.ver_current])
        || (ret.hw_ext.length != 0 && ![ret.hw_ext isEqualToString:ret.prj_ext])){
        UIView *badgeView = [[UIView alloc]init];
        badgeView.layer.cornerRadius = 7;//
        badgeView.backgroundColor = [UIColor redColor];//
        badgeView.frame = CGRectMake( 22, 3, 14, 14); //(_settingButton.center.x +15,);
        [_settingButton addSubview:badgeView];
        
        _ver_valid = YES;
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.devices.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNBoxViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    ipc_obj *ipc = [self.devices objectAtIndex:indexPath.row];
    
    cell.online = ipc.online;
    cell.deviceID = ipc.sn;
    cell.boxID = _boxID;
    cell.nickLabel.text = ipc.nick.length ? ipc.nick : ipc.sn;

    if (self.app.is_luxcam)
    {
        cell.backgroundImageView.image = [UIImage imageNamed:@"placeholder.png"];
    }
    else if (self.app.is_vimtag)
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
        cell.backgroundImageView.image = [UIImage imageNamed:@"camera_placeholder.png"];
    }
    [cell loadWebImage];

    if (_isDeleteIPC) {
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [cell addGestureRecognizer:longPressGestureRecognizer];
    }
    
    return cell;
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
//    m_dev *dev = [self.agent.devs get_dev_by_index:indexPath.row];
    ipc_obj *ipc = [self.devices objectAtIndex:indexPath.row];
    
    NSString *deviceID = ipc.sn;
//    [self performSegueWithIdentifier:@"MNBoxRecordsViewController" sender:deviceID];
    [self performSegueWithIdentifier:@"MNBoxPageViewController" sender:deviceID];
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
        else if (self.app.is_vimtag  || self.app.is_ebitcam || self.app.is_mipc)
        {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 96 / 153 + 21);
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
//            NSInteger screenWidth = [UIDevice currentDevice].systemVersion.floatValue < 8.0 ? CGRectGetWidth(self.view.bounds) : self.transitionToSize.width;
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? width : height;
            //            CGFloat screenWidth = width > height ? width : height;
            if (self.app.is_luxcam) {
                
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else if (self.app.is_vimtag  || self.app.is_ebitcam || self.app.is_mipc)
            {
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 96 / 153 + 21);
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
//            NSInteger screenWidth = [UIDevice currentDevice].systemVersion.floatValue < 8.0 ? CGRectGetWidth(self.view.bounds) : self.transitionToSize.width;
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? height : width;
            //            CGFloat screenWidth = width <  height ? width : height;
            
            if (self.app.is_luxcam) {
                int lineCounts = DEFAULT_LINE_COUNTS;
                CGFloat cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
            {
                int lineCounts = DEFAULT_LINE_COUNTS;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 96 / 153 + 21);
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

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */
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
            [self.refreshTimer invalidate];
            self.refreshImageView.hidden = NO;
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
            [self.refreshTimer invalidate];
            self.refreshImageView.hidden = YES;
        }
        else {
            [_pullUpActivityView stopAnimating];
        }
    }
}

#pragma mark - handleLongPress
- (void)handleLongPress:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [recognizer locationInView:recognizer.view];
        MNBoxViewCell *cell = ((MNBoxViewCell *)recognizer.view);
        _deleteIPCID = cell.deviceID;
        [self becomeFirstResponder];
        
        UIMenuController *popMenuController = [UIMenuController sharedMenuController];
        UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"mcs_delete", nil) action:@selector(onMenuItemDelete:)];
        NSArray *menuItemArray = [NSArray arrayWithObject:deleteMenuItem];
        [popMenuController setMenuItems:menuItemArray];
        [popMenuController setArrowDirection:UIMenuControllerArrowDown];
        [popMenuController setTargetRect:CGRectMake(point.x, point.y, 0, 0) inView:recognizer.view];
        [popMenuController setMenuVisible:YES animated:YES];
    }
}

- (void)onMenuItemDelete:(id)sender
{
    NSString *info = NSLocalizedString(@"mcs_are_you_sure_delete", nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:info
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
    [alertView show];
}

#pragma mark - becomeFirstResponder
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(onMenuItemDelete:)) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex !=  alertView.cancelButtonIndex) {
        mcall_ctx_box_set *ctx = [[mcall_ctx_box_set alloc] init];
        
        ctx.sn = _boxID;
        ctx.dev_sn = _deleteIPCID;
        ctx.cmd = @"erase_all";
        ctx.target = self;
        ctx.on_event = @selector(box_set_done:);
        [self.agent box_set:ctx];
        _progressHUD.labelText = NSLocalizedString(@"mcs_deleting", nil);
        [self.progressHUD show:YES];
    }
}

- (void)box_set_done:(mcall_ret_box_set *)ret
{
    [_progressHUD hide:YES];
    if (!_isViewAppearing) {
        return;
    }
    if ([ret.result isEqualToString:@"ret.permission.denied"]) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_permission_denied", nil)]];
        }
        return;
    }else if(nil != ret.result){
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_delete_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_delete_fail", nil)]];
        }
        return;
    }
    
    if (self.app.is_InfoPrompt) {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_delete_success", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
    }
    else
    {
        [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_delete_success", nil)]];
    }
    @try {
        int index = 0;
        int deleteFlag = 0;
        for (ipc_obj *obj in self.devices)
        {
            if ([obj.sn isEqualToString:_deleteIPCID]) {
                deleteFlag = 1;
                break;
            }
            index++;
        }
        
        if (deleteFlag) {
            [self.devices removeObjectAtIndex:index];
            [self.collectionView reloadData];
        }
    } @catch (NSException *exception) {
        NSLog(@"exception:%@", exception);
    } @finally {
        
    }
}

- (void)dev_info_get_done:(mcall_ret_dev_info_get *)ret
{
    if (ret.result == nil)
    {
        m_dev *device = [self.agent.devs get_dev_by_sn:_boxID];
        if (ret.del_ipc) {
            _isDeleteIPC = YES;
            device.del_ipc = ret.del_ipc;
            if (_isViewAppearing) {
                [self.collectionView reloadData];
            }
        }
        if (ret.timezone.length) {
            device.timeZone = ret.timezone;
        }
    }
}

@end
