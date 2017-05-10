//
//  MNInfoPromptView.m
//  mipci
//
//  Created by mining on 15/8/29.
//
//

#import "MNInfoPromptView.h"
#import "MNHierarchySearcher.h"
#import "AppDelegate.h"

#ifdef UIColorFromRGB
#undef UIColorFromRGB
#endif

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((((rgbValue) & 0xFF0000) >> 16))/255.f \
green:((((rgbValue) & 0xFF00) >> 8))/255.f \
blue:(((rgbValue) & 0xFF))/255.f alpha:alphaValue]

static const CGFloat kMargin = 10.f;
static const NSTimeInterval kAnimationDuration = 0.3;
static const int kRedBannerColor = 0xFF5659;
static const int kGreenBannerColor = 0x71D4E0;
static const int kDefaultTextColor = 0xffffff;
static const int kBlueBannerColor = 0x2988cc;
static const int kOrangeBannerColor = 0xff781f;
static const int kGrayBannerColor = 0x646464;
static const int kEbitBannerColor = 0x5c5c66;
static const int kMIPCBannerColor = 0x86cd1b;

static const CGFloat kFontSize = 12.f;
static const CGFloat kDefaultHideInterval = 3.0;

@interface MNInfoPromptView ()

@property (weak, nonatomic) AppDelegate *app;
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UIView *targetView;
@property (nonatomic) UIView *viewAboveBanner;
@property (nonatomic) CGFloat additionalTopSpacing;
@property (nonatomic) NSLayoutConstraint *topSpacingConstraint;
@property (nonatomic) UIButton *closeButton;
//@property (nonatomic) UIImageView *infoImage;

@end

@implementation MNInfoPromptView

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setStyle:(MNInfoPromptViewStyle)style
{
    _style = style;
    [self applyStyle];
}

- (void)applyStyle
{
    if (self.style == MNInfoPromptViewStyleError) {
        if (self.app.is_ebitcam) {
            [self setBackgroundColor:self.errorBackgroundColor ?: UIColorFromRGB(kOrangeBannerColor, 1.0)];
            [self.textLabel setTextColor:self.errorTextColor ?: UIColorFromRGB(kDefaultTextColor, 1.0)];
        } else if (self.app.is_mipc) {
            [self setBackgroundColor:self.errorBackgroundColor ?: UIColorFromRGB(kMIPCBannerColor, 1.0)];
            [self.textLabel setTextColor:self.errorTextColor ?: UIColorFromRGB(kDefaultTextColor, 1.0)];
        } else {
            [self setBackgroundColor:self.errorBackgroundColor ?: UIColorFromRGB(kRedBannerColor, 1.0)];
            [self.textLabel setTextColor:self.errorTextColor ?: UIColorFromRGB(kDefaultTextColor, 1.0)];
        }
    } else if (self.style == MNInfoPromptViewStyleInfo) {
        if (self.app.is_ebitcam) {
            [self setBackgroundColor:self.infoBackgroundColor ?: UIColorFromRGB(kEbitBannerColor, 0.8)];
            [self.textLabel setTextColor:self.infoTextColor ?: UIColorFromRGB(kDefaultTextColor, 1.0)];
        } else if (self.app.is_mipc) {
            [self setBackgroundColor:self.infoBackgroundColor ?: UIColorFromRGB(kBlueBannerColor, 0.8)];
            [self.textLabel setTextColor:self.infoTextColor ?: UIColorFromRGB(kDefaultTextColor, 1.0)];
        } else {
            [self setBackgroundColor:self.infoBackgroundColor ?: UIColorFromRGB(kGreenBannerColor, 1.0)];
            [self.textLabel setTextColor:self.infoTextColor ?: UIColorFromRGB(kDefaultTextColor, 1.0)];
        }
    } else if (self.style == MNInfoPromptViewStyleAutomation) {
        [self setBackgroundColor:self.infoBackgroundColor ?: UIColorFromRGB(kGrayBannerColor, 1.0)];
        [self.textLabel setTextColor:self.infoTextColor ?: UIColorFromRGB(kDefaultTextColor, 1.0)];
    }
    [self.textLabel setFont:self.font ?: [UIFont boldSystemFontOfSize:kFontSize]];
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self.textLabel setText:text];
    //Add Automation Accessibility
    self.textLabel.isAccessibilityElement = YES;
    self.textLabel.accessibilityLabel = @"MNInfoPromptViewLabel";
    self.textLabel.accessibilityValue = text;

    [self setNeedsLayout];
}

- (void)setErrorBackgroundColor:(UIColor *)errorBackgroundColor
{
    _errorBackgroundColor = errorBackgroundColor;
    [self applyStyle];
}

- (void)setInfoBackgroundColor:(UIColor *)infoBackgroundColor
{
    _infoBackgroundColor = infoBackgroundColor;
    [self applyStyle];
}

- (void)setErrorTextColor:(UIColor *)errorTextColor
{
    _errorTextColor = errorTextColor;
    [self applyStyle];
}

- (void)setInfoTextColor:(UIColor *)infoTextColor
{
    _infoTextColor = infoTextColor;
    [self applyStyle];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    [self applyStyle];
}

- (void)setUp
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UILabel *label = [[UILabel alloc] init];
    
    [self setTextLabel:label];
    [self configureLabel];
    [self addSubview:label];
    if (self.app.is_ebitcam || self.app.is_mipc) {
    
    } else {
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(tapCloseInfoPrompt) forControlEvents:UIControlEventTouchUpInside];
        [self setCloseButton:button];
        [self configureButton];
        [self addSubview:button];
    }

}

- (void)configureLabel
{
    [self.textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
    [self.textLabel setTextAlignment:NSTextAlignmentCenter];
    [self.textLabel setNumberOfLines:0];
}

- (void)configureButton
{
    [self.closeButton setImage:[UIImage imageNamed:@"vt_promapt_delete.png"] forState:UIControlStateNormal];
}

- (void)updateConstraints
{
    NSDictionary *viewsDict = @{@"self": self, @"label": self.textLabel};
    
    // Expand to the superview's width
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|"
                                                                           options:0 metrics:nil views:viewsDict]];
    // Place initial constraint exactly one frame above the bottom line of view above us
    // or above top of screen, if there is no such view. Assign it to property to animate later.
    CGFloat topOffset = -self.frame.size.height;
    if (self.viewAboveBanner)
        topOffset += CGRectGetMaxY(self.viewAboveBanner.frame);
    NSArray *topConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(offset)-[self]"
                                                                      options:0
                                                                      metrics:@{@"offset": @(topOffset)}
                                                                        views:viewsDict];
    self.topSpacingConstraint = [topConstraints firstObject];
    [self.superview addConstraints:topConstraints];
    
    // Position label correctly
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-|"
                                                                 options:0 metrics:nil views:viewsDict]];
    CGFloat topMargin = kMargin + self.additionalTopSpacing;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[label]-(bottom)-|"
                                                                 options:0
                                                                 metrics:@{@"top": @(topMargin), @"bottom": @(kMargin)}
                                                                   views:viewsDict]];
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.preferredMaxLayoutWidth = self.textLabel.frame.size.width;
    if (self.app.is_ebitcam || self.app.is_mipc)
    {
        
    }
    else
    {
        self.closeButton.frame = CGRectMake(self.frame.size.width - 25, self.frame.size.height - 30, 25, 25);
    }

    [super layoutSubviews];
}

- (void)show:(BOOL)animated
     isModal:(BOOL)is_modal
{
    //hide first
//    [self hide:YES];
    
    [self applyStyle];
    [self setupViewsAndFramesIsModal:is_modal];
    
    // In previously indicated, send subview to be below another view.
    // This is used when showing below navigation bar
    if (self.viewAboveBanner && !is_modal)
        [self.targetView insertSubview:self belowSubview:self.viewAboveBanner];
    else
        [self.targetView addSubview:self];
    
    [self setHidden:NO];
    
    if (animated) {
        // First pass calculates the height correctly with existing constraints.
        // Self-only doesn't calculate height on iOS 6, so pass through a superview
        [self updateConstraintsIfNeeded];
        [self.superview layoutIfNeeded];
        
        // Invalidate the top contraint because it needs to be changed
        [self.superview removeConstraint:self.topSpacingConstraint];
        
        // New pass to take frame and new top constraint, position frame before the animation
        [self setNeedsUpdateConstraints];
        [self.superview layoutIfNeeded];
        
        // Target top layout after animation is one frame down
        self.topSpacingConstraint.constant += self.frame.size.height;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self.superview layoutIfNeeded];
        }];
    } else {
        self.topSpacingConstraint.constant += self.frame.size.height;
    }
}

- (void)setupViewsAndFramesIsModal:(BOOL)is_modal

{
    UINavigationController *navVC = [[[MNHierarchySearcher alloc] init] topmostNavigationController];
    if (navVC && navVC.navigationBar.superview && !is_modal) {
        self.targetView = navVC.navigationBar.superview;
        self.viewAboveBanner = navVC.navigationBar;
    } else {
        // If there isn't a navigation controller with a bar, show in window instead.
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        // Forget the frame convertions, smallest is the height, no doubt
        CGFloat statusBarHeight = MIN(statusBarFrame.size.width, statusBarFrame.size.height);
        
        self.additionalTopSpacing = statusBarHeight;
        self.targetView = window;
    }
}

- (void)tapCloseInfoPrompt
{
    [self hide:YES];
}

- (void)hide:(BOOL)animated
{
    if (animated) {
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            weakSelf.frame = CGRectOffset(weakSelf.frame, 0, -weakSelf.frame.size.height);
        } completion:^(BOOL finished) {
            [weakSelf removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

+ (instancetype)showAndHideWithText:(NSString *)text
                              style:(MNInfoPromptViewStyle)style
                              isModal:(BOOL)is_modal

{
    return [self showWithText:text style:style andHideAfter:kDefaultHideInterval isModal:is_modal];
}

+ (instancetype)showWithText:(NSString *)text
                       style:(MNInfoPromptViewStyle)style
                andHideAfter:(NSTimeInterval)timeout
                     isModal:(BOOL)is_modal

{
    MNInfoPromptView *banner = [self showWithText:text style:style isModal:is_modal];
    if (style == MNInfoPromptViewStyleError) {
        [banner performSelector:@selector(tapCloseInfoPrompt) withObject:nil afterDelay:kDefaultHideInterval];
    }
    
    return banner;
}

+ (instancetype)showAndHideWithText:(NSString *)text
                              style:(MNInfoPromptViewStyle)style
                            isModal:(BOOL)is_modal
                         navigation:(UINavigationController *)navVC
{
    [self hideAll:navVC];
    
    MNInfoPromptView *banner = [[[self class] alloc] init];
    [banner setText:text];
    [banner setStyle:style];
    
    if (navVC && navVC.navigationBar.superview && !is_modal) {
        banner.targetView = navVC.navigationBar.superview;
        banner.viewAboveBanner = navVC.navigationBar;
    } else {
        // If there isn't a navigation controller with a bar, show in window instead.
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        // Forget the frame convertions, smallest is the height, no doubt
        CGFloat statusBarHeight = MIN(statusBarFrame.size.width, statusBarFrame.size.height);
        
        banner.additionalTopSpacing = statusBarHeight;
        banner.targetView = window;
    }
    
    // In previously indicated, send subview to be below another view.
    // This is used when showing below navigation bar
    if (banner.viewAboveBanner && !is_modal)
        [banner.targetView insertSubview:banner belowSubview:banner.viewAboveBanner];
    else
        [banner.targetView addSubview:banner];
    
    [banner setHidden:NO];
    
    // First pass calculates the height correctly with existing constraints.
    // Self-only doesn't calculate height on iOS 6, so pass through a superview
    [banner updateConstraintsIfNeeded];
    [banner.superview layoutIfNeeded];
    
    // Invalidate the top contraint because it needs to be changed
    [banner.superview removeConstraint:banner.topSpacingConstraint];
    
    // New pass to take frame and new top constraint, position frame before the animation
    [banner setNeedsUpdateConstraints];
    [banner.superview layoutIfNeeded];
    
    // Target top layout after animation is one frame down
    banner.topSpacingConstraint.constant += banner.frame.size.height;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [banner.superview layoutIfNeeded];
    }];
    
//    if (style == MNInfoPromptViewStyleError) {
        [banner performSelector:@selector(tapCloseInfoPrompt) withObject:nil afterDelay:kDefaultHideInterval];
//    }
    
    return banner;
}

+ (instancetype)showWithText:(NSString *)text
                       style:(MNInfoPromptViewStyle)style
                     isModal:(BOOL)is_modal

{
    //hide all
    [self hideAll];
    
    MNInfoPromptView *banner = [[[self class] alloc] init];
    [banner setText:text];
    [banner setStyle:style];
    
    [banner show:YES isModal:is_modal];
    return banner;
}

+ (void)hideAll
{
    UINavigationController *navVC = [[[MNHierarchySearcher alloc] init] topmostNavigationController];
    [self hideAllInView:navVC.navigationBar.superview];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [self hideAllInView:window];
}

+ (void)hideAll:(UINavigationController *)nav
{
    UINavigationController *navVC = nav;
    [self hideAllInView:navVC.navigationBar.superview];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [self hideAllInView:window];
}

+ (void)hideAllInView:(UIView *)view
{
    for (MNInfoPromptView *subview in view.subviews) {
        if ([subview isKindOfClass:[self class]]) {
            [subview hide:NO];
        }
    }
}



@end
