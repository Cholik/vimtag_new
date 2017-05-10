//
//  MNLocalMessageViewController.m
//  mipci
//
//
//

#import "MNBoxLocalRecordViewController.h"
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
#import "MNBoxPlayViewController.h"
#import "MNBoxSegmentViewCell.h"

#define DEFAULT_LINE_COUNTS       2
#define DEFAULT_CELL_MARGIN       4
#define DEFAULT_EDGE_MARGIN       5
#define DELETE_TAG                1004
#define SUREBUTTON_INDEX           1

@interface MNBoxLocalRecordViewController ()
@property (strong, nonatomic) mipc_agent *agent;
@property (assign, nonatomic) BOOL isViewAppearing;

@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) LocalVideoInfo *deleteLocalInfo;
@property (strong, nonatomic) NSMutableDictionary  *deleteDictionary;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (assign, nonatomic) CGSize transitionToSize;
@property (strong, nonatomic) NSMutableArray *deviceArray;
@property (weak, nonatomic) MNConfiguration *configuration;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *originLocalMessages;
@property (strong, nonatomic) NSMutableArray *originOldLocalMessages;

@end

@implementation MNBoxLocalRecordViewController

static NSString * const reuseIdentifier = @"Cell";

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

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
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


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _emptyPromptLabel.text = NSLocalizedString(@"mcs_no_local_record", nil);

    self.collectionView.alwaysBounceVertical = YES;

    self.originLocalMessages = [NSMutableArray array];
    _isViewAppearing = YES;
    
    [self.collectionView reloadData];
    _originLocalMessages = [self loadLocalVideoInfoByID:_deviceID boxID:_boxID];
    _originOldLocalMessages = _originLocalMessages;
    self.messages = [self separateArrayUsingDate];
    [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _transitionToSize = self.view.bounds.size;
    _originLocalMessages = [self loadLocalVideoInfoByID:_deviceID boxID:_boxID];
    if (_originLocalMessages.count != _originOldLocalMessages.count) {
        _originOldLocalMessages = _originLocalMessages;
        self.messages = [self separateArrayUsingDate];
        [self.collectionView reloadData];
        [_emptyPromptView setHidden:(self.messages.lastObject ? YES : NO)];
    }
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
    
    //    [self cancelNetworkRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLongPress:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [recognizer locationInView:recognizer.view];
        MNBoxSegmentViewCell *cell = ((MNBoxSegmentViewCell *)recognizer.view);
        NSInteger Index = [[self.collectionView indexPathForCell:cell] row];
        NSInteger section = [[self.collectionView indexPathForCell:cell] section];
        _deleteDictionary = [self.messages objectAtIndex:section];
        _deleteLocalInfo = [[_deleteDictionary objectForKey:@"messages"] objectAtIndex:Index];
        
        [self becomeFirstResponder];
        
        UIMenuController *popMenuController = [UIMenuController sharedMenuController];
        UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"mcs_delete", nil) action:@selector(onMenuItemDelete:)];
        NSArray *menuItemArray = [NSArray arrayWithObject:deleteMenuItem];
        [popMenuController setMenuItems:menuItemArray];
        [popMenuController setArrowDirection:UIMenuControllerArrowDown];
        [popMenuController setTargetRect:CGRectMake(point.x, point.y, 0, 0) inView:recognizer.view];
        [popMenuController setMenuVisible:YES animated:YES];
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
    //    [self updateCollectionViewFlowLayout];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0){
        [self.collectionView reloadData];
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"xxxxxx");
    _transitionToSize = size;
    [self.collectionView reloadData];
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


- (NSMutableArray *)loadLocalVideoInfoByID:(NSString *)serialNumber boxID:(NSString *)boxID
{
    NSMutableArray *videoInfoArray = [NSMutableArray array];
    
    NSString *videoInfoDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@/%@", boxID, serialNumber]];
    
    BOOL isDirectory;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:videoInfoDirectory isDirectory:&isDirectory];
    
    if (isDirectory && isFileExist) {
        NSError *error = nil;
        NSArray *videoInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:videoInfoDirectory error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        for (NSString *videoInfo in videoInfos)
        {
            if ([videoInfo hasSuffix:@".inf"]) {
                NSString *videoInfoPath = [videoInfoDirectory stringByAppendingPathComponent:videoInfo];
                LocalVideoInfo *videoInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:videoInfoPath];
                if (videoInfo != nil) {
                    [videoInfoArray addObject:videoInfo];
                }
            }
        }
        
        [videoInfoArray sortUsingComparator:^NSComparisonResult(LocalVideoInfo *obj1, LocalVideoInfo *obj2) {
            NSString *date1 = [[obj1.date componentsSeparatedByString:@" "] firstObject];
            NSString *date2 = [[obj2.date componentsSeparatedByString:@" "] firstObject];
            
            NSComparisonResult result = [date1 compare:date2];
            if (result == NSOrderedSame) {
                NSString *time1 = [[obj1.date componentsSeparatedByString:@" "] lastObject];
                NSString *time2 = [[obj2.date componentsSeparatedByString:@" "] lastObject];
                
                result = [time1 compare:time2];
            }
            
            return -result;
        }];
    }
    
    
    return videoInfoArray;
}

- (NSMutableArray *)separateArrayUsingDate
{
    NSString *compareDateKey;
    NSString *anotherDateKey;
    NSMutableArray *separetedArray = [NSMutableArray array];
    
    int currentIndex = 0;
    for (int i = 0; i < _originLocalMessages.count; i++)
    {
        LocalVideoInfo *localVideoInfo = _originLocalMessages[i];
        if (_originLocalMessages.count == 1) {
            compareDateKey = [[localVideoInfo.date componentsSeparatedByString:@" "] firstObject];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
            NSMutableArray *messages = [NSMutableArray arrayWithArray:[_originLocalMessages objectsAtIndexes:indexSet]];
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            [dictionary setObject:compareDateKey forKey:@"date"];
            [dictionary setObject:messages forKey:@"messages"];
            [separetedArray addObject:dictionary];
        }else  if (0 == i) {
            compareDateKey = [[localVideoInfo.date componentsSeparatedByString:@" "] firstObject];
        }
        else
        {
            anotherDateKey  = [[localVideoInfo.date componentsSeparatedByString:@" "] firstObject];
            if (![anotherDateKey isEqualToString:compareDateKey])
            {
                int length = i - currentIndex;
                NSRange range = NSMakeRange(currentIndex, length);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                NSMutableArray *messages = [NSMutableArray arrayWithArray:[_originLocalMessages objectsAtIndexes:indexSet]];
                
                currentIndex = i;
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [dictionary setObject:messages forKey:@"messages"];
                [dictionary setObject:compareDateKey forKey:@"date"];
                
                [separetedArray addObject:dictionary];
                
                compareDateKey = anotherDateKey;   //exchange
            }
            if (i == _originLocalMessages.count - 1)
            {
                int length = i - currentIndex + 1;
                NSRange range = NSMakeRange(currentIndex, length);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                NSMutableArray *messages = [NSMutableArray arrayWithArray:[_originLocalMessages objectsAtIndexes:indexSet]];
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [dictionary setObject:messages forKey:@"messages"];
                [dictionary setObject:compareDateKey forKey:@"date"];
                
                [separetedArray addObject:dictionary];
            }
        }
    }
    
    return separetedArray;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([MNRecordViewController class])])
    {
        MNRecordViewController *recordViewController = segue.destinationViewController;
        recordViewController.localVideoInfo = sender;
        recordViewController.isLocalVideo = YES;
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
    MNBoxSegmentViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//    MNMessageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSDictionary *dictionary = [_messages objectAtIndex:indexPath.section];
    LocalVideoInfo *localVideoInfo =[[dictionary objectForKey:@"messages"] objectAtIndex:indexPath.row];
    cell.deviceID = localVideoInfo.deviceId;
    cell.timeLabel.text = [[localVideoInfo.date componentsSeparatedByString:@" "] lastObject];
    cell.start_time = localVideoInfo.start_time;
    cell.end_time = localVideoInfo.end_time;
    cell.token = localVideoInfo.bigImageId;
    cell.durationLabel.text = localVideoInfo.duration;
    
    if (self.app.is_vimtag) {
        cell.markImageView.image = [UIImage imageNamed:@"vt_box_video.png"];
    }else if (self.app.is_luxcam)
    {
        cell.markImageView.image = [UIImage imageNamed:@"btn_play.png"];
    }else
    {
        cell.markImageView.image = [UIImage imageNamed:@"video.png"];
    }
    
    if (localVideoInfo.image) {
        cell.contentImageView.image = localVideoInfo.image;
    } else {
        if (self.app.is_vimtag) {
            cell.contentImageView.image = [UIImage imageNamed:@"vt_cellBg.png"];
        } else if (self.app.is_ebitcam){
            cell.contentImageView.image = [UIImage imageNamed:@"eb_cellBg.png"];
        } else if (self.app.is_mipc) {
            cell.contentImageView.image = [UIImage imageNamed:@"mi_cellBg.png"];
        } else {
            cell.contentImageView.image = [UIImage imageNamed: self.app.is_luxcam ? @"placeholder.png" : @"camera_placeholder.png"];
        }
    }
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [cell addGestureRecognizer:longPressGestureRecognizer];
    
    
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
    LocalVideoInfo * videoInfo = [infos objectAtIndex:indexPath.row];
    MNRecordViewController *recordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MNRecordViewController"];
    recordViewController.localVideoInfo = videoInfo;
    recordViewController.isLocalVideo = YES;
    recordViewController.deviceID = _deviceID;
    recordViewController.boxID = _boxID;
    [self.navigationController pushViewController:recordViewController animated:YES];
}


#pragma mark - alertView Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == SUREBUTTON_INDEX) {
        NSString *mp4FilePath = [self checkFilePath:self.deleteLocalInfo.mp4FilePath];
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

#pragma mark - Check URL
- (NSString *)checkFilePath:(NSString *)url
{
    NSString *fileURL = url;
    NSString *fileString = [self getFileName:fileURL];
    fileString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:(![_boxID isEqualToString:_deviceID]) ? [NSString stringWithFormat:@"video-mp4/%@/%@/%@", _boxID, _deviceID,fileString] : [NSString stringWithFormat:@"video-mp4/%@/%@",_deviceID,fileString]];
    
    NSString *tmpString = [NSString string];
    //Change String
    tmpString = [fileString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    fileURL = tmpString;
    if ([fileString rangeOfString:@" "].length) {
        //Rename
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        if ([fileManager moveItemAtPath:fileString toPath:tmpString error:&error])
        {
            NSLog(@"success");
            NSString *infoFilePath = [[fileString stringByDeletingPathExtension] stringByAppendingPathExtension:@"inf"];
            NSString *tmpInfoFilePath = [infoFilePath stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            if ([fileManager moveItemAtPath:infoFilePath toPath:tmpInfoFilePath error:&error]) {
                return fileURL;
            }
        }
    }
    return fileURL;
}

#pragma mark - Get File Name
- (NSString *)getFileName:(NSString *)filePath
{
    NSString *fileString = filePath;
    NSString *fileName = nil;
    unsigned long location = 0;
    
    for(int i =0; i < [fileString length]; i++)
    {
        fileName = [fileString substringWithRange:NSMakeRange(i, 1)];
        if ([fileName isEqualToString:@"/"]) {
            location = i;
        }
    }
    
    return [fileString substringWithRange:NSMakeRange(location + 1,[fileString length] - location -1)];
}

@end

