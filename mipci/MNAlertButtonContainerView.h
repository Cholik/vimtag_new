//
//  MNAlertButtonContainerView.h
//  mipci
//
//  Created by mining on 16/1/28.
//
//

#import <UIKit/UIKit.h>
#import "MNSystemSettingsAlertView.h"

@interface MNAlertButtonContainerView : UIScrollView

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic) BOOL defaultTopLineVisible;

- (void)addButtonWithTitle:(NSString *)title type:(MNAlertViewButtonType)type handler:(MNAlertButtonHandler)handler;
@end
