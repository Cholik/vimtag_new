//
//  MNCustomDatePicker.h
//  mipci
//
//  Created by weken on 15/3/20.
//
//

#import <UIKit/UIKit.h>
@class MNCustomDatePicker;
@protocol MNCustomDatePickerDelegate <NSObject>

- (void)datePicker:(MNCustomDatePicker*)datePicker value:(NSDate *)date;

@end

@interface MNCustomDatePicker : UIView
@property (assign, nonatomic) UIDatePickerMode datePickerMode;
@property (weak, nonatomic) id<MNCustomDatePickerDelegate> delegate;
@property (strong, nonatomic) NSDate            *customSelectDate;
@end
