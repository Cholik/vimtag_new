//
//  UIdeviceSettingTableViewController.m
//  mining_client
//
//  Created by mining on 14-9-12.
//  Copyright (c) 2014年 mining. All rights reserved.
//

#import "MNDeviceSettingsViewController.h"
#import "MNDetailViewController.h"
#import "MNDeviceAboutViewController.h"
#import "MNDeviceNameSetViewController.h"
#import "MNDevicePasswordManagerViewController.h"
#import "MNGuestPasswordManagerViewController.h"
#import "MNDeviceEthernetSetViewController.h"
#import "MNDeviceWIFISetViewController.h"
#import "MNDeviceOSDSetViewController.h"
#import "MNDeviceSDcardSetViewController.h"
#import "MNDevicePlanRecordSetViewController.h"
#import "MNDevicePlanDefenceSetViewController.h"
#import "MNDeviceDateSetViewController.h"
#import "MNDeviceSystemSetViewController.h"
#import "MNDeviceOtherSetViewController.h"
#import "MNMotionAndNotificationsViewController.h"
#import "UITableViewController+loading.h"
#import "AppDelegate.h"
#import "MNDeviceListViewController.h"
#import "MNDeviceTabBarController.h"
#import "MNNetworkPageViewController.h"
#import "MNBoxTabBarController.h"
#import "MNTransitionViewController.h"
#define DELETEDEVICE 1001
#define ALERTSUCCESS  1002
#define ALERTINFO 1003


@interface MNDeviceSettingsViewController ()
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) m_dev *dev;
@property (strong, nonatomic) NSMutableArray *settingsArray;
@property (assign, nonatomic) NSInteger sectionNumber;
@end

@implementation MNDeviceSettingsViewController
@synthesize back = back;

#pragma mark - initialization
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceRestartNotification:)
                                                     name:@"DeviceRestartNotification"
                                                   object:nil];
    }
    
    return self;
}

-(m_dev *)dev
{
    if (nil == _dev) {
        _dev = [self.agent.devs get_dev_by_sn:_deviceID];
    }
    
    return _dev;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(NSMutableArray *)settingsArray
{
    @synchronized(self)
    {
        if (nil == _settingsArray ) {
            if ([self.dev.type isEqualToString:@"BOX"])
            {
                _settingsArray = [NSMutableArray arrayWithArray: @[NSLocalizedString(@"mcs_about", nil),
                                                                   NSLocalizedString(@"mcs_nickname", nil),
                                                                   NSLocalizedString(@"mcs_device_admin_password", nil),
                                                                   NSLocalizedString(@"mcs_device_guest_password", nil),
                                                                   NSLocalizedString(@"mcs_network", nil),
                                                                   //                                                                   NSLocalizedString(@"mcs_wifi", nil),
                                                                   NSLocalizedString(@"mcs_hard_disk", nil),
                                                                   NSLocalizedString(@"mcs_date_time", nil),
                                                                   NSLocalizedString(@"mcs_system_settings", nil)]];
            }
            else {
                if (self.dev.spv) {
                    if (self.app.is_vimtag) {
                        NSString *accessory_open = [[NSUserDefaults standardUserDefaults] stringForKey:@"f_exdev"];
                        if (self.dev.support_scene == 1 && (accessory_open.length > 0 || self.app.developerOption.ipcSwitch)) {
                            _settingsArray = [NSMutableArray arrayWithArray: @[NSLocalizedString(@"mcs_about", nil),
                                                                               NSLocalizedString(@"mcs_nickname", nil),
                                                                               NSLocalizedString(@"mcs_device_admin_password", nil),
                                                                               NSLocalizedString(@"mcs_device_guest_password", nil),
                                                                               NSLocalizedString(@"mcs_network", nil),
                                                                               //                                                                       NSLocalizedString(@"mcs_wifi", nil),
                                                                               NSLocalizedString(@"mcs_osd", nil),
                                                                               NSLocalizedString(@"mcs_sdcord", nil),
                                                                               NSLocalizedString(@"mcs_storage_device", nil),
                                                                               NSLocalizedString(@"mcs_scenes", nil),
                                                                               NSLocalizedString(@"mcs_accessory", nil),
                                                                               NSLocalizedString(@"mcs_record", nil),
                                                                               NSLocalizedString(@"mcs_date_time", nil),
                                                                               NSLocalizedString(@"mcs_system_settings", nil),
                                                                               NSLocalizedString(@"mcs_others", nil)]];
                        }
                        else {
                            _settingsArray = [NSMutableArray arrayWithArray: @[NSLocalizedString(@"mcs_about", nil),
                                                                               NSLocalizedString(@"mcs_nickname", nil),
                                                                               NSLocalizedString(@"mcs_device_admin_password", nil),
                                                                               NSLocalizedString(@"mcs_device_guest_password", nil),
                                                                               NSLocalizedString(@"mcs_network", nil),
                                                                               //                                                                       NSLocalizedString(@"mcs_wifi", nil),
                                                                               NSLocalizedString(@"mcs_osd", nil),
                                                                               NSLocalizedString(@"mcs_sdcord", nil),
                                                                               NSLocalizedString(@"mcs_storage_device", nil),
                                                                               NSLocalizedString(@"mcs_motion_notification", nil),
                                                                               NSLocalizedString(@"mcs_scheduled_alerting", nil),
                                                                               NSLocalizedString(@"mcs_scheduled_recording", nil),
                                                                               NSLocalizedString(@"mcs_date_time", nil),
                                                                               NSLocalizedString(@"mcs_system_settings", nil),
                                                                               NSLocalizedString(@"mcs_others", nil)]];
                            
                        }
                    }else {
                        _settingsArray = [NSMutableArray arrayWithArray: @[NSLocalizedString(@"mcs_about", nil),
                                                                           NSLocalizedString(@"mcs_nickname", nil),
                                                                           NSLocalizedString(@"mcs_device_admin_password", nil),
                                                                           NSLocalizedString(@"mcs_device_guest_password", nil),
                                                                           NSLocalizedString(@"mcs_network", nil),
                                                                           //                                                                       NSLocalizedString(@"mcs_wifi", nil),
                                                                           NSLocalizedString(@"mcs_osd", nil),
                                                                           NSLocalizedString(@"mcs_sdcord", nil),
                                                                           NSLocalizedString(@"mcs_storage_device", nil),
                                                                           NSLocalizedString(@"mcs_motion_notification", nil),
                                                                           NSLocalizedString(@"mcs_scheduled_alerting", nil),
                                                                           NSLocalizedString(@"mcs_scheduled_recording", nil),
                                                                           NSLocalizedString(@"mcs_date_time", nil),
                                                                           NSLocalizedString(@"mcs_system_settings", nil),
                                                                           NSLocalizedString(@"mcs_others", nil)]];
                        
                    }
                    
                    if ([self.dev.img_ver compare:@"v1.7.6"] ==  NSOrderedAscending)
                    {
                        [_settingsArray removeObjectAtIndex:9];
                    }
                }
                else
                {
                    _settingsArray = [NSMutableArray arrayWithArray: @[NSLocalizedString(@"mcs_about", nil),
                                                                       NSLocalizedString(@"mcs_nickname", nil),
                                                                       NSLocalizedString(@"mcs_device_admin_password", nil),
                                                                       NSLocalizedString(@"mcs_device_guest_password", nil),
                                                                       NSLocalizedString(@"mcs_network", nil),
                                                                       //                                                                       NSLocalizedString(@"mcs_wifi", nil),
                                                                       NSLocalizedString(@"mcs_osd", nil),
                                                                       NSLocalizedString(@"mcs_sdcord", nil),
                                                                       NSLocalizedString(@"mcs_motion_notification", nil),
                                                                       NSLocalizedString(@"mcs_scheduled_alerting", nil),
                                                                       NSLocalizedString(@"mcs_scheduled_recording", nil),
                                                                       NSLocalizedString(@"mcs_date_time", nil),
                                                                       NSLocalizedString(@"mcs_system_settings", nil),
                                                                       NSLocalizedString(@"mcs_others", nil)]];
                    if ([self.dev.img_ver compare:@"v1.7.6"] ==  NSOrderedAscending)
                    {
                        [_settingsArray removeObjectAtIndex:8];
                    }
                    
                    
                }
            }
        }
        
        return _settingsArray;
    }
}
- (void)initUI
{
    
    if (self.app.is_luxcam) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
//        [self.settingsArray insertObject:NSLocalizedString(@"mcs_notification_center", nil) atIndex:11];
    }
    else if (self.app.is_vimtag)
    {
        //        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"vt_navigation.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:self.app.is_ebitcam ? @"eb_navbar_bg.png" : (self.app.is_mipc ? @"mi_navbar_bg.png" : @"navbar_bg.png")] forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    [self.navigationItem.backBarButtonItem setTitle:NSLocalizedString(@"mcs_back", nil)];
    self.navigationItem.title = NSLocalizedString(@"mcs_settings", nil);
        
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
        negativeSpacer.width = -10.0;
    }
    else
    {
        negativeSpacer.width = 0.0;
    }
    
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, leftBarButtonItem] animated:YES];
    if (self.app.is_luxcam || self.app.is_vimtag)
    {
        if (!self.ver_valid) {
            mcall_ctx_upgrade_get *ctx = [[mcall_ctx_upgrade_get alloc] init];
            ctx.sn = _deviceID;
            ctx.target = self;
            ctx.on_event = @selector(upgrade_get_done:);
            
            [self.agent upgrade_get:ctx];
        }
    }
//    else
//    {
//        if (!((MNDeviceTabBarController *)self.tabBarController).ver_valid) {
//            mcall_ctx_upgrade_get *ctx = [[mcall_ctx_upgrade_get alloc] init];
//            ctx.sn = _deviceID;
//            ctx.target = self;
//            ctx.on_event = @selector(upgrade_get_done:);
//            
//            [self.agent upgrade_get:ctx];
//        }
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self initUI];

    if ([self.dev.type isEqualToString:@"BOX"])
    {
        _viewControllerKeys = [NSMutableArray arrayWithArray:@[@"MNDeviceAboutViewController",
                                                               @"MNDeviceNameSetViewController",
                                                               @"MNDevicePasswordManagerViewController",
                                                               @"MNGuestPasswordManagerViewController",
                                                               @"MNDeviceNetworkSetViewController",
//                                                               @"MNDeviceWIFISetViewController",
                                                               @"MNDeviceSDcardSetViewController",
                                                               @"MNDeviceDateSetViewController",
                                                               @"MNDeviceSystemSetViewController"]];
        
    }
    else
    {
        if (self.dev.spv) {
            
            if (self.app.is_vimtag) {
                NSString *accessory_open = [[NSUserDefaults standardUserDefaults] stringForKey:@"f_exdev"];
                if (self.dev.support_scene == 1 && (accessory_open.length > 0 || self.app.developerOption.ipcSwitch)) {
                    _viewControllerKeys = [NSMutableArray arrayWithArray:@[@"MNDeviceAboutViewController",
                                                                           @"MNDeviceNameSetViewController",
                                                                           @"MNDevicePasswordManagerViewController",
                                                                           @"MNGuestPasswordManagerViewController",
                                                                           @"MNDeviceNetworkSetViewController",
                                                                           //                                                                   @"MNDeviceWIFISetViewController",
                                                                           @"MNDeviceOSDSetViewController",
                                                                           @"MNDeviceSDcardSetViewController",
                                                                           @"MNStorageDeviceViewController",
                                                                           @"MNAccessorySceneViewController",
                                                                           @"MNDeviceAccessoryViewController",
                                                                           @"MNAccessoryVideoViewController",
                                                                           @"MNDeviceDateSetViewController",
                                                                           @"MNDeviceSystemSetViewController",
                                                                           
                                                                           @"MNDeviceOtherSetViewController"]];
                    
                }
                else {
                    
                    _viewControllerKeys = [NSMutableArray arrayWithArray:@[@"MNDeviceAboutViewController",
                                                                           @"MNDeviceNameSetViewController",
                                                                           @"MNDevicePasswordManagerViewController",
                                                                           @"MNGuestPasswordManagerViewController",
                                                                           @"MNDeviceNetworkSetViewController",
                                                                           //                                                                   @"MNDeviceWIFISetViewController",
                                                                           @"MNDeviceOSDSetViewController",
                                                                           @"MNDeviceSDcardSetViewController",
                                                                           @"MNStorageDeviceViewController",
                                                                           @"MNMotionAndNotificationsViewController",
                                                                           @"MNDevicePlanDefenceSetViewController",
                                                                           @"MNDevicePlanRecordSetViewController",
                                                                           @"MNDeviceDateSetViewController",
                                                                           @"MNDeviceSystemSetViewController",
                                                                           
                                                                           @"MNDeviceOtherSetViewController"]];
                }
            }
            else {
                _viewControllerKeys = [NSMutableArray arrayWithArray:@[@"MNDeviceAboutViewController",
                                                                       @"MNDeviceNameSetViewController",
                                                                       @"MNDevicePasswordManagerViewController",
                                                                       @"MNGuestPasswordManagerViewController",
                                                                       @"MNDeviceNetworkSetViewController",
                                                                       //                                                                   @"MNDeviceWIFISetViewController",
                                                                       @"MNDeviceOSDSetViewController",
                                                                       @"MNDeviceSDcardSetViewController",
                                                                       @"MNStorageDeviceViewController",
                                                                       @"MNMotionAndNotificationsViewController",
                                                                       @"MNDevicePlanDefenceSetViewController",
                                                                       @"MNDevicePlanRecordSetViewController",
                                                                       @"MNDeviceDateSetViewController",
                                                                       @"MNDeviceSystemSetViewController",
                                                                       
                                                                       @"MNDeviceOtherSetViewController"]];
            }

            
            if ([self.dev.img_ver compare:@"v1.7.6"] ==  NSOrderedAscending)
            {
                [_viewControllerKeys removeObjectAtIndex:9];
            }
        }
        else
        {
            _viewControllerKeys = [NSMutableArray arrayWithArray:@[@"MNDeviceAboutViewController",
                                                                   @"MNDeviceNameSetViewController",
                                                                   @"MNDevicePasswordManagerViewController",
                                                                   @"MNGuestPasswordManagerViewController",
                                                                   @"MNDeviceNetworkSetViewController",
                                                                   //                                                                   @"MNDeviceWIFISetViewController",
                                                                   @"MNDeviceOSDSetViewController",
                                                                   @"MNDeviceSDcardSetViewController",
                                                                   @"MNMotionAndNotificationsViewController",
                                                                   @"MNDevicePlanDefenceSetViewController",
                                                                   @"MNDevicePlanRecordSetViewController",
                                                                   @"MNDeviceDateSetViewController",
                                                                   @"MNDeviceSystemSetViewController",
                                                                   @"MNDeviceOtherSetViewController"]];
            if ([self.dev.img_ver compare:@"v1.7.6"] ==  NSOrderedAscending)
            {
                [_viewControllerKeys removeObjectAtIndex:8];
            }
        }

        
    }
    
    if (self.app.is_luxcam)
    {
//        [_viewControllerKeys insertObject:@"MNNotificationCenterViewController" atIndex:11];
    }
    
    _sectionNumber = (self.app.isLoginByID || self.app.isLocalDevice) ? 1 : 2;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UITableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[self.viewControllerKeys firstObject]];
        [viewController setValue:_agent forKey:@"agent"];
        [viewController setValue:_deviceID forKey:@"deviceID"];
        [viewController setValue:((UINavigationController*)self.splitViewController.viewControllers.lastObject) forKey:@"rootNavigationController"];
        
        [self.delegate setViewController:viewController];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}


- (void)back:(id)sender
{
    //FIXME:need to be 
    if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        if (nil != back) {
            back(YES);
        }
    }
    else
    {
        NSString *url = [self.app.fromTarget stringByAppendingString:@"://"];
        if (url) {
            if (!self.app.isLoginByID && ([self.app.serialNumber isEqualToString:@"(null)"] || [self.app.serialNumber isEqualToString:@""] || !self.app.serialNumber))
            {
                [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init] ;
                ctx.target = self;
                ctx.on_event = nil;
                
                [self.agent sign_out:ctx];
                self.app.is_jump = NO;
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
        else
        {
            [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        }
    }    
}

#pragma mark getCurrentRootViewController
-(UIViewController *)getCurrentRootViewController
{
    UIViewController *result;
    // Try to find the root view controller programmically
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        
        
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    }
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
    {
        result = topWindow.rootViewController;
    }
    else
        NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
    
    return result;
}

#pragma mark - Delete device
- (void)deleteDevice:(id)sender
{
    UIAlertView *deleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_delete_device", nil)
                                                              message:NSLocalizedString(@"mcs_are_you_sure_delete", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                                    otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
    deleteAlertView.tag = DELETEDEVICE;
    [deleteAlertView show];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
//    if (dev && (NSOrderedSame != [dev.status caseInsensitiveCompare:@"online"]))
//    {
//        return 1;
//    }
//    else
//    {
        return self.sectionNumber;
//    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    if (0 == section && dev && (NSOrderedSame == [dev.status caseInsensitiveCompare:@"online"])) {
        return self.settingsArray.count;
    }
    else
    {
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
   
  
    if (!self.app.is_vimtag && ((![self.dev.type isEqualToString:@"BOX"] && 0 == indexPath.section && (_viewControllerKeys.count - 2) == indexPath.row && (((MNDeviceTabBarController *)self.tabBarController).ver_valid || self.ver_valid)) ||([self.dev.type isEqualToString:@"BOX"] && 0 == indexPath.section && (_viewControllerKeys.count - 1) == indexPath.row && (((MNBoxTabBarController *)self.tabBarController).ver_valid || self.ver_valid))) )
    {

        NSString *title = [self.settingsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = title;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //get cell.textLabel.Size
        CGSize labelSize = CGSizeMake(100, 20);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
        {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
             labelSize = [cell.textLabel.text boundingRectWithSize:CGSizeMake(0, 0)
                                                             options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                          attributes:attributes
                                                             context:nil].size;
        
            labelSize.width = ceil(labelSize.width);
        }
        
        
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x + labelSize.width + 10, 13, 40, 18)];
        newLabel.backgroundColor = [UIColor redColor];
        newLabel.textColor = [UIColor whiteColor];
        newLabel.text = NSLocalizedString(@"mcs_new", nil);
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.layer.cornerRadius = 9.5f;
        newLabel.font = [UIFont systemFontOfSize:14];
        newLabel.layer.masksToBounds = YES;
        
        [cell addSubview:newLabel];
    }
    else if (self.app.is_vimtag && self.ver_valid && ((![self.dev.type isEqualToString:@"BOX"] && 0 == indexPath.section && (_viewControllerKeys.count - 2) == indexPath.row ) || ([self.dev.type isEqualToString:@"BOX"] && 0 == indexPath.section && (_viewControllerKeys.count - 1) == indexPath.row)))
    {
        NSString *title = [self.settingsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = title;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //get cell.textLabel.Size
        CGSize labelSize = CGSizeMake(100, 20);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
        {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20], NSParagraphStyleAttributeName:paragraphStyle.copy};
            
            labelSize = [cell.textLabel.text boundingRectWithSize:CGSizeMake(0, 0)
                                                          options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                       attributes:attributes
                                                          context:nil].size;
            
            labelSize.width = ceil(labelSize.width);
        }
        
        
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x + labelSize.width + 10, 13, 40, 18)];
        newLabel.backgroundColor = [UIColor redColor];
        newLabel.textColor = [UIColor whiteColor];
        newLabel.text = NSLocalizedString(@"mcs_new", nil);
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.layer.cornerRadius = 9.5f;
        newLabel.font = [UIFont systemFontOfSize:14];
        newLabel.layer.masksToBounds = YES;
        
        [cell addSubview:newLabel];
    }
    else if (0 == indexPath.section) {
        NSString *title = [self.settingsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = title;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(1 == indexPath.section)
    {
        UIButton *deleteDeviceButton = [[UIButton alloc] initWithFrame:cell.contentView.bounds];
        deleteDeviceButton.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        [deleteDeviceButton addTarget:self action:@selector(deleteDevice:) forControlEvents:UIControlEventTouchUpInside];
        [deleteDeviceButton setBackgroundColor:[UIColor redColor]];
        [deleteDeviceButton setTitle:NSLocalizedString(@"mcs_delete_device", nil) forState:UIControlStateNormal];
        deleteDeviceButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        
        [cell.contentView addSubview:deleteDeviceButton];
    }
    
    return cell;
}


#pragma mark - Table view data delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSString *viewControllerKey = [self.viewControllerKeys objectAtIndex:indexPath.row];
         UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:viewControllerKey];
        [viewController setValue:_agent forKey:@"agent"];
        [viewController setValue:_deviceID forKey:@"deviceID"];
        [viewController setValue:((UINavigationController*)self.splitViewController.viewControllers.lastObject) forKey:@"rootNavigationController"];
        
        if ([viewControllerKey isEqualToString:@"MNSceneViewController"] | [viewControllerKey isEqualToString:@"MNDeviceAccessoryViewController"] | [viewControllerKey isEqualToString:@"MNDeviceScheduleViewController"]) {
            
            [viewController setValue:self forKey:@"deviceSettingsViewController"];
        }

        if ((![self.dev.type isEqualToString:@"BOX"] && (_viewControllerKeys.count - 2) == indexPath.row) || ([self.dev.type isEqualToString:@"BOX"] && (_viewControllerKeys.count - 1) == indexPath.row))
        {
            ((MNDeviceSystemSetViewController *)viewController).ver_valid = (self.app.is_luxcam || self.app.is_vimtag)? self.ver_valid :((MNDeviceTabBarController *)self.tabBarController).ver_valid;
        }
        [self.delegate setViewController:viewController];
    }
    else
    {
        NSString *identifier = [self.viewControllerKeys objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:identifier sender:nil];
    }
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *viewController = segue.destinationViewController;
    [viewController setValue:_agent forKey:@"agent"];
    [viewController setValue:_deviceID forKey:@"deviceID"];
    [viewController setValue:self.navigationController forKey:@"rootNavigationController"];

    if (![self.dev.type isEqualToString:@"BOX"] && [segue.identifier isEqualToString:@"MNDeviceSystemSetViewController"]) {
        ((MNDeviceSystemSetViewController *)viewController).ver_valid = (self.app.is_luxcam || self.app.is_vimtag)? self.ver_valid :((MNDeviceTabBarController *)self.tabBarController).ver_valid;
    } else if ([self.dev.type isEqualToString:@"BOX"] && [segue.identifier isEqualToString:@"MNDeviceSystemSetViewController"]){
        ((MNDeviceSystemSetViewController *)viewController).ver_valid = (self.app.is_luxcam || self.app.is_vimtag)? self.ver_valid :((MNBoxTabBarController *)self.tabBarController).ver_valid;
        
    }
}

#pragma mark - Notification
- (void)deviceRestartNotification:(NSNotification*)notification
{
    if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
        if (nil != back) {
            back(NO);
        }
    }
    else
    {
        if (self.app.is_jump)
        {
            MNTransitionViewController *transitionViewController  = (MNTransitionViewController *)[self getCurrentRootViewController];
            transitionViewController.isDevicesRefresh = YES;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - dev_del_done
- (void)dev_del_done:(mcall_ret_dev_del *)ret
{
    [self loading:NO];
    if(nil == ret.result)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_success_removed_equipment", nil)
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"mcs_ok", nil) , nil];
        alertView.tag = ALERTSUCCESS;
        [alertView show];
    }
    else
    {
        
        NSString *result = [ret.result isEqualToString:@"ret.permission.denied"]? NSLocalizedString(@"mcs_permission_denied", nil) : NSLocalizedString(@"mcs_remove_equipment_failure", nil);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:result
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"mcs_ok", nil) , nil];
        alertView.tag = ALERTINFO;
        [alertView show];
    }
    
}

- (void)upgrade_get_done:(mcall_ret_upgrade_get *)ret
{
    if (ret.ver_valid && ![ret.ver_valid isEqualToString:ret.ver_current]) {
        self.ver_valid = YES;
        [self.tableView reloadData];
    }
}

#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == DELETEDEVICE)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            mcall_ctx_dev_del *ctx = [[mcall_ctx_dev_del alloc] init];
            ctx.sn = _deviceID;
            ctx.target = self;
            ctx.on_event = @selector(dev_del_done:);
            [_agent dev_del:ctx];
            [self loading:YES];
        }
    }
    
    if ([alertView tag] == ALERTSUCCESS)
    {
        [self.deviceListViewController refreshData];
        
        if (self.app.is_luxcam || self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc) {
            if (nil != back) {
                back(NO);
            }
        }
        else
        {
            if (self.app.is_jump)
            {
                MNTransitionViewController *transitionViewController  = (MNTransitionViewController *)[self getCurrentRootViewController];
                    transitionViewController.isDevicesRefresh = YES;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"DeviceRestartNotification"
                                                  object:nil];

}

@end
