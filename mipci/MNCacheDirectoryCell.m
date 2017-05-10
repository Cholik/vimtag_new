//
//  MNCacheDirectoryCell.m
//  mipci
//
//  Created by mining on 16/3/2.
//
//

#import "MNCacheDirectoryCell.h"

@implementation MNCacheDirectoryCell

#pragma mark - prepareForReuse
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    _isBox = 0;
    _titleLabel.text = nil;
    _detailLabel.text = nil;
    _backgroundImage.image = nil;
}

#pragma mark - Action
- (IBAction)select:(id)sender
{
    
}

@end
