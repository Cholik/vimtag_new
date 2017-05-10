//
//  MNMoreInformationViewController.m
//  mipci
//
//  Created by mining on 15/11/6.
//
//

#define SIGN_OUT_TAG    1001
#define STOP_DIAGNOSIS_TAG  1002

#define HELP_TAG        2001
#define CACH_TAG        2002
#define LOCAL_TAG       2003
#define FEEDBACK_TAG    2004
#define DIAGNOSIS_TAG   2005
#define SETTING_TAg     2006
#define EXIT_TAG        2007
#define ORDER_TAG       2008


#import "MNMoreInformationViewController.h"
#import "UITableViewController+loading.h"
#import "AppDelegate.h"
#import "MIPCUtils.h"
#import "mipc_agent.h"
#import "MNDeviceListViewController.h"
#import "MNDeviceListSetViewController.h"
#import "MNLocalDeviceListViewController.h"
#import "MNMyOrderViewController.h"
#import "MNDeveloperOption.h"

@interface MNMoreInformationViewController ()

@property (strong, nonatomic) NSMutableArray *relatedArray;
@property (strong, nonatomic) mipc_agent *agent;
@property (assign, nonatomic) BOOL  isHideNav;
@property (weak, nonatomic) AppDelegate *app;
@property (weak, nonatomic) MNDeveloperOption  *developerOption;


@end

static NSString *CellIdentifier = @"Cell";

@implementation MNMoreInformationViewController

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

- (MNDeveloperOption *)developerOption
{
    if (nil == _developerOption) {
        _developerOption = [MNDeveloperOption shared_developerOption];
    }
    return _developerOption;
}

- (NSMutableArray *)relatedArray
{
    @synchronized(self){
        if (nil == _relatedArray) {
            _relatedArray = [NSMutableArray arrayWithArray:@[_cacheViewCell,_localViewCell,_settingViewCell, _exitViewCell]];
        }
        return _relatedArray;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"mcs_my",nil) image:[UIImage imageNamed:@"vt_myself_idle"] tag:1];
        self.navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"vt_myself"];
    }
    
    return self;
}

#pragma mark - View lifecycle
- (void)initUI
{
    //init cell
    _helpViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    _helpViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _helpViewCell.textLabel.font = [UIFont systemFontOfSize:17.0];
    _helpViewCell.textLabel.text = NSLocalizedString(@"mcs_help_feedback", nil);
    _helpViewCell.imageView.image = [UIImage imageNamed:@"vt_Help-and-consultation"];
    _helpViewCell.tag = HELP_TAG;
    
    _settingViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    _settingViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _settingViewCell.textLabel.font = [UIFont systemFontOfSize:17.0];
    _settingViewCell.textLabel.text = NSLocalizedString(@"mcs_settings", nil);
    _settingViewCell.imageView.image = [UIImage imageNamed:@"vt_Set-up-the"];
    _settingViewCell.tag = SETTING_TAg;
    
    _exitViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    _exitViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _exitViewCell.textLabel.font = [UIFont systemFontOfSize:17.0];
    _exitViewCell.textLabel.text = NSLocalizedString(@"mcs_exit", nil);
    _exitViewCell.imageView.image = [UIImage imageNamed:@"vt_exit"];
    _exitViewCell.tag = EXIT_TAG;
    
    _cacheViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    _cacheViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _cacheViewCell.textLabel.font = [UIFont systemFontOfSize:17.0];
    _cacheViewCell.textLabel.text = NSLocalizedString(@"mcs_my_folder", nil);
    _cacheViewCell.imageView.image = [UIImage imageNamed:@"vt_my_Download"];
    _cacheViewCell.tag = CACH_TAG;
    
    _orderViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    _orderViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _orderViewCell.textLabel.font = [UIFont systemFontOfSize:17.0];
    _orderViewCell.textLabel.text = NSLocalizedString(@"mcs_my_order", nil);
    _orderViewCell.imageView.image = [UIImage imageNamed:@"My_order"];
    _orderViewCell.tag = ORDER_TAG;
    
    _localViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    _localViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _localViewCell.textLabel.font = [UIFont systemFontOfSize:17.0];
    _localViewCell.textLabel.text = NSLocalizedString(@"mcs_local_search", nil);
    _localViewCell.imageView.image = [UIImage imageNamed:@"vt_Local"];
    _localViewCell.tag = LOCAL_TAG;
    
    _feedbackCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    _feedbackCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _feedbackCell.textLabel.font = [UIFont systemFontOfSize:17.0];
    _feedbackCell.textLabel.text = NSLocalizedString(@"mcs_feedback", nil);
    _feedbackCell.imageView.image = [UIImage imageNamed:@"feedback"];
    _feedbackCell.tag = FEEDBACK_TAG;
    
    _erroDiagnosisCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    _erroDiagnosisCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _erroDiagnosisCell.textLabel.font = [UIFont systemFontOfSize:17.0];
    _erroDiagnosisCell.textLabel.text = NSLocalizedString(@"mcs_fault_diagnosis", nil);
    _erroDiagnosisCell.imageView.image = [UIImage imageNamed:@"vt_diagnosis"];
    _erroDiagnosisCell.tag = DIAGNOSIS_TAG;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    _isHideNav = YES;
    if (self.app.is_userOnline) {
        [self updateInterface];
    } else {
        [self initInterface];
    }
    self.app.isLocalDevice = NO;
    
    [self reloadInterface];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_isHideNav) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -reload interface
-(void)reloadInterface
{
    NSString *f_log = [[NSUserDefaults standardUserDefaults] stringForKey:@"f_log"];
    NSString *f_ticket = [[NSUserDefaults standardUserDefaults] stringForKey:@"f_ticket"];
    NSString *faq_url = [[NSUserDefaults standardUserDefaults] stringForKey:@"faq_url"];
    NSString *f_mall = [[NSUserDefaults standardUserDefaults] stringForKey:@"f_mall"];
    
    _relatedArray = [NSMutableArray arrayWithArray:@[_cacheViewCell,_localViewCell,_settingViewCell, _exitViewCell]];
    
    if (self.app.is_userOnline && f_mall.length) {
        [_relatedArray insertObject:_orderViewCell atIndex:0];
    }
    if (faq_url.length) {
        [_relatedArray insertObject:_helpViewCell atIndex:_relatedArray.count - 2];
    }
    if (f_ticket.length) {
        [_relatedArray insertObject:_feedbackCell atIndex:_relatedArray.count - 2];
    }
    if (f_log.length) {
        [_relatedArray insertObject:_erroDiagnosisCell atIndex:_relatedArray.count - 2];
    }

    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)toLoginInterface:(id)sender
{
    if (self.app.is_userOnline) {
        if (_exitViewCell.hidden) {
            [self updateInterface];
        }
    }
    else
    {
        [self performSegueWithIdentifier:@"MNLoginViewController" sender:nil];
        _isHideNav = NO;
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

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.relatedArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // NSArray *dataArray = [self.relatedArray objectAtIndex:section];
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = _relatedArray[indexPath.section];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.tag == HELP_TAG)
    {
        [self performSegueWithIdentifier:@"MNFAQViewController" sender:nil];
    }
    else if (cell.tag == CACH_TAG)
    {
        [self performSegueWithIdentifier:@"MNCacheDirectoryViewController" sender:nil];
    }
    else if (cell.tag == LOCAL_TAG)
    {
        [self performSegueWithIdentifier:@"MNLocalDeviceListViewController" sender:nil];
    }
    else if(cell.tag == FEEDBACK_TAG){
        [self performSegueWithIdentifier:@"MNFeedbackViewController" sender:nil];
    }
    else if (cell.tag == DIAGNOSIS_TAG){
        if (self.app.startSaveLog) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_exit_detail_diagnosis", nil)
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"mcs_no_verif", nil)
                                                      otherButtonTitles:NSLocalizedString(@"mcs_yes_verif", nil), nil];
            alertView.tag = STOP_DIAGNOSIS_TAG;
            [alertView show];
        } else {
            [self performSegueWithIdentifier:@"MNDiagnosisViewController" sender:nil];
        }
    }
    else if (cell.tag == SETTING_TAg)
    {
        [self performSegueWithIdentifier:@"MNAppSettingsViewController" sender:nil];
    }
    else if (cell.tag == ORDER_TAG)
    {
        [self performSegueWithIdentifier:@"MNMyOrderViewController" sender:nil];
        
    }
    else if (cell.tag == EXIT_TAG)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt_exit", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) otherButtonTitles:NSLocalizedString(@"mcs_exit", nil), nil];
        alertView.tag = SIGN_OUT_TAG;
        [alertView show];
    }
}

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (alertView.tag == SIGN_OUT_TAG) {
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
            [self initInterface];
            [self reloadInterface];

            UITabBarController *rootTabBarController = self.tabBarController;
            for (UINavigationController *navigationController in rootTabBarController.viewControllers) {
                for (UIViewController *viewController in navigationController.viewControllers) {
                    if ([viewController isMemberOfClass:[MNDeviceListSetViewController class]]) {
                        MNDeviceListSetViewController *deviceListSetViewController= (MNDeviceListSetViewController*)viewController;
                        [deviceListSetViewController checkUserOnlie];
                        MNDeviceListViewController *deviceListViewController= ((MNDeviceListSetViewController*)viewController).deviceListViewController;
                        if ([deviceListViewController isKindOfClass:[MNDeviceListViewController class]]) {
                            [deviceListViewController removeAllData];
                        }
                    }
                }
            }
        }
        else if (alertView.tag == STOP_DIAGNOSIS_TAG)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterDetailDiagnosis" object:@"StopDetailDiagnosis"];
            [self.tableView reloadData];
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

#pragma mark - Update & Hide Interface
- (void)updateInterface
{
    _loginButton.selected = YES;
//    [_loginButton setImage:[UIImage imageNamed:@"vt_logo_icon"] forState:UIControlStateNormal];
    _userNameLabel.text = self.agent.user;
    _exitViewCell.hidden = NO;
    
    [self.tableView reloadData];
}

- (void)initInterface
{
    _loginButton.selected = NO;
//    [_loginButton setImage:[UIImage imageNamed:@"vt_logo_icon_idle"] forState:UIControlStateNormal];
    _userNameLabel.text = NSLocalizedString(@"mcs_click_login", nil);
    _exitViewCell.hidden = YES;
    
    [self.tableView reloadData];
}

@end
