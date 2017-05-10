//
//  MNDeviceTabBarViewController.m
//  mipci
//
//  Created by mining on 15-1-13.
//
//

#import "MNDeviceTabBarController.h"
#import "MNSettingsDeviceViewController.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "UITabBar+badgeValue.h"
#import "MNDeviceSettingsViewController.h"
#import "MNDevicePlayViewController.h"

@interface MNDeviceTabBarController ()

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic)mipc_agent   *agent;
@end

@implementation MNDeviceTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (AppDelegate *)app
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mcall_ctx_upgrade_get *ctx = [[mcall_ctx_upgrade_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(upgrade_get_done:);
    
    [self.agent upgrade_get:ctx];
    
    if (self.app.disableAll) {
        [self.tabBar setHidden:YES];
    }
    
    if (self.app.disableSettings)
    {
        NSArray *viewControllers = [self removeObjectFromViewControllersByClass:[MNSettingsDeviceViewController class]];
        [self setViewControllers:viewControllers animated:YES];
    }
    
    if (self.app.disableHistory)
    {
//        NSArray *viewControllers = [self removeObjectFromViewControllersByClass:[MNMessageViewController class]];
//        [self setViewControllers:viewControllers animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSLog(@"viewDidDisappear");
}
#pragma mark - upgrade_get_done
- (void)upgrade_get_done:(mcall_ret_upgrade_get *)ret
{
    //    if(nil != ret.result)
    //    {
    ////        [self.view.superview addSubview:[MNToastView failToast:nil]];
    //        return;
    //    }
    
    if ((ret.ver_valid.length != 0 && ret.ver_current.length != 0 && ![ret.ver_valid isEqualToString:ret.ver_current])
        || (ret.hw_ext.length != 0 && ![ret.hw_ext isEqualToString:ret.prj_ext])){
        [self.tabBar showBadgeOnItemIndex:2];
        _ver_valid = YES;
        
        
        UINavigationController *navigationController = (UINavigationController * )([self.viewControllers objectAtIndex:2]);
        MNSettingsDeviceViewController *settingsViewController = [navigationController.viewControllers firstObject];
        [settingsViewController updateData];
        
        UINavigationController *playNavigationController = (UINavigationController * )([self.viewControllers objectAtIndex:0]);
        MNDevicePlayViewController *playViewController = [playNavigationController.viewControllers firstObject];
        
        if (playViewController.is_viewAppear) {
            if ([playViewController respondsToSelector:@selector(showUpdatePromptView)]) {
                [playViewController showUpdatePromptView];
            }
        } else {
            playViewController.ver_valid = YES;
        }
    }
}

#pragma mark -viewDidLayoutSubviews
- (void)viewDidLayoutSubviews
{
    if (_ver_valid) {
        [self.tabBar showBadgeOnItemIndex:2];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)removeObjectFromViewControllersByClass:(Class)aClass
{
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    UIViewController *viewController;
    for (UIViewController *subViewController in viewControllers) {
        if ([subViewController isMemberOfClass:aClass]) {
            viewController = subViewController;
        }
    }
    [viewControllers removeObject:viewController];
    
    return viewControllers;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
