//
//  MNBoxLocalRecordViewController.h
//  mipci
//
//  Created by mining on 15/11/21.
//
//

#import <UIKit/UIKit.h>

@interface MNBoxLocalRecordViewController : UICollectionViewController

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *boxID;

@property (weak, nonatomic) IBOutlet UIView *emptyPromptView;
@property (weak, nonatomic) IBOutlet UILabel *emptyPromptLabel;

@end
