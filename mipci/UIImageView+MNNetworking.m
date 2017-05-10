//
//  UIImageView+Networking.m
//  mipci
//
//  Created by weken on 15/8/10.
//
//

#import "UIImageView+MNNetworking.h"

#import <objc/runtime.h>
#import "MIPCUtils.h"
#import "mipc_agent.h"
#import "AppDelegate.h"
#import "sdc_api.h"
#import "mh264_jpg/mh264_jpg.h"

#pragma mark -

@interface UIImageView (_MNNetworking)
@property (readwrite, nonatomic, strong, setter = mn_setImageRequestOperation:) NSBlockOperation *mn_imageRequestOperation;

@end

@implementation UIImageView (_MNNetworking)

+ (NSOperationQueue *)mn_sharedImageRequestOperationQueue {
    static NSOperationQueue *_mn_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mn_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _mn_sharedImageRequestOperationQueue.maxConcurrentOperationCount = 2;
    });
    
    return _mn_sharedImageRequestOperationQueue;
}

- (NSBlockOperation *)mn_imageRequestOperation {
    return (NSBlockOperation *)objc_getAssociatedObject(self, @selector(mn_imageRequestOperation));
}

- (void)mn_setImageRequestOperation:(NSBlockOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, @selector(mn_imageRequestOperation), imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIImageView (MNNetworking)

#pragma mark -

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil token:nil deviceID:nil];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                  token:(NSString *)token
               deviceID:(NSString *)deviceID;
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:request placeholderImage:placeholderImage token:token deviceID:deviceID flag:0 success:nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                         token:(NSString *)token
                      deviceID:(NSString *)deviceID
                          flag:(long)flag
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image, NSString *deviceID, NSString *token))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];
    
    if (placeholderImage) {
        self.image = placeholderImage;
    }

    __weak __typeof(self)weakSelf = self;
    self.mn_imageRequestOperation = [NSBlockOperation blockOperationWithBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
       
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
        if (error) {
            
            if (failure) {
                failure(urlRequest, response, error);
            }
        }
        else
        {
            UIImage *downloadImage;
            
            NSString *imgString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (imgString.length && [imgString rangeOfString:@"ccm_pic_get_ack"].length)
            {
                struct json_object *json_msg = MIPC_DataTransformToJson(data);
                struct json_object  *ret_data_json = json_get_child_by_name(json_msg, NULL, len_str_def_const("data"));
                struct len_str data_str = {0};
                json_get_child_string(ret_data_json, "frame", &data_str);
                
                if (NULL != data_str.data)
                {
                    uchar *buf_data = (uchar*)malloc(500 * 1024 * sizeof(uchar));
                    long buf_len = 500 * 1024;
                    long dec_success = mh264_jpg_decode(mh264_decode_type_jpg, (uchar*)data_str.data, data_str.len, buf_data, &buf_len);
                    NSData *data_dec = [NSData dataWithBytes:buf_data length:buf_len];
                    downloadImage = [UIImage imageWithData:data_dec];
                    free(buf_data);
                }
            }
            else
            {
                downloadImage = [UIImage imageWithData:data];
            }
            
            
            if (success) {
                success(urlRequest, response, downloadImage, deviceID, token);
            }
            else if (downloadImage)
            {
                dispatch_async(dispatch_get_main_queue(), ^{

                    strongSelf.image = downloadImage;
                });
            }
        }
    }];
    [[[self class] mn_sharedImageRequestOperationQueue] addOperation:self.mn_imageRequestOperation];
}

- (void)cancelImageRequestOperation {
    [self.mn_imageRequestOperation cancel];
    self.mn_imageRequestOperation = nil;
}
@end
