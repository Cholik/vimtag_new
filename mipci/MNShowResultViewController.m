//
//  MNShowResultViewController.m
//  mipci
//
//  Created by mining on 15/9/9.
//
//

#import "MNShowResultViewController.h"
#import "MNDeviceListViewController.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNRootNavigationController.h"
#import "MNDeviceTabBarController.h"
#import "MNDeviceListSetViewController.h"

@interface MNShowResultViewController ()
{
    NSString *first;
    NSString *second;
    NSString *third;
    NSString *forth;
}
@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) NSArray *numberArray;
@property (strong, nonatomic) NSArray *constantArray;

@end

@implementation MNShowResultViewController

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
    _addSuccessLabel.text = NSLocalizedString(@"mcs_state_success", nil);
    _modifySuccessLabel.text = NSLocalizedString(@"mcs_state_success", nil);
    _setSuccessLabel.text = NSLocalizedString(@"mcs_state_success", nil);
    _timezoneSuccessLabel.text = NSLocalizedString(@"mcs_state_success", nil);

    
    first = [NSString stringWithFormat:@"1、"];
    second = [NSString stringWithFormat:@"2、"];
    third = [NSString stringWithFormat:@"3、"];
    forth = [NSString stringWithFormat:@"4、"];
    
    _numberArray = @[ first, second, third, forth];
    _constantArray = @[ @"14", @"53", @"92", @"131", @"170"];
    
    _addLabel.text = NSLocalizedString(@"mcs_action_add_device", nil);
    _modifyLabel.text = NSLocalizedString(@"mcs_modify_password", nil);
    _setWiFILabel.text = NSLocalizedString(@"mcs_action_config_wifi", nil);
    _timezoneLabel.text = NSLocalizedString(@"mcs_timezone_change", nil);
    
    NSString *name = [NSString stringWithFormat:@"%@ : ", NSLocalizedString(@"mcs_device_id", nil)];
    _deviceLabel.text = [name stringByAppendingString:_deviceID];
    
    [_certainButton setTitle:NSLocalizedString(@"mcs_ok", nil) forState:UIControlStateNormal];
    [_certainButton setTitleColor:self.app.configuration.loginButtonTitleColor forState:UIControlStateNormal];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setTitle:NSLocalizedString(@"mcs_finish", nil)];
    
    _deviceLabel.textColor = self.configuration.labelTextColor;
    _addLabel.textColor = self.configuration.labelTextColor;
    _modifyLabel.textColor = self.configuration.labelTextColor;
    _setWiFILabel.textColor = self.configuration.labelTextColor;
    _timezoneLabel.textColor = self.configuration.labelTextColor;
    _addSuccessLabel.textColor = self.configuration.labelTextColor;
    _modifySuccessLabel.textColor = self.configuration.labelTextColor;
    _setSuccessLabel.textColor = self.configuration.labelTextColor;
    _timezoneSuccessLabel.textColor = self.configuration.labelTextColor;

    if (self.app.is_luxcam) {
        [_certainButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];

        [_bgImage setImage:[UIImage imageNamed:@"background.png"]];
    }
    else if (self.app.is_vimtag)
    {
        [_bgImage setImage:[UIImage imageNamed:@"vt_bg.png"]];
        [_certainButton setBackgroundImage:[UIImage imageNamed:@"vt_btn_login.png"] forState:UIControlStateNormal];
    }
    else if (self.app.is_ebitcam)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_certainButton setBackgroundImage:[UIImage imageNamed:@"eb_login_btn.png"] forState:UIControlStateNormal];
    }
    else if (self.app.is_mipc)
    {
        [_bgImage setImage:[UIImage imageNamed:@"eb_bg.png"]];
        [_certainButton setBackgroundImage:[UIImage imageNamed:@"mi_login_btn.png"] forState:UIControlStateNormal];
    }
    else
    {
        [_bgImage setImage:[UIImage imageNamed:@"bg.png"]];
        [_certainButton setBackgroundImage:[UIImage imageNamed:@"btn_login.png"] forState:UIControlStateNormal];

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
    if (self.app.isLoginByID || _is_notAdd) {
        [self.addView setHidden:YES];
        [self.modifyView setHidden:_is_changePwd ? NO : YES];
        [self.setView setHidden:_is_connectWiFi ? NO : YES];
        [self.timezoneView setHidden:_is_timezoneModify ? NO : YES];
        
        NSInteger index = 0;
        if (_is_changePwd) {
            _modifyLabel.text = [NSString stringWithFormat:@"%@%@",[_numberArray objectAtIndex:index],NSLocalizedString(@"mcs_modify_password", nil)];
            _modifyLayoutConstraint.constant = [NSString stringWithFormat:@"%@",[_constantArray objectAtIndex:index]].floatValue;
            index++;
        }
        if (_is_connectWiFi) {
            _setWiFILabel.text = [NSString stringWithFormat:@"%@%@",[_numberArray objectAtIndex:index],NSLocalizedString(@"mcs_action_config_wifi", nil)];
            _setLayoutConstraint.constant = [NSString stringWithFormat:@"%@",[_constantArray objectAtIndex:index]].floatValue;
            index++;
        }
        if (_is_timezoneModify) {
            _timezoneLabel.text = [NSString stringWithFormat:@"%@%@",[_numberArray objectAtIndex:index],NSLocalizedString(@"mcs_timezone_change", nil)];
            _timezoneLayoutConstraint.constant = [NSString stringWithFormat:@"%@",[_constantArray objectAtIndex:index]].floatValue;
            index++;
        }
        if (index == 1) {
            _modifyLabel.text = NSLocalizedString(@"mcs_modify_password", nil);
            _setWiFILabel.text = NSLocalizedString(@"mcs_action_config_wifi", nil);
            _timezoneLabel.text = NSLocalizedString(@"mcs_timezone_change", nil);
        }
        _certainLayoutConstraint.constant = [NSString stringWithFormat:@"%@",[_constantArray objectAtIndex:index]].floatValue;
        
//        if (_is_changePwd && _is_connectWiFi && _is_timezoneModify) {
//            _modifyLabel.text = [first stringByAppendingString:_modifyLabel.text];
//            _setWiFILabel.text = [second stringByAppendingString:_setWiFILabel.text];
//            _timezoneLabel.text = [third stringByAppendingString:_timezoneLabel.text];
//            self.modifyLayoutConstraint.constant = 14;
//            self.setLayoutConstraint.constant = 53;
//            self.timezoneLayoutConstraint.constant = 92;
//            self.certainLayoutConstraint.constant = 131;
//        } else if (_is_changePwd && !_is_connectWiFi) {
//            _modifyLabel.text = NSLocalizedString(@"mcs_modify_password", nil);
//            self.modifyLayoutConstraint.constant = 14;
//            self.certainLayoutConstraint.constant = 53;
//        } else if (!_is_changePwd && _is_connectWiFi) {
//            _setWiFILabel.text = NSLocalizedString(@"mcs_action_config_wifi", nil);
//            self.setLayoutConstraint.constant = 14;
//            self.certainLayoutConstraint.constant = 53;
//        }
    }
    else
    {
        [self.addView setHidden:NO];
        [self.modifyView setHidden:_is_changePwd ? NO : YES];
        [self.setView setHidden:_is_connectWiFi ? NO : YES];
        [self.timezoneView setHidden:_is_timezoneModify ? NO : YES];

        if (self.is_onlyAdd) {
            _addLabel.text = NSLocalizedString(@"mcs_action_add_device", nil);
            self.certainLayoutConstraint.constant = 53;
        } else {
            NSInteger index = 0;
            _addLabel.text = [NSString stringWithFormat:@"%@%@",[_numberArray objectAtIndex:index],NSLocalizedString(@"mcs_action_add_device", nil)];
            index++;
            if (_is_changePwd) {
                _modifyLabel.text = [NSString stringWithFormat:@"%@%@",[_numberArray objectAtIndex:index],NSLocalizedString(@"mcs_modify_password", nil)];
                _modifyLayoutConstraint.constant = [NSString stringWithFormat:@"%@",[_constantArray objectAtIndex:index]].floatValue;
                index++;
            }
            if (_is_connectWiFi) {
                _setWiFILabel.text = [NSString stringWithFormat:@"%@%@",[_numberArray objectAtIndex:index],NSLocalizedString(@"mcs_action_config_wifi", nil)];
                _setLayoutConstraint.constant = [NSString stringWithFormat:@"%@",[_constantArray objectAtIndex:index]].floatValue;
                index++;
            }
            if (_is_timezoneModify) {
                _timezoneLabel.text = [NSString stringWithFormat:@"%@%@",[_numberArray objectAtIndex:index],NSLocalizedString(@"mcs_timezone_change", nil)];
                _timezoneLayoutConstraint.constant = [NSString stringWithFormat:@"%@",[_constantArray objectAtIndex:index]].floatValue;
                index++;
            }
            if (index == 1) {
                _addLabel.text = NSLocalizedString(@"mcs_action_add_device", nil);
            }
            _certainLayoutConstraint.constant = [NSString stringWithFormat:@"%@",[_constantArray objectAtIndex:index]].floatValue;
//            if (_is_changePwd && _is_connectWiFi) {
//                
//            } else if (_is_changePwd && !_is_connectWiFi) {
//                [self.setView setHidden:YES];
//                self.certainLayoutConstraint.constant = 92;
//            } else if (!_is_changePwd && _is_connectWiFi) {
//                [self.modifyView setHidden:YES];
//                self.setLayoutConstraint.constant = 53;
//                self.certainLayoutConstraint.constant = 92;
//                _setWiFILabel.text = [second stringByAppendingString:NSLocalizedString(@"mcs_action_config_wifi", nil)];
//            } else {
//                [self.modifyView setHidden:YES];
//                [self.setView setHidden:YES];
//                self.certainLayoutConstraint.constant = 53;
//                _addLabel.text = NSLocalizedString(@"mcs_action_add_device", nil);
//            }
        }
    }
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)certain:(id)sender {
//    if (self.app.isLoginByID) {
//        [self performSegueWithIdentifier:@"MNDeviceListViewController" sender:nil];
//    }
//    else
//    {
//        for (UIViewController *viewController in self.navigationController.viewControllers)
//        {
//            if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
//                [((MNDeviceListViewController*)viewController) refreshData];
//                [self.navigationController popToViewController:viewController animated:YES];
//            }
//        }
//    }
    if (self.is_notAdd) {
//        [self.navigationController popToViewController:self.deviceListViewController animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (self.is_loginModify)
    {
        if (self.app.is_luxcam)
        {
            UINavigationController *navigationController = (UINavigationController *)self.presentingViewController;
            for (UIViewController *viewController in navigationController.viewControllers) {
                if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                    [((MNDeviceListViewController *)viewController) loadingDeviceData];
                }
            }
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else if (self.app.is_vimtag)
        {
            UIStoryboard *guideStoryboard = [UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil];
//            MNDeviceListPageViewController *deviceListPageViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceListPageViewController"];
//            [self.navigationController pushViewController:deviceListPageViewController animated:YES];
            MNDeviceListSetViewController *deviceListSetViewController = [guideStoryboard instantiateViewControllerWithIdentifier:@"MNDeviceListSetViewController"];
            [self.navigationController pushViewController:deviceListSetViewController animated:YES];
        }
        else
        {
            UINavigationController *navigationController = (UINavigationController *)self.presentingViewController;
            for (UIViewController *viewController in navigationController.viewControllers) {
                if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                    [((MNDeviceListViewController *)viewController) loadingDeviceData];
                }
            }
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        if (self.app.is_vimtag) {
            if (self.presentingViewController) {
                UITabBarController *rootTabBarController = (UITabBarController*)self.presentingViewController;
                for (UINavigationController *navigationController in rootTabBarController.viewControllers) {
                    for (UIViewController *viewController in navigationController.viewControllers) {
//                        if ([viewController isMemberOfClass:[MNDeviceListPageViewController class]]) {
//                            MNDeviceListViewController *deviceListViewController= [((MNDeviceListPageViewController*)viewController).viewControllerArray firstObject];
//                            [deviceListViewController refreshData];
//                        }
                        if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                            MNDeviceListViewController *deviceListViewController = ((MNDeviceListSetViewController *)viewController).deviceListViewController;
                            [deviceListViewController refreshData];
                        }
                    }
                }
                [self dismissViewControllerAnimated:YES completion:nil];

            }
        } else {
            if (self.presentingViewController && !self.app.is_jump)
            {
                UINavigationController *rootNavigationcontroller = (UINavigationController*)self.presentingViewController;
                for (UIViewController *viewController in rootNavigationcontroller.viewControllers)
                {
                    if ([viewController isMemberOfClass:[MNDeviceListViewController class]]) {
                        [((MNDeviceListViewController*)viewController) refreshData];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            }
            else
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }

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
@end
