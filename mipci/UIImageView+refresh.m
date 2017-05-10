//
//  UIImageView+refresh.m
//  mipci
//
//  Created by mining on 16/5/27.
//
//

#import "UIImageView+refresh.h"

@implementation UIImageView (refresh)

-(void)initRefreshWithLabel:(UILabel *)downRefreshLabel and:(UICollectionView *)collectionView
{
    CGRect downRefreshLabelFrame = downRefreshLabel.frame;
    downRefreshLabelFrame = CGRectMake(0, -35, 300, 40);
    downRefreshLabel.frame = downRefreshLabelFrame;
    
    CGPoint downRefreshLabelCenter = downRefreshLabel.center;
    downRefreshLabelCenter.x = collectionView.center.x;
    downRefreshLabel.center = downRefreshLabelCenter;
    
    downRefreshLabel.font = [UIFont systemFontOfSize:16];
    downRefreshLabel.textAlignment = NSTextAlignmentCenter;
    downRefreshLabel.textColor = [UIColor blackColor];
    downRefreshLabel.hidden = YES;
    NSString *downRefreshLabelText = NSLocalizedString(@"mcs_refreshing", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle.copy};
        labelSize = [downRefreshLabelText boundingRectWithSize:CGSizeMake(0, 0)
                                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:attributes
                                                       context:nil].size;
        labelSize.width = ceil(labelSize.width);
    }
    [self setImageViewFrame:collectionView with:labelSize];
}

-(void)layoutRefreshWithLabel:(UILabel *)downRefreshLabel and:(UICollectionView *)collectionView
{
    CGPoint downRefreshLabelCenter = downRefreshLabel.center;
    downRefreshLabelCenter.x = collectionView.center.x;
    downRefreshLabel.center = downRefreshLabelCenter;
    [collectionView addSubview:downRefreshLabel];
    
    //get _downRefreshLabel.text width
    NSString *downRefreshLabelText = NSLocalizedString(@"mcs_refreshing", nil);
    CGSize labelSize = CGSizeMake(100, 20);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.0)
    {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        labelSize = [downRefreshLabelText boundingRectWithSize:CGSizeMake(0, 0)
                                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                                                    attributes:attributes
                                                       context:nil].size;
        
        labelSize.width = ceil(labelSize.width);
    }
    [self layoutFrame:collectionView with:labelSize];
}

-(void)setImageViewFrame:(UIView *)view with:(CGSize)labelSize
{
    CGRect frame = self.frame;
    frame.origin.y =  -25;
    self.frame = frame;
    CGPoint center =self.center;
    center.x = view.center.x - labelSize.width / 2.0 - 15;
    self.center = center;
    self.hidden = YES;
}

-(void)layoutFrame:(UIView *)view with:(CGSize)labelSize
{
    CGPoint center =self.center;
    center.x = view.center.x - labelSize.width / 2.0 - 15;
    self.center = center;
    [view addSubview:self];
}

-(void)start
{
    CGAffineTransform transform = CGAffineTransformRotate(self.transform, M_PI / 6.0);
    self.transform = transform;
}
@end
