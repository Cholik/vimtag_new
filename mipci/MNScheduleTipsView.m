//
//  MNScheduleTipsView.m
//  mipci
//
//  Created by mining on 16/6/15.
//
//

#import "MNScheduleTipsView.h"

//#define TEXTCOLOR [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1.0]
//#define BUTTONTITLECOLOR [UIColor colorWithRed:0/255.0 green:166/255.0 blue:186/255.0 alpha:1.0]
//#define LINECOLOR [UIColor colorWithRed:214/255.0 green:215/255.0 blue:220/255.0 alpha:1.0]

@implementation MNScheduleTipsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setAllLanguageImage
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [allLanguages objectAtIndex:0];
    if ([preferredLang rangeOfString:@"en"].length) {
        self.imageView.image = [UIImage imageNamed:@"vt_sceneen"];
    }
    else if ([preferredLang rangeOfString:@"zh-Hans"].length) {
        self.imageView.image = [UIImage imageNamed:@"vt_sceneCH"];
    }
    else if ([preferredLang rangeOfString:@"zh-Hant"].length) {
        self.imageView.image = [UIImage imageNamed:@"vt_sceneCH"];
    }
    else {
        self.imageView.image = [UIImage imageNamed:@"vt_sceneen"];
    }
}

-(void)initUI
{
    [self setAllLanguageImage];
    self.tipsView.layer.cornerRadius = 5.0;
    self.tipsView.layer.masksToBounds = YES;
    self.headLabel.text = NSLocalizedString(@"mcs_Sense_Schedule_Set", nil);
    self.detailLabel.text = NSLocalizedString(@"mcs_Sence_Schedule_detail", nil);
    [self.knowButton setTitle:NSLocalizedString(@"mcs_i_know", nil) forState:UIControlStateNormal];
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    [self initUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark- Rote
-(void)didRotate
{
    self.frame = [UIScreen mainScreen].bounds;
}

#pragma mark - Action
- (IBAction)knowButtonClick:(id)sender {
    [self removeFromSuperview];
}
@end
