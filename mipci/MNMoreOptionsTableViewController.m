//
//  MNMoreOptionsTableViewController.m
//  mipci
//
//  Created by mining on 16/11/16.
//
//

#define NOTIFICATION_TAG    2001
#define MYFOLDER_TAG        2002
#define LOCALDEVICE_TAG     2003
#define PASSWORD_TAG        2004
#define BINDEMAIL_TAG       2005
#define ABOUT_TAG           2006
#define EXIT_TAG            2007

#import "MNMoreOptionsTableViewController.h"

#import "AppDelegate.h"
#import "mipc_agent.h"
#import "MIPCUtils.h"

@interface MNMoreTableViewCell : UITableViewCell

- (instancetype)initWithText:(NSString *)text image:(UIImage *)image tag:(NSInteger)tag;

@end

@implementation MNMoreTableViewCell

- (instancetype)initWithText:(NSString *)text image:(UIImage *)image tag:(NSInteger)tag
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.textLabel.font = [UIFont systemFontOfSize:17.0];
        self.textLabel.text = text;
        self.imageView.image = image;
        self.tag = tag;
    }
    
    return self;
}

@end

@interface MNMoreOptionsTableViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;

@property (strong, nonatomic) NSMutableArray *relatedArray;
@property (strong, nonatomic) MNMoreTableViewCell *notificationCell;
@property (strong, nonatomic) MNMoreTableViewCell *myFolderCell;
@property (strong, nonatomic) MNMoreTableViewCell *localDeviceCell;
@property (strong, nonatomic) MNMoreTableViewCell *passwordCell;
@property (strong, nonatomic) MNMoreTableViewCell *bindEmailCell;
@property (strong, nonatomic) MNMoreTableViewCell *aboutCell;
@property (strong, nonatomic) UITableViewCell *exitCell;

@end

static NSString *CellIdentifier = @"Cell";

@implementation MNMoreOptionsTableViewController

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(mipc_agent *)agent
{
    return self.app.cloudAgent;
}

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_more_options", nil);
    
    //Init cell
    _notificationCell = [[MNMoreTableViewCell alloc] initWithText:NSLocalizedString(@"mcs_notification_center", nil) image:[UIImage imageNamed:self.app.is_mipc ? @"mi_more_notification.png" : @"eb_more_notification.png"] tag:NOTIFICATION_TAG];
    _myFolderCell = [[MNMoreTableViewCell alloc] initWithText:NSLocalizedString(@"mcs_my_folder", nil) image:[UIImage imageNamed:self.app.is_mipc ? @"mi_more_file.png" : @"eb_more_file.png"] tag:MYFOLDER_TAG];
    _localDeviceCell = [[MNMoreTableViewCell alloc] initWithText:NSLocalizedString(@"mcs_local_search", nil) image:[UIImage imageNamed:self.app.is_mipc ? @"mi_more_local.png" : @"eb_more_local.png"] tag:LOCALDEVICE_TAG];
    _passwordCell = [[MNMoreTableViewCell alloc] initWithText:NSLocalizedString(@"mcs_password_admin", nil) image:[UIImage imageNamed:self.app.is_mipc ? @"mi_more_password.png" : @"eb_more_password.png"] tag:PASSWORD_TAG];
    _bindEmailCell = [[MNMoreTableViewCell alloc] initWithText:NSLocalizedString(@"mcs_binding_email", nil) image:[UIImage imageNamed:self.app.is_mipc ? @"mi_more_email.png" : @"eb_more_email.png"] tag:BINDEMAIL_TAG];
    _aboutCell = [[MNMoreTableViewCell alloc] initWithText:NSLocalizedString(@"mcs_about", nil) image:[UIImage imageNamed:self.app.is_mipc ? @"mi_more_about.png" : @"eb_more_about.png"] tag:ABOUT_TAG];
    
    _exitLabel.text = NSLocalizedString(@"mcs_exit", nil);
    
    if (self.app.is_userOnline) {
        self.relatedArray = [NSMutableArray arrayWithArray:@[_notificationCell, _myFolderCell, _localDeviceCell, _passwordCell, _bindEmailCell, _aboutCell]];
    } else {
        self.relatedArray = [NSMutableArray arrayWithArray:@[_notificationCell, _myFolderCell, _localDeviceCell,  _aboutCell]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.relatedArray.count > 4 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.relatedArray.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = _relatedArray[indexPath.row];
    } else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        cell.tag = EXIT_TAG;
    }
    
    return cell;
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.tag == NOTIFICATION_TAG)
    {
        [self performSegueWithIdentifier:@"MNNotificationTableViewController" sender:nil];
    }
    else if (cell.tag == MYFOLDER_TAG)
    {
        [self performSegueWithIdentifier:@"MNCacheDirectoryViewController" sender:nil];
    }
    else if (cell.tag == LOCALDEVICE_TAG)
    {
        [self performSegueWithIdentifier:@"MNLocalDeviceListViewController" sender:nil];
    }
    else if (cell.tag == PASSWORD_TAG)
    {
        [self performSegueWithIdentifier:@"MNPasswordTableViewController" sender:nil];
    }
    else if (cell.tag == BINDEMAIL_TAG)
    {
        [self performSegueWithIdentifier:@"MNBindEmailViewController" sender:nil];
    }
    else if (cell.tag == ABOUT_TAG)
    {
        [self performSegueWithIdentifier:@"MNAppAboutTableViewController" sender:nil];
    }
    else if (cell.tag == EXIT_TAG)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt_exit", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) otherButtonTitles:NSLocalizedString(@"mcs_exit", nil), nil];
        alertView.tag = EXIT_TAG;
        [alertView show];
    }
}

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (alertView.tag == EXIT_TAG) {
            mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init];
            ctx.target = self;
            ctx.on_event = @selector(sign_out_done:);
            [self.agent sign_out:ctx];
            
            //flag dismiss auto login and online
            struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
            if(conf)
            {
                conf_new = *conf;
            }
            conf_new.auto_login = 0;
            MIPC_ConfigSave(&conf_new);
            self.app.is_userOnline = NO;
            
            [self.tableView reloadData];
            
            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        }
    } else {
        [self.tableView reloadData];
    }
}

-(void)sign_out_done:(mcall_ret_sign_out*)ret
{
    if (ret.result != nil) {
        return;
    }
}

#pragma mark - Rotate
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
