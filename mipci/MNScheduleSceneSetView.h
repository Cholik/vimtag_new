//
//  MNScheduleSceneSetView.h
//  mipci
//
//  Created by 谢跃聪 on 16/12/19.
//
//

#import <UIKit/UIKit.h>

@protocol MNScheduleSceneSetViewDelegate <NSObject>

- (void)finishSceneSetView:(BOOL)select schedule:(long)schedule;

@end

@interface MNScheduleSceneSetView : UIView

@property (nonatomic,weak) id<MNScheduleSceneSetViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *setSceneView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *outButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *certainButton;

@end
