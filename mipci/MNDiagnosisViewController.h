//
//  MNDiagnosisViewController.h
//  mipci
//
//  Created by mining on 16/7/28.
//
//

#import <UIKit/UIKit.h>

@interface MNDiagnosisViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *diagnosisTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectProblemLabel;

@property (weak, nonatomic) IBOutlet UIView *problemView;

@property (weak, nonatomic) IBOutlet UIView *unableLoginView;
@property (weak, nonatomic) IBOutlet UILabel *unableLoginLabel;
@property (weak, nonatomic) IBOutlet UIButton *unableLoginButton;

@property (weak, nonatomic) IBOutlet UIView *unablePlayView;
@property (weak, nonatomic) IBOutlet UILabel *unablePlayLabel;
@property (weak, nonatomic) IBOutlet UIButton *unablePlayButton;

@property (weak, nonatomic) IBOutlet UIView *otherView;
@property (weak, nonatomic) IBOutlet UILabel *otherLabel;
@property (weak, nonatomic) IBOutlet UIButton *otherButton;

@property (weak, nonatomic) IBOutlet UIView *otherProblemView;
@property (weak, nonatomic) IBOutlet UILabel *otherProblemTitle;
@property (weak, nonatomic) IBOutlet UITextField *otherProblemText;

@property (weak, nonatomic) IBOutlet UIButton *diagnosisButton;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisLabel;

@end
