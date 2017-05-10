//
//  MNGuestPasswordManagerViewController.m
//  mining_client
//
//  Created by mining on 14-9-9.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNGuestPasswordManagerViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MNInfoPromptView.h"

@interface MNGuestPasswordManagerViewController ()

@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) BOOL isViewAppearing;

@end

@implementation MNGuestPasswordManagerViewController

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

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
        self.title = NSLocalizedString(@"mcs_device_guest_password", nil);
    }
    
    return self;
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_device_guest_password", nil);
    
    [_commitButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_commitButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_commitButton setBackgroundColor:app.button_color];

    _adminPasswordHintLabel.text = NSLocalizedString(@"mcs_admin_password", nil);
    _visitorPasswordHintLabel.text = NSLocalizedString(@"mcs_guest_password", nil);
    _commitPasswordHintLabel.text = NSLocalizedString(@"mcs_confirm_password", nil);
    
    _adminPasswordTextField.placeholder = NSLocalizedString(@"mcs_input_password" , nil);
    _visitorPasswordTextField.placeholder = NSLocalizedString(@"mcs_guest_password", nil);
    _commitPasswordTextField.placeholder = NSLocalizedString(@"mcs_input_confirm_password", nil);
}

#pragma mark - View LifeCycle
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

#pragma mark - Action
- (void)handleSingleTap:(UITapGestureRecognizer*)gesturenizer
{
    [[UIApplication sharedApplication] resignFirstResponder];
}

- (IBAction)apply:(id)sender
{
    
    if(nil == _adminPasswordTextField.text
       || nil == _visitorPasswordTextField.text
       || 0 == _adminPasswordTextField.text.length
       || 0 == _visitorPasswordTextField.text.length)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_blank_password", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_blank_password", nil)]];
        }
        return ;
    }
    
    if (![_visitorPasswordTextField.text isEqualToString: _commitPasswordTextField.text]) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_two_password_input_inconsistent", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_two_password_input_inconsistent", nil)]];
        }
        return ;
    }
    
    if(_visitorPasswordTextField.text.length < 6 || _visitorPasswordTextField.text.length > 32)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_range_hint", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_password_range_hint", nil)]];
        }
        return ;
    }
        
    if ([_adminPasswordTextField.text isEqualToString:@"amdin"]) {
        _adminPasswordTextField.text = @"admin";
    }
    mcall_ctx_dev_passwd_set *ctx = [[mcall_ctx_dev_passwd_set alloc] init];
    ctx.sn = _deviceID;
    unsigned char  *encrypt_pwd = malloc(16), *encrypt_guest_pwd = malloc(16);
    [mipc_agent passwd_encrypt:_adminPasswordTextField.text encrypt_pwd:encrypt_pwd];
    [mipc_agent passwd_encrypt:_visitorPasswordTextField.text encrypt_pwd:encrypt_guest_pwd];
    
    ctx.on_event = @selector(dev_passwd_set_done:);
    ctx.target = self;
    ctx.is_guest = YES;
    ctx.new_encrypt_pwd = encrypt_guest_pwd;
    ctx.old_encrypt_pwd = encrypt_pwd;
    
    [_agent dev_passwd_set:ctx];
    [self loading:YES];
}

#pragma mark - Netword Callback
- (void)dev_passwd_set_done:(mcall_ret_dev_passwd_set *)ret
{
    [self loading:NO];
    
    if(nil == ret.result)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        }
    }
    else if ([ret.result isEqualToString:@"ret.dev.offline"]) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
        }
    }
    else if ([ret.result isEqualToString:@"ret.permission.denied"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied", nil)]];
        }
    }
    else if([ret.result isEqualToString:@"ret.pwd.invalid"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_password", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_invalid_password", nil)]];
        }
    }
    else if([ret.result isEqualToString:@"ret.permission.denied"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied", nil)]];
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


#pragma mark

@end
