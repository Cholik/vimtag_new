// MNHTTPRequestOperation.m
//  mipci
//
//  Created by weken on 15/9/15.
//
//

#import "MNHTTPRequestOperation.h"

static dispatch_queue_t http_request_operation_processing_queue() {
    static dispatch_queue_t mn_http_request_operation_processing_queue;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        mn_http_request_operation_processing_queue = dispatch_queue_create("com.mining.networking.http-request.processing", DISPATCH_QUEUE_CONCURRENT);
    });

    return mn_http_request_operation_processing_queue;
}

static dispatch_group_t http_request_operation_completion_group() {
    static dispatch_group_t mn_http_request_operation_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mn_http_request_operation_completion_group = dispatch_group_create();
    });

    return mn_http_request_operation_completion_group;
}

#pragma mark -

@interface MNURLConnectionOperation ()
@property (readwrite, nonatomic, strong) NSURLRequest *request;
@property (readwrite, nonatomic, strong) NSURLResponse *response;
@end

@interface MNHTTPRequestOperation ()
@property (readwrite, nonatomic, strong) NSHTTPURLResponse *response;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@end

@implementation MNHTTPRequestOperation
@dynamic response;
@dynamic lock;

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (!self) {
        return nil;
    }

    return self;
}

- (NSError *)error {
    return [super error];
}

#pragma mark - AFHTTPRequestOperation

- (void)setCompletionBlockWithSuccess:(void (^)(MNHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(MNHTTPRequestOperation *operation, NSError *error))failure
{
    // completionBlock is manually nilled out in AFURLConnectionOperation to break the retain cycle.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wgnu"
    self.completionBlock = ^{
        if (self.completionGroup) {
            dispatch_group_enter(self.completionGroup);
        }
        
        dispatch_async(http_request_operation_processing_queue(), ^{
            if (self.error) {
                if (failure) {
                    dispatch_group_async(self.completionGroup ?: http_request_operation_completion_group(), self.completionQueue ?: dispatch_get_main_queue(), ^{
                        failure(self, self.error);
                    });
                }
            } else {
                id responseObject = self.responseData;
                if (self.error) {
                    if (failure) {
                        dispatch_group_async(self.completionGroup ?: http_request_operation_completion_group(), self.completionQueue ?: dispatch_get_main_queue(), ^{
                            failure(self, self.error);
                        });
                    }
                } else {
                    if (success) {
                        dispatch_group_async(self.completionGroup ?: http_request_operation_completion_group(), self.completionQueue ?: dispatch_get_main_queue(), ^{
                            success(self, responseObject);
                        });
                    }
                }
            }
            
            if (self.completionGroup) {
                dispatch_group_leave(self.completionGroup);
            }
        });
    };
#pragma clang diagnostic pop
}

#pragma mark - MNURLRequestOperation

- (void)pause {
    [super pause];

    u_int64_t offset = 0;
    if ([self.outputStream propertyForKey:NSStreamFileCurrentOffsetKey]) {
        offset = [(NSNumber *)[self.outputStream propertyForKey:NSStreamFileCurrentOffsetKey] unsignedLongLongValue];
    } else {
        offset = [(NSData *)[self.outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] length];
    }

    NSMutableURLRequest *mutableURLRequest = [self.request mutableCopy];
    if ([self.response respondsToSelector:@selector(allHeaderFields)] && [[self.response allHeaderFields] valueForKey:@"ETag"]) {
        [mutableURLRequest setValue:[[self.response allHeaderFields] valueForKey:@"ETag"] forHTTPHeaderField:@"If-Range"];
    }
    [mutableURLRequest setValue:[NSString stringWithFormat:@"bytes=%llu-", offset] forHTTPHeaderField:@"Range"];
    self.request = mutableURLRequest;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    MNHTTPRequestOperation *operation = [super copyWithZone:zone];
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;

    return operation;
}

@end
