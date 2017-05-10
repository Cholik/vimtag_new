//
//  MNPasswordManagerViewController.m
//  mipci
//
//  Created by weken on 15/3/10.
//
//

#import "MNPasswordManagerViewController.h"
#import "UITableViewController+loading.h"
#import "MNToastView.h"
#import "AppDelegate.h"
#import "MIPCUtils.h"
#import "MNInfoPromptView.h"
#import "mipc_agent.h"

@interface MNPasswordManagerViewController ()
{
    unsigned char  _new_encrypt_pwd[16];
}
@property (assign, nonatomic) BOOL isViewAppearing;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) mipc_agent *agent;

@end

@implementation MNPasswordManagerViewController

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(mipc_agent *)agent
{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return app.cloudAgent;
}

- (void)initUI
{
    if (_isAdmin) {
        self.navigationItem.title = NSLocalizedString(@"mcs_user_admin_password", nil);

        //code for color
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [_commitButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
        [_commitButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
        [_commitButton setBackgroundColor:app.button_color];
        
        _currentPasswordHintLabel.text = NSLocalizedString(@"mcs_old_password", nil);
        _changePasswordHintLabel.text = NSLocalizedString(@"mcs_new_password", nil);
        _commitPasswordHintLabel.text = NSLocalizedString(@"mcs_confirm_password", nil);

        _currentPasswordTextField.placeholder = NSLocalizedString(@"mcs_input_password" , nil);
        _changePasswordTextField.placeholder = NSLocalizedString(@"mcs_input_new_pass", nil);
        _commitPasswordTextField.placeholder = NSLocalizedString(@"mcs_confirm_password", nil);

    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"mcs_user_guest_password", nil);

        //code for color
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [_commitButton setTitle:NSLocalizedString(@"mcs_apply", nil) forState:UIControlStateNormal];
        [_commitButton setTitleColor:app.button_title_color forState:UIControlStateNormal];
        [_commitButton setBackgroundColor:app.button_color];
        
        _currentPasswordHintLabel.text = NSLocalizedString(@"mcs_admin_password", nil);
        _changePasswordHintLabel.text = NSLocalizedString(@"mcs_guest_password", nil);
        _commitPasswordHintLabel.text = NSLocalizedString(@"mcs_confirm_password", nil);

        _currentPasswordTextField.placeholder = NSLocalizedString(@"mcs_input_password" , nil);
        _changePasswordTextField.placeholder = NSLocalizedString(@"mcs_guest_password", nil);
        _commitPasswordTextField.placeholder = NSLocalizedString(@"mcs_input_confirm_password", nil);

    }
}

#pragma mark - View lifeCycle
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MNInfoPromptView hideAll:self.navigationController];
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
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer*)gesturenizer
{
    [[UIApplication sharedApplication] resignFirstResponder];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)apply:(id)sender
{
    if (self.app.is_InfoPrompt) {
        [MNInfoPromptView hideAll:self.navigationController];
    }
    if ( nil == _currentPasswordTextField.text
        || nil == _changePasswordTextField.text
        || 0 == _currentPasswordTextField.text.length
        || 0 == _changePasswordTextField.text.length)
    {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_blank_password", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_blank_password", nil)]];
        }
        return;
    }

    if (![_changePasswordTextField.text isEqualToString:_commitPasswordTextField.text]) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_two_password_input_inconsistent", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_two_password_input_inconsistent", nil)]];
        }
        return;
    }

    if (_changePasswordTextField.text.length < 6 || _changePasswordTextField.text.length > 32) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_password_range_hint", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_password_range_hint", nil)]];
        }
        return;
    }

    mcall_ctx_account_passwd_set *ctx = [[mcall_ctx_account_passwd_set alloc] init];
    ctx.sn = _deviceID;
    unsigned char  *_new_pwd = malloc(16), *_old_pwd = malloc(16);
    [mipc_agent passwd_encrypt:_changePasswordTextField.text encrypt_pwd:_new_pwd];
    [mipc_agent passwd_encrypt:_currentPasswordTextField.text encrypt_pwd:_old_pwd];
    ctx.on_event = @selector(account_passwd_set_done:);
    ctx.target = self;
    ctx.new_encrypt_pwd = _new_pwd;
    ctx.old_encrypt_pwd = _old_pwd;
    ctx.is_guest = !_isAdmin;

    [self.agent account_passwd_set:ctx];
    [self loading:YES];
    

    [[NSUserDefaults standardUserDefaults] setObject:_changePasswordTextField.text forKey:@"password"];
    

}


#pragma mark - Netword Callback
- (void)account_passwd_set_done:(mcall_ret_account_passwd_set *)ret
{
    if (!_isViewAppearing) {
        [self loading:NO];
        return;
    }

    if(nil == ret.result)
    {
        if (_isAdmin) {
            [mipc_agent passwd_encrypt:_changePasswordTextField.text encrypt_pwd:_new_encrypt_pwd];
            struct mipci_conf   *conf = MIPC_ConfigLoad(), conf_new = {0};
            
            if(conf)
            {
                conf_new        = *conf;
            }
            if (conf->password_md5.len) {
                conf_new.password_md5.data = (char*)_new_encrypt_pwd;
                conf_new.password_md5.len = 16;
                MIPC_ConfigSave(&conf_new);
            }
           
            mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc]init];
            ctx.srv = nil;
            ctx.user = [NSString stringWithUTF8String:
                        conf_new.user.data];
            ctx.passwd = _new_encrypt_pwd;
            ctx.target = self;
            ctx.on_event = @selector(sign_in_done:);

            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSString *token = [user objectForKey:@"mipci_token"];

            if(token && token.length)
            {
                ctx.token = token;
            }
            [self.agent sign_in:ctx];      
        }
        else
        {
             [self loading:NO];
            if (self.app.is_InfoPrompt) {
                [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_state_modify_pass_success", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
            } else {
                [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_state_modify_pass_success", nil)]];
            }
        }
    }
    else if ([ret.result isEqualToString:@"ret.permission.denied"])
    {
        [self loading:NO];
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_permission_denied", nil)]];
        }
    }
    else if([ret.result isEqualToString:@"ret.pwd.invalid"])
    {
        [self loading:NO];
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_invalid_password", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_invalid_password", nil)]];
        }
    }
    else
    {
        [self loading:NO];
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_state_modify_pass_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_state_modify_pass_fail", nil)]];
        }
    }

}

- (void)sign_in_done:(mcall_ret_sign_in*)ret
{
    [self loading:NO];
    if (nil == ret.result) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_state_modify_pass_success", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_state_modify_pass_success", nil)]];
        }
    } else {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_state_modify_pass_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_state_modify_pass_fail", nil)]];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
