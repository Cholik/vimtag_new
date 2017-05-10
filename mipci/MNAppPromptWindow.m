//
//  MNAppPromptWindow.m
//  mipci
//
//  Created by mining on 16/4/25.
//
//

#import "MNAppPromptWindow.h"
#import "AppDelegate.h"

#define SHADOWBACKGROUNDCOLOR       [UIColor blackColor]
#define SHADOWBACKGROUNDALPHA       0.4
#define TITLECOLOR                  [UIColor whiteColor]

#define LABELFONTSIZE               15.0
#define BUTTONFONTSIZE              14.0

#define MAINVIEWLENGTH              320
#define MOVEIMAGEVIEWLENGTH         150
#define ENLARGEIMAGEVIEWWIDTH       80
#define ENLARGEIMAGEVIEWHEIGHT      90
#define LABELFRAMEWIDTH             320
#define LABELFRAMEHEIGHT            40
#define BUTTONFRAMEWIDTH            86
#define BUTTONFRAMEHEIGHT           28

#define LABELTOCENTER               60
#define BUTTONTOIMAGE               36

@interface MNAppPromptWindow ()

@property (weak, nonatomic) AppDelegate *app;

@property (strong, nonatomic) UIView        *shadowView;
@property (strong, nonatomic) UIView        *mainView;
@property (strong, nonatomic) UIImageView   *enlargeImageView;
@property (strong, nonatomic) UIImageView   *moveImageView;
@property (strong, nonatomic) UILabel       *promptLabel;
@property (strong, nonatomic) UIButton      *certainButton;
@property (strong, nonatomic) UILabel       *enlargeLabel;
@property (strong, nonatomic) UILabel       *moveLabel;

@end

@implementation MNAppPromptWindow

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (instancetype)initWithFrame:(CGRect)frame style:(MNAppPromptStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUIWithStyle:style];
    }
    
    return self;
}

- (void)initUIWithStyle:(MNAppPromptStyle)style
{
    self.windowLevel = UIWindowLevelAlert;
    self.isAccessibilityElement = YES;
    self.accessibilityLabel = @"MNAppPromptWindow";
    
    //init
    UIViewController *rootViewController = [[UIViewController alloc] init];
    
    _shadowView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _shadowView.backgroundColor = SHADOWBACKGROUNDCOLOR;
    _shadowView.alpha = SHADOWBACKGROUNDALPHA;

    [rootViewController.view addSubview:_shadowView];

    if (style == MNAppPromptStyleVideo)
    {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(self.center.x - MAINVIEWLENGTH/2, self.center.y - MAINVIEWLENGTH/2, MAINVIEWLENGTH, MAINVIEWLENGTH)];
        _mainView.backgroundColor = [UIColor clearColor];
        
        _moveImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pu_Finger_move.png"]];
        _moveImageView.frame = CGRectMake(40, 80, 80, 80);
        
        _enlargeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pu_Enlarge_finger.png"]];
        _enlargeImageView.frame = CGRectMake(200, 80, 80, 80);
        
        _moveLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 120, 60)];
        _moveLabel.textColor = TITLECOLOR;
        _moveLabel.font = [UIFont systemFontOfSize:LABELFONTSIZE];
        _moveLabel.textAlignment = NSTextAlignmentCenter;
        _moveLabel.numberOfLines = 0;
        _moveLabel.text = NSLocalizedString(@"mcs_slide_screen", nil);
        
        _enlargeLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 160, 120, 60)];
        _enlargeLabel.textColor = TITLECOLOR;
        _enlargeLabel.font = [UIFont systemFontOfSize:LABELFONTSIZE];
        _enlargeLabel.textAlignment = NSTextAlignmentCenter;
        _enlargeLabel.numberOfLines = 0;
        _enlargeLabel.text = NSLocalizedString(@"mcs_zoom_in_screen", nil);
        
        _certainButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _certainButton.frame = CGRectMake(100, 260, 120, 40);
        _certainButton.layer.cornerRadius = 2;
        _certainButton.layer.borderWidth = 1;
        _certainButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [_certainButton setTitle:NSLocalizedString(@"mcs_i_know", nil) forState:UIControlStateNormal];
        [_certainButton setTitleColor:TITLECOLOR forState:UIControlStateNormal];
        [_certainButton addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_mainView addSubview:_moveImageView];
        [_mainView addSubview:_enlargeImageView];
        [_mainView addSubview:_moveLabel];
        [_mainView addSubview:_enlargeLabel];
        [_mainView addSubview:_certainButton];
        
        [rootViewController.view addSubview:_mainView];

//        _mainView = [[UIView alloc] initWithFrame:CGRectMake(self.center.x - MAINVIEWLENGTH/2, self.center.y - MAINVIEWLENGTH/2, MAINVIEWLENGTH, MAINVIEWLENGTH)];
//        _mainView.backgroundColor = [UIColor clearColor];
//        
//        _moveImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.app.is_vimtag ? @"vt_Finger_move.png" : self.app.is_ebitcam? @"eb_Finger_move.png" : @"finger_move.png"]];
//        _moveImageView.frame = CGRectMake((MAINVIEWLENGTH - MOVEIMAGEVIEWLENGTH)/2, (MAINVIEWLENGTH - MOVEIMAGEVIEWLENGTH)/2, MOVEIMAGEVIEWLENGTH, MOVEIMAGEVIEWLENGTH);
//        
//        _enlargeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.app.is_vimtag ? @"vt_Enlarge_finger.png" : self.app.is_ebitcam ? @"eb_Enlarge_finger.png" : @"enlarge_finger.png"]];
//        _enlargeImageView.frame = CGRectMake((MAINVIEWLENGTH - ENLARGEIMAGEVIEWWIDTH)/2, (MAINVIEWLENGTH - ENLARGEIMAGEVIEWHEIGHT)/2, ENLARGEIMAGEVIEWWIDTH, ENLARGEIMAGEVIEWHEIGHT);
//        
//        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake((MAINVIEWLENGTH - LABELFRAMEWIDTH)/2, MAINVIEWLENGTH/2 + LABELTOCENTER, LABELFRAMEWIDTH, LABELFRAMEHEIGHT)];
//        _promptLabel.textColor = TITLECOLOR;
//        _promptLabel.font = [UIFont systemFontOfSize:LABELFONTSIZE];
//        _promptLabel.textAlignment = NSTextAlignmentCenter;
//        _promptLabel.numberOfLines = 2;
//        _promptLabel.text = NSLocalizedString(@"mcs_slide_screen", nil);
//        
////        _certainButton = [UIButton buttonWithType:UIButtonTypeSystem];
////        _certainButton.frame = CGRectMake((MAINVIEWLENGTH - BUTTONFRAMEWIDTH)/2, (MAINVIEWLENGTH+MOVEIMAGEVIEWLENGTH)/2 + BUTTONTOIMAGE, BUTTONFRAMEWIDTH, BUTTONFRAMEHEIGHT);
////        [_certainButton setBackgroundImage:[UIImage imageNamed:@"btn_rectangle.png"] forState:UIControlStateNormal];
////        [_certainButton setTitle:NSLocalizedString(@"mcs_i_know", nil) forState:UIControlStateNormal];
////        [_certainButton setTitleColor:TITLECOLOR forState:UIControlStateNormal];
////        [_certainButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
//        
//        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction)];
//        tapGestureRecognizer.numberOfTapsRequired = 1;
//        [self addGestureRecognizer:tapGestureRecognizer];
//        
//        _enlargeImageView.hidden = YES;
//        
//        [_mainView addSubview:_moveImageView];
//        [_mainView addSubview:_enlargeImageView];
//        [_mainView addSubview:_promptLabel];
//        [_mainView addSubview:_certainButton];
//        
//        
//        [rootViewController.view addSubview:_mainView];
    }
    
    self.rootViewController = rootViewController;
    [self makeKeyAndVisible];
}

- (void)closeAction
{
    if (_moveImageView.hidden)
    {
        self.hidden = YES;
    }
    else
    {
        _moveImageView.hidden = YES;
        _enlargeImageView.hidden = NO;
        _promptLabel.text = NSLocalizedString(@"mcs_zoom_in_screen", nil);
    }
}

- (void)dismissAction
{
    self.hidden = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        frame = self.bounds;
    }
    
    _shadowView.frame = frame;
    _mainView.frame = CGRectMake(self.center.x - MAINVIEWLENGTH/2, self.center.y - MAINVIEWLENGTH/2, MAINVIEWLENGTH, MAINVIEWLENGTH);
}

@end
