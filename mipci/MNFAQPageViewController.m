//
//  MNFAQPageViewController.m
//  mipci
//
//  Created by mining on 15/11/11.
//
//

#import "MNFAQPageViewController.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "MNFAQViewController.h"
#import "MNFeedbackViewController.h"

@interface MNFAQPageViewController ()

@property (strong, nonatomic) NSArray *viewControllerArray;
@property (strong, nonatomic) NSArray *currentViewController;
@property (strong, nonatomic) MNFAQViewController *faqViewController;
@property (strong, nonatomic) MNFeedbackViewController *feedbackViewController;

@end

@implementation MNFAQPageViewController

- (NSArray *)viewControllerArray
{
    if (_viewControllerArray == nil) {
        _viewControllerArray = [[NSArray alloc] init];
    }
    
    return _viewControllerArray;
}

- (NSArray *)currentViewController
{
    if (_currentViewController == nil) {
        _currentViewController = [[NSMutableArray alloc] init];
    }
    
    return _currentViewController;
}

#pragma mark - View lifeCycle
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)initUI
{
    [_selectSegment setSelectedSegmentIndex:0];
    [_selectSegment setTitle:NSLocalizedString(@"mcs_help_information", nil) forSegmentAtIndex:0];
    [_selectSegment setTitle:NSLocalizedString(@"mcs_feedback", nil) forSegmentAtIndex:1];
    //hide feedbackView
//    [_selectSegment setHidden:YES];
    self.navigationItem.title =  NSLocalizedString(@"mcs_help_feedback", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    
    _faqViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MNFAQViewController"];
//    _feedbackViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MNFeedbackViewController"];
//    self.viewControllerArray = @[_faqViewController, _feedbackViewController];
    self.currentViewController = @[_faqViewController];
    [self setViewControllers:self.currentViewController direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    if ([self.currentViewController[0] isMemberOfClass:[MNFAQViewController class]])
    {
        if ([_faqViewController.customWebView canGoBack]) {
            [_faqViewController.customWebView goBack];

        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
//    else if ([self.currentViewController[0] isMemberOfClass:[MNFeedbackViewController class]])
//    {
//        if ([_feedbackViewController.customWebView canGoBack]) {
//            [_feedbackViewController.customWebView goBack];
//            
//        } else {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    }
}

- (IBAction)selectStyle:(id)sender
{
//    UISegmentedControl * segmentedControl = sender;
//    self.currentViewController = @[self.viewControllerArray[segmentedControl.selectedSegmentIndex]];
//    [self setViewControllers:self.currentViewController
//                   direction:UIPageViewControllerNavigationDirectionForward
//                    animated:NO
//                  completion:nil];
}

- (IBAction)refresh:(id)sender
{
    if ([self.currentViewController[0] isMemberOfClass:[MNFAQViewController class]])
    {
            [_faqViewController.customWebView reload];
    }
//    else if ([self.currentViewController[0] isMemberOfClass:[MNFeedbackViewController class]])
//    {
//        [_feedbackViewController.customWebView reload];
//    }
}
@end
