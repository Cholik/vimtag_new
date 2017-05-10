//
//  UIImageView+Networking.h
//  mipci
//
//  Created by weken on 15/8/10.
//
//

#import <UIKit/UIKit.h>

@interface UIImageView (MNNetworking)

- (void)setImageWithURL:(NSURL *)url;

/**
 Asynchronously downloads an image from the specified URL, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 */

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                  token:(NSString *)token
               deviceID:(NSString *)deviceID;

/**
 Asynchronously downloads an image from the specified URL request, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 If a success block is specified, it is the responsibility of the block to set the image of the image view before returning. If no success block is specified, the default behavior of setting the image with `self.image = image` is applied.
 
 @param urlRequest The URL request used for the image request.
 @param placeholderImage The image to be set initially, until the image request finishes. If `nil`, the image view will not change its image until the image request finishes.
 @param success A block to be executed when the image request operation finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the image created from the response data of request. If the image was returned from cache, the response parameter will be `nil`.
 @param failure A block object to be executed when the image request operation finishes unsuccessfully, or that finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the error object describing the network or parsing error that occurred.
 */
- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                         token:(NSString *)token
                      deviceID:(NSString *)deviceID
                          flag:(long)flag
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image, NSString *deviceID, NSString *token))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

/**
 Cancels any executing image operation for the receiver, if one exists.
 */
- (void)cancelImageRequestOperation;


@end
