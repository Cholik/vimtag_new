//
//  UItimezoneListTableViewController.m
//  mining_client
//
//  Created by mining on 14-10-17.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNTimezoneListViewController.h"
#import "UITableViewController+loading.h"
#import "mipc_agent.h"
#import "MNProgressHUD.h"
#import "AppDelegate.h"
#import "MNToastView.h"
#import "mipc_timezone_manager.h"
#import "MNInfoPromptView.h"

@interface MNTimezoneListViewController ()
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (strong, nonatomic) NSIndexPath *lastIndexPath;
@property (strong, nonatomic) NSMutableArray *timezoneList;
@property (assign, nonatomic) BOOL isNewZone;
@end

@implementation MNTimezoneListViewController

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

- (NSMutableArray *)timezoneList
{
    if (nil == _timezoneList) {
        _timezoneList = [NSMutableArray array];
    }
    return _timezoneList;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isViewAppearing = YES;
    
    
    mcall_ctx_timezone_get *ctx = [[mcall_ctx_timezone_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(timezone_get_done:);
    [self.agent timezone_get:ctx];
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

#pragma mark - timezone_get_done
- (void)timezone_get_done:(mcall_ret_timezone_get *)ret
{
    [self loading:NO];
    if (!_isViewAppearing) {
        return;
    }
    
    if(nil != ret.result)
    {
        if (ret.address.count == 0) {
            _isNewZone = NO;
            self.timezoneList = [NSMutableArray arrayWithObjects:@"UTC+14:00",@"UTC+13:00",@"UTC+12:00",@"UTC+11:00",@"UTC+10:30",@"UTC+10:00",@"UTC+09:30",@"UTC+09:00",@"UTC+08:00",@"UTC+07:00",@"UTC+06:30",@"UTC+06:00",@"UTC+05:45",@"UTC+05:30",@"UTC+05:00",@"UTC+04:30",@"UTC+04:00",@"UTC+03:30",@"UTC+02:00",@"UTC+01:00",@"UTC+00:00",@"UTC-01:00", @"UTC-02:00",@"UTC-03:00",@"UTC-03:30",@"UTC-04:00",@"UTC-05:00",@"UTC-06:00",@"UTC-07:00",@"UTC-08:00",@"UTC-09:00",@"UTC-09:30",@"UTC-10:00",@"UTC-11:00",@"UTC-12:00",nil];
            
            NSInteger index = [_timezoneList indexOfObject:_selectedTimetone];
            _lastIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        }
        else if ([ret.result isEqualToString:@"ret.dev.offline"]) {
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
    else if(ret.address.count > 0){
        _isNewZone = YES;
        self.timezoneList = ret.address;
        for (int i = 0; i < self.timezoneList.count; i++) {
            zone_obj * zone = self.timezoneList[i];
            NSString *zoneStr = [NSString stringWithFormat:@"%@,%@",zone.utc, NSLocalizedString(TIMEZONE_CITY[zone.city], nil)];
//            NSArray *selectedTimeArray = [_selectedTimetone componentsSeparatedByString:@","];
            if ([zoneStr isEqualToString:_selectedTimetone] || [zone.utc isEqualToString:_selectedTimetone]) {
                _lastIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                break;
            }
        }
        
        //        NSMutableArray *zones_arr = ret.address;
        //        NSString *zone_str = [[NSString alloc] init];
        //        for (int i = 0 ; i < zones_arr.count; i++) {
        //            if (i >= zones_arr.count-1) {
        //                [self.timezoneList addObject:zone_str];
        //                break;
        //            }
        //            zone_obj *zone = zones_arr[i];
        //            zone_obj *zone_next = zones_arr[i+1];
        //            if (i == 0) {
        //                zone_str = [zone_str stringByAppendingFormat:@"%@  %@",zone.utc,NSLocalizedString(TIMEZONE_CITY[zone.city], nil)];
        //            }
        //            if ([zone.utc isEqualToString:zone_next.utc]) {
        //                zone_str = [zone_str stringByAppendingFormat:@",%@",zone_next.city];
        //            }else{
        //                [self.timezoneList addObject:zone_str];
        //                if ([zone.utc isEqualToString:[_selectedTimetone stringByReplacingOccurrencesOfString:@":" withString:@"_"]]) {
        //                    _selectedTimetone = zone_str;
        //                }
        //                zone_str = @"";
        //                zone_str = [zone_str stringByAppendingFormat:@"%@  %@",zone_next.utc,zone_next.city];
        //            }
        //        }
        
        //        zone_obj *zone_tmp = [[zone_obj alloc] init];
        //        for (int i = 0 ; i < zones_arr.count; i++) {
        //            if (i >= zones_arr.count-1) {
        //                zone_tmp.city = zone_str;
        //                [self.timezoneList addObject:zone_tmp];
        //                break;
        //            }
        //            zone_obj *zone = zones_arr[i];
        //            zone_obj *zone_next = zones_arr[i+1];
        //            if (i == 0) {
        //                zone_tmp.utc = zone.utc;
        //                zone_str = [zone_str stringByAppendingFormat:@"%@",zone.city];
        //            }
        //            if ([zone.utc isEqualToString:zone_next.utc]) {
        //                zone_str = [zone_str stringByAppendingFormat:@",%@",zone_next.city];
        //            }else{
        //                zone_tmp.utc = zone.utc;
        //                zone_tmp.city = zone_str;
        //                [self.timezoneList addObject:zone_tmp];
        //                if ([zone.utc isEqualToString:[_selectedTimetone stringByReplacingOccurrencesOfString:@":" withString:@"_"]]) {
        //                    _selectedTimetone = zone_str;
        //                }
        //                zone_str = @"";
        //                zone_tmp = [[zone_obj alloc] init];
        //                zone_tmp.utc = zone.utc;
        ////                zone_tmp.city = @"";
        //
        //                zone_str = [zone_str stringByAppendingFormat:@"%@",zone_next.city];
        //            }
        //        }
    }
    else if (ret.address.count == 0) {
        _isNewZone = NO;
        self.timezoneList = [NSMutableArray arrayWithObjects:@"UTC+14:00",@"UTC+13:00",@"UTC+12:00",@"UTC+11:00",@"UTC+10:30",@"UTC+10:00",@"UTC+09:30",@"UTC+09:00",@"UTC+08:00",@"UTC+07:00",@"UTC+06:30",@"UTC+06:00",@"UTC+05:45",@"UTC+05:30",@"UTC+05:00",@"UTC+04:30",@"UTC+04:00",@"UTC+03:30",@"UTC+02:00",@"UTC+01:00",@"UTC+00:00",@"UTC-01:00", @"UTC-02:00",@"UTC-03:00",@"UTC-03:30",@"UTC-04:00",@"UTC-05:00",@"UTC-06:00",@"UTC-07:00",@"UTC-08:00",@"UTC-09:00",@"UTC-09:30",@"UTC-10:00",@"UTC-11:00",@"UTC-12:00",nil];
        
        NSInteger index = [_timezoneList indexOfObject:_selectedTimetone];
        _lastIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.timezoneList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (_isNewZone) {
        zone_obj *zone = self.timezoneList[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(TIMEZONE_CITY[zone.city], nil)];
        cell.detailTextLabel.text = zone.utc;
    }
    else{
        cell.textLabel.text = self.timezoneList[indexPath.row];
        cell.detailTextLabel.text = @"";
    }
    //    cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    //    cell.detailTextLabel.numberOfLines = 0;
    //    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    //    CGSize requiredSize = [cell.detailTextLabel.text boundingRectWithSize:CGSizeMake(100, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute
    //                                              context:nil].size;
    //    CGRect rect = cell.frame;
    //    rect.size.height = requiredSize.height > 44 ? requiredSize.height : 44;
    //    cell.frame = rect;
    //
    if (_lastIndexPath == indexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nil == _lastIndexPath)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        _lastIndexPath = indexPath;
    }
    else if (_lastIndexPath.row != indexPath.row)
    {
        UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:_lastIndexPath];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        _lastIndexPath = indexPath;
    }
    if (_isNewZone) {
        zone_obj *timezone = [_timezoneList objectAtIndex:indexPath.row];
        if (_deviceDateSetViewController) {
            _deviceDateSetViewController.timezoneLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(TIMEZONE_CITY[timezone.city], nil)];
            _deviceDateSetViewController.timezone_obj = timezone;
        } else {
            _modifyTimezoneViewController.deviceTimezoneLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(TIMEZONE_CITY[timezone.city], nil)];
            _modifyTimezoneViewController.timezone_obj = timezone;
        }
    }
    else
    {
        NSString *timezone = [_timezoneList objectAtIndex:indexPath.row];
        if (_deviceDateSetViewController) {
            _deviceDateSetViewController.timezoneLabel.text = timezone;
            _deviceDateSetViewController.timezone_obj.utc = timezone;
        } else {
            _modifyTimezoneViewController.deviceTimezoneLabel.text = timezone;
            _modifyTimezoneViewController.timezone_obj.utc = timezone;
        }
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
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
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
