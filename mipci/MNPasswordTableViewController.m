//
//  MNPasswordTableViewController.m
//  mipci
//
//  Created by mining on 16/11/16.
//
//

#import "MNPasswordTableViewController.h"
#import "MNPasswordManagerViewController.h"

@interface MNPasswordTableViewController ()

@end

@implementation MNPasswordTableViewController

#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_admin_password", nil);
    
    _adminPasswordLabel.text = NSLocalizedString(@"mcs_user_admin_password", nil);
    _guestPasswordLabel.text = NSLocalizedString(@"mcs_user_guest_password", nil);
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

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"MNPasswordManagerViewController" sender:[NSNumber numberWithInteger:indexPath.row]];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNPasswordManagerViewController"]) {
        NSInteger index = [sender integerValue];
        MNPasswordManagerViewController *passwordManagerViewController = segue.destinationViewController;
        passwordManagerViewController.isAdmin = index ? NO : YES;
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
