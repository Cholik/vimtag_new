//
//  MNMotionDetectionViewController.m
//  mipci
//
//  Created by mining on 15/7/27.
//
//

#import "MNMotionDetectionViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "MNDeviceMatteSetViewController.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"

@interface MNMotionDetectionViewController ()
{
    NSString *_src;
}
@property (strong, nonatomic) NSArray *headTitel;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray *relatedArray;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (assign, nonatomic) BOOL enable;

@end

@implementation MNMotionDetectionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(AppDelegate *)app
{
    if (nil == _app){
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = NSLocalizedString(@"mcs_motion_detection", nil);
    }
    
    return self;
}

-(NSMutableArray *)relatedArray
{
    @synchronized(self)
    {
        if (nil == _relatedArray && self.app.is_luxcam) {
            _relatedArray = [NSMutableArray arrayWithArray:
                                @[[NSMutableArray arrayWithArray:@[[NSNull null]]],
                                 [NSMutableArray arrayWithArray:@[[NSNull null]]],
                                 [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null]]],
                                 [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null],
                                                                  [NSNull null]]],
                                 [NSMutableArray arrayWithArray:@[[NSNull null]]]]];
        }else if (nil == _relatedArray){
            _relatedArray = [NSMutableArray arrayWithArray:
                                @[[NSMutableArray arrayWithArray:@[[NSNull null]]],
                                 [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null]]],
                                 [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null],                     [NSNull null]]],
                                 [NSMutableArray arrayWithArray:@[[NSNull null]]]]];
        }

        return _relatedArray;
    }
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_motion_detection", nil);
    [self.applyButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    _headTitel = [NSArray arrayWithObjects:NSLocalizedString(@"mcs_motion_detection_sensitivity", nil),  NSLocalizedString(@"mcs_motion_alert", nil), nil];
    
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_applyButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_applyButton setBackgroundColor:app.button_color];
    
    self.daytimeTiteLable.text = NSLocalizedString(@"mcs_daytime", nil);
    self.nightTiteLable.text = NSLocalizedString(@"mcs_night", nil);
    self.maskSettingTiteLabel.text = NSLocalizedString(@"mcs_mask_settings", nil);
    
    self.daytimeSlider.value   = 0;
    self.nightSlider.value     = 0;
    self.daytimeLable.text     = 0;
    self.nightLable.text       = 0;
    
      _statusTiteLabel.text = NSLocalizedString(@"mcs_enabled", nil);
    _IOAlertTiteLabel.text = NSLocalizedString(@"mcs_io", nil);
    _snapshotTiteLabel.text = NSLocalizedString(@"mcs_snapshots", nil);
    _recordTiteLabel.text = NSLocalizedString(@"mcs_record", nil);
    
    _statusSwitch.onTintColor = self.configuration.switchTintColor;
    _IOAlertSwitch.onTintColor = self.configuration.switchTintColor;
    _snapshotSWitch.onTintColor = self.configuration.switchTintColor;
    _recordSwitch.onTintColor =self.configuration.switchTintColor;
    
    _daytimeSlider.tintColor = self.configuration.switchTintColor;
    _nightSlider.tintColor = self.configuration.switchTintColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
    
    //get info
    [self alarmActionGet];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -alarmActionGet
- (void)alarmActionGet
{
    //FIXME:add alert
    mcall_ctx_alarm_action_get *alarmCtx = [[mcall_ctx_alarm_action_get alloc] init];
    alarmCtx.sn = _deviceID;
    alarmCtx.target = self;
    alarmCtx.on_event = @selector(alarm_action_get_done:);
    
    [_agent alarm_action_get:alarmCtx];
    
    mcall_ctx_trigger_action_get *triggerCtx = [[mcall_ctx_trigger_action_get alloc] init];
    triggerCtx.sn = _deviceID;
    triggerCtx.on_event = @selector(alarm_trigger_get_done:);
    triggerCtx.target = self;
    
    [_agent alarm_trigger_get:triggerCtx];
    [self loading:YES];
}

#pragma mark - alarm_trigger_get_done
- (void)alarm_trigger_get_done:(mcall_ret_trigger_action_get*)ret
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
        return;
    }
    
    
    self.daytimeSlider.value = ret.sensitivity;
    [_daytimeSlider sendActionsForControlEvents:UIControlEventValueChanged];
    
    self.nightSlider.value = ret.night_sensitivity;
    [_nightSlider sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - alarm_trigger_set_done
- (void)alarm_trigger_set_done:(mcall_ret_trigger_action_set *)ret
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

#pragma mark - alarm_action_get_done
- (void)alarm_action_get_done:(mcall_ret_alarm_action_get *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing)
    {
        return;
    }
    
    if(nil != ret.result)
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
        
        return;
    }
    else
    {
        _enable = ret.enable;
        alarm_action *alarm = ret.alarm_items[0];
        
        _statusSwitch.on = alarm.enable;
        _IOAlertSwitch.on = alarm.io_out_enable;
        _snapshotSWitch.on = alarm.snapshot_enable;
        _recordSwitch.on = alarm.record_enable;

        [_statusSwitch sendActionsForControlEvents:UIControlEventValueChanged];
        
        
        
//        //FIXME:add alert
        if(alarm.alarm_src)
        {
            NSString *s_src = @"";
            for(NSString *src in alarm.alarm_src)
                s_src = [NSString stringWithFormat:@"%@%@%@",s_src,s_src.length?@"|":@"",src];
            _src = s_src;
        }
    }
    
}

#pragma mark - alarm_action_set_done
- (void)alarm_action_set_done:(mcall_ret_alarm_action_set *)ret
{
    [self loading:NO];
    
    if (!_isViewAppearing)
    {
        return;
    }
    
    if (nil != ret.result)
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
    else
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        }
    }
}


#pragma mark - Action
- (IBAction)daytimeSensitivityChange:(id)sender
{
    UISlider *slider = sender;
    NSInteger  value = slider.value;
    NSString *number = [NSString stringWithFormat:@"%ld",(long)value];
    self.daytimeLable.text = number;
}

- (IBAction)nightSensitivityChange:(id)sender
{
    UISlider *slider = sender;
    NSInteger value = slider.value;
    NSString *number = [NSString stringWithFormat:@"%ld",(long)value];
    self.nightLable.text = number;
}

- (IBAction)enableChange:(id)sender {
    if (self.app.is_luxcam) {
        NSRange range = NSMakeRange(1, 3);
        if (_statusSwitch.on && _relatedArray.count == 2) {
            NSMutableArray *datas = [NSMutableArray arrayWithArray:
                                     @[[NSMutableArray arrayWithArray:@[[NSNull null]]],
                                       [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null]]],
                                       [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null], [NSNull null]]]]];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray insertObjects:datas atIndexes:indexSet];
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
        else if (!_statusSwitch.on && _relatedArray.count == 5){
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray removeObjectsAtIndexes:indexSet];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        NSRange range = NSMakeRange(1, 2);
        if (_statusSwitch.on && _relatedArray.count == 2) {
            NSMutableArray *datas = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null]]],  [NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null], [NSNull null]]]]];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray insertObjects:datas atIndexes:indexSet];
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }else if (!_statusSwitch.on && _relatedArray.count == 4) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_relatedArray removeObjectsAtIndexes:indexSet];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    [self.tableView reloadData];
}

- (IBAction)apply:(id)sender
{
    mcall_ctx_trigger_action_set *ctx = [[mcall_ctx_trigger_action_set alloc] init];
    ctx.sn =_deviceID;
    ctx.target = self;
    ctx.on_event = @selector(alarm_trigger_set_done:);
    ctx.sensitivity = [_daytimeLable.text intValue];
    ctx.night_sensitivity = [_nightLable.text intValue];
    [_agent alarm_trigger_set:ctx];
    
//    NSString *regex = @"[0-6]{1}";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",regex];
//    BOOL isValid = [predicate evaluateWithObject:_recordTimeTextField.text];
//    
//    if (!isValid)
//    {
//        //FIXME:add alert
//        [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_prerecord_interval_range_hint", nil)]];
//        return ;
//    }
    
    alarm_action *action = [[alarm_action alloc] init];
    action.token            = @"motion_alert";
    action.name             = action.token;
    action.enable           = _statusSwitch.on;
    action.io_out_enable    = _IOAlertSwitch.on;
    action.record_enable    = _recordSwitch.on;
    action.snapshot_enable  = _snapshotSWitch.on;
    action.pre_record_lenght= 3;

    //FIXME:how
    action.alarm_src = [_src componentsSeparatedByString:@"|"];
    
    
    mcall_ctx_alarm_action_set *alarmCtx = [[mcall_ctx_alarm_action_set alloc]init];

    alarmCtx.alarm_items = @[action];
    alarmCtx.sn = _deviceID;
    alarmCtx.enable = _enable;
    alarmCtx.target = self;
    alarmCtx.on_event = @selector(alarm_action_set_done:);
    
    [_agent alarm_action_set:alarmCtx];

    [self loading:YES];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.app.is_luxcam) {
        if (_statusSwitch.on  && (section == 2 || section == 3)){
                return [_headTitel objectAtIndex:(section - 2)];
            } else if (!_statusSwitch.on && section == 2) {
                return [_headTitel objectAtIndex:(section - 2)];
        }
    } else if (_statusSwitch.on && (section == 1 || section == 2)){
        return [_headTitel objectAtIndex:(section - 1)];
    } else {
        return nil;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.relatedArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (self.app.is_luxcam && (section == 1 || section == 2)) {
//        return ((NSMutableArray *)self.relatedArray[section]).count - 1;
//    } else {
        return ((NSMutableArray *)self.relatedArray[section]).count;
//    }
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell;
     if (self.app.is_luxcam) {
         if (self.tableView.numberOfSections == 2 && indexPath.section == 1) {
             NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 3];
             cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
         } else {
             cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
         }

     } else if((self.tableView.numberOfSections == 4 && indexPath.section > 0 )|| (self.tableView.numberOfSections == 3 && indexPath.section == 1)){
         NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
         cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
     } else if (self.tableView.numberOfSections == 2 && indexPath.section == 1){
         NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 3];
         cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
     }
     else {
         cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
     }
 
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     return cell;
 }

#pragma mark tableDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && self.app.is_luxcam) {
        [self performSegueWithIdentifier:@"MNDeviceMatteSetViewController" sender:nil];
    }
}

 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"MNDeviceMatteSetViewController"])
     {
         MNDeviceMatteSetViewController *deviceMatteSetViewController = segue.destinationViewController;
         deviceMatteSetViewController.deviceID = _deviceID;
         deviceMatteSetViewController.rootNavigationController = _rootNavigationController;
     }
 }


@end
