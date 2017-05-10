//
//  MNAccessoryListCell.m
//  mipci
//
//  Created by PC-lizebin on 16/8/12.
//
//

#import "MNAccessoryListCell.h"
#import "mipc_agent.h"

@interface MNAccessoryListCell ()

@end

@implementation MNAccessoryListCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    _sceneLabel.text = NSLocalizedString(@"mcs_scenes", nil);
    _activeLabel.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"mcs_at_home", nil)];
    _awayLabel.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"mcs_away_home", nil)];
}

-(void)setDic:(NSDictionary *)dic
{
    _dic = dic;
    if (_dic.count) {
        _accessoryView.hidden = NO;
        _addView.hidden = YES;
        sceneExdev_obj *active = [_dic valueForKey:@"in"];
        sceneExdev_obj *awayDev = [_dic valueForKey:@"out"];
        if ([active.exdev_id isEqualToString:@"motion"]) {
            _imageView.image = [UIImage imageNamed:@"vt_move"];
            _typeLabel.text = NSLocalizedString(@"mcs_motion", nil);
        }else {
            if (active.nick.length ) {
                _nickLabel.text = active.nick;
            }else {
                _nickLabel.text = active.exdev_id;
            }
            switch (active.exdev_type) {
                case 5:
                    _imageView.image = [UIImage imageNamed:@"vt_sos"];
                    _typeLabel.text = NSLocalizedString(@"mcs_sos", nil);
                    break;
                case 6:
                    _imageView.image = [UIImage imageNamed:@"vt_door-lock"];
                    _typeLabel.text = NSLocalizedString(@"mcs_magnetic", nil);
                    break;
                default:
                    _imageView.image = nil;
                    _typeLabel.text = nil;
                    break;
            }
        }
        if (active.nick.length) {
            _nickLabel.text = active.nick;
        }else {
            _nickLabel.text = active.exdev_id;
        }
        [self showEventImageVew:@[_activeFirstImage,_activeSecondImage,_activeThirdImage] with:active];
        [self showEventImageVew:@[_awayFirstImage,_awaySecondImage,_awayThirdImage] with:awayDev];
    } else {
        _accessoryView.hidden = YES;
        _addView.hidden = NO;
        _imageView.image = [UIImage imageNamed:@"vt_add-attachment"];
        _addLabel.text = NSLocalizedString(@"mcs_add_accessory", nil);
    }
}

-(void)showEventImageVew:(NSArray *)imageArray with:(sceneExdev_obj *)dev
{
    for (UIImageView *imageview in imageArray) {
        imageview.image = nil;
    }
    BOOL isVideo= dev.flag & 1;
    BOOL isPhoto = dev.flag & 2;
    BOOL isAlert = dev.flag & 4;
    
    BOOL array[]={isAlert,isVideo,isPhoto};
    int lenth =  sizeof(array) / sizeof(BOOL);
    int m = 0;
    for (int i = 0; i < lenth; i ++) {
        BOOL event = array[i];
        if (event) {
            m++;
            UIImageView *imageView = [self judgeImageView:imageArray with:m];
            [self judgeImageView:imageView withInt:i];
        }
    }
}

-(UIImageView *)judgeImageView:(NSArray *)array with:(int)sequence
{

    UIImageView *imageView;
    switch (sequence) {
        case 1:
            imageView = array[0];
            break;
        case 2:
            imageView = array[1];
            break;
        case 3:
            imageView = array[2];
            break;
        default:
            break;
    }
    return imageView;
}

-(void)judgeImageView:(UIImageView *)imageView withInt:(int)flag
{
    NSString *imageName ;
    switch (flag) {
        case 0:
            imageName = @"vt_list_alert";
            break;
        case 1:
            imageName = @"vt_list_videotape";
            break;
        case 2:
            imageName = @"vt_list_photograph";
            break;
        default:
            break;
    }
    imageView.image = [UIImage imageNamed:imageName];
}

@end
