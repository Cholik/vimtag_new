//
//  MNCacheDirectoryViewController.m
//  mipci
//
//  Created by mining on 16/3/1.
//
//

#import "MNCacheDirectoryViewController.h"
#import "MNCacheDirectoryCell.h"
#import "LocalVideoInfo.h"
#import "MNCacheVideoViewController.h"
#import "DirectoryConf.h"
#import "AppDelegate.h"

#define DEFAULT_LINE_COUNTS         1
#define DEFAULT_LINE_HEIGHT         112
#define DEFAULT_CELL_MARGIN         12

/****** Save cache directory ******/
@interface MNDirectory : NSObject

@property (strong, nonatomic) NSString  *nickName;
@property (strong, nonatomic) NSString  *directoryId;
@property (strong, nonatomic) NSString  *directoryPath;
@property (assign, nonatomic) long      videoCount;
@property (strong, nonatomic) UIImage   *image;
@property (assign, nonatomic) BOOL      isBox;
@property (assign, nonatomic) BOOL      isSelect;
@end

@implementation MNDirectory

@end

@interface MNCacheDirectoryViewController ()

@property (strong, nonatomic) NSMutableArray *directoryArray;
@property (strong, nonatomic) NSMutableArray *oldDirectoryArray;
@property (assign, nonatomic) BOOL      isEdit;
@property (weak, nonatomic) AppDelegate *app;
//@property (strong, nonatomic) UIButton *deleteBtn;

@end

@implementation MNCacheDirectoryViewController

static NSString * const reuseIdentifier = @"Cell";

- (NSMutableArray *)directoryArray
{
    @synchronized(self){
        if (nil == _directoryArray) {
            _directoryArray = [NSMutableArray array];
        }
        
        return _directoryArray;
    }
}

- (AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

#pragma mark - View lifecycle
- (void)initUI
{
    self.navigationItem.title = NSLocalizedString(@"mcs_my_folder", nil);
    _editBarButtonItem.title = NSLocalizedString(@"mcs_edit", nil);
    _emptyPromptLabel.text = NSLocalizedString(@"mcs_empty_folder", nil);
    _isDeleteVideo = NO;
    [_deleteBtn setTitle:NSLocalizedString(@"mcs_delete", nil) forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deteminedDelete) forControlEvents:UIControlEventTouchUpInside];
    _deleteBtn.hidden = YES;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    self.collectionView.alwaysBounceVertical = YES;
    
    //show local file
    [self getVideoCacheFile];
    
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _isEdit = NO;
    if (_isDeleteVideo) {
        //Deal with deleting video in directory
        if ([self.directoryArray lastObject])
        {
            [self.directoryArray removeAllObjects];
            [self getVideoCacheFile];
            [self.collectionView reloadData];
        }
        _isDeleteVideo = NO;
    }
    [_emptyPromptView setHidden:(self.directoryArray.lastObject ? YES : NO)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)edit:(id)sender
{
    if (![self.directoryArray lastObject]) {
        return;
    }
    _isEdit = !_isEdit;
    if (_isEdit)
    {
        _deleteBtn.hidden = NO;
        self.collectionBottomConstraint.constant = 44;
        _editBarButtonItem.title = NSLocalizedString(@"mcs_cancel",nil);
        [self.collectionView reloadData];
    }
    else
    {
        _deleteBtn.hidden = YES;
        self.collectionBottomConstraint.constant = 0;
        _editBarButtonItem.title = NSLocalizedString(@"mcs_edit", nil);
        [self resetDirectorySelectStatus];
        [self.collectionView reloadData];
    }
}

#pragma mark -delete Video cache
-(void)deteminedDelete
{
    //alert delete video
    if ([self selectDirectoryStatus]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"mcs_are_you_sure_delete", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"mcs_cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"mcs_ok", nil), nil];
        [alertView show];
    }
    else
    {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请选择你要删除的视屏,或者点击右上角返回" delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_ok", nil) otherButtonTitles: nil];
//        [alertView show];
    }

}


#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.directoryArray.count;
    //    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNCacheDirectoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    MNDirectory *directory = (MNDirectory *)(self.directoryArray[indexPath.row]);
    cell.titleLabel.text = directory.nickName;
    cell.detailLabel.text = [NSString stringWithFormat:@"%ld %@",directory.videoCount,NSLocalizedString(@"mcs_video_number", nil)];
    cell.isBox = directory.isBox;
    if (self.app.is_vimtag) {
        cell.backgroundImage.image = [UIImage imageNamed:@"vt_cellBg.png"];
        [cell.selectButton setImage:[UIImage imageNamed:(_isEdit ? (directory.isSelect ? @"vt_select.png" : @"vt_unselected.png") : @"vt_next.png")] forState:UIControlStateNormal];
    }
    else if (self.app.is_ebitcam)
    {
       cell.backgroundImage.image = [UIImage imageNamed:@"eb_cellBg.png"];
       [cell.selectButton setImage:[UIImage imageNamed:(_isEdit ? (directory.isSelect ? @"save_network" : @"no_save_network") : @"vt_next.png")] forState:UIControlStateNormal];
    }
    else if (self.app.is_mipc)
    {
        cell.backgroundImage.image = [UIImage imageNamed:@"mi_cellBg.png"];
        [cell.selectButton setImage:[UIImage imageNamed:(_isEdit ? (directory.isSelect ? @"save_network" : @"no_save_network") : @"vt_next.png")] forState:UIControlStateNormal];
    }
    else {
        cell.backgroundImage.image = [UIImage imageNamed: self.app.is_luxcam ? @"placeholder.png" : @"camera_placeholder.png"];
       [cell.selectButton setImage:[UIImage imageNamed:(_isEdit ? (directory.isSelect ? @"save_network" : @"no_save_network") : @"vt_next.png")] forState:UIControlStateNormal];
    }
    if (directory.image) {
        cell.backgroundImage.image = directory.image;
    }
    cell.selectButton.enabled = NO;
    [cell setNeedsLayout];
    
//    NSLog(@"w:%lf h:%lf",cell.backgroundImage.image.size.width, cell.backgroundImage.image.size.height);
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    MNDirectory *directory = (MNDirectory *)(self.directoryArray[indexPath.row]);
    if (_isEdit)
    {
        MNCacheDirectoryCell *cell = (MNCacheDirectoryCell *)[collectionView cellForItemAtIndexPath:indexPath];
        directory.isSelect = !directory.isSelect;
        if (self.app.is_vimtag) {
            [cell.selectButton setImage:[UIImage imageNamed:(directory.isSelect ? @"vt_select.png" : @"vt_unselected.png")] forState:UIControlStateNormal];

        } else {
            [cell.selectButton setImage:[UIImage imageNamed:(directory.isSelect ? @"save_network" : @"no_save_network")] forState:UIControlStateNormal];
        }

    }
    else
    {
        [self performSegueWithIdentifier:@"MNCacheVideoViewController" sender:directory];
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

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([MNCacheVideoViewController class])])
    {
        MNCacheVideoViewController *cacheVideoViewController = segue.destinationViewController;
        cacheVideoViewController.directoryId = ((MNDirectory *)sender).directoryId;
        cacheVideoViewController.isBox = ((MNDirectory *)sender).isBox;
        cacheVideoViewController.cacheDirectoryViewController = self;
    }
}

#pragma mark - InterfaceOrientation
-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //    [self updateCollectionViewFlowLayout];
    [self.collectionView reloadData];
}

#pragma mark - UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if ([self.directoryArray lastObject])
        {
            NSMutableArray *tmpArray = [NSMutableArray array];
            for (MNDirectory *directory in self.directoryArray)
            {
                if (directory.isSelect)
                {
                    //Delete Select Directory
                    NSString *directoryPath = directory.directoryPath;
                    NSError *error = nil;
                    if (![[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error]) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    [tmpArray addObject:directory];
                }
            }
            [self.directoryArray removeObjectsInArray:tmpArray];
            
        }
    }
    else
    {
        [self resetDirectorySelectStatus];
    }
    [self.collectionView reloadData];
    [_emptyPromptView setHidden:(self.directoryArray.lastObject ? YES : NO)];
    if (!self.directoryArray.lastObject) {
    _editBarButtonItem.title = NSLocalizedString(@"mcs_edit", nil);
    }
}

#pragma mark - Get Video Cache File
- (void)getVideoCacheFile
{
    NSString *saveDirectory  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"video-mp4"];
    NSArray *directoryInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:saveDirectory error:nil];
    for (NSString *directoryInfo in directoryInfos)
    {
        if ([directoryInfo rangeOfString:@"1jfieg"].length)
        {
            //init directory
            MNDirectory *directory = [[MNDirectory alloc] init];
            directory.directoryId = directoryInfo;
            directory.videoCount = 0;
            directory.isBox = NO;
            directory.isSelect = NO;
            BOOL firstVideoFlag = NO;
            
            NSString *videoInfoDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@", directoryInfo]];
            directory.directoryPath = videoInfoDirectory;
            NSArray *videoInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:videoInfoDirectory error:nil];
            for (NSString *videoInfo in videoInfos)
            {
                if ([videoInfo rangeOfString:@"_1jfieg"].length)
                {
                    if ([videoInfo hasSuffix:@".inf"]) {
                        directory.videoCount++;
                        if (!firstVideoFlag) {
                            NSString *videoInfoPath = [videoInfoDirectory stringByAppendingPathComponent:videoInfo];
                            LocalVideoInfo *videoInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:videoInfoPath];
                            directory.image = videoInfo.image;
                            firstVideoFlag = YES;
                        }
                    }
                }
                else if ([videoInfo rangeOfString:@"1jfieg"].length && [videoInfo rangeOfString:@"_"].length)
                {
                    if ([videoInfo hasSuffix:@".inf"]) {
                        directory.videoCount++;
                        if (!firstVideoFlag) {
                            NSString *videoInfoPath = [videoInfoDirectory stringByAppendingPathComponent:videoInfo];
                            LocalVideoInfo *videoInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:videoInfoPath];
                            directory.image = videoInfo.image;
                            firstVideoFlag = YES;
                        }
                    }
                }
                else if ([videoInfo rangeOfString:@"1jfieg"].length)
                {
                    //box video, flag it
                    directory.isBox = YES;
                    
                    NSString *boxVideoInfoDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"video-mp4/%@/%@", directoryInfo, videoInfo]];
                    NSArray *boxVideoInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:boxVideoInfoDirectory error:nil];
                    for (NSString *boxVideoInfo in boxVideoInfos)
                    {
                        if ([boxVideoInfo rangeOfString:@"_1jfieg"].length && [boxVideoInfo hasSuffix:@".inf"])
                        {
                            directory.videoCount++;
                            if (!firstVideoFlag) {
                                NSString *videoInfoPath = [boxVideoInfoDirectory stringByAppendingPathComponent:boxVideoInfo];
                                LocalVideoInfo *videoInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:videoInfoPath];
                                directory.image = videoInfo.image;
                                firstVideoFlag = YES;
                            }
                        }
                    }
                }
            }
            
            if (directory.videoCount) {
                DirectoryConf *directotyConf = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@.conf",videoInfoDirectory]];
                directory.nickName = directotyConf.nick.length ? directotyConf.nick : directory.directoryId;
                [self.directoryArray addObject:directory];
            }
        }
    }
}

#pragma mark - Custom Method
- (BOOL)selectDirectoryStatus
{
    if ([self.directoryArray lastObject])
    {
        for (MNDirectory *directory in self.directoryArray)
        {
            if (directory.isSelect)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (void)resetDirectorySelectStatus
{
    if ([self.directoryArray lastObject])
    {
        for (MNDirectory *directory in self.directoryArray)
        {
            directory.isSelect = NO;
        }
    }
}

@end
