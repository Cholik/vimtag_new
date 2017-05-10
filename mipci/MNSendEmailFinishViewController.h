//
//  MNSendEmailFinishViewController.h
//  mipci
//
//  Created by tanjiancong on 16/9/7.
//
//

#import <UIKit/UIKit.h>

@interface MNSendEmailFinishViewController : UIViewController

@property (strong, nonatomic) NSString *emailString;
@property (weak, nonatomic) IBOutlet UILabel  *sendSuccessPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *certainButton;

@end
