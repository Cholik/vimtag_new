//
//  MNImagesPickerController.h
//  MNImagePickerController
//
//  Created by yyx on 15/9/17.
//  Copyright (c) 2015年 yyx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNImagePickerController : UINavigationController


@property (nonatomic,copy) void(^didFinishSelectImages)(NSArray *images);


@property (nonatomic,copy) void(^didFinishSelectThumbnails)(NSArray *thumbnails);


@property (nonatomic,assign) NSInteger maxCount;
@end
