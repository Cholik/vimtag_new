//
//  UITableViewController+loading.m
//  mipci
//
//  Created by mining on 13-10-28.
//
//

#import "UITableViewController+loading.h"



@implementation UITableViewController (loading)

- (UIView *)createLoadingView
{
//    CGRect bounds = self.tableView.bounds;
//    UIView *loadingView = [[UIView alloc] initWithFrame:bounds];
    UIView *loadingView = [[UIView alloc] init];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
    loadingView.tag = 1123002;
    loadingView.isAccessibilityElement = YES;
    loadingView.accessibilityLabel = @"TableViewLoading";
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity startAnimating];
    [activity sizeToFit];
    activity.center = CGPointMake(loadingView.center.x, loadingView.frame.size.height/3);
    activity.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
    
    [loadingView addSubview:activity];
    [self.tableView addSubview:loadingView];
    [self.tableView bringSubviewToFront:loadingView];
    
    return loadingView;
}


- (void)loading:(BOOL)visible
{
    UIView *loadingView = [self.tableView viewWithTag:1123002];
    if (loadingView==nil){
        loadingView = [self createLoadingView];
    }
    
    loadingView.frame = CGRectMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
    self.tableView.userInteractionEnabled = !visible;
    
    if (visible)
    {
        loadingView.hidden = NO;
    }
    
    loadingView.alpha = visible ? 0 : 1;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         loadingView.alpha = visible ? 1 : 0;
                     }
                     completion: ^(BOOL  finished) {
                         if (!visible) {
                             loadingView.hidden = YES;
                         }
                     }];
}

@end
