//
//  MNShareVideoWindow.h
//  mipci
//
//  Created by mining on 16/1/27.
//
//

#import <UIKit/UIKit.h>

typedef void (^CloseBlock)();

@interface MNShareVideoWindow : UIWindow

@property (nonatomic, copy) CloseBlock closeBlock;
- (void)closeWindowWithBlock:(CloseBlock)block;

@end
