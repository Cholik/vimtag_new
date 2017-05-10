//
//  MNMessageViewCell.m
//  mipci
//
//  Created by weken on 15/2/9.
//
//

#import "MNMessageViewCell.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "UIImageView+MNNetworking.h"
#import "MNCache.h"
#import "MIPCUtils.h"

@interface MNMessageViewCell()
@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;

@end

@implementation MNMessageViewCell

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

- (void)setType:(NSString *)type
{
    _type = type;
    
    if ([type isEqualToString:@"record"])
    {
        if (self.app.is_vimtag) {
            _markImageView.image = [UIImage imageNamed:@"vt_box_video.png"];
            
        } else {
            _markImageView.image = [UIImage imageNamed:@"video.png"];
        }
        _durationLabel.hidden = NO;
    }
    else
    {
        _markImageView.image = nil;
        _durationLabel.hidden = YES;
    }
}

-(void)loadWebImage
{
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *path = [weakSelf localMessagePathByID:weakSelf.deviceID withMessageToken:weakSelf.token];
            NSString *imagePath = [weakSelf localMessagePathByID:_deviceID withMessageToken:_token];
            UIImage *image = [[[MNCache class] mn_sharedCache] objectForKey:imagePath];
            if (!image) {
                image = [UIImage imageWithContentsOfFile:path];
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
                    ctx.sn = weakSelf.deviceID;
                    //                ctx.target = weakSelf;
                    //                ctx.on_event = @selector(pic_get_done:);
                    ctx.type = mdev_pic_album;
                    ctx.token = weakSelf.token;
                    
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
                    m_dev *dev = [self.agent.devs get_dev_by_sn:_deviceID];
                    [weakSelf.contentImageView setImageWithURLRequest:[NSURLRequest requestWithURL:downloadImageURL]            placeholderImage:placeholderImage token:_token deviceID:_deviceID flag:dev.spv                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image, NSString *deviceID, NSString *token) {
                
                        if (token == strongSelf.token && image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                strongSelf.contentImageView.image = image;
                                [strongSelf.contentImageView setAlpha:0.5];
                                [UIView animateWithDuration:0.3 animations:^{
                                    [strongSelf.contentImageView setAlpha:1.0];
                                }];
                            });
                        }
                        
                        NSString *imagePath = [weakSelf localMessagePathByID:_deviceID withMessageToken:token];
                        if (image && imagePath) {
                            [[[MNCache class] mn_sharedCache ] setObject:image forKey:imagePath];
                        }
                        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
                        
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
    [self.contentImageView cancelImageRequestOperation];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - prepareForReuse
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    _deviceID = nil;
    _token = nil;
    _type = nil;
    _messageID = 0;
    
    _markImageView.image = nil;
    _timeLabel.text = nil;
    _durationLabel.text = nil;
//    _warnlabel.text = nil;
    [_contentImageView cancelImageRequestOperation];
}

#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _warnlabel.layer.cornerRadius = 5.0;
    _warnlabel.layer.masksToBounds = YES;
    
}

#pragma mark - pic_get_done
- (void)pic_get_done:(mcall_ret_pic_get*)ret
{
    if (nil != ret.img && _token == ret.token)
    {
        NSString *sn = [NSString stringWithString:ret.sn];
        NSString *token = [NSString stringWithString:ret.token];
        UIImage *thubImage = ret.img;
        
        _contentImageView.image = thubImage;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //save image
            NSString *messagePath = [weakSelf localMessagePathByID:sn withMessageToken:token];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:messagePath])
            {
                [UIImagePNGRepresentation(thubImage) writeToFile:messagePath atomically:YES];
            }
        });
    }
}

#pragma mark - Local message path
- (NSString*)localMessagePathByID:(NSString*)deviceID withMessageToken:(NSString*)token
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    NSString *messagePath = [[path stringByAppendingPathComponent:@"photos/messagesCell"] stringByAppendingPathComponent:deviceID];
    
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

@end
