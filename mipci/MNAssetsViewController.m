//
//  MNAssetsViewController.m
//  mipci
//
//  Created by mining on 16/9/2.
//
//

#import "MNAssetsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MNAssetModel.h"
#import "MNPhotosBrowser.h"
#import "MNImagePickerController.h"
#define MARGIN 10
#define COL 4
#define KWidth [UIScreen mainScreen].bounds.size.width

@interface MNShowPicCell : UICollectionViewCell
@property(nonatomic,strong) UIButton *selectButton;

@end


@implementation MNShowPicCell

@end


@interface MNAssetsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong) NSMutableArray *assetModels;
@property(nonatomic,strong) NSMutableArray *selectModels;
@property(nonatomic,strong) NSMutableArray *selectImages;

//@property(nonatomic,strong) UIButton *currentBtn;

@property(nonatomic,assign) int currentIndex;

//@property(nonatomic,strong) UILabel *selectLabel;
@property(assign,nonatomic) int picNum;
@property(assign,nonatomic) int totalCount;

@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)UIButton *previewBtn;
@property(nonatomic,strong)UIButton *finishBtn;

@end

@implementation MNAssetsViewController

static NSString *const reuseIdentifier = @"Cell";

-(NSMutableArray *)assetModels
{
    if (!_assetModels) {
        _assetModels = [[NSMutableArray alloc]init];
    }
    return _assetModels;
}

-(NSMutableArray *)selectModels
{
    if (!_selectModels) {
        _selectModels = [[NSMutableArray alloc]init];
    }
    return  _selectModels;
}

-(NSMutableArray *)selectImages
{
    if (!_selectImages) {
        _selectImages = [[NSMutableArray alloc]init];
    }
    return _selectImages;
}

-(void)setGroup:(ALAssetsGroup *)group
{
    _group = group;
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result == nil) {
            return ;
        }
        if (![[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            return;
        }
        
        MNAssetModel *model = [[MNAssetModel alloc]init];
        model.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
        model.imageURL = result.defaultRepresentation.url;
        [self.assetModels addObject:model];
        
    }];
    
}



-(void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = MARGIN;
    flowLayout.minimumInteritemSpacing = MARGIN;
    CGFloat cellWidth = (KWidth - (COL + 1) * MARGIN) / COL;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_collectionView];
    
    CGRect frame = _collectionView.frame;
    frame.size.height = frame.size.height - 44;
    _collectionView.frame = frame;
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    _bottomView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    [self.view addSubview:_bottomView];
    
    _finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 128, 5, 120, 35)];
    [_finishBtn setTitle:NSLocalizedString(@"mcs_finish", nil) forState:UIControlStateNormal];
    [_finishBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    _finishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _finishBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _finishBtn.userInteractionEnabled = NO;
    [_finishBtn setTitleColor:[UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:0.5] forState:UIControlStateNormal];
    [_finishBtn addTarget:self action:@selector(finishSelect) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_finishBtn];
    
    _previewBtn = [[UIButton alloc]initWithFrame:CGRectMake(8, 5, 120, 35)];
    [_previewBtn setTitle:NSLocalizedString(@"mcs_preview_pic", nil) forState:UIControlStateNormal];
    [_previewBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    _previewBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _previewBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    _previewBtn.userInteractionEnabled = NO;
    _previewBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_previewBtn setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] forState:UIControlStateNormal];
    [_previewBtn addTarget:self action:@selector(showPic) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_previewBtn];
    
//    _picNum = 0;
//    _totalCount = (int)self.maxCount;
//    _selectLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
//    _selectLabel.textColor = [UIColor colorWithRed:177.0/225.0 green:177.0/225.0 blue:177.0/225.0 alpha:1];
//    _selectLabel.backgroundColor = [UIColor colorWithRed:250.0/225.0 green:250.0/225.0 blue:250.0/225.0 alpha:1];
//    _selectLabel.textAlignment = NSTextAlignmentCenter;
//    _selectLabel.font = [UIFont systemFontOfSize:20];
//    _selectLabel.text = [NSString stringWithFormat:@"%d/%d",_picNum,_totalCount];
//    [self.view addSubview:_selectLabel];
//    
}
-(void)showPic
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIImageView *imgv = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imgv.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.9];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeFromView:)];
    [imgv addGestureRecognizer:tap];
    imgv.userInteractionEnabled = YES;
    imgv.contentMode = UIViewContentModeScaleAspectFit;
    MNAssetModel *model = self.assetModels[_currentIndex - 1000];
    [model originalImage:^(UIImage *image) {
        imgv.image = image;
    }];
    [window addSubview:imgv];
    
}
-(void)removeFromView:(UITapGestureRecognizer *)tap
{
    UIView *view = tap.view;
    [view removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    _currentIndex = -1;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"item_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backToPhotoGroup)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"mcs_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    [_collectionView registerClass:[MNShowPicCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
}
-(void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)backToPhotoGroup
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)finishSelect
{
    
    if ([self.navigationController isKindOfClass:[MNImagePickerController class]]) {
        MNImagePickerController *imgPicker = (MNImagePickerController *)self.navigationController;
        if (imgPicker.didFinishSelectImages || imgPicker.didFinishSelectThumbnails) {
            
            for (MNAssetModel *model in self.assetModels) {
                if (model.isSelected == YES) {
                    [self.selectModels addObject:model];
                }
            }
            
            for (int i = 0; i < self.selectModels.count; i++) {
                MNAssetModel *model = self.selectModels[i];
                [model originalImage:^(UIImage *image) {
                    [self.selectImages addObject:image];
                    if (i == self.selectModels.count - 1) {
                        if ([imgPicker didFinishSelectImages]) {
                            imgPicker.didFinishSelectImages(self.selectImages);
                        }
                    }
                }];
            }
            if (imgPicker.didFinishSelectThumbnails) {
                imgPicker.didFinishSelectThumbnails([self.selectModels valueForKeyPath:@"thumbnail"]);
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    

}
#pragma mark -collectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assetModels.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNShowPicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    MNAssetModel *model = self.assetModels[indexPath.item];

    if (cell.backgroundView == nil) {
        UIImageView *backgroundImgV = [[UIImageView alloc]init];
        cell.backgroundView = backgroundImgV;
    }
    UIImageView *backimgV = (UIImageView *)cell.backgroundView;
    backimgV.image = model.thumbnail;
    
    if(cell.selectButton == nil){
    
        UIButton *selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(cell.bounds.size.width - 21, 1, 20, 20)];
        [selectBtn setBackgroundImage:[UIImage imageNamed:@"vt_unchekPic"] forState:UIControlStateNormal];
        [selectBtn setBackgroundImage:[UIImage imageNamed:@"vt_checkPic"] forState:UIControlStateSelected];
        [selectBtn addTarget:self action:@selector(changeSelectStatus:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:selectBtn];
        cell.selectButton = selectBtn;
  
    }
    cell.selectButton.tag = indexPath.item + 1000;
    cell.selectButton.selected = model.isSelected;
    
    return cell;
}


-(void)changeSelectStatus:(UIButton *)btn
{
    if (_currentIndex != btn.tag) {
        if (_currentIndex != -1) {
            NSInteger index1 = _currentIndex - 1000;
            MNAssetModel *model1 = self.assetModels[index1];
            model1.isSelected = NO;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index1 inSection:0];
            MNShowPicCell *showCell = (MNShowPicCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            showCell.selectButton.selected = NO;
            
            NSInteger index2 = btn.tag - 1000;
            MNAssetModel *model2 = self.assetModels[index2];
            model2.isSelected = YES;
            btn.selected = YES;
            
            _currentIndex = btn.tag;
            // _selectLabel.text = [NSString stringWithFormat:@"%d/%d",1,_totalCount];
        }
        else{
            btn.selected = YES;
            MNAssetModel *model = self.assetModels[btn.tag - 1000];
            model.isSelected = YES;
            
            _currentIndex = btn.tag;
           //  _selectLabel.text = [NSString stringWithFormat:@"%d/%d",1,_totalCount];
        }
    }
    else{
        btn.selected = NO;
        MNAssetModel *model = self.assetModels[btn.tag - 1000];
        model.isSelected = NO;
        
        _currentIndex = -1;
        
       //  _selectLabel.text = [NSString stringWithFormat:@"%d/%d",0,_totalCount];
    }
    
    [_finishBtn setTitleColor:(_currentIndex == -1 ? [UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:0.5] : [UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:1]) forState:UIControlStateNormal];
    _finishBtn.userInteractionEnabled = !(_currentIndex == -1);
    
    [_previewBtn setTitleColor:(_currentIndex == -1 ? [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1]) forState:UIControlStateNormal];
    _previewBtn.userInteractionEnabled = !(_currentIndex == -1);
//    btn.selected = !btn.selected;
//   // btn.hidden = !btn.hidden;
//    MNAssetModel *model = self.assetModels[btn.tag];
//    if (btn.selected == YES) {
//        if (self.maxCount <= 0) {
//            btn.selected = NO;
//        }else{
//            model.isSelected = YES;
//            _picNum ++;
//            _selectLabel.text = [NSString stringWithFormat:@"%d/%d",_picNum,_totalCount];
//            self.maxCount--;
//        }
//    }else{
//        model.isSelected = NO;
//        _picNum --;
//        _selectLabel.text = [NSString stringWithFormat:@"%d/%d",_picNum,_totalCount];
//        self.maxCount++;
//    }
// 
    
}
#pragma mark -collectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNAssetModel *model = self.assetModels[indexPath.item];
    
    MNPhotosBrowser *browser = [[MNPhotosBrowser alloc]init];
    browser.isCurrentSelect = model.isSelected;
    browser.assetModels = self.assetModels;
    browser.currentIndex = indexPath.item;
    [browser setSelectResult:^(int index) {
        if (index >= 0) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForItem:index inSection:0];
            MNShowPicCell *showCell = (MNShowPicCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
            showCell.selectButton.selected = YES;
            MNAssetModel *model = self.assetModels[index];
            model.isSelected = YES;
            _currentIndex = 1000 + index;
//            self.maxCount --;
//            _picNum ++;
//            self.selectLabel.text = [NSString stringWithFormat:@"%d/%d",1,_totalCount];
            
            [_finishBtn setTitleColor:(_currentIndex == -1 ? [UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:0.5] : [UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:1]) forState:UIControlStateNormal];
            _finishBtn.userInteractionEnabled = !(_currentIndex == -1);
            
            [_previewBtn setTitleColor:(_currentIndex == -1 ? [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1]) forState:UIControlStateNormal];
            _previewBtn.userInteractionEnabled = !(_currentIndex == -1);
        }
    }];
    
    [self resetSelectModel];
    [self.navigationController pushViewController:browser animated:YES];
}

-(void)resetSelectModel
{
    
    if (_currentIndex != -1) {
        MNAssetModel *model = self.assetModels[_currentIndex - 1000];
        model.isSelected = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(_currentIndex - 1000) inSection:0];
        MNShowPicCell *showCell = (MNShowPicCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        showCell.selectButton.selected = NO;
        
        _currentIndex = -1;
        
//        _selectLabel.text = [NSString stringWithFormat:@"%d/%d",0,_totalCount];
        [_finishBtn setTitleColor:(_currentIndex == -1 ? [UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:0.5] : [UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:1]) forState:UIControlStateNormal];
        _finishBtn.userInteractionEnabled = !(_currentIndex == -1);
        
        [_previewBtn setTitleColor:(_currentIndex == -1 ? [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1]) forState:UIControlStateNormal];
        _previewBtn.userInteractionEnabled = !(_currentIndex == -1);
    }
//    _picNum = 0;
//    for (int i = 0;i < self.assetModels.count;i++) {
//        MNAssetModel *model = self.assetModels[i];
//        if (model.isSelected == YES) {
//            self.maxCount ++;
//            model.isSelected = NO;
//            NSIndexPath *indexpath = [NSIndexPath indexPathForItem:i inSection:0];
//            MNShowPicCell *showCell = (MNShowPicCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
//            showCell.selectButton.selected = NO;
//        }
//    }
//    _selectLabel.text = [NSString stringWithFormat:@"%d/%d",0,_totalCount];
}

@end
