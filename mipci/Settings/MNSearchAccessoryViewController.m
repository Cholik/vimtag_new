//
//  MNSearchAccessoryViewController.m
//  mipci
//
//  Created by mining on 16/1/13.
//
//

#import "MNSearchAccessoryViewController.h"
#import "MNSearchAccessoryCollectionViewCell.h"
#import "MNCollectionReusableView.h"
#import "UIViewController+loading.h"
#import "MNToastView.h"
#import "MNInfoPromptView.h"
#import "MNProgressHUD.h"
#import "MNSetNickNameViewController.h"
#import "MNAddResultViewController.h"

#define DEFAULT_LINE_COUNTS      2
#define TIMEOUT                  90

@interface MNSearchAccessoryViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (nonatomic,assign,getter = isSearch) BOOL search;
@property (strong, nonatomic) NSMutableArray *accessoryArray;
@property (nonatomic,strong) NSTimer *searchTimer;
@property (nonatomic,strong) MNCollectionReusableView *collectionReusableView;

@property (strong, nonatomic) NSTimer *timeout;
@property (nonatomic, assign) int timeCount;
@property (assign,nonatomic) long rtime;;
@property (assign, nonatomic) BOOL isfailOfCancle;
@property (assign, nonatomic) BOOL isViewAppearing;

@end

static NSString *CellIdentifier = @"Cell";
static NSString *ReusableViewIdentifier = @"ReusableView";

@implementation MNSearchAccessoryViewController

-(MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_progressHUD];
        _progressHUD.color = [UIColor colorWithWhite:1.0f alpha:0.8f];
        _progressHUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        _progressHUD.labelText = NSLocalizedString(@"mcs_adding", nil);
        _progressHUD.labelColor = [UIColor grayColor];
//        if (self.app.is_vimtag) {
            _progressHUD.activityIndicatorColor = [UIColor colorWithRed:0 green:168.0/255 blue:185.0/255 alpha:1.0f];
//        }
//        else {
//            _progressHUD.activityIndicatorColor = [UIColor grayColor];
//        }
    }
    
    return  _progressHUD;
}

- (NSMutableArray *)accessoryArray
{
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    
    return _accessoryArray;
}

#pragma mark - initUI
-(void)initUI
{
    self.title = NSLocalizedString(@"mcs_add_accessory", nil);
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
//    self.exit = 0;
    _isViewAppearing = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _isViewAppearing = NO;
    [self.searchTimer invalidate];
    [self.timeout invalidate];
    self.search = NO;
    [self.collectionReusableView reviseUnsearchUI];
    [MNInfoPromptView hideAll:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
-(void)searchAccessory
{
    self.search = !self.search;
    if (self.search) {
        
        [self.collectionReusableView reviseSearchUI];
        mcall_ctx_exdev_discover *ctx = [[mcall_ctx_exdev_discover alloc] init];
        ctx.sn = _deviceID;
        ctx.flag = 1;
        ctx.SearchTimeout = 100 * 1000;
        ctx.target = self;
        ctx.on_event = @selector(exdev_discover_done:);
        [_agent exdev_discover:ctx];
        [self loading:YES];
    }
    else {
        [_searchTimer invalidate];
        [self.collectionReusableView reviseUnsearchUI];
    }
}

-(void)back
{
    //    mcall_ctx_dev_msg_listener_del *del = [[mcall_ctx_dev_msg_listener_del alloc] init];
    //    del.target = self;
    //    [self.agent dev_msg_listener_del:del];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MMQ
//- (void)dev_msg_listener:(mdev_msg *)msg
//{
//    if ([msg.type isEqualToString:@"exdev"]) {
//        if ([msg.code isEqualToString:@"add"]) {
//            if (msg.ok == 1) {
//            }
//            if (msg.exit == 1) {
//                self.exit = 1;
//            }
//        }
//    }
//}

#pragma mark - Call & Recall
-(void)exdev_discover_done:(mcall_ret_exdev_discover *)ret
{
    [self loading:NO];
    if (ret.result == nil) {
        _searchTimer = [NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(openDiscover) userInfo:self repeats:NO];
        
        mcall_ctx_exdev_get *ctx = [[mcall_ctx_exdev_get alloc] init];
        ctx.sn = _deviceID;
        ctx.start = 0;
        ctx.counts = 100;
        ctx.flag = 2;
        ctx.target = self;
        ctx.timeout = 10;
        ctx.on_event = @selector(exdev_get_done:);
        [_agent exdev_get:ctx];
    }else
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_search_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

-(void)exdev_get_done:(mcall_ret_exdev_get *)ret
{
    if (self.searchTimer.isValid == YES) {
        mcall_ctx_exdev_get *ctx = [[mcall_ctx_exdev_get alloc] init];
        ctx.sn = _deviceID;
        ctx.start = 0;
        ctx.counts = 100;
        ctx.flag = 2;
        ctx.target = self;
        ctx.timeout = 10;
        ctx.on_event = @selector(exdev_get_done:);
        [_agent performSelector:@selector(exdev_get:) withObject:ctx afterDelay:5.0];
    }
    
    if (ret.result == nil) {
        if (self.isSearch) {
            [self.accessoryArray removeAllObjects];
            for (mExDev_obj *dev in ret.exDevs) {
                if (dev.type == self.type) {
                    [self.accessoryArray addObject:dev];
                }
            }
            [self.collectionView reloadData];
        }
    }
}

-(void)exdev_add_done:(mcall_ret_exdev_add *)ret
{
//    [self loading:NO];
//    [self performSegueWithIdentifier:@"MNAddAccessoryViewController" sender:nil];
    
    mcall_ctx_exdev_get *ctx = [[mcall_ctx_exdev_get alloc] init];
    ctx.sn = _deviceID;
    ctx.flag = 3;
    ctx.target = self;
    ctx.exdev_id = self.exdevID;
    ctx.on_event = @selector(exdev_get_add_done:);
    [_agent exdev_get:ctx];
    self.timeout = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkAddResult) userInfo:nil repeats:YES];
    self.timeCount = TIMEOUT;
}

-(void)exdev_get_add_done:(mcall_ret_exdev_get *)ret
{
    if (ret.result == nil) {
        if (ret.exDevs.count == 1) {
            mExDev_obj *obj = ret.exDevs[0];
            if (obj.stat == 1) {
                _rtime = obj.rtime;
                [self.progressHUD hide:YES];
                if (_isViewAppearing) {
                    [self performSegueWithIdentifier:@"MNSetNickNameViewController" sender:ret.exDevs];
                }
                [self.timeout invalidate];
                return;
            }
        }
    }
    if (self.timeout.isValid) {
        mcall_ctx_exdev_get *ctx = [[mcall_ctx_exdev_get alloc] init];
        ctx.sn = _deviceID;
        ctx.flag = 3;
        ctx.target = self;
        ctx.exdev_id = self.exdevID;
        ctx.on_event = @selector(exdev_get_add_done:);
        [_agent performSelector:@selector(exdev_get:) withObject:ctx afterDelay:3.0];
    }
}

#pragma mark - checkAddRecall
-(void)checkAddResult
{
//    if (self.searchAccessoryViewController.exit) {
//        _isfailOfCancle = YES;
//        [self performSegueWithIdentifier:@"MNAddResultViewController" sender:nil];
//    }
    if (_timeCount == 0) {
        [self.progressHUD hide:YES];
        _isfailOfCancle = NO;
        if (_isViewAppearing) {
            [self performSegueWithIdentifier:@"MNAddResultViewController" sender:nil];
        }
    } else {
        self.timeCount -= 1;
    }
}

-(void)openDiscover
{
    [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_search_timeout", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    [self.searchTimer invalidate];
    self.search = NO;
    [self.collectionReusableView reviseUnsearchUI];
}

#pragma mark - <UICollectionViewDatasource>
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (!self.collectionReusableView) {
        self.collectionReusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
        self.collectionReusableView.searchView.layer.cornerRadius = 5.0;
        self.collectionReusableView.type = self.type;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchAccessory)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [self.collectionReusableView.searchView addGestureRecognizer:tapGestureRecognizer];
        if (self.isSearch) {
            [self.collectionReusableView reviseSearchUI];
        }else {
            [self.collectionReusableView reviseUnsearchUI];
        }
    }

    return self.collectionReusableView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.accessoryArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    MNSearchAccessoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (self.isSearch == NO) {
        cell.hidden = YES;
        collectionView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:241/255.0 alpha:1.0];
    }else
    {
        cell.hidden = NO;
        collectionView.backgroundColor = [UIColor whiteColor];
    }
    mExDev_obj *dev = self.accessoryArray[indexPath.row];
    switch (dev.type) {
            
        case 5:
            cell.imageView.image = [UIImage imageNamed:@"vt_sos"];
            break;
        case 6:
            cell.imageView.image = [UIImage imageNamed:@"vt_door-lock"];
            break;
            
        default:
            break;
    }
    cell.IDLabel.text = dev.exdev_id;
    [cell.addButton setTitle:NSLocalizedString(@"mcs_add", nil) forState:UIControlStateNormal];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    mExDev_obj *dev = self.accessoryArray[indexPath.row];
    _exdevID = dev.exdev_id;
    mcall_ctx_exdev_add *ctx = [[mcall_ctx_exdev_add alloc] init];
    ctx.sn = _deviceID;
    ctx.exdev_id = dev.exdev_id;
    ctx.model = 2;
    ctx.addTimeout = 90 * 1000;
    ctx.target = self;
    ctx.on_event = @selector(exdev_add_done:);
    [_agent exdev_add:ctx];
    [self.searchTimer invalidate];
    [self.progressHUD show:YES];
    
    //    mcall_ctx_dev_msg_listener_add *add = [[mcall_ctx_dev_msg_listener_add alloc] init];
    //    add.target = self;
    //    add.on_event = @selector(dev_msg_listener:);
    //    add.type = @"exdev";
    //    [self.agent dev_msg_listener_add:add];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight) {
            float width = [UIScreen mainScreen].bounds.size.width;
            itemSize = CGSizeMake(width / 4.0, 123);
        }else
        {
            float width = [UIScreen mainScreen].bounds.size.width;
            itemSize = CGSizeMake(width / 3.0, 123);
        }
    }
    else
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight) {
            
            float width = [UIScreen mainScreen].bounds.size.width;
            itemSize = CGSizeMake(width / 3.0, 123);
        }else
        {
            float width = [UIScreen mainScreen].bounds.size.width;
            itemSize = CGSizeMake(width / 2.0, 123);
        }
    }
    
    return itemSize;
}

#pragma mark - PrepareSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNSetNickNameViewController"]) {
        MNSetNickNameViewController *setNickNameViewController = segue.destinationViewController;
        setNickNameViewController.agent = _agent;
        setNickNameViewController.deviceID = _deviceID;
        setNickNameViewController.exdevID = _exdevID;
        setNickNameViewController.rtime = _rtime;
        setNickNameViewController.exdevs = sender;
    }
    else if ([segue.identifier isEqualToString:@"MNAddResultViewController"]) {
        MNAddResultViewController *addResultViewController = segue.destinationViewController;
        addResultViewController.isfailOfCanle = _isfailOfCancle;
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
