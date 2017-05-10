//
//  MNEbitInputView.m
//  mipci
//
//  Created by 谢跃聪 on 16/12/2.
//
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "MNEbitInputView.h"

@interface MNEbitInputView ()

@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton    *passwordButton;
@property (strong, nonatomic) UIButton    *checkButton;
@property (strong, nonatomic) UIView      *lineView;

@end

@implementation MNEbitInputView

#pragma mark - Setter && Getter
- (NSString *)text
{
    return _textField.text;
}

- (void)setText:(NSString *)text
{
    _textField.text =  text;
}

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame
                        style:(MNEbitInputViewStyle)style
                    idleImage:(UIImage *)idleImage
                  activeImage:(UIImage *)activeImage
                  placeholder:(NSString *)placeholder
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initUIWithStyle:style
                    idleImage:idleImage
                  activeImage:activeImage
                  placeholder:placeholder];
    }
    
    return self;
}

- (void)initUIWithStyle:(MNEbitInputViewStyle)style
              idleImage:(UIImage *)idleImage
            activeImage:(UIImage *)activeImage
            placeholder:(NSString *)placeholder
{
    self.backgroundColor = [UIColor clearColor];
    
    _iconImageView = [[UIImageView alloc] initWithImage:idleImage highlightedImage:activeImage];
    _iconImageView.frame = CGRectMake(0, 12, 16, 16);
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37, 280, 1)];
    _lineView.backgroundColor = UIColorFromRGB(0xa1a6b3);

    _textField = [[UITextField alloc] initWithFrame:CGRectMake(26, 5, 254, 30)];
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.returnKeyType = UIAccessibilityTraitNone;
    _textField.font = [UIFont systemFontOfSize:15.0];
    _textField.placeholder = placeholder;
    _textField.keyboardType = UIKeyboardTypeASCIICapable;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.backgroundColor = [UIColor clearColor];
    [_textField addTarget:self action:@selector(editingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [_textField addTarget:self action:@selector(editingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [_textField addTarget:self action:@selector(eidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];

    if (style == MNEbitInputViewNormal)
    {

    }
    else if (style == MNEbitInputViewCheck)
    {
        
    }
    else if (style == MNEbitInputViewPassword)
    {
        _textField.frame = CGRectMake(26, 5, 214, 30);
        
        _passwordButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _passwordButton.frame = CGRectMake(240, -2, 44, 44);
        [_passwordButton setImage:[UIImage imageNamed:@"eb_eye_gray.png"] forState:UIControlStateNormal];
        [_passwordButton setImage:[UIImage imageNamed:@"eb_eye.png"] forState:UIControlStateSelected];
        [_passwordButton addTarget:self action:@selector(showPassword) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Action
- (void)editingDidBegin:(id)sender
{
    _iconImageView.highlighted = YES;
    _textField.backgroundColor = UIColorFromRGB(0x2e87e6);
    _textField.textColor = UIColorFromRGB(0x2e87e6);
    [_textField setValue:UIColorFromRGB(0x2e87e6) forKeyPath:@"_placeholderLabel.textColor"];
    _lineView.backgroundColor = UIColorFromRGB(0x2e87e6);
}

- (void)editingDidEnd:(id)sender
{
    _iconImageView.highlighted = NO;
    _textField.backgroundColor = UIColorFromRGB(0xa1a6b3);
    _textField.textColor = UIColorFromRGB(0xa1a6b3);
    [_textField setValue:UIColorFromRGB(0xa1a6b3) forKeyPath:@"_placeholderLabel.textColor"];
    _lineView.backgroundColor = UIColorFromRGB(0xa1a6b3);
}

- (void)eidEndOnExit:(id)sender
{
    [sender resignFirstResponder];
    
    return;
}

- (void)showPassword
{
    _passwordButton.selected = !_passwordButton.selected;
    _textField.secureTextEntry = !_passwordButton.selected;
}

@end
