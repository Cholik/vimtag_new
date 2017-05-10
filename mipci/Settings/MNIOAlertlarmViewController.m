//
//  MNIOAlertlarmViewController.m
//  mipci
//
//  Created by mining on 15/7/27.
//
//

#import "MNIOAlertlarmViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "MNDeviceMatteSetViewController.h"
#import "AppDelegate.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"

@interface MNIOAlertlarmViewController ()
{
    NSString *_src;
}
@property (strong, nonatomic) NSString *headTitel;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSMutableArray *relatedArray;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (assign, nonatomic) BOOL enable;

@end

@implementation MNIOAlertlarmViewController

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

//-(mipc_agent *)agent
//{
//    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
//}

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
        self.title = NSLocalizedString(@"mcs_alarm_settings", nil);
    }
    
    return self;
}

-(NSMutableArray *)relatedArray
{
    @synchronized(self)
    {
        if (nil == _relatedArray) {
            _relatedArray = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null]]],
                                                             [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null], [NSNull null], [NSNull null]]],
                                                           
                                                            [NSMutableArray arrayWithArray:@[[NSNull null]]]]];
        }
        return _relatedArray;
    }
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_alarm_settings", nil);
    [self.applyButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_applyButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_applyButton setBackgroundColor:app.button_color];
    

    
    _statusTiteLabel.text = NSLocalizedString(@"mcs_enabled", nil);
    _IOAlertTiteLabel.text = NSLocalizedString(@"mcs_io", nil);
    _snapshotTiteLabel.text = NSLocalizedString(@"mcs_snapshots", nil);
    _recordTiteLable.text = NSLocalizedString(@"mcs_record", nil);
    
    _IOAlertTimeTiteLable.text = NSLocalizedString(@"mcs_io_alert_time", nil);
    
    _statusSwitch.onTintColor = self.configuration.switchTintColor;
    _IOAlertSwitch.onTintColor = self.configuration.switchTintColor;
    _snapshotSWitch.onTintColor = self.configuration.switchTintColor;
    _recordSwitch.onTintColor = self.configuration.switchTintColor;
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
    mcall_ctx_alarm_action_get *ctx = [[mcall_ctx_alarm_action_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(alarm_action_get_done:);
    
    [_agent alarm_action_get:ctx];
    
    [self loading:YES];
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
    else
    {
        _enable = ret.enable;
        alarm_action *alarm = ret.alarm_items[1];
        
        _statusSwitch.on = alarm.enable;
        _IOAlertSwitch.on = alarm.io_out_enable;
        _snapshotSWitch.on = alarm.snapshot_enable;
        _recordSwitch.on = alarm.record_enable;
           _IOAlertTimeTextField.text = [NSString stringWithFormat:@"%d", alarm.io_alart_lenght];
        [_statusSwitch sendActionsForControlEvents:UIControlEventValueChanged];
        
        [_IOAlertSwitch sendActionsForControlEvents:UIControlEventEditingChanged];
        
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
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_failed_to_set_the", nil)]];
            }
        }
    }
    else
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        }
    }
}

#pragma mark - Action
- (IBAction)apply:(id)sender
{
  
    
//        NSString *regex = @"[1-6][0-9]{1}";
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",regex];
//        BOOL isValid = [predicate evaluateWithObject:_IOAlertTimeTextField.text];
//    if (!isValid)
//    {
//        //FIXME:add alert
//        [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_ioalert_prerecord_interval_range_hint", nil)]];
//        return ;
//    }
//    
    if ([_IOAlertTimeTextField.text floatValue] > 60) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_ioalert_prerecord_interval_range_hint", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView alertToast:NSLocalizedString(@"mcs_ioalert_prerecord_interval_range_hint", nil)]];
        }
        return ;
    }
    
    
    alarm_action *action = [[alarm_action alloc] init];
    action.token            = @"io_alert";
    action.name             = action.token;
    action.enable           = _statusSwitch.on;
    action.io_out_enable    = _IOAlertSwitch.on;
    action.record_enable    = _recordSwitch.on;
    action.snapshot_enable  = _snapshotSWitch.on;
     action.io_alart_lenght = [_IOAlertTimeTextField.text intValue];
    //FIXME:how
    action.alarm_src = [_src componentsSeparatedByString:@"|"];
    
    
    mcall_ctx_alarm_action_set *ctx = [[mcall_ctx_alarm_action_set alloc]init];
    
    ctx.alarm_items = @[action];
    ctx.sn = _deviceID;
    ctx.enable = _enable;
    ctx.target = self;
    ctx.on_event = @selector(alarm_action_set_done:);
    
    [_agent alarm_action_set:ctx];
    
    [self loading:YES];
}

- (IBAction)enableChange:(id)sender {
    if (_statusSwitch.on && _relatedArray.count == 2) {
        NSMutableArray *datas = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null], [NSNull null], [NSNull null]]]]];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
        [_relatedArray insertObjects:datas atIndexes:indexSet];
        [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    } else if(!_statusSwitch.on && _relatedArray.count == 3) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
        [_relatedArray removeObjectAtIndex:1];
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView reloadData];
}

- (IBAction)IOOutputChange:(id)sender {
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_statusSwitch.on && section == 1 ) {
        return NSLocalizedString(@"mcs_io_alert", nil);
    } else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.relatedArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if ((!dev.exsw && section == 1 && _statusSwitch.on)|| (dev.exsw && section == 1 && !_IOAlertSwitch.on && _statusSwitch.on)){
        return ((NSMutableArray *)self.relatedArray[section]).count - 1;
    } else {
         return ((NSMutableArray *)self.relatedArray[section]).count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (self.tableView.numberOfSections == 2 && indexPath.section == 1) {
        NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
        cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
    } else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
