//
//  MNDeviceSettingsViewController.m
//  mipci
//
//  Created by weken on 15/2/9.
//
//

#import "MNSettingsDeviceViewController.h"
#import "mipc_agent.h"
#import "MNDeviceTabBarController.h"
#import "MNDetailViewController.h"
#import "MNDeviceSettingsViewController.h"
#import "AppDelegate.h"
//#import "MNDeviceListPageViewController.h"
#import "MNBoxTabBarController.h"
#import "MNDeviceListSetViewController.h"
#import "MNRootNavigationController.h"
#import "MNLocalDeviceListViewController.h"

@interface MNSettingsDeviceViewController ()
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@end

@implementation MNSettingsDeviceViewController

- (void)dealloc
{

}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"mcs_settings", nil)];
        if (self.app.is_sereneViewer)
        {
            [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor blackColor], UITextAttributeTextColor,
                                                               nil] forState:UIControlStateNormal];
            UIColor *titleHighlightedColor = [UIColor whiteColor];
            [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               titleHighlightedColor, UITextAttributeTextColor,
                                                               nil] forState:UIControlStateSelected];
            self.navigationController.tabBarItem.image = [[UIImage imageNamed:@"tab_settings_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        
        [self.navigationController.tabBarItem setSelectedImage:
         [UIImage imageNamed:@"tab_settings_selected.png"]];
        if (self.app.is_vimtag)
        {
            self.hidesBottomBarWhenPushed = YES;
        }
    }
    
    return self;
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
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.app.is_luxcam && !self.app.is_vimtag && !self.app.is_ebitcam && !self.app.is_mipc) {
        
        if ([self.tabBarController isKindOfClass:[MNDeviceTabBarController class]])
        {
            MNDeviceTabBarController *deviceTabBarViewController = (MNDeviceTabBarController*)self.tabBarController;
            _deviceID = deviceTabBarViewController.deviceID;
            _deviceListViewController = deviceTabBarViewController.deviceListViewController;
        }
        else
        {
            MNBoxTabBarController *boxTabBarController = (MNBoxTabBarController *)self.tabBarController;
            _deviceID = boxTabBarController.boxID;
        }
    }
    else
    {
        if ([self.tabBarController isKindOfClass:[MNBoxTabBarController class]]) {
            MNBoxTabBarController *boxTabBarController = (MNBoxTabBarController *)self.tabBarController;
            _deviceID = boxTabBarController.boxID;
            _isBox = YES;
        }
        for (UIViewController *viewController in self.navigationController.viewControllers)
        {
            if ([viewController isMemberOfClass:[MNDeviceListViewController class]])
            {
                _deviceListViewController = (MNDeviceListViewController *)viewController;
            }
        }
    }
    
    UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil];
    MNRootNavigationController *settingsNavigationController = settingsStoryboard.instantiateInitialViewController;
    _settingsViewController = [settingsNavigationController.viewControllers firstObject];
    //KVC
//    _agent = [mipc_agent shared_mipc_agent];
    _settingsViewController.agent = self.agent;
    _settingsViewController.deviceID = _deviceID;
    _settingsViewController.isLoginByID = _isLoginByID;
    _settingsViewController.deviceListViewController = _deviceListViewController;
    if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        _settingsViewController.ver_valid = _ver_valid;
    }
//    [settingsViewController setValue:_agent forKey:@"agent"];
//    [settingsViewController setValue:_deviceID forKey:@"deviceID"];
//    [settingsViewController setValue:[NSNumber numberWithBool:_isLoginByID] forKey:@"isLoginByID"];
//    [settingsViewController setValue:_deviceListViewController forKey:@"deviceListViewController"];
    
    __weak typeof(self) weakSelf = self;
    _settingsViewController.back = ^(BOOL isBack){
        if (isBack) {
            if (weakSelf.navigationController) {
                if (weakSelf.isBox) {
                    [weakSelf.tabBarController dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else
        {
            if (weakSelf.app.is_vimtag) {
                if (weakSelf.navigationController) {
                    [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
                    if (weakSelf.app.isLocalDevice) {
                        for (UIViewController *viewController in weakSelf.navigationController.viewControllers) {
                            if ([viewController isMemberOfClass:[MNLocalDeviceListViewController class]]) {
                                [weakSelf.navigationController popToViewController:viewController animated:YES];
                            }
                        }
                    } else {
                        for (UIViewController *viewController in weakSelf.navigationController.viewControllers) {
                            if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                                [weakSelf.navigationController popToViewController:viewController animated:YES];
                            }
                        }
                    }
                }
            } else if (weakSelf.app.is_ebitcam || weakSelf.app.is_mipc){
                if (weakSelf.isBox) {
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                } else {
                    if (weakSelf.app.isLocalDevice) {
                        if (weakSelf.navigationController) {
                            [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
                            for (UIViewController *viewController in weakSelf.navigationController.viewControllers) {
                                if ([viewController isMemberOfClass:[MNLocalDeviceListViewController class]]) {
                                    [weakSelf.navigationController popToViewController:viewController animated:YES];
                                }
                            }
                        }
                    } else {
                        if (weakSelf.navigationController) {
                            [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
                            for (UIViewController *viewController in weakSelf.navigationController.viewControllers) {
                                if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                                    [weakSelf.navigationController popToViewController:viewController animated:YES];
                                }
                            }
                        }
                    }
                }
            } else {
                if (weakSelf.navigationController) {
                    [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
                    for (UIViewController *viewController in weakSelf.navigationController.viewControllers) {
                        if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                            [weakSelf.navigationController popToViewController:viewController animated:YES];
                        }
                    }
                }
            }
        }
        [weakSelf.navigationController setNavigationBarHidden:NO];
    };
    
    
    UIViewController *viewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        MNDetailViewController *detailViewController = [[MNDetailViewController alloc] init];
        _settingsViewController.delegate = detailViewController;
        
         UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        if (self.app.is_luxcam) {
            [detailNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
        }
        else if (self.app.is_vimtag)
        {
            //            [detailNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"vt_navigation.png"] forBarMetrics:UIBarMetricsDefault];
        }
        else if (self.app.is_ebitcam || self.app.is_mipc)
        {
        
        }
        else
        {
            [detailNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
        }

        
        UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
        splitViewController.delegate = self;
        [splitViewController setViewControllers:@[settingsNavigationController, detailNavigationController]];
        
        viewController = splitViewController;
    }
    else
    {
        viewController = settingsNavigationController;
    }
    
    //set the frame for new view
    CGRect frame = self.view.frame;
    viewController.view.frame = frame;
    
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - updateData
-(void)updateData
{
    _settingsViewController.ver_valid = YES;
    [_settingsViewController.tableView reloadData];
}

#pragma mark - UISplitViewController
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

-(BOOL)shouldAutorotate
{
//    return YES;
    return [self.childViewControllers.lastObject shouldAutorotate];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.childViewControllers.lastObject supportedInterfaceOrientations];
}
@end
