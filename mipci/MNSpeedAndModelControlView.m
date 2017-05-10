//
//  MNYouBiXuanControlBoardView.m
//  mipci
//
//  Created by mining on 15/7/2.
//
//

#import "MNSpeedAndModelControlView.h"
#import "AppDelegate.h"

#define controlboard_title_width 75.f
@interface MNSpeedAndModelControlView ()
@property (strong, nonatomic) UIButton *cancleButton;
@property (strong, nonatomic) UIButton *sureButton;



@end
@implementation MNSpeedAndModelControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.5];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.f;
    }
    return self;
}

- (void)layoutSubviews
{
    [self createShowView];
}
#pragma mark -Action
- (void)dismissControlBoard:(id)sender
{
    [((UIButton *)sender).superview removeFromSuperview];
    
}

- (void)segmentModeValueChange:(id)sender
{
    _modeValue = ((UISegmentedControl *)[self viewWithTag:888]).selectedSegmentIndex;
    _valueChanged(sender, _modeValue);
}
- (void)segmentWindSpeedChange:(id)sender
{
    _windSpeedValue = ((UISegmentedControl *)[self viewWithTag:999]).selectedSegmentIndex;
    _valueChanged(sender, _windSpeedValue);
}

#pragma mark -CreateShowView
- (void)createShowView
{
    CGFloat height = 30.f;
    CGFloat width = self.frame.size.width;
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(5, 40, controlboard_title_width, height)];
    lab.text = NSLocalizedString(@"mcs_mode", nil);
    lab.backgroundColor = [UIColor clearColor];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont boldSystemFontOfSize:13];
    lab.textColor = [UIColor whiteColor];
    [self addSubview:lab];
    
    NSArray *modeName = @[NSLocalizedString(@"mcs_smart", nil), NSLocalizedString(@"mcs_plan", nil), NSLocalizedString(@"mcs_mute", nil)];
    
    UISegmentedControl *modeSegment = [[UISegmentedControl alloc] initWithItems:modeName];
    [modeSegment addTarget:self action:@selector(segmentModeValueChange:) forControlEvents:UIControlEventValueChanged];
    modeSegment.selectedSegmentIndex = _modeValue;
    modeSegment.tag = 888;
    modeSegment.frame = (CGRectMake(85, 40, width - controlboard_title_width - 15.f, height));
    [self addSubview:modeSegment];
    
    UILabel *windSpeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, height + 50, controlboard_title_width, height)];
    windSpeedLabel.text = NSLocalizedString(@"mcs_wind_speed", nil);
    windSpeedLabel.backgroundColor = [UIColor clearColor];
    windSpeedLabel.textAlignment = NSTextAlignmentCenter;
    windSpeedLabel.font = [UIFont boldSystemFontOfSize:13];
    windSpeedLabel.textColor = [UIColor whiteColor];
    [self addSubview:windSpeedLabel];
    
    
    NSArray *windSpeeds = [NSArray arrayWithObjects:NSLocalizedString(@"mcs_one", nil), NSLocalizedString(@"mcs_two", nil),
                           NSLocalizedString(@"mcs_three", nil), nil];
    UISegmentedControl *windSpeedSegment = [[UISegmentedControl alloc] initWithItems:windSpeeds];
    [windSpeedSegment addTarget:self action:@selector(segmentWindSpeedChange:) forControlEvents:UIControlEventValueChanged];
    windSpeedSegment.selectedSegmentIndex = _windSpeedValue;
    windSpeedSegment.tag = 999;
    windSpeedSegment.frame = (CGRectMake(85, 50 + height, width - controlboard_title_width - 15.f, height));
    [self addSubview:windSpeedSegment];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
