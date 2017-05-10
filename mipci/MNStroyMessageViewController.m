//
//  
//  mipci
//
//  Created by weken on 15/2/5.
//
//

#import "MNStroyMessageViewController.h"
#import "mipc_agent.h"
#import "MNMessageViewCell.h"
#import "MNDeviceTabBarController.h"
#import "MNMessageHeaderView.h"
#import "MNRecordViewController.h"
#import "MNSnapshotViewController.h"
#import "AppDelegate.h"
#import "LocalVideoInfo.h"
#import "MNProgressHUD.h"
#import "MNStroyMessageViewController.h"
#import "MNConfiguration.h"
#import "MNBoxRecordsViewController.h"

#define PULL_AREA_HEIGTH 60.0f
#define PULL_TRIGGER_HEIGHT (PULL_AREA_HEIGTH + 5.0f)
#define PULL_DISTANCE_TO_VIEW 10.0f

#define DEFAULT_LINE_COUNTS       2
#define DEFAULT_CELL_MARGIN       4
#define DEFAULT_EDGE_MARGIN       5
#define DELETE_TAG                1004
#define SUREBUTTON_INDEX           1

@interface MNStroyMessageViewController ()
@property (strong, nonatomic) mipc_agent *agent;
@property (assign, nonatomic) BOOL isViewAppearing;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *originLocalMessages;
@property (strong, nonatomic) NSMutableArray *originHistoryMessages;
@property (strong, nonatomic) UIActivityIndicatorView *pullUpActivityView;
@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL finishReloadData;
@property (strong, nonatomic) UILabel *reloadDataPromptLabel;
@property (assign, nonatomic) long start_id;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) BOOL isLocal;
@property (strong, nonatomic) LocalVideoInfo *deleteLocalInfo;
@property (strong, nonatomic) NSMutableDictionary  *deleteDictionary;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (assign, nonatomic) CGSize transitionToSize;
@property (strong, nonatomic) NSMutableArray *deviceArray;
@property (weak, nonatomic) MNConfiguration *configuration;

@end

@implementation MNStroyMessageViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)dealloc
{
    for (m_dev *dev in self.deviceArray) {
        [dev removeObserver:self forKeyPath:@"read_id"];
    }
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //        [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"mcs_messages", nil)];
        //        [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_message_selected.png"]];
        //        [self.collectionView alwaysBounceVertical];
    }
    
    return self;
}

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

- (MNConfiguration *)configuration
{
    if (nil == _configuration) {
        _configuration = [MNConfiguration shared_configuration];
    }
    return _configuration;
}

- (NSMutableArray *)deviceArray
{
    if (nil == _deviceArray) {
        _deviceArray = [NSMutableArray array];
    }
    return _deviceArray;
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
    
    return _progressHUD;
}

- (void)initUI
{
    _emptyPromptLabel.text = NSLocalizedString(@"mcs_no_history_record", nil);

    //[self.collectionView alwaysBounceVertical];
    //prompt for refresh
    _reloadDataPromptLabel = [[UILabel alloc] init];
    CGRect promptFrame = _reloadDataPromptLabel.frame;
    promptFrame.origin.y = self.collectionView.bounds.size.height;
    _reloadDataPromptLabel.frame = promptFrame;
    
    CGPoint promptCenter = _reloadDataPromptLabel.center;
    promptCenter.x = self.collectionView.center.x;
    _reloadDataPromptLabel.center = promptCenter;
    
    _reloadDataPromptLabel.font = [UIFont systemFontOfSize:16];
    _reloadDataPromptLabel.textAlignment = NSTextAlignmentCenter;
    _reloadDataPromptLabel.textColor = self.configuration.labelTextColor;
    _reloadDataPromptLabel.hidden = YES;
    [self.collectionView addSubview:_reloadDataPromptLabel];
    
    //activity for refresh
    _pullUpActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _pullUpActivityView.hidesWhenStopped = YES;
    [self.collectionView addSubview:_pullUpActivityView];
    
    if (self.app.is_luxcam || self.app.is_vimtag) {
        _pullUpActivityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        //        [_messageStyleSegmented setTitle:NSLocalizedString(@"mcs_messages", nil) forSegmentAtIndex:0];
        //        [_messageStyleSegmented setTitle:NSLocalizedString(@"mcs_local", nil) forSegmentAtIndex:1];
        
    }
    else
    {
//        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0) {
            negativeSpacer.width = -10.0;
        }
        else
        {
            negativeSpacer.width = 0.0;
        }
        
        //        [self.navigationItem setTitle:NSLocalizedString(@"mcs_messages", nil)];
        //        [_recordmessageStyleSegmented setTitle:NSLocalizedString(@"mcs_messages", nil) forSegmentAtIndex:0];
        //        [_recordmessageStyleSegmented setTitle:NSLocalizedString(@"mcs_local", nil) forSegmentAtIndex:1];
        //        [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, leftBarButtonItem] animated:YES];
        
        //        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        //        {
        //            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
        //        }
    }
}


-(NSMutableArray *)messages
{
    @synchronized(self)
    {
        if (nil ==_messages) {
            _messages = [NSMutableArray array];
        }
        
        return _messages;
    }
}

//- (void)back:(id)sender
//{
//    NSString *url = self.app.fromTarget;
//    if (url) {
//        mcall_ctx_sign_out *ctx = [[mcall_ctx_sign_out alloc] init] ;
//        ctx.target = self;
//        ctx.on_event = nil;
//
//        [self.agent sign_out:ctx];
//
//        NSString *url = self.app.fromTarget;
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//    }
//
//    else
//    {
//        [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
//    }
//}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    self.collectionView.alwaysBounceVertical = YES;
    //    [self updateCollectionViewFlowLayout];
    //
    //    if (!self.app.is_luxcam) {
    //        MNDeviceTabBarController *deviceTabBarViewController = (MNDeviceTabBarController*)self.tabBarController;
    //        _deviceID = deviceTabBarViewController.deviceID;
    //    }
    
    //    self.originLocalMessages = [NSMutableArray array];
    self.originHistoryMessages = [NSMutableArray array];
    _isViewAppearing = YES;
    _isRefreshing = NO;
    
    //FIXME:change the dev after snapshot
    //    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    
    mcall_ctx_msgs_get *ctx = [[mcall_ctx_msgs_get alloc] init];
    ctx.target = self;
    ctx.on_event = @selector(msgs_get_done:);
    ctx.counts = -50;
    ctx.start_id = INT_MAX;
    ctx.flag = 0;
    ctx.sn = _deviceID;
    
    [self.agent msgs_get:ctx];
    [self.progressHUD show:YES];
    if (!self.app.isLocalDevice) {
        mcall_ctx_dev_msg_listener_add *add = [[mcall_ctx_dev_msg_listener_add alloc] init];
        add.target = self;
        add.on_event = @selector(dev_msg_listener:);
        add.type = @"device,io,motion,alert,snapshot,record";
        [self.agent dev_msg_listener_add:add];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _transitionToSize = self.view.bounds.size;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
         [self.collectionView reloadData];
        [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isViewAppearing = YES;
    //    [self updateCollectionViewFlowLayout];
    //    [self.collectionView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isViewAppearing = NO;
    
    [self cancelNetworkRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)refresh:(id)sender
{
    if (!_isRefreshing)
    {
        mcall_ctx_msgs_get *ctx = [[mcall_ctx_msgs_get alloc] init];
        ctx.target = self;
        ctx.on_event = @selector(msgs_get_done:);
        ctx.counts = -50;
        ctx.start_id = (int)_start_id;
        ctx.flag = 0;
        ctx.sn = _deviceID;
        
        _isRefreshing = YES;
        [self.agent msgs_get:ctx];
    }
}

//- (IBAction)selectMessagesStyle:(id)sender
//{
//    if (((UISegmentedControl*)sender).selectedSegmentIndex == 0) {
//        [self.messages removeAllObjects];
//        _isLocal = NO;
//
//        m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
//
//        mcall_ctx_msgs_get *ctx = [[mcall_ctx_msgs_get alloc] init];
//        ctx.target = self;
//        ctx.on_event = @selector(msgs_get_done:);
//        ctx.counts = -50;
//        ctx.start_id = (int)dev.msg_id_max + 1;
//        ctx.flag = 0;
//        ctx.sn = _deviceID;
//
//        [self.agent msgs_get:ctx];
//    }
//    else
//    {
//        _isLocal = YES;
//        [self.messages removeAllObjects];
//        [self.collectionView reloadData];
//    }
//}

- (void)nullRecord
{
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //_deviceListLable.hidden =  (0 !=_videoInfoArray.count);
    //_deviceListLable.text = NSLocalizedString(@"mcs_record_list_is_empty",nil);
    NSLog(@"nullRecord");
    
}

- (IBAction)selectMessagesStyle:(id)sender
{
    [self.messages removeAllObjects];
    [self.collectionView reloadData];
    [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];

    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
    
    mcall_ctx_msgs_get *ctx = [[mcall_ctx_msgs_get alloc] init];
    ctx.target = self;
    ctx.on_event = @selector(msgs_get_done:);
    ctx.counts = -50;
    ctx.start_id = (int)dev.msg_id_max + 1;
    ctx.flag = 0;
    ctx.sn = _deviceID;
    
    [self.agent msgs_get:ctx];
}

//- (void)handleLongPress:(UIGestureRecognizer *)recognizer
//{
//    if (_isLocal && (recognizer.state == UIGestureRecognizerStateBegan))
//    {
//        CGPoint point = [recognizer locationInView:recognizer.view];
//        MNMessageViewCell *cell = ((MNMessageViewCell *)recognizer.view);
//        NSInteger Index = [[self.collectionView indexPathForCell:cell] row];
//        NSInteger section = [[self.collectionView indexPathForCell:cell] section];
//        _deleteDictionary = [self.messages objectAtIndex:section];
//        _deleteLocalInfo = [[_deleteDictionary objectForKey:@"messages"] objectAtIndex:Index];
//
//        [recognizer.view becomeFirstResponder];
//
//        UIMenuController *popMenuController = [UIMenuController sharedMenuController];
//        UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"mcs_delete", nil) action:@selector(onMenuItemDelete:)];
//        NSArray *menuItemArray = [NSArray arrayWithObject:deleteMenuItem];
//        [popMenuController setMenuItems:menuItemArray];
//        [popMenuController setArrowDirection:UIMenuControllerArrowDown];
//        [popMenuController setTargetRect:CGRectMake(point.x, point.y, 0, 0) inView:recognizer.view];
//        [popMenuController setMenuVisible:YES animated:YES];
//    }
//}

//- (void)onMenuItemDelete:(id)sender
//{
//    NSString *info = NSLocalizedString(@"mcs_are_you_sure_delete", nil);
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:info
//                                                       delegate:self
//                                              cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
//                                              otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
//    [alertView show];
//}

#pragma mark - InterfaceOrientation

-(BOOL)shouldAutorotate
{
    return YES;
}


-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIDeviceOrientationLandscapeLeft | UIDeviceOrientationLandscapeRight | UIDeviceOrientationPortrait;
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//        [self updateCollectionViewFlowLayout];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        [self.collectionView reloadData];
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"xxxxxx");
    _transitionToSize = size;
    [self.collectionView reloadData];
}

//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [self updateCollectionViewFlowLayout];
//}

//#pragma mark - becomeFirstResponder
//- (BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//
//-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    if (action == @selector(onMenuItemDelete:)) {
//        return YES;
//    }else{
//        return NO;
//    }
//}

#pragma mark - View did layout subviews
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat visibleTableDiffBoundsHeight = [self visibleTableHeightDiffWithBoundsHeight:self.collectionView];
    
    CGRect promptFrame = _reloadDataPromptLabel.frame;
    promptFrame = CGRectMake(0, 0, 300, 40);
    promptFrame.origin.y = self.collectionView.contentSize.height - 10+ visibleTableDiffBoundsHeight + PULL_DISTANCE_TO_VIEW ;
    _reloadDataPromptLabel.frame = promptFrame;
    
    CGPoint promptCenter =_reloadDataPromptLabel.center;
    promptCenter.x = self.collectionView.center.x;
    _reloadDataPromptLabel.center = promptCenter;
    
    //get _downRefreshLabel.text width
    NSString *reloadDataPromptLabelText =  NSLocalizedString(@"mcs_loading", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        labelSize = [reloadDataPromptLabelText boundingRectWithSize:CGSizeMake(0, 0)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                                attributes:attributes
                                                                   context:nil].size;
        labelSize.width = ceil(labelSize.width);
    }
    CGRect frame = _pullUpActivityView.frame;
    frame.origin.y = self.collectionView.contentSize.height + visibleTableDiffBoundsHeight + PULL_DISTANCE_TO_VIEW;
    _pullUpActivityView.frame = frame;
    CGPoint center =_pullUpActivityView.center;
    center.x = self.collectionView.center.x - labelSize.width / 2.0 - 15;
    _pullUpActivityView.center = center;
}
#pragma mark - msg_listener
- (void)dev_msg_listener:(mdev_msg *)msg
{
    
    if ((!_isViewAppearing)
        || (NSOrderedSame != [_deviceID caseInsensitiveCompare:msg.sn])
        || (0 == msg.msg_id))
    {
        return;
    }
    //Fixed bug : 160723
    if (!msg.img_token.length) {
        return;
    }
    
    [self.originHistoryMessages insertObject:msg atIndex:0];
    
    self.messages = [self separateArrayUsingDate];
    [self.collectionView reloadData];
    [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];
}

#pragma mark - msgs_get_done
- (void)msgs_get_done:(mcall_ret_msgs_get*)ret
{
    
    if (!_isViewAppearing) {
        return;
    }
    
    [self.progressHUD hide:YES];
    
    //stop animating
    if (_pullUpActivityView.isAnimating) {
        [self scrollViewDataSourceDidFinishedLoading:self.collectionView];
    }
    
    if (nil != ret.result) {
        //FIXME:add alert
    
        return;
    }
    
    _start_id = ((mdev_msg*)[ret.msg_arr lastObject]).msg_id;
    
    if (_isRefreshing)
    {
        _isRefreshing = NO;
        [_originHistoryMessages addObjectsFromArray:ret.msg_arr];
        //        [self scrollViewDataSourceDidFinishedLoading:self.collectionView];
    }
    else
    {
        _originHistoryMessages = [NSMutableArray arrayWithArray:ret.msg_arr];
    }
    
    self.messages = [self separateArrayUsingDate];
    [self.collectionView reloadData];
    [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];
    if (ret.bound == -1) {
        _isRefreshing = NO;
        _finishReloadData = YES;
        [self scrollViewDataSourceDidFinishedLoading:self.collectionView];
    }
    
}

#pragma mark - Utils
-(MNMessageViewCell*)getCollectionViewCell:(NSString*)deviceID
{
    NSArray *subviews = self.collectionView.subviews;
    for (UIView *view in subviews) {
        if ([view isMemberOfClass:[MNMessageViewCell class]]) {
            if ([((MNMessageViewCell*)view).deviceID isEqualToString:deviceID]) {
                return (MNMessageViewCell*)view;
            }
        }
    }
    
    return nil;
}


- (NSMutableArray *)separateArrayUsingDate
{
    NSString *compareDateKey;
    NSString *anotherDateKey;
    NSMutableArray *separetedArray = [NSMutableArray array];
    
    int currentIndex = 0;
    
    for (int i = 0; i < _originHistoryMessages.count; i++)
    {
        mdev_msg *msg = _originHistoryMessages[i];
        if (_originHistoryMessages.count == 1) {
            compareDateKey = [[msg.format_data componentsSeparatedByString:@" "] firstObject];
            //Fixed bug : 160723
            if (!compareDateKey.length) {
                continue;
            }
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
            NSMutableArray *messages = [NSMutableArray arrayWithArray:[_originHistoryMessages objectsAtIndexes:indexSet]];
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            [dictionary setObject:compareDateKey forKey:@"date"];
            [dictionary setObject:messages forKey:@"messages"];
            [separetedArray addObject:dictionary];
        }
        if (0 == i) {
            compareDateKey =[[msg.format_data componentsSeparatedByString:@" "] firstObject];
        }
        else if (!compareDateKey.length)
        {
            //Fixed bug : 160723
            compareDateKey =[[msg.format_data componentsSeparatedByString:@" "] firstObject];
        }
        else
        {
            anotherDateKey = [[msg.format_data componentsSeparatedByString:@" "] firstObject];
            if (![anotherDateKey isEqualToString:compareDateKey])
            {
                //Fixed bug : 160723
                if (!anotherDateKey.length) {
                    continue;
                }
                int length = i - currentIndex;
                NSRange range = NSMakeRange(currentIndex, length);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                NSMutableArray *messages = [NSMutableArray arrayWithArray:[_originHistoryMessages objectsAtIndexes:indexSet]];
                
                currentIndex = i;
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [dictionary setObject:messages forKey:@"messages"];
                [dictionary setObject:compareDateKey forKey:@"date"];
                
                [separetedArray addObject:dictionary];
                
                compareDateKey = anotherDateKey;   //exchange
            }
            if (i == _originHistoryMessages.count - 1)
            {
                //Fixed bug : 160723
                if (!anotherDateKey.length) {
                    int length = i - currentIndex;
                    if (!length) {
                        continue;
                    }
                    NSRange range = NSMakeRange(currentIndex, length);
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    NSMutableArray *messages = [NSMutableArray arrayWithArray:[_originHistoryMessages objectsAtIndexes:indexSet]];
                    
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                    [dictionary setObject:messages forKey:@"messages"];
                    [dictionary setObject:compareDateKey forKey:@"date"];
                    
                    [separetedArray addObject:dictionary];
                    continue;
                }
                int length = i - currentIndex + 1;
                NSRange range = NSMakeRange(currentIndex, length);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                NSMutableArray *messages = [NSMutableArray arrayWithArray:[_originHistoryMessages objectsAtIndexes:indexSet]];
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [dictionary setObject:messages forKey:@"messages"];
                [dictionary setObject:compareDateKey forKey:@"date"];
                
                [separetedArray addObject:dictionary];
            }
        }
    }
    
    return separetedArray;
}

-(void)cancelNetworkRequest
{
    for (UIView *view in self.collectionView.subviews) {
        if ([view isMemberOfClass:[MNMessageViewCell class]]) {
            MNMessageViewCell *cell = (MNMessageViewCell*)view;
            if ([cell respondsToSelector:@selector(cancelNetworkRequest)]) {
                [cell performSelector:@selector(cancelNetworkRequest)];
            }
        }
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([MNRecordViewController class])])
    {
        
        MNRecordViewController *recordViewController = segue.destinationViewController;
        recordViewController.msg = sender;
        recordViewController.isLocalVideo = NO;
    }
    else if ([segue.identifier isEqualToString:NSStringFromClass([MNSnapshotViewController class])])
    {
        MNSnapshotViewController *snapshotViewController = segue.destinationViewController;
        snapshotViewController.msg = sender;
        snapshotViewController.snapshotID = ((mdev_msg*)sender).sn;
        snapshotViewController.snapshotImage = ((mdev_msg *)sender).local_thumb_img;
        
    }
//    else if ([segue.identifier isEqualToString:NSStringFromClass([MNSegmentRecordsViewController class])])
//    {
//        MNSegmentRecordsViewController *segmentRecordsViewController = segue.destinationViewController;
//        segmentRecordsViewController.deviceID = ((mdev_msg*)sender).sn;
//        segmentRecordsViewController.boxID = ((mdev_msg*)sender).sn;
//        
//    }
    else if ([segue.identifier isEqualToString:@"MNBoxRecordsViewController"])
    {
        MNBoxRecordsViewController *boxRecordsViewController = segue.destinationViewController;
        boxRecordsViewController.deviceID = _deviceID;
        boxRecordsViewController.boxID = ((mdev_msg*)sender).sn;
    }
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
    MNMessageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *dictionary = [_messages objectAtIndex:indexPath.section];
    mdev_msg *msg = [[dictionary objectForKey:@"messages"] objectAtIndex:indexPath.row];
    
    
    m_dev *device = [self.agent.devs get_dev_by_sn:_deviceID];
    
    cell.warnlabel.hidden = msg.msg_id > device.read_id ? NO : YES;
    cell.deviceID = msg.sn;
    if (msg.thumb_img_token && msg.thumb_img_token.length) {
        cell.token = msg.thumb_img_token;
    }
    else
    {
        cell.token = msg.min_img_token;
    }
    
    cell.type = msg.type;
    cell.messageID = msg.msg_id;
    cell.timeLabel.text = [[msg.format_data componentsSeparatedByString:@" "] lastObject];
    cell.durationLabel.text = msg.format_length;
    
    [device addObserver:self forKeyPath:@"read_id"options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.deviceArray addObject:device];
    //load network image
    [cell loadWebImage];
    
    [cell setNeedsLayout];
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MNMessageHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
    //
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
            || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight || (self.view.bounds.size.width > self.view.bounds.size.height))
        {
            //            float height = CGRectGetHeight(self.view.bounds);
//            NSInteger screenWidth = [UIDevice currentDevice].systemVersion.floatValue < 8.0 ? CGRectGetWidth(self.view.bounds) : self.transitionToSize.width;
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? width : height;
            //            CGFloat screenWidth = width > height ? width : height;
            
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
            //            float height = CGRectGetHeight(self.view.bounds);
//            NSInteger screenWidth = [UIDevice currentDevice].systemVersion.floatValue < 8.0 ? CGRectGetWidth(self.view.bounds) : self.transitionToSize.width;
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? height : width;
            //            CGFloat screenWidth = width <  height ? width : height;
            
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
    
    NSDictionary *dictionary = [_messages objectAtIndex:indexPath.section];
    NSArray *infos = [dictionary objectForKey:@"messages"];
    
    mdev_msg *msg = [infos objectAtIndex:indexPath.row];
    MNMessageViewCell *cell = (MNMessageViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    msg.local_thumb_img = cell.contentImageView.image;
    //save the read_id of device for local cache
    m_dev *device = [self.agent.devs get_dev_by_sn:_deviceID];
    device.read_id = device.read_id < msg.msg_id ? msg.msg_id : device.read_id;
    cell.warnlabel.hidden = YES;
    [self.agent.devs save];
    
    if ([msg.type isEqualToString:@"record"])
    {
//        if (device.spv)
//        {
////            [self performSegueWithIdentifier:NSStringFromClass([MNSegmentRecordsViewController class]) sender:msg];
////              [self performSegueWithIdentifier:@"MNBoxRecordsViewController" sender:msg];
//        }
//        else

//            [self performSegueWithIdentifier:NSStringFromClass([MNSegmentRecordsViewController class]) sender:msg];
        
        [self performSegueWithIdentifier:NSStringFromClass([MNRecordViewController class]) sender:msg];
    }
    else
    {
        [self performSegueWithIdentifier:NSStringFromClass([MNSnapshotViewController class]) sender:msg];
    }
}

#pragma mark - Handle longpress gesture
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (_isLocal) {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    if ([NSStringFromSelector(@selector(action)) isEqualToString:@"menuItemDelete:"]) {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//}

//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    NSLog(@"performAction");
//}

//#pragma mark - MNMenuDelegate
//- (void)menuItemDelete:(id)sender forCell:(MNMessageViewCell*)cell;
//{
//    NSInteger index = [[self.collectionView indexPathForCell:cell] row];
//    _deleteLocalInfo = [self.messages objectAtIndex:index];
//    UIAlertView *deleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mcs_are_you_sure_delete", nil)
//                                                              message:nil
//                                                             delegate:self
//                                                    cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
//                                                    otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
//    deleteAlertView.tag = DELETE_TAG;
//    [deleteAlertView show];
//
//}

#pragma mark - alertView Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == SUREBUTTON_INDEX) {
        NSString *mp4FilePath = self.deleteLocalInfo.mp4FilePath;
        NSString *infoFilePath = [[mp4FilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"inf"];
        
        BOOL deletedMp4;
        BOOL deletedInf;
        
        NSError *errorMp4 = nil;
        deletedMp4 = [[NSFileManager defaultManager] removeItemAtPath:mp4FilePath error:&errorMp4];
        if (errorMp4) {
            NSLog(@"%@", [errorMp4 localizedDescription]);
        }
        
        NSError *errorInf = nil;
        deletedInf = [[NSFileManager defaultManager] removeItemAtPath:infoFilePath error:&errorInf];
        if (errorInf) {
            NSLog(@"%@", [errorInf localizedDescription]);
        }
        
        if (deletedMp4 || deletedInf) {
            [[_deleteDictionary objectForKey:@"messages"] removeObject:_deleteLocalInfo];
            
            NSMutableArray *messageArray = [_deleteDictionary objectForKey:@"messages"];
            NSInteger count = messageArray.count;
            if (!count) {
                [self.messages removeObject:_deleteDictionary];
            }
            [self.collectionView reloadData];
            [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];
        }
    }
    
}

#pragma mark - ScrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isLocal) {
        _reloadDataPromptLabel.hidden = YES;
        _pullUpActivityView.hidden = YES;
        return;
    }
    CGFloat bottomOffset = [self scrollViewOffsetFromBottom:scrollView];
    if (_isRefreshing) {
        
        CGFloat offset = MAX(bottomOffset * -1, 0);
        offset = MIN(offset, PULL_AREA_HEIGTH);
        UIEdgeInsets currentInsets = scrollView.contentInset;
        currentInsets.bottom = offset? offset + [self visibleTableHeightDiffWithBoundsHeight:scrollView]: 0;
        scrollView.contentInset = currentInsets;
        
    } else if (_finishReloadData) {
        _reloadDataPromptLabel.hidden = NO;
        _reloadDataPromptLabel.text = NSLocalizedString(@"mcs_load_end", nil);
    }else if (scrollView.isDragging) {
        
        if (bottomOffset > -60 && bottomOffset < -20) {
            _reloadDataPromptLabel.hidden = NO;
            
            _reloadDataPromptLabel.text = NSLocalizedString(@"mcs_pull_refresh_hint", nil);
        } else if (bottomOffset < -60 && bottomOffset > -80){
            _reloadDataPromptLabel.hidden = NO;
            
            _reloadDataPromptLabel.text = NSLocalizedString(@"mcs_release_then_loading_data_hint", nil);
        }
    }
    
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (_isLocal) {
        return;
    }
    CGFloat bottomOffset = [self scrollViewOffsetFromBottom:scrollView];
    NSLog(@"bottomOffset:%f _finishReloadData:%d _isRefreshing:%d", bottomOffset, _finishReloadData, _isRefreshing);
    if ([self scrollViewOffsetFromBottom:scrollView] <= -PULL_AREA_HEIGTH && !_isRefreshing&& !_finishReloadData)
    {
        _reloadDataPromptLabel.text = NSLocalizedString(@"mcs_loading", nil);
        [self startAnimatingWithScrollView:scrollView];
    }
}

//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if ([self scrollViewOffsetFromBottom:scrollView] <= -PULL_TRIGGER_HEIGHT && !_isRefreshing)
//    {
//        if (!_finishReloadData) {
//            [self startAnimatingWithScrollView:scrollView];
//        }
//    }
//}

#pragma mark - Util for pull up refresh
- (void)scrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
    [_pullUpActivityView stopAnimating];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = 0;
    scrollView.contentInset = currentInsets;
    [UIView commitAnimations];
}

- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView
{
    [_pullUpActivityView startAnimating];
    [self performSelector:@selector(refresh:) withObject:nil afterDelay:0.5f];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = PULL_AREA_HEIGTH + [self visibleTableHeightDiffWithBoundsHeight:scrollView];
    scrollView.contentInset = currentInsets;
    [UIView commitAnimations];
    
    if([self scrollViewOffsetFromBottom:scrollView] == 0){
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + PULL_TRIGGER_HEIGHT) animated:YES];
    }
}

- (CGFloat)scrollViewOffsetFromBottom:(UIScrollView *) scrollView
{
    CGFloat scrollAreaContenHeight = scrollView.contentSize.height;
    
    CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, scrollAreaContenHeight);
    CGFloat scrolledDistance = scrollView.contentOffset.y + visibleTableHeight; // If scrolled all the way down this should add upp to the content heigh.
    
    CGFloat normalizedOffset = scrollAreaContenHeight - scrolledDistance;
    
    return normalizedOffset;
    
}

- (CGFloat)visibleTableHeightDiffWithBoundsHeight:(UIScrollView *) scrollView
{
    return (scrollView.bounds.size.height - MIN(scrollView.bounds.size.height, scrollView.contentSize.height));
}

#pragma mark -m oberser
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    m_dev *device = [self.agent.devs get_dev_by_sn:_deviceID];
    for (UIView *view in self.collectionView.subviews) {
        if ([view isMemberOfClass:[MNMessageViewCell class]]) {
            ((MNMessageViewCell *)view).warnlabel.hidden = ((MNMessageViewCell *)view).messageID > device.read_id ? NO : YES;
        }
    }
}
@end

