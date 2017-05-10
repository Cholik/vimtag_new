// MNHTTPSessionManager.h
//  mipci
//
//  Created by weken on 15/9/15.
//
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <CoreServices/CoreServices.h>
#endif

#import "MNHTTPRequestOperation.h"
//#import "MNNetworkReachabilityManager.h"

#ifndef NS_DESIGNATED_INITIALIZER
#if __has_attribute(objc_designated_initializer)
#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#else
#define NS_DESIGNATED_INITIALIZER
#endif
#endif

//NS_ASSUME_NONNULL_BEGIN

/**
 `MNHTTPRequestOperationManager` encapsulates the common patterns of communicating with a web application over HTTP, including request creation, response serialization, network reachability monitoring, and security, as well as request operation management.

 ## Subclassing Notes

 Developers targeting iOS 7 or Mac OS X 10.9 or later that deal extensively with a web service are encouraged to subclass `MNHTTPSessionManager`, providing a class method that returns a shared singleton object on which authentication and other configuration can be shared across the application.

 For developers targeting iOS 6 or Mac OS X 10.8 or earlier, `MNHTTPRequestOperationManager` may be used to similar effect.

 ## Methods to Override

 To change the behavior of all request operation construction for an `MNHTTPRequestOperationManager` subclass, override `HTTPRequestOperationWithRequest:success:failure`.

 ## Serialization

 Requests created by an HTTP client will contain default headers and encode parameters according to the `requestSerializer` property, which is an object conforming to `<MNURLRequestSerialization>`.

 Responses received from the server are automatically validated and serialized by the `responseSerializers` property, which is an object conforming to `<MNURLResponseSerialization>`

 ## URL Construction Using Relative Paths

 For HTTP convenience methods, the request serializer constructs URLs from the path relative to the `-baseURL`, using `NSURL +URLWithString:relativeToURL:`, when provided. If `baseURL` is `nil`, `path` needs to resolve to a valid `NSURL` object using `NSURL +URLWithString:`.

 Below are a few examples of how `baseURL` and relative paths interact:

    NSURL *baseURL = [NSURL URLWithString:@"http://example.com/v1/"];
    [NSURL URLWithString:@"foo" relativeToURL:baseURL];                  // http://example.com/v1/foo
    [NSURL URLWithString:@"foo?bar=baz" relativeToURL:baseURL];          // http://example.com/v1/foo?bar=baz
    [NSURL URLWithString:@"/foo" relativeToURL:baseURL];                 // http://example.com/foo
    [NSURL URLWithString:@"foo/" relativeToURL:baseURL];                 // http://example.com/v1/foo
    [NSURL URLWithString:@"/foo/" relativeToURL:baseURL];                // http://example.com/foo/
    [NSURL URLWithString:@"http://example2.com/" relativeToURL:baseURL]; // http://example2.com/

 Also important to note is that a trailing slash will be added to any `baseURL` without one. This would otherwise cause unexpected behavior when constructing URLs using paths without a leading slash.

 ## Network Reachability Monitoring

 Network reachability status and change monitoring is available through the `reachabilityManager` property. Applications may choose to monitor network reachability conditions in order to prevent or suspend any outbound requests. See `MNNetworkReachabilityManager` for more details.

 ## NSSecureCoding & NSCopying Caveats

 `MNHTTPRequestOperationManager` conforms to the `NSSecureCoding` and `NSCopying` protocols, allowing operations to be archived to disk, and copied in memory, respectively. There are a few minor caveats to keep in mind, however:

 - Archives and copies of HTTP clients will be initialized with an empty operation queue.
 - NSSecureCoding cannot serialize / deserialize block properties, so an archive of an HTTP client will not include any reachability callback block that may be set.
 */
@interface MNHTTPRequestOperationManager : NSObject <NSSecureCoding, NSCopying>

/**
 The URL used to monitor reachability, and construct requests from relative paths in methods like `requestWithMethod:URLString:parameters:`, and the `GET` / `POST` / et al. convenience methods.
 */
@property (readonly, nonatomic, strong) NSURL *baseURL;

/**
 The operation queue on which request operations are scheduled and run.
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;

///-------------------------------
/// @name Managing URL Credentials
///-------------------------------

/**
 Whether request operations should consult the credential storage for authenticating the connection. `YES` by default.

 @see MNURLConnectionOperation -shouldUseCredentialStorage
 */
@property (nonatomic, assign) BOOL shouldUseCredentialStorage;

/**
 The credential used by request operations for authentication challenges.

 @see MNURLConnectionOperation -credential
 */
@property (nonatomic, strong) NSURLCredential *credential;

///------------------------------------
/// @name Managing Network Reachability
///------------------------------------

/**
 The network reachability manager. `MNHTTPRequestOperationManager` uses the `sharedManager` by default.
 */
//@property (readwrite, nonatomic, strong) MNNetworkReachabilityManager *reachabilityManager;

///-------------------------------
/// @name Managing Callback Queues
///-------------------------------

/**
 The dispatch queue for the `completionBlock` of request operations. If `NULL` (default), the main queue is used.
 */
#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property (nonatomic, strong) dispatch_queue_t completionQueue;
#else
@property (nonatomic, assign) dispatch_queue_t completionQueue;
#endif

/**
 The dispatch group for the `completionBlock` of request operations. If `NULL` (default), a private dispatch group is used.
 */
#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property (nonatomic, strong) dispatch_group_t completionGroup;
#else
@property (nonatomic, assign) dispatch_group_t completionGroup;
#endif

///---------------------------------------------
/// @name Creating and Initializing HTTP Clients
///---------------------------------------------

/**
 Creates and returns an `MNHTTPRequestOperationManager` object.
 */
+ (instancetype)manager;

/**
 Initializes an `MNHTTPRequestOperationManager` object with the specified base URL.

 This is the designated initializer.

 @param url The base URL for the HTTP client.

 @return The newly-initialized HTTP client
 */
- (instancetype)initWithBaseURL:( NSURL *)url NS_DESIGNATED_INITIALIZER;

///---------------------------------------
/// @name Managing HTTP Request Operations
///---------------------------------------

/**
 Creates an `MNHTTPRequestOperation`, and sets the response serializers to that of the HTTP client.

 @param request The request object to be loaded asynchronously during execution of the operation.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes two arguments: the created request operation and the object created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments:, the created request operation and the `NSError` object describing the network or parsing error that occurred.
 */
- (MNHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:( void (^)(MNHTTPRequestOperation *operation, id responseObject))success
                                                    failure:( void (^)(MNHTTPRequestOperation *operation, NSError *error))failure;

@end

//NS_ASSUME_NONNULL_END
