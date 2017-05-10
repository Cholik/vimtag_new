//
//  MNCacheVideoViewController.h
//  mipci
//
//  Created by mining on 16/2/25.
//
//

#import <UIKit/UIKit.h>
#import "MNCacheDirectoryViewController.h"

@interface MNCacheVideoViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (assign, nonatomic) BOOL      isBox;
@property (strong, nonatomic) NSString *directoryId;
@property (strong, nonatomic) MNCacheDirectoryViewController *cacheDirectoryViewController;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;

@property (weak, nonatomic) IBOutlet UIView *emptyPromptView;
@property (weak, nonatomic) IBOutlet UILabel *emptyPromptLabel;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionBottomConstraint;

@end
