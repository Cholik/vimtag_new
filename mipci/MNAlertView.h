//
//  MNAlertView.h
//  mipci
//
//  Created by mining on 15/7/25.
//
//

#import <UIKit/UIKit.h>

@class MNAlertView;
@protocol MNAlertViewDelegate <NSObject>

- (void)alertView:(MNAlertView *)alertView;

@end

@interface MNAlertView : UIView

@property (strong, nonatomic) id<MNAlertViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *saveNetworkLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *mainAlertView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;

@property (weak, nonatomic) IBOutlet UIButton *saveNetworkButton;
@property (assign, nonatomic) BOOL isSaveNetwork;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
@end
