//
//  MNCacheVideoCell.m
//  mipci
//
//  Created by mining on 16/2/29.
//
//

#import "MNCacheVideoCell.h"

@implementation MNCacheVideoCell

#pragma mark - prepareForReuse
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    _backgroundImage.image = nil;
    _idLabel.text = nil;
    _sizeLabel.text = nil;
    _durationLabel.text = nil;
    _dateLabel.text = nil;
    _selectImage.image = nil;
}

@end
