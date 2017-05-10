// MNHTTPSessionManager.h
//  mipci
//
//  Created by weken on 15/9/15.
//
//

#import <Foundation/Foundation.h>
#import "MNHTTPRequestOperationManager.h"

#import <Availability.h>
#import <Security/Security.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#endif

@interface MNHTTPRequestOperationManager ()
@property (readwrite, nonatomic, strong) NSURL *baseURL;
@end

@implementation MNHTTPRequestOperationManager

+ (instancetype)manager {
    return [[self alloc] initWithBaseURL:nil];
}

- (instancetype)init {
    return [self initWithBaseURL:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return nil;
    }

    // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
    if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }

    self.baseURL = url;

//    self.reachabilityManager = [MNNetworkReachabilityManager sharedManager];

    self.operationQueue = [[NSOperationQueue alloc] init];

    self.shouldUseCredentialStorage = YES;

    return self;
}

#pragma mark -

#ifdef _SYSTEMCONFIGURATION_H
#endif

#pragma mark -

- (MNHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(MNHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(MNHTTPRequestOperation *operation, NSError *error))failure
{
    MNHTTPRequestOperation *operation = [[MNHTTPRequestOperation alloc] initWithRequest:request];
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;

    [operation setCompletionBlockWithSuccess:success failure:failure];
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;
    
    [self.operationQueue addOperation:operation];

    return operation;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, baseURL: %@, operationQueue: %@>", NSStringFromClass([self class]), self, [self.baseURL absoluteString], self.operationQueue];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSURL *baseURL = [decoder decodeObjectForKey:NSStringFromSelector(@selector(baseURL))];

    self = [self initWithBaseURL:baseURL];
    if (!self) {
        return nil;
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.baseURL forKey:NSStringFromSelector(@selector(baseURL))];

}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    MNHTTPRequestOperationManager *HTTPClient = [[[self class] allocWithZone:zone] initWithBaseURL:self.baseURL];
    
    return HTTPClient;
}

@end
