// MNHTTPRequestOperation.h
//  mipci
//
//  Created by weken on 15/9/15.
//
//

#import <Foundation/Foundation.h>
#import "MNURLConnectionOperation.h"

//NS_ASSUME_NONNULL_BEGIN

/**
 `MNHTTPRequestOperation` is a subclass of `MNURLConnectionOperation` for requests using the HTTP or HTTPS protocols. It encapsulates the concept of acceptable status codes and content types, which determine the success or failure of a request.
 */
@interface MNHTTPRequestOperation : MNURLConnectionOperation

///------------------------------------------------
/// @name Getting HTTP URL Connection Information
///------------------------------------------------

/**
 The last HTTP response received by the operation's connection.
 */
@property (readonly, nonatomic, strong) NSHTTPURLResponse *response;

///-----------------------------------------------------------
/// @name Setting Completion Block Success / Failure Callbacks
///-----------------------------------------------------------

/**
 Sets the `completionBlock` property with a block that executes either the specified success or failure block, depending on the state of the request on completion. If `error` returns a value, which can be caused by an unacceptable status code or content type, then `failure` is executed. Otherwise, `success` is executed.

 This method should be overridden in subclasses in order to specify the response object passed into the success block.

 @param success The block to be executed on the completion of a successful request. This block has no return value and takes two arguments: the receiver operation and the object constructed from the response data of the request.
 @param failure The block to be executed on the completion of an unsuccessful request. This block has no return value and takes two arguments: the receiver operation and the error that occurred during the request.
 */
- (void)setCompletionBlockWithSuccess:(void (^)(MNHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(MNHTTPRequestOperation *operation, NSError *error))failure;


@end

//NS_ASSUME_NONNULL_END
