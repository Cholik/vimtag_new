//
//  MNSendEmailFinishViewController.m
//  mipci
//
//  Created by tanjiancong on 16/9/7.
//
//

#import "MNSendEmailFinishViewController.h"
#import "MNConfiguration.h"
#import "AppDelegate.h"

@interface MNSendEmailFinishViewController ()

@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNSendEmailFinishViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

#pragma mark - Life Cycle
- (void)initUI
{
    [self.navigationItem setHidesBackButton:YES];
    self.title = NSLocalizedString(@"mcs_forgot_your_password", nil);
    
    MNConfiguration *configuration = [MNConfiguration shared_configuration];
    self.sendSuccessPromptLabel.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"mcs_send_mailbox_succuess_prev", nil),  _emailString, NSLocalizedString(@"mcs_send_mailbox_succuess_next", nil)];
    if (!self.app.is_vimtag && !self.app.is_ebitcam && !self.app.is_mipc)
    {
        _sendSuccessPromptLabel.textColor = configuration.labelTextColor;
    }
    [_certainButton setTitle:NSLocalizedString(@"mcs_ok", nil) forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)certain:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
