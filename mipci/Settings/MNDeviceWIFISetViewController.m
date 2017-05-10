//
//  MNDeviceWIFISetViewController.m
//  mining_client
//
//  Created by mining on 14-9-12.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDeviceWIFISetViewController.h"
#import "UITableViewController+loading.h"
#import "MNDeviceWIFIListViewController.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MNProgressHUD.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"
#import "MNDetailViewController.h"
#import "MNDeviceNetworkSetViewController.h"

@interface MNDeviceWIFISetViewController ()

@property (assign, nonatomic) BOOL isViewAppearing;
@property (strong, nonatomic) NSMutableArray *relatedArray;
@property (strong, nonatomic) NSTimer *wifiStateShowTimer;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (strong, nonatomic) MNToastView *connectToastView;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNDeviceWIFISetViewController

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
        self.title = NSLocalizedString(@"mcs_wifi", nil);
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

-(MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_progressHUD];
        _progressHUD.color = [UIColor colorWithWhite:0.5f alpha:0.8f];
        _progressHUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        _progressHUD.labelText = NSLocalizedString(@"mcs_connecting", nil);
        _progressHUD.labelColor = [UIColor grayColor];
        if (self.app.is_vimtag) {
            _progressHUD.activityIndicatorColor = [UIColor colorWithRed:0 green:168.0/255 blue:185.0/255 alpha:1.0f];
        }
        else {
            _progressHUD.activityIndicatorColor = [UIColor grayColor];
        }
        
    }
    
    return  _progressHUD;
}
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_wifi", nil);
    [self.navigationItem.backBarButtonItem setTitle:NSLocalizedString(@"mcs_wifi", nil)];
    [_commitButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];

    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_commitButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_commitButton setBackgroundColor:app.button_color];

    _enableStatusTiteLabel.text = NSLocalizedString(@"mcs_enabled", nil);
    _MACAddressTiteLabel.text = NSLocalizedString(@"mcs_mac_address", nil);
    _linkStatusTiteLabel.text = NSLocalizedString(@"mcs_network_status", nil);
    
    [_WIFIStyleSegment setTitle:NSLocalizedString(@"mcs_client", nil) forSegmentAtIndex:0];
    [_WIFIStyleSegment setTitle:NSLocalizedString(@"mcs_ap", nil) forSegmentAtIndex:1];
    
    _networkListTiteLabel.text = NSLocalizedString(@"mcs_wifi_list", nil);
    _passwordTiteLabel.text = NSLocalizedString(@"mcs_password", nil);
    _WIFIlinkStatusTiteLabel.text = NSLocalizedString(@"mcs_network_status", nil);
    
    _autoIPTiteLabel.text = NSLocalizedString(@"mcs_dhcp_ip", nil);
    _IPAddressTiteLabel.text = NSLocalizedString(@"mcs_ip_address", nil);
    _gatewayTiteLabel.text = NSLocalizedString(@"mcs_gateway", nil);
    _maskTiteLabel.text = NSLocalizedString(@"mcs_network_mask", nil);
    
    _autoDNSTiteLabel.text  = NSLocalizedString(@"mcs_dhcp_dns", nil);
    _firstDNSTiteLabel.text = NSLocalizedString(@"mcs_dns_prim" , nil);
    _standbyDNSTiteLabel.text = NSLocalizedString(@"mcs_secondary_dns", nil);

    //NSLocalizedString(@"mcs_dhcp_server", nil);
    _beginIPTiteLabel.text = NSLocalizedString(@"mcs_start_address", nil);
    _endIPTiteLabel.text = NSLocalizedString(@"mcs_end_address", nil);
    _hotpotGatewayTiteLabel.text = NSLocalizedString(@"mcs_gateway", nil);
    
    //NSLocalizedString(@"mcs_enter_wifi", nil);
    
    _passwordTextField.placeholder = NSLocalizedString(@"mcs_please_input_password", nil);
    _WIFINameText.placeholder = NSLocalizedString(@"mcs_not_select", nil);

    _beginIPTextField.placeholder = NSLocalizedString(@"mcs_enter_starting_address", nil);
    _endIPTextField.placeholder = NSLocalizedString(@"mcs_enter_address", nil);
    _hotpotGatewayTextField.placeholder = NSLocalizedString(@"mcs_input_gateway" , nil);
    
    _enableStatusSwitch.onTintColor = self.configuration.switchTintColor;
    _autoIPSwitch.onTintColor = self.configuration.switchTintColor;
    _autoDNSSwitch.onTintColor = self.configuration.switchTintColor;
    _WIFIStyleSegment.tintColor = self.configuration.switchTintColor;
}

#pragma mark - View lifecycle
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
    _isViewAppearing = YES;
    _faultLabel.hidden = YES;
    
    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if ([dev.wifi_status isEqualToString:@"none"]) {
        _relatedArray = [NSMutableArray arrayWithArray:@[@[[NSNull null]]]];
        _enableStatusSwitch.hidden = YES;
        _enableStatusTiteLabel.text = NSLocalizedString(@"mcs_status", nil);
        _faultLabel.text = NSLocalizedString(@"mcs_fault", nil);
        _faultLabel.hidden = NO;
    } else {
        //preudo-data
        _relatedArray = [NSMutableArray arrayWithArray:@[@[[NSNull null]],
                                                         @[[NSNull null], [NSNull null]],
                                                         @[[NSNull null]],
                                                         @[[NSNull null], [NSNull null], [NSNull null]],
                                                         @[[NSNull null], [NSNull null], [NSNull null], [NSNull null]],
                                                         @[[NSNull null], [NSNull null], [NSNull null]],
                                                         @[[NSNull null]]]];

        
        mcall_ctx_net_get *ctx =[[mcall_ctx_net_get alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(net_get_done:);
        
        [_agent net_get:ctx];
        [self loading:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated
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
    if (_wifiStateShowTimer != nil) {
        [_wifiStateShowTimer invalidate];
        _wifiStateShowTimer = nil;
    }
    _isViewAppearing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                [self updateDetailVCFrame];
            } else {
                [self.view.superview addSubview:[MNToastView failToast:nil]];
            }
        }
        return;
    }
    
    net_obj *netObj = ret.networks[1];
    
    _enableStatusSwitch.on = netObj.enable;
    [_enableStatusSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    
    _MACAddressLabel.text = netObj.info.mac;
    _linkStatusLabel.text = netObj.info.status;
    
    
    if ([netObj.info.mode isEqualToString:@"wificlient"]) {
        [_WIFIStyleSegment setSelectedSegmentIndex:0];
    }
    else
    {
        [_WIFIStyleSegment setSelectedSegmentIndex:1];
    }
    
    //set the wifi style
    [_WIFIStyleSegment sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (!netObj.use_wifi_ssid) {
//        _WIFINameLabel.text = NSLocalizedString(@"mcs_not_select", nil);
        _WIFINameText.text = nil;
    } else {
//         _WIFINameLabel.text = netObj.use_wifi_ssid;
        _WIFINameText.text = netObj.use_wifi_ssid;
    }
   
    _passwordTextField.text = netObj.use_wifi_passwd;
    
    wifi_obj *wifiObj;
    NSString *wifiStatus = netObj.use_wifi_status;
    NSString *wifiSsid = netObj.use_wifi_ssid;
    NSMutableArray *wifiList = netObj.wifi_list;
    
   
    if ([wifiStatus isEqualToString:@"ok"])
    {
        _WIFIlinkStatusLabel.text = NSLocalizedString(@"mcs_connnected", nil);
        for (NSInteger i = 0 ; i < wifiList.count; i++) {
            wifiObj = [wifiList objectAtIndex:i];
            if([wifiObj.ssid isEqualToString:wifiSsid])
            {
               _WIFIlinkStatusLabel.text =  [NSString stringWithFormat:@"%d%%", wifiObj.quality];
                break;
            }
        }
        
    }
    else if([wifiStatus isEqualToString:@"info.connecting"])
    {
        _WIFIlinkStatusLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"mcs_connecting", nil)];
    }
    else
    {
        _WIFIlinkStatusLabel.text = NSLocalizedString(@"mcs_not_connected", nil);
    }
    
    _autoIPSwitch.on = netObj.ip.dhcp;
    _IPAddressTextField.text = netObj.ip.ip;
    _gatewayTextField.text = netObj.ip.gateway;
    _maskTextField.text = netObj.ip.mask;
    
    _autoDNSSwitch.on = ret.dns.dhcp;
    _firstDNSTextField.text = ret.dns.dns;
    _standbyDNSTextField.text = ret.dns.secondary_dns;

    _beginIPTextField.text          = netObj.dhcp_srv.start_ip;
    _endIPTextField.text            = netObj.dhcp_srv.end_ip;
    _hotpotGatewayTextField.text   = netObj.dhcp_srv.gateway;
    
}

#pragma mark - wifiState_net_get_done
- (void)wifiState_net_get_done:(mcall_ret_net_get *)ret
{
    [self loading:NO];
    if (!_isViewAppearing)
    {
        return;
    }
    
//    if(nil != ret.result || nil == ret.networks)
//    {
//        [self.view.superview addSubview:[MNToastView failToast:nil]];
//        return;
//    }
//    
    net_obj *netObj = ret.networks[1];

    wifi_obj *wifiObj;
    NSString *wifiStatus = netObj.use_wifi_status;
    NSString *wifiSsid = netObj.use_wifi_ssid;
    NSMutableArray *wifiList = netObj.wifi_list;
    
    
    if ([wifiStatus isEqualToString:@"ok"])
    {
        _WIFIlinkStatusLabel.text = NSLocalizedString(@"mcs_connnected", nil);
        for (NSInteger i = 0 ; i < wifiList.count; i++) {
            wifiObj = [wifiList objectAtIndex:i];
            if([wifiObj.ssid isEqualToString:wifiSsid])
            {
                _WIFIlinkStatusLabel.text =  [NSString stringWithFormat:@"%d%%", wifiObj.quality];
                break;
            }
        }
        if (_wifiStateShowTimer != nil) {
            [_wifiStateShowTimer invalidate];
            _wifiStateShowTimer = nil;
        }
        [_connectToastView removeFromSuperview];
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_connection_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
            [self updateDetailVCFrame];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_connection_successfully", nil)]];
        }
        
    }
    else if(_wifiStateShowTimer)
    {
        _WIFIlinkStatusLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"mcs_connecting", nil)];
        [self performSelector:@selector(wifiStateShow) withObject:nil afterDelay:5.0];
    }
    
//    else
//    {
//        _WIFIlinkStatusLabel.text = NSLocalizedString(@"mcs_not_connected", nil);
//    }
    
}
#pragma mark - net_set_done
- (void)net_set_done:(mcall_ret_net_set *)ret
{
    [self loading:NO];
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil == ret.result)
    {
        if (!_enableStatusSwitch.on || _WIFIStyleSegment.selectedSegmentIndex == 1) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
                [self updateDetailVCFrame];
            } else {
                [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
            }
        } else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_wifi_is_connection", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
                [self updateDetailVCFrame];
            } else {
                _connectToastView = [MNToastView connectToast:NSLocalizedString(@"mcs_wifi_is_connection", nil)];
            }
            [self.view.superview addSubview:_connectToastView];
            _WIFIlinkStatusLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"mcs_connecting", nil)];
            _wifiStateShowTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timeOut) userInfo:nil repeats:YES];
            [self  performSelector:@selector(wifiStateShow) withObject:nil afterDelay:3.0];
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

#pragma mark - Action

- (void)handleSingleTap:(UITapGestureRecognizer*)gesturenizer
{
    [[UIApplication sharedApplication] resignFirstResponder];
}

- (IBAction)selectWIFI:(id)sender
{
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
// 
//    } else {
        [self performSegueWithIdentifier:@"MNDeviceWIFIListViewController" sender:nil];
//    }
}


- (IBAction)networkStatusChoice:(id)sender
{
    [self.tableView beginUpdates];
    
    if (((UISwitch*)sender).on)
    {
        if (self.tableView.numberOfSections == 2) {
            NSArray *datas = nil;
            if (0 == _WIFIStyleSegment.selectedSegmentIndex)
            {
                datas = @[@[[NSNull null], [NSNull null]],
                          @[[NSNull null]],
                          @[[NSNull null], [NSNull null], [NSNull null]],
                          @[[NSNull null], [NSNull null], [NSNull null], [NSNull null]],
                          @[[NSNull null], [NSNull null], [NSNull null]]];
            }
            else
            {
                datas = @[@[[NSNull null], [NSNull null]],
                          @[[NSNull null]],
                          @[[NSNull null], [NSNull null], [NSNull null]],];
            }
            
            NSRange range = NSMakeRange(1, datas.count);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray insertObjects:datas atIndexes:indexSet];
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];

        }
    }
    else
    {
        NSRange range = NSMakeRange(1, _relatedArray.count - 2);
        [_relatedArray removeObjectsInRange:range];
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

- (IBAction)WIFIStyleChoice:(id)sender
{
    [self.tableView beginUpdates];
    
    if (((UISegmentedControl*)sender).selectedSegmentIndex == 0)
    {
        if (self.tableView.numberOfSections == 5) {
            [_relatedArray removeObjectAtIndex:3];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
            
            NSArray *datas = @[@[[NSNull null], [NSNull null], [NSNull null]],
                               @[[NSNull null], [NSNull null], [NSNull null], [NSNull null]],
                               @[[NSNull null], [NSNull null], [NSNull null]]];
            NSRange range = NSMakeRange(3, 3);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray insertObjects:datas atIndexes:indexSet];
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else
    {
        if (self.tableView.numberOfSections == 7) {
            NSRange range = NSMakeRange(3, 3);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            
            [_relatedArray removeObjectsAtIndexes:indexSet];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            
            NSArray *datas = @[[NSNull null], [NSNull null], [NSNull null]];
            [_relatedArray insertObject:datas atIndex:3];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
        }
    }

    [self.tableView endUpdates];
}

- (IBAction)setupGetIPStyle:(id)sender
{
    BOOL isOn = ((UISwitch*)sender).on;
    
    if (isOn) {
        _IPAddressTextField.placeholder = nil;
        _gatewayTextField.placeholder = nil;
        _maskTextField.placeholder = nil;
    }
    else
    {
        _IPAddressTextField.placeholder = NSLocalizedString(@"mcs_input_ip", nil);
        _gatewayTextField.placeholder = NSLocalizedString(@"mcs_input_gateway", nil);
        _maskTextField.placeholder = NSLocalizedString(@"mcs_input_network_mask", nil);
    }
    
    _IPAddressTextField.enabled = !isOn;
    _gatewayTextField.enabled = !isOn;
    _maskTextField.enabled = !isOn;
    
}

- (IBAction)setupGetDNSStyle:(id)sender
{
    BOOL isOn = ((UISwitch*)sender).on;
    
    if (isOn) {
        _firstDNSTextField.placeholder = nil;
        _standbyDNSTextField.placeholder = nil;
    }
    else
    {
        _firstDNSTextField.placeholder = NSLocalizedString(@"mcs_input_dns", nil);
        _standbyDNSTextField.placeholder = NSLocalizedString(@"mcs_input_alternate_dns", nil);
    }
    
    _firstDNSTextField.enabled = !isOn;
    _standbyDNSTextField.enabled = !isOn;
}

- (IBAction)apply:(id)sender
{
    if (!_enableStatusSwitch.on) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_wifi_disable_prompt", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
        [alertView show];
        return;
    }
    net_obj *net_o          = [[net_obj alloc] init];
    net_o.enable            = _enableStatusSwitch.on;
    net_o.token             = @"ra0";
    
    dns_obj *dns_o          = [[dns_obj alloc] init];
    
    if (_WIFIStyleSegment.selectedSegmentIndex == 0)
    {
        net_info_obj *info      = [[net_info_obj alloc] init];
        info.mode = @"wificlient";
        
        net_o.info              = info;
//        if (_WIFINameLabel.text == NSLocalizedString(@"mcs_not_select", nil)) {
        if (_WIFINameText.text == nil) {
            net_o.use_wifi_ssid = @"";
        } else {
//               net_o.use_wifi_ssid     = _WIFINameLabel.text;
            net_o.use_wifi_ssid     = _WIFINameText.text;
        }
        net_o.use_wifi_passwd   = _passwordTextField.text;
        
        ip_obj *ip_o = [[ip_obj alloc] init] ;
        ip_o.dhcp = _autoIPSwitch.on;
        ip_o.ip = _IPAddressTextField.text;
        ip_o.gateway = _gatewayTextField.text;
        ip_o.mask = _maskTextField.text;
        net_o.ip = ip_o;
        
//        dns_o.enable = _autoDNSSwitch.on;
//        dns_o.enable = NO;
        dns_o.dhcp = _autoDNSSwitch.on;
        dns_o.dns = _firstDNSTextField.text;
        dns_o.secondary_dns = _standbyDNSTextField.text;
        
        
    }
    else if (_WIFIStyleSegment.selectedSegmentIndex == 1)
    {
        net_info_obj *info      = [[net_info_obj alloc] init];
        info.mode               = @"adhoc";
        net_o.info              = info;
        
        dhcp_srv_obj *dhcp_srv_o=[[dhcp_srv_obj alloc]init];
        dhcp_srv_o.start_ip     =_beginIPTextField.text;
        dhcp_srv_o.end_ip       =_endIPTextField.text;
        dhcp_srv_o.gateway      =_hotpotGatewayTextField.text;
        net_o.dhcp_srv          =dhcp_srv_o;
        
        ip_obj *ip_o            =[[ip_obj alloc]init];
        ip_o.dhcp               =YES;
        net_o.ip                =ip_o;
        
        dns_o.dhcp              = YES;
    }
    
    
    mcall_ctx_net_set *ctx = [[mcall_ctx_net_set alloc] init];
    ctx.sn = _deviceID;
    ctx.dns = dns_o;
    ctx.networks = @[net_o];
    ctx.on_event = @selector(net_set_done:);
    ctx.target = self;
    
    [self loading:YES];
    [_agent net_set:ctx];
    
}

- (void)wifiStateShow
{
    mcall_ctx_net_get *ctx =[[mcall_ctx_net_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(wifiState_net_get_done:);
    
    [_agent net_get:ctx];
}

- (void)timeOut
{
    if (_wifiStateShowTimer != nil) {
        [_wifiStateShowTimer invalidate];
        _wifiStateShowTimer = nil;
    }
    [_connectToastView removeFromSuperview];
    if (self.app.is_InfoPrompt) {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_state_config_wifi_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        [self updateDetailVCFrame];
    } else {
        [self.view.superview addSubview:[MNToastView failToast: NSLocalizedString(@"mcs_state_config_wifi_fail",nil)]];
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNDeviceWIFIListViewController"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        MNDeviceWIFIListViewController *deviceWIFIListViewController = [navigationController.viewControllers firstObject];
        deviceWIFIListViewController.deviceID = _deviceID;
        deviceWIFIListViewController.deviceWIFISetViewController = self;
    }
}


#pragma mark - Table view delegate
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2)
    {
        return NSLocalizedString(@"mcs_wifi_mode", nil);
    }
    else if (self.tableView.numberOfSections == 5 && section == 3)
    {
        return NSLocalizedString(@"mcs_dhcp_server", nil);
    }
    else
    {
        return nil;
    }
}

#pragma mark - Table view date source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _relatedArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataArray = [_relatedArray objectAtIndex:section];
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (self.tableView.numberOfSections == 2 && indexPath.section == 1)
    {
        NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 6];
        cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
    }
    else if (self.tableView.numberOfSections == 7 && indexPath.section == 6)
    {
        NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
        cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
    }
    else if (self.tableView.numberOfSections == 5 && (indexPath.section == 3 || indexPath.section == 4))
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

#pragma mark - AlertView delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        net_obj *net_o          = [[net_obj alloc] init];
        net_o.enable            = _enableStatusSwitch.on;
        net_o.token             = @"ra0";
        
        dns_obj *dns_o          = [[dns_obj alloc] init];
        
        if (_WIFIStyleSegment.selectedSegmentIndex == 0)
        {
            net_info_obj *info      = [[net_info_obj alloc] init];
            info.mode = @"wificlient";
            
            net_o.info              = info;
//            if (_WIFINameLabel.text == NSLocalizedString(@"mcs_not_select", nil)) {
            if (_WIFINameText.text == nil) {
                net_o.use_wifi_ssid = @"";
            } else {
//                net_o.use_wifi_ssid     = _WIFINameLabel.text;
                net_o.use_wifi_ssid     = _WIFINameText.text;
            }
            net_o.use_wifi_passwd   = _passwordTextField.text;
            
            ip_obj *ip_o = [[ip_obj alloc] init] ;
            ip_o.dhcp = _autoIPSwitch.on;
            ip_o.ip = _IPAddressTextField.text;
            ip_o.gateway = _gatewayTextField.text;
            ip_o.mask = _maskTextField.text;
            net_o.ip = ip_o;
            
            //        dns_o.enable = _autoDNSSwitch.on;
            //        dns_o.enable = NO;
            dns_o.dhcp = _autoDNSSwitch.on;
            dns_o.dns = _firstDNSTextField.text;
            dns_o.secondary_dns = _standbyDNSTextField.text;
            
            
        }
        else if (_WIFIStyleSegment.selectedSegmentIndex == 1)
        {
            net_info_obj *info      = [[net_info_obj alloc] init];
            info.mode               = @"adhoc";
            net_o.info              = info;
            
            dhcp_srv_obj *dhcp_srv_o=[[dhcp_srv_obj alloc]init];
            dhcp_srv_o.start_ip     =_beginIPTextField.text;
            dhcp_srv_o.end_ip       =_endIPTextField.text;
            dhcp_srv_o.gateway      =_hotpotGatewayTextField.text;
            net_o.dhcp_srv          =dhcp_srv_o;
            
            ip_obj *ip_o            =[[ip_obj alloc]init];
            ip_o.dhcp               =YES;
            net_o.ip                =ip_o;
            
            dns_o.dhcp              = YES;
        }
        
        
        mcall_ctx_net_set *ctx = [[mcall_ctx_net_set alloc] init];
        ctx.sn = _deviceID;
        ctx.dns = dns_o;
        ctx.networks = @[net_o];
        ctx.on_event = @selector(net_set_done:);
        ctx.target = self;
        
        [self loading:YES];
        [_agent net_set:ctx];
    }
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
