//
//  MNBoxRecordsViewController.m
//  mipci
//
//  Created by mining on 15/10/12.
//
//

#import "MNBoxRecordsViewController.h"
#import "AppDelegate.h"
#import "mipc_agent.h"
#import "mcore/mcore.h"
#import "mme_ios.h"
#import "MIPCUtils.h"
#import "MNProgressHUD.h"
#import "mios_core_frameworks.h"
#import "MNSnapshotViewCell.h"
#import "MNConfiguration.h"
#import "MNBoxSegmentViewCell.h"
#import "MNBoxPlayViewController.h"
#import "MNBoxHeaderView.h"
#import "MNToastView.h"
#import "MNInfoPromptView.h"
#import "MNSnapshotViewController.h"
#import "UIImageView+refresh.h"

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

#define DEFAULT_LINE_COUNTS         2
#define DEFAULT_CELL_MARGIN         4
#define DEFAULT_EDGE_MARGIN         5

#define FIVE_MINUTES                (5*60*1000)
#define HALF_AN_HOUR                (30*60*1000)
#define ONE_HOUR                    (60*60*1000)
#define RECORD_SEG_INTERVAL         (7*1000)    //(2*1000)

//#define PULL_AREA_HEIGTH 60.0f
//#define PULL_TRIGGER_HEIGHT (PULL_AREA_HEIGTH + 5.0f)
//#define PULL_DISTANCE_TO_VIEW 10.0f

#define MOTION_FLAG_OLD     1
#define MOTION_FLAG_NEW     8
#define SNAPSHOT_FLAG       2
#define IO_FLAG             4
#define DOOR_FLAG           16
#define SOS_FLAG            32

@interface MNRecordObj : NSObject

@property (copy, nonatomic) NSMutableArray *recordArray;
@property (assign, nonatomic) BOOL is_photo;
@property (assign, nonatomic) long motionFlag;      //Old flag is 1, new flag is 8
@property (assign, nonatomic) long snapshotFlag;    //Flag is 2
@property (assign, nonatomic) long ioFlag;          //Flag is 4
@property (assign, nonatomic) long doorFlag;        //Flag is 16
@property (assign, nonatomic) long sosFlag;         //Flag is 32

- (void)setAllFlagWithSegFlag:(long)flag;
- (void)resetAllFlag;

@end

@implementation MNRecordObj

- (NSMutableArray *)recordArray
{
    @synchronized(self){
        if (nil == _recordArray) {
            _recordArray = [NSMutableArray array];
        }
        
        return _recordArray;
    }
}

- (void)setAllFlagWithSegFlag:(long)flag
{
    self.sosFlag = flag/SOS_FLAG ? 1 : self.sosFlag;
    self.doorFlag = (flag%SOS_FLAG)/DOOR_FLAG ? 1 : self.doorFlag;
    self.motionFlag = ((flag%SOS_FLAG)%DOOR_FLAG)/MOTION_FLAG_NEW ? 1 : self.motionFlag;
    self.ioFlag = (((flag%SOS_FLAG)%DOOR_FLAG)%MOTION_FLAG_NEW)/IO_FLAG ? 1 : self.ioFlag;
    self.snapshotFlag = ((((flag%SOS_FLAG)%DOOR_FLAG)%MOTION_FLAG_NEW)%IO_FLAG)/SNAPSHOT_FLAG ? 1 : self.snapshotFlag;
    self.motionFlag = ((((flag%SOS_FLAG)%DOOR_FLAG)%MOTION_FLAG_NEW)%IO_FLAG)%SNAPSHOT_FLAG ? 1 : self.motionFlag;
}
//Clear all flag
- (void)resetAllFlag
{
    self.motionFlag = 0;
    self.snapshotFlag = 0;
    self.ioFlag = 0;
    self.doorFlag = 0;
    self.sosFlag = 0;
    self.is_photo = NO;
}

@end

@interface MNBoxRecordsViewController ()

@property (strong, nonatomic)   mipc_agent              *agent;
@property (assign, nonatomic)   BOOL                    isViewAppearing;
@property (weak, nonatomic)     AppDelegate             *app;
@property (weak, nonatomic)   MNConfiguration         *configuration;
@property (strong, nonatomic)   MNProgressHUD           *progressHUD;
@property (copy, nonatomic)   NSMutableArray          *messagesArray;
@property (copy, nonatomic)   NSMutableArray          *recordSegmentArray;
@property (assign, nonatomic)   CGSize                  transitionToSize;
@property (assign, nonatomic)   NSInteger               selectResult;
@property (strong, nonatomic)   NSDate                  *selectedDate;
@property (copy, nonatomic)   NSMutableArray          *dateSliceArray;
@property (copy, nonatomic)   NSMutableArray          *allDateArray;
@property (strong, nonatomic)   UIActivityIndicatorView *pullDownActivityView;
@property (assign, nonatomic)   BOOL                    isRefreshing;
@property (assign, nonatomic)   BOOL                    downFinishReloadData;
@property (strong, nonatomic)   UILabel                 *downRefreshLabel;
@property (assign, nonatomic)   BOOL                    isScrollerViewRelease;
//@property (strong, nonatomic)   NSDate                  *refreshDate;
@property (copy, nonatomic)   NSMutableArray          *messages;
@property (strong, nonatomic)   MNRecordObj             *deleteArray;

@property (strong,nonatomic)    UIView                  *upRefreshView;
@property (strong,nonatomic)    UILabel                 *upRefreshLabel;
@property (strong,nonatomic)    UIActivityIndicatorView *pullUpActivityView;
@property (strong,nonatomic)    NSDate                  *previousDate;
@property (strong,nonatomic)    NSDate                  *laterDate;
@property (strong,nonatomic)    NSDate                  *lastUpDate;
@property (strong,nonatomic)    NSDate                  *lastDownDate;
@property (assign,nonatomic)    BOOL                    isPreviosRefresh;
@property (assign,nonatomic)    BOOL                    upFinishReloadData;
@property (assign,nonatomic)    CGFloat                 _contentOffsetY;
@property (strong ,nonatomic) UIImageView *refreshDownImageView;
@property (strong ,nonatomic) UIImageView *refreshUpImageView;
@property (strong, nonatomic) NSTimer *refreshUpTimer;
@property (strong, nonatomic) NSTimer *refreshDownTimer;
@property (assign, nonatomic) int timeDifference;

@property (assign, nonatomic) BOOL      is_getSD;

@end

@implementation MNBoxRecordsViewController

static NSString * const reuseIdentifier = @"Cell";

- (NSMutableArray *)messagesArray
{
    @synchronized(self){
        if (nil == _messagesArray) {
            _messagesArray = [NSMutableArray array];
        }
        
        return _messagesArray;
    }
}

- (NSMutableArray *)recordSegmentArray
{
    @synchronized(self){
        if (nil == _recordSegmentArray) {
            _recordSegmentArray = [NSMutableArray array];
        }
        
        return _recordSegmentArray;
    }
}

- (NSMutableArray *)dateSliceArray
{
    @synchronized(self){
        if (nil == _dateSliceArray) {
            _dateSliceArray = [NSMutableArray array];
        }
        
        return _dateSliceArray;
    }
}

- (NSMutableArray *)allDateArray
{
    @synchronized(self){
        if (nil == _allDateArray) {
            _allDateArray = [NSMutableArray array];
        }
        
        return _allDateArray;
    }
}

- (NSMutableArray *)messages
{
    @synchronized(self){
        if (nil == _messages) {
            _messages = [NSMutableArray array];
        }
        
        return _messages;
    }
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

-(MNProgressHUD *)progressHUD
{
    if (nil == _progressHUD) {
        _progressHUD = [[MNProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_progressHUD];
        _progressHUD.color = [UIColor colorWithWhite:1.0f alpha:0.8f];
        _progressHUD.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
        _progressHUD.labelText = NSLocalizedString(@"mcs_loading", nil);
        _progressHUD.labelColor = [UIColor grayColor];
        if (self.app.is_vimtag) {
            _progressHUD.activityIndicatorColor = [UIColor colorWithRed:0 green:168.0/255 blue:185.0/255 alpha:1.0f];
        }
        else {
            _progressHUD.activityIndicatorColor = [UIColor grayColor];
        }
        
    }
    
    return  _progressHUD;
}
-(UIImageView *)refreshUpImageView
{
    if (_refreshUpImageView == nil) {
        _refreshUpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_vimtagRefresh"]];
    }
    return _refreshUpImageView;
}

-(UIImageView *)refreshDownImageView
{
    if (_refreshDownImageView == nil) {
        _refreshDownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vt_vimtagRefresh"]];
    }
    return _refreshDownImageView;
}

- (void)dealloc
{

}

#pragma mark - life cycle
- (void)initUI
{
    self.collectionView.alwaysBounceVertical = YES;
    
    [_selectSegment setTitle:NSLocalizedString(@"mcs_device", nil) forSegmentAtIndex:0];
    [_selectSegment setTitle:NSLocalizedString(@"mcs_local", nil) forSegmentAtIndex:1];
    _selectSegment.tintColor = self.configuration.switchTintColor;
    //test
    _selectSegment.hidden = YES;
    _emptyPromptLabel.text = NSLocalizedString(@"mcs_no_history_record", nil);

    if (self.app.is_vimtag)
    {
        //add filter View
        _screeningView = [[MNScreeningView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 109) style:MNScreeningStyleAll];
        _screeningView.lineView.frame = CGRectMake(5, _screeningView.frame.size.height - 2, self.view.frame.size.width - 10, 1);
        _screeningView.delegate = self;
        [self.view addSubview:_screeningView];
        
        //vimtag calender
        _calendar = [[MNCalendar alloc] initWithFrame:CGRectMake(0, 0 , self.view.frame.size.width, self.view.frame.size.width)];
        _calendar.delegate = self;
        [self.view addSubview:_calendar];
    }
    self.selectResult = ALL_ALL_HALFHOUR;
    
    //Refresh prompt
    _downRefreshLabel = [[UILabel alloc] init];
    CGRect downRefreshLabelFrame = _downRefreshLabel.frame;
    downRefreshLabelFrame = CGRectMake(0, -35, 300, 40);
    //    downRefreshLabelFrame.origin.y = -35;
    _downRefreshLabel.frame = downRefreshLabelFrame;
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.collectionView.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    
    _downRefreshLabel.font = [UIFont systemFontOfSize:16];
    _downRefreshLabel.textAlignment = NSTextAlignmentCenter;
    _downRefreshLabel.textColor = self.configuration.labelTextColor;
    _downRefreshLabel.hidden = YES;
    
    _upRefreshLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
    
    _upRefreshLabel.font = [UIFont systemFontOfSize:16];
    _upRefreshLabel.textColor = self.configuration.labelTextColor;
    _upRefreshLabel.textAlignment = NSTextAlignmentCenter;
    
    //get _downRefreshLabel.text width
    NSString *downRefreshLabelText = NSLocalizedString(@"mcs_refreshing", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        labelSize = [downRefreshLabelText boundingRectWithSize:CGSizeMake(0, 0)
                                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:attributes
                                                       context:nil].size;
        
        labelSize.width = ceil(labelSize.width);
    }
    if (self.app.is_vimtag) {
        
        [self.refreshDownImageView setImageViewFrame:self.collectionView with:labelSize];
        
        CGPoint upCenter = self.refreshUpImageView.center;
        upCenter.x = self.collectionView.center.x - labelSize.width / 2.0 - 15;
        self.refreshUpImageView.center = upCenter;
        self.refreshUpImageView.hidden = YES;
        self.refreshDownImageView.hidden = YES;
    }
    else {
        //activity for refresh
        _pullDownActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _pullDownActivityView.color = self.configuration.labelTextColor;
        CGRect frame = _pullDownActivityView.frame;
        frame.origin.y =  -25;
        _pullDownActivityView.frame = frame;
        _pullDownActivityView.hidesWhenStopped = YES;
        CGPoint center =_pullDownActivityView.center;
        center.x = self.collectionView.center.x - labelSize.width / 2.0 - 15;
        _pullDownActivityView.center = center;
        
        
        _pullUpActivityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _pullUpActivityView.color = self.configuration.labelTextColor;
        _pullUpActivityView.hidesWhenStopped = YES;
        CGPoint upCenter = _pullUpActivityView.center;
        upCenter.x = self.collectionView.center.x - labelSize.width / 2.0 - 15;
        _pullUpActivityView.center = upCenter;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    _isRefreshing = NO;
    _downFinishReloadData = YES;
    
    m_dev *dev = [self.agent.devs get_dev_by_sn:_boxID];
    if ([dev.type isEqualToString:@"IPC"]) {
        _is_getSD = NO;
    } else {
        _is_getSD = YES;
    }
    if (dev.timeZone.length) {
        self.timeDifference = [dev.timeZone intValue] * 60 * 60;
    }else {
        self.timeDifference = [self getTimeIntervalBetweenTimeZoneAndUTC];
    }
    
    //Get all days in box data
    mcall_ctx_box_get *ctx = [[mcall_ctx_box_get alloc] init];
    ctx.sn = _boxID;
    ctx.dev_sn = _deviceID;
    ctx.target = self;
    ctx.flag = 2;
    ctx.on_event = @selector(box_get_done:);
    
    [self.agent box_get:ctx];
    [self.progressHUD show:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _isRefreshing = NO;
    _isViewAppearing = YES;
    _transitionToSize = self.view.bounds.size;
    self.app.is_vimtag ? [_screeningView setHidden:YES] : nil;
    [_calendar setHidden:YES];
    _is_datePickerShow = NO;
    //    [_selectSegment setHidden:NO];
    [self initLayoutConstraint];
    
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _isViewAppearing = NO;
    self.app.is_vimtag ? [_screeningView setHidden:YES] : nil;
    [_calendar setHidden:YES];
    [self initLayoutConstraint];
    [MNInfoPromptView hideAll:self.navigationController];
    //    [_selectSegment setHidden:NO];
    if (self.app.is_vimtag) {
        [self.refreshUpTimer invalidate];
        [self.refreshDownTimer invalidate];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self cancelNetworkRequest];
}

#pragma mark - collection add refreshView
-(BOOL)collectionViewAddRefreshView
{
    if (!_upRefreshView) {
        _upRefreshView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    }
    CGRect frame = _upRefreshView.frame;
    if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
        frame.origin.y = self.collectionView.contentSize.height + 5;
    }
    else{
        frame.origin.y = self.collectionView .frame.size.height +5;
    }
    _upRefreshView.frame = frame;
    [self.collectionView addSubview:_upRefreshView];
    
    CGPoint labelCentert = _upRefreshLabel.center;
    labelCentert.x = _upRefreshView.frame.size.width / 2;
    _upRefreshLabel.center = labelCentert;
    [_upRefreshView addSubview:_upRefreshLabel];
    if (self.app.is_vimtag) {
        CGPoint activityCenter = self.refreshUpImageView.center;
        activityCenter.y = _upRefreshView.frame.size.height / 2;
        self.refreshUpImageView.center = activityCenter;
        [_upRefreshView addSubview:self.refreshUpImageView];
    }
    else {
        CGPoint activityCenter = _pullUpActivityView.center;
        activityCenter.y = _upRefreshView.frame.size.height / 2;
        _pullUpActivityView.center = activityCenter;
        [_upRefreshView addSubview:_pullUpActivityView];
    }
    return YES;
}


#pragma mark - box_get_done
- (void)box_get_done:(mcall_ret_box_get*)ret
{
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil != ret.result) {
        //FIXME:add alert
        _upFinishReloadData = YES;
        _downFinishReloadData = YES;
        if ([ret.result isEqualToString:@"ret.no.rsp"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_access_server_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        return;
    }
    
    self.dateSliceArray = ret.date_info_array;
    [self getAllDateArray];
}

-(void)box_get_segs_done:(mcall_ret_box_get*)ret
{
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil != ret.result) {
        //FIXME:add alert
        return;
    }
    //Cancel Load Image
    [self cancelNetworkRequest];
    
    [self.messagesArray removeAllObjects];
    [self.recordSegmentArray removeAllObjects];
    
    NSMutableArray *tmpArray = [ret.seg_sdc_array mutableCopy];
    if ([tmpArray lastObject]) {
        [self.recordSegmentArray addObject:tmpArray];
    }
    [self mergeBoxSegmentMessage];
    
    //reload data
    self.messages = [self separateArrayUsingDate];
    [self.collectionView reloadData];
    [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];
    if (self.app.is_vimtag && !_emptyPromptView.hidden && !self.is_getSD) {
        [self checkSDCard];
    }
}

- (void)box_get_segs_refresh_done:(mcall_ret_box_get*)ret
{
    if (_isPreviosRefresh) {
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
            __contentOffsetY = self.collectionView.contentSize.height - self.collectionView.frame.size.height;
        }else{
            __contentOffsetY = 0;
        }
    }else{
        __contentOffsetY = 0;
    }
    
    if (_isScrollerViewRelease)
    {
        [self.collectionView setContentOffset:CGPointMake(0, __contentOffsetY) animated:YES];

    }
    _isRefreshing = NO;
    if (!_isViewAppearing) {
        return;
    }
    
    if (nil != ret.result) {
        //FIXME:add alert
        if ([ret.result isEqualToString:@"ret.no.rsp"]) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_access_server_failed", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        }
        if (_isPreviosRefresh) {
            _previousDate = _lastUpDate;
        }
        else{
            _laterDate = _lastDownDate;
        }
        return;
    }
    
    //Cancel Load Image
    [self cancelNetworkRequest];
    
    //deal with previous date
    [self.messagesArray removeAllObjects];
    
    NSMutableArray *tmpArray = [ret.seg_sdc_array mutableCopy];
    if ([tmpArray lastObject]) {
        if (_isPreviosRefresh) {
            [self.recordSegmentArray insertObject:tmpArray atIndex:0];
        }
        else{
            [self.recordSegmentArray addObject:tmpArray];
        }
    }
    [self mergeBoxSegmentMessage];
    
    self.messages = [self separateArrayUsingDate];
    [self.collectionView reloadData];
    [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];
}

- (void)box_set_done:(mcall_ret_box_set *)ret
{
    [_progressHUD hide:YES];
    if (!_isViewAppearing) {
        return;
    }
    if ([ret.result isEqualToString:@"ret.permission.denied"]) {
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_permission_denied", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_permission_denied", nil)]];
        }
        return;
    }else if(nil != ret.result){
        if (self.app.is_InfoPrompt) {
            [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_delete_fail", nil) style:MNInfoPromptViewStyleError isModal:NO navigation:self.navigationController];
        } else {
            [self.view.superview addSubview:[MNToastView failToast:NSLocalizedString(@"mcs_delete_fail", nil)]];
        }
        return;
    }
    
    if (self.app.is_InfoPrompt) {
        [MNInfoPromptView showAndHideWithText:NSLocalizedString(@"mcs_delete_success", nil) style:MNInfoPromptViewStyleInfo isModal:NO navigation:self.navigationController];
    }
    else{
        [self.view.superview addSubview:[MNToastView successToast:NSLocalizedString(@"mcs_delete_success", nil)]];
    }
    
    @try {
        //reload data
        int recordIndex = 0;
        int arrayIndex = 0;
        int deleteFlag = 0;
        for ( ; recordIndex < _recordSegmentArray.count; recordIndex++)
        {
            NSString *deleteDate = [self stringFromLong:(((seg_obj*)_deleteArray.recordArray.firstObject).start_time)];
            NSString *compareDate = [self stringFromLong:(((seg_obj*)([_recordSegmentArray[recordIndex] firstObject])).start_time)];
            if ([deleteDate isEqualToString:compareDate]) {
                for ( ; arrayIndex < [_recordSegmentArray[recordIndex] count]; arrayIndex++)
                {
                    seg_obj *seg = (_recordSegmentArray[recordIndex])[arrayIndex];
                    if (((seg_obj*)_deleteArray.recordArray.firstObject).start_time == seg.start_time) {
                        deleteFlag = 1;
                        break;
                    }
                }
                break;
            }
        }
        if (deleteFlag)
        {
            //Cancel Load Image
            [self cancelNetworkRequest];
            
            NSRange range = NSMakeRange(arrayIndex, _deleteArray.recordArray.count);
            [_recordSegmentArray[recordIndex] removeObjectsInRange:range];
            
            [self.messagesArray removeAllObjects];
            [self mergeBoxSegmentMessage];
            self.messages = [self separateArrayUsingDate];
            [self.collectionView reloadData];
            [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    } @finally {
        
    }
}

- (void)checkSDCard
{
    _emptyPromptView.hidden = YES;
    _is_getSD = YES;
    mcall_ctx_sd_get *ctx = [[mcall_ctx_sd_get alloc] init];
    ctx.sn = _deviceID;
    ctx.on_event = @selector(sd_get_done:);
    ctx.target = self;

    [self.agent sd_get:ctx];
    [self.progressHUD show:YES];
}

- (void)sd_get_done:(mcall_ret_sd_get *)ret
{
    [self.progressHUD hide:YES];
    if (!_isViewAppearing) {
        return;
    }
    _emptyPromptView.hidden = NO;

    if(nil == ret.result)
    {
        if ([@"empty" isEqualToString:ret.status])
        {
            _emptyPromptImage.highlighted = YES;
            _emptyPromptLabel.text = NSLocalizedString(@"mcs_record_empty_set_sd", nil);
        }
    }
}


- (void)getAllDateArray
{
    if ([self.allDateArray lastObject]) {
        [self.allDateArray removeAllObjects];
    }
    
//    int i = 0;
    for (date_info_obj *date_info in self.dateSliceArray)
    {
        NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:date_info.date];
//        NSDate *destinationDateNow = [[NSDate alloc] initWithTimeInterval:[self getTimeIntervalBetweenTimeZoneAndUTC] sinceDate:currentDate];
        NSDate *destinationDateNow = [[NSDate alloc] initWithTimeInterval:self.timeDifference sinceDate:currentDate];
//        NSLog(@"%d:%@ flag:%ld,%ld",i++,destinationDateNow,date_info.flag,date_info.date);
//        NSLog(@"%@ | %@",destinationDateNow, currentDate);
        
        calendar_info_obj *calendar_info = [[calendar_info_obj alloc] init];
        calendar_info.date = destinationDateNow;
        calendar_info.date = [self extractDate:calendar_info.date];
        calendar_info.flag = date_info.flag;
        //        NSLog(@"%@",calendar_info.date);
        if ([self.allDateArray lastObject])
        {
            if ([((calendar_info_obj *)(self.allDateArray.lastObject)).date timeIntervalSince1970] == [calendar_info.date timeIntervalSince1970])
            {
                if (calendar_info.flag) {
                    ((calendar_info_obj *)(self.allDateArray.lastObject)).flag = calendar_info.flag;
                }
            }
            else  if ([((calendar_info_obj *)(self.allDateArray.lastObject)).date timeIntervalSince1970] < [calendar_info.date timeIntervalSince1970])
            {
                if (self.app.is_vimtag) {
                    //Check up date info unusual or date info is not in the date range
                    if ([_calendar isDateInRange:[NSDate dateWithTimeInterval:-7*24*60*60 sinceDate:calendar_info.date] ]) {
                        [self.allDateArray addObject:calendar_info];
                    }
                } else {
                    [self.allDateArray addObject:calendar_info];
                }
            }
        }
        else
        {
            if (self.app.is_vimtag) {
                //Check up date info unusual or date info is not in the date range
                if ([_calendar isDateInRange:[NSDate dateWithTimeInterval:-7*24*60*60 sinceDate:calendar_info.date]]) {
                    [self.allDateArray addObject:calendar_info];
                }
            } else {
                [self.allDateArray addObject:calendar_info];
            }
        }
    }
    
    if (self.app.is_vimtag) {
//        NSMutableArray *copyArray = [self.allDateArray copy];
        _calendar.allDatesArray = self.allDateArray;

        [_calendar reloadData];
    }
    
    //for mipc and oem
    NSDate *datePickerDate = [NSDate date];
    
    if ([self.allDateArray lastObject])
    {
        if ([self.allDateArray count] == 1) {
            _upFinishReloadData = YES;
            _downFinishReloadData = YES;
        }
        NSDate *recentlyDate = [NSDate date];
        for (long i = self.allDateArray.count; i > 0; i--) {
//            NSLog(@"%ld,%@", i-1, ((calendar_info_obj *)self.allDateArray[i-1]).date);
            if (1 == i) {
                recentlyDate = ((calendar_info_obj *)self.allDateArray[i-1]).date;
                break;
            }
            if ([recentlyDate timeIntervalSince1970] >= [((calendar_info_obj *)self.allDateArray[i-1]).date timeIntervalSince1970]) {
                recentlyDate = ((calendar_info_obj *)self.allDateArray[i-1]).date;
                break;
            }
        }
//        NSDate *recentlyDate = ((calendar_info_obj *)self.allDateArray.lastObject).date;
        [_calendar selectDate:recentlyDate];
        recentlyDate = [self extractDate:recentlyDate];
        datePickerDate = recentlyDate;
        
//        NSTimeInterval timeInterval = [recentlyDate timeIntervalSince1970] * 1000 - [self getTimeIntervalBetweenTimeZoneAndUTC]*1000;
        NSTimeInterval timeInterval = [recentlyDate timeIntervalSince1970] * 1000 - self.timeDifference * 1000;
        long long startTime = timeInterval ;
        long long endTime = startTime + 24*60*60*1000;
        
        mcall_ctx_box_get *ctx = [[mcall_ctx_box_get alloc] init];
        ctx.sn = _boxID;
        ctx.dev_sn = _deviceID;
        ctx.target = self;
        ctx.flag = 8;
        ctx.on_event = @selector(box_get_segs_done:);
        ctx.start_time = startTime;
        ctx.end_time = endTime;
        
        [self.agent box_get:ctx];
    }
    else
    {
        [_calendar selectDate:[NSDate date]];
        [self.progressHUD hide:YES];
        _upFinishReloadData = YES;
        _downFinishReloadData = YES;
        [_emptyPromptView setHidden:NO];
        if (self.app.is_vimtag && !_emptyPromptView.hidden && !self.is_getSD) {
            [self checkSDCard];
        }
    }
    self.selectedDate = self.app.is_vimtag ? [NSDate dateWithTimeIntervalSince1970:([[self extractDate:_calendar.selectedDate] timeIntervalSince1970] + 24*60*60)] : datePickerDate;
    self.previousDate = [_selectedDate copy];
    self.laterDate = [_selectedDate copy];
    self.lastUpDate = [_selectedDate copy];
    self.lastDownDate = [_selectedDate copy];
}

- (NSMutableArray *)separateArrayUsingDate
{
    NSString *compareDateKey;
    NSString *anotherDateKey;
    NSMutableArray *separetedArray = [NSMutableArray array];
    //    int daySeconds = 24 * 60 * 60;
    int currentIndex = 0;
    
    for (int i = 0; i < _messagesArray.count; i++)
    {
//        NSMutableArray *tmparray = _messagesArray[i];
        MNRecordObj *recordObj = _messagesArray[i];
        if (_messagesArray.count == 1) {
            compareDateKey = [self stringFromLong:(((seg_obj *)recordObj.recordArray.lastObject).start_time)];
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
            NSMutableArray *messages = [NSMutableArray arrayWithArray:[_messagesArray objectsAtIndexes:indexSet]];
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            [dictionary setObject:compareDateKey forKey:@"date"];
            [dictionary setObject:messages forKey:@"messages"];
            [separetedArray addObject:dictionary];
        }
        if (0 == i) {
            compareDateKey = [self stringFromLong:(((seg_obj *)recordObj.recordArray.lastObject).start_time)];
        }
        else
        {
            anotherDateKey = [self stringFromLong:(((seg_obj *)recordObj.recordArray.lastObject).start_time)];
            if (![anotherDateKey isEqualToString:compareDateKey])
            {
                int length = i - currentIndex;
                NSRange range = NSMakeRange(currentIndex, length);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                NSMutableArray *messages = [NSMutableArray arrayWithArray:[_messagesArray objectsAtIndexes:indexSet]];
                
                currentIndex = i;
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [dictionary setObject:messages forKey:@"messages"];
                [dictionary setObject:compareDateKey forKey:@"date"];
                
                [separetedArray addObject:dictionary];
                
                compareDateKey = anotherDateKey;   //exchange
            }
            if (i == _messagesArray.count - 1)
            {
                int length = i - currentIndex + 1;
                NSRange range = NSMakeRange(currentIndex, length);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                NSMutableArray *messages = [NSMutableArray arrayWithArray:[_messagesArray objectsAtIndexes:indexSet]];
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [dictionary setObject:messages forKey:@"messages"];
                [dictionary setObject:compareDateKey forKey:@"date"];
                
                [separetedArray addObject:dictionary];
            }
        }
    }
    
    return separetedArray;
}

#pragma mark Action

-(void)startUp
{
    CGAffineTransform transform = CGAffineTransformRotate(self.refreshUpImageView.transform, M_PI / 6.0);
    self.refreshUpImageView.transform = transform;
}

-(void)startDown
{
    CGAffineTransform transform = CGAffineTransformRotate(self.refreshDownImageView.transform, M_PI / 6.0);
    self.refreshDownImageView.transform = transform;
    
}

- (IBAction)back:(id)sender
{
    if (self.app.is_vimtag || self.app.is_luxcam || self.app.is_ebitcam || self.app.is_mipc) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
}


- (IBAction)selectDate:(id)sender
{
    if (self.app.is_vimtag) {
        _calendar.hidden = !_calendar.hidden;
        if (!_screeningView.hidden) {
            _screeningView.hidden = YES;
            [self initLayoutConstraint];
        }
    } else {
        if (_is_datePickerShow)
        {
            if (_datePicker) {
                [_datePicker removeFromSuperview];
            }
            _is_datePickerShow = NO;
        }
        else
        {
            [self createDatePickerWithMode:UIDatePickerModeDate];
        }
    }
}

- (IBAction)selectFilterStyle:(id)sender
{
    _screeningView.hidden = !_screeningView.hidden;
    _calendar.hidden = YES;
    if (_screeningView.hidden)
    {
        [self initLayoutConstraint];
    }
    else
    {
        [self updateLayoutConstraint];
    }
}

- (void)createDatePickerWithMode:(UIDatePickerMode)datePickerMode
{
    if (_datePicker) {
        [_datePicker removeFromSuperview];
    }
    
    _datePicker = [[MNCustomDatePicker alloc] initWithFrame:CGRectNull];
    _datePicker.customSelectDate = self.selectedDate;
    _datePicker.delegate = self;
    _datePicker.datePickerMode = datePickerMode;
    _datePicker.center = self.view.center;
    [self.view.superview addSubview:_datePicker];
    _is_datePickerShow = YES;
}

- (void)upRefreshData
{
//    if (!_isRefreshing)
//    {
//        _isRefreshing = YES;
    _lastUpDate = _previousDate;
        NSTimeInterval timeInterval = [self.previousDate timeIntervalSince1970];
        
        for (calendar_info_obj *info_obj in self.allDateArray) {
        if (_selectResult == RECORD_EVENT_ONEHOUR || _selectResult == RECORD_EVENT_HALFHOUR || _selectResult == RECORD_EVENT_FIVEMIN || _selectResult == RECORD_EVENT_SHORTEST || _selectResult == SNAPSHOT_EVENT || _selectResult == SNAPSHOT_ALL || _selectResult == ALL_EVENT_ONEHOUR || _selectResult == ALL_EVENT_HALFHOUR || _selectResult == ALL_EVENT_FIVEMIN || _selectResult == ALL_EVENT_SHORTEST) {
            if (!info_obj.flag) {
                   continue;
            }
        }
        if (timeInterval == [info_obj.date timeIntervalSince1970]) {
                
            break;
        }
        //refreshDate(null) is between start Date and end Date
        if (timeInterval < [info_obj.date timeIntervalSince1970] && timeInterval > [self.previousDate timeIntervalSince1970]) {
            break;
        }
            self.previousDate = [info_obj.date copy];
        }
        
    
        
//        timeInterval = [self.previousDate timeIntervalSince1970] * 1000 - [self getTimeIntervalBetweenTimeZoneAndUTC]*1000;
        timeInterval = [self.previousDate timeIntervalSince1970] * 1000 - self.timeDifference * 1000;
        long long startTime = timeInterval ;
        long long endTime = timeInterval + 24*60*60*1000;
        
        mcall_ctx_box_get *ctx = [[mcall_ctx_box_get alloc] init];
        ctx.sn = _boxID;
        ctx.dev_sn = _deviceID;
        ctx.target = self;
        ctx.flag = 8;
        ctx.on_event = @selector(box_get_segs_refresh_done:);
        ctx.start_time = startTime;
        ctx.end_time = endTime;
        
        [self.agent box_get:ctx];
    [self checkFinishReloadData];
//    }
}
-(void)downRefreshData
{

//    if (!_isRefreshing)
//    {
//        _isRefreshing = YES;
    _lastDownDate = _laterDate;
        NSTimeInterval timeInterval = [self.laterDate timeIntervalSince1970];
        
        for (int i = (int)self.allDateArray.count - 1;i >= 0;i--) {
            
            calendar_info_obj *info_obj = self.allDateArray[i];
            
            if (_selectResult == RECORD_EVENT_ONEHOUR || _selectResult == RECORD_EVENT_HALFHOUR || _selectResult == RECORD_EVENT_FIVEMIN || _selectResult == RECORD_EVENT_SHORTEST || _selectResult == SNAPSHOT_EVENT || _selectResult == SNAPSHOT_ALL || _selectResult == ALL_EVENT_ONEHOUR || _selectResult == ALL_EVENT_HALFHOUR || _selectResult == ALL_EVENT_FIVEMIN || _selectResult == ALL_EVENT_SHORTEST) {
                if (!info_obj.flag) {
                    continue;
                }
            }
            if (timeInterval == [info_obj.date timeIntervalSince1970]) {
                
                break;
            }
            //refreshDate(null) is between start Date and end Date
            if (timeInterval > [info_obj.date timeIntervalSince1970] && timeInterval < [self.laterDate timeIntervalSince1970]) {
                break;
            }
            self.laterDate = [info_obj.date copy];
        }
        
        [self checkFinishReloadData];
        
//        timeInterval = [self.laterDate timeIntervalSince1970] * 1000 - [self getTimeIntervalBetweenTimeZoneAndUTC]*1000;
        timeInterval = [self.laterDate timeIntervalSince1970] * 1000 - self.timeDifference * 1000;
        long long startTime = timeInterval ;
        long long endTime = timeInterval + 24*60*60*1000;
        
        mcall_ctx_box_get *ctx = [[mcall_ctx_box_get alloc] init];
        ctx.sn = _boxID;
        ctx.dev_sn = _deviceID;
        ctx.target = self;
        ctx.flag = 8;
        ctx.on_event = @selector(box_get_segs_refresh_done:);
        ctx.start_time = startTime;
        ctx.end_time = endTime;
        
        [self.agent box_get:ctx];
//    }
}
- (void)mergeBoxSegmentMessage
{
    long long segmentStartTime = 0;     //Seg array start time
    long long segmentEndTime = 0;       //Seg array end time
    long long segmentTotalTime = 0;     //Seg array duration
    //Save seg array and flag
    MNRecordObj *recordObj = [[MNRecordObj alloc] init];
    //Flag if show event only, for Record or All
    long selectEvent = ((self.selectResult >= RECORD_EVENT_ONEHOUR) && (self.selectResult <= RECORD_EVENT_SHORTEST)) || ((self.selectResult >= ALL_EVENT_ONEHOUR) && (self.selectResult <= ALL_EVENT_SHORTEST));
    //Count photo number
    long photoCount = 0;
    
    if (self.selectResult == RECORD_EVENT_ONEHOUR || self.selectResult == RECORD_ALL_ONEHOUR || self.selectResult == ALL_EVENT_ONEHOUR || self.selectResult == ALL_ALL_ONEHOUR) {
        segmentTotalTime = ONE_HOUR;
    }
    else if (self.selectResult == RECORD_EVENT_FIVEMIN || self.selectResult == RECORD_ALL_FIVEMIN || self.selectResult == ALL_EVENT_FIVEMIN || self.selectResult == ALL_ALL_FIVEMIN)
    {
        segmentTotalTime = FIVE_MINUTES;
    }
    else
    {
        segmentTotalTime = HALF_AN_HOUR;
    }
    
    for (NSMutableArray *recordArray in self.recordSegmentArray)
    {
        for (seg_obj *seg in recordArray)
        {
//            if (seg.flag) {
//                NSLog(@"%ld",seg.flag);
//            }\
            
            //Catch and filter the exception seg
            
            if ((segmentEndTime != 0 && seg.start_time < segmentEndTime) || (seg.start_time > seg.end_time)) {
                continue;
            }
            
            //Deal with Snapshot Event
            if (self.selectResult == SNAPSHOT_EVENT || self.selectResult == SNAPSHOT_ALL)
            {
                if (seg.flag)
                {
                    [recordObj.recordArray addObject:seg];
                    MNRecordObj *tmpObj = [[MNRecordObj alloc] init];
                    tmpObj.recordArray = [recordObj.recordArray copy];
                    [tmpObj setAllFlagWithSegFlag:seg.flag];
                    tmpObj.is_photo = YES;
                    [self.messagesArray insertObject:tmpObj atIndex:0];
                    [recordObj.recordArray removeAllObjects];
                    [recordObj resetAllFlag];
                }
                continue;
            }
            //Deal with Shortest Event
            if (self.selectResult == RECORD_EVENT_SHORTEST || self.selectResult == ALL_EVENT_SHORTEST)
            {
                if (seg.flag)
                {
                    //Filter photo
                    if ((2 == seg.flag) || (seg.start_time == seg.end_time))
                    {
                        if (self.selectResult == RECORD_EVENT_SHORTEST) {
                            continue;
                        } else {
                            recordObj.is_photo = YES;
                        }
                    }

                    [recordObj.recordArray addObject:seg];
                    MNRecordObj *tmpObj = [[MNRecordObj alloc] init];
                    tmpObj.recordArray = [recordObj.recordArray copy];
                    [tmpObj setAllFlagWithSegFlag:seg.flag];
                    tmpObj.is_photo = recordObj.is_photo;
                    [self.messagesArray insertObject:tmpObj atIndex:0];
                    [recordObj.recordArray removeAllObjects];
                    [recordObj resetAllFlag];
                }
                if (seg.flag && (self.selectResult == ALL_EVENT_SHORTEST)) {
                    if ((seg.flag == 2) || (seg.start_time == seg.end_time)) {
                        
                    } else {
                        MNRecordObj *tmpObj = [[MNRecordObj alloc] init];
                        [tmpObj.recordArray addObject:seg];
                        [tmpObj setAllFlagWithSegFlag:seg.flag];
                        tmpObj.is_photo = YES;
                        [self.messagesArray insertObject:tmpObj atIndex:0];
                    }
                }
                continue;
            }
            
            //Filter snapshot
            if (seg.flag) {
                if ((self.selectResult >= ALL_EVENT_ONEHOUR) && (self.selectResult <= ALL_ALL_FIVEMIN)) {
                    recordObj.recordArray.count ? photoCount++ : 0;
                    
                    MNRecordObj *tmpObj = [[MNRecordObj alloc] init];
                    [tmpObj.recordArray addObject:seg];
                    [tmpObj setAllFlagWithSegFlag:seg.flag];
                    tmpObj.is_photo = YES;
                    [self.messagesArray insertObject:tmpObj atIndex:0];
                }
                if (2 == seg.flag || (seg.start_time == seg.end_time)) {
                    continue;
                }
            }
            
            if ([recordObj.recordArray lastObject])
            {
                if (seg.start_time - segmentEndTime <= RECORD_SEG_INTERVAL && seg.end_time - segmentStartTime < segmentTotalTime)
                {
                    [recordObj.recordArray addObject:seg];
                    segmentEndTime = ((seg_obj *)recordObj.recordArray.lastObject).end_time;
                }
                else
                {
                    MNRecordObj *tmpObj = [[MNRecordObj alloc] init];
                    tmpObj.recordArray = [recordObj.recordArray copy];
                    tmpObj.motionFlag = recordObj.motionFlag;
                    tmpObj.snapshotFlag = recordObj.snapshotFlag;
                    tmpObj.ioFlag = recordObj.ioFlag;
                    tmpObj.doorFlag = recordObj.doorFlag;
                    tmpObj.sosFlag = recordObj.sosFlag;
                    if (selectEvent)
                    {
                        if (tmpObj.motionFlag || tmpObj.snapshotFlag || tmpObj.ioFlag || tmpObj.doorFlag || tmpObj.sosFlag) {
                            [self.messagesArray insertObject:tmpObj atIndex:(photoCount <= self.messagesArray.count ? photoCount : 0)];
                        }
                    } else {
                        [self.messagesArray insertObject:tmpObj atIndex:(photoCount < self.messagesArray.count ? photoCount : 0)];
                    }
                    [recordObj.recordArray removeAllObjects];
                    [recordObj.recordArray addObject:seg];
                    [recordObj resetAllFlag];
                    segmentStartTime = seg.start_time;
                    segmentEndTime = seg.end_time;
                    photoCount = 0;
                }
            }
            else
            {
                [recordObj.recordArray addObject:seg];
                segmentEndTime = ((seg_obj *)recordObj.recordArray.lastObject).end_time;
                segmentStartTime = ((seg_obj *)recordObj.recordArray.lastObject).start_time;
            }
            
            //marker tmpArray‘s event flag
            if (seg.flag)
            {
                [recordObj setAllFlagWithSegFlag:seg.flag];
            }
        }
        if ([recordObj.recordArray lastObject]) {
            MNRecordObj *tmpObj = [[MNRecordObj alloc] init];
            tmpObj.recordArray = [recordObj.recordArray copy];
            tmpObj.motionFlag = recordObj.motionFlag;
            tmpObj.snapshotFlag = recordObj.snapshotFlag;
            tmpObj.ioFlag = recordObj.ioFlag;
            tmpObj.doorFlag = recordObj.doorFlag;
            tmpObj.sosFlag = recordObj.sosFlag;
            if (selectEvent)
            {
                if (tmpObj.motionFlag || tmpObj.snapshotFlag || tmpObj.ioFlag || tmpObj.doorFlag || tmpObj.sosFlag) {
                    [self.messagesArray insertObject:tmpObj atIndex:(photoCount < self.messagesArray.count ? photoCount : 0)];
                }
            } else {
                [self.messagesArray insertObject:tmpObj atIndex:(photoCount < self.messagesArray.count ? photoCount : 0)];
            }
            
            [recordObj.recordArray removeAllObjects];
            [recordObj resetAllFlag];
        }
        segmentStartTime = 0;
        segmentEndTime = 0;
        photoCount = 0;
    }
    
    [self.progressHUD hide:YES];
}

//- (NSString *)getStringTime:(long long)time
//{
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time / 1000];
//    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *weekdayComponents = [currentCalendar components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
//    NSInteger hour = [weekdayComponents hour];
//    NSInteger min = [weekdayComponents minute];
//    NSInteger sec = [weekdayComponents second];
//    
//    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];
//}

-(void)cancelNetworkRequest
{
    for (UIView *view in self.collectionView.subviews) {
        if ([view isMemberOfClass:[MNBoxSegmentViewCell class]]) {
            MNBoxSegmentViewCell *cell = (MNBoxSegmentViewCell*)view;
            if ([cell respondsToSelector:@selector(cancelNetworkRequest)]) {
                [cell performSelector:@selector(cancelNetworkRequest)];
            }
        }
    }
}

#pragma mark - handleLongPress
- (void)handleLongPress:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        @try {
            CGPoint point = [recognizer locationInView:recognizer.view];
            MNBoxSegmentViewCell *cell = ((MNBoxSegmentViewCell *)recognizer.view);
            NSInteger section = [[self.collectionView indexPathForCell:cell] section];
            NSInteger Index = [[self.collectionView indexPathForCell:cell] row];
            NSDictionary *dictionary = [_messages objectAtIndex:section];
            _deleteArray = [[dictionary objectForKey:@"messages"] objectAtIndex:Index];
            
            [self becomeFirstResponder];
            
            UIMenuController *popMenuController = [UIMenuController sharedMenuController];
            UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"mcs_delete", nil) action:@selector(onMenuItemDelete:)];
            NSArray *menuItemArray = [NSArray arrayWithObject:deleteMenuItem];
            [popMenuController setMenuItems:menuItemArray];
            [popMenuController setArrowDirection:UIMenuControllerArrowDown];
            [popMenuController setTargetRect:CGRectMake(point.x, point.y, 0, 0) inView:recognizer.view];
            [popMenuController setMenuVisible:YES animated:YES];
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
            
        }
    }
}


- (void)onMenuItemDelete:(id)sender
{
    NSString *info = NSLocalizedString(@"mcs_are_you_sure_delete", nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:info
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
    [alertView show];
}

#pragma mark - becomeFirstResponder
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(onMenuItemDelete:)) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - layoutSubViews
- (void)viewDidLayoutSubviews
{
    if (self.app.is_vimtag) {
        _screeningView.lineView.frame = CGRectMake(5, _screeningView.frame.size.height - 2, self.view.frame.size.width - 10, 1);
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
            _calendar.frame = CGRectMake(0, 0 , self.view.frame.size.width, self.view.frame.size.width * 0.6);
        } else {
            if (self.view.frame.size.height > self.view.frame.size.width) {
                _calendar.frame = CGRectMake(0, 0 , self.view.frame.size.width, self.view.frame.size.width);
            } else {
                _calendar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            }
        }
    }
    else
    {
        if (_datePicker) {
            _datePicker.center = self.view.center;
        }
    }
    
    //layout refresh
    
    CGPoint downRefreshLabelCenter = _downRefreshLabel.center;
    downRefreshLabelCenter.x = self.collectionView.center.x;
    _downRefreshLabel.center = downRefreshLabelCenter;
    [self.collectionView addSubview:_downRefreshLabel];
    
    //get _downRefreshLabel.text width
    NSString *downRefreshLabelText = NSLocalizedString(@"mcs_refreshing", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        labelSize = [downRefreshLabelText boundingRectWithSize:CGSizeMake(0, 0)
                                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:attributes
                                                       context:nil].size;
        
        labelSize.width = ceil(labelSize.width);
    }
    if (self.app.is_vimtag) {
        [self.refreshDownImageView layoutFrame:self.collectionView with:labelSize];
        
        CGRect frame = _upRefreshView.frame;
        frame.size.width = self.collectionView.frame.size.width;
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
            frame.origin.y = self.collectionView.contentSize.height + 5;
        }
        else{
            frame.origin.y = self.collectionView .frame.size.height +5;
        }
        _upRefreshView.frame = frame;
        if ([self collectionViewAddRefreshView]) {
            [_upRefreshView removeFromSuperview];
        }
        [self collectionViewAddRefreshView];
        
        CGPoint labelCenter = _upRefreshLabel.center;
        labelCenter.x = _upRefreshView.frame.size.width / 2;
        _upRefreshLabel.center = labelCenter;
        
        self.refreshUpImageView.center = self.refreshDownImageView.center;
    }
    else {
        //activity for refresh
        CGPoint center =_pullDownActivityView.center;
        center.x = self.collectionView.center.x - labelSize.width / 2.0 - 15;
        _pullDownActivityView.center = center;
        [self.collectionView addSubview:_pullDownActivityView];
        
        CGRect frame = _upRefreshView.frame;
        frame.size.width = self.collectionView.frame.size.width;
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
            frame.origin.y = self.collectionView.contentSize.height + 5;
        }
        else{
            frame.origin.y = self.collectionView .frame.size.height +5;
        }
        _upRefreshView.frame = frame;
        if ([self collectionViewAddRefreshView]) {
            [_upRefreshView removeFromSuperview];
        }
        [self collectionViewAddRefreshView];
        
        CGPoint labelCenter = _upRefreshLabel.center;
        labelCenter.x = _upRefreshView.frame.size.width / 2;
        _upRefreshLabel.center = labelCenter;
        
        _pullUpActivityView.center = center;
    }

}

- (void)initLayoutConstraint
{
    self.collectionLayoutConstraint.constant = 0;
}

- (void)updateLayoutConstraint
{
    self.collectionLayoutConstraint.constant = CGRectGetHeight(_screeningView.frame);
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _messages.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary *dictionary = [_messages objectAtIndex:section];
    NSInteger count = [[dictionary objectForKey:@"messages"] count];
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNBoxSegmentViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSDictionary *dictionary = [_messages objectAtIndex:indexPath.section];
    MNRecordObj *obj = [[dictionary objectForKey:@"messages"] objectAtIndex:indexPath.row];
    seg_obj *startSeg = [[obj recordArray] firstObject];
    seg_obj *endSeg = [[obj recordArray] lastObject];
    
    cell.isPhoto = obj.is_photo;//Check Photo
    cell.isEvent = obj.motionFlag ? YES : NO;
    cell.deviceID = _deviceID;
    cell.boxID = _boxID;
    cell.cluster_id = startSeg.cluster_id;
    cell.seg_id = startSeg.seg_id;
    cell.start_time = startSeg.start_time;
    cell.end_time = endSeg.end_time;
    cell.timeDifference = self.timeDifference;
    cell.token = [NSString stringWithFormat:@"%@_p3_%ld_%ld", _deviceID, startSeg.cluster_id, startSeg.seg_id];
    cell.isMotion = obj.motionFlag ? YES : NO;
    cell.isSnapshot = obj.snapshotFlag ? YES : NO;
    cell.isDoor = obj.doorFlag ? YES : NO;
    cell.isSOS = obj.sosFlag ? YES : NO;
    
    if (self.app.is_luxcam) {
        cell.markImageView.image = [UIImage imageNamed:@"btn_play.png"];
        cell.contentImageView.image = [UIImage imageNamed:@"placeholder.png"];
        cell.eventImageView.image = [UIImage imageNamed:@"record_event.png"];
    }
    else  if (self.app.is_vimtag)
    {
        cell.markImageView.image = [UIImage imageNamed:@"vt_box_video.png"];
        cell.contentImageView.image = [UIImage imageNamed:@"vt_cellBg.png"];
        [cell showEventImage];
    }
    else if (self.app.is_ebitcam)
    {
        cell.markImageView.image = [UIImage imageNamed:cell.isPhoto ? @"eb_record_photo.png" : @"eb_record_video.png"];
        cell.contentImageView.image = [UIImage imageNamed:@"eb_cellBg.png"];
        cell.eventImageView.image = [UIImage imageNamed:@"record_event.png"];
    }
    else if (self.app.is_mipc)
    {
        cell.markImageView.image = [UIImage imageNamed:cell.isPhoto ? @"mi_record_photo.png" : @"mi_record_video.png"];
        cell.contentImageView.image = [UIImage imageNamed:@"mi_cellBg.png"];
        cell.eventImageView.image = [UIImage imageNamed:@"record_event.png"];
    }
    else
    {
        cell.markImageView.image = [UIImage imageNamed:@"video.png"];
        cell.contentImageView.image = [UIImage imageNamed:@"placeholder.png"];
        cell.eventImageView.image = [UIImage imageNamed:@"record_event.png"];
    }
    
    [cell loadWebImage];
    [cell setNeedsLayout];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [cell addGestureRecognizer:longPressGestureRecognizer];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MNBoxHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
    NSDictionary *dictionary = [_messages objectAtIndex:indexPath.section];
    headerView.dateLabel.text = [dictionary objectForKey:@"date"];
    headerView.dateLabel.textColor = self.configuration.labelTextColor;
    
    
    return headerView;
}

#pragma mark - <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //        float height = CGRectGetHeight(self.view.bounds);
        NSInteger screenWidth =[UIDevice currentDevice].systemVersion.floatValue < 8.0 ? CGRectGetWidth(self.view.bounds) : self.transitionToSize.width;
        //        CGFloat screenWidth = width < height ? width : height;
        
        if (self.app.is_luxcam) {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
        }
        else
        {
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
            itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16);
        }
    }
    else
    {
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft
            || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight || ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height))
        {
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? width : height;
            
            if (self.app.is_luxcam) {
                
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else
            {
                int lineCounts = DEFAULT_LINE_COUNTS + 3;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
        }
        else
        {
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? height : width;
            
            if (self.app.is_luxcam) {
                CGFloat cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (DEFAULT_LINE_COUNTS - 1) * DEFAULT_CELL_MARGIN) / DEFAULT_LINE_COUNTS;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
            else
            {
                int lineCounts = DEFAULT_LINE_COUNTS + 1;
                NSInteger cellWidth = (screenWidth - DEFAULT_EDGE_MARGIN * 2 - (lineCounts - 1) * DEFAULT_CELL_MARGIN) / lineCounts;
                itemSize = CGSizeMake(cellWidth, cellWidth * 9 / 16 + 20);
            }
        }
        
    }
    
    return itemSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNBoxSegmentViewCell *cell = (MNBoxSegmentViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    _cellImage = cell.contentImageView.image;
    NSDictionary *dictionary = [_messages objectAtIndex:indexPath.section];
    NSMutableArray *array = [[[[dictionary objectForKey:@"messages"] objectAtIndex:indexPath.row] recordArray] copy];
    if (cell.isPhoto) {
        UIStoryboard *storyboard;
        if (self.app.is_luxcam)
        {
            storyboard = [UIStoryboard storyboardWithName:@"LuxcamStoryboard_iPhone" bundle:nil];
        }
        else if (self.app.is_vimtag)
        {
            storyboard = [UIStoryboard storyboardWithName:@"VimtagStoryboard_iPhone" bundle:nil];
        }
        else if (self.app.is_ebitcam)
        {
            storyboard = [UIStoryboard storyboardWithName:@"EbitcamStoryboard_iPhone" bundle:nil];
        }
        else if (self.app.is_mipc)
        {
            storyboard = [UIStoryboard storyboardWithName:@"MIPCStoryboard_iPhone" bundle:nil];
        }
        else
        {
            storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        }
        MNSnapshotViewController *snapshotViewController = [storyboard instantiateViewControllerWithIdentifier:@"MNSnapshotViewController"];
        snapshotViewController.snapshotImage = _cellImage;
        snapshotViewController.snapshotID = _deviceID;
        snapshotViewController.boxID = _boxID;
        snapshotViewController.token = [array lastObject] ?[NSString stringWithFormat:@"%@_p0_%ld_%ld", _deviceID, ((seg_obj *)array.firstObject).cluster_id, ((seg_obj *)array.firstObject).seg_id] : nil;
        [self.navigationController pushViewController:snapshotViewController animated:YES];
    } else {
        [self performSegueWithIdentifier:@"MNBoxPlayViewController" sender:array];
    }
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0 ) {
        if (!_isRefreshing) {
            _isPreviosRefresh = NO;
        }
        if (_downFinishReloadData) {
            _downRefreshLabel.hidden = NO;
            self.refreshDownImageView.hidden = YES;
            _downRefreshLabel.text = NSLocalizedString(@"mcs_load_end", nil);
            if (_pullDownActivityView.isAnimating) {
                [_pullDownActivityView stopAnimating];
            }
            return;
        }
        if (scrollView.contentOffset.y < -20 && !_isScrollerViewRelease ) {
            _downRefreshLabel.hidden = NO;
            self.refreshDownImageView.hidden = YES;
            _downRefreshLabel.text = NSLocalizedString(@"mcs_down_refresh", nil);
        }
        if (scrollView.contentOffset.y  < -50 && !_isScrollerViewRelease){
            _downRefreshLabel.hidden = NO;
            self.refreshDownImageView.hidden = YES;
            _downRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
        }
    }
    if (scrollView.contentOffset.y > 0) {
        if (!_isRefreshing) {
            _isPreviosRefresh = YES;

        }
        [self collectionViewAddRefreshView];
        
        if (_upFinishReloadData) {
            self.refreshUpImageView.hidden = YES;
            _upRefreshLabel.text = NSLocalizedString(@"mcs_load_end", nil);
            if ([_pullUpActivityView isAnimating]) {
                [_pullUpActivityView stopAnimating];
            }
            return ;
        }
        
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
            if ((self.collectionView.contentSize.height - self.collectionView.frame.size.height) < scrollView.contentOffset.y && !_isScrollerViewRelease) {
                self.refreshUpImageView.hidden = YES;
                _upRefreshLabel .text = NSLocalizedString(@"mcs_pull_refresh_hint", nil);
            }
            if ((self.collectionView.contentSize.height - self.collectionView.frame.size.height + 50) < scrollView.contentOffset.y && !_isScrollerViewRelease) {
                self.refreshUpImageView.hidden = YES;
                _upRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
            }
        }
        else{
            if (scrollView.contentOffset.y > 0 && !_isScrollerViewRelease) {
                self.refreshUpImageView.hidden = YES;
                _upRefreshLabel.text = NSLocalizedString(@"mcs_pull_refresh_hint", nil);
            }
            if (scrollView.contentOffset.y > 50 && !_isScrollerViewRelease) {
                self.refreshUpImageView.hidden = YES;
                _upRefreshLabel.text = NSLocalizedString(@"mcs_release_refresh", nil);
            }
        
        }
    }
   
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (_isRefreshing) {
        return;
    }
    if (_isPreviosRefresh && !_upFinishReloadData) {
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
            
            if ((self.collectionView.contentSize.height - self.collectionView.frame.size.height + 50) < scrollView.contentOffset.y) {
                _isRefreshing = YES;
                _upRefreshLabel.text = NSLocalizedString(@"mcs_refreshing", nil);
                if (self.app.is_vimtag) {
                    [self.refreshUpTimer invalidate];
                    self.refreshUpImageView.hidden = NO;
                    self.refreshUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(startUp) userInfo:nil repeats:YES];
                }else {
                    [_pullUpActivityView startAnimating];
                }
                _isScrollerViewRelease = YES;
                [scrollView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.frame.size.height + 40) animated:YES];
                [self performSelector:@selector(upRefreshData) withObject:nil afterDelay:1.0f];
            }
        }
        else{
            if (scrollView.contentOffset.y > 50) {
                _isRefreshing = YES;
                _upRefreshLabel.text = NSLocalizedString(@"mcs_refreshing", nil);
                if (self.app.is_vimtag) {
                    [self.refreshUpTimer invalidate];
                    self.refreshUpImageView.hidden = NO;
                    self.refreshUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(startUp) userInfo:nil repeats:YES];
                }else {
                    [_pullUpActivityView startAnimating];
                }
                _isScrollerViewRelease = YES;
                [scrollView setContentOffset:CGPointMake(0, 40) animated:YES];
                [self performSelector:@selector(upRefreshData) withObject:nil afterDelay:1.0f];
            }
        }

    }
    else{
        if (scrollView.contentOffset.y < -50 && !_downFinishReloadData) {
            _isRefreshing = YES;
            _downRefreshLabel.text = NSLocalizedString(@"mcs_refreshing", nil);
            if (self.app.is_vimtag) {
                [self.refreshDownTimer invalidate];
                self.refreshDownImageView.hidden = NO;
                self.refreshDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(startDown) userInfo:nil repeats:YES];
            }else {
                [_pullDownActivityView startAnimating];
            }
            _isScrollerViewRelease = YES;
            [scrollView setContentOffset:CGPointMake(0, -40) animated:YES];
            [self performSelector:@selector(downRefreshData) withObject:nil afterDelay:1.0f];
        }
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == __contentOffsetY) {
        _isScrollerViewRelease = NO;
        if (self.app.is_vimtag) {
            [self.refreshUpTimer invalidate];
            [self.refreshDownTimer invalidate];
        }
        else {
            [_pullDownActivityView stopAnimating];
            [_pullUpActivityView stopAnimating];
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MNBoxPlayViewController"])
    {
        MNBoxPlayViewController *boxPlayViewController = segue.destinationViewController;
        boxPlayViewController.boxID = _boxID;
        boxPlayViewController.deviceID = _deviceID;
        boxPlayViewController.videoImage = _cellImage;
        boxPlayViewController.segmentArray = sender;
        boxPlayViewController.timeDifference = self.timeDifference;
    }
}

#pragma mark - Get fixed date
- (void)getFixedDateData
{
    //test today merge
    NSDate *today = self.selectedDate;
    today = [self extractDate:today];
    
//    NSTimeInterval timeInterval = [today timeIntervalSince1970] * 1000 - [self getTimeIntervalBetweenTimeZoneAndUTC]*1000;
    NSTimeInterval timeInterval = [today timeIntervalSince1970] * 1000 - self.timeDifference * 1000;
    long long startTime = timeInterval ;
    long long endTime = timeInterval + 24*60*60*1000;
    
    mcall_ctx_box_get *ctx = [[mcall_ctx_box_get alloc] init];
    ctx.sn = _boxID;
    ctx.dev_sn = _deviceID;
    ctx.target = self;
    ctx.flag = 8;
    ctx.on_event = @selector(box_get_segs_done:);
    ctx.start_time = startTime;
    ctx.end_time = endTime;
    
    [self.agent box_get:ctx];
    [self.progressHUD show:YES];
}

- (NSDate *)extractDate:(NSDate *)date {
    //get seconds since 1970
    NSTimeInterval interval = [date timeIntervalSince1970];
    int daySeconds = 24 * 60 * 60;
    //calculate integer type of days
    NSInteger allDays = interval / daySeconds;
    
    return [NSDate dateWithTimeIntervalSince1970:allDays * daySeconds];
}

- (NSTimeInterval)getTimeIntervalBetweenTimeZoneAndUTC
{
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSDate *currentDate = [NSDate date];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:currentDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:currentDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    return interval;
}

#pragma mark - InterfaceOrientation

- (BOOL)shouldAutorotate
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //    [self updateCollectionViewFlowLayout];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        //Cancel Load Image
        [self cancelNetworkRequest];
        
        [self.collectionView reloadData];
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    _transitionToSize = size;
    //Cancel Load Image
    [self cancelNetworkRequest];
    
    [self.collectionView reloadData];
}

#pragma mark - Check Finish Reload Data
- (void)checkFinishReloadData
{
    if (![self.allDateArray lastObject]) {
        _upFinishReloadData = YES;
        _downFinishReloadData = YES;
        return;
    }
    if (_selectResult == RECORD_EVENT_ONEHOUR || _selectResult == RECORD_EVENT_HALFHOUR || _selectResult == RECORD_EVENT_FIVEMIN || _selectResult == RECORD_EVENT_SHORTEST || _selectResult == SNAPSHOT_EVENT || _selectResult == SNAPSHOT_ALL || _selectResult == ALL_EVENT_ONEHOUR || _selectResult == ALL_EVENT_HALFHOUR || _selectResult == ALL_EVENT_FIVEMIN || _selectResult == ALL_EVENT_SHORTEST) {
        NSMutableArray *infoArr = [[NSMutableArray alloc]init];
        for (calendar_info_obj *info_obj in self.allDateArray)
        {
            if (info_obj.flag)
            {
                [infoArr addObject:info_obj];
            }
        }
        
        if ([infoArr lastObject]) {
            calendar_info_obj *info_obj_first = [infoArr firstObject];
            calendar_info_obj *info_obj_last = [infoArr lastObject];
            
            if ([self.previousDate timeIntervalSince1970] <= [info_obj_first.date timeIntervalSince1970]) {
                _upFinishReloadData = YES;
            }
            else {
                _upFinishReloadData = NO;
            }
            
            if ([self.laterDate timeIntervalSince1970] >= [info_obj_last.date timeIntervalSince1970]) {
                _downFinishReloadData = YES;
            }
            else{
                _downFinishReloadData = NO;
            }
            
            return;
        }
        _downFinishReloadData = YES;
        _upFinishReloadData = YES;
    }
    else
    {
        NSTimeInterval timeIntervalPrevious = [self.previousDate timeIntervalSince1970];
        NSTimeInterval datesStartInterval = [((calendar_info_obj *)(self.allDateArray.firstObject)).date timeIntervalSince1970];
        if (timeIntervalPrevious <= datesStartInterval) {
            _upFinishReloadData = YES;
        } else {
            _upFinishReloadData = NO;
        }
        
        NSTimeInterval timeIntervalLater = [self.laterDate timeIntervalSince1970];
        NSTimeInterval dateEndInterval = [((calendar_info_obj *)(self.allDateArray.lastObject)).date timeIntervalSince1970 ];
        if (timeIntervalLater >= dateEndInterval) {
            _downFinishReloadData = YES;
        }
        else{
            _downFinishReloadData = NO;
        }
    }
}

#pragma mark - MNScreeningViewDelegate
- (void)filteringResults:(NSInteger)selectResult
{
    self.selectResult = selectResult;
    if (self.app.is_vimtag) {
        [self updateLayoutConstraint];
    } else if (!self.recordSegmentArray.count) {
//        NSLog(@"1111");
        return;
    }
    
    //Cancel Load Image
    [self cancelNetworkRequest];
    
    [self.messagesArray removeAllObjects];
    [self mergeBoxSegmentMessage];
    
    [self checkFinishReloadData];
    
    //reload data
    self.messages = [self separateArrayUsingDate];
    [self.collectionView reloadData];
    [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];
}

#pragma mark - MNCalendarDelegate
- (void)calendarSelectedDate:(NSDate *)date
{
    self.selectedDate = [NSDate dateWithTimeIntervalSince1970:([[self extractDate:date] timeIntervalSince1970] + 24*60*60)];
    self.previousDate = [_selectedDate copy];
    self.laterDate = [_selectedDate copy];
    self.lastUpDate = [_selectedDate copy];
    self.lastDownDate = [_selectedDate copy];
    //check can download data
    [self checkFinishReloadData];
    
    [self getFixedDateData];
    [_calendar setHidden:YES];
}

- (void)hiddenCalendar
{
    [_calendar setHidden:YES];
}

#pragma mark - MNCustomDatePickerDelegate
- (void)datePicker:(MNCustomDatePicker*)datePicker value:(NSDate *)date
{
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSString *dateString = [dateFormatter stringFromDate:date];
    
    self.selectedDate = date;
    self.previousDate = date;
    self.laterDate = date;
    self.lastUpDate = date;
    self.lastDownDate = date;
    [self checkFinishReloadData];
    [self getFixedDateData];
    _is_datePickerShow = NO;
}

- (NSString *)stringFromLong:(long long)startTime
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:startTime / 1000 + self.timeDifference];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:calendar];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

#pragma mark - alertView Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex !=  alertView.cancelButtonIndex) {
        mcall_ctx_box_set *ctx = [[mcall_ctx_box_set alloc] init];
        seg_obj *startSeg = [_deleteArray.recordArray firstObject];
        seg_obj *endSeg = [_deleteArray.recordArray lastObject];
        
        ctx.start_time = startSeg.start_time;
        ctx.end_time = endSeg.end_time;
        ctx.sn = _boxID;
        ctx.dev_sn = _deviceID;
        ctx.cmd = @"erase";
        ctx.target = self;
        ctx.on_event = @selector(box_set_done:);
        [self.agent box_set:ctx];
        _progressHUD.labelText = NSLocalizedString(@"mcs_deleting", nil);
        [self.progressHUD show:YES];
    }
    
}
@end
