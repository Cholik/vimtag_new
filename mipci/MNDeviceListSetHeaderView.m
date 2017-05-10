//
//  MNDeviceListSetHeaderView.m
//  mipci
//
//  Created by mining on 16/3/29.
//
//

#import "MNDeviceListSetHeaderView.h"

#define AUTOBUTTONTAG 1001
#define ACTIVEBUTTONTAG 1002
#define AWAYBUTTONTAG 1003
#define QUIETBUTTONTAG  1004

@implementation MNDeviceListSetHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)initUI
{
    [_activeButton setTitle:[NSString stringWithFormat:@"   %@", NSLocalizedString(@"mcs_home_mode", nil)] forState:UIControlStateNormal];
    [_activeButton setTitle:[NSString stringWithFormat:@"   %@", NSLocalizedString(@"mcs_home_mode", nil)] forState:UIControlStateSelected];
    [_awayButton setTitle:[NSString stringWithFormat:@"   %@", NSLocalizedString(@"mcs_away_home_mode", nil)] forState:UIControlStateNormal];
    [_awayButton setTitle:[NSString stringWithFormat:@"   %@", NSLocalizedString(@"mcs_away_home_mode", nil)] forState:UIControlStateSelected];
    _autoLabel.text = NSLocalizedString(@"mcs_auto_switch_mode", nil);

    CGSize activeButtonSize = [_activeButton.titleLabel.text boundingRectWithSize:CGSizeMake(320, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_activeButton.titleLabel.font} context:nil].size;
    _activeButtonWidth.constant = activeButtonSize.width+28;
    CGSize awayButtonSize = [_awayButton.titleLabel.text boundingRectWithSize:CGSizeMake(320, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_awayButton.titleLabel.font} context:nil].size;
    _awayButtonWidth.constant = awayButtonSize.width+28;
    CGSize autoLabelSize = [_autoLabel.text boundingRectWithSize:CGSizeMake(320, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_autoLabel.font} context:nil].size;
    _autoLabelWidth.constant = autoLabelSize.width+2;
    
    _activeButton.selected = NO;
    _awayButton.selected = NO;
    _autoLabel.highlighted = NO;
    _autoSwitch.on = NO;
    _autoSwitch.transform = CGAffineTransformMakeScale( 0.68, 0.71);

    _homeSynButton.hidden = YES;
    _outSynButton.hidden = YES;
    _autoSynButton.hidden = YES;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initUI];
}

#pragma mark - Action
- (IBAction)showSceneBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(showOrHideSceneView)]) {
        [self.delegate showOrHideSceneView];
    }
}
- (IBAction)addDeviceBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addDevice)]) {
        [self.delegate addDevice];
    }
}
- (IBAction)selectScene:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chooseScene:)]) {
        [self.delegate chooseScene:sender];
    }
}

- (IBAction)openAutoModel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chooseScene:)]) {
        [self.delegate chooseScene:sender];
    }
}

- (IBAction)synchronization:(id)sender {
    if ([self.delegate respondsToSelector:@selector(synchronizeScene)]) {
        [self.delegate synchronizeScene];
    }
}

@end
