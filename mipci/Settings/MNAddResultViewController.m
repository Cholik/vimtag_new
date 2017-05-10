//
//  MNAddResultViewController.m
//  mipci
//
//  Created by PC-lizebin on 16/8/8.
//
//

#import "MNAddResultViewController.h"
#import "MNDeviceAccessoryViewController.h"
#import "MNSearchAccessoryViewController.h"

@interface MNAddResultViewController ()
@property (nonatomic,weak) MNDeviceAccessoryViewController *accessoryVc;
@property (nonatomic,weak) MNSearchAccessoryViewController *searchVc;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIView *buttonBackView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;


@end

@implementation MNAddResultViewController

-(MNDeviceAccessoryViewController *)accessoryVc
{
    if (_accessoryVc == nil) {
        for (UIViewController *vc in self.navigationController.childViewControllers ) {
            if ([vc isKindOfClass:[MNDeviceAccessoryViewController class]]) {
                _accessoryVc = (MNDeviceAccessoryViewController *)vc;
            }
        }
    }
    return _accessoryVc;
}

-(MNSearchAccessoryViewController *)searchVc
{
    if (_searchVc == nil) {
        for (UIViewController *vc in self.navigationController.childViewControllers ) {
            if ([vc isKindOfClass:[MNSearchAccessoryViewController class]]) {
                _searchVc = (MNSearchAccessoryViewController *)vc;
            }
        }
    }
    return _searchVc;
}
#pragma mark - initUI
-(void)initUI
{
    self.navigationItem.hidesBackButton = YES;
    _buttonBackView.layer.cornerRadius = 5.0;
    if (_isSuccess) {
        [self showSuccessView];
    }else {
        if (_isfailOfCanle) {
            [self showFailView:NSLocalizedString(@"mcs_add_fail1", nil)];
        }else {
            [self showFailView:NSLocalizedString(@"mcs_add_fail2", nil)];
        }
    }
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)exit:(id)sender {
    [self.navigationController popToViewController:self.accessoryVc animated:YES];
}

- (IBAction)confirmOrRetry:(id)sender {
    if ([self.confirmBtn.titleLabel.text isEqualToString:NSLocalizedString(@"mcs_ok", nil)]) {
        [self.accessoryVc refreshData];
        [self.navigationController popToViewController:self.accessoryVc animated:YES];
    }else {
        [self.navigationController popToViewController:self.searchVc animated:YES];
    }
}

-(void)showFailView:(NSString *)failText
{
    self.exitButton.hidden = NO;
    [self.exitButton setTitle:NSLocalizedString(@"mcs_action_cancel", nil) forState:UIControlStateNormal];
    [self.confirmBtn setTitle:NSLocalizedString(@"mcs_action_retry", nil) forState:UIControlStateNormal];
    self.buttonBackView.backgroundColor = [UIColor redColor];
    self.imageView.image = [UIImage imageNamed:@"vt_accessory_fail"];
    self.label.text = failText;
}

-(void)showSuccessView
{
    self.exitButton.hidden = YES;
    self.label.text = NSLocalizedString(@"mcs_add_successfully", nil);
    [self.confirmBtn setTitle:NSLocalizedString(@"mcs_ok", nil) forState:UIControlStateNormal];
}

#pragma mark - InterfaceOrientation
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
@end
