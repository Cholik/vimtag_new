//
//  MNCacheDirectoryViewController.h
//  mipci
//
//  Created by mining on 16/3/1.
//
//

#import <UIKit/UIKit.h>

@interface MNCacheDirectoryViewController : UIViewController

@property (assign, nonatomic) BOOL isDeleteVideo;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;

@property (weak, nonatomic) IBOutlet UIView *emptyPromptView;
@property (weak, nonatomic) IBOutlet UILabel *emptyPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionBottomConstraint;


@end
