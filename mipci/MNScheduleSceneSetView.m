//
//  MNScheduleSceneSetView.m
//  mipci
//
//  Created by 谢跃聪 on 16/12/19.
//
//

#define CANCEL_OPERATION        1000
#define CERTAIN_OPERATION       1001
#define HOME_OPERATION          1003
#define OUT_OPERATION           1004

#define SCHEDULE_ACTIVE         2001
#define SCHEDULE_AWAY           2002

#import "MNScheduleSceneSetView.h"

@implementation MNScheduleSceneSetView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initUI
{
    self.setSceneView.layer.cornerRadius = 5.0;
    self.setSceneView.layer.masksToBounds = YES;
    
    self.homeButton.selected = YES;
    self.outButton.selected = NO;
    
    _titleLabel.text = NSLocalizedString(@"mcs_select_scene_mode", nil);
    
    [_homeButton setTitle:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"mcs_home_mode", nil)] forState:UIControlStateNormal];
    [_homeButton setTitle:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"mcs_home_mode", nil)] forState:UIControlStateSelected];
    [_outButton setTitle:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"mcs_away_home_mode", nil)] forState:UIControlStateNormal];
    [_outButton setTitle:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"mcs_away_home_mode", nil)] forState:UIControlStateSelected];
    
    [_cancelButton setTitle:NSLocalizedString(@"mcs_cancel", nil) forState:UIControlStateNormal];
    [_certainButton setTitle:NSLocalizedString(@"mcs_ok", nil) forState:UIControlStateNormal];
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

- (IBAction)selectScene:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    _homeButton.selected = tag == HOME_OPERATION ? YES : NO;
    _outButton.selected = tag == HOME_OPERATION ? NO : YES;
}

- (IBAction)operating:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    self.hidden = YES;
    [self.delegate finishSceneSetView:(tag == CERTAIN_OPERATION ? YES : NO) schedule:(_homeButton.selected ? SCHEDULE_ACTIVE : SCHEDULE_AWAY)];
}

@end
