//
//  MNNotificationTableViewController.m
//  mipci
//
//  Created by mining on 16/11/16.
//
//

#import "MNNotificationTableViewController.h"
#import "MNTimeOrRingtoneViewController.h"

#import "MNConfiguration.h"
#import "MIPCUtils.h"

@interface MNNotificationTableViewController ()

@property (weak, nonatomic) MNConfiguration *configuration;

@end

@implementation MNNotificationTableViewController

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_notification_center", nil);

    _soundLabel.text = NSLocalizedString(@"mcs_sound", nil);
    _vibration.text = NSLocalizedString(@"mcs_vibration", nil);
    _ringLabel.text = NSLocalizedString(@"mcs_notify_tone", nil);

    self.soundSwitch.onTintColor = self.configuration.switchTintColor;
    self.vibrationSwitch.onTintColor = self.configuration.switchTintColor;

    struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
    if(conf) {
        conf_new = *conf;
    }
    
    _soundSwitch.on = conf_new.dis_audio?NO:YES;
    _vibrationSwitch.on = conf_new.dis_vibrate ? NO : YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)setupSound:(id)sender
{
    struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
    if(conf)
    {
        conf_new = *conf;
    }
    conf_new.dis_audio = ((UISwitch*)sender).on?0:1;
    MIPC_ConfigSave(&conf_new);
}

- (IBAction)setupVibration:(id)sender
{
    struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
    if(conf)
    {
        conf_new = *conf;
    }
    conf_new.dis_vibrate = ((UISwitch*)sender).on?0:1;
    MIPC_ConfigSave(&conf_new);
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section && 2 == indexPath.row) {
        [self performSegueWithIdentifier:@"MNTimeOrRingtoneViewController" sender:nil];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNTimeOrRingtoneViewController"])
    {
        MNTimeOrRingtoneViewController *timeOrRingtoneViewController = segue.destinationViewController;
        timeOrRingtoneViewController.isRingtone = YES;
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
