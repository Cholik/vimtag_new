//
//  MNSnapshotViewController.h
//  mipci
//
//  Created by mining on 13-11-25.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "mipc_agent.h"

@class MNSnapshotViewController;
@interface MNPhotoScrollView : UIScrollView<UIScrollViewDelegate>
{
@private
    BOOL       _isZoomed;
}
@property (nonatomic, strong) UIScrollView                  *scrollView;
@property (nonatomic, strong) UIImageView                   *photo;
@property (nonatomic, strong) UIActivityIndicatorView       *indicatorView;
@property (nonatomic ,assign) id                            photoView;
@end


//---------------------------------------------------------------------------------------------------------------
@interface MNSnapshotViewController : UIViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) MNPhotoScrollView    *scrollView;
@property (nonatomic, strong) mdev_msg            *msg;
@property (nonatomic, strong) NSString            *snapshotID;
@property (nonatomic, strong) mipc_agent          *agent;
@property (nonatomic, strong) UIImage             *snapshotImage;
@property (nonatomic, strong) NSString            *token;
@property (nonatomic, strong) NSString            *boxID;

- (void)singleTapView;
@end
