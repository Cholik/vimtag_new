//
//  MNSceneButtonBackView.h
//  mipci
//
//  Created by mining on 16/6/22.
//
//

#import <UIKit/UIKit.h>

@interface MNSceneButtonBackView : UIView

@property (nonatomic,strong) NSTimer *timer;

-(void)startLoading;
-(void)stopLoading;

@end
