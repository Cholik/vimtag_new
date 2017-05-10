//
//  MNPhotosBrowser.m
//  mipci
//
//  Created by mining on 16/9/5.
//
//

#import "MNPhotosBrowser.h"
#import "MNAssetModel.h"
#import "MNImagePickerController.h"

#define MN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define MN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define MARGIN 10;


static NSString *reuseIdetifier = @"cell";

@interface MNPhotosBrowser ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(strong,nonatomic)NSMutableArray *selectModels;
@property(strong,nonatomic)NSMutableArray *selectImages;

@property(strong,nonatomic)UICollectionView *collectionView;

@property(strong,nonatomic)UIView *topView;
@property(strong,nonatomic)UIView *bottomView;
@property(strong,nonatomic)UIButton *finishBtn;
@property(strong,nonatomic)UIButton *selectBtn ;

@property(strong,nonatomic)UILabel *topLabel;

@end

@implementation MNPhotosBrowser


-(void)initUI
{
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(MN_WIDTH, MN_HEIGHT);
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:flowLayout];
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdetifier];
    
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, MN_WIDTH, 44)];
    _topView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:0.6];
    [self.view insertSubview:_topView aboveSubview:self.collectionView];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backBtn setImage:[UIImage imageNamed:@"item_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPhotos) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:backBtn];
    
    _selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(MN_WIDTH - 35, 10, 25, 25)];
    [_selectBtn setImage:[UIImage imageNamed: @"vt_unchekPic"] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed: @"vt_checkPic"] forState:UIControlStateSelected];
    [_selectBtn addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    _selectBtn.selected = self.isCurrentSelect;
    [_topView addSubview:_selectBtn];
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, MN_HEIGHT - 44, MN_WIDTH, 44)];
    _bottomView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:0.6];
    [self.view addSubview:_bottomView];
    
    _finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(MN_WIDTH - 50, 10, 50, 25)];
    [_finishBtn setTitle:NSLocalizedString(@"mcs_finish", nil) forState:UIControlStateNormal];
    [_finishBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    _finishBtn.userInteractionEnabled = self.isCurrentSelect;
    if (_finishBtn.userInteractionEnabled == NO) {
        [_finishBtn setTitleColor:[UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:0.5] forState:UIControlStateNormal];

    }
    else{
        [_finishBtn setTitleColor:[UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:1] forState:UIControlStateNormal];
    }
    [_finishBtn addTarget:self action:@selector(finishedSelectedPic:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_finishBtn];
    
}

-(void)backToPhotos
{
    if (_selectBtn.isSelected == YES) {
        if (self.selectResult) {
            _selectResult((int)self.currentIndex);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)selectPhoto:(UIButton *)button
{
    button.selected = !button.selected;
    _finishBtn.userInteractionEnabled = button.selected;
    [_finishBtn setTitleColor:(button.selected ? [UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:1] : [UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:0.5]) forState:UIControlStateNormal];
    
}
-(void)finishedSelectedPic:(UIButton *)button
{
    
    MNAssetModel *model = _assetModels[_currentIndex];
    if (_selectModels == nil) {
        _selectModels = [[NSMutableArray alloc]init];
    }
    [_selectModels addObject:model];
    if (_selectImages == nil) {
        _selectImages = [[NSMutableArray alloc]init];
    }
    
    if ([self.navigationController isKindOfClass:[MNImagePickerController class]]) {
        MNImagePickerController *imgPicker = (MNImagePickerController *)self.navigationController;
        if (imgPicker.didFinishSelectImages || imgPicker.didFinishSelectThumbnails) {
            for (MNAssetModel *selectmodel in _selectModels) {
                [selectmodel originalImage:^(UIImage *image) {
                    [self.selectImages addObject:image];
                    if (imgPicker.didFinishSelectImages) {
                        imgPicker.didFinishSelectImages(self.selectImages);
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
  
}

#pragma mark -collection Delegate  & DataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetModels.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdetifier forIndexPath:indexPath];
    
    if (cell.backgroundView == nil) {
        UIImageView *imgv = [[UIImageView alloc]init];
        cell.backgroundView = imgv;
    }
    UIImageView *backView = (UIImageView *)cell.backgroundView;
    backView.contentMode = UIViewContentModeScaleAspectFit;
    backView.userInteractionEnabled = YES;
    
    MNAssetModel *model = self.assetModels[indexPath.item];
    [model originalImage:^(UIImage *image) {
        backView.image = image;
    }];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _topView.hidden = !_topView.hidden;
    _bottomView.hidden = !_bottomView.hidden;
}

-(void)hideOrDisplayView:(UITapGestureRecognizer *)tap
{
    _topView.hidden = !_topView.hidden;
    _bottomView.hidden = !_bottomView.hidden;
}

#pragma mark -scrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = (scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5)/MN_WIDTH;
    if (index < 0) {
        return;
    }
    if(_currentIndex != index){
        [self resetfinishAndSelectBtn];
    }
    _currentIndex = index;

}

-(void)resetfinishAndSelectBtn
{
    _selectBtn.selected = NO;
    _finishBtn.userInteractionEnabled = NO;
    [_finishBtn setTitleColor:(_finishBtn.userInteractionEnabled ? [UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:1] : [UIColor colorWithRed:37.0/255.0 green:180.0/255.0 blue:197.0/255.0 alpha:0.5]) forState:UIControlStateNormal];

}

@end
