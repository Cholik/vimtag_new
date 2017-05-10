//
//  MNBoxListViewController.h
//  mipci
//
//  Created by weken on 15/4/7.
//
//

#import <UIKit/UIKit.h>

@interface MNBoxListViewController : UICollectionViewController

@property (copy, nonatomic) NSString *boxID;
@property (assign, nonatomic) BOOL ver_valid;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@end
