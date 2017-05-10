//
//  MNCustomDatePicker.m
//  mipci
//
//  Created by weken on 15/3/20.
//
//

#import "MNCustomDatePicker.h"
@interface MNCustomDatePicker ()
@property (strong, nonatomic) UIDatePicker *datePicker;
@end

@implementation MNCustomDatePicker

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.frame = CGRectMake(0, 0, 250, 214);
        
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:calendar];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        _datePicker.minimumDate = [dateFormatter dateFromString:@"1970-01-01 00:00:00"];
        _datePicker.maximumDate = [dateFormatter dateFromString:@"2099-01-01 00:00:00"];
//        [_datePicker addTarget:self action:@selector(dateValueChange:) forControlEvents:UIControlEventValueChanged];
        
        UIButton *sureButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 175, 230, 32)];
        [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureButton setBackgroundColor:[UIColor redColor]];
//        [sureButton setBackgroundImage:[[UIImage imageNamed:@"btn_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [sureButton setTitle:NSLocalizedString(@"mcs_ok", nil) forState:UIControlStateNormal];
        [sureButton addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_datePicker];
        [self addSubview:sureButton];
                
        self.frame = CGRectMake(0, 0, 250, 216);
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        self.layer.shadowOffset = CGSizeMake(-5.0f, 5.0f);
        self.layer.shadowOpacity = 2.0f;
        self.layer.shadowRadius = 2.0f;
    }
    
    return self;
}

-(void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
    _datePickerMode = datePickerMode;
    _datePicker.datePickerMode = datePickerMode;
}

- (void)setCustomSelectDate:(NSDate *)customSelectDate
{
    if (customSelectDate) {
        _datePicker.date = customSelectDate;
    }
}
#pragma mark - Action

-(void)sure:(id)sender
{
    NSDate *date = _datePicker.date;
    if ([self.delegate respondsToSelector:@selector(datePicker:value:)]) {
        [self.delegate datePicker:(MNCustomDatePicker*)_datePicker value:date];
    }
    
    [UIView animateWithDuration:1.0 animations:^{
        self.frame = CGRectNull;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dateValueChange:(UIDatePicker *)datePicker
{
    NSDate *date = datePicker.date;
    if ([self.delegate respondsToSelector:@selector(datePicker:value:)]) {
            [self.delegate datePicker:(MNCustomDatePicker*)datePicker value:date];
        }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
