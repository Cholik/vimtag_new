//
//  MNDeviceListSetViewController.m
//  mipci
//
//  Created by mining on 16/3/29.
//
//

#import "MNDeviceListSetViewController.h"
#import "MNDeviceListViewController.h"
#import "MNGuideNavigationController.h"
#import "MIPCUtils.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "UIViewController+loading.h"
#import "MNToastView.h"
#import "MNSceneButtonBackView.h"

#define HEADERVIEWUNROTATESHOWHEIGHT 139.0f
#define HEADERVIEWUNROTATEUNSHOWHEIGHT 64.0f
#define HEADERVIEWROTATESHOWHEIGHT 119.0f
#define HEADERVIEWROTATEUNSHOWHEIGHT 39.0f
#define SCENEVIEWUNROTATETOP 0
#define SCENEVIEWROTATETOP -25.0f
#define AUTOBUTTONTAG 1001
#define ACTIVEBUTTONTAG 1002
#define AWAYBUTTONTAG 1003
#define QUIETBUTTONTAG  1004

#define COLOR_NORMAL_SYN    [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0]
#define COLOR_ERROR_SYN     [UIColor colorWithRed:255./255. green:194./255. blue:85./255. alpha:1.0]

@interface MNDeviceListSetViewController () <DeviceListSetHeaderViewDelegate>

@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mdev_devs *devices;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTop;
@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *rightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *topConstraint;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) NSMutableArray *sceneSetArray;;
@property (strong ,nonatomic) NSString *selectSceneName;
@property (assign, nonatomic) NSInteger recallIndex;

@end

@implementation MNDeviceListSetViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

- (MNDeviceListSetHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[[NSBundle mainBundle] loadNibNamed:@"MNDeviceListSetHeaderView" owner:self options:nil] lastObject];
        _headerView.delegate = self;
    }
    return _headerView;
}

-(NSMutableArray *)sceneSetArray
{
    if (_sceneSetArray == nil) {
        _sceneSetArray = [NSMutableArray array];
    }
    return _sceneSetArray;
}

#pragma mark - Life Cycle
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"mcs_device",nil) image:[UIImage imageNamed:@"vt_equipment_idle"] tag:1];
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"vt_equipment"];
    }
    
    return self;
}

- (void)initUI
{
    [self.view addSubview:self.headerView];
    
    _leftConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    _rightConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    _topConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeTop  relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop  multiplier:1.0f constant:0.0f];
    _heightConstraint = [NSLayoutConstraint constraintWithItem:self.headerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:HEADERVIEWUNROTATESHOWHEIGHT];
    NSArray *array = @[_leftConstraint,_rightConstraint,_topConstraint,_heightConstraint];
    [self.view addConstraints:array];
    
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self checkUserOnlie];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}

#pragma mark - Action
- (void)addDevice
{
    UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"GuideStoryboard" bundle:nil];
    MNGuideNavigationController *guideNavigationController;
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
    [self presentViewController:guideNavigationController animated:YES completion:nil];
}

- (void)chooseScene:(UIButton *)sender
{
    NSString *selectScene;
    if (sender.tag == ACTIVEBUTTONTAG)
    {
        selectScene = @"in";
    }
    else if (sender.tag == AUTOBUTTONTAG)
    {
        if (!((UISwitch *)sender).on) {
            selectScene = @"out";
        } else {
            selectScene = @"auto";
        }
    }
    else
    {
        selectScene = @"out";
    }
    [self sceneStyleChange:selectScene];

    self.selectSceneName = selectScene;
    [self startSceneLoadingAndShowSceneBtnBackView];
    self.recallIndex = 0;
    
    [[NSUserDefaults standardUserDefaults] setObject:selectScene forKey:@"scene"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self scene_set_done:nil];
}

- (void)sceneStyleChange:(NSString *)sceneName
{
    NSInteger tag = 0;
    if ([sceneName isEqualToString:@"auto"])
    {
        tag = AUTOBUTTONTAG;
    }
    else if ([sceneName isEqualToString:@"in"])
    {
        tag = ACTIVEBUTTONTAG;
    }
    else
    {
        tag = AWAYBUTTONTAG;
    }
    
    
    self.headerView.activeButton.selected = ((tag !=AUTOBUTTONTAG) && (tag != AWAYBUTTONTAG)) ? YES : NO;
    self.headerView.awayButton.selected = (tag == AWAYBUTTONTAG) ? YES : NO;
    self.headerView.autoLabel.highlighted = (tag == AUTOBUTTONTAG) ? YES : NO;
    self.headerView.autoSwitch.on = (tag == AUTOBUTTONTAG) ? YES : NO;
    
    [self synStatusHidden:YES];
}

- (void)synStatusHidden:(BOOL)hidden
{
    if (hidden) {
        self.headerView.homeSynButton.hidden = YES;
        self.headerView.outSynButton.hidden = YES;
        self.headerView.autoSynButton.hidden = YES;
        [self synButtonColorSet:0];
    } else {
        self.headerView.homeSynButton.hidden = self.headerView.activeButton.selected ? NO : YES;
        self.headerView.outSynButton.hidden = self.headerView.awayButton.selected ? NO : YES;
        self.headerView.autoSynButton.hidden = self.headerView.autoLabel.highlighted ? NO : YES;
        [self synButtonColorSet:1];
    }
}

- (void)synButtonColorSet:(NSInteger)index
{
    if (index) {
        [self.headerView.activeButton setTitleColor:COLOR_ERROR_SYN forState:UIControlStateSelected];
        [self.headerView.awayButton setTitleColor:COLOR_ERROR_SYN forState:UIControlStateSelected];
        [self.headerView.autoLabel setHighlightedTextColor:COLOR_ERROR_SYN];
    } else {
        [self.headerView.activeButton setTitleColor:COLOR_NORMAL_SYN forState:UIControlStateSelected];
        [self.headerView.awayButton setTitleColor:COLOR_NORMAL_SYN forState:UIControlStateSelected];
        [self.headerView.autoLabel setHighlightedTextColor:COLOR_NORMAL_SYN];
    }
}

#pragma mark - Callback
- (void)scene_set_done:(mcall_ret_scene_set *)ret
{
    if (ret.result == nil) {
        
    }
    if (self.recallIndex == self.sceneSetArray.count) {
        mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
        ctx.target = self;
        ctx.on_event = @selector(devs_refresh_done:);
        [self.agent devs_refresh:ctx];
    } else {
        m_dev *dev = nil;
        for ( ; self.recallIndex < self.sceneSetArray.count; self.recallIndex++) {
            dev = self.sceneSetArray[self.recallIndex];
            if (NSOrderedSame == [dev.status caseInsensitiveCompare:@"online"]) {
                break;
            }
        }
        if (self.recallIndex >= self.sceneSetArray.count) {
            mcall_ctx_devs_refresh *ctx = [[mcall_ctx_devs_refresh alloc] init];
            ctx.target = self;
            ctx.on_event = @selector(devs_refresh_done:);
            [self.agent devs_refresh:ctx];
            return;
        }
        mcall_ctx_scene_set *ctx = [[mcall_ctx_scene_set alloc] init];
        ctx.sn = dev.sn;
        ctx.select = self.selectSceneName;
        ctx.all = 0;
        ctx.target = self;
        ctx.on_event = @selector(scene_set_done:);
        ctx.timeout = 10;
        [self.agent scene_set:ctx];
        self.recallIndex ++;
    }
}

- (void)devs_refresh_done:(mcall_ret_devs_refresh *)ret
{
    [self stopSceneLoadingAndHideSceneBtn];
    if (ret.result == nil) {
        self.devices = ret.devs;
        [self resetSceneSetArray];
        [self checkSynchronize:self.selectSceneName inArray:self.sceneSetArray];
    }
}

#pragma mark - Refresh Scene
- (void)refreshCurrentScene
{
    _devices = _deviceListViewController.devices;
    [self resetSceneSetArray];
    
    NSString *sceneName = [[NSUserDefaults standardUserDefaults] objectForKey:@"scene"];
    if (sceneName != nil) {
        self.selectSceneName = sceneName;
        [self sceneStyleChange:sceneName];
    }
    else
    {
        int autoCount = 0, outCount = 0, activeCount = 0, sceneCount = 0;
        for (int i = 0; i < self.devices.counts; i ++) {
            
            m_dev *dev = [self.devices get_dev_by_index:i];
            sceneName = dev.scene;
            
            if (sceneName == nil) {
                continue;
            }
            if ([sceneName isEqualToString:@"auto"]) {
                autoCount ++;
            }
            else if ([sceneName isEqualToString:@"in"])
            {
                activeCount ++;
            }
            else
            {
                outCount ++;
            }
        }
        
        sceneName = autoCount >= activeCount ? @"auto" : @"in";
        sceneCount = autoCount >= activeCount ? autoCount : activeCount;
        
        sceneName = sceneCount >= outCount ? sceneName : @"out";
        sceneCount = sceneCount >= outCount ? sceneCount : outCount;
        
        self.selectSceneName = sceneName;
        [self sceneStyleChange:sceneName];
        [[NSUserDefaults standardUserDefaults] setObject:sceneName forKey:@"scene"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self checkSynchronize:self.selectSceneName inArray:self.sceneSetArray];
}

- (void)checkSynchronize:(NSString *)sceneName inArray:(NSMutableArray*)sceneSetArray
{
    [self synStatusHidden:YES];
    
    NSString *scene_open = [[NSUserDefaults standardUserDefaults] stringForKey:@"f_profile"];
    for (m_dev *dev in sceneSetArray) {
        if (![dev.scene isEqualToString:sceneName]) {
            if (scene_open.length > 0 || self.app.developerOption.sceneSwitch) {
                [self synStatusHidden:NO];
                return;
            }
        }
    }
}

- (void)stopSceneLoadingAndHideSceneBtn
{
    self.headerView.secneView.userInteractionEnabled = YES;
}

- (void)startSceneLoadingAndShowSceneBtnBackView
{
    self.headerView.secneView.userInteractionEnabled = NO;
    if ([self.selectSceneName isEqualToString:@"auto"]) {
        //
    }
    if ([self.selectSceneName isEqualToString:@"out"]) {

    }
    if ([self.selectSceneName isEqualToString:@"in"]) {
       
    }
}

- (void)resetSceneSetArray
{
    [self.sceneSetArray removeAllObjects];
    for (int i = 0; i < self.devices.counts; i ++) {
        m_dev *dev = [self.devices get_dev_by_index:i];
        if (dev.support_scene) {
            [self.sceneSetArray addObject:dev];
        }
    }
}

- (void)showOrHideSceneView
{
    if (!self.headerView.isShowing) {
        
        [UIView animateWithDuration:0.75 animations:^{
            [self checkRotate:YES];
            [self.view layoutIfNeeded];
        }];
        
        self.headerView.showing = YES;
    } else {
        [UIView animateWithDuration:0.75 animations:^{
            [self checkRotate:NO];
            [self.view layoutIfNeeded];
        }];
        
        self.headerView.showing = NO;
    }
}

- (void)synchronizeScene
{
    _deviceListViewController.selectSceneName = self.selectSceneName;
    _deviceListViewController.devices = self.devices;
    [_deviceListViewController performSegueWithIdentifier:@"MNSynchronizeViewController" sender:nil];
}

- (void)checkUserOnlie
{
    if (self.app.is_userOnline)
    {
        NSString *scene_open = [[NSUserDefaults standardUserDefaults] stringForKey:@"f_profile"];
        if (scene_open.length > 0 || self.app.developerOption.sceneSwitch) {
            self.headerView.showSceneBtn.hidden = NO;
//            self.headerView.synchronizeBtn.hidden = NO;
            self.headerView.addButton.hidden = NO;
        }
        else {
            self.headerView.showSceneBtn.hidden = YES;
//            self.headerView.synchronizeBtn.hidden = YES;
            self.headerView.addButton.hidden = NO;
        }
    }
    else
    {
        self.headerView.showSceneBtn.hidden = YES;
        self.headerView.addButton.hidden = YES;
//        self.headerView.synchronizeBtn.hidden = YES;
        self.headerView.showing = NO;
        
    }
    [self checkRotate:self.headerView.isShowing];
}

#pragma mark - Refresh Constraint
- (void)checkRotate:(BOOL)show
{
    if (show) {
        [self setHeightConstraint:HEADERVIEWUNROTATESHOWHEIGHT containerViewTopConstant:HEADERVIEWUNROTATESHOWHEIGHT sceneTopConstant:SCENEVIEWUNROTATETOP showSceneButtonImageString:@"vt_up" backGroundImageString:@"vt_navigation"];
    } else {
        
        [self setHeightConstraint:HEADERVIEWUNROTATEUNSHOWHEIGHT containerViewTopConstant:HEADERVIEWUNROTATEUNSHOWHEIGHT sceneTopConstant:-105.0f showSceneButtonImageString:@"vt_down" backGroundImageString:@"vt_navigation"];
    }
}

- (void)setHeightConstraint:(float)heightConstraint containerViewTopConstant:(float)containerViewTopConstant sceneTopConstant:(float)sceneTopConstant showSceneButtonImageString:(NSString *)btnImage backGroundImageString:(NSString *)backGroundImage
{
    self.heightConstraint.constant = heightConstraint;
    self.containerViewTop.constant = containerViewTopConstant;
    self.headerView.sceneTop.constant = sceneTopConstant;
    [self.headerView.showSceneBtn setImage:[UIImage imageNamed:btnImage] forState:UIControlStateNormal];
    self.headerView.backGroudView.image = [UIImage imageNamed:backGroundImage];
}

#pragma mark - InterfaceOrientation
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

//Fixed iOS 7　
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
#endif

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNDeviceListViewController"]) {
        _deviceListViewController = segue.destinationViewController;
        _deviceListViewController.deviceListSetViewController = self;
    }
}

@end
