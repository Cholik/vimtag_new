//
//  MNBoxPlayViewController.h
//  mipci
//
//  Created by mining on 15/10/14.
//
//

#import <UIKit/UIKit.h>
#import "MNPlayProgressView.h"

@class LocalVideoInfo;
@interface MNBoxPlayViewController : UIViewController <MNPlayProgressViewDelegate, UIAlertViewDelegate>

@property (copy, nonatomic) NSMutableArray *segmentArray;
@property (copy, nonatomic) NSString *deviceID;
@property (copy, nonatomic) NSString *boxID;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (weak, nonatomic) IBOutlet MNPlayProgressView *progressSliderView;
@property (weak, nonatomic) IBOutlet UIButton *controlButton;
@property (weak, nonatomic) IBOutlet UIView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *thumbnailTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbnailLayoutConstraint;

@property (strong, nonatomic) UIButton *playButton;
@property (nonatomic, strong) UIImageView * videoImageView;
@property (strong, nonatomic) UIImage *videoImage;

@property (strong, nonatomic) LocalVideoInfo *localVideoInfo;
@property (assign, nonatomic) int timeDifference;

@end
