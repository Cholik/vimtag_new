//
//  MLDetailViewController.m
//  SpliteViewDemo
//
//  Created by mining on 14-10-24.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDetailViewController.h"
#import "MNAccessorySceneViewController.h"
#import "MNAccessoryVideoViewController.h"
#import "MNDeviceAccessoryViewController.h"
#import "MNRootNavigationController.h"

@interface MNDetailViewController ()

@end

@implementation MNDetailViewController

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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setViewController:(UIViewController *)viewController
{
    
    if ([viewController isMemberOfClass:[MNAccessorySceneViewController class]] | [viewController isMemberOfClass:[MNDeviceAccessoryViewController class]] | [viewController isMemberOfClass:[MNAccessoryVideoViewController class]]) {
        MNRootNavigationController *accessoryNavigationController = [[MNRootNavigationController alloc] initWithRootViewController:viewController];
        [self.navigationController presentViewController:accessoryNavigationController animated:YES completion:nil];
        
    }else
    {
        UIViewController *subViewController = [self.childViewControllers lastObject];
        if (subViewController) {
            [subViewController willMoveToParentViewController:nil];
            [subViewController.view removeFromSuperview];
            [subViewController removeFromParentViewController];
        }
        
        if (self.view.frame.origin.y != 64.0) {
            self.view.frame = CGRectMake(0.0, 64.0, self.view.frame.size.width, self.view.frame.size.height);
        }
        
        CGRect bounds = self.view.bounds;
        viewController.view.frame = bounds;
        
        if (self.navigationController) {
            NSString *title = [viewController valueForKey:@"title"];
            self.navigationItem.title = title;
            for (UIViewController *viewController in self.navigationController.childViewControllers) {
                if (![viewController isKindOfClass:[MNDetailViewController class]]) {
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }
            }
            
        }
        
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        
    }
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
