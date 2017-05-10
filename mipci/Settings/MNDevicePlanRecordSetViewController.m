//
//  UIplanRecordTableViewController.m
//  mining_client
//
//  Created by mining on 14-9-11.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDevicePlanRecordSetViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "MNWeekListViewController.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"

#ifndef WEEK

#define WEEK @[\
NSLocalizedString(@"mcs_sunday",nil),\
NSLocalizedString(@"mcs_monday",nil),\
NSLocalizedString(@"mcs_tuesday",nil),\
NSLocalizedString(@"mcs_wednesday",nil),\
NSLocalizedString(@"mcs_thursday",nil),\
NSLocalizedString(@"mcs_friday",nil),\
NSLocalizedString(@"mcs_saturday",nil),\
]

#endif

#define WEEK_SAMPlE @[\
NSLocalizedString(@"mcs_sun",nil),\
NSLocalizedString(@"mcs_mon",nil),\
NSLocalizedString(@"mcs_tue",nil),\
NSLocalizedString(@"mcs_wed",nil),\
NSLocalizedString(@"mcs_thu",nil),\
NSLocalizedString(@"mcs_fri",nil),\
NSLocalizedString(@"mcs_sat",nil),\
]

#define WEEK_SEGMENT 4
#define WEEK_BYTE @[@0x1,@0x2,@0x4,@0x8,@0x10,@0x20,@0x40]

@interface MNDevicePlanRecordSetViewController ()

@property (strong, nonatomic) NSArray *headTite;
@property (strong, nonatomic) NSArray *weekTite;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (strong, nonatomic) MNCustomDatePicker *datePicker;
@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) NSMutableArray *relatedArray;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNDevicePlanRecordSetViewController

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
        self.title = NSLocalizedString(@"mcs_scheduled_recording", nil);
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

-(NSMutableArray *)weeks
{
    @synchronized(self)
    {
        if (nil == _weeks) {
            _weeks = [NSMutableArray arrayWithArray:@[[NSNull null],
                                                      [NSNull null],
                                                      [NSNull null],
                                                      [NSNull null]]];
        }
        
        return _weeks;
    }
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_scheduled_recording", nil);

    [_applyButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_applyButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_applyButton setBackgroundColor:app.button_color];

    
    _recordStateTiteLabel.text = NSLocalizedString(@"mcs_enabled", nil);
    _weekStateTiteLabel.text = NSLocalizedString(@"mcs_7x24_hours" , nil);
    
    _oneStartTimeTiteLabel.text = NSLocalizedString(@"mcs_begin_time", nil);
    _oneEndTimeTiteLabel.text = NSLocalizedString(@"mcs_end_time", nil);
    _oneDateTimeTiteLabel.text = NSLocalizedString(@"mcs_date", nil);
    
    _twoStartTimeTiteLabel.text = NSLocalizedString(@"mcs_begin_time", nil);
    _twoEndTimeTiteLabel.text = NSLocalizedString(@"mcs_end_time", nil);
    _twoDateTimeTiteLabel.text = NSLocalizedString(@"mcs_date", nil);
    
    _threeStartTimeTiteLabel.text = NSLocalizedString(@"mcs_begin_time", nil);
    _threeEndTimeTiteLabel.text = NSLocalizedString(@"mcs_end_time", nil);
    _threeDateTimeTiteLabel.text = NSLocalizedString(@"mcs_date", nil);
    
    _fourStartTimeTiteLabel.text = NSLocalizedString(@"mcs_begin_time", nil);
    _fourEndTimeTiteLabel.text = NSLocalizedString(@"mcs_end_time", nil);
    _fourDateTimeTiteLabel.text = NSLocalizedString(@"mcs_date", nil);
    
    _recordStateSwitch.onTintColor = self.configuration.switchTintColor;
    _weekStateSwitch.onTintColor = self.configuration.switchTintColor;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    _isViewAppearing = YES;
    
    _headTite = [NSArray arrayWithObjects:NSLocalizedString(@"mcs_scheduled_one", nil),
                 NSLocalizedString(@"mcs_scheduled_two", nil),
                 NSLocalizedString(@"mcs_scheduled_three", nil),
                 NSLocalizedString(@"mcs_scheduled_four", nil), nil];
    
    _weekTite = [NSArray arrayWithObjects:NSLocalizedString(@"mcs_sun", nil),
                 NSLocalizedString(@"mcs_mon", nil),
                 NSLocalizedString(@"mcs_tue" , nil),
                 NSLocalizedString(@"mcs_wed", nil),
                 NSLocalizedString(@"mcs_thu", nil),
                 NSLocalizedString(@"mcs_fri", nil),
                 NSLocalizedString(@"mcs_sat", nil), nil];
    
    _relatedArray = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null]]]]];
    _isViewAppearing = YES;
    mcall_ctx_record_get *ctx = [[mcall_ctx_record_get alloc] init];
    ctx.target = self;
    ctx.on_event = @selector(record_get_done:);
    ctx.sn = _deviceID;
    
    [_agent record_get:ctx];
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

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network callback
- (void)record_get_done:(mcall_ret_record_get *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing)
    {
        return;
    }
    
    if(nil == ret.result)
    {
        _recordStateSwitch.on  = ret.enable;
        _weekStateSwitch.on    = ret.full_time;
        
        for (int i = 0; i < ret.times.count; i++) {
            mdev_time *times_item = ret.times[i];
            
            UILabel *startTimeLabel = _startTimeLabels[i];
            startTimeLabel.text = [self longToString:(int)times_item.start_time];
            
            UILabel *endTimeLabel = _endTimeLabels[i];
            endTimeLabel.text = [self longToString:(int)times_item.end_time];
            
            NSString *week_value = nil;
            for(int j = 0 ; j < 7 ; j++)
            {
                if ([WEEK_BYTE[j] intValue] == (times_item.time & [WEEK_BYTE[j] intValue]))
                {
                    week_value = week_value?[NSString stringWithFormat:@"%@ %@", week_value, WEEK_SAMPlE[j]]:WEEK_SAMPlE[j];
                }
            }
            
            UILabel *dateTimeLabel = _dateTimeLabels[i];
            dateTimeLabel.text = week_value;
            self.weeks[i] = [NSNumber numberWithInt:times_item.time];
        }
        
        [_recordStateSwitch sendActionsForControlEvents:UIControlEventValueChanged];
        [_weekStateSwitch sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else
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
}

- (void)record_set_done:(mcall_ret_record_set *)ret
{
    [self loading:NO];
    if (!_isViewAppearing)
    {
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
    else if ([ret.result isEqualToString:@"ret.sdcard.notready"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_no_sdcard", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            
        } else {
            [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_no_sdcard", nil)]];
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

- (IBAction)setupEnableStatus:(id)sender {
    NSRange range = NSMakeRange(1, 5);
    
    if (((UISwitch*)sender).on) {
        if (self.tableView.numberOfSections == 2 && !_weekStateSwitch.on) {
            NSMutableArray *datas = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null]]],
                                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]],
                                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]],
                                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]],
                                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]]]];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray insertObjects:datas atIndexes:indexSet];
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        } else if (self.tableView.numberOfSections == 2 && _weekStateSwitch.on) {
            range = NSMakeRange(1, 1);
            NSMutableArray *datas = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null]]],
                                                                     ]];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray insertObjects:datas atIndexes:indexSet];
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else
    {
        if (self.tableView.numberOfSections == 7) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray removeObjectsAtIndexes:indexSet];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
        if (self.tableView.numberOfSections == 3) {
            range = NSMakeRange(1, 1);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray removeObjectsAtIndexes:indexSet];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    [self.tableView reloadData];

}

- (IBAction)setupEnableWeekStatus:(id)sender {
    NSRange range = NSMakeRange(2, 4);
    
    if ((((UISwitch*)sender).on) && (_recordStateSwitch.on)) {
        if (self.tableView.numberOfSections == 7) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray removeObjectsAtIndexes:indexSet];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if(_recordStateSwitch.on)
    {
        if (self.tableView.numberOfSections == 3) {
            NSMutableArray *datas = [NSMutableArray arrayWithArray:@[
                                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]],
                                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]],
                                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]],
                                                                     [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null]]]]];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray insertObjects:datas atIndexes:indexSet];
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }

    }
    
    [self.tableView reloadData];
    
}

#pragma mark - Action
- (IBAction)apply:(id)sender {
    
//    NSMutableArray *times = [[NSMutableArray alloc] initWithCapacity:4];
//    
////    for (int j = 0; j < WEEK_SEGMENT; j++) {
////        NSLog(@"[%d]-------[%@]-----\n",j,self.weeks[j]);
////    }
//    
//    for (int i = 0 ; i < WEEK_SEGMENT ; i++)
//    {
//        
//        int l_start = [self stringToLong:((UILabel*)_startTimeLabels[i]).text];
//        int l_end = [self stringToLong:((UILabel*)_endTimeLabels[i]).text];
//        if (l_start > l_end)
//        {
//            //FIXME:
//            [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_end_time_should_lt_begin", nil)]];
//            return;
//        }
//        
//        int wday_byte = 0;
//        wday_byte = [self.weeks[i] isMemberOfClass:[NSNull class]]?0:[self.weeks[i] intValue];
//        if (!wday_byte)continue;
//        
//        mdev_time *time = [[mdev_time alloc] init];
//        time.start_time = l_start;
//        time.end_time = l_end;
//        time.time = wday_byte;
//        [times addObject:time];
//    }

    NSMutableArray *times = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray *checkTimesArray = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (int i = 0 ; i < WEEK_SEGMENT ; i++)
    {
        int l_start = [self stringToLong:((UILabel*)_startTimeLabels[i]).text];
        int l_end = [self stringToLong:((UILabel*)_endTimeLabels[i]).text];
        
        if ((l_start > l_end) && _recordStateSwitch.on  && !_weekStateSwitch.on)
        {
            //FIXME:
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_end_time_should_lt_begin", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                
            } else {
                [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_end_time_should_lt_begin", nil)]];
            }
            return;
        }
        
        int wday_byte = 0;
        wday_byte = [self.weeks[i] isMemberOfClass:[NSNull class]]?0:[self.weeks[i] intValue];
        
        mdev_time *time = [[mdev_time alloc] init];
        time.start_time = l_start;
        time.end_time = l_end;
        time.time = wday_byte;
        [checkTimesArray addObject:time];
    }
    
    for (mdev_time *time in checkTimesArray)
    {
        if (!time.time && time.end_time != 0) {
            if ( _recordStateSwitch.on  && !_weekStateSwitch.on) {
                if (self.app.is_InfoPrompt) {
                    [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_week_setting_prompt", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                    
                } else {
                    [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_week_setting_prompt", nil)]];
                }
                return;
            }
        }
        else if (!time.time)
        {
            continue;
        }
        else
        {
            if (time.start_time == 0 && time.end_time == 0)
            {
                if ( _recordStateSwitch.on && !_weekStateSwitch.on) {
                    if (self.app.is_InfoPrompt) {
                        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_time_setting_prompt", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
                        
                    } else {
                        [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_time_setting_prompt", nil)]];
                    }
                    return;
                }
            } else {
                [times addObject:time];
            }
        }
    }
    
    mcall_ctx_record_set *ctx = [[mcall_ctx_record_set alloc] init];
    ctx.enable = _recordStateSwitch.on;
    ctx.full_time = _weekStateSwitch.on;
    ctx.times = times;
    ctx.target = self;
    ctx.sn = _deviceID;
    ctx.on_event = @selector(record_set_done:);

    [self loading:YES];
    [_agent record_set:ctx];
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
    [self.view.superview addSubview:_datePicker];
     _datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
}

- (NSString*)longToString:(int)longtime
{
    NSString *date = [NSString stringWithFormat:@"%02d:%02d:%02d",longtime/3600,(longtime%3600)/60,longtime%3600%60];
    return date;
}

- (int)stringToLong:(NSString*)date
{
    NSArray *dates = [date componentsSeparatedByString:@":"];
    
    NSString *fhours;
    NSString *fmintues;
    NSString *fseconds;
    
    if (dates.count > 0)
        fhours = dates[0];
    if (dates.count > 1)
        fmintues = dates[1];
    if (dates.count > 2)
        fseconds = dates[2];
    
    int hours = [fhours intValue]*3600;
    int mintues = [fmintues intValue]*60;
    int seconds = [fseconds intValue];
    
    return hours + mintues + seconds;
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

#pragma mark - Table view data source
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (_recordStateSwitch.on && section > 1 && section < 6 && !_weekStateSwitch.on)
    {
        return [_headTite objectAtIndex:section-2];
    }
    else
    {
        return nil;
    }
}
#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.relatedArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *datas = self.relatedArray[section];
    NSInteger count = datas.count;
    
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSLog(@"---------------------------%ld", (long)self.tableView.numberOfSections);
    if (self.tableView.numberOfSections == 2 && indexPath.section == 1)
    {
        NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 5];
        cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
    }
    else if (self.tableView.numberOfSections == 3 && indexPath.section == 2)
    {
            NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 4];
            cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
    }
    else
    {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= 2)
    {
        if (0 == indexPath.row)
        {
            _currentTimeLabel = self.startTimeLabels[indexPath.section - 2];
            [self createDatePickerWithMode:UIDatePickerModeCountDownTimer];

        }
        else if (1 == indexPath.row)
        {
            _currentTimeLabel = self.endTimeLabels[indexPath.section - 2];
            [self createDatePickerWithMode:UIDatePickerModeCountDownTimer];

        }
        else if (2 == indexPath.row)
        {
            int index = (int)indexPath.section;
            _currentDateLabel = self.dateTimeLabels[indexPath.section - 2];
            [self performSegueWithIdentifier:@"MNWeekListViewController" sender:[NSNumber numberWithInt:index]];

        }
    }
}

#pragma mark - MNCustomDatePickerDelegate
- (void)datePicker:(MNCustomDatePicker*)datePicker value:(NSDate *)date
{
    NSString *contentStr = [self stringFromDate:date];
    
    NSArray *dates = [contentStr componentsSeparatedByString:@" "];
//    NSString *dateStr = dates[0];
    NSString *timeStr = dates[1];
    
    _currentTimeLabel.text = timeStr;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNWeekListViewController"]) {
        MNWeekListViewController *weekListViewController = segue.destinationViewController;
        weekListViewController.index = [sender intValue];
        weekListViewController.devicePlanRecordSetViewController = self;
    }
}


@end
