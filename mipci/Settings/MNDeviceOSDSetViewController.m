//
//  UIdeviceOSDTableViewController.m
//  mining_client
//
//  Created by mining on 14-9-10.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDeviceOSDSetViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"

@interface MNDeviceOSDSetViewController ()

@property (assign, nonatomic) BOOL isViewAppearing;
@property (strong, nonatomic) NSMutableArray *relatedArray;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNDeviceOSDSetViewController

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
        self.title = NSLocalizedString(@"mcs_osd", nil);
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
    self.navigationItem.title = NSLocalizedString(@"mcs_osd", nil);
    [self.commitButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_commitButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_commitButton setBackgroundColor:app.button_color];

    self.nameShowTiteLabel.text = NSLocalizedString(@"mcs_display_text", nil);
    self.nameTiteLabel.text = NSLocalizedString(@"mcs_old_nick", nil);
    self.dateShowTiteLabel.text = NSLocalizedString(@"mcs_display_date", nil);
    self.timeShowTiteLabel.text = NSLocalizedString(@"mcs_display_time", nil);
    self.weekShowTiteLabel.text = NSLocalizedString(@"mcs_display_weeks", nil);
    
    self.nameTextField.placeholder = NSLocalizedString(@"mcs_input_nick", nil);

    self.nameSwitch.onTintColor = self.configuration.switchTintColor;
    self.dateSwitch.onTintColor = self.configuration.switchTintColor;
    self.weekShowSwitch.onTintColor = self.configuration.switchTintColor;
    self.timeSwitch.onTintColor = self.configuration.switchTintColor;
    self.dateStyleSegmented.tintColor = self.configuration.switchTintColor;
    self.timeStyleSegmented.tintColor = self.configuration.switchTintColor;
    
    //distinguish
    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if (([dev.img_ver caseInsensitiveCompare:@"v3.3.1"] == NSOrderedAscending))
    {
        [self.dateStyleSegmented removeSegmentAtIndex:(self.dateStyleSegmented.numberOfSegments - 1) animated:NO];
    }
}

#pragma mark View lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    
    //pseudo-data
    _relatedArray = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null]]]]];
    
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
    
    mcall_ctx_osd_get *ctx = [[mcall_ctx_osd_get alloc] init];
    ctx.sn = _deviceID;
    ctx.on_event = @selector(osd_get_done:);
    ctx.target = self;
    [_agent osd_get:ctx];
    
    [self loading:YES];
}

- (void)viewDidAppear:(BOOL)animated
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

#pragma mark - osd_get_done
//设置操作
- (void)osd_get_done:(mcall_ret_osd_get *)ret
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
    
    self.nameSwitch.on         = ret.text_enable;
    self.dateSwitch.on         = ret.date_enable;
    self.timeSwitch.on         = ret.time_enable;
    
    [_nameSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    [_dateSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    [_timeSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    
    self.weekShowSwitch.on     = ret.week_enable;
    
    self.nameTextField.text    = ret.text;
    _dateStyleSegmented.selectedSegmentIndex = self.dateStyleSegmented.numberOfSegments == 2 ? ([ret.date_format isEqual:@"MM-DD-YYYY"] ? 0 : 1) : ([ret.date_format isEqual:@"MM-DD-YYYY"] ? 0 : [ret.date_format isEqual:@"YYYY-MM-DD"] ? 1 : 2);
    _timeStyleSegmented.selectedSegmentIndex = ret.time_12h? 0 : 1;
}

#pragma mark - osd_set_done
- (void)osd_set_done:(mcall_ret_osd_set *)ret
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

- (IBAction)setupNameDispaly:(id)sender
{
    NSMutableArray *dataArray = [_relatedArray objectAtIndex:0];
    
    [self.tableView beginUpdates];
    if (((UISwitch*)sender).on)
    {
        if (dataArray.count <= 1)
        {
            [dataArray insertObject:[NSNull null] atIndex:1];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else
    {
        if (dataArray.count > 1)
        {
            [dataArray removeObjectAtIndex:1];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0] ]withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [self.tableView endUpdates];
}

- (IBAction)setupDateDisplay:(id)sender
{
    NSMutableArray *dataArray = [_relatedArray objectAtIndex:1];

    [self.tableView beginUpdates];
    if (((UISwitch*)sender).on)
    {
        if (dataArray.count <= 1)
        {
            [dataArray insertObject:[NSNull null] atIndex:1];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else
    {
        if (dataArray.count > 1)
        {
            [dataArray removeObjectAtIndex:1];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1] ]withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [self.tableView endUpdates];
}

- (IBAction)setupTimeDispaly:(id)sender
{
    NSMutableArray *dataArray = [_relatedArray objectAtIndex:2];

    [self.tableView beginUpdates];
    if (((UISwitch*)sender).on)
    {
        if (dataArray.count <= 1)
        {
            [dataArray insertObject:[NSNull null] atIndex:1];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else
    {
        if (dataArray.count > 1)
        {
            [dataArray removeObjectAtIndex:1];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2] ]withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [self.tableView endUpdates];
}

- (IBAction)apply:(id)sender
{
    NSString *userRegex = @"[A-Za-z0-9]{0,20}";
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",userRegex];
    BOOL valid = [userPredicate evaluateWithObject:_nameTextField.text];

    if (valid)
    {
        mcall_ctx_osd_set *ctx = [[mcall_ctx_osd_set alloc] init];
        ctx.text_enable = _nameSwitch.on;
        ctx.text = _nameTextField.text.length? _nameTextField.text:@"";
        
        NSString *format = _dateStyleSegmented.numberOfSegments == 2 ? (_dateStyleSegmented.selectedSegmentIndex == 0 ? @"MM-DD-YYYY" :  @"YYYY-MM-DD") : (_dateStyleSegmented.selectedSegmentIndex == 0 ? @"MM-DD-YYYY" : (_dateStyleSegmented.selectedSegmentIndex == 1 ? @"YYYY-MM-DD" : @"DD-MM-YYYY"));
        ctx.date_format = format;
        ctx.date_enable = _dateSwitch.on;
        ctx.time_12h = _timeStyleSegmented.selectedSegmentIndex == 0 ? YES : NO;
        ctx.time_enable = _timeSwitch.on;
        ctx.week_enable = _weekShowSwitch.on;
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(osd_set_done:);
        
        [self loading:YES];
        [_agent osd_set:ctx];
    }
    else
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_nick_range_hint", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_nick_range_hint", nil)]];
        }
    }
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _relatedArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataArray = [_relatedArray objectAtIndex:section];
    NSInteger number = dataArray.count;
    return number;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
