//
//  MNQRCodeViewController.h
//  mipci
//
//  Created by weken on 15/4/22.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MNCameraOverlayView.h"

#import "ZBarSDK.h"
#import "MNStorageDeviceViewController.h"
#import "MNDeviceListViewController.h"

@class MNLoginViewController;
@class MNAddDeviceViewController;
@class MNDeviceListViewController;
@interface MNQRCodeViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate, ZBarReaderViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MNCameraOverlayView *cameraOverlayView;

@property (assign, nonatomic) CGSize scanMaskSize;
@property (weak, nonatomic) MNLoginViewController *loginViewController;
@property (weak, nonatomic) MNAddDeviceViewController *addDeviceViewController;
@property (weak, nonatomic) MNStorageDeviceViewController *storageDeviceViewController;
@property (weak, nonatomic) MNDeviceListViewController *deviceListViewController;

@property (weak, nonatomic) IBOutlet UIButton *imputIDBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBtn;

@property (weak, nonatomic) IBOutlet UIView *promaptView;
@property (weak, nonatomic) IBOutlet UILabel *promaptLabel;
@property (weak, nonatomic) IBOutlet UIImageView *promaptImage;


@property (weak, nonatomic) IBOutlet UIImageView *navImage;

@end
