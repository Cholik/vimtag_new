//
//  MNAlertButtonItem.h
//  mipci
//
//  Created by mining on 16/1/28.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNAlertViewButtonType) {
    MNAlertViewButtonTypeDefault = 0,
    MNAlertViewButtonTypeCustom = 1,
    MNAlertViewButtonTypeCancel = 2
};

@class MNSystemSettingsAlertView;
@class MNAlertButtonItem;
typedef void(^MNAlertButtonHandler)(MNSystemSettingsAlertView *alertView, MNAlertButtonItem *button);

@interface MNAlertButtonItem : UIButton


@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) MNAlertViewButtonType type;
@property (nonatomic, copy) MNAlertButtonHandler action;
@property (nonatomic) BOOL defaultRightLineVisible;

@end