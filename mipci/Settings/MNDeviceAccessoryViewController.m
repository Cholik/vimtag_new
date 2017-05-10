//
//  MNDeviceAccessoryViewController.m
//  mipci
//
//  Created by mining on 16/1/12.
//
//

#define DEFAULT_LINE_COUNTS      2

#import "MNDeviceAccessoryViewController.h"
#import "MNAccessoryCell.h"
#import "MNSetAccessoryViewController.h"
#import "MNSelectAccessoryTypeViewController.h"
#import "UIViewController+loading.h"
#import "MNInfoPromptView.h"
#import "UIImageView+refresh.h"
#import "MNAccessorySceneViewController.h"
#import "MNAccessoryListCell.h"
#import "MNSetMotionTableViewController.h"

@interface MNDeviceAccessoryViewController () <UIScrollViewDelegate>

@property (nonatomic,strong) UILabel *downRefreshLabel;
@property (strong ,nonatomic) UIImageView *refreshImageView;
@property (strong, nonatomic) NSTimer *refreshTimer;
@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL isScrollerViewRelease;
@property (strong, nonatomic) NSMutableArray *sceneArray;
@property (assign, nonatomic) long addAccessory;

@end

@implementation MNDeviceAccessoryViewController

static NSString * const reuseIdentifier = @"Cell";

-(UIImageView *)refreshImageView
{
    if (_refreshImageView == nil) {
        _refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_vimtagRefresh"]];
    }
    return _refreshImageView;
}

-(UILabel *)downRefreshLabel
{
    if (_downRefreshLabel == nil) {
        _downRefreshLabel = [[UILabel alloc] init];
    }
    return _downRefreshLabel;
}

-(void)initUI
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancle)];
        self.navigationItem.leftBarButtonItem = item;
    }
    self.title = NSLocalizedString(@"mcs_accessory", nil);
    [self showScene:@"in"];
    [self.refreshImageView initRefreshWithLabel:self.downRefreshLabel and:self.collectionView];
    
    _addAccessory = 0;
     m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if (dev) {
        if (dev.add_accessory) {
            _addAccessory = 1;
        }
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    _isRefreshing = NO;
    [self refreshData];
    [self loading:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isRefreshing = NO;
    [MNInfoPromptView hideAll:_rootNavigationController];
    [self.refreshTimer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.refreshImageView layoutRefreshWithLabel:self.downRefreshLabel and:self.collectionView];
}

#pragma mark - Action
- (IBAction)changeScene:(id)sender
{
    [self performSegueWithIdentifier:@"MNAccessorySceneViewController" sender:nil];
}

-(void)cancle
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Call & Recall
-(void)scene_get_done:(mcall_ret_scene_get *)ret
{
    [self loading:NO];
    _isRefreshing = NO;
    if (_isScrollerViewRelease)
    {
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    if (ret.result == nil)
    {
        _sceneArray = ret.sceneArray;
        mScene_obj *obj = _sceneArray[1];
        self.accessoryArray = obj.exDevs;
        self.selectScene = ret.select;
        [self.collectionView reloadData];
        [self showScene:ret.select];
    }
    else
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_get_accessory_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}
- (void)refreshData
{
    if (!_isRefreshing)
    {
        mcall_ctx_scene_get *ctx = [[mcall_ctx_scene_get alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(scene_get_done:);
        [_agent scene_get:ctx];
        _isRefreshing = YES;
    }
}

-(void)showScene:(NSString *)select
{
    NSString *selectScene;
    
    if ([select isEqualToString:@"auto"]) {
        selectScene = NSLocalizedString(@"mcs_auto_mode", nil);
    } else if ([select isEqualToString:@"in"]) {
        selectScene = NSLocalizedString(@"mcs_home_mode", nil);
    } else {
        selectScene = NSLocalizedString(@"mcs_away_home_mode", nil);
    }
    _sceneLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"mcs_scenes", nil),selectScene];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.accessoryArray.count + _addAccessory;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNAccessoryListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (int i = 0; i < _sceneArray.count; i ++) {
        mScene_obj *obj = _sceneArray[i];
        if (indexPath.row < _accessoryArray.count) {
            sceneExdev_obj *dev = obj.exDevs[indexPath.row];
            [dic setValue:dev forKey:obj.name];
        }
    }
    cell.dic = dic;
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight) {
            
            float width = [UIScreen mainScreen].bounds.size.width;
            itemSize = CGSizeMake(width , 109);
        }else
        {
            float width = [UIScreen mainScreen].bounds.size.width;
            itemSize = CGSizeMake(width  ,109);
        }
    }
    else
    {
        float width = [UIScreen mainScreen].bounds.size.width;
        itemSize = CGSizeMake(width, 109);
    }
    return itemSize;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -24 && !_isScrollerViewRelease ) {
        _downRefreshLabel.hidden = NO;
        _downRefreshLabel.text = NSLocalizedString(@"mcs_down_refresh", nil);
        self.refreshImageView.hidden = YES;
    }
    if (scrollView.contentOffset.y  < -54 && !_isScrollerViewRelease){
        _downRefreshLabel.hidden = NO;
        _downRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
        self.refreshImageView.hidden = YES;
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -54) {
        _downRefreshLabel.text = NSLocalizedString(@"mcs_refreshing", nil);
        self.refreshImageView.hidden = NO;
        [self.refreshTimer invalidate];
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self.refreshImageView selector:@selector(start) userInfo:nil repeats:YES];
        _isScrollerViewRelease = YES;
        [scrollView setContentOffset:CGPointMake(0, -54) animated:YES];
        [self performSelector:@selector(refreshData) withObject:nil afterDelay:1.0f];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == 0) {
        _downRefreshLabel.text = NSLocalizedString(@"mcs_down_refresh", nil);
        _isScrollerViewRelease = NO;
        self.refreshImageView.hidden = YES;
        [self.refreshTimer invalidate];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.index = indexPath.row;
    if (indexPath.row < self.accessoryArray.count) {
        sceneExdev_obj *dev = (sceneExdev_obj *)self.accessoryArray[indexPath.row];
        if ([dev.exdev_id isEqualToString:@"motion"]) {
            [self performSegueWithIdentifier:@"MNSetMotionTableViewController" sender:nil];
        }else {
            [self performSegueWithIdentifier:@"MNSetAccessoryViewController" sender:nil];
        }
    }else {
        [self performSegueWithIdentifier:@"MNSelectAccessoryTypeViewController" sender:nil];
    }
}
#pragma mark - PrepareForSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *viewController = segue.destinationViewController;
    [viewController setValue:_agent forKey:@"agent"];
    [viewController setValue:_deviceID forKey:@"deviceID"];
    
    if ([segue.identifier isEqualToString:@"MNSetAccessoryViewController"]) {
        MNSetAccessoryViewController *setAccessoryViewController = segue.destinationViewController;
        setAccessoryViewController.sceneArray = _sceneArray;
        setAccessoryViewController.index = self.index;
        setAccessoryViewController.deviceAccessoryViewController = self;
        setAccessoryViewController.selectScene = self.selectScene;
    }else if ([segue.identifier isEqualToString:@"MNAccessorySceneViewController"]) {
        MNAccessorySceneViewController *accessorySceneViewController = segue.destinationViewController;
        accessorySceneViewController.deviceAccessoryViewController = self;
        accessorySceneViewController.selectScene = self.selectScene;
        
    }else if ([segue.identifier isEqualToString:@"MNSetMotionTableViewController"]) {
        MNSetMotionTableViewController *setMotionTableViewController = segue.destinationViewController;
        setMotionTableViewController.sceneArray = _sceneArray;
        setMotionTableViewController.deviceAccessoryViewController = self;
        setMotionTableViewController.selectScene = self.selectScene;
    }
}

#pragma mark - InterfaceOrientation
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView reloadData];
}


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
