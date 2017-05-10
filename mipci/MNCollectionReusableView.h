//
//  MNCollectionReusableView.h
//  mipci
//
//  Created by mining on 16/4/21.
//
//

#import <UIKit/UIKit.h>

@interface MNCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIWebView *gifWebView;
@property (strong ,nonatomic) NSData *gifData;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (strong ,nonatomic) NSData *searchGifData;
@property (weak, nonatomic) IBOutlet UIWebView *searchGifWebView;
@property (weak, nonatomic) IBOutlet UIImageView *searchImageView;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UIView *searchContainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchImgLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchGifLeading;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *staticShowView;
@property (weak, nonatomic) IBOutlet UIImageView *staticShowImage;

@property (assign, nonatomic) NSInteger type;


-(void)reviseSearchUI;
-(void)reviseUnsearchUI;
@end
