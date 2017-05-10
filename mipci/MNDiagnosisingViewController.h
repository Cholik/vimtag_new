//
//  MNDiagnosisingViewController.h
//  mipci
//
//  Created by mining on 16/9/19.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNDiagnosisType) {
    MNDiagnosisLoginFail = 0,
    MNDiagnosisPlayFail = 1,
    MNDiagnosisOther = 2
};

typedef NS_ENUM(NSInteger, MNDiagnosisResult) {
    MNDiagnosisSuccess = 1,
    MNDiagnosisFailed = 2,
    MNDiagnosisContinue = 3
};

@interface MNDiagnosisingViewController : UIViewController

@property (assign, nonatomic) NSInteger typeIndex;
@property (strong, nonatomic) NSString  *diagnosisProblem;

@property (weak, nonatomic) IBOutlet UIWebView *diagnosisingWebView;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisingLabel;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisingPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelDiagnosisButton;

@end
