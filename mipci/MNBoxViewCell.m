//
//  MNBoxViewCell.m
//  mipci
//
//  Created by weken on 15/4/27.
//
//

#import "MNBoxViewCell.h"
#import "AppDelegate.h"
#import "UIImageView+MNNetworking.h"
#import "MNCache.h"

@interface MNBoxViewCell()

@property (strong, nonatomic) mipc_agent *agent;
@property (weak, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSString *token;

@end

@implementation MNBoxViewCell

-(AppDelegate *)app
{
    if (nil == _app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    
    return _app;
}

-(mipc_agent *)agent
{
    return self.app.isLocalDevice?self.app.localAgent:self.app.cloudAgent;
}

-(void)setOnline:(BOOL)online
{
    _online = online;
    if (online)
    {
        if (self.app.is_luxcam)
        {
            _statusImageView.image = [UIImage imageNamed:@"green_dot.png"];
        }
        else
        {
            _statusImageView.image = [UIImage imageNamed:@"green_status.png"];
            
        }
    }
    else
    {
        if (self.app.is_luxcam)
        {
            _statusImageView.image = [UIImage imageNamed:@"red_dot.png"];
        }
        else
        {
            _statusImageView.image = [UIImage imageNamed:@"red_status.png"];
            
        }
    }
}

-(void)loadWebImage
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *token = [NSString stringWithFormat:@"%@_p3_%d_%d", _deviceID, INT_MAX, INT_MAX];
        NSString *imagePath = [weakSelf localImagePathByDeviceID:token];
        UIImage *image = [[[MNCache class] mn_sharedCache] objectForKey:imagePath];
        if (!image) {
           image = [UIImage imageWithContentsOfFile:imagePath];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                weakSelf.backgroundImageView.image = image;
            }
        });
        weakSelf.token = token;
        if (_online) {
            __strong typeof(self) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
                ctx.sn = strongSelf.boxID;
                ctx.type = mdev_pic_seg_album;
                ctx.token = strongSelf.token;
                ctx.flag = 1;

                NSURL *downloadImageURL = [NSURL URLWithString:[self.agent pic_url_create:ctx]];
                [self.backgroundImageView setImageWithURLRequest:[NSURLRequest requestWithURL:downloadImageURL]
                                                placeholderImage:weakSelf.backgroundImageView.image
                                                           token:nil
                                                        deviceID:_deviceID
                                                            flag:0
                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image, NSString *deviceID, NSString *token) {
                                                             
                                                             __strong __typeof(weakSelf)strongSelf = weakSelf;
                                                             
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 if (deviceID == strongSelf.deviceID && image) {
                                                                     strongSelf.backgroundImageView.image = image;
                                                                 }
                                                             });
                                                             
                                                             NSString *imagePath = [self localImagePathByDeviceID:strongSelf.token];
                                                             if (imagePath && image) {
                                                                 [[[MNCache class] mn_sharedCache] setObject:image forKey:imagePath];
                                                             }
                                                             [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
                                                         }
                                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                             NSLog(@"err[%@]", [error localizedDescription]);
                                                         }];

//                if (image)
//                {
//                    strongSelf.backgroundImageView.image = image;
//                }
//                else
//                {
//                    strongSelf.token = token;
//                    
//                    mcall_ctx_pic_get *ctx = [[mcall_ctx_pic_get alloc] init];
//                    ctx.sn = strongSelf.boxID;
//                    ctx.target = strongSelf;
//                    ctx.token = strongSelf.token;
//                    ctx.type = mdev_pic_seg_album;
//                    ctx.flag = 1;
//                    ctx.on_event = @selector(pic_get_done:);
//                    
//                    [strongSelf.agent pic_get:ctx];
//                }
            });
        }
    });
}

#pragma mark - Reuse
-(void)prepareForReuse
{
    _nickLabel.text = nil;
    _backgroundImageView.image = nil;
    [_backgroundImageView cancelImageRequestOperation];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - pic_get_done
- (void)pic_get_done:(mcall_ret_pic_get*)ret
{
    //the normal operation is that cancel the thread of downloading the picture
    //FIXME:need to be changed
    if (nil != ret.img && _token == ret.token)
    {
        _backgroundImageView.image = ret.img;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //save image
            NSString *imagePath = [self localImagePathByDeviceID:ret.token];
            if (imagePath && ret.img) {
                [[[MNCache class] mn_sharedCache] setObject:ret.img forKey:imagePath];
            }
            [UIImagePNGRepresentation(ret.img) writeToFile:imagePath atomically:YES];
        });
    }
}

#pragma mark -
- (NSString*)localImagePathByDeviceID:(NSString *)deviceID
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    NSString *imageDirectory  = [path stringByAppendingPathComponent:@"photos/boxCell"];
    NSString *imagePath = [imageDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", deviceID]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDirectory])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            NSLog(@"error:%@", [error localizedDescription]);
        }
        
    }
    
    return imagePath;
}
@end
