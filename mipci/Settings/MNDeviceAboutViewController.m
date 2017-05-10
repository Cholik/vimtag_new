//
//  MNDeviceAboutViewController.m
//  mining_client
//
//  Created by mining on 14-9-9.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#define DEFAULT_CELL_COUNT      4
#define UPDATE_CELL_COUNT       5

#import "MNDeviceAboutViewController.h"
#import "UITableViewController+loading.h"
#import "AppDelegate.h"
#import "MNToastView.h"
#import "MNInfoPromptView.h"

@interface MNDeviceAboutViewController ()

@property (assign, nonatomic) BOOL isViewAppearing;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) UIView *customHeaderView;
@property (assign, nonatomic) BOOL isUpdateCell;

@end

@implementation MNDeviceAboutViewController

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

#pragma mark - initialization
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
        self.title = NSLocalizedString(@"mcs_about", nil);
    }
    
    return self;
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_about", nil);
        
    _deviceModelHintLabel.text = NSLocalizedString(@"mcs_model", nil);
    _softwareVersionHintLabel.text = NSLocalizedString(@"mcs_firmware_version", nil);
    _deviceIDHintLabel.text = NSLocalizedString(@"mcs_device_id", nil);
    _breakDownLabel.text = NSLocalizedString(@"mcs_fault", nil);
    _sensorStatuLabel.text = NSLocalizedString(@"mcs_sensor_status", nil);
    _firmHintLabel.text = NSLocalizedString(@"mcs_manufacturer", nil);

    _deviceIDTextView.text = _deviceID;
    _deviceIDTextView.editable = NO;
    _versionTextView.editable = NO;
    _deviceModelTextView.editable = NO;
    _firmTextView.editable = NO;

    self.sensorStatuCell.hidden = YES;
}

#pragma mark - viewLifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    _isViewAppearing = YES;
    _isUpdateCell = NO;

    m_dev *device = [_agent.devs get_dev_by_sn:_deviceID];
    
    if (device && [device.status isEqualToString:@"Online"])
    {
        mcall_ctx_dev_info_get *ctx = [[mcall_ctx_dev_info_get alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(dev_info_get_done:);
        
        [self loading:YES];
        [_agent dev_info_get:ctx];
    }
    else
    {
        _deviceModelTextView.text = device.model;
        _versionTextView.text = device.img_ver;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"mcs_device_offline", nil)
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil)
                                                 otherButtonTitles:nil , nil];
        [alertView show];
    }
    
    _customHeaderView = self.tableView.tableHeaderView;
    self.tableView.tableHeaderView = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _isViewAppearing = NO;
    [MNInfoPromptView hideAll:_rootNavigationController];
}

#pragma mark - 
- (void)dev_info_get_done:(mcall_ret_dev_info_get *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing)
    {
        return;
    }
    
    if (nil == ret.result)
    {
        _deviceModelTextView.text = ret.s_model.length ? ret.s_model : ret.model;
        _versionTextView.text = ret.img_ver;
        _deviceIDTextView.text = _deviceID;

        if (!self.app.is_vimtag && ret.s_mfc.length) {
            _firmTextView.text = ret.s_mfc;
            _isUpdateCell = YES;
        }
        
        if (!self.app.is_vimtag && ret.s_logo.length) {
            //            self.tableView.tableHeaderView = _customHeaderView;
            mcall_ctx_snapshot *ctx = [[mcall_ctx_snapshot alloc] init];
            ctx.token = ret.s_logo;
            ctx.on_event = @selector(logo_get_done:);
            ctx.target = self;
            [self.agent logo_get:ctx];
        }
        
        if ([ret.type isEqualToString:@"IPC"] && [ret.sensor_status isEqualToString:@"fail"])
        {
            self.sensorStatuCell.hidden = NO;
        }

        [self.tableView reloadData];
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
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                
            } else {
                [self.view.superview addSubview:[MNToastView failToast:nil]];
            }
        }
    }
}

- (void)logo_get_done:(mcall_ret_snapshot *)ret
{
    if (ret.img) {
        _logoImage.image = ret.img;
        self.tableView.tableHeaderView = _customHeaderView;
        [self.tableView reloadData];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _isUpdateCell ? UPDATE_CELL_COUNT : DEFAULT_CELL_COUNT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (_isUpdateCell) {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        if (indexPath.row > 0) {
            NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
        } else {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
    }
    
    
    return cell;
}

@end
