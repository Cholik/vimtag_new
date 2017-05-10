//
//  MNScreeningView.m
//  mipci
//
//  Created by mining on 15/9/24.
//
//

#import "MNScreeningView.h"
#import "MNConfiguration.h"


#define SNAPSHOT_EVENT              2001
#define SNAPSHOT_ALL                2002

#define RECORD_EVENT_ONEHOUR        2011
#define RECORD_EVENT_HALFHOUR       2012
#define RECORD_EVENT_FIVEMIN        2013
#define RECORD_EVENT_SHORTEST       2014

#define RECORD_ALL_ONEHOUR          2015
#define RECORD_ALL_HALFHOUR         2016
#define RECORD_ALL_FIVEMIN          2017

#define ALL_EVENT_ONEHOUR           2021
#define ALL_EVENT_HALFHOUR          2022
#define ALL_EVENT_FIVEMIN           2023
#define ALL_EVENT_SHORTEST          2024

#define ALL_ALL_ONEHOUR             2025
#define ALL_ALL_HALFHOUR            2026
#define ALL_ALL_FIVEMIN             2027

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define LABELFONTSIZE       [UIFont systemFontOfSize:14.0]
#define LABELTEXTCOLOR      [UIColor blackColor]

@implementation MNScreeningView

- (instancetype)initWithFrame:(CGRect)frame style:(MNScreeningInitStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUIWithStyle:style];
    }
    
    return self;
}

- (void)initUIWithStyle:(MNScreeningInitStyle)style
{
    MNConfiguration *configuration = [MNConfiguration shared_configuration];
    self.screeningInitStyle = style;
    
    //Init With Style
    _formatLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 80, 29)];
    _formatLabel.textAlignment = NSTextAlignmentCenter;
    _formatLabel.textColor = LABELTEXTCOLOR;
    _formatLabel.font = LABELFONTSIZE;
    _formatLabel.text = NSLocalizedString(@"mcs_format_options", nil);
    
//    CGSize titleSize = [NSLocalizedString(@"mcs_snapshot", nil) sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
//    CGFloat segmentWidth = 114;
//    if (titleSize.width > segmentWidth/2) {
//        segmentWidth = titleSize.width*2 + 5;
//    }
    
    _formatSegment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"mcs_snapshot", nil), NSLocalizedString(@"mcs_record", nil), NSLocalizedString(@"mcs_all", nil)]];
    _formatSegment.frame = CGRectMake(80, 5, 228, 29);
    _formatSegment.tintColor = configuration.switchTintColor;
    [_formatSegment setSelectedSegmentIndex:2];
    [_formatSegment addTarget:self action:@selector(showSelectResult) forControlEvents:UIControlEventValueChanged];
    
    if (_screeningInitStyle == MNScreeningStyleAll)
    {
        _categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 39, 80, 29)];
        _categoryLabel.textAlignment = NSTextAlignmentCenter;
        _categoryLabel.textColor = LABELTEXTCOLOR;
        _categoryLabel.font = LABELFONTSIZE;
        _categoryLabel.text = NSLocalizedString(@"mcs_category", nil);
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 73, 80, 29)];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = LABELTEXTCOLOR;
        _timeLabel.font = LABELFONTSIZE;
        _timeLabel.text = NSLocalizedString(@"mcs_time_length", nil);
        
        _categorySegment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"mcs_event", nil),  NSLocalizedString(@"mcs_all", nil)]];
        _categorySegment.frame = CGRectMake(80, 39, 152, 29);
        _categorySegment.tintColor = configuration.switchTintColor;
        _categorySegment.selectedSegmentIndex = 1;
        [_categorySegment addTarget:self action:@selector(showSelectResult) forControlEvents:UIControlEventValueChanged];
        
        _timeSegment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"mcs_one_hour", nil), NSLocalizedString(@"mcs_half_hour", nil),NSLocalizedString(@"mcs_five_min", nil)]];
        _timeSegment.frame = CGRectMake(80, 73, 228, 29);
        _timeSegment.tintColor = configuration.switchTintColor;
        [_timeSegment setSelectedSegmentIndex:1];
        [_timeSegment addTarget:self action:@selector(showSelectResult) forControlEvents:UIControlEventValueChanged];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(5, 107, 310, 1)];
        _lineView.backgroundColor = UIColorFromRGB(0xcccccc);
        
        //add subView
        [self addSubview:_categoryLabel];
        [self addSubview:_timeLabel];
        [self addSubview:_categorySegment];
        [self addSubview:_timeSegment];
    }
    else
    {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(5, 39, 310, 1)];
        _lineView.backgroundColor = UIColorFromRGB(0xcccccc);
    }
    
    //add subView
    [self addSubview:_formatSegment];
    [self addSubview:_formatLabel];
    [self addSubview:_lineView];
}

- (void)showSelectResult
{
    if (_screeningInitStyle == MNScreeningStyleAll)
    {
        if (_formatSegment.selectedSegmentIndex == 0)
        {
            self.selectStyle = MNSelectStyleSnapshot;
            switch (_categorySegment.selectedSegmentIndex) {
                case 0:
                    _selectResult = SNAPSHOT_EVENT;
                    break;
                case 1:
                    _selectResult = SNAPSHOT_ALL;
            }
        }
        else if (_formatSegment.selectedSegmentIndex == 1)
        {
            if (_categorySegment.selectedSegmentIndex == 0)
            {
                self.selectStyle = MNSelectStyleEvent;
                switch (_timeSegment.selectedSegmentIndex)
                {
                    case 0:
                        _selectResult = RECORD_EVENT_ONEHOUR;
                        break;
                    case 1:
                        _selectResult = RECORD_EVENT_HALFHOUR;
                        break;
                    case 2:
                        _selectResult = RECORD_EVENT_FIVEMIN;
                        break;
                    case 3:
                        _selectResult = RECORD_EVENT_SHORTEST;
                }
            }
            else
            {
                self.selectStyle = MNSelectStyleAll;
                switch (_timeSegment.selectedSegmentIndex)
                {
                    case 0:
                        _selectResult = RECORD_ALL_ONEHOUR;
                        break;
                    case 1:
                        _selectResult = RECORD_ALL_HALFHOUR;
                        break;
                    case 2:
                        _selectResult = RECORD_ALL_FIVEMIN;
                        break;
                }
            }
        }
        else
        {
            if (_categorySegment.selectedSegmentIndex == 0)
            {
                self.selectStyle = MNSelectStyleEvent;
                switch (_timeSegment.selectedSegmentIndex)
                {
                    case 0:
                        _selectResult = ALL_EVENT_ONEHOUR;
                        break;
                    case 1:
                        _selectResult = ALL_EVENT_HALFHOUR;
                        break;
                    case 2:
                        _selectResult = ALL_EVENT_FIVEMIN;
                        break;
                    case 3:
                        _selectResult = ALL_EVENT_SHORTEST;
                }
            }
            else
            {
                self.selectStyle = MNSelectStyleAll;
                switch (_timeSegment.selectedSegmentIndex)
                {
                    case 0:
                        _selectResult = ALL_ALL_ONEHOUR;
                        break;
                    case 1:
                        _selectResult = ALL_ALL_HALFHOUR;
                        break;
                    case 2:
                        _selectResult = ALL_ALL_FIVEMIN;
                        break;
                }
            }
        }
    }
    else
    {
        switch (_formatSegment.selectedSegmentIndex) {
            case 0:
                _selectResult = SNAPSHOT_ALL;
                break;
            case 1:
                _selectResult = RECORD_ALL_HALFHOUR;
        }
    }
//    NSLog(@"the reselt is [%ld] \n",(long)_selectResult);
    [self.delegate filteringResults:_selectResult];
}

#pragma mark - Set Screening Style
- (void)setSelectStyle:(MNSelectStyle)selectStyle
{
    if (selectStyle == MNSelectStyleSnapshot)
    {
        _timeLabel.hidden = YES;
        _timeSegment.hidden = YES;
        _lineView.frame = CGRectMake(5, 73, CGRectGetWidth(_lineView.frame), 1);
        CGRect frame = self.frame;
        frame.size.height = 75;
        self.frame = frame;
    }
    else
    {
        _timeLabel.hidden = NO;
        _timeSegment.hidden = NO;
        _lineView.frame = CGRectMake(5, 107, CGRectGetWidth(_lineView.frame), 1);
        CGRect frame = self.frame;
        frame.size.height = 109;
        self.frame = frame;
    }
    
    NSUInteger index = _timeSegment.numberOfSegments;
    
    if (selectStyle == MNSelectStyleAll)
    {
        if (index > 3)
        {
            [_timeSegment removeSegmentAtIndex:index - 1 animated:NO];
        }
        if (_selectResult == RECORD_EVENT_SHORTEST || (_timeSegment.selectedSegmentIndex < 0 || _timeSegment.selectedSegmentIndex > 3))
        {
            _timeSegment.selectedSegmentIndex = 1;
            [self.delegate filteringResults:_selectResult];
        }
    }
    else if (selectStyle == MNSelectStyleEvent)
    {
        if (index < 4)
        {
            [_timeSegment insertSegmentWithTitle:NSLocalizedString(@"mcs_shortest", nil) atIndex:index animated:NO];
        }
    }
}

@end
