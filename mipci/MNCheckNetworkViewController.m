//
//  MNCheckNetworkViewController.m
//  mipci
//
//  Created by mining on 16/11/2.
//
//

#define CIRCLE_RADIU        5
#define COLOR_RGB(rgbValue,a) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) & 0xFF00)>>8))/255.0 blue: ((float)((rgbValue) & 0xFF))/255.0 alpha:(a)]

#define TITLE_COLOR                    COLOR_RGB(0x333333,1.0)
#define CONTENT_COLOR                  COLOR_RGB(0x646464,1.0)

#import "MNCheckNetworkViewController.h"

@interface MNCheckNetworkViewController ()

@end

@implementation MNCheckNetworkViewController

#pragma mark - Life Cycle
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_network_connection_unavailable", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_delete"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    _firstCircleView.layer.cornerRadius = CIRCLE_RADIU;
    _secondCircleView.layer.cornerRadius = CIRCLE_RADIU;
    _thirdCircleView.layer.cornerRadius = CIRCLE_RADIU;
    
    _firstPromptText.editable = NO;
    _firstPromptText.selectable = NO;
    _secondPromptText.editable = NO;
    _secondPromptText.selectable = NO;
    _firstContentText.editable = NO;
    _firstContentText.selectable = NO;
    _secondContentText.editable = NO;
    _secondContentText.selectable = NO;
    _thirdContentText.editable = NO;
    _thirdContentText.selectable = NO;
    
    _promptTitleLabel.text = NSLocalizedString(@"mcs_Failed_connect_Internet", nil);
    _firstPromptText.text = NSLocalizedString(@"mcs_connect_internet_note", nil);
    _secondPromptText.text = NSLocalizedString(@"mcs_connect_wifi_note", nil);
    _firstContentText.text = NSLocalizedString(@"mcs_connect_internet_detail_first", nil);
    _secondContentText.text = NSLocalizedString(@"mcs_connect_internet_detail_second", nil);
    _thirdContentText.text = NSLocalizedString(@"mcs_connect_wifi_detail", nil);
    
    _promptTitleLabel.textColor = TITLE_COLOR;
    _firstPromptText.textColor = CONTENT_COLOR;
    _secondPromptText.textColor = CONTENT_COLOR;
    _firstContentText.textColor = CONTENT_COLOR;
    _secondContentText.textColor = CONTENT_COLOR;
    _thirdContentText.textColor = CONTENT_COLOR;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Rotate
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIApplication sharedApplication].statusBarOrientation;
    }
    else
    {
        return UIInterfaceOrientationPortrait;
    }
    
}

@end
