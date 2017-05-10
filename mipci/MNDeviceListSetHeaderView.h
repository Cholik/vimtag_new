//
//  MNDeviceListSetHeaderView.h
//  mipci
//
//  Created by mining on 16/3/29.
//
//

#import <UIKit/UIKit.h>
#import "MNSceneButtonBackView.h"

@protocol DeviceListSetHeaderViewDelegate <NSObject>

- (void)showOrHideSceneView;
- (void)addDevice;
- (void)chooseScene:(UIButton *)sender;
- (void)synchronizeScene;

@end


@interface MNDeviceListSetHeaderView : UIView

@property (nonatomic,weak) id<DeviceListSetHeaderViewDelegate> delegate;
@property (nonatomic,assign,getter=isShowing) BOOL showing;

@property (weak, nonatomic) IBOutlet UIImageView *backGroudView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sceneTop;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *showSceneBtn;
@property (weak, nonatomic) IBOutlet UIView *secneView;

@property (weak, nonatomic) IBOutlet UIButton *activeButton;
@property (weak, nonatomic) IBOutlet UIButton *awayButton;
@property (weak, nonatomic) IBOutlet UILabel *autoLabel;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;

@property (weak, nonatomic) IBOutlet UIButton *homeSynButton;
@property (weak, nonatomic) IBOutlet UIButton *outSynButton;
@property (weak, nonatomic) IBOutlet UIButton *autoSynButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activeButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *awayButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autoLabelWidth;

@end
