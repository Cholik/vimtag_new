//
//  MNStorageDeviceViewController.m
//  mipci
//
//  Created by weken on 15/5/12.
//
//

#import "MNStorageDeviceViewController.h"
#import "MNToastView.h"
#import "UITableViewController+loading.h"
#import "AppDelegate.h"
#import "MNQRCodeViewController.h"
#import "MNConfiguration.h"
#import "MNInfoPromptView.h"

@interface MNStorageDeviceViewController ()

@property (nonatomic, strong) NSMutableArray *relatedArray;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNStorageDeviceViewController

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = NSLocalizedString(@"mcs_storage_device", nil);
    }
    
    return self;
}

- (void)initUI
{
    _enableTintLabel.text = NSLocalizedString(@"mcs_enabled", nil);
    _deviceIDTintLabel.text = NSLocalizedString(@"mcs_device_id", nil);
    _passwordTintLabel.text = NSLocalizedString(@"mcs_password", nil);
    
    _deviceIDTextField.placeholder = NSLocalizedString(@"mcs_input_device_id", nil);
    _passwordTextField.placeholder = NSLocalizedString(@"mcs_input_password", nil);
    _connectStateTintLabel.text = NSLocalizedString(@"mcs_network_status", nil);
    [_applyButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
    
    //code for color
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_applyButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
    [_applyButton setBackgroundColor:app.button_color];
    
    _enableSwitch.onTintColor = self.configuration.switchTintColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    //keyboard dismiss style
    if ([self.tableView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        [self.tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    }
    else
    {
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self.tableView addGestureRecognizer:singleTapGestureRecognizer];
    }
    
    
    _relatedArray = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null]]],
                                                     [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null], [NSNull null]]],
                                                     
                                                     [NSMutableArray arrayWithArray:@[[NSNull null]]]]];
    if (_isViewAppearing ) {
        
    } else {
        _isViewAppearing = YES;
        
        mcall_ctx_box_conf_get *ctx = [[mcall_ctx_box_conf_get alloc] init];
        ctx.sn = _deviceID;
        ctx.target = self;
        ctx.on_event = @selector(box_conf_get_done:);
        
        [_agent box_conf_get:ctx];
        [self loading:YES];
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MNInfoPromptView hideAll:_rootNavigationController];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Hide
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer*)gesturenizer
{
    [[UIApplication sharedApplication] resignFirstResponder];
}

#pragma mark - Action
- (IBAction)apply:(id)sender {
    mcall_ctx_box_login *ctx = [[mcall_ctx_box_login alloc] init];
    if (_enableSwitch.on && !_deviceIDTextField.text.length) {
        ctx.enable = NO;
        ctx.username = _deviceIDTextField.text;
        ctx.password = _passwordTextField.text;
    } else {
        ctx.enable = _enableSwitch.on;
        ctx.username = _deviceIDTextField.text;
        ctx.password = _passwordTextField.text;
    }
    
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(box_login_done:);
    
    [_agent box_login:ctx];
    [self loading:YES];
}

- (IBAction)switchChange:(id)sender {
    NSRange range = NSMakeRange(1, 1);
    if(_enableSwitch.on){
        NSMutableArray *datas = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null], [NSNull null]]]]];
                                 
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [_relatedArray insertObjects:datas atIndexes:indexSet];
        [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    } else{
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [_relatedArray removeObjectsAtIndexes:indexSet];
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView reloadData];
}

#pragma for qrcode
- (IBAction)onQRCodeBtn:(id)sender
{
//    if ([self checkCamera])
//    {
    
        [self performSegueWithIdentifier:@"MNQRCodeViewController" sender:nil];
//    }
}

- (IBAction)editingDidExit:(id)sender
{
    [sender resignFirstResponder];
}

//- (BOOL)checkCamera
//{
//    NSError *error = nil;
//    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
//    if(nil == videoInput)
//    {
//        if(error.code == -11852)
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_please_allow_access_camera", nil) message:NSLocalizedString(@"mcs_ios_privacy_setting_for_camera_prompt", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil) otherButtonTitles: nil];
//            [alert show];
//        }
//        return NO;
//    }
//    return YES;
//}

- (void)checkStorageDeviceStatus
{
    mcall_ctx_box_conf_get *ctx = [[mcall_ctx_box_conf_get alloc] init];
    ctx.sn = _deviceID;
    ctx.target = self;
    ctx.on_event = @selector(box_conf_get_status_done:);
    
    [_agent box_conf_get:ctx];
}

#pragma mark - Network Callback

-(void)box_conf_get_done:(mcall_ret_box_conf_get*)ret
{
    if (!_isViewAppearing) {
        return;
    }
    
    [self loading:NO];
    
    if (nil == ret.result) {
        _enableSwitch.on = ret.box_conf.enable;
        _passwordTextField.text = ret.box_conf.password;
         _deviceIDTextField.text = ret.box_conf.username;
        if (_enableSwitch.on) {
            _relatedArray = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null]]],
                                                             [NSMutableArray arrayWithArray:@[[NSNull null], [NSNull null], [NSNull null]]],
                                                             
                                                             [NSMutableArray arrayWithArray:@[[NSNull null]]]]];
        } else {
                _relatedArray = [NSMutableArray arrayWithArray:@[[NSMutableArray arrayWithArray:@[[NSNull null]]],
            
                                   [NSMutableArray arrayWithArray:@[[NSNull null]]]]];
            
        }
        [self.tableView reloadData];
        if (ret.connect) {
            _connectStateShowLabel.text = NSLocalizedString(@"mcs_connnected", nil);
        } else {
            _connectStateShowLabel.text = NSLocalizedString(@"mcs_not_connected", nil);
        }
    }
    else
    {
        if ([ret.result isEqualToString:@"ret.dev.offline"]) {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_device_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_device_offline",nil)]];
            }
        }
        else if ([ret.result isEqualToString:@"ret.pwd.invalid"])
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_expired", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_password_expired",nil)]];
            }
        }
        else
        {
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
            } else {
                [self.view addSubview:[MNToastView failToast:nil]];
            }
        }
    }
}

-(void)box_conf_get_status_done:(mcall_ret_box_conf_get*)ret
{
    if (!_isViewAppearing) {
        return;
    }
    
//    [self loading:NO];
    
    if (nil == ret.result) {
        if (ret.connect) {
            _connectStateShowLabel.text = NSLocalizedString(@"mcs_connnected", nil);
            return;
        }
    }
    
    [self performSelector:@selector(checkStorageDeviceStatus) withObject:nil afterDelay:3.0];
}

-(void)box_login_done:(mcall_ret_box_login*)ret
{
    if (!_isViewAppearing) {
        return;
    }
    
    [self loading:NO];
    
    if (nil == ret.result)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_set_successfully", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_set_successfully", nil)]];
        }
        [self performSelector:@selector(checkStorageDeviceStatus) withObject:nil afterDelay:1.0];
    } else if ([ret.result isEqualToString:@"ret.user.unknown"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_dev", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_invalid_user", nil)]];
        }
    } else if([ret.result isEqualToString:@"ret.dev.offline"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_offline", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_offline", nil)]];
        }
    } else if([ret.result isEqualToString:@"ret.pwd.invalid"])
    {
        NSLog(@"ret.pwd.invalid");
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_password", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_invalid_password", nil)]];
        }
    }
    else if([ret.result isEqualToString:@"ret.permission.denied"])
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView promptToast:NSLocalizedString(@"mcs_permission_denied", nil)]];
        }
    }
    else
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_failed_to_set_the", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:_rootNavigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_failed_to_set_the", nil)]];
        }
    }
}

#pragma mark -tableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray *)self.relatedArray[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.tableView.numberOfSections == 2 && indexPath.section == 1) {
        NSIndexPath *otherIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+1];
        cell = [super tableView:tableView cellForRowAtIndexPath:otherIndexPath];
    }else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.relatedArray.count;
}

#pragma mark -prepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNQRCodeViewController"]) {
        MNQRCodeViewController *QRCodeViewController = segue.destinationViewController;
        QRCodeViewController.storageDeviceViewController = self;
        
    }
}


@end
