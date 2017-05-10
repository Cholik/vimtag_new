//
//  MNVideoPixelsView.h
//  mipci
//
//  Created by mining on 15/9/1.
//
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "mipc_agent.h"
#import "MIPCUtils.h"
#import "UISlider+MNAddition.h"
//#import "MNdeviceSetDisplayViewController.h"

@protocol MNVideoPixelsView <NSObject>

- (void)refreshCamMessage;
- (void)closeVideoView;

@end

@interface MNVideoPixelsView : UIView

@property (nonatomic, assign) id<MNVideoPixelsView> delegate;

@property(assign) int       brightness;       /*         */
@property(assign) int       contrast;         /* 0 - 100 */
@property(assign) int       saturation;       /*         */
@property(assign) int       sharpness;        /*         */
@property(retain) NSString  *day_night;       /*auto(default),day,night*/

@property (weak, nonatomic) IBOutlet UILabel *modalTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *brightnessTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contrastTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *saturationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sharpnessTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *brightnessLabel;
@property (weak, nonatomic) IBOutlet UILabel *contrastLabel;
@property (weak, nonatomic) IBOutlet UILabel *saturationLabel;
@property (weak, nonatomic) IBOutlet UILabel *sharpnessLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modalSegment;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UISlider *contrastSlider;
@property (weak, nonatomic) IBOutlet UISlider *saturationSlider;
@property (weak, nonatomic) IBOutlet UISlider *sharpnessSlider;

@property (weak, nonatomic) IBOutlet UIView *buttonView;

@end
