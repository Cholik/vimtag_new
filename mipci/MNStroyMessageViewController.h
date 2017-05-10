//
//  MNStroyMessageViewController.h
//  mipci
//
//  Created by mining on 15/9/14.
//
//

#import <UIKit/UIKit.h>

@interface MNStroyMessageViewController : UICollectionViewController

@property (copy, nonatomic) NSString *deviceID;

@property (weak, nonatomic) IBOutlet UIView *emptyPromptView;
@property (weak, nonatomic) IBOutlet UILabel *emptyPromptLabel;

@end
