//
//  MNCustomTextView.m
//  mipci
//
//  Created by mining on 16/6/1.
//
//

#import "MNCustomTextView.h"

@implementation MNCustomTextView

-(instancetype)initWithFrame:(CGRect)frame
{
    self= [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addObserver];
}

-(void)addObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)textViewDidBeginEditing:(NSNotification *)notfication
{
    if ([super.text isEqualToString:_placeHolder]) {
        super.text = @"";
        super.textColor = [UIColor blackColor];
    }
}

-(void)textViewEndEditing:(NSNotification *)notification
{
    if ([super.text isEqualToString:@""]) {
        super.text = _placeHolder;
        super.textColor = [UIColor lightGrayColor];
    }
}
-(void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    [self textViewEndEditing: nil];
}

-(NSString *)text
{
    if ([[super text] isEqualToString:_placeHolder]) {
        return @"";
    }
    return [super text];
}


@end
