//
//  MNMoreInformationViewController.h
//  mipci
//
//  Created by mining on 15/11/6.
//
//

#import <UIKit/UIKit.h>


@interface MNMoreInformationViewController :  UITableViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) UITableViewCell   *helpViewCell;
@property (strong, nonatomic) UITableViewCell   *cacheViewCell;
@property (strong, nonatomic) UITableViewCell   *orderViewCell;
@property (strong, nonatomic) UITableViewCell   *settingViewCell;
@property (strong, nonatomic) UITableViewCell   *exitViewCell;
@property (strong, nonatomic) UITableViewCell   *localViewCell;

@property (strong, nonatomic) UITableViewCell   *feedbackCell;
@property (strong, nonatomic) UITableViewCell   *erroDiagnosisCell;

@property (assign, nonatomic) BOOL isLogin;


- (void)updateInterface;
- (void)initInterface;


@end
