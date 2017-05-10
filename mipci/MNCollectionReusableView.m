    //
//  MNCollectionReusableView.m
//  mipci
//
//  Created by mining on 16/4/21.
//
//

#import "MNCollectionReusableView.h"

@implementation MNCollectionReusableView


-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.gifData == nil) {
        NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"gif" ofType:nil];
        NSString *headGifPath;
        switch (self.type) {
            case 5:
                headGifPath = [NSString stringWithFormat:@"%@/sos_search.gif",gifPath];
                break;
            case 6:
                headGifPath = [NSString stringWithFormat:@"%@/magnetic_search.gif",gifPath];
                break;  
            default:
                break;
        }
        self.gifData = [NSData dataWithContentsOfFile:headGifPath];
        self.gifWebView.userInteractionEnabled = NO;
        self.gifWebView.scalesPageToFit = YES;
        self.gifWebView.backgroundColor = [UIColor clearColor];
        self.gifWebView.opaque = 0;
        [self.gifWebView loadData:self.gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    }
    
    if (self.searchGifData == nil) {
        NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"gif" ofType:nil];
        NSString *Searchpath = [NSString stringWithFormat:@"%@/search.gif",gifPath];
        self.searchGifData = [NSData dataWithContentsOfFile:Searchpath];
        self.searchGifWebView.userInteractionEnabled = NO;
        self.searchGifWebView.scalesPageToFit = YES;
        self.searchGifWebView.backgroundColor = [UIColor clearColor];
        self.searchGifWebView.opaque = 0;
        [self.searchGifWebView loadData:self.searchGifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    }
}

-(void)reviseSearchUI
{
    self.staticShowView.hidden = YES;
    self.searchImageView.hidden = YES;
    self.searchGifWebView.hidden = NO;
    self.searchLabel.text = NSLocalizedString(@"mcs_stop_search", nil);
    if (self.type == 5) {
        self.staticShowImage.image = [UIImage imageNamed:@"sos_static.png"];
    }
    
    NSString *startString;
    NSString *endString;
    
    switch (self.type) {
        case 5:
            startString = NSLocalizedString(@"mcs_search_sos_strat", nil);
            endString = NSLocalizedString(@"mcs_search_sos_end", nil);
            self.staticShowImage.image = [UIImage imageNamed:@"sos_static.png"];
            break;
        case 6:
            startString = NSLocalizedString(@"mcs_search_magnetic_start", nil);
            endString = NSLocalizedString(@"mcs_search_magnetic_end", nil);
            self.staticShowImage.image = [UIImage imageNamed:@"magnetic_door_static.png"];
            break;
        default:
            break;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",startString]];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"vt_button_prompt_image.png"];
    NSAttributedString *imgString = [NSAttributedString attributedStringWithAttachment:attachment];
    [attributedString appendAttributedString:imgString];
    NSMutableAttributedString *endAttributedStringString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",endString]];
    [attributedString appendAttributedString:endAttributedStringString];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:51./255. green:51./255. blue:51./255. alpha:1.0] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, attributedString.length)];
    self.detailLabel.attributedText = attributedString;
}

-(void)reviseUnsearchUI
{
    self.staticShowView.hidden = NO;
    self.searchImageView.hidden = NO;
    self.searchGifWebView.hidden = YES;
    self.searchLabel.text = NSLocalizedString(@"mcs_search", nil);
    self.detailLabel.attributedText = nil;
    if (self.staticShowImage.image == nil) {
        switch (self.type) {
                case 5:
                self.staticShowImage.image = [UIImage imageNamed:@"sos_static.png"];
                break;
                case 6:
                self.staticShowImage.image = [UIImage imageNamed:@"magnetic_door_static.png"];
                break;
            default:
                self.staticShowImage.image = [UIImage imageNamed:@"sos_static.png"];
                break;
        }
    }
}

@end
