//
//  MNCustomAlertView.m
//  mipci
//
//  Created by mining on 15/9/23.
//
//

#import "MNCustomAlertView.h"
#import <QuartzCore/QuartzCore.h>

#define CustomUIWindowLevel     1999

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MNCustomAlertView ()
{
    CGFloat width;
    CGFloat height;
    CGFloat orginX;
    CGFloat orginY;
    CGFloat circleBgRadius;
    CGFloat circleRadius;

}
@property (nonatomic, strong) UIWindow *thisAlertWindow;
@property (nonatomic, strong)  UIViewController *customRootViewController;

@end

@implementation MNCustomAlertView

static UIImage *imageOfWarning = nil;

- (instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title Details:(NSString *)details isSave:(BOOL)isSave
{
    self = [super initWithFrame:frame];
    if (self) {
        _title = title;
        _details = details;
        _isSave = isSave;
    }
    
    return self;
}

- (UIWindow *)thisAlertWindow
{
    if (nil == _thisAlertWindow) {
        [self initAlertViewUI];
    }
    
    return _thisAlertWindow;
}

- (void)initAlertViewUI
{
    width = 240.0;
    height = 240.0;
    orginX = (self.frame.size.width - width)/2;
    orginY = (self.frame.size.height - height)/2;
    circleBgRadius = 50.0;
    circleRadius = 40.0;
    
    //init RootViewController
    _customRootViewController = [[UIViewController alloc] init];
    
    //init shadow and other mainView
    UIView *shadowView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    shadowView.backgroundColor = [UIColor darkGrayColor];
    shadowView.alpha = 0.4;
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(orginX, orginY, width, height)];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.masksToBounds = YES;
    _contentView.layer.cornerRadius = 6.0;
    
    _circleViewBackground = [[UIView alloc] initWithFrame:CGRectMake(_contentView.center.x -circleBgRadius, _contentView.frame.origin.y - circleBgRadius, circleBgRadius * 2, circleBgRadius * 2)];
    _circleViewBackground.backgroundColor = [UIColor whiteColor];
    _circleViewBackground.layer.cornerRadius = 50.0;
    _circleViewBackground.layer.masksToBounds = YES;
    
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(circleBgRadius - circleRadius, circleBgRadius - circleRadius, circleRadius * 2, circleRadius * 2)];
    circleView.backgroundColor = UIColorFromRGB(0x00A6BA);
    circleView.layer.cornerRadius = 40.0;
    circleView.layer.masksToBounds = YES;
    [_circleViewBackground addSubview:circleView];
    
    UIImageView *circleIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
    circleIconImageView.image = self.imageOfWarning;
    [circleView addSubview:circleIconImageView];
    
    //init title and detail
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/2 - 100, 45, 200,30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextColor:UIColorFromRGB(0x00A6BA)];
    titleLabel.numberOfLines = 1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.text = _title;
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/2 - 100, 75, 200, 60)];
    detailLabel.backgroundColor = [UIColor clearColor];
    [detailLabel setTextColor:[UIColor grayColor]];
    detailLabel.numberOfLines = 5;
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.font = [UIFont systemFontOfSize:14];
    detailLabel.text = _details;
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(width/2 - 78, 135, 180, 20)];
    promptLabel.backgroundColor = [UIColor clearColor];
    [promptLabel setTextColor:[UIColor grayColor]];
    promptLabel.numberOfLines = 1;
    promptLabel.textAlignment = NSTextAlignmentLeft;
    promptLabel.font = [UIFont systemFontOfSize:12];
    promptLabel.text = NSLocalizedString(@"mcs_save_network_set", nil);
    
    //init button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.frame = CGRectMake(width/2 - 100, height - 40 , 200, 30);
//    [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 100, height - 40 , 200, 30)];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitleColor:UIColorFromRGB(0x00A6BA) forState:UIControlStateNormal];
    [cancelButton setTitle:NSLocalizedString(@"mcs_cancel", nil) forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
    cancelButton.layer.masksToBounds = YES;
    cancelButton.layer.cornerRadius = 6.0;
    cancelButton.layer.borderColor = UIColorFromRGB(0x00A6BA).CGColor;
    cancelButton.layer.borderWidth = 1.0;
    [cancelButton addTarget:self action:@selector(cancelOperation) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *certainButton = [UIButton buttonWithType:UIButtonTypeSystem];
    certainButton.frame = CGRectMake(width/2 - 100,height - 80, 200, 30);
    //UIButton *certainButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 100,height - 80, 200, 30)];
    certainButton.backgroundColor = UIColorFromRGB(0x00A6BA);
    [certainButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [certainButton setTitle:NSLocalizedString(@"mcs_ok", nil) forState:UIControlStateNormal];
    certainButton.titleLabel.font = [UIFont systemFontOfSize:17];
    certainButton.layer.masksToBounds = YES;
    certainButton.layer.cornerRadius = 6.0;
    certainButton.layer.borderColor = UIColorFromRGB(0x00A6BA).CGColor;
    certainButton.layer.borderWidth = 1.0;
    [certainButton addTarget:self action:@selector(certainOperation) forControlEvents:UIControlEventTouchUpInside];
    
    _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2 -100, 135, 20, 20)];
    _saveButton.layer.cornerRadius = 10.0;
    _saveButton.layer.masksToBounds = YES;
    _saveButton.layer.borderColor = UIColorFromRGB(0x00A6BA).CGColor;
    _saveButton.layer.borderWidth = 1.0;
    [_saveButton setImage:[UIImage imageNamed:_isSaveNetwork ? @"vt_select_save" : @"vt_select_nosave"] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(selectSave) forControlEvents:UIControlEventTouchUpInside];
    
    if (_isSave) {
        [_contentView addSubview:titleLabel];
        [_contentView addSubview:detailLabel];
        [_contentView addSubview:cancelButton];
        [_contentView addSubview:certainButton];
        [_contentView addSubview:promptLabel];
        [_contentView addSubview:_saveButton];
    } else {
        detailLabel.frame = CGRectMake(width/2 - 100, 75, 200, 85);
        if (detailLabel.text.length > 50) {
            detailLabel.font = [UIFont systemFontOfSize:12];
        }
        [_contentView addSubview:titleLabel];
        [_contentView addSubview:detailLabel];
        [_contentView addSubview:cancelButton];
        [_contentView addSubview:certainButton];
    }
    
    
    [_customRootViewController.view addSubview:shadowView];
    [_customRootViewController.view addSubview:_contentView];
    [_customRootViewController.view addSubview:_circleViewBackground];
    
    
    
    //init window
    _thisAlertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _thisAlertWindow.backgroundColor = [UIColor clearColor];
    _thisAlertWindow.windowLevel = CustomUIWindowLevel;
    _thisAlertWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _thisAlertWindow.rootViewController = _customRootViewController;
}

- (UIImage*)imageOfWarning
{
    if (imageOfWarning != nil)
    {
        return imageOfWarning;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(80, 80), NO, 0);
    [self drawWarning];
    imageOfWarning = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageOfWarning;
}

- (void)drawWarning
{
    // Color Declarations
    UIColor *greyColor = [UIColor whiteColor];
    
    // Warning Group
    // Warning Circle Drawing
    UIBezierPath *warningCirclePath = [[UIBezierPath alloc] init];
    [warningCirclePath moveToPoint:CGPointMake(40.94, 63.39)];
    [warningCirclePath addCurveToPoint:CGPointMake(36.03, 65.55) controlPoint1: CGPointMake(39.06, 63.39) controlPoint2: CGPointMake(37.36, 64.18)];
    [warningCirclePath addCurveToPoint:CGPointMake(34.14, 70.45) controlPoint1: CGPointMake(34.9, 66.92) controlPoint2: CGPointMake(34.14, 68.49)];
    [warningCirclePath addCurveToPoint:CGPointMake(36.22, 75.54) controlPoint1: CGPointMake(34.14, 72.41) controlPoint2: CGPointMake(34.9, 74.17)];
    [warningCirclePath addCurveToPoint:CGPointMake(40.94, 77.5) controlPoint1: CGPointMake(37.54, 76.91) controlPoint2: CGPointMake(39.06, 77.5)];
    [warningCirclePath addCurveToPoint:CGPointMake(45.86, 75.35) controlPoint1: CGPointMake(42.83, 77.5) controlPoint2: CGPointMake(44.53, 76.72)];
    [warningCirclePath addCurveToPoint:CGPointMake(47.93, 70.45) controlPoint1: CGPointMake(47.18, 74.17) controlPoint2: CGPointMake(47.93, 72.41)];
    [warningCirclePath addCurveToPoint:CGPointMake(45.86, 65.35) controlPoint1: CGPointMake(47.93, 68.49) controlPoint2: CGPointMake(47.18, 66.72)];
    [warningCirclePath addCurveToPoint:CGPointMake(40.94, 63.39) controlPoint1: CGPointMake(44.53, 64.18) controlPoint2: CGPointMake(42.83, 63.39)];
    [warningCirclePath closePath];
    warningCirclePath.miterLimit = 4;
    
    [greyColor setFill];
    [warningCirclePath fill];
    
    
    //// Warning Shape Drawing
    UIBezierPath *warningShapePath = [[UIBezierPath alloc] init];
    [warningShapePath moveToPoint:CGPointMake(46.23, 4.26)];
    [warningShapePath addCurveToPoint:CGPointMake(40.94, 2.5) controlPoint1: CGPointMake(44.91, 3.09) controlPoint2: CGPointMake(43.02, 2.5)];
    [warningShapePath addCurveToPoint:CGPointMake(34.71, 4.26) controlPoint1: CGPointMake(38.68, 2.5) controlPoint2: CGPointMake(36.03, 3.09)];
    [warningShapePath addCurveToPoint:CGPointMake(31.5, 8.77) controlPoint1: CGPointMake(33.01, 5.44) controlPoint2: CGPointMake(31.5, 7.01)];
    [warningShapePath addLineToPoint:CGPointMake(31.5, 19.36)];
    [warningShapePath addLineToPoint:CGPointMake(34.71, 54.44)];
    [warningShapePath addCurveToPoint:CGPointMake(40.38, 58.16) controlPoint1: CGPointMake(34.9, 56.2) controlPoint2: CGPointMake(36.41, 58.16)];
    [warningShapePath addCurveToPoint:CGPointMake(45.67, 54.44) controlPoint1: CGPointMake(44.34, 58.16) controlPoint2: CGPointMake(45.67, 56.01)];
    [warningShapePath addLineToPoint:CGPointMake(48.5, 19.36)];
    [warningShapePath addLineToPoint:CGPointMake(48.5, 8.77)];
    [warningShapePath addCurveToPoint:CGPointMake(46.23, 4.26) controlPoint1: CGPointMake(48.5, 7.01) controlPoint2: CGPointMake(47.74, 5.44)];
    [warningShapePath closePath];
    warningShapePath.miterLimit = 4;
    
    [greyColor setFill];
    [warningShapePath fill];
}

- (void)show
{
    [self.thisAlertWindow makeKeyAndVisible];
    
}

//- (void)layoutSubviews
//{
//    width = 240.0;
//    height = 240.0;
//    orginX = (self.frame.size.width - width)/2;
//    orginY = (self.frame.size.height - height)/2;
//    circleBgRadius = 50.0;
//    circleRadius = 40.0;
//    
//    _contentView.frame = CGRectMake(orginX, orginY, width, height);
//    _circleViewBackground.frame = CGRectMake(_contentView.center.x -circleBgRadius, _contentView.frame.origin.y - circleBgRadius, circleBgRadius * 2, circleBgRadius * 2);
//}

#pragma action
- (void)cancelOperation
{
    [self closeWindow];
}

- (void)certainOperation
{
    [self.delegate customAlertView:self];
    [self closeWindow];
}

- (void)selectSave
{
    _isSaveNetwork = !_isSaveNetwork;
    [_saveButton setImage:[UIImage imageNamed:_isSaveNetwork ? @"vt_select_save" : @"vt_select_nosave"] forState:UIControlStateNormal];
}

- (void)closeWindow
{
    if (self.thisAlertWindow) {
        [self.thisAlertWindow resignKeyWindow];
        self.thisAlertWindow = nil;
    }
    
    for (UIView *view in _customRootViewController.view.subviews) {
        [view removeFromSuperview];
    }

    [self removeFromSuperview];
}

@end
