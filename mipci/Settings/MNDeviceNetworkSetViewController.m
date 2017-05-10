//
//  MNDeviceNetworkSetViewController.m
//  mipci
//
//  Created by mining on 15/10/9.
//
//

#import "MNDeviceNetworkSetViewController.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNNetworkPageViewController.h"

@interface MNDeviceNetworkSetViewController ()


@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) MNNetworkPageViewController *networkPageViewController;
@end

@implementation MNDeviceNetworkSetViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = NSLocalizedString(@"mcs_network", nil);
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

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

- (void)initUI
{
    [_networkSelectSegment setTitle:NSLocalizedString(@"mcs_ethernet", nil) forSegmentAtIndex:0];
    [_networkSelectSegment setTitle:NSLocalizedString(@"mcs_wifi", nil) forSegmentAtIndex:1];
    _networkSelectSegment.tintColor = self.configuration.switchTintColor;
    _networkSelectSegment.selectedSegmentIndex = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if ([dev.type isEqualToString:@"BOX"] && [dev.wifi_status isEqualToString:@"none"]) {
        [_networkSelectSegment removeFromSuperview];
        _containerLayoutConstraint.constant = 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNNetworkPageViewController"]) {
        _networkPageViewController = segue.destinationViewController;
        [_networkPageViewController setValue:_agent forKey:@"agent"];
        [_networkPageViewController setValue:_deviceID forKey:@"deviceID"];
        [_networkPageViewController setValue:_rootNavigationController forKey:@"rootNavigationController"];
    }
}

#pragma mark Action
- (IBAction)selectNetwork:(id)sender
{
    [_networkPageViewController selectIndex:((UISegmentedControl*)sender).selectedSegmentIndex];
}

@end

