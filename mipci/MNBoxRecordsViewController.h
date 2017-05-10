//
//  MNBoxRecordsViewController.h
//  mipci
//
//  Created by mining on 15/10/12.
//
//

#import <UIKit/UIKit.h>
#import "MNScreeningView.h"
#import "MNCalendar.h"
#import "MNCustomDatePicker.h"


@interface MNBoxRecordsViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, MNScreeningViewDelegate, MNCalendarDataSource, MNCalendarDelegate, MNCustomDatePickerDelegate>

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *boxID;

@property (weak, nonatomic) IBOutlet UIButton *calendarButton;
@property (weak, nonatomic) IBOutlet UIButton *fillerButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectSegment;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *emptyPromptView;
@property (weak, nonatomic) IBOutlet UILabel *emptyPromptLabel;
@property (weak, nonatomic) IBOutlet UIImageView *emptyPromptImage;

@property (strong, nonatomic)   UIImage             *cellImage;
@property (strong, nonatomic)   MNScreeningView     *screeningView;
@property (strong, nonatomic)   MNCalendar          *calendar;

@property (assign, nonatomic)   BOOL                is_datePickerShow;
@property (strong, nonatomic)   MNCustomDatePicker  *datePicker;

- (void)initLayoutConstraint;
- (void)updateLayoutConstraint;
- (void)createDatePickerWithMode:(UIDatePickerMode)datePickerMode;

@end
