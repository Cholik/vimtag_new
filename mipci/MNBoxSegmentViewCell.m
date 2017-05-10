//
//  MNBoxSegmentViewCell.m
//  mipci
//
//  Created by mining on 15/10/13.
//
//

#import "MNBoxSegmentViewCell.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "UIImageView+MNNetworking.h"
#import "MNCache.h"
#import "MIPCUtils.h"

@interface MNBoxSegmentViewCell ()

@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;

//@property (assign, nonatomic) BOOL is_stopImage;

@end

@implementation MNBoxSegmentViewCell

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return  _app;
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

#pragma mark - prepareForReuse
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    _deviceID = nil;
    _boxID = nil;
    _cluster_id = 0;
    _seg_id = 0;
    _start_time = 0;
    _end_time = 0;
    
//    _is_stopImage = NO;
    
    _markImageView.image = nil;
    _timeLabel.text = nil;
    _durationLabel.text = nil;
    _eventImageView.image = nil;
    //    _warnlabel.text = nil;
    _firstImageView.image = nil;
    _secondImageView.image = nil;
    _thirdImageView.image = nil;
    _fourthImageView.image = nil;
    _fifthImageView.image = nil;
    [_contentImageView cancelImageRequestOperation];
}

-(void)loadWebImage
{
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//        NSString *path = [weakSelf localBoxSegmentPathByID:weakSelf.deviceID withBoxSegmentToken:weakSelf.token];
        NSString *imagePath = [weakSelf localBoxSegmentPathByID:_deviceID withBoxSegmentToken:_token];
        UIImage *image = [[[MNCache class] mn_sharedCache] objectForKey:imagePath];
        if (!image) {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image)
            {
                strongSelf.contentImageView.image = image;
            }
            else
            {
                mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
                ctx.sn = weakSelf.boxID;
                //                ctx.target = weakSelf;
                //                ctx.on_event = @selector(pic_get_done:);
                ctx.type = mdev_pic_seg_album;
                ctx.token = weakSelf.token;
                ctx.flag = 1;
                
                UIImage *placeholderImage;
                if (weakSelf.app.is_luxcam)
                {
                    placeholderImage = [UIImage imageNamed:@"placeholder.png"];
                }
                else if (self.app.is_vimtag)
                {
                    placeholderImage = [UIImage imageNamed:@"vt_cellBg.png"];
                }
                else if (self.app.is_ebitcam)
                {
                    placeholderImage = [UIImage imageNamed:@"eb_cellBg.png"];
                }
                else if (self.app.is_mipc)
                {
                    placeholderImage = [UIImage imageNamed:@"mi_cellBg.png"];
                }
                else
                {
                    placeholderImage = [UIImage imageNamed:@"camera_placeholder.png"];
                }
                
                NSURL *downloadImageURL = [NSURL URLWithString:[weakSelf.agent pic_url_create:ctx]];
                
            [weakSelf.contentImageView setImageWithURLRequest:[NSURLRequest requestWithURL:downloadImageURL]            placeholderImage:placeholderImage token:_token deviceID:_deviceID flag:1                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image, NSString *deviceID, NSString *token) {
                
                    //Fixed image cache in confusion
//                    if (strongSelf.is_stopImage) {
//                        return ;
//                    }
                
                    if (token == strongSelf.token && image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            strongSelf.contentImageView.image = image;
                            [strongSelf.contentImageView setAlpha:0.5];
                            [UIView animateWithDuration:0.3 animations:^{
                                [strongSelf.contentImageView setAlpha:1.0];
                            }];
                        });
                        
                        NSString *imagePath = [weakSelf localBoxSegmentPathByID:_deviceID withBoxSegmentToken:_token];
                        if (image && imagePath) {
                            [[[MNCache class] mn_sharedCache ] setObject:image forKey:imagePath];
                        }
                        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
                    }
                }
                                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                              NSLog(@"err[%@]", [error localizedDescription]);
                                                          }];
            }
        });
    });
    
}

-(void)cancelNetworkRequest
{
//    _is_stopImage = YES;
    [self.contentImageView cancelImageRequestOperation];
}

#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _contentImageView.layer.borderWidth = 0.5;
    _contentImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _timeLabel.text = [self getStringTime:_start_time];
    _durationLabel.text = [self getStringDurationTime:(_end_time - _start_time)];

    _durationLabel.hidden = _isPhoto;
    _eventImageView.hidden = !_isEvent;
    if (self.app.is_mipc || self.app.is_ebitcam) {
        
    } else {
        _markImageView.hidden = _isPhoto;
    }
}

#pragma mark - pic_get_done
- (void)pic_get_done:(mcall_ret_pic_get*)ret
{
    //the normal operation is that cancel the thread of downloading the picture
    //FIXME:need to be changed
    if (nil != ret.img && _token == ret.token)
    {
        _contentImageView.image = ret.img;
    }
}

- (NSString *)getStringTime:(long long)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000 + self.timeDifference];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    currentCalendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateComponents *weekdayComponents = [currentCalendar components:(NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    NSInteger hour = [weekdayComponents hour];
    NSInteger min = [weekdayComponents minute];
    NSInteger sec = [weekdayComponents second];
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];
}

- (NSString *)getStringDurationTime:(long long)time
{
    long long durationTime = time / 1000;
    long long hour = durationTime / 3600;
    long long min = (durationTime % 3600) / 60;
    long long sec = durationTime % 60;
    
    if (hour) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)sec];
    }
}

#pragma mark - Local message path
- (NSString*)localBoxSegmentPathByID:(NSString*)deviceID withBoxSegmentToken:(NSString*)token
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    NSString *messagePath = [[path stringByAppendingPathComponent:@"photos/boxSegmentCell"] stringByAppendingPathComponent:deviceID];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:messagePath])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:messagePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            NSLog(@"error:%@", [error localizedDescription]);
        }
    }
    
    NSString *imagePath = [messagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", token]];
    
    return imagePath;
}

-(void)showEventImage
{
    NSArray *imageArray = @[_firstImageView,_secondImageView,_thirdImageView,_fourthImageView,_fifthImageView];
    for (UIImageView *imageView in imageArray) {
        imageView.image = nil;
    }
    
    BOOL array[]={_isMotion,_isSnapshot,_isDoor,_isSOS};
    int lenth =  sizeof(array) / sizeof(BOOL);
    int m = 0;
    for (int i = 0; i < lenth; i ++) {
        BOOL event = array[i];
        if (event) {
            m++;
            UIImageView *imageView = [self judgeImageViewWithInt:m];
            [self judgeImageView:imageView withInt:(i + 1)];
        }
    }
}

-(UIImageView *)judgeImageViewWithInt:(int)sequence
{
    UIImageView *imageView;
    switch (sequence) {
        case 1:
            imageView = _firstImageView;
            break;
        case 2:
            imageView = _secondImageView;
            break;
        case 3:
            imageView = _thirdImageView;
            break;
        case 4:
            imageView = _fourthImageView;
            break;
        case 5:
            imageView = _fifthImageView;
            break;
        default:
            break;
    }
    return imageView;
}

-(void)judgeImageView:(UIImageView *)imageView withInt:(int)flag
{
    NSString *imageName;
    switch (flag) {
        case 1:
            imageName = @"vt_event_motion";
            break;
        case 2:
            imageName = @"vt_event_photograph";
            break;
        case 3:
            imageName = @"vt_event_magnetic";
            break;
        case 4:
            imageName = @"vt_event_sos";
            break;
        default:
            break;
    }
    imageView.image = [UIImage imageNamed:imageName];
}
@end
