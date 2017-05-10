//
//  MNDiagnosisResultViewController.h
//  mipci
//
//  Created by mining on 16/9/26.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MNDiagnosisResultViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (assign, nonatomic) NSInteger diagnosisResult;
@property (strong, nonatomic) NSString  *diagnosisProblem;
@property (assign, nonatomic) BOOL      is_detailDiagnosis;

@property (weak, nonatomic) IBOutlet UIView *diagnosisSuccessView;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisSuccessResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisSuccessPromptLabel;

@property (weak, nonatomic) IBOutlet UIView *diagnosisSendFailView;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisSendResultLabel;
@property (weak, nonatomic) IBOutlet UIButton *diagnosisSendEmailButton;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisSendEmailLabel;

@property (weak, nonatomic) IBOutlet UIView *diagnosisNormalView;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisNormalResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisDetailLabel;
@property (weak, nonatomic) IBOutlet UIButton *diagnosisDetailButton;

@property (weak, nonatomic) IBOutlet UIView *sendReportView;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *sendProgressView;
@property (weak, nonatomic) IBOutlet UILabel *sendPromptLabel;

@end
