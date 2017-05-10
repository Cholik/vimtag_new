//
//  MNAppSettingsViewController.m
//  mipci
//
//  Created by weken on 15/3/5.
//
//

#import "MNAppSettingsViewController.h"
#import "MIPCUtils.h"
#import "MNPasswordManagerViewController.h"
#import "MNTimeOrRingtoneViewController.h"
#import "mipc_agent.h"
#import "UITableViewController+loading.h"
#import "AppDelegate.h"
#import "MNToastView.h"
#import "MNMailboxBindingViewController.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"
#import "MNZipArchive.h"

#define SIGN_OUT_TAG    1001
#define CLEAN_TAG   1002

@interface MNAppSettingsViewController ()
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;
@property (strong, nonatomic) NSMutableArray *headerTitle;
@property (strong, nonatomic) NSMutableArray *relatedArray;
@property (weak, nonatomic) MNConfiguration *configuration;

@end

@implementation MNAppSettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (self.app.is_vimtag) {
            self.hidesBottomBarWhenPushed = YES;
        }
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

-(NSMutableArray *)relatedArray
{
    @synchronized(self){
        if (nil == _relatedArray) {
           if (self.app.is_vimtag) {
                _relatedArray = [NSMutableArray arrayWithArray:@[@[[NSNull null], [NSNull null], [NSNull null]],
                                                                 @[[NSNull null]],
                                                                 @[[NSNull null], [NSNull null]],
                                                                 @[[NSNull null]],
                                                                 @[[NSNull null]],
                                                                 @[[NSNull null]]]];
            } else {
                _relatedArray = [NSMutableArray arrayWithArray:@[@[[NSNull null], [NSNull null], [NSNull null]],
                                                                 @[[NSNull null]],
                                                                 @[[NSNull null], [NSNull null]],
                                                                 @[[NSNull null]],
                                                                 @[[NSNull null]],
                                                                 @[[NSNull null]]]];
            }
        }
        
        return _relatedArray;
    }
}

-(AppDelegate *)app
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

- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_settings", nil);
    
    self.soundTiteLabel.text = NSLocalizedString(@"mcs_sound", nil);
    self.vibrationTiteLabel.text = NSLocalizedString(@"mcs_vibration", nil);
    self.ringtoneTiteLabel.text = NSLocalizedString(@"mcs_notify_tone", nil);
    self.bufferTimeLabel.text = NSLocalizedString(@"mcs_buffer_time", nil);
    self.bindingEmaiLabel.text = NSLocalizedString(@"mcs_binding_email", nil);
    self.adminPasswordTiteLabel.text = NSLocalizedString(@"mcs_user_admin_password", nil);
    self.guestPasswordTiteLabel.text = NSLocalizedString(@"mcs_user_guest_password", nil);
    self.softwareVersionTiteLabel.text = NSLocalizedString(@"mcs_software_version", nil);
    [self.cleanCacheButton setTitle:NSLocalizedString(@"mcs_clear_cache", nil) forState:UIControlStateNormal];
    [self.exitButton setTitle:NSLocalizedString(@"mcs_exit", nil) forState:UIControlStateNormal];
    
    [self.cleanCacheButton setTitleColor:self.app.button_title_color forState:UIControlStateNormal];
    [self.cleanCacheButton setBackgroundColor:self.app.button_color];
    [self.exitButton setTitleColor:self.app.button_title_color forState:UIControlStateNormal];
    [self.exitButton setBackgroundColor:self.app.button_color];
    
    self.soundSwitch.onTintColor = self.configuration.switchTintColor;
    self.vibrationSwitch.onTintColor = self.configuration.switchTintColor;
    
    //Hide exit button
    [self.exitTableViewCell setHidden:YES];
    
    struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
    if(conf) {
        conf_new = *conf;
    }
    
    self.soundSwitch.on = conf_new.dis_audio?NO:YES;
    self.vibrationSwitch.on = conf_new.dis_vibrate ? NO : YES;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    if (self.app.is_vimtag) {
        self.headerTitle = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"mcs_notification_center", nil),
                                                        NSLocalizedString(@"mcs_email", nil),
                                                        NSLocalizedString(@"mcs_password", nil) ,
                                                        NSLocalizedString(@"mcs_others", nil)]];
    } else {
        self.headerTitle = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"mcs_notification_center", nil),
                                                        NSLocalizedString(@"mcs_video", nil),
                                                        NSLocalizedString(@"mcs_password", nil) ,
                                                        NSLocalizedString(@"mcs_others", nil)]];
    }
    
    if (self.app.isLoginByID) {
        if (self.app.is_vimtag) {
            [self.relatedArray removeObjectAtIndex:1];
            [self.headerTitle removeObjectAtIndex:1];
            
            [self.tableView beginUpdates];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        } else {
            [self.relatedArray removeObjectAtIndex:2];
            [self.headerTitle removeObjectAtIndex:2];
            
            [self.tableView beginUpdates];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:2];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    }
    if (self.app.is_vimtag) {
        if (self.app.is_userOnline) {
            
        } else {
            NSRange range = NSMakeRange(1, 2);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.relatedArray removeObjectsAtIndexes:indexSet];
            [self.headerTitle removeObjectsAtIndexes:indexSet];
            
            [self.tableView beginUpdates];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
//            [self.relatedArray removeObjectAtIndex:1];
//            [self.headerTitle removeObjectAtIndex:1];
//
//            [self.tableView beginUpdates];
//            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
//            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
//            [self.tableView endUpdates];
        }
    }
    
    self.softwareVersionLabel.text = [NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mark - Action
- (IBAction)setupSound:(UISwitch*)sender
{
    struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
    if(conf)
    {
        conf_new = *conf;
    }
    conf_new.dis_audio = sender.on?0:1;
    MIPC_ConfigSave(&conf_new);
    
}

- (IBAction)setupVibration:(UISwitch*)sender
{
    struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
    if(conf)
    {
        conf_new = *conf;
    }
    conf_new.dis_vibrate = sender.on?0:1;
    MIPC_ConfigSave(&conf_new);
}

- (IBAction)cleanCache:(id)sender
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)
                                                        message:NSLocalizedString(@"mcs_clear_cache_hint", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
    alertView.tag = CLEAN_TAG;
    [alertView show];
}

- (IBAction)exit:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt_exit", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil) otherButtonTitles:NSLocalizedString(@"mcs_exit", nil), nil];
    alertView.tag = SIGN_OUT_TAG;
    [alertView show];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - sign_out_done
-(void)sign_out_done:(mcall_ret_sign_out*)ret
{
    if (ret.result != nil) {
        return;
    }
    //    unsigned char encrypt_pwd[16] = {0};
    //    [mipc_agent passwd_encrypt:@"123456" encrypt_pwd:encrypt_pwd];
    ////    NSLog(@"_changedPasswordTextField.text:%@", _changedPasswordTextField.text);
    //    mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
    //    ctx.srv = @"";
    //    ctx.user = @"1jfiegbpv6fba";
    //    ctx.passwd = encrypt_pwd;
    //    ctx.target = self;
    //    ctx.on_event = @selector(sign_in_done:);
    //    ctx.token = nil;
    //    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    //    NSString *token = [user objectForKey:@"mipci_token"];
    //
    //    if(token && token.length)
    //    {
    //        ctx.token = token;
    //    }
    //
    //    [self.agent sign_in:ctx];
    [self loading:NO];
}

//- (void)sign_in_done:(mcall_ret_sign_in*)ret
//{
//    if (nil == ret.result) {
//        __weak typeof (self) weakSelf = self;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
//                                     (int64_t)(1 * NSEC_PER_SEC)),
//                       dispatch_get_main_queue(), ^{
//                           [weakSelf performSegueWithIdentifier:@"MNModifyWIFIViewController" sender:nil];
//                       });
//    }
//}

#pragma mark - Table view data source
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section < self.headerTitle.count) {
        return self.headerTitle[section];
    } else {
        return nil;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.relatedArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataArray = [self.relatedArray objectAtIndex:section];
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    
    if (self.app.is_vimtag) {
        if (self.tableView.numberOfSections == 4 && indexPath.section >= 1) {
            NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 2];
            cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
            
        } else {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
    } else {
        if (self.tableView.numberOfSections == 5 & indexPath.section >= 2) {
            NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
            cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
            
        } else {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.app.is_vimtag) {
        if (2 == indexPath.section && ![self.app isLoginByID])
        {
            [self performSegueWithIdentifier:@"MNPasswordManagerViewController" sender:[NSNumber numberWithInteger:indexPath.row]];
        } else if (1 == indexPath.section) {
            [self performSegueWithIdentifier:@"MNMailboxBindingViewController" sender:[NSNumber numberWithInteger:indexPath.section]];
        } else if (11 == indexPath.section) {
            [self performSegueWithIdentifier:@"MNTimeOrRingtoneViewController" sender:[NSNumber numberWithInteger:indexPath.section]];
        } else if (0 == indexPath.section && 2 == indexPath.row) {
            [self performSegueWithIdentifier:@"MNTimeOrRingtoneViewController" sender:[NSNumber numberWithInteger:indexPath.section]];
        }
    } else {
        if (2 == indexPath.section && ![self.app isLoginByID]) {
            [self performSegueWithIdentifier:@"MNPasswordManagerViewController" sender:[NSNumber numberWithInteger:indexPath.row]];
        } else if (1 == indexPath.section) {
            [self performSegueWithIdentifier:@"MNTimeOrRingtoneViewController" sender:[NSNumber numberWithInteger:indexPath.section]];
        } else if (3 == indexPath.section) {
            [self performSegueWithIdentifier:@"MNMailboxBindingViewController" sender:[NSNumber numberWithInteger:indexPath.section]];
        } else if (0 == indexPath.section && 2 == indexPath.row) {
            [self performSegueWithIdentifier:@"MNTimeOrRingtoneViewController" sender:[NSNumber numberWithInteger:indexPath.section]];
        }
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
            [self loading:YES];
            
            //flag dismiss auto login
            struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
            if(conf) {
                conf_new = *conf;
            }
            conf_new.auto_login = 0;
            MIPC_ConfigSave(&conf_new);
            
            [self.navigationController popToRootViewControllerAnimated:NO];
        } else if (alertView.tag == CLEAN_TAG) {
            [self loading:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == CLEAN_TAG) {
            //[self loading:YES];
            
            //Clean local entra srv
            struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
            
            if(conf && (*conf).exSrv.len)
            {
                conf_new = *conf;
                conf_new.exSrv.len = 0;
                conf_new.exSrv.data = nil;
                MIPC_ConfigSave(&conf_new);
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *tmp_photo = MIPC_GetFileFullPath(@"photos");
            
            NSError *error = nil;
            NSArray *contents = nil;
            
            contents = [fileManager contentsOfDirectoryAtPath:tmp_photo error:&error];
            for (NSString *filename in contents) {
                [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",tmp_photo,filename]  error:&error];
                if (error) {
                    NSLog(@"%@", [error localizedDescription]);
                }
            }
            
            if (self.app.is_vimtag || self.app.is_ebitcam || self.app.is_mipc)
            {
                NSString *wwwFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"wwwFilePath"];
                NSString *unzipFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"unzipFilePath"];
                [[NSFileManager defaultManager] removeItemAtPath:wwwFilePath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:unzipFilePath error:nil];
                
                NSString *sourceZipPath = [[[NSBundle mainBundle] pathsForResourcesOfType:@"zip" inDirectory:nil] firstObject];
                NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                
                wwwFilePath = [documentPath stringByAppendingPathComponent:[sourceZipPath lastPathComponent]];
                unzipFilePath = [documentPath stringByAppendingPathComponent:[[sourceZipPath lastPathComponent] stringByDeletingPathExtension]];
                [[NSFileManager defaultManager] copyItemAtPath:sourceZipPath toPath:wwwFilePath error:&error];
                
                MNZipArchive *zip = [[MNZipArchive alloc] init];
                if ([zip UnzipOpenFile:wwwFilePath])
                {
                    [zip UnzipFileTo:unzipFilePath overWrite:YES];
                    [zip UnzipCloseFile];
                }
                [[NSUserDefaults standardUserDefaults] setObject:wwwFilePath forKey:@"wwwFilePath"];
                [[NSUserDefaults standardUserDefaults] setObject:unzipFilePath forKey:@"unzipFilePath"];
                
                NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
                [[NSUserDefaults standardUserDefaults] setObject:infoDic[@"CFBundleVersion"] forKey:@"webMobileVersion"];
            }
            
            [self loading:NO];
        }
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

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNPasswordManagerViewController"]) {
        NSInteger index = [sender integerValue];
        MNPasswordManagerViewController *passwordManagerViewController = segue.destinationViewController;
        passwordManagerViewController.isAdmin = index ? NO : YES;
    } else if ([segue.identifier isEqualToString:@"MNTimeOrRingtoneViewController"]) {
        NSInteger index = [sender integerValue];
        MNTimeOrRingtoneViewController *timeOrRingtoneViewController = segue.destinationViewController;
        timeOrRingtoneViewController.isRingtone = index ? NO : YES;
    }
}



@end
