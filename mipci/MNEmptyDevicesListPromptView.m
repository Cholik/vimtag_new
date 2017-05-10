//
//  MNEmptyDevicesListPromptView.m
//  mipci
//
//  Created by mining on 16/2/25.
//
//

#import "MNEmptyDevicesListPromptView.h"


#define CustomUIWindowLevel     1999

@interface MNEmptyDevicesListPromptView ()

@property (strong, nonatomic) UIWindow *promptWindow;
@property (strong, nonatomic) UIViewController *promptViewController;
@property (strong, nonatomic) UITapGestureRecognizer *clickTap;
@end

@implementation MNEmptyDevicesListPromptView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

- (UIWindow *)promptWindow
{
    if (nil == _promptWindow) {
        [self initUI];
    }
    
    return _promptWindow;
}

- (void)initUI
{
    //init RootViewController
    _promptViewController = [[UIViewController alloc] init];
    
    //init shadow and other mainView
    UIView *shadowView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    shadowView.backgroundColor = [UIColor darkGrayColor];
    shadowView.alpha = 0.4;
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //init tap
    _clickTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    _clickTap.numberOfTapsRequired = 1;
    [_promptViewController.view addGestureRecognizer:_clickTap];
    
    [_promptViewController.view addSubview:shadowView];
    
    //init window
    _promptWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _promptWindow.backgroundColor = [UIColor clearColor];
    _promptWindow.windowLevel = CustomUIWindowLevel;
    _promptWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _promptWindow.rootViewController = _promptViewController;
}

- (void)show
{
    [self.promptWindow makeKeyAndVisible];
}

- (void)hide
{
    [self closeWindow];
}

- (void)closeWindow
{
    if (self.promptWindow) {
        [self.promptWindow resignKeyWindow];
        self.promptWindow = nil;
    }
    
    for (UIView *view in _promptViewController.view.subviews) {
        [view removeFromSuperview];
    }
    
    [self removeFromSuperview];
}

@end
