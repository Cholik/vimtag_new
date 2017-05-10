//
//  MNCacheVideoViewController.m
//  mipci
//
//  Created by mining on 16/2/25.
//
//

#import "MNCacheVideoViewController.h"
#import "MNCacheVideoCell.h"
#import "LocalVideoInfo.h"
#import "MNProgressHUD.h"
#import "MNRecordViewController.h"
#import "AppDelegate.h"

#define one_trillion                    (1024.0*1024.0)
#define DEFAULT_LINE_COUNTS         1
#define DEFAULT_LINE_HEIGHT         104
#define DEFAULT_CELL_MARGIN         12

@interface MNCacheVideoViewController ()

@property (strong, nonatomic) LocalVideoInfo *deleteLocalInfo;
@property (strong, nonatomic) NSMutableDictionary  *deleteDictionary;
@property (strong, nonatomic) MNProgressHUD *progressHUD;
@property (assign, nonatomic) CGSize transitionToSize;
@property (strong, nonatomic) NSMutableArray *originLocalMessages;
@property (assign, nonatomic) BOOL      isEdit;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNCacheVideoViewController

static NSString * const reuseIdentifier = @"Cell";

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

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}
//-(NSMutableArray *)messages
//{
//    @synchronized(self)
//    {
//        if (nil ==_messages) {
//            _messages = [NSMutableArray array];
//        }
//        
//        return _messages;
//    }
//}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

#pragma mark - View lifecycle
- (void)initUI
{
    self.navigationItem.title = _directoryId;
    _editBarButtonItem.title = NSLocalizedString(@"mcs_edit", nil);
    _emptyPromptLabel.text = NSLocalizedString(@"mcs_no_local_video", nil);
    
    [_deleteBtn setTitle:NSLocalizedString(@"mcs_delete", nil) forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(detimeniedDelete) forControlEvents:UIControlEventTouchUpInside];
    _deleteBtn.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    self.collectionView.alwaysBounceVertical = YES;
    self.originLocalMessages = [NSMutableArray array];
    _originLocalMessages = [self loadLocalVideoInfoByID:_directoryId];
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _isEdit = NO;
    _transitionToSize = self.view.bounds.size;
    [_emptyPromptView setHidden:(self.originLocalMessages.lastObject ? YES : NO)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)detimeniedDelete
{
    if ([self selectVideoStatu]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"mcs_are_you_sure_delete", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
        [alertView show];
    }
    else
    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请选择要删除的视屏，或者点击右上角返回" delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil) otherButtonTitles: nil];
//        [alert show];
    }

}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)edit:(id)sender
{
    if (![self.originLocalMessages lastObject]) {
        return;
    }
    _isEdit = !_isEdit;
    if (_isEdit)
    {
        _deleteBtn.hidden = NO;
        self.collectionBottomConstraint.constant = 44;
        _editBarButtonItem.title = NSLocalizedString(@"mcs_cancel", nil);
        [self.collectionView reloadData];
    }
    else
    {
        _editBarButtonItem.title = NSLocalizedString(@"mcs_edit", nil);
        _deleteBtn.hidden = YES;
        self.collectionBottomConstraint.constant = 0;
        [self resetVideoSelectStatu];
        [self.collectionView reloadData];
    }
}

#pragma mark - Get Video
- (NSMutableArray *)loadLocalVideoInfoByID:(NSString *)serialNumber
{
    NSMutableArray *videoInfoArray = [NSMutableArray array];
    
    NSString *videoInfoDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@", serialNumber]];
    
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
            if (_isBox)
            {
                if ([videoInfo rangeOfString:@"1jfieg"].length)
                {
                    NSString *boxVideoInfoDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@/%@", serialNumber, videoInfo]];
                    NSArray *boxVideoInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:boxVideoInfoDirectory error:nil];
                    for (NSString *boxVideoInfo in boxVideoInfos)
                    {
                        if ([boxVideoInfo hasSuffix:@".inf"])
                        {
                            NSString *videoInfoPath = [boxVideoInfoDirectory stringByAppendingPathComponent:boxVideoInfo];
                            LocalVideoInfo *videoInfoObj = [NSKeyedUnarchiver unarchiveObjectWithFile:videoInfoPath];

                            if (videoInfoObj != nil) {
                                videoInfoObj.isSelect = NO;
                                videoInfoObj.mp4FilePath = [[NSString stringWithFormat:@"%@/%@",boxVideoInfoDirectory,boxVideoInfo] stringByReplacingOccurrencesOfString:@".inf" withString:@".mp4"];
                                [videoInfoArray addObject:videoInfoObj];
                            }
                        }
                    }
                }
            }
            else
            {
                if ([videoInfo hasSuffix:@".inf"]) {
                    NSString *videoInfoPath = [videoInfoDirectory stringByAppendingPathComponent:videoInfo];
                    LocalVideoInfo *videoInfoObj = [NSKeyedUnarchiver unarchiveObjectWithFile:videoInfoPath];
                    if (videoInfoObj != nil) {
                        videoInfoObj.isSelect = NO;
                        videoInfoObj.mp4FilePath = [[NSString stringWithFormat:@"%@/%@",videoInfoDirectory,videoInfo] stringByReplacingOccurrencesOfString:@".inf" withString:@".mp4"];
                        [videoInfoArray addObject:videoInfoObj];
                    }
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

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([MNRecordViewController class])])
    {
        MNRecordViewController *recordViewController = segue.destinationViewController;
        recordViewController.localVideoInfo = sender;
        recordViewController.isLocalVideo = YES;
        recordViewController.boxID = _directoryId;
        recordViewController.deviceID = _isBox ? ((LocalVideoInfo*)sender).deviceId: _directoryId;
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.originLocalMessages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNCacheVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    LocalVideoInfo *videoInfo = (LocalVideoInfo *)(self.originLocalMessages[indexPath.row]);
    cell.idLabel.text = [NSString stringWithFormat:@"ID:%@",videoInfo.deviceId];
    cell.sizeLabel.text = [NSString stringWithFormat:@"%@：%.1lfM",NSLocalizedString(@"mcs_video_size",nil),[self fileSizeAtPath:videoInfo.mp4FilePath]];
    cell.durationLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"mcs_video_duration", nil),videoInfo.duration];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"mcs_time", nil),videoInfo.date];
    
    [cell.selectImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
    cell.selectImage.contentMode =  UIViewContentModeCenter;
    cell.selectImage.clipsToBounds  = YES;
    
    if (self.app.is_vimtag) {
        cell.backgroundImage.image = videoInfo.image != nil ? videoInfo.image : [UIImage imageNamed:@"vt_cellBg.png"];
        cell.selectImage.image = [UIImage imageNamed:_isEdit ? (videoInfo.isSelect ? @"vt_select.png" : @"vt_unselected.png") : @"vt_next.png"];
    }
    else if (self.app.is_ebitcam)
    {
        cell.backgroundImage.image = videoInfo.image != nil ? videoInfo.image : [UIImage imageNamed:@"eb_cellBg.png"];
        cell.selectImage.image = [UIImage imageNamed:_isEdit ? (videoInfo.isSelect ? @"save_network" : @"no_save_network") : @"vt_next.png"];
    }
    else if (self.app.is_mipc)
    {
        cell.backgroundImage.image = videoInfo.image != nil ? videoInfo.image : [UIImage imageNamed:@"mi_cellBg.png"];
        cell.selectImage.image = [UIImage imageNamed:_isEdit ? (videoInfo.isSelect ? @"save_network" : @"no_save_network") : @"vt_next.png"];
    }
    else {
        cell.backgroundImage.image = videoInfo.image != nil ? videoInfo.image : [UIImage imageNamed:self.app.is_luxcam ? @"placeholder.png" : @"camera_placeholder.png"];
        cell.selectImage.image = [UIImage imageNamed:_isEdit ? (videoInfo.isSelect ? @"save_network" : @"no_save_network") : @"vt_next.png"];
    }
    [cell setNeedsLayout];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    LocalVideoInfo *videoInfo = (LocalVideoInfo *)(self.originLocalMessages[indexPath.row]);
    if (_isEdit) {
        MNCacheVideoCell *cell = (MNCacheVideoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        videoInfo.isSelect = !videoInfo.isSelect;
        cell.selectImage.image = [UIImage imageNamed:(videoInfo.isSelect ? @"vt_select.png" : @"vt_unselected.png")];
        if (self.app.is_vimtag) {
            cell.selectImage.image = [UIImage imageNamed:(videoInfo.isSelect ? @"vt_select.png" : @"vt_unselected.png")];
        } else {
             cell.selectImage.image = [UIImage imageNamed:(videoInfo.isSelect ? @"save_network" : @"no_save_network")];
        }
    }
    else
    {
        MNRecordViewController *recordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MNRecordViewController"];
        recordViewController.localVideoInfo = videoInfo;
        recordViewController.isLocalVideo = YES;
        recordViewController.deviceID = _isBox ? [self getBoxID:videoInfo.mp4FilePath] : _directoryId;
        recordViewController.boxID = _directoryId;
        
        [self.navigationController pushViewController:recordViewController animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
        {
            NSInteger screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
            int lineCounts = DEFAULT_LINE_COUNTS + 2;
            NSInteger cellWidth = (screenWidth - DEFAULT_CELL_MARGIN * (lineCounts - 1)) / lineCounts;
            itemSize = CGSizeMake(cellWidth, DEFAULT_LINE_HEIGHT);
        }
        else
        {
            NSInteger screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_CELL_MARGIN * (lineCounts - 1)) / lineCounts;
            itemSize = CGSizeMake(cellWidth, DEFAULT_LINE_HEIGHT);
        }
    }
    else
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
        {
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? width : height;
            int lineCounts = DEFAULT_LINE_COUNTS + 1;
            NSInteger cellWidth = (screenWidth - DEFAULT_CELL_MARGIN * (lineCounts - 1)) / lineCounts;
            itemSize = CGSizeMake(cellWidth, DEFAULT_LINE_HEIGHT);
        }
        else
        {
            float height = CGRectGetHeight(self.view.bounds);
            float width = CGRectGetWidth(self.view.bounds);
            NSInteger screenWidth = width > height ? height : width;
            int lineCounts = DEFAULT_LINE_COUNTS;
            CGFloat cellWidth = screenWidth / lineCounts;
            itemSize = CGSizeMake(cellWidth, DEFAULT_LINE_HEIGHT);
        }
    }
    
    return itemSize;
}

#pragma mark - InterfaceOrientation
- (BOOL)shouldAutorotate
{
    return YES;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //    [self updateCollectionViewFlowLayout];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0){
        [self.collectionView reloadData];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"xxxxxx");
    _transitionToSize = size;
    [self.collectionView reloadData];
}

#pragma mark - UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if ([self.originLocalMessages lastObject])
        {
            NSMutableArray *tmpArray = [NSMutableArray array];
            for (LocalVideoInfo *videoInfo in self.originLocalMessages)
            {
                if (videoInfo.isSelect)
                {
                    //Delete Select Videp
                    NSString *mp4FilePath = videoInfo.mp4FilePath;
                    NSString *infoFilePath = [[mp4FilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"inf"];
                    
                    BOOL deletedMp4;
                    BOOL deletedInf;
                    
                    NSError *errorInf = nil;
                    deletedInf = [[NSFileManager defaultManager] removeItemAtPath:infoFilePath error:&errorInf];
                    if (errorInf) {
                        NSLog(@"%@", [errorInf localizedDescription]);
                    }
                    
                    NSError *errorMp4 = nil;
                    deletedMp4 = [[NSFileManager defaultManager] removeItemAtPath:mp4FilePath error:&errorMp4];
                    if (errorMp4) {
                        NSLog(@"%@", [errorMp4 localizedDescription]);
                    }
                    
                    if (deletedMp4 || deletedInf)
                    {
                        [tmpArray addObject:videoInfo];
                    }
                }
            }
            [self.originLocalMessages removeObjectsInArray:tmpArray];
            self.cacheDirectoryViewController.isDeleteVideo = YES;
        }
    }
    else
    {
        [self resetVideoSelectStatu];
    }
    [self.collectionView reloadData];
    [_emptyPromptView setHidden:(self.originLocalMessages.lastObject ? YES : NO)];
    if (!self.originLocalMessages.lastObject) {
        _editBarButtonItem.title = NSLocalizedString(@"mcs_edit", nil);
    }
}

#pragma mark - Custom methods
- (float)fileSizeAtPath:(NSString *)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:_isBox ? [NSString stringWithFormat:@"video-mp4/%@/%@",_directoryId,[self getFileName:url]] : [NSString stringWithFormat:@"video-mp4/%@/%@",_directoryId,[self getFileName:url]]];
    
//    NSLog(@"%@",filePath);
    if ([fileManager fileExistsAtPath:filePath])
    {
        return ([[fileManager attributesOfItemAtPath:filePath error:nil] fileSize]/one_trillion);
    }
    return 0;
}

- (NSString *)getFileName:(NSString *)filePath
{
    NSString *fileString = filePath;
    NSString *fileName = nil;
    unsigned long location = 0;
    unsigned long boxLocation = 0;
    
    for(int i =0; i < [fileString length]; i++)
    {
        fileName = [fileString substringWithRange:NSMakeRange(i, 1)];
        if ([fileName isEqualToString:@"/"]) {
            boxLocation = location;
            location = i;
        }
    }
    
    return [fileString substringWithRange:_isBox ? NSMakeRange(boxLocation + 1,[fileString length] - boxLocation -1) : NSMakeRange(location + 1,[fileString length] - location -1)];
}

- (NSString *)getBoxID:(NSString *)filePath
{
    NSString *fileString = filePath;
    NSString *fileName = nil;
    unsigned long location = 0;
    unsigned long boxLocation = 0;
    
    for(int i =0; i < [fileString length]; i++)
    {
        fileName = [fileString substringWithRange:NSMakeRange(i, 1)];
        if ([fileName isEqualToString:@"/"]) {
            boxLocation = location;
            location = i;
        }
    }
    
    return [fileString substringWithRange: NSMakeRange(boxLocation + 1,location - boxLocation - 1)];
}

#pragma mark - Custom Method
- (BOOL)selectVideoStatu
{
    if ([self.originLocalMessages lastObject])
    {
        for (LocalVideoInfo *videoInfo in self.originLocalMessages)
        {
            if (videoInfo.isSelect)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (void)resetVideoSelectStatu
{
    if ([self.originLocalMessages lastObject])
    {
        for (LocalVideoInfo *videoInfo in self.originLocalMessages)
        {
            videoInfo.isSelect = NO;
        }
    }
}

@end
