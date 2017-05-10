//
//  MNBoxPageViewController.m
//  mipci
//
//  Created by mining on 15/11/21.
//
//

#import "MNBoxPageViewController.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "MNBoxRecordsViewController.h"

#define SNAPSHOT_ALL                2002
#define RECORD_ALL_HALFHOUR         2016
#define ALL_ALL_HALFHOUR            2026


@interface MNBoxPageViewController ()

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSArray *viewControllerArray;

@end

@implementation MNBoxPageViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

- (mipc_agent *)agent
{
    return _agent ? _agent : (_agent = [mipc_agent shared_mipc_agent]);
}

- (NSArray *)viewControllerArray
{
    if (nil == _viewControllerArray) {
        _viewControllerArray = [[NSArray alloc] init];
    }
    return _viewControllerArray;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        ;
    }
    return self;
}

- (void)initUI
{
    _boxStyleSegmented.hidden = self.app.is_vimtag ? YES : NO;
    [_boxStyleSegmented setTitle:NSLocalizedString(@"mcs_snapshot", nil) forSegmentAtIndex:0];
    [_boxStyleSegmented setTitle:NSLocalizedString(@"mcs_record", nil) forSegmentAtIndex:1];
    [_boxStyleSegmented setTitle:NSLocalizedString(@"mcs_all", nil) forSegmentAtIndex:2];
    _boxStyleSegmented.selectedSegmentIndex = 2;
    [_boxStyleSegmented addTarget:self action:@selector(choseCategory:) forControlEvents:UIControlEventValueChanged];
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
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:self.app.is_ebitcam ? @"eb_navbar_bg.png" : (self.app.is_mipc ? @"mi_navbar_bg.png" : @"navbar_bg.png")] forBarMetrics:UIBarMetricsDefault];
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    MNBoxRecordsViewController *boxRecordsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MNBoxRecordsViewController"];
    boxRecordsViewController.deviceID = _deviceID;
    boxRecordsViewController.boxID = _boxID;
    self.viewControllerArray = @[boxRecordsViewController];
    NSArray *currentViewControllers = @[self.viewControllerArray[0]];
    [self setViewControllers:currentViewControllers
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma  mark - Action
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

- (void)back:(id)sender
{
    NSString *url = [self.app.fromTarget stringByAppendingString:@"://"];
    if (url) {
        if (!self.app.isLoginByID && ([self.app.serialNumber isEqualToString:@"(null)"] || [self.app.serialNumber isEqualToString:@""] || !self.app.serialNumber))
        {
             [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }

}

- (IBAction)backTo:(id)sender {
    if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)selectDate:(id)sender {
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
