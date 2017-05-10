//
//  MNAppAboutTableViewController.m
//  mipci
//
//  Created by mining on 16/11/16.
//
//

#define CLEAN_TAG   1002

#import "MNAppAboutTableViewController.h"
#import "UITableViewController+loading.h"
#import "MIPCUtils.h"
#import "MNZipArchive.h"

@interface MNAppAboutTableViewController () <UIAlertViewDelegate>

@end

@implementation MNAppAboutTableViewController

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_about", nil);
    
    _versionLabel.text = [NSString stringWithFormat:@"%@:v%@", NSLocalizedString(@"mcs_software_version", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    _cleanCacheLabel.text = NSLocalizedString(@"mcs_clear_cache", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    
//    return cell;
//}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_prompt", nil)
                                                        message:NSLocalizedString(@"mcs_clear_cache_hint", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
    alertView.tag = CLEAN_TAG;
    [alertView show];
}

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView reloadData];
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (alertView.tag == CLEAN_TAG)
        {
            [self loading:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (alertView.tag == CLEAN_TAG)
        {
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

@end
