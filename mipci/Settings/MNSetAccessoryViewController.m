//
//  MNSetAccessoryViewController.m
//  mipci
//
//  Created by mining on 16/4/20.
//
//

#import "MNSetAccessoryViewController.h"
#import "MNToastView.h"
#import "UIViewController+loading.h"
#import "MNInfoPromptView.h"

@interface MNSetAccessoryViewController () <UIAlertViewDelegate, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UITextField *nickTextField;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *videoTextField;
@property (weak, nonatomic) IBOutlet UILabel *awayLabel;
@property (weak, nonatomic) IBOutlet UIButton *awayAlertBtn;
@property (weak, nonatomic) IBOutlet UIButton *awayVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *awayPhotoBtn;
@property (weak, nonatomic) IBOutlet UILabel *activeLabel;
@property (weak, nonatomic) IBOutlet UIButton *activeAlertBtn;
@property (weak, nonatomic) IBOutlet UIButton *activeVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *activePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (copy, nonatomic) NSString *exdevID;

@property (strong, nonatomic) NSMutableArray *exdevs;

@end

@implementation MNSetAccessoryViewController

#pragma mark - initUI
-(void)initUI
{
    _nickTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _nickTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _videoTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _videoTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_nickTextField addTarget:self action:@selector(editingDidExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_videoTextField addTarget:self action:@selector(editingDidExit:) forControlEvents:UIControlEventEditingDidEndOnExit];

    _nickTextField.placeholder = NSLocalizedString(@"mcs_input_nick", nil);
    _videoTimeLabel.text = NSLocalizedString(@"mcs_record_time", nil);

    _awayLabel.text = NSLocalizedString(@"mcs_away_home_mode", nil);
    _activeLabel.text = NSLocalizedString(@"mcs_home_mode", nil);
    [_confirmBtn setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    [_deleteBtn setTitle:NSLocalizedString(@"mcs_delete", nil) forState:UIControlStateNormal];
    
    mScene_obj *obj = _sceneArray[1];
    sceneExdev_obj *exdev = obj.exDevs[_index];
    _idLabel.text = [NSString stringWithFormat:@"ID:%@",exdev.exdev_id];
    switch (exdev.exdev_type) {
        case 5:
            _typeImageView.image = [UIImage imageNamed:@"vt_sos"];
            _typeLabel.text = NSLocalizedString(@"mcs_sos", nil);
            break;
        case 6:
            _typeImageView.image = [UIImage imageNamed:@"vt_door-lock"];
            _typeLabel.text = NSLocalizedString(@"mcs_magnetic", nil);
            break;
        default:
            _typeImageView.image = nil;
            _typeLabel.text = nil;
            break;
    }
    
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    [self initUI];

    mcall_ctx_exdev_get *ctx = [[mcall_ctx_exdev_get alloc] init];
    ctx.sn = _deviceID;
    ctx.flag = 1;
    ctx.start = 0;
    ctx.counts = 100;
    ctx.target = self;
    ctx.on_event = @selector(exdev_get_done:);
    [_agent exdev_get:ctx];
    [self loading:YES];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

- (void)editingDidExit:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)eventSet:(id)sender {
    UIButton *button = sender;
    button.selected = !button.selected;
}

- (IBAction)confirm:(id)sender
{
    
    float rtime = [self.videoTextField.text longLongValue];

    mExDev_obj *exdev = _exdevs[_index];
    exdev.outFlag =_awayAlertBtn.selected * 4 + _awayPhotoBtn.selected * 2 + _awayVideoBtn.selected;
    exdev.activeFlag = exdev.flag = _activeAlertBtn.selected * 4 + _activePhotoBtn.selected * 2 + _activeVideoBtn.selected;
    exdev.rtime = rtime * 1000;
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
}

- (IBAction)delete:(id)sender {
    UIAlertView *deleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_delete_device", nil)
        message:NSLocalizedString(@"mcs_are_you_sure_delete", nil)
        delegate:self
        cancelButtonTitle: NSLocalizedString(@"mcs_cancel", nil)
        otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
    [deleteAlertView show];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}   

#pragma mark - Call & Recall
-(void)scene_set_done:(mcall_ret_scene_set *)ret
{
    [self loading:NO];
    if (nil == ret.result)
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
        [_deviceAccessoryViewController refreshData];
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
    }
}

-(void)exdev_del_done:(mcall_ret_exdev_del *)ret
{
    if (ret.result == nil) {
        [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_delete_success", nil)]];
        [self.navigationController popToViewController:self.deviceAccessoryViewController animated:YES];
        [self.deviceAccessoryViewController refreshData];
    }else {
        [self.view addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_delete_fail", nil)]];
    }
}

-(void)exdev_get_done:(mcall_ret_exdev_get *)ret
{
    [self loading:NO];
    if (ret.result == nil) {
        self.exdevs = ret.exDevs;
        mExDev_obj *dev = ret.exDevs[_index];
        _exdevID = dev.exdev_id;
        _videoTextField.text = [NSString stringWithFormat:@"%ld",dev.rtime / 1000];
         _nickTextField.text = dev.nick;
        for (mScene_obj *obj in _sceneArray) {
            if ([obj.name isEqualToString:@"out"]) {
                sceneExdev_obj *exdev = obj.exDevs[_index];
                _awayAlertBtn.selected = (exdev.flag & 4) ? YES : NO;
                _awayPhotoBtn.selected = (exdev.flag & 2) ? YES : NO;
                _awayVideoBtn.selected = (exdev.flag & 1) ? YES : NO;
            }
            if ([obj.name isEqualToString:@"in"]) {
                sceneExdev_obj *exdev = obj.exDevs[_index];
                _activeAlertBtn.selected = (exdev.flag & 4) ? YES : NO;
                _activePhotoBtn.selected = (exdev.flag & 2) ? YES : NO;
                _activeVideoBtn.selected = (exdev.flag & 1) ? YES : NO;
            }
        }
    }
}

-(void)exdev_set_done:(mcall_ret_exdev_set *)ret
{
    [self loading:NO];
    if (nil == ret.result)
    {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
        [_deviceAccessoryViewController refreshData];
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else if ([ret.result isEqualToString:@"ret.permission.denied"])
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        else
        {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
    }
//    if (ret.result == nil) {
//        for (mScene_obj *obj in _sceneArray) {
//            if ([obj.name isEqualToString:@"out"]) {
//                mExDev_obj *exdev = obj.exDevs[_index];
//                exdev.flag = _awayAlertBtn.selected * 4 +_awayPhotoBtn .selected * 2 + _awayVideoBtn.selected;
//            }
//            if ([obj.name isEqualToString:@"in"]) {
//                mExDev_obj *exdev = obj.exDevs[_index];
//                exdev.flag = _activeAlertBtn.selected * 4 + _activePhotoBtn.selected * 2 + _activeVideoBtn.selected;
//            }
//        }
//        mcall_ctx_scene_set *ctx = [[mcall_ctx_scene_set alloc] init];
//        ctx.target = self;
//        ctx.on_event = @selector(scene_set_done:);
//        ctx.all = 0;
//        ctx.sn = _deviceID;
//        ctx.sceneArray = self.sceneArray;
//        ctx.select = self.selectScene;
//        [_agent scene_set:ctx];
//    } else {
//        [self loading:NO];
//        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
//    }
}

#pragma mark - <UITableViewDataSource>
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSString *headerTitle;
    
    switch (section) {
        case 1:
            headerTitle = NSLocalizedString(@"mcs_record", nil);
            break;
        case 2:
            headerTitle = NSLocalizedString(@"mcs_Scene_set", nil);
            break;
        default:
            break;
    }
    return headerTitle;
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else {
        return 30;
    }
}

#pragma mark - <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        mcall_ctx_exdev_del *ctx = [[mcall_ctx_exdev_del alloc] init];
        ctx.sn = _deviceID;
        ctx.exdev_id = _exdevID;
        ctx.target = self;
        ctx.on_event = @selector(exdev_del_done:);
        [_agent exdev_del:ctx];
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
