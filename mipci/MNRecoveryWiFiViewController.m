//
//  MNRecoveryWiFiViewController.m
//  mipci
//
//  Created by mining on 16/5/16.
//
//

#import "MNRecoveryWiFiViewController.h"
#import "MNConfiguration.h"
#import "AppDelegate.h"

@interface MNRecoveryWiFiViewController ()

@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNRecoveryWiFiViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

- (void)initUI
{
    MNConfiguration *configuration = [MNConfiguration shared_configuration];
    _firstLabel.textColor = configuration.labelTextColor;
    _secondLabel.textColor = configuration.labelTextColor;
    self.navigationItem.title = NSLocalizedString(@"mcs_prompt", nil);
    _firstLabel.text = NSLocalizedString(@"mcs_wifi_config_restore_start", nil);
    _secondLabel.text = NSLocalizedString(@"mcs_wifi_config_restore_end", nil);
    [_prepareok setTitle:NSLocalizedString(@"mcs_close", nil)  forState:UIControlStateNormal];
    [_prepareok setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    self.resetLabel.text = @"Reset";
    if (self.app.is_luxcam) {
        [_prepareok setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
        _resetLabel.textColor = configuration.labelTextColor;
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_prepareok setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_prepareok setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];
        _resetLabel.textColor = configuration.labelTextColor;
    }
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

#pragma mark - Rotate
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
#pragma mark  - Action
- (IBAction)close:(id)sender
{
    if (self.app.is_jump && self.app.isLoginByID)
    {
        NSString  *message = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"mcs_device_offline",nil), NSLocalizedString(@"mcs_will_back",nil), self.app.fromTarget];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
        [alertView show];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
