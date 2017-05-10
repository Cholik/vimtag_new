//
//  MNSetNickNameViewController.m
//  mipci
//
//  Created by PC-lizebin on 16/8/8.
//
//

#import "MNSetNickNameViewController.h"
#import "UIViewController+loading.h"
#import "MNInfoPromptView.h"
#import "MNDeviceAccessoryViewController.h"
#import "MNAddResultViewController.h"

@interface MNSetNickNameViewController ()
@property (weak, nonatomic) IBOutlet UILabel *IDLabel;
@property (weak, nonatomic) IBOutlet UITextField *nickTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIView *nickView;

@end

@implementation MNSetNickNameViewController

#pragma mark - initUI
-(void)initUI
{
    self.title = NSLocalizedString(@"mcs_set_nickname", nil);
    _IDLabel.text = _exdevID;
    self.navigationItem.hidesBackButton = YES;
    _IDLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"mcs_device", nil),_exdevID];
    _nickTextField.placeholder = NSLocalizedString(@"mcs_input_nick", nil);
    _nickView.layer.cornerRadius = 5.0;
    [_confirmButton setTitle:NSLocalizedString(@"mcs_ok", nil) forState:UIControlStateNormal];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MNInfoPromptView hideAll:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)confirm:(id)sender {
    if (_nickTextField.text.length) {
        
        mExDev_obj *exdev = _exdevs[0];
        exdev.outFlag = 7;
        exdev.activeFlag = 0;
        exdev.nick = self.nickTextField.text;
        
        mcall_ctx_exdev_set *ctx = [[mcall_ctx_exdev_set alloc] init];
        ctx.sn = _deviceID;
        ctx.exdev_id = _exdevID;
        //    ctx.nick = self.nickTextField.text;
        ctx.target = self;
        //    ctx.rtime = rtime * 1000;
        ctx.exdevs = self.exdevs;
        ctx.on_event = @selector(exdev_set_done:);
        [_agent exdev_set:ctx];
        [self loading:YES];
    }else {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_nick_not_empty", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

#pragma mark - Call & Recall
- (void)exdev_set_done:(mcall_ret_exdev_set *)ret
{
    [self loading:NO];
    if (ret.result == nil) {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
        [self performSegueWithIdentifier:@"MNAddResultViewController" sender:nil];
    }
    else {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
    }
}

#pragma mark - prepareForSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNAddResultViewController"]) {
        MNAddResultViewController *addResultViewController = segue.destinationViewController;
        addResultViewController.isSuccess = YES;
    }
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
