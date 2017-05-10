//
//  MNAlertView.m
//  mipci
//
//  Created by mining on 15/7/25.
//
//

#import "MNAlertView.h"

@implementation MNAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)layout
{
    [[self.mainAlertView layer] setCornerRadius:6];
//    [[self.buttonView layer] setCornerRadius:6];
    
    
    _promptLabel.text = NSLocalizedString(@"mcs_prompt", nil);
    _saveNetworkLabel.text = NSLocalizedString(@"mcs_save_network_set", nil);
    [[self.cancelButton layer] setCornerRadius:4.0];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelButton setTitle:NSLocalizedString(@"mcs_cancel", nil) forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self.sureButton layer] setCornerRadius:4.0];
    self.sureButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.sureButton setTitle:NSLocalizedString(@"mcs_ok", nil) forState:UIControlStateNormal];
    [self.sureButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];

    [_saveNetworkButton setImage:[UIImage imageNamed: _isSaveNetwork ? @"save_network" : @"no_save_network"] forState:UIControlStateNormal];
    [self.saveNetworkButton addTarget:self action:@selector(changeSaveNetwork:) forControlEvents:UIControlEventTouchUpInside];
   
    
}
- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"MNAlertView" owner:self options:nil];
        self.contentView.frame = frame;
        [self addSubview:self.contentView];
        self.titleLabel.text = title;
        _isSaveNetwork = 1;
        [self layout];
    }
    return self;
}

#pragma mark - Action
- (void)dismissView:(id)sender
{
    [_contentView.superview removeFromSuperview];
}
- (void)action:(id)sender
{
    [self.delegate alertView:self];
    [_contentView.superview removeFromSuperview];
}
- (void)changeSaveNetwork:(id)sender
{
    _isSaveNetwork = !_isSaveNetwork;
    [_saveNetworkButton setImage:[UIImage imageNamed: _isSaveNetwork ? @"save_network" : @"no_save_network"] forState:UIControlStateNormal];
}

//#pragma mark - Interface orientation
//- (void)setMainAlertView
//{
//    _mainAlertView.center = self.center;
//}

@end
