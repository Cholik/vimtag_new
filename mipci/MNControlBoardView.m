//
//  MNControlBoardView.m
//  mipci
//
//  Created by weken on 15/4/13.
//
//

#import "MNControlBoardView.h"
#import "MIPCUtils.h"
#import "AppDelegate.h"

#define wifiboard_title_widht  75.f
#define PROFILE_ID_MAX 2
#define CANCELBUTTON_INDEX 0
#define SUREBUTTON_INDEX 1
#define SHARPNESS_TAG 1001
#define PRESETPOINT_TAG 1002
#define controlboard_title_widht  75.f

@interface MNControlBoardView()
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIButton *currentButton;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *sureButton;

@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNControlBoardView

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.5];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.f;
        
        if (self.app.is_luxcam) {
            UIButton *sharpnessButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 46, 30)];
            sharpnessButton.tag = SHARPNESS_TAG;
            sharpnessButton.layer.borderColor = [UIColor whiteColor].CGColor;
            sharpnessButton.layer.borderWidth = 1.0f;
            [sharpnessButton setImage:[UIImage imageNamed:@"camera_set.png"] forState:UIControlStateNormal];
            [sharpnessButton addTarget:self action:@selector(createSharpnessView:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *presetPointButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 5, 46, 30)];
            presetPointButton.tag = PRESETPOINT_TAG;
            presetPointButton.layer.borderColor = [UIColor whiteColor].CGColor;
            presetPointButton.layer.borderWidth = 1.0;
            [presetPointButton setImage:[UIImage imageNamed:@"curise_set.png"] forState:UIControlStateNormal];
            [presetPointButton addTarget:self action:@selector(createPresetPointView:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:sharpnessButton];
            [self addSubview:presetPointButton];
        }
        
//        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 30, 5, 25, 25)];
//        [cancelButton setImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
//        [cancelButton addTarget:self action:@selector(dismissControlBoard:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self addSubview:cancelButton];
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(frame), CGRectGetHeight(frame) - 30)];
        _containerView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_containerView];
        
    }
    
    return self;
}

-(void)layoutSubviews
{
    //init ui
    [self createSharpnessView:nil];
    
}

- (void)setAllowPosition:(CGFloat)allowPosition
{
    _allowPosition = allowPosition;
    [self setNeedsDisplay];
}

//- (void)drawRect:(CGRect)rect
//{
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:(CGPoint){_allowPosition-5.f, 10.f}];
//    [path addLineToPoint:(CGPoint){_allowPosition, 0.f}];
//    [path addLineToPoint:(CGPoint){_allowPosition+5.f, 10.f}];
//    [path closePath];
//    [[UIColor lightGrayColor] set];
//    [path fill];
//}

#pragma mark - Action

- (void)createPresetPointView:(id)sender
{
    for (UIView *subview in _containerView.subviews) {
        [subview removeFromSuperview];
    }
    for (int i = 0; i < 8; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i%4 * 55 + 42, i/4 * 55 + 40, 50, 50)];
        [button setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
            //        [button setAlpha:0.5];
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        button.tag = i + 1;
        [button addTarget:self action:@selector(selectPresetPoint:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"check_mark.png"] forState:UIControlStateSelected];
            
        [_containerView addSubview:button];
    }
    self.sureButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 180, 30, 30)];
    _sureButton.hidden = YES;
    [_sureButton setBackgroundImage:[UIImage imageNamed:@"btn_save_normal.png"] forState:UIControlStateNormal];
    [_sureButton setBackgroundImage:[UIImage imageNamed:@"btn_save_press.png"] forState:UIControlStateHighlighted];
    
    [_sureButton addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(170, 180, 30, 30)];
    _deleteButton.hidden = YES;
    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"btn_delete_normal.png"] forState:UIControlStateNormal];
    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"btn_delete_press.png"] forState:UIControlStateHighlighted];
    [_deleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    
    [_containerView addSubview:_sureButton];
    [_containerView addSubview:_deleteButton];
    
    //send message to receive
    _selectedStyle(sender);
    
    /*container for preset position*/
    
}

- (void)createSharpnessView:(id)sender
{
    for (UIView *subview in _containerView.subviews) {
        [subview removeFromSuperview];
    }
    
    CGRect frame = self.frame;
    /*container for sharpness*/
    NSArray *labTitles = @[NSLocalizedString(@"mcs_brightness", nil),NSLocalizedString(@"mcs_contrast", nil),NSLocalizedString(@"mcs_color_saturation", nil),NSLocalizedString(@"mcs_sharpness", nil)];
    float defaultValues[] = {50.f,60.f,70.f,6.f};
    CGFloat height = 30.f,
    width = frame.size.width;
    
    
    for(int i = 0 ; i < 4 ; i++)
    {
        UISlider *slider = [[UISlider alloc] initWithFrame:(CGRect){{controlboard_title_widht+10.f,i*height+height*.15f},{width-controlboard_title_widht-20.f,height*.7f}}];
        slider.tag = 1100 + i;
//        slider.tintColor = [UIColor grayColor];
        //slider.continuous = NO;
        slider.maximumValue = 100;
//        slider.alpha = 0.5;
        slider.value = defaultValues[i];
        [slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
        [_containerView addSubview:slider];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:(CGRect){{8,i*height},{controlboard_title_widht,height}}];
        lab.text = labTitles[i];
        lab.backgroundColor = [UIColor clearColor];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont boldSystemFontOfSize:13];
        lab.textColor = [UIColor whiteColor];
        [_containerView addSubview:lab];
    }
    
    UILabel *lab = [[UILabel alloc] initWithFrame:(CGRect){{8,4*height},{controlboard_title_widht,height}}];
    lab.text = NSLocalizedString(@"mcs_mode", nil);
    lab.backgroundColor = [UIColor clearColor];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont boldSystemFontOfSize:13];
    lab.textColor = [UIColor whiteColor];
    [_containerView addSubview:lab];
    
    NSArray *modeName = @[NSLocalizedString(@"mcs_auto",nil),NSLocalizedString(@"mcs_daytime",nil),NSLocalizedString(@"mcs_night",nil)];
    
    UISegmentedControl *modeSegment = [[UISegmentedControl alloc] initWithItems:modeName];
//    modeSegment.tintColor = [UIColor grayColor];
    [modeSegment addTarget:self action:@selector(segmentValueChange:) forControlEvents:UIControlEventValueChanged];
    modeSegment.tag = 888;
//    modeSegment.alpha = 0.5;
    modeSegment.selectedSegmentIndex = 0;
    modeSegment.frame = (CGRect){{controlboard_title_widht+10.f,4*height+height*.15f},{width-controlboard_title_widht-20.f,height}};
    [_containerView addSubview:modeSegment];
    
    NSArray *definitionTypes = [NSArray arrayWithObjects:
                                _HDString,
                                NSLocalizedString(@"mcs_standard_clear",nil),
                                NSLocalizedString(@"mcs_fluent_clear",nil),
                                nil];
    
    UILabel *definitionLabel =[[UILabel alloc] initWithFrame:CGRectMake(8, height*5+5, controlboard_title_widht, height)];
    definitionLabel.text = NSLocalizedString(@"mcs_resolution",nil);
    definitionLabel.backgroundColor = [UIColor clearColor];
    definitionLabel.textAlignment = NSTextAlignmentCenter;
    definitionLabel.font = [UIFont boldSystemFontOfSize:12];
    definitionLabel.textColor = [UIColor whiteColor];
    [_containerView addSubview:definitionLabel];
    
    /*分辨率*/
    struct mipci_conf *conf = MIPC_ConfigLoad();
    int index = (conf && ((PROFILE_ID_MAX) >= conf->profile_id))?conf->profile_id:1;
    
    UISegmentedControl *sharpnessSegment = [[UISegmentedControl alloc] initWithItems:definitionTypes];
    [sharpnessSegment addTarget:self action:@selector(sharpnessValueChange:) forControlEvents:UIControlEventValueChanged];
    sharpnessSegment.tag = 1001;
//    sharpnessSegment.alpha= 0.5;
    
//    if (UI_USER_INTERFACE_IDIOM() ==  UIUserInterfaceIdiomPhone) {
//        [sharpnessSegment setTitleTextAttributes:@{ UITextAttributeFont:[UIFont systemFontOfSize:10.0]}forState:UIControlStateNormal];
//    }
    [sharpnessSegment setTitleTextAttributes:@{ UITextAttributeFont:[UIFont systemFontOfSize:10.0]}forState:UIControlStateNormal];
    sharpnessSegment.frame = CGRectMake(controlboard_title_widht+10.f, height*5+10, width-controlboard_title_widht-20.f, height);
    [sharpnessSegment setSelectedSegmentIndex:index];
    [_containerView addSubview:sharpnessSegment];
    
    UIButton *reset = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    reset.frame = CGRectMake((width-controlboard_title_widht)*.5f, height*5 + 50, controlboard_title_widht, height - 10);
    [reset addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventTouchUpInside];
    reset.tag = 999;
    [reset setTitle:NSLocalizedString(@"mcs_reset",nil) forState:UIControlStateNormal];
    reset.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_containerView addSubview:reset];
    
    //send message to receive
    _selectedStyle(sender);
    
    /*container for sharpness*/
    
}

- (void)dismissControlBoard:(id)sender
{
    [((UIButton *)sender).superview removeFromSuperview];
}

- (void)sure:(id)sender
{
    _setupPreset(_selectedIndex, YES);
}

- (void)delete:(id)sender
{
    _currentButton.selected = NO;
    _setupPreset(_selectedIndex, NO);
   
}

- (void)selectPresetPoint:(id)sender
{
    [_currentButton setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
    _currentButton = sender;
    [_currentButton setBackgroundColor:[UIColor grayColor]];

    if (((UIButton*)sender).selected == NO) {
        _deleteButton.hidden = YES;
        _sureButton.hidden = NO;
        self.selectedIndex = ((UIButton*)sender).tag;
    }
    else
    {
        _deleteButton.hidden = NO;
        _sureButton.hidden = YES;
        self.selectedIndex = ((UIButton*)sender).tag;
         _selectedPreset(_selectedIndex);
    }
}

- (void)sharpnessValueChange:(id)sender
{
    int index = (int)((UISegmentedControl*)sender).selectedSegmentIndex;
    struct mipci_conf *conf = MIPC_ConfigLoad(), new_conf = {0};
    if(conf){ new_conf = *conf; };
    new_conf.profile_id = index;
    MIPC_ConfigSave(&new_conf);
    
    float value[] = {((UISlider*)[self viewWithTag:1100]).value,
        ((UISlider*)[self viewWithTag:1101]).value,
        ((UISlider*)[self viewWithTag:1102]).value,
        ((UISlider*)[self viewWithTag:1103]).value,
        ((UISegmentedControl*)[self viewWithTag:888]).selectedSegmentIndex};
    _valueChanged(sender, value);
}

- (void)segmentValueChange:(id)sender
{
    float value[] = {((UISlider*)[self viewWithTag:1100]).value,
        ((UISlider*)[self viewWithTag:1101]).value,
        ((UISlider*)[self viewWithTag:1102]).value,
        ((UISlider*)[self viewWithTag:1103]).value,
        ((UISegmentedControl*)[self viewWithTag:888]).selectedSegmentIndex};
    _valueChanged(sender,value);
}

- (void)sliderValueChange:(id)slider
{
//    _valueChangeing(slider);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(valueChange:) object:slider];
    [self performSelector:@selector(valueChange:) withObject:slider afterDelay:0.5f];
}

- (void)valueChange:(id)sender
{
    float value[] = {((UISlider*)[self viewWithTag:1100]).value, ((UISlider*)[self viewWithTag:1101]).value, ((UISlider*)[self viewWithTag:1102]).value, ((UISlider*)[self viewWithTag:1103]).value, ((UISegmentedControl*)[self viewWithTag:888]).selectedSegmentIndex};
    _valueChanged(sender,value);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
