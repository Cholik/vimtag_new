//
//  MNDeviceEthernetSetViewController.m
//  mining_client
//
//  Created by mining on 14-9-12.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDeviceEthernetSetViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"
#import "MNDetailViewController.h"
#import "MNDeviceNetworkSetViewController.h"

@interface MNDeviceEthernetSetViewController ()
@property (assign, nonatomic) BOOL isViewAppearing;
@property (assign, nonatomic) NSInteger sectionNumbers;
//save data
@property (copy, nonatomic) NSString *ip;
@property (copy, nonatomic) NSString *gateway;
@property (copy, nonatomic) NSString *mask;
@property (copy, nonatomic) NSString *firstDNS;
@property (copy, nonatomic) NSString *secondDNS;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNDeviceEthernetSetViewController

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
        self.title = NSLocalizedString(@"mcs_ethernet", nil);
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
    self.navigationItem.title = NSLocalizedString(@"mcs_ethernet", nil);
    [_commitButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];

    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_commitButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_commitButton setBackgroundColor:app.button_color];
    
    _enableTiteLabel.text = NSLocalizedString(@"mcs_enabled", nil);
    _MACAddressTiteLabel.text = NSLocalizedString(@"mcs_mac_address", nil);
    _linkStatusTiteLabel.text = NSLocalizedString(@"mcs_network_status", nil);
    
    _autoIPTiteLabel.text = NSLocalizedString(@"mcs_dhcp_ip", nil);
    _IPAddressTiteLabel.text = NSLocalizedString(@"mcs_ip_address", nil);
    _gatewayTiteLabel.text = NSLocalizedString(@"mcs_gateway", nil);
    _maskTiteLabel.text = NSLocalizedString(@"mcs_network_mask", nil);
    
    _autoDNSTiteLabel.text  = NSLocalizedString(@"mcs_dhcp_dns", nil);
    _firstDNSTiteLabel.text = NSLocalizedString(@"mcs_dns_prim" , nil);
    _standbyDNSTiteLabel.text = NSLocalizedString(@"mcs_secondary_dns", nil);
    
    _enableSwitch.onTintColor = self.configuration.switchTintColor;
    _autoDNSSwitch.onTintColor = self.configuration.switchTintColor;
    _autoIPSwitch.onTintColor = self.configuration.switchTintColor;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    
    _sectionNumbers = 5;
    //keyboard dismiss style
    if ([self.tableView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        [self.tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    }
    else
    {
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self.tableView addGestureRecognizer:singleTapGestureRecognizer];
    }
    _isViewAppearing = YES;
    
    mcall_ctx_net_get *ctx =[[mcall_ctx_net_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(net_get_done:);
    
    [_agent net_get:ctx];
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

#pragma mark - Keyboard Hide

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - net_get_done
- (void)net_get_done:(mcall_ret_net_get *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing)
    {
        return;
    }
    
    if(nil != ret.result || nil == ret.networks)
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                [self updateDetailVCFrame];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                [self updateDetailVCFrame];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                [self updateDetailVCFrame];
            } else {
                [self.view addSubview:[MNToastView failToast:nil]];
            }
        }
        return;
    }
    
    _enableSwitch.on = ((net_obj*)ret.networks[0]).enable;
    [_enableSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    
    _MACAddressLabel.text = ((net_obj*)ret.networks[0]).info.mac;
    _linkStatusLabel.text = [((net_obj*)ret.networks[0]).info.status isEqualToString:@"ok"]? NSLocalizedString(@"mcs_connnected", nil): NSLocalizedString(@"mcs_not_connected", nil);
    
    _autoIPSwitch.on = ((net_obj*)ret.networks[0]).ip.dhcp;
    _ip = ((net_obj*)ret.networks[0]).ip.ip;
    _IPAddressText.text = _ip;
    _gateway = ((net_obj*)ret.networks[0]).ip.gateway;
    _gatewayText.text = _gateway;
    _mask = ((net_obj*)ret.networks[0]).ip.mask;
    _maskText.text = _mask;
    
    [_autoIPSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    
    _autoDNSSwitch.on = ret.dns.dhcp;
    _firstDNS = ret.dns.dns;
    _firstDNSText.text = _firstDNS;
    _secondDNS = ret.dns.secondary_dns;
    _standbyDNSText.text = _secondDNS;
    
    [_autoDNSSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    
}

#pragma mark - net_set_done
- (void)net_set_done:(mcall_ret_net_set *)ret
{
    [self loading:NO];
    
    if(!_isViewAppearing)
    {
        return;
    }
    
    if (nil == ret.result)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
            [self updateDetailVCFrame];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        }
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                [self updateDetailVCFrame];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                [self updateDetailVCFrame];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                [self updateDetailVCFrame];
            } else {
                [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                [self updateDetailVCFrame];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_failed_to_set_the", nil)]];
            }
        }
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

#pragma mark - Action

- (void)handleSingleTap:(UITapGestureRecognizer*)gesturenizer
{
    [[UIApplication sharedApplication] resignFirstResponder];
}

- (IBAction)networkStatusChoice:(id)sender
{
    NSRange range = NSMakeRange(1, 3);
    
    [self.tableView beginUpdates];
    
    if (((UISwitch*)sender).on)
    {
        _sectionNumbers = 5;
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

- (IBAction)setupGetIPStyle:(id)sender
{
    BOOL isOn = ((UISwitch*)sender).on;
    if (isOn)
    {
        _IPAddressText.placeholder = nil;
        _gatewayText.placeholder = nil;
        _maskText.placeholder = nil;
    }
    else
    {
        _IPAddressText.placeholder = NSLocalizedString(@"mcs_input_ip", nil);
        _gatewayText.placeholder = NSLocalizedString(@"mcs_input_gateway", nil);
        _maskText.placeholder = NSLocalizedString(@"mcs_input_network_mask", nil);
    }
    
    _IPAddressText.enabled = !isOn;
    _gatewayText.enabled = !isOn;
    _maskText.enabled = !isOn;

}

- (IBAction)setupGetDNSStyle:(id)sender
{
    BOOL isOn = ((UISwitch*)sender).on;
    if (isOn)
    {
        _firstDNSText.placeholder = nil;
        _standbyDNSText.placeholder = nil;
    }
    else
    {
        _firstDNSText.placeholder = NSLocalizedString(@"mcs_input_dns", nil);
        _standbyDNSText.placeholder = NSLocalizedString(@"mcs_input_alternate_dns", nil);
    }
    
    _firstDNSText.enabled = !isOn;
    _standbyDNSText.enabled = !isOn;

}

-(BOOL)checkIPFormat:(NSArray *)ipArray
{
    for (NSString *str in ipArray) {
        NSArray *strArr = [str componentsSeparatedByString:@"."];
        if (strArr.count == 4) {
            for (NSString *ipStr in strArr) {
                NSString *regex = @"^[0-9]{1,3}$";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",regex];
                if (![predicate evaluateWithObject:ipStr]) {
                    return NO;
                }
                NSInteger ipNum = [ipStr integerValue];
                NSLog(@"%ld",ipNum);
                if (ipNum > 255 || ipNum < 0) {
                    return NO;
                }
            }
        }else{
            return NO;
        }
    }
    return YES;
}

- (IBAction)apply:(id)sender
{
    if (!_autoIPSwitch.on) {
        NSArray *ipArr = @[_IPAddressText.text,_gatewayText.text,_maskText.text];
        if (![self checkIPFormat:ipArr]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_ip_format_incorrect", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            }
            else{
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_ip_format_incorrect", nil)]];
            }
            return ;
        }
    }
    if (!_autoDNSSwitch.on) {
        NSArray *dnsArr = @[_firstDNSText.text,_standbyDNSText.text];
        if (![self checkIPFormat:dnsArr]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_ip_format_incorrect", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            }
            else{
                [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_ip_format_incorrect", nil)]];
            }
            return ;
        }
    }
    
    net_obj *net_o      = [[net_obj alloc] init];
    net_o.enable        = _enableSwitch.on;
    net_o.token         = @"eth0";
    
    net_info_obj *info  = [[net_info_obj alloc] init];
    info.mode           = @"ether";
    net_o.info          = info;
    
    BOOL autoIP         = _autoIPSwitch.on;
    
    ip_obj *ip_o        = [[ip_obj alloc] init];
    ip_o.enable         = YES;
    ip_o.dhcp           = autoIP;
    ip_o.ip             = autoIP ? nil : _IPAddressText.text;
    ip_o.gateway        = autoIP ? nil : _gatewayText.text;
    ip_o.mask           = autoIP ? nil : _maskText.text;
    net_o.ip            = ip_o;
    
    BOOL autoDNS        = _autoDNSSwitch.on;
    
    dns_obj *dns_o      = [[dns_obj alloc] init];
    dns_o.enable        = YES;
    dns_o.dhcp          = autoDNS;
    dns_o.dns           = autoDNS ? nil : _firstDNSText.text;
    dns_o.secondary_dns = autoDNS ? nil : _standbyDNSText.text;
    
    mcall_ctx_net_set *ctx = [[mcall_ctx_net_set alloc] init];
    ctx.sn = _deviceID;
    ctx.dns = dns_o;
    ctx.networks = @[net_o];
    ctx.on_event = @selector(net_set_done:);
    ctx.target = self;
    
    [_agent net_set:ctx];
    [self loading:YES];

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
            row = _enableSwitch.on?2:1;
            break;
        case 2:
            row = 4;
            break;
        case 3:
            row = 3;
            break;
        case 4:
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
    
    NSLog(@"%ld------%ld", indexPath.section, (long)indexPath.row);
    
    if (_sectionNumbers == 2 && indexPath.section == 1)
    {
        NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 3];
        cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
    }
    else
    {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Test
- (void)updateDetailVCFrame
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        return;
    }
    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if ([dev.wifi_status isEqualToString:@"none"]) {
        return;
    }
    
    MNDetailViewController *VC = (MNDetailViewController *)self.rootNavigationController.viewControllers.firstObject;
    
    if (VC.view.frame.origin.y != 64.0) {
        ((MNDeviceNetworkSetViewController*)VC.childViewControllers.lastObject).toTopLayoutConstraint.constant = 64;
    }
}
@end
