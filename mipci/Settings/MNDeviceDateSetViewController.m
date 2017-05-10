//
//  UIdevicedateTableViewController.m
//  mining_client
//
//  Created by mining on 14-9-11.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDeviceDateSetViewController.h"
#import "UITableViewController+loading.h"
#import "MNTimezoneListViewController.h"
#import "MNToastView.h"
#import "MNCustomDatePicker.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "mipc_timezone_manager.h"
#import "MNInfoPromptView.h"

@interface MNDeviceDateSetViewController ()

@property (assign, nonatomic) BOOL isViewAppearing;
@property (strong, nonatomic) NSString *timezone;
@property (strong, nonatomic) MNCustomDatePicker *datePicker;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNDeviceDateSetViewController

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
        self.title = NSLocalizedString(@"mcs_date_time", nil);
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
    self.navigationItem.title = NSLocalizedString(@"mcs_date_time", nil);
    self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"mcs_back", nil);
    [self.commitButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_commitButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_commitButton setBackgroundColor:app.button_color];
    
    self.dateTiteLable.text = NSLocalizedString(@"mcs_date", nil);
    self.timeTiteLable.text = NSLocalizedString(@"mcs_time", nil);
    self.synchronizationTiteLabel.text = NSLocalizedString(@"mcs_auto_sync_date_time", nil);
    self.serverIPTiteLable.text = NSLocalizedString(@"mcs_ntp", nil);
    self.timezoneTiteLable.text = NSLocalizedString(@"mcs_time_zone", nil);
    
    self.synchronizationSwitch.onTintColor = self.configuration.switchTintColor;

//    _datePicker = [UIDatePicker ]

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
    mcall_ctx_time_get *ctx = [[mcall_ctx_time_get alloc] init];
    ctx.sn = _deviceID;
    ctx.on_event = @selector(time_get_done:);
    ctx.target = self;
    
    [_agent time_get:ctx];
    [self loading:YES];
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

#pragma mark - Utils
- (void)createDatePickerWithMode:(UIDatePickerMode)datePickerMode
{
    if (_datePicker) {
        [_datePicker removeFromSuperview];
    }
    
    _datePicker = [[MNCustomDatePicker alloc] initWithFrame:CGRectNull];
    _datePicker.delegate = self;
    _datePicker.datePickerMode = datePickerMode;
    _datePicker.center = self.view.center;
    [self.view addSubview:_datePicker];
     _datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}


#pragma mark - time_get_done
//设置操作
- (void)time_get_done:(mcall_ret_time_get *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing) {
        return;
    }
    
    if(ret.result != nil)
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
        return;
    }
    
    long year = ret.year ? ret.year : 1900;
    long month = ret.mon;
    long day = ret.day;
    
    long hour = ret.hour;
    long minute = ret.min;
    long second = ret.sec;
    
    NSString *date = [NSString stringWithFormat:@"%ld-%.2ld-%.2ld", year, month, day];
    NSString *time = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", hour, minute, second];
    
    self.dateLable.text = date;
    self.timeLable.text = time;
    self.serverIPTextField.text = ret.ntp_addr;
    
    self.synchronizationSwitch.on = ret.auto_sync;
    [_synchronizationSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    
//    NSArray *retTimeArray = [ret.time_zone componentsSeparatedByString:@","];
//    if (retTimeArray.count>1) {
        NSString *city = NSLocalizedString(TIMEZONE_CITY[ret.time_zone], nil);
        self.timezoneLabel.text = city.length ? [NSString stringWithFormat:@"%@",city] : ret.time_zone;
//    }else{
//        self.timezoneLabel.text = ret.time_zone;
//    }
}

#pragma mark - time_set_done
- (void)time_set_done:(mcall_ret_time_set *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil == ret.result)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        }
        
        mcall_ctx_time_get *ctx = [[mcall_ctx_time_get alloc] init];
        ctx.sn = _deviceID;
        ctx.on_event = @selector(time_get_done:);
        ctx.target = self;
        
        [_agent time_get:ctx];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNTimezoneListViewController"]) {
        MNTimezoneListViewController *timezoneListViewController = segue.destinationViewController;
        timezoneListViewController.deviceID = _deviceID;
        timezoneListViewController.deviceDateSetViewController = self;
        timezoneListViewController.selectedTimetone = _timezoneLabel.text;
        timezoneListViewController.rootNavigationController = _rootNavigationController;
    }
}


#pragma mark - resignFirstResponder
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Action
- (IBAction)apply:(id)sender
{
    mcall_ctx_time_set *ctx = [[mcall_ctx_time_set alloc] init];
    ctx.target = self;
    ctx.on_event = @selector(time_set_done:);
    ctx.sn      = _deviceID;
    
    NSArray *date = [_dateLable.text componentsSeparatedByString:@"-"];
    int year = [[date objectAtIndex:0] intValue];
    int month = [[date objectAtIndex:1] intValue];
    int day = [[date objectAtIndex:2] intValue];
    
    NSArray *time = [_timeLable.text componentsSeparatedByString:@":"];
    int hour = [[time objectAtIndex:0] intValue];
    int minute = [[time objectAtIndex:1] intValue];
    int second = [[time objectAtIndex:2] intValue];
    
    ctx.year    = year;
    ctx.mon     = month;
    ctx.day     = day;
    ctx.hour    = hour;
    ctx.min     = minute;
    ctx.sec     = second;
    ctx.auto_sync = _synchronizationSwitch.on;
    ctx.time_zone = _timezone_obj ? (_timezone_obj.city?[NSString stringWithFormat:@"%@",_timezone_obj.city]:_timezone_obj.utc) : _timezoneLabel.text;
    ctx.ntp_addr = _serverIPTextField.text;
    
    [_agent time_set:ctx];
    [self loading:YES];
}

- (IBAction)setupGetTimeStyle:(id)sender
{
//    if (((UISwitch*)sender).on) {
//        [self.tableView setAllowsSelection:NO];
//    }
//    else
//    {
//        [self.tableView setAllowsSelection:YES];
//    }
}

- (void)handleSingleTap:(UITapGestureRecognizer*)gesturenizer
{
    [[UIApplication sharedApplication] resignFirstResponder];
}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row && !_synchronizationSwitch.on)
        {
            [self createDatePickerWithMode:UIDatePickerModeDate];
        }
        else if (1 == indexPath.row && !_synchronizationSwitch.on)
        {
            [self createDatePickerWithMode:UIDatePickerModeTime];
        }
        else if (4 == indexPath.row)
        {
            [self performSegueWithIdentifier:@"MNTimezoneListViewController" sender:nil];
        }
    }
}

#pragma mark - MNCustomDatePickerDelegate
- (void)datePicker:(MNCustomDatePicker*)datePicker value:(NSDate *)date
{
    NSString *contentStr = [self stringFromDate:date];
    
    NSArray *dates = [contentStr componentsSeparatedByString:@" "];
    NSString *dateStr = dates[0];
    NSString *timeStr = dates[1];
    
    if (datePicker.datePickerMode == UIDatePickerModeTime) {
        _timeLable.text = timeStr;
    }
    else if (datePicker.datePickerMode == UIDatePickerModeDate)
    {
        _dateLable.text = dateStr;
    }
}

@end
