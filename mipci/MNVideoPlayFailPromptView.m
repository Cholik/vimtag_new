//
//  MNVideoPlayFailPromptView.m
//  mipci
//
//  Created by 谢跃聪 on 17/1/7.
//
//

#define BUTTON_LENGTH       50
#define LABEL_WIDTH         300
#define LABEL_HEIGHT        40

#import "MNVideoPlayFailPromptView.h"
#import "AppDelegate.h"

@interface MNVideoPlayFailPromptView ()

@property (assign, nonatomic) MNVideoPlayFailPromptStyle videoPlayFailPromptStyle;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIButton *retryButton;
@property (strong, nonatomic) UILabel *promptLabel;

@end

@implementation MNVideoPlayFailPromptView

- (instancetype)initWithFrame:(CGRect)frame Style:(MNVideoPlayFailPromptStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        _videoPlayFailPromptStyle = style;
        [self initUI];
    }
    
    return self;
}

- (void)initUI
{
    _shadowView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _shadowView.backgroundColor = [UIColor blackColor];
    _shadowView.alpha = 0.4;
    
    _retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _retryButton.frame = CGRectMake((self.frame.origin.x - BUTTON_LENGTH)/2, (self.frame.origin.y - BUTTON_LENGTH)/2, BUTTON_LENGTH, BUTTON_LENGTH);
    [_retryButton addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.is_vimtag) {
        [_retryButton setBackgroundImage:[UIImage imageNamed:@"vt_video_refresh.png"] forState:UIControlStateNormal];
    } else if (app.is_ebitcam) {
        [_retryButton setBackgroundImage:[UIImage imageNamed:@"eb_video_refresh.png"] forState:UIControlStateNormal];
    } else {
        [_retryButton setBackgroundImage:[UIImage imageNamed:@"mi_video_refresh.png"] forState:UIControlStateNormal];
    }
    
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.origin.x - LABEL_WIDTH)/2, _retryButton.frame.origin.y+BUTTON_LENGTH, LABEL_WIDTH, LABEL_HEIGHT)];
    _promptLabel.textColor = [UIColor whiteColor];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.numberOfLines = 0;
    _promptLabel.font = [UIFont systemFontOfSize:14.0];
    if (_videoPlayFailPromptStyle == MNVideoPlayFailPromptOffline) {
        _promptLabel.text = NSLocalizedString(@"mcs_video_play_offline", nil);
    } else {
        _promptLabel.text = NSLocalizedString(@"mcs_video_play_network_fail", nil);
    }
    
    [self addSubview:_shadowView];
    [self addSubview:_retryButton];
    [self addSubview:_promptLabel];
    
    NSLayoutConstraint *shadowLeftConstraint = [NSLayoutConstraint constraintWithItem:_shadowView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *shadowRightConstraint = [NSLayoutConstraint constraintWithItem:_shadowView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *shadowTopConstraint = [NSLayoutConstraint constraintWithItem:_shadowView attribute:NSLayoutAttributeTop  relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop  multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *shadowBottomConstraint = [NSLayoutConstraint constraintWithItem:_shadowView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSArray *shadowConstraintArray = @[shadowLeftConstraint,shadowRightConstraint,shadowTopConstraint,shadowBottomConstraint];
    [self addConstraints:shadowConstraintArray];
    _shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *buttonWidthConstraint = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:BUTTON_LENGTH];
    NSLayoutConstraint *buttonHeightConstraint = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:BUTTON_LENGTH];
    
    NSLayoutConstraint *buttonCenterXConstraint = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeCenterX  relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX  multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *buttonCenterYConstraint = [NSLayoutConstraint constraintWithItem:_retryButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    NSArray *buttonConstraintArray = @[buttonWidthConstraint,buttonHeightConstraint,buttonCenterXConstraint,buttonCenterYConstraint];
    [self addConstraints:buttonConstraintArray];
    _retryButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *labelWidthConstraint = [NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0f constant:LABEL_WIDTH];
    NSLayoutConstraint *labelHeightConstraint = [NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:LABEL_HEIGHT];
    
    NSLayoutConstraint *labelCenterXConstraint = [NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeCenterX  relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX  multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *labelTopConstraint = [NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_retryButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSArray *labelConstraintArray = @[labelWidthConstraint,labelHeightConstraint,labelCenterXConstraint,labelTopConstraint];
    [self addConstraints:labelConstraintArray];
    _promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)refreshPromptTextWithStyle:(MNVideoPlayFailPromptStyle)style
{
    _videoPlayFailPromptStyle = style;

    if (_videoPlayFailPromptStyle == MNVideoPlayFailPromptOffline) {
        _promptLabel.text = NSLocalizedString(@"mcs_video_play_offline", nil);
    } else {
        _promptLabel.text = NSLocalizedString(@"mcs_video_play_network_fail", nil);
    }
}

- (void)retry
{
    [self.delegate videoReplay];
}


@end
