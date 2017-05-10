//
//  UISDcardTableViewController.m
//  mining_client
//
//  Created by mining on 14-9-10.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDeviceSDcardSetViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"

#define FORMATALERT 1001
#define UNMOUNTALERT 1002
#define REPAIRALERT 1003
#define REBOOTALERT 1004
#define MOUNTALERT 1005

@interface MNDeviceSDcardSetViewController ()
@property (assign, nonatomic) BOOL isViewAppearing;
@property (assign, nonatomic) int sectionNumbers;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (assign, nonatomic) BOOL isReboot;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNDeviceSDcardSetViewController

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
             //   self.title = NSLocalizedString(@"mcs_sdcord", nil);
    }
    
    return self;
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
    _dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if ([_dev.type isEqualToString:@"IPC"])
    {
        [self setTitle:NSLocalizedString(@"mcs_sdcord", nil)];;
    }
    else
    {
        [self setTitle:NSLocalizedString(@"mcs_hard_disk", nil)];
    }
    
    [_commitButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    [_formatButton setTitle:NSLocalizedString(@"mcs_format", nil) forState:UIControlStateNormal];
    
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_commitButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_commitButton setBackgroundColor:app.button_color];
    [_formatButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_formatButton setBackgroundColor:app.button_color];
    
    [_formatButton setUserInteractionEnabled:NO];
    
    self.enableTiteLabel.text = NSLocalizedString(@"mcs_enabled", nil);
    self.stateTiteLabel.text = NSLocalizedString(@"mcs_status", nil);
    self.roomTiteLabel.text = NSLocalizedString(@"mcs_capacity", nil);
    self.usedTiteLabel.text = NSLocalizedString(@"mcs_usage", nil);
    self.availableTiteLabel.text = NSLocalizedString(@"mcs_valid", nil);
    self.stateLable.text = NSLocalizedString(@"mcs_no_sdcard", nil);
    self.enableSwitch.onTintColor = self.configuration.switchTintColor;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    
    _sectionNumbers = 4;
    
    _isViewAppearing = YES;
    
    mcall_ctx_sd_get *ctx = [[mcall_ctx_sd_get alloc] init];
    ctx.sn = _deviceID;
    ctx.on_event = @selector(sd_get_done:);
    ctx.target = self;
    
    [_agent sd_get:ctx];
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

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Action
- (IBAction)setupEnableStatus:(id)sender
{
    NSRange range = NSMakeRange(1, 2);
    
    [self.tableView beginUpdates];
    
    if (((UISwitch*)sender).on)
    {
        _sectionNumbers = 4;
        if (self.tableView.numberOfSections != _sectionNumbers)
        {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:range] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else
    {
        _sectionNumbers = 2;
        if (self.tableView.numberOfSections != _sectionNumbers)
        {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:range] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    [self.tableView endUpdates];
}

- (IBAction)format:(id)sender
{
    //FIXME:add alert

    UIAlertView *alertView;
    if ([_stateLable.text isEqualToString:NSLocalizedString(@"mcs_no_sdcard", nil)])
    {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_no_sdcard", nil)
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
                                                  otherButtonTitles: nil];
    }
    else if ([self.dev.img_ver compare:@"v2"] ==  NSOrderedAscending)
    {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_sdcard_formating", nil)
                                               message:nil
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                     otherButtonTitles:NSLocalizedString(@"mcs_ok", nil) , nil];
         alertView.tag = FORMATALERT;
    }
    else
    {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_format_prompt", nil)
                                               message:nil
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                     otherButtonTitles:NSLocalizedString(@"mcs_ok", nil) , nil];
         alertView.tag = FORMATALERT;
    }
  
    [alertView show];
}

//- (IBAction)unmount:(id)sender
//{
//    //FIXME:add alert
//    if ([_stateLable.text isEqualToString:NSLocalizedString(@"mcs_mounted", nil)]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_umounted_prompt", nil)
//                                                            message:nil
//                                                           delegate:self
//                                                  cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
//                                                  otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
//        alertView.tag = UNMOUNTALERT;
//        [alertView show];
//    } else if ([_stateLable.text isEqualToString:NSLocalizedString(@"mcs_sdcard_umount", nil)])
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_mounted_prompt", nil)
//                                                            message:nil
//                                                           delegate:self
//                                                  cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
//                                                  otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
//        alertView.tag = MOUNTALERT;
//        [alertView show];
//    }
//    else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_no_sdcard", nil)
//                                                            message:nil
//                                                           delegate:self
//                                                  cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
//                                                  otherButtonTitles: nil];
//        //alertView.tag = UNMOUNTALERT;
//        [alertView show];
//    }
//}

//- (IBAction)repair:(id)sender
//{
//    
//    UIAlertView *alertView;
//    if ([_stateLable.text isEqualToString:NSLocalizedString(@"mcs_no_sdcard", nil)])
//    {
//        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_no_sdcard", nil)
//                                               message:nil
//                                              delegate:self
//                                     cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
//                                     otherButtonTitles: nil];
//    }
//    else if ([self.dev.img_ver compare:@"v2"] ==  NSOrderedAscending)
//    {
//        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_sdcard_repairing", nil)
//                                               message:nil
//                                              delegate:self
//                                     cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
//                                     otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
//         alertView.tag = REPAIRALERT;
//    }
//    else
//    {
//        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_repair_prompt", nil)
//                                               message:nil
//                                              delegate:self
//                                     cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
//                                     otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
//         alertView.tag = REPAIRALERT;
//    }
//    
//    [alertView show];
//    
//}


- (IBAction)apply:(id)sender
{
    self.isReboot = NO;
    mcall_ctx_sd_set *ctx = [[mcall_ctx_sd_set alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(sd_set_done:);
    ctx.enable = _enableSwitch.on;
    
    [_agent sd_set:ctx];
    [self loading:YES];
}

#pragma mark - Sd_set_done
- (void)sd_set_done:(mcall_ret_sd_get *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing) {
        return;
    }
    
    if (self.isReboot) {
        mcall_ctx_reboot *ctx = [[mcall_ctx_reboot alloc] init] ;
        ctx.sn = _deviceID;
        ctx.on_event = @selector(reboot_done:);
        ctx.target = self;
        [_agent reboot:ctx];
    }
    
    if (nil == ret.result)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        }
        mcall_ctx_sd_get *ctx = [[mcall_ctx_sd_get alloc] init];
        ctx.sn = _deviceID;
        ctx.on_event = @selector(sd_get_status_done:);
        ctx.target = self;
        
//        [_agent sd_get:ctx];
        [_agent performSelector:@selector(sd_get:) withObject:ctx afterDelay:3];
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
    if (!_isViewAppearing) {
        return;
    }
    
    if(nil == ret.result)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_restarting", nil)
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil)
                                                  otherButtonTitles:nil , nil];
        alertView.tag = REBOOTALERT;
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

#pragma mark - Sd_get_done
//设置中SD卡操作
- (void)sd_get_done:(mcall_ret_sd_get *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing) {
        return;
    }
    
    if(nil != ret.result)
    {
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
    }
    
    BOOL enable = ret.enable;
    self.enableSwitch.on = enable;
    
    //setup the enable status
    [self setupEnableStatus:_enableSwitch];
   
    [self.formatButton setUserInteractionEnabled:enable];
    
    NSString *status = ret.status;
    if ([@"empty" isEqualToString:status])
    {
        if ([_dev.type isEqualToString:@"BOX"]) {
            self.stateLable.text = NSLocalizedString(@"mcs_no_hard_disk", nil);
        }
        else
        {
            self.stateLable.text = NSLocalizedString(@"mcs_no_sdcard", nil);
        }
        return;
    }
    
    if ([@"mount" isEqualToString:status])
    {
        self.stateLable.text = NSLocalizedString(@"mcs_mounted", nil);
    }
    
    if ([@"umount" isEqualToString:status])
    {
        self.stateLable.text = NSLocalizedString(@"mcs_sdcard_umount", nil);
    }
    
    if ([@"readonly" isEqualToString:status])
        self.stateLable.text = NSLocalizedString(@"mcs_readonly", nil);
    
    if ([@"formating" isEqualToString:status])
        self.stateLable.text = NSLocalizedString(@"mcs_formating", nil);
    
    if ([@"repairing" isEqualToString:status])
        self.stateLable.text = NSLocalizedString(@"mcs_repairing", nil);
    
    self.roomLable.text = ret.capacity >= 1024 ? [NSString stringWithFormat:@"%.2fGB", ret.capacity / 1024.0] : [NSString stringWithFormat:@"%ldMB",ret.capacity];
    self.usedLable.text        = ret.usage >= 1024 ? [NSString stringWithFormat:@"%.2fGB", ret.usage / 1024.0] : [NSString stringWithFormat:@"%ldMB",ret.usage];
    self.availableLabel.text   = ret.available_size >= 1024 ? [NSString stringWithFormat:@"%.2fGB", ret.available_size / 1024.0] : [NSString stringWithFormat:@"%ldMB",ret.available_size];
}

- (void)sd_get_status_done:(mcall_ret_sd_get *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing) {
        return;
    }
    
    if(nil != ret.result)
    {
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
    }
    
    BOOL enable = ret.enable;
    self.enableSwitch.on = enable;
    
    //setup the enable status
    [self setupEnableStatus:_enableSwitch];
    
    [self.formatButton setUserInteractionEnabled:enable];
    
    NSString *status = ret.status;
    if ([@"empty" isEqualToString:status])
    {
        if ([_dev.type isEqualToString:@"BOX"]) {
            self.stateLable.text = NSLocalizedString(@"mcs_no_hard_disk", nil);
        }
        else
        {
            self.stateLable.text = NSLocalizedString(@"mcs_no_sdcard", nil);
        }
        return;
    }
    
    if ([@"mount" isEqualToString:status])
    {
        self.stateLable.text = NSLocalizedString(@"mcs_mounted", nil);
    }
    
    if ([@"umount" isEqualToString:status])
    {
        self.stateLable.text = NSLocalizedString(@"mcs_sdcard_umount", nil);
    }
    
    if ([@"readonly" isEqualToString:status])
        self.stateLable.text = NSLocalizedString(@"mcs_readonly", nil);
    
    if ([@"formating" isEqualToString:status])
    {
        self.stateLable.text = NSLocalizedString(@"mcs_formating", nil);
        mcall_ctx_sd_get *ctx = [[mcall_ctx_sd_get alloc] init];
        ctx.sn = _deviceID;
        ctx.on_event = @selector(sd_get_status_done:);
        ctx.target = self;
        
        [_agent performSelector:@selector(sd_get:) withObject:ctx afterDelay:3];
    }
    if ([@"repairing" isEqualToString:status])
        self.stateLable.text = NSLocalizedString(@"mcs_repairing", nil);
    
    self.roomLable.text = ret.capacity >= 1024 ? [NSString stringWithFormat:@"%.2fGB", ret.capacity / 1024.0] : [NSString stringWithFormat:@"%ldMB",ret.capacity];
    self.usedLable.text        = ret.usage >= 1024 ? [NSString stringWithFormat:@"%.2fGB", ret.usage / 1024.0] : [NSString stringWithFormat:@"%ldMB",ret.usage];
    self.availableLabel.text   = ret.available_size >= 1024 ? [NSString stringWithFormat:@"%.2fGB", ret.available_size / 1024.0] : [NSString stringWithFormat:@"%ldMB",ret.available_size];
}

#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == FORMATALERT
            || alertView.tag == UNMOUNTALERT
            || alertView.tag == REPAIRALERT
            || alertView.tag == MOUNTALERT)
        {
            mcall_ctx_sd_set *ctx = [[mcall_ctx_sd_set alloc] init];
            ctx.sn = _deviceID;
            ctx.target = self;
            ctx.on_event = @selector(sd_set_done:);
            ctx.enable = _enableSwitch.on;
//            ctx.ctrl = @"format";
            
            
            switch (alertView.tag) {
                case FORMATALERT:
                    ctx.ctrl = @"format";
                    if ([self.dev.img_ver compare:@"v2"] ==  NSOrderedAscending)
                    {
                        self.isReboot = YES;
                    }
                    break;
                case UNMOUNTALERT:
                    ctx.ctrl = @"umount";
                    break;
                case MOUNTALERT:
                    ctx.ctrl = @"mount";
                    break;
                case REPAIRALERT:
                    ctx.ctrl = @"repair";
                    if ([self.dev.img_ver compare:@"v2"] ==  NSOrderedAscending)
                    {
                        self.isReboot = YES;
                    }
                    break;
                default:
                    ctx.ctrl = @"";
                    break;
            }
            
            [_agent sd_set:ctx];
            
        }

    }
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionNumbers;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row;
    
    switch (section) {
        case 0:
            row = 1;
            break;
        case 1:
            row = _enableSwitch.on?4:1;
            break;
        case 2:
            row = 1;
            break;
        case 3:
            row = 1;
            break;
        default:
            row = 0;
            break;
    }
    
    return row;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (_sectionNumbers == 2 && indexPath.section == 1)
    {
        NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 2];
        cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
    }
    else
    {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


@end
