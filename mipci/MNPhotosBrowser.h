//
//  MNPhotosBrowser.h
//  mipci
//
//  Created by mining on 16/9/5.
//
//

#import <UIKit/UIKit.h>


@interface MNPhotosBrowser : UIViewController

@property(nonatomic,assign) NSInteger currentIndex;
@property(nonatomic,strong) NSArray *assetModels;
@property(nonatomic,assign) BOOL isCurrentSelect;

@property(nonatomic,copy)void(^selectResult)(int index);


@end