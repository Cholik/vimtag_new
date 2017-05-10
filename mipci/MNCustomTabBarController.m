//
//  MNCustomTabBarController.m
//  mipci
//
//  Created by mining on 15/11/5.
//
//

#import "MNCustomTabBarController.h"
#import "MNProductInformationViewController.h"
#import "MNRootNavigationController.h"
#import "AppDelegate.h"
#import "MNDeveloperOption.h"

@interface MNCustomTabBarController ()

@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) MNDeveloperOption *developerOption;

@end

@implementation MNCustomTabBarController

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (MNDeveloperOption *)developerOption
{
    if (nil == _developerOption) {
        _developerOption = [MNDeveloperOption shared_developerOption];
    }
    
    return _developerOption;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productInformationChange) name:@"ProductInformationChange" object:nil];

        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"u_home"].length || self.developerOption.homeUrl.length) {
            NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.viewControllers];
            if ([newArray count] < 3) {
                UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil];
                MNProductInformationViewController *productInformationViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNProductInformationViewController"];
                MNRootNavigationController *productNavigationController = [[MNRootNavigationController alloc] initWithRootViewController:productInformationViewController];
                [newArray insertObject:productNavigationController atIndex:0];
                [self setViewControllers:newArray];
                NSArray *tabBarItems = self.tabBar.items;
                UITabBarItem *tabBarItem = (UITabBarItem *)tabBarItems.firstObject;
                tabBarItem.title = NSLocalizedString(@"mcs_product", nil);
                tabBarItem.image = [UIImage imageNamed:@"vt_home_idle"];
                tabBarItem.selectedImage = [UIImage imageNamed:@"vt_home"];
            }
            self.selectedIndex = 1;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ProductInformationChange" object:nil];
}

- (void)productInformationChange
{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"u_home"].length || self.developerOption.homeUrl.length) {
        NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.viewControllers];
        if ([newArray count] < 3) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil];
                MNProductInformationViewController *productInformationViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNProductInformationViewController"];
                MNRootNavigationController *productNavigationController = [[MNRootNavigationController alloc] initWithRootViewController:productInformationViewController];
                [newArray insertObject:productNavigationController atIndex:0];
                [self setViewControllers:newArray];
                NSArray *tabBarItems = self.tabBar.items;
                UITabBarItem *tabBarItem = (UITabBarItem *)tabBarItems.firstObject;
                tabBarItem.title = NSLocalizedString(@"mcs_product", nil);
                tabBarItem.image = [UIImage imageNamed:@"vt_home_idle"];
                tabBarItem.selectedImage = [UIImage imageNamed:@"vt_home"];
            });
        }
    } else {
        NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.viewControllers];
        if ([newArray count] > 2) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (0 == self.selectedIndex) {
                    self.selectedIndex = 1;
                }
                [newArray removeObjectAtIndex:0];
                [self setViewControllers:newArray];
            });
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
