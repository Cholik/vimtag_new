//
//  MNMessagePageViewController.m
//  mipci
//
//  Created by mining on 15/9/17.
//
//

#import "MNMessagePageViewController.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "MNStroyMessageViewController.h"
#import "MNDeviceTabBarController.h"
#import "MNBoxRecordsViewController.h"

#define SNAPSHOT_ALL                2002
#define RECORD_ALL_HALFHOUR         2016
#define ALL_ALL_HALFHOUR            2026

@interface MNMessagePageViewController ()

@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSArray *viewControllerArray;
@property (assign, nonatomic) BOOL is_showItems;

@end

@implementation MNMessagePageViewController

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

- (NSArray *)viewControllerArray
{
    if (_viewControllerArray == nil) {
        _viewControllerArray = [[NSArray alloc] init];
    }
    return _viewControllerArray;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"mcs_messages", nil)];
        if (self.app.is_sereneViewer) {
            self.navigationController.tabBarItem.image = [[UIImage imageNamed:@"tab_message_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_message_selected.png"]];
        
        //        [self.collectionView alwaysBounceVertical];
        if (self.app.is_vimtag)
        {
            self.hidesBottomBarWhenPushed = YES;
        }
    }
    
    return self;
}

- (void)initUI
{
    _messageStyleSegmented.hidden = self.app.is_vimtag ? YES : NO;
    [_messageStyleSegmented setTitle:NSLocalizedString(@"mcs_snapshot", nil) forSegmentAtIndex:0];
    [_messageStyleSegmented setTitle:NSLocalizedString(@"mcs_record", nil) forSegmentAtIndex:1];
    [_messageStyleSegmented setTitle:NSLocalizedString(@"mcs_all", nil) forSegmentAtIndex:2];
    [_messageStyleSegmented addTarget:self action:@selector(choseCategory:) forControlEvents:UIControlEventValueChanged];
    [_messageStyleSegmented setSelectedSegmentIndex:2];
    [self.navigationController setNavigationBarHidden:NO];

    if (!self.app.is_luxcam && !self.app.is_vimtag && !self.app.is_ebitcam && !self.app.is_mipc) {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
            negativeSpacer.width = -10.0;
        }
        else
        {
            negativeSpacer.width = 0.0;
        }
        
        [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, leftBarButtonItem] animated:YES];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
        }
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self initUI];
    
    if (!self.app.is_luxcam && !self.app.is_vimtag && !self.app.is_ebitcam && !self.app.is_mipc) {
        MNDeviceTabBarController *deviceTabBarViewController = (MNDeviceTabBarController*)self.tabBarController;
        _deviceID = deviceTabBarViewController.deviceID;
    }
    
    m_dev *device = [self.agent.devs get_dev_by_sn:_deviceID];

    //Distinguish version
    if (device.spv) {
        _is_showItems = YES;
        [_itemBtnView setHidden:!_is_showItems];
        MNBoxRecordsViewController *boxRecordsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MNBoxRecordsViewController"];
        boxRecordsViewController.deviceID = _deviceID;
        boxRecordsViewController.boxID = _deviceID;
        self.viewControllerArray = @[boxRecordsViewController];
        NSArray *currentViewControllers = @[self.viewControllerArray[0]];
        [self setViewControllers:currentViewControllers
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
    } else {
        _messageStyleSegmented.hidden = YES;
        _is_showItems = NO;
        [_itemBtnView setHidden:!_is_showItems];
        MNStroyMessageViewController *stroyMessageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MNStroyMessageViewController"];
        stroyMessageViewController.deviceID = _deviceID;
        self.viewControllerArray = @[stroyMessageViewController];
        NSArray *currentViewControllers = @[self.viewControllerArray[0]];
        [self setViewControllers:currentViewControllers
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
    }

    //    [self addChildViewController:self.pageViewController];
    //    [self.containView addSubview:self.pageViewController.view];
    //    [self.pageViewController didMoveToParentViewController:self];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_is_showItems) {
        MNBoxRecordsViewController *boxRecordsViewController = (MNBoxRecordsViewController *)(self.viewControllerArray.firstObject);
        [boxRecordsViewController.screeningView setHidden:YES];
        [boxRecordsViewController.calendar setHidden:YES];
        [boxRecordsViewController initLayoutConstraint];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)choseCategory:(id)sender
{
    UISegmentedControl *segmentedControl = sender;
    NSInteger selectResult = 0;
    if ([self.viewControllerArray[0] isMemberOfClass:[MNBoxRecordsViewController class]])
    {
        MNBoxRecordsViewController *boxRecordsViewController = (MNBoxRecordsViewController *)(self.viewControllerArray.firstObject);
        switch (segmentedControl.selectedSegmentIndex) {
            case 0:
                selectResult = SNAPSHOT_ALL;
                break;
            case 1:
                selectResult = RECORD_ALL_HALFHOUR;
                break;
            default:
                selectResult = ALL_ALL_HALFHOUR;
                break;
        }
        [boxRecordsViewController filteringResults:selectResult];
    }
}

- (IBAction)selectDate:(id)sender
{
    if ([self.viewControllerArray[0] isMemberOfClass:[MNBoxRecordsViewController class]])
    {
        MNBoxRecordsViewController *boxRecordsViewController = (MNBoxRecordsViewController *)(self.viewControllerArray.firstObject);
        if (self.app.is_vimtag) {
            boxRecordsViewController.calendar.hidden = !boxRecordsViewController.calendar.hidden;
            if (!boxRecordsViewController.screeningView.hidden) {
                boxRecordsViewController.screeningView.hidden = YES;
                [boxRecordsViewController initLayoutConstraint];
            }
            
        }
        else {
            if (boxRecordsViewController.is_datePickerShow)
            {
                if (boxRecordsViewController.datePicker) {
                    [boxRecordsViewController.datePicker removeFromSuperview];
                }
                boxRecordsViewController.is_datePickerShow = NO;
            }
            else
            {
                [boxRecordsViewController createDatePickerWithMode:UIDatePickerModeDate];
            }
        }
    }
}

- (IBAction)filterData:(id)sender
{
    if ([self.viewControllerArray[0] isMemberOfClass:[MNBoxRecordsViewController class]])
    {
        MNBoxRecordsViewController *boxRecordsViewController = (MNBoxRecordsViewController *)(self.viewControllerArray.firstObject);
        boxRecordsViewController.screeningView.hidden = !boxRecordsViewController.screeningView.hidden;
        boxRecordsViewController.calendar.hidden = YES;
        if (boxRecordsViewController.screeningView.hidden) {
            [boxRecordsViewController initLayoutConstraint];
        }
        else
        {
            [boxRecordsViewController updateLayoutConstraint];
        }
    }
}

- (void)back:(id)sender
{
    NSString *url = [self.app.fromTarget stringByAppendingString:@"://"];
    if (url) {
        if (!self.app.isLoginByID && ([self.app.serialNumber isEqualToString:@"(null)"] || [self.app.serialNumber isEqualToString:@""] || !self.app.serialNumber))
        {
             [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init] ;
            ctx.target = self;
            ctx.on_event = nil;
    
            [self.agent sign_out:ctx];
            self.app.is_jump = NO;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
 
    }
    
    else
    {
        if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
- (IBAction)btnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
