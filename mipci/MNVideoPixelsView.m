//
//  MNVideoPixelsView.m
//  mipci
//
//  Created by mining on 15/9/1.
//
//

#import "MNVideoPixelsView.h"
#import "AppDelegate.h"
#import "mme_ios.h"
#import "AppDelegate.h"

@implementation MNVideoPixelsView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //[self initUI];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self initUI];
}

- (void)initUI
{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.is_ebitcam) {
        [_brightnessSlider setThumbImage:[UIImage imageNamed: @"eb_slider_orange.png"] forState:UIControlStateNormal];
        [_contrastSlider setThumbImage:[UIImage imageNamed: @"eb_slider_orange.png"] forState:UIControlStateNormal];
        [_sharpnessSlider setThumbImage:[UIImage imageNamed: @"eb_slider_orange.png"] forState:UIControlStateNormal];
        [_saturationSlider setThumbImage:[UIImage imageNamed: @"eb_slider_orange.png"] forState:UIControlStateNormal];
        [_brightnessSlider setThumbImage:[UIImage imageNamed: @"eb_slider_orange.png"] forState:UIControlStateHighlighted];
        [_contrastSlider setThumbImage:[UIImage imageNamed: @"eb_slider_orange.png"] forState:UIControlStateHighlighted];
        [_sharpnessSlider setThumbImage:[UIImage imageNamed: @"eb_slider_orange.png"] forState:UIControlStateHighlighted];
        [_saturationSlider setThumbImage:[UIImage imageNamed: @"eb_slider_orange.png"] forState:UIControlStateHighlighted];
        
        CGRect rect = [self.buttonView bounds];
        CGSize radii = CGSizeMake(6,6);
        UIRectCorner corners = UIRectCornerBottomLeft;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        shapeLayer.lineWidth = 1;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.path = path.CGPath;
        
        [self.buttonView.layer addSublayer:shapeLayer];
    } else if (app.is_mipc) {
        [_brightnessSlider setThumbImage:[UIImage imageNamed: @"mi_slider_orange.png"] forState:UIControlStateNormal];
        [_contrastSlider setThumbImage:[UIImage imageNamed: @"mi_slider_orange.png"] forState:UIControlStateNormal];
        [_sharpnessSlider setThumbImage:[UIImage imageNamed: @"mi_slider_orange.png"] forState:UIControlStateNormal];
        [_saturationSlider setThumbImage:[UIImage imageNamed: @"mi_slider_orange.png"] forState:UIControlStateNormal];
        [_brightnessSlider setThumbImage:[UIImage imageNamed: @"mi_slider_orange.png"] forState:UIControlStateHighlighted];
        [_contrastSlider setThumbImage:[UIImage imageNamed: @"mi_slider_orange.png"] forState:UIControlStateHighlighted];
        [_sharpnessSlider setThumbImage:[UIImage imageNamed: @"mi_slider_orange.png"] forState:UIControlStateHighlighted];
        [_saturationSlider setThumbImage:[UIImage imageNamed: @"mi_slider_orange.png"] forState:UIControlStateHighlighted];
        
        CGRect rect = [self.buttonView bounds];
        CGSize radii = CGSizeMake(6,6);
        UIRectCorner corners = UIRectCornerBottomLeft;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        shapeLayer.lineWidth = 1;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.path = path.CGPath;
        
        [self.buttonView.layer addSublayer:shapeLayer];
        
        _modalTitleLabel.textColor = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0];
        _brightnessTitleLabel.textColor = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0];
        _contrastTitleLabel.textColor = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0];
        _saturationTitleLabel.textColor = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0];
        _sharpnessTitleLabel.textColor = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0];

        _brightnessSlider.minimumTrackTintColor = [UIColor colorWithRed:41./255. green:136./255. blue:204./255. alpha:1.0];
        _contrastSlider.minimumTrackTintColor = [UIColor colorWithRed:41./255. green:136./255. blue:204./255. alpha:1.0];
        _saturationSlider.minimumTrackTintColor = [UIColor colorWithRed:41./255. green:136./255. blue:204./255. alpha:1.0];
        _sharpnessSlider.minimumTrackTintColor = [UIColor colorWithRed:41./255. green:136./255. blue:204./255. alpha:1.0];
        
        _brightnessSlider.maximumTrackTintColor = [UIColor colorWithRed:168./255. green:171./255. blue:178./255. alpha:1.0];
        _contrastSlider.maximumTrackTintColor = [UIColor colorWithRed:168./255. green:171./255. blue:178./255. alpha:1.0];
        _saturationSlider.maximumTrackTintColor = [UIColor colorWithRed:168./255. green:171./255. blue:178./255. alpha:1.0];
        _sharpnessSlider.maximumTrackTintColor = [UIColor colorWithRed:168./255. green:171./255. blue:178./255. alpha:1.0];

        _modalSegment.tintColor = [UIColor colorWithRed:41./255. green:136./255. blue:204./255. alpha:1.0];
        [_resetButton setTitleColor:[UIColor colorWithRed:41./255. green:136./255. blue:204./255. alpha:1.0] forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0] forState:UIControlStateNormal];
    }
    
    _sharpnessTitleLabel.text = NSLocalizedString(@"mcs_sharpness", nil);
    _saturationTitleLabel.text = NSLocalizedString(@"mcs_color_saturation", nil);
    _contrastTitleLabel.text = NSLocalizedString(@"mcs_contrast", nil);
    _brightnessTitleLabel.text = NSLocalizedString(@"mcs_brightness", nil);
    _modalTitleLabel.text = NSLocalizedString(@"mcs_mode", nil);
    
    _sharpnessLabel.text = [NSString stringWithFormat:@"%d",(int)_sharpnessSlider.value];
    _saturationLabel.text = [NSString stringWithFormat:@"%d",(int)_saturationSlider.value];
    _contrastLabel.text = [NSString stringWithFormat:@"%d",(int)_contrastSlider.value];
    _brightnessLabel.text = [NSString stringWithFormat:@"%d",(int)_brightnessSlider.value];
    
    [self.closeButton setTitle:NSLocalizedString(@"mcs_close", nil) forState:UIControlStateNormal];
    [self.resetButton setTitle:NSLocalizedString(@"mcs_reset", nil) forState:UIControlStateNormal];
    [self.modalSegment setTitle:NSLocalizedString(@"mcs_auto", nil) forSegmentAtIndex:0];
    [self.modalSegment setTitle:NSLocalizedString(@"mcs_daytime", nil) forSegmentAtIndex:1];
    [self.modalSegment setTitle:NSLocalizedString(@"mcs_night", nil) forSegmentAtIndex:2];
}

- (IBAction)setBrightnessBtn:(id)sender {
    _brightnessLabel.text = [NSString stringWithFormat:@"%d",(int)_brightnessSlider.value];
    
    [self sliderValueChange:sender];
}

- (IBAction)setContrastBtn:(id)sender {
    _contrastLabel.text = [NSString stringWithFormat:@"%d",(int)_contrastSlider.value];
    
    [self sliderValueChange:sender];
}

- (IBAction)setStaturationBtn:(id)sender {
    _saturationLabel.text = [NSString stringWithFormat:@"%d",(int)_saturationSlider.value];
    
    [self sliderValueChange:sender];
}

- (IBAction)setSharpnessBtn:(id)sender {
    _sharpnessLabel.text = [NSString stringWithFormat:@"%d",(int)_sharpnessSlider.value];
    
    [self sliderValueChange:sender];
}

- (IBAction)setModal:(id)sender {
//    NSString *modeltext;
//    switch ([sender selectedSegmentIndex]) {
//        case 0:
//            //_video_model= @"auto";
//            modeltext = @"mcs_auto";
//            break;
//        case 1:
//            //_video_model = @"day";
//            modeltext = @"mcs_daytime";
//            break;
//        case 2:
//            //_video_model = @"night";
//            modeltext = @"mcs_night";
//            break;
//        default:
//            break;
//    }
    
    
    //    [self sliderValueChange:sender];
    self.sharpness = (int)_sharpnessSlider.value;
    self.saturation = (int)_saturationSlider.value;
    self.contrast = (int)_contrastSlider.value;
    self.brightness = (int)_brightnessSlider.value;
    self.day_night = _modalSegment.selectedSegmentIndex == 0 ? @"auto": (_modalSegment.selectedSegmentIndex == 1 ?@"day" : @"night");
    [_delegate refreshCamMessage];
}

- (IBAction)setReset:(id)sender {
    _sharpnessSlider.value = 6.f;
    _saturationSlider.value = 70.f;
    _contrastSlider.value = 60.f;
    _brightnessSlider.value = 50.f;
    
    _sharpnessLabel.text = [NSString stringWithFormat:@"%d",(int)_sharpnessSlider.value];
    _saturationLabel.text = [NSString stringWithFormat:@"%d",(int)_saturationSlider.value];
    _contrastLabel.text = [NSString stringWithFormat:@"%d",(int)_contrastSlider.value];
    _brightnessLabel.text = [NSString stringWithFormat:@"%d",(int)_brightnessSlider.value];
    _modalSegment.selectedSegmentIndex = 0;
    
    [self sliderValueChange:sender];
}

- (void)sliderValueChange:(id)slider
{
    self.sharpness = (int)_sharpnessSlider.value;
    self.saturation = (int)_saturationSlider.value;
    self.contrast = (int)_contrastSlider.value;
    self.brightness = (int)_brightnessSlider.value;
    self.day_night = _modalSegment.selectedSegmentIndex == 0 ? @"auto": (_modalSegment.selectedSegmentIndex == 1 ?@"day" : @"night");
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(valueChange:) object:slider];
    [self performSelector:@selector(valueChange:) withObject:slider afterDelay:0.5f];
}

- (void)valueChange:(id)sender
{
    [_delegate refreshCamMessage];
}
- (IBAction)close:(id)sender {
    [_delegate closeVideoView];
}

@end
