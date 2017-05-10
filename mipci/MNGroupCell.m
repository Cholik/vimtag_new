//
//  MNGroupCell.m
//  MNImagePickerController
//
//  Created by yyx on 15/9/20.
//  Copyright (c) 2015年 yyx. All rights reserved.
//

#import "MNGroupCell.h"
#define MARGIN 10

@implementation MNGroupCell

+ (instancetype)groupCell:(UITableView *)tableView{
    NSString *reusedId = @"groupCell";
    MNGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedId];
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedId];
    }
    return cell;
}
- (void)setGroup:(ALAssetsGroup *)group{
    
    NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
    if ([groupName isEqualToString:@"Camera Roll"]) {
        groupName = NSLocalizedString(@"mcs_camera_cell", nil);
    } else if ([groupName isEqualToString:@"My Photo Stream"]) {
        groupName = NSLocalizedString(@"mcs_myphoto", nil);
    }
    
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger groupCount = [group numberOfAssets];
    self.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)",groupName, (long)groupCount];
    UIImage *image =[UIImage imageWithCGImage:group.posterImage] ;
    [self.imageView setImage:image];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellHeight = self.frame.size.height - 2 *MARGIN;
    self.imageView.frame = CGRectMake(MARGIN, MARGIN, cellHeight, cellHeight);
}

@end
