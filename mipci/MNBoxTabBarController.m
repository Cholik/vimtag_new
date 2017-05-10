//
//  MNBoxTabBarController.m
//  mipci
//
//  Created by weken on 15/6/24.
//
//

#import "MNBoxTabBarController.h"
#import "MNDeviceTabBarController.h"
#import "MNSettingsDeviceViewController.h"
#import "MNDeviceSettingsViewController.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "UITabBar+badgeValue.h"

@interface MNBoxTabBarController ()

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic)mipc_agent   *agent;

@end

@implementation MNBoxTabBarController

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

#pragma mark -Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mcall_ctx_upgrade_get *ctx = [[mcall_ctx_upgrade_get alloc] init];
    ctx.sn = _boxID;
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

- (void)viewDidLayoutSubviews
{
    if (_ver_valid) {
        [self.tabBar showBadgeOnItemIndex:1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Callback
- (void)upgrade_get_done:(mcall_ret_upgrade_get *)ret
{
    if ((ret.ver_valid.length != 0 && ret.ver_current.length != 0 && ![ret.ver_valid isEqualToString:ret.ver_current])
        || (ret.hw_ext.length != 0 && ![ret.hw_ext isEqualToString:ret.prj_ext])) {

        @try {
            [self.tabBar showBadgeOnItemIndex:1];
            _ver_valid = YES;
            UINavigationController *navigationController = (UINavigationController * )([self.viewControllers objectAtIndex:1]);
            MNSettingsDeviceViewController *settingsViewController = [navigationController.viewControllers firstObject];
            [settingsViewController updateData];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
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

@end

