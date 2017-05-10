//
//  MNGroupCell.h
//  MNImagePickerController
//
//  Created by yyx on 15/9/20.
//  Copyright (c) 2015年 yyx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface MNGroupCell : UITableViewCell
@property (nonatomic,strong) ALAssetsGroup *group;
+ (instancetype)groupCell:(UITableView *)tableView;
@end
