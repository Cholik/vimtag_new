//
//  MNDevicePasswordManagerViewController.m
//  mining_client
//
//  Created by mining on 14-9-9.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDevicePasswordManagerViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MIPCUtils.h"
#import "UserInfo.h"
#import "MNInfoPromptView.h"

@interface MNDevicePasswordManagerViewController ()
{
    unsigned char  _new_encrypt_pwd[16];
}
@property (assign, nonatomic) BOOL isViewAppearing;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNDevicePasswordManagerViewController

#pragma mark - Initialization
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
        self.title = NSLocalizedString(@"mcs_device_admin_password", nil);
    }
    
    return self;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_device_admin_password", nil);
    
    [_commitButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_commitButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_commitButton setBackgroundColor:app.button_color];

    _currentPasswordHintLabel.text = NSLocalizedString(@"mcs_old_password", nil);
    _changePasswordHintLabel.text = NSLocalizedString(@"mcs_new_password", nil);
    _commitPasswordHintLabel.text = NSLocalizedString(@"mcs_confirm_password", nil);
    
    _currentPasswordTextField.placeholder = NSLocalizedString(@"mcs_input_password" , nil);
    _changePasswordTextField.placeholder = NSLocalizedString(@"mcs_input_new_pass", nil);
    _commitPasswordTextField.placeholder = NSLocalizedString(@"mcs_confirm_password", nil);

}

#pragma mark - view LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    
    //keyboard dismiss style
    if ([self.tableView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        [self.tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    }
    else
    {
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self.tableView addGestureRecognizer:singleTapGestureRecognizer];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

#pragma mark - Keyboard Hide
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer*)gesturenizer
{
    [[UIApplication sharedApplication] resignFirstResponder];
}

- (IBAction)apply:(id)sender
{
    if ( nil == _currentPasswordTextField.text
        || nil == _changePasswordTextField.text
        || 0 == _currentPasswordTextField.text.length
        || 0 == _changePasswordTextField.text.length)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_blank_password", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_blank_password", nil)]];
        }
        return;
    }
    
    if (![_changePasswordTextField.text isEqualToString:_commitPasswordTextField.text]) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_two_password_input_inconsistent", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_two_password_input_inconsistent", nil)]];
        }
        return;
    }
    
    if (_changePasswordTextField.text.length < 6 || _changePasswordTextField.text.length > 32) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_range_hint", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_password_range_hint", nil)]];
        }
        return;
    }
    
    if ([_currentPasswordTextField.text isEqualToString:@"amdin"]) {
        _currentPasswordTextField.text = @"admin";
    }
    mcall_ctx_dev_passwd_set *ctx = [[mcall_ctx_dev_passwd_set alloc] init];
    ctx.sn = _deviceID;
    unsigned char  *_new_pwd = malloc(16), *_old_pwd = malloc(16);
    [mipc_agent passwd_encrypt:_changePasswordTextField.text encrypt_pwd:_new_pwd];
    [mipc_agent passwd_encrypt:_currentPasswordTextField.text encrypt_pwd:_old_pwd];
    ctx.on_event = @selector(dev_passwd_set_done:);
    ctx.target = self;
    ctx.new_encrypt_pwd = _new_pwd;
    ctx.old_encrypt_pwd = _old_pwd;
    ctx.is_guest = NO;
    
    [_agent dev_passwd_set:ctx];
    
    [self loading:YES];
}


#pragma mark - Netword Callback
- (void)dev_passwd_set_done:(mcall_ret_dev_passwd_set *)ret
{
    if (!_isViewAppearing)
    {
        [self loading:NO];
        return;
    }
    
    if (nil == ret.result)
    {
//        [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        if (self.app.isLocalDevice) {
//            [self loading:NO];
            
            [mipc_agent passwd_encrypt:_changePasswordTextField.text encrypt_pwd:_new_encrypt_pwd];
            UserInfo *userInfo = [[UserInfo alloc] init];
            userInfo.name = _deviceID;
            char *pass_md5 = _new_encrypt_pwd;
            NSData *data = [NSData dataWithBytes:pass_md5   length:16];
            userInfo.password = data;
            [self saveUserInfoToLocal:userInfo];

            m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
            mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
            ctx.srv = MIPC_SrvFix(dev.ip_addr);
            ctx.user = _deviceID;
            ctx.passwd = _new_encrypt_pwd;
            ctx.target = self;
            ctx.on_event = @selector(sign_in_done:);

            [self.agent local_sign_in:ctx switchMmq:YES];
            
        }
        else if (!self.app.isLoginByID) {
//            [self loading:NO];
            unsigned char encrypt_pwd[16] = {0};
            [mipc_agent passwd_encrypt:_changePasswordTextField.text encrypt_pwd:encrypt_pwd];
            
            mcall_ctx_dev_add *ctx = [[mcall_ctx_dev_add alloc] init];
            ctx.sn = _deviceID;
            ctx.passwd = encrypt_pwd;
            ctx.target = self;
            ctx.on_event = @selector(dev_add_done:);
            [self.agent dev_add:ctx];
        }
        else
        {
          
            [mipc_agent passwd_encrypt:_changePasswordTextField.text encrypt_pwd:_new_encrypt_pwd];
            struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
            
            if(conf)
            {
                conf_new        = *conf;
            }
            if (conf && conf->password_md5.len)
            {
                conf_new.password_md5.data = (char*)_new_encrypt_pwd;
                conf_new.password_md5.len = 16;
                MIPC_ConfigSave(&conf_new);
            }
    
            NSString *connectDevID = MIPC_GetConnectedIPCDevID();
            mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc]init];
            ctx.srv = nil;
            ctx.user = _deviceID;
            ctx.passwd = _new_encrypt_pwd;
            ctx.target = self;
            if (connectDevID && connectDevID.length) {
                ctx.srv = @"http://192.168.188.254/ccm";
            }
            ctx.on_event = @selector(sign_in_done:);
            [_agent sign_in:ctx];
        }
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
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_password", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_invalid_password",nil)]];
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

- (void)dev_add_done:(mcall_ret_dev_add*)ret
{
    [self loading:NO];
    if (nil == ret.result) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        }
    }
}

- (void)sign_in_done:(mcall_ret_dev_add*)ret
{
    [self loading:NO];
    if (nil == ret.result) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        }
    }
}

#pragma mark - Utils
- (void)saveUserInfoToLocal:(UserInfo *)userInfo
{
    NSData *usersData = [[NSUserDefaults standardUserDefaults] dataForKey:@"local_users"];
    
    NSMutableArray *usersArray = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:usersData]];
    
    if (userInfo.name && userInfo.password)
    {
        
        if (![usersArray containsObject:userInfo])
        {
            [usersArray insertObject:userInfo atIndex:0];
        }
        else
        {
            for (int i =0; i<usersArray.count; i++) {
                UserInfo *tempInfo = [usersArray objectAtIndex:i];
                
                if ([tempInfo.name isEqualToString:userInfo.name])
                {
                    [usersArray replaceObjectAtIndex:i withObject:userInfo];
                }
            }
        }
        NSData *usersData = [NSKeyedArchiver archivedDataWithRootObject:usersArray];
        
        [[NSUserDefaults standardUserDefaults] setObject:usersData forKey:@"local_users"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}
@end
