//
//  MNImagesPickerController.m
//  MNImagePickerController
//
//  Created by yyx on 15/9/17.
//  Copyright (c) 2015年 yyx. All rights reserved.
//

#import "MNImagePickerController.h"
#import "MNAssetsGroupController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MNImagePickerController ()
@property (nonatomic,strong) MNAssetsGroupController *assetsGroupVC;
@end

@implementation MNImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (instancetype)init{

    if (self = [super initWithRootViewController:self.assetsGroupVC]) {
        self.maxCount = LONG_MAX;
 
    }
    return self;
}
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    return  [self init];
}
- (MNAssetsGroupController *)assetsGroupVC{
    if (_assetsGroupVC == nil) {
    _assetsGroupVC = [[MNAssetsGroupController alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"mcs_select_photo", nil);
    [titleLabel sizeToFit];
    _assetsGroupVC.navigationItem.titleView = titleLabel;
    
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"mcs_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    _assetsGroupVC.navigationItem.rightBarButtonItem = cancelItem;
    }
    return _assetsGroupVC;
}
- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setMaxCount:(NSInteger)maxCount{
    _maxCount = maxCount;
    if (maxCount > 0) {
        self.assetsGroupVC.maxCount = maxCount;
    }
}
@end
