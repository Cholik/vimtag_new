//
//  UIsystemTableViewController.m
//  mining_client
//
//  Created by mining on 14-9-12.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDeviceSystemSetViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MNDeviceTabBarController.h"
#import "UITabBar+badgeValue.h"
#import "MNSystemSettingsAlertView.h"
#import "MNInfoPromptView.h"

#define DEVICEUPDATE 1000
#define DEVICERECOVER 1001
#define DEVICEREBOOT 1002
#define DEVICERESTARTING 1003

#define UPDATE @"update"
#define RECOVER @"recover"
#define REBOOT @"reboot"

@interface MNDeviceSystemSetViewController ()
@property (assign, nonatomic) BOOL isViewAppearing;
@property (assign, nonatomic) BOOL isUpgrading;
@property (assign, nonatomic) int getUpgradeStatusCount;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *currentVersion;
@property (strong, nonatomic) NSString *validVersion;
@property (strong, nonatomic)  UILabel *updateLabel;
@property (strong, nonatomic)  MNCustomAlertView *customAlertView;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSString *currentLanguage;

@end

@implementation MNDeviceSystemSetViewController

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = NSLocalizedString(@"mcs_system_settings", nil);
    }
    
    return self;
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_system_settings", nil);
    if (self.is_videoPlay) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_delete.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    
    [self.updateButton setTitle:NSLocalizedString(@"mcs_upgrade", nil) forState:UIControlStateNormal];
    [self.updateButton setEnabled:NO];
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_updateButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_updateButton setBackgroundColor:app.button_color];
    
    [self.recoverButton setTitle:NSLocalizedString(@"mcs_restore_the_factory_settings", nil) forState:UIControlStateNormal];
    [_recoverButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_recoverButton setBackgroundColor:app.button_color];

    [self.rebootButton setTitle:NSLocalizedString(@"mcs_restore_camera", nil) forState:UIControlStateNormal];
    [_rebootButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_rebootButton setBackgroundColor:app.button_color];
    
    if (!self.app.is_vimtag && (((MNDeviceTabBarController *)self.navigationController.tabBarController).ver_valid
        || self.ver_valid)) {
        //get cell.textLabel.Size
        CGSize labelSize = CGSizeMake(100, 20);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
        {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
       labelSize = [_updateButton.titleLabel.text boundingRectWithSize:CGSizeMake(0, 0)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                                    attributes:attributes
                                                                       context:nil].size;
        
        labelSize.width = ceil(labelSize.width);
        }
        _updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 + labelSize.width / 2 + 10, 13, 40, 18)];
        _updateLabel.backgroundColor = [UIColor redColor];
        _updateLabel.textColor = [UIColor whiteColor];
        _updateLabel.text = NSLocalizedString(@"mcs_new", nil);
        
        _updateLabel.textAlignment = NSTextAlignmentCenter;
        _updateLabel.layer.cornerRadius = 9.5f;
        _updateLabel.font = [UIFont systemFontOfSize:14];
        _updateLabel.layer.masksToBounds = YES;
        
        [_updateView addSubview:_updateLabel];
    }
    else if (self.app.is_vimtag && self.ver_valid)
    {
        //get cell.textLabel.Size
        CGSize labelSize = CGSizeMake(100, 20);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
        {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20], NSParagraphStyleAttributeName:paragraphStyle.copy};
            
            labelSize = [_updateButton.titleLabel.text boundingRectWithSize:CGSizeMake(0, 0)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                                 attributes:attributes
                                                                    context:nil].size;
            
            labelSize.width = ceil(labelSize.width);
        }
        _updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 + labelSize.width / 2 + 10, 13, 40, 18)];
        _updateLabel.backgroundColor = [UIColor redColor];
        _updateLabel.textColor = [UIColor whiteColor];
        _updateLabel.text = NSLocalizedString(@"mcs_new", nil);
        
        _updateLabel.textAlignment = NSTextAlignmentCenter;
        _updateLabel.layer.cornerRadius = 9.5f;
        _updateLabel.font = [UIFont systemFontOfSize:14];
        _updateLabel.layer.masksToBounds = YES;
        
        [_updateView addSubview:_updateLabel];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    
    _version = NSLocalizedString(@"mcs_upgrade_to_ver", nil);
    //get currentLanguage
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey : @"AppleLanguages" ];
    _isViewAppearing = YES;
    _currentLanguage = [languages objectAtIndex:0];
    if ([_currentLanguage rangeOfString:@"zh-Hans"].length) {
        _currentLanguage=@"zh";
    }
    if ([_currentLanguage rangeOfString:@"zh-Hant"].length) {
        _currentLanguage=@"tw";
    }

    mcall_ctx_upgrade_get *ctx = [[mcall_ctx_upgrade_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(upgrade_get_done:);
    
    [_agent upgrade_get:ctx];
    [self loading:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MNInfoPromptView hideAll:_rootNavigationController];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
    _isUpgrading = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - upgrade_get_done
- (void)upgrade_get_done:(mcall_ret_upgrade_get *)ret
{
    if (!_isUpgrading) {
        [self loading:NO];
    }
    
    if(!_isViewAppearing)
    {
        return;
    }
    
    if(nil != ret.result)
    {
        [self loading:NO];
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView failToast:nil]];
            }
        }
        return;
    }
    
    if(!_isUpgrading)
    {
        //set the version
        _version = [_version stringByAppendingString:[NSString stringWithFormat:@":%@", ret.ver_valid]];
        _validVersion = ret.ver_valid;
        _currentVersion = ret.ver_current;
        [self.tableView reloadData];
        
        if ((ret.ver_valid.length != 0 && ret.ver_current.length != 0 && ![ret.ver_valid isEqualToString:ret.ver_current])
            || (ret.hw_ext.length != 0 && ![ret.hw_ext isEqualToString:ret.prj_ext]))
        {
            
            [_updateButton setTitle:NSLocalizedString(@"mcs_upgrade", nil) forState:UIControlStateNormal];
            [_updateButton setEnabled:YES];
        }
        else
        {
            [_updateButton setTitle:NSLocalizedString(@"mcs_already_latest_version", nil) forState:UIControlStateNormal];
            [_updateButton setEnabled:NO];
        }
    }

    
    if([ret.status isEqualToString:@"download"]
            ||[ret.status isEqualToString:@"erase"]
            || [ret.status isEqualToString:@"write"])
    {
        if (_isUpgrading) {
            
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                mcall_ctx_upgrade_get *ctx = [[mcall_ctx_upgrade_get alloc] init];
                ctx.sn = _deviceID;
                ctx.target = weakSelf;
                ctx.on_event = @selector(upgrade_get_done:);
                
                [_agent upgrade_get:ctx];
            });
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_upgrading", nil)
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    else if([ret.status isEqualToString:@"finish"] && _isUpgrading)
    {
        _isUpgrading = NO;
        [self loading:NO];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_upgrade_successful_restart_to_take_effect", nil)
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
        alertView.tag = DEVICEREBOOT;
        [alertView show];
    }
    else if([ret.status isEqualToString:@"fail"]  && _isUpgrading)
    {
        _isUpgrading = NO;
        [self loading:NO];
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_update_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_update_failed", nil)]];
        }
    }
    
    
}

#pragma mark - upgrade_set_done
- (void)upgrade_set_done:(mcall_ret_upgrade_set *)ret
{
    //    [self loading:NO];
    if (nil == ret.result)
    {
        //        [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        
        _isUpgrading = YES;
        _getUpgradeStatusCount++;
        mcall_ctx_upgrade_get *ctx = [[mcall_ctx_upgrade_get alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(upgrade_get_done:);
        
        [_agent upgrade_get:ctx];
        //        [self loading:YES];
    }
    else
    {
        [self loading:NO];
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_failed_to_set_the", nil)]];
            }
        }
    }
}

#pragma mark - reboot_done
- (void)reboot_done:(mcall_ret_reboot *)ret
{
    [self loading:NO];
    if (!_isViewAppearing) {
        return;
    }
    
    if(nil == ret.result)
    {
        NSString *buttonTitle;
        if (self.app.is_jump && (self.app.isLoginByID || (self.app.serialNumber && self.app.serialNumber.length)))
        {
            buttonTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"mcs_will_back", nil), self.app.fromTarget];
        }
        else
        {
            buttonTitle = NSLocalizedString(@"mcs_i_know", nil);
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_restarting" , nil)
                                                       message:NSLocalizedString(@"mcs_visit_again_later", nil)
                                                      delegate:self
                                             cancelButtonTitle:nil
                                                  otherButtonTitles:buttonTitle , nil];
        alertView.tag = DEVICERESTARTING;
        [alertView show];
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_restart_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_restart_failed", nil)]];
            }
        }
    }
}

#pragma mark - restore_done
- (void)restore_done:(mcall_ret_restore *)ret
{
    [self loading:NO];
    if (!_isViewAppearing) {
        return;
    }
    
    NSLog(@"%@============", ret.result);
    if(nil == ret.result)
    {
        //FIXME:add alert
        mcall_ctx_reboot *ctx = [[mcall_ctx_reboot alloc] init];
        ctx.sn = _deviceID;
        ctx.on_event = @selector(reboot_done:);
        ctx.target = self;
        [_agent reboot:ctx];
        [self loading:YES];
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_restore_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_restore_failed", nil)]];
            }
        }
    }
}

#pragma mark - get desc done
- (void)get_desc_done:(mcall_ret_get_desc *)ret
{
    [self loading:NO];
    if (!_isViewAppearing) {
        return;
    }
    
    if ([ret.result isEqualToString:@"ret.dev.offline"]) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
        }
        return;
    }
    else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
        }
        return;
    }
    else if ([ret.result isEqualToString:@"ret.permission.denied"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied",nil)]];
        }
        return;
    }
    
    if (self.app.is_vimtag ) {
        _customAlertView = [[MNCustomAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds Title: NSLocalizedString(@"mcs_prompt",nil)  Details:ret.desc.length ? ret.desc : NSLocalizedString(@"mcs_do_you_want_upgrade",nil) isSave:NO];
        _customAlertView.delegate = self;
        _customAlertView.tag =  DEVICEUPDATE;
        [_customAlertView show];
        [self.view addSubview:_customAlertView];
    } else {
        MNSystemSettingsAlertView *alertView = [[MNSystemSettingsAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt",nil) detail:ret.desc.length ? ret.desc : NSLocalizedString(@"mcs_do_you_want_upgrade",nil) Type:UPDATE];
        [alertView addButtonWithTitle:NSLocalizedString(@"mcs_ok", nil)
                                 type:MNAlertViewButtonTypeDefault
                              handler:^(MNSystemSettingsAlertView *alertView, MNAlertButtonItem *button) {
                                  [alertView dismiss];
                                  mcall_ctx_upgrade_set *ctx = [[mcall_ctx_upgrade_set alloc] init];
                                  ctx.sn = _deviceID;
                                  ctx.on_event = @selector(upgrade_set_done:);
                                  ctx.target = self;
                                  [_agent upgrade_set:ctx];
                                  [self loading:YES];
                              }];
        [alertView show];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//按钮操作

#pragma mark - Action
- (void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)update:(id)sender
{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_do_you_want_upgrade", nil)
//                                                        message:nil
//                                                       delegate:self
//                                              cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
//                                              otherButtonTitles:NSLocalizedString(@"mcs_ok", nil) , nil];
//    alertView.tag = DEVICEUPDATE;
//    [alertView show];
//    if (self.app.is_vimtag) {
//        _customAlertView = [[MNCustomAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds Title:NSLocalizedString(@"mcs_prompt",nil) Details:NSLocalizedString(@"mcs_do_you_want_upgrade", nil) isSave:NO];
//        _customAlertView.delegate = self;
//        _customAlertView.tag =  DEVICEUPDATE;
//        [_customAlertView show];
//        [self.view addSubview:_customAlertView];
//    } else {
//        _alertView = [[MNAlertView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:NSLocalizedString(@"mcs_do_you_want_upgrade", nil)];
//        _alertView.saveNetworkButton.hidden = YES;
//        _alertView.saveNetworkLabel.hidden = YES;
//
//        _alertView.delegate = self;
//        _alertView.tag =  DEVICEUPDATE;
//        [self.view addSubview:_alertView];
//    }
    
    mcall_ctx_get_desc *ctx = [[mcall_ctx_get_desc alloc] init];
    ctx.ver_from = _currentVersion;
    ctx.ver_to = _validVersion;
    ctx.lang = _currentLanguage;
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event  = @selector(get_desc_done:);
    [self.agent get_desc:ctx];
    [self loading:YES];
}

- (IBAction)recover:(id)sender
{
//    UIAlertView *alertView = [[UIAlertView alloc]
//                              initWithTitle:NSLocalizedString(@"mcs_restore_factory_settings_prompt", nil)
//                                                        message:nil
//                                                       delegate:self
//                                              cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
//                                              otherButtonTitles:NSLocalizedString(@"mcs_ok", nil) , nil];
//
//    alertView.tag = DEVICERECOVER;
//    [alertView show];

    if(self.app.is_vimtag)
    {
        _customAlertView = [[MNCustomAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds Title:NSLocalizedString(@"mcs_prompt",nil) Details:NSLocalizedString(@"mcs_restore_factory_settings_prompt", nil) isSave:YES];
        _customAlertView.delegate = self;
        _customAlertView.tag =  DEVICERECOVER;
        [_customAlertView show];
        [self.view addSubview:_customAlertView];
    }
    else
    {
        MNSystemSettingsAlertView *alertView = [[MNSystemSettingsAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt",nil)  detail:NSLocalizedString(@"mcs_restore_factory_settings_prompt", nil) Type:RECOVER];
        [alertView addButtonWithTitle:NSLocalizedString(@"mcs_ok", nil)
                                 type:MNAlertViewButtonTypeDefault
                              handler:^(MNSystemSettingsAlertView *alertView, MNAlertButtonItem *button) {
                                  [alertView dismiss];
                                  mcall_ctx_restore *ctx = [[mcall_ctx_restore alloc] init];
                                  ctx.sn = _deviceID;
                                  ctx.keep_base_cofig = alertView.isSaveNetwork;
                                  ctx.on_event = @selector(restore_done:);
                                  ctx.target = self;
                                  [_agent restore:ctx];
                                  [self loading:YES];
                              }];
        [alertView show];

    }
}

- (IBAction)reboot:(id)sender
{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_do_you_want_restart", nil)
//                                                        message:nil
//                                                       delegate:self
//                                              cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
//                                              otherButtonTitles:NSLocalizedString(@"mcs_ok", nil) , nil];
//    alertView.tag = DEVICEREBOOT;
//    [alertView show];
    
    if (self.app.is_vimtag) {
        _customAlertView = [[MNCustomAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds Title:NSLocalizedString(@"mcs_prompt",nil) Details:NSLocalizedString(@"mcs_do_you_want_restart", nil) isSave:NO];
        _customAlertView.delegate = self;
        _customAlertView.tag =  DEVICEREBOOT;
        [_customAlertView show];
        [self.view addSubview:_customAlertView];
    } else {
        MNSystemSettingsAlertView *alertView = [[MNSystemSettingsAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt",nil)  detail:NSLocalizedString(@"mcs_do_you_want_restart", nil) Type:REBOOT];
        [alertView addButtonWithTitle:NSLocalizedString(@"mcs_ok", nil)
                                 type:MNAlertViewButtonTypeDefault
                              handler:^(MNSystemSettingsAlertView *alertView, MNAlertButtonItem *button) {
                                  [alertView dismiss];
                                  
                                  mcall_ctx_reboot *ctx = [[mcall_ctx_reboot alloc] init];
                                  ctx.sn = _deviceID;
                                  ctx.on_event = @selector(reboot_done:);
                                  ctx.target = self;
                                  [_agent reboot:ctx];
                                  [self loading:YES];
                              }];
        [alertView show];
    }
}


#pragma mark - View did layout subviews
- (void)viewDidLayoutSubviews
{
    if (!self.app.is_vimtag && (((MNDeviceTabBarController *)self.navigationController.tabBarController).ver_valid || self.ver_valid)) {
        //get cell.textLabel.Size
        CGSize labelSize = CGSizeMake(100, 20);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
        {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
            labelSize = [_updateButton.titleLabel.text boundingRectWithSize:CGSizeMake(0, 0)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                                    attributes:attributes
                                                                       context:nil].size;
        
            labelSize.width = ceil(labelSize.width);
        }
        
        _updateLabel.frame = CGRectMake(self.view.frame.size.width / 2 + labelSize.width / 2 + 10, 13, 40, 18);
    }
    else if (self.app.is_vimtag && self.ver_valid)
    {
        CGSize labelSize = CGSizeMake(100, 20);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
        {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20], NSParagraphStyleAttributeName:paragraphStyle.copy};
            
            labelSize = [_updateButton.titleLabel.text boundingRectWithSize:CGSizeMake(0, 0)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                                 attributes:attributes
                                                                    context:nil].size;
            
            labelSize.width = ceil(labelSize.width);
        }
        
        _updateLabel.frame = CGRectMake(self.view.frame.size.width / 2 + labelSize.width / 2 + 10, 13, 40, 18);
    }
    
    if (self.app.is_vimtag) {
        CGRect frame = [UIScreen mainScreen].bounds;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            frame = self.view.bounds;
        }
        
        _customAlertView.contentView.frame = CGRectMake((frame.size.width - 240.0)/2, (frame.size.height - 240.0)/2, 240.0, 240.0);
        _customAlertView.circleViewBackground.frame = CGRectMake(_customAlertView.contentView.center.x -50.0, _customAlertView.contentView.frame.origin.y - 50.0, 50.0 * 2, 50.0 * 2);
    }
}
#pragma mark -MNAlertView delegate
-(void)customAlertView:(MNCustomAlertView *)customAlertView {
    
    switch ([customAlertView tag])
    {
        case DEVICEUPDATE:
        {
            //FIXME:add alert
            mcall_ctx_upgrade_set *ctx = [[mcall_ctx_upgrade_set alloc] init];
            ctx.sn = _deviceID;
            ctx.on_event = @selector(upgrade_set_done:);
            ctx.target = self;
            [_agent upgrade_set:ctx];
            [self loading:YES];
            break;
        }
        case DEVICEREBOOT:
        {
            mcall_ctx_reboot *ctx = [[mcall_ctx_reboot alloc] init];
            ctx.sn = _deviceID;
            ctx.on_event = @selector(reboot_done:);
            ctx.target = self;
            [_agent reboot:ctx];
            [self loading:YES];
            break;
        }
        case DEVICERECOVER:
        {
            mcall_ctx_restore *ctx = [[mcall_ctx_restore alloc] init];
            ctx.sn = _deviceID;
            ctx.keep_base_cofig = _customAlertView.isSaveNetwork;
            ctx.on_event = @selector(restore_done:);
            ctx.target = self;
            [_agent restore:ctx];
            [self loading:YES];
            break;
        }
        case DEVICERESTARTING:
        {
            if (_is_videoPlay) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSNotification *notification = [NSNotification notificationWithName:@"DeviceRestartNotification" object:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        }
        default:
            break;
    }
}

#pragma mark - AlertView delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        switch ([alertView tag])
        {
            case DEVICEUPDATE:
            {
                //FIXME:add alert
                mcall_ctx_upgrade_set *ctx = [[mcall_ctx_upgrade_set alloc] init];
                ctx.sn = _deviceID;
                ctx.on_event = @selector(upgrade_set_done:);
                ctx.target = self;
                [_agent upgrade_set:ctx];
                [self loading:YES];
                break;
            }
            case DEVICEREBOOT:
            {
                mcall_ctx_reboot *ctx = [[mcall_ctx_reboot alloc] init];
                ctx.sn = _deviceID;
                ctx.on_event = @selector(reboot_done:);
                ctx.target = self;
                [_agent reboot:ctx];
                [self loading:YES];
                break;
            }
            case DEVICERECOVER:
            {
                mcall_ctx_restore *ctx = [[mcall_ctx_restore alloc] init];
                ctx.sn = _deviceID;
                ctx.keep_base_cofig = NO;
                ctx.on_event = @selector(restore_done:);
                ctx.target = self;
                [_agent restore:ctx];
                [self loading:YES];
                break;
            }
            case DEVICERESTARTING:
            {
                if (self.app.is_jump && (self.app.isLoginByID || (self.app.serialNumber && self.app.serialNumber.length)))
                {
                    NSString *url = [self.app.fromTarget stringByAppendingString:@"://ret.dev.offline"];
                    if (url) {
                        self.app.is_jump = NO;
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    }
                    
                }
                else
                {
                    if (_is_videoPlay) {
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    } else {
                        NSNotification *notification = [NSNotification notificationWithName:@"DeviceRestartNotification" object:nil];
                        [[NSNotificationCenter defaultCenter] postNotification:notification];
                    }
                }
            }
            default:
                break;
        }
    }
}

#pragma mark - Table view data source
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        if (!self.ver_valid && [_validVersion isEqualToString:_currentVersion]) {
            return nil;
        }else{
            return _version;
        }
    }
    else
    {
        return nil;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"mcs_online_upgrade", nil);
    }
    else
    {
        return nil;
    }
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 40;
    }
    else
    {
        return 0;
    }
}

#pragma mark - Interface orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.view setNeedsUpdateConstraints];
}


//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//        customView.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, 315, 20)];
//        label.font = [UIFont systemFontOfSize:14];
//        label.textColor = [UIColor grayColor];
//        label.lineBreakMode = NSLineBreakByCharWrapping;
//        label.text = NSLocalizedString(@"mcs_online_upgrade", nil);
//        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        
//        [customView addSubview:label];
//        
//        return customView;
//
//    }
//    else
//    {
//        return nil;
//    }
//    
//}
@end
