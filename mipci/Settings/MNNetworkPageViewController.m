//
//  MNNetworkPageViewController.m
//  mipci
//
//  Created by mining on 15/10/9.
//
//

#import "MNNetworkPageViewController.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNDeviceEthernetSetViewController.h"
#import "MNDeviceWIFISetViewController.h"

@interface MNNetworkPageViewController ()

@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) NSArray *currentViewControllers;
@property (strong, nonatomic) MNDeviceEthernetSetViewController *deviceEthernetSetViewController;
@property (strong, nonatomic) MNDeviceWIFISetViewController    *deviceWIFISetViewController;

@property (strong, nonatomic) UISegmentedControl                *segmentedControl;
@property (strong, nonatomic) UINavigationBar                   *navigationBar;

@end

@implementation MNNetworkPageViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = NSLocalizedString(@"mcs_network", nil);
    }
    
    return self;
}

- (void)initUI
{
    _deviceEthernetSetViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MNDeviceEthernetSetViewController"];
    _deviceWIFISetViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MNDeviceWIFISetViewController"];
    
    [_deviceEthernetSetViewController setValue:_agent forKey:@"agent"];
    [_deviceEthernetSetViewController setValue:_deviceID forKey:@"deviceID"];
    [_deviceEthernetSetViewController setValue:_rootNavigationController forKey:@"rootNavigationController"];
    [_deviceWIFISetViewController setValue:_agent forKey:@"agent"];
    [_deviceWIFISetViewController setValue:_deviceID forKey:@"deviceID"];
    [_deviceWIFISetViewController setValue:_rootNavigationController forKey:@"rootNavigationController"];
    
    self.delegate = self;
    _currentViewControllers = @[_deviceEthernetSetViewController];
    [self setViewControllers:_currentViewControllers
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)selectIndex:(NSInteger)index
{
    if (index == 0) {
        
        _currentViewControllers = @[_deviceEthernetSetViewController];
        [self setViewControllers:_currentViewControllers
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
        
    }
    else
    {
        _currentViewControllers = @[_deviceWIFISetViewController];
        [self setViewControllers:_currentViewControllers
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
    }
    
}


@end
