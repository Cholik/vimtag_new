//
//  MNMotionAndNotificationsViewController.m
//  mipci
//
//  Created by mining on 15/7/27.
//
//

#import "MNMotionAndNotificationsViewController.h"
#import "MNMotionDetectionViewController.h"
#import "MNIOAlertlarmViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MNInfoPromptView.h"

#define ALERT_ON    1001
#define ALERT_OFF   1000

@interface MNMotionAndNotificationsViewController ()
@property (assign, nonatomic) BOOL isViewAppearing;
@property (copy, nonatomic) NSArray *headTitle;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSArray *relatedArray;
//@property (strong, nonatomic) NSMutableArray *viewControllerKeys;
@end

@implementation MNMotionAndNotificationsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = NSLocalizedString(@"mcs_motion_notification", nil);
    }
    
    return self;
}

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return  _app;
}

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_motion_notification", nil);
    _motionDetectionTitleLabel.text = NSLocalizedString(@"mcs_motion_detection", nil);
    _IOAlarmtiTleLabel.text = NSLocalizedString(@"mcs_io_alarm", nil);
    _notificationCenter.text = NSLocalizedString(@"mcs_notification_center", nil);
    [_turnAlertOnButton setTitle:NSLocalizedString(@"mcs_alert_on", nil) forState:UIControlStateNormal];
    self.headTitle = [NSArray arrayWithObjects:NSLocalizedString(@"mcs_alarm_settings", nil), NSLocalizedString(@"mcs_notification_settings", nil), nil];
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_turnAlertOnButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_turnAlertOnButton setBackgroundColor:app.button_color];
    
    _relatedArray = @[@[[NSNull null], [NSNull null]], @[[NSNull null]], @[[NSNull null]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    //get info
    _isViewAppearing = YES;
    mcall_ctx_alarm_action_get *ctx = [[mcall_ctx_alarm_action_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(alarm_action_get_done:);
    
    [_agent alarm_action_get:ctx];
    [self loading:YES];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    else
    {
        //_statusSwitch.on = ret.enable;
        //        enableResult = ret.enable;
        _turnAlertOnButton.tag = ret.enable ? ALERT_ON : ALERT_OFF;
        if (ret.enable == YES) {
            [_turnAlertOnButton setTitle:NSLocalizedString(@"mcs_alert_off", nil) forState:UIControlStateNormal];
        } else {
            [_turnAlertOnButton setTitle:NSLocalizedString(@"mcs_alert_on", nil) forState:UIControlStateNormal];
        }
    }
    
}


#pragma mark -Action

- (IBAction)turnAlertOn:(id)sender {
    mcall_ctx_alarm_action_set *ctx = [[mcall_ctx_alarm_action_set alloc]init];
    ctx.enable = _turnAlertOnButton.tag == ALERT_ON ? NO : YES;
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(alarm_action_set_done:);
    
    _turnAlertOnButton.tag = (_turnAlertOnButton.tag == ALERT_ON) ? ALERT_OFF : ALERT_ON;
    
    [_agent alarm_action_set:ctx];
    [self loading:YES];
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
        _turnAlertOnButton.tag = (_turnAlertOnButton.tag == ALERT_ON) ? ALERT_OFF : ALERT_ON;
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
        
        if (_turnAlertOnButton.tag == ALERT_ON) {
            [_turnAlertOnButton setTitle:NSLocalizedString(@"mcs_alert_off", nil) forState:UIControlStateNormal];
        } else {
            [_turnAlertOnButton setTitle:NSLocalizedString(@"mcs_alert_on", nil) forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section == 0 || (section == 1 && self.app.is_luxcam)) {
        return [_headTitle objectAtIndex:section];
    } else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    if (!self.app.is_luxcam) {
        return _relatedArray.count - 1;
    }
    return _relatedArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (!self.app.is_luxcam &&  indexPath.section == 1) {
        NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
        cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
    } else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - Table view data delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"MNMotionDetectionViewController" sender:nil];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"MNIOAlertlarmViewController" sender: nil];
    } else if (indexPath.section == 1 && self.app.is_luxcam) {
        [self performSegueWithIdentifier:@"MNNotificationCenterViewController" sender:nil];
    }
}

#pragma mark - prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *viewController = segue.destinationViewController;
    [viewController setValue:_agent forKey:@"agent"];
    [viewController setValue:_deviceID forKey:@"deviceID"];
    [viewController setValue:_rootNavigationController forKey:@"rootNavigationController"];
}


@end
