//
//  MNDiagnosisResultViewController.m
//  mipci
//
//  Created by mining on 16/9/26.
//
//

#define DIAGNOSIS_SUCC      1
#define DIAGNOSIS_FAILED    2
#define DIAGNOSIS_CONTINUE  3

#define SEND_EMAIL_SUCC         1001
#define CONTINUE_DIAGNOSIS      1002

#import "MNDiagnosisResultViewController.h"
#import "MNDiagnosisViewController.h"
#import "MNDeviceListViewController.h"
#import "MNConfiguration.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "MIPCUtils.h"
#import "MessageUI/MFMailComposeViewController.h"
#import "MNUncaughtExceptionHandler.h"

@interface MNMailComposeViewController : MFMailComposeViewController

@end

@implementation MNMailComposeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}


#pragma mark - Rotate
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

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIApplication sharedApplication].statusBarOrientation;
    }
    else
    {
        return UIInterfaceOrientationPortrait;
    }
}

@end

@interface MNDiagnosisResultViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property(weak, nonatomic) MNConfiguration *configration;
@property(weak, nonatomic) AppDelegate *app;
@property(strong, nonatomic) UIView *promtDiagnosisView;
@property (strong, nonatomic) mipc_agent *agent;

@property (strong, nonatomic) NSTimer *timeOutTimer;
@property (assign, nonatomic) long timeCount;
@property (assign, nonatomic) BOOL is_sendBack;
@property (assign, nonatomic) BOOL is_success;

@end

@implementation MNDiagnosisResultViewController 

- (MNConfiguration *)configration
{
    if (_configration == nil) {
        _configration = [MNConfiguration shared_configuration];
    }
    return _configration;
}
- (AppDelegate *)app
{
    if (!_app) {
        _app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    return _app;
}

- (mipc_agent *)agent
{
    return self.app.cloudAgent;
}


#pragma mark - Life Cycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_diagnostic_results", nil);
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"mcs_finish", nil) style:UIBarButtonItemStylePlain target:self action:@selector(finishedDiagnosis)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"item_delete.png"] style:UIBarButtonItemStylePlain target:self action:@selector(finishedDiagnosis)];
    self.navigationItem.hidesBackButton = YES;
    
    _diagnosisSuccessResultLabel.text = NSLocalizedString(@"mcs_diagnostic_results_received", nil);
    _diagnosisSuccessPromptLabel.text = NSLocalizedString(@"mcs_diagnostic_results_prompt", nil);
    
    _diagnosisSendResultLabel.text = NSLocalizedString(@"mcs_diagnosis_connot_sent", nil);
    _diagnosisSendEmailLabel.text = NSLocalizedString(@"mcs_email_sends_prompt", nil);
    [_diagnosisSendEmailButton setTitle:NSLocalizedString(@"mcs_email_sends", nil) forState:UIControlStateNormal];
    _diagnosisSendEmailButton.layer.cornerRadius = 4.0f;
    _diagnosisSendEmailButton.backgroundColor = self.configration.switchTintColor;
    [_diagnosisSendEmailButton addTarget:self action:@selector(showSendEmailView) forControlEvents:UIControlEventTouchUpInside];
    
    _diagnosisNormalResultLabel.text = NSLocalizedString(@"mcs_results_no_abnormality", nil);
    _diagnosisDetailLabel.text = NSLocalizedString(@"mcs_no_abnormality_prompt", nil);
    [_diagnosisDetailButton setTitle:NSLocalizedString(@"mcs_continue_diagnosis", nil) forState:UIControlStateNormal];
    _diagnosisDetailButton.layer.cornerRadius = 4.0f;
    _diagnosisDetailButton.backgroundColor = self.configration.switchTintColor;
    [_diagnosisDetailButton addTarget:self action:@selector(diagnosisDetail) forControlEvents:UIControlEventTouchUpInside];
    
    if (_diagnosisResult == DIAGNOSIS_SUCC) {
        _diagnosisSuccessView.hidden = NO;
        _diagnosisSendFailView.hidden = YES;
        _diagnosisNormalView.hidden = YES;
    }
    else if (_diagnosisResult == DIAGNOSIS_FAILED){
        _diagnosisSuccessView.hidden = YES;
        _diagnosisSendFailView.hidden = NO;
        _diagnosisNormalView.hidden = YES;
    }
    else
    {
        _diagnosisSuccessView.hidden = YES;
        _diagnosisSendFailView.hidden = YES;
        _diagnosisNormalView.hidden = NO;
    }
    
    _sendReportView.hidden = !_is_detailDiagnosis;
    if (_is_detailDiagnosis) {
        _diagnosisSuccessView.hidden = YES;
        _diagnosisSendFailView.hidden = YES;
        _diagnosisNormalView.hidden = YES;
        
        _sendLabel.text = NSLocalizedString(@"mcs_send_diagnosis_results", nil);
        _sendPromptLabel.text = NSLocalizedString(@"mcs_diagnostic_results_prompt", nil);
        _sendProgressView.progress = 0;
        
        _is_sendBack = NO;
        _timeCount = 0;
        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeOutStop:) userInfo:nil repeats:YES];
        
        //send log
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"NetworkRequest/NetworkRequest.txt"]];

        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        NSString *log = [NSString stringWithContentsOfFile:filePath usedEncoding:nil error:nil];
        [fileHandle closeFile];

        mcall_ctx_log_reg *ctx = [[mcall_ctx_log_reg alloc] init];
        ctx.target = self;
        ctx.mode = [MNUncaughtExceptionHandler getCurrentDeviceModel];
        ctx.exception_name = @"ios_request_log";
        ctx.exception_reason = @"Detail diagnosis";
        ctx.call_stack = log;
        ctx.log_type = @"ios_request_log";
        ctx.on_event = @selector(log_req_send_done:);
        [self.agent log_req:ctx];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_timeOutTimer) {
        [_timeOutTimer invalidate];
        _timeOutTimer = nil;
    }
}

#pragma mark - Action
-(void)back
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)finishedDiagnosis
{
    if (_is_detailDiagnosis) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (void)diagnosisDetail
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"mcs_detail_diagnosis_prompt", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
                                              otherButtonTitles:nil];
    alertView.tag = CONTINUE_DIAGNOSIS;
    [alertView show];
}

- (void)showSendEmailView
{
    MNMailComposeViewController* mailComposeViewController = [[MNMailComposeViewController alloc] init];
    if (!mailComposeViewController) {
        return;
    }
    mailComposeViewController.mailComposeDelegate = self;
    //Add receiver
    NSArray *toRecipients = [NSArray arrayWithObject:@"vimtagservice@vimtag.com"];
    [mailComposeViewController setToRecipients: toRecipients];
    //Add title
    [mailComposeViewController setSubject:self.diagnosisProblem];
    //Add options file    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"NetworkRequest/NetworkRequest.txt"]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    NSString *log = [NSString stringWithContentsOfFile:filePath usedEncoding:nil error:nil];
    [fileHandle closeFile];
    mcall_ctx_log_reg *ctx = [[mcall_ctx_log_reg alloc] init];
    ctx.target = self;
    ctx.mode = [MNUncaughtExceptionHandler getCurrentDeviceModel];
    ctx.exception_name = @"ios_request_log";
    ctx.exception_reason = self.diagnosisProblem;
    ctx.call_stack = log;
    ctx.log_type = @"ios_request_log";
    
    NSData *pdf = [self.agent build_mining64_data:ctx];;
    [mailComposeViewController addAttachmentData: pdf mimeType: @"" fileName: @"log"];

    if ([MNMailComposeViewController canSendMail]) {
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
}

#pragma mark - Callback
-(void)log_req_send_done:(mcall_ret_log_reg *)ret
{
    if (nil == ret.result) {
        _is_success = YES;
    } else {
        _is_success = NO;
    }
    _is_sendBack = YES;
}

- (void)timeOutStop:(NSTimer *)timer
{
    if (!_timeOutTimer) {
        return;
    }
    if (_is_sendBack) {
        if (_timeOutTimer) {
            [_timeOutTimer invalidate];
            _timeOutTimer = nil;
        }
        _sendProgressView.progress = 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           _sendReportView.hidden = YES;
                           if (_is_success) {
                               _diagnosisSuccessView.hidden = NO;
                           } else {
                               _diagnosisSendFailView.hidden = NO;
                           }
                       });
    } else {
        _timeCount++;
        if (_timeCount < 8) {
            _sendProgressView.progress = ((float)_timeCount)/10;
        } else {
            _sendProgressView.progress = 0.7 + ((float)_timeCount)/400;
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    NSString *msg;
    switch (result) {
            case MFMailComposeResultCancelled:
            msg = @"E-mail send cancel";
            break;
            case MFMailComposeResultSaved:
            msg = @"E-mail save successful";
            break;
            case MFMailComposeResultSent:
            msg = @"E-mail send successful";
            break;
            case MFMailComposeResultFailed:
            msg = @"E-mail send fail";
            break;
        default:
            break;
    }
//    NSLog(@"Send result：%@", msg);
    [self dismissViewControllerAnimated:YES completion:nil];
    if (result == MFMailComposeResultSent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_mail_send", nil)
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
                                                      otherButtonTitles:nil];
            alertView.tag = SEND_EMAIL_SUCC;
            [alertView show];
        });
    }
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex)
    {
        if (alertView.tag == SEND_EMAIL_SUCC)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else if (alertView.tag == CONTINUE_DIAGNOSIS)
        {
            //Start Save Log Flag
            self.app.startSaveLog = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterDetailDiagnosis" object:@"EnterDetailDiagnosis"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Rotate
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

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIApplication sharedApplication].statusBarOrientation;
    }
    else
    {
        return UIInterfaceOrientationPortrait;
    }
}

@end
