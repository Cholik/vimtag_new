//
//  MNAssetsGroupController.m
//  MNImagePickerController
//
//  Created by yyx on 15/9/20.
//  Copyright (c) 2015年 yyx. All rights reserved.
//

#import "MNAssetsGroupController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MNGroupCell.h"
#import "MNAssetsViewController.h"

#define CANCEL_TAG                  1001

@interface MNAssetsGroupController () <UIAlertViewDelegate>

@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic,strong) NSMutableArray *groups;

@end

@implementation MNAssetsGroupController
- (ALAssetsLibrary *)assetsLibrary{
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}
- (NSMutableArray *)groups{
    if (_groups == nil) {
        _groups = [NSMutableArray array];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if(group){
                    [_groups addObject:group];
                    [self.tableView reloadData];
                }
            } failureBlock:^(NSError *error) {
                NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                NSString *appName = [infoDict objectForKey:@"CFBundleDisplayName"];
                NSString *title = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"mcs_please_allow", nil), appName, NSLocalizedString(@"mcs_access_album", nil)];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:[NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"mcs_ios_privacy_setting_for_photo_prompt", nil),appName, NSLocalizedString(@"mcs_execute_change", nil)]
                                                               delegate:self cancelButtonTitle:NSLocalizedString(@"mcs_i_know", nil)
                                                      otherButtonTitles: nil];
                alert.tag = CANCEL_TAG;
                [alert show];
            }];
        });
    }
    return _groups;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    backItem.title = @"";
//    self.navigationItem.backBarButtonItem = backItem;
}


#pragma mark - -----------------delegate-----------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNGroupCell *cell = [MNGroupCell groupCell:tableView];
    ALAssetsGroup *group = [self.groups objectAtIndex:indexPath.row];
    cell.group = group;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 108;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    MNCollectionController *collectionVC = [[MNCollectionController alloc] init];
//    collectionVC.maxCount = self.maxCount;
//    collectionVC.group = self.groups[indexPath.row];
//    [self.navigationController pushViewController:collectionVC animated:YES];
    
    MNAssetsViewController *assetVC = [[MNAssetsViewController alloc]init];
    assetVC.maxCount = self.maxCount;
    assetVC.group = self.groups[indexPath.row];
    [self.navigationController pushViewController:assetVC animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
