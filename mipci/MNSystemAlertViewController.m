//
//  MNSystemAlertViewController.m
//  mipci
//
//  Created by mining on 16/2/1.
//
//

#import "MNSystemAlertViewController.h"

@interface MNSystemAlertViewController ()

//- (void)setup;
//- (void)resetTransition;
//- (void)invalidateLayout;

@end


@implementation MNSystemAlertViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View life cycle

- (void)loadView
{
    self.view = self.systemSettingAlertView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.systemSettingAlertView setup];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.systemSettingAlertView resetTransition];
    [self.systemSettingAlertView invalidateLayout];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end

