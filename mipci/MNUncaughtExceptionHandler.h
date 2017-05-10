//
//  MNUncaughtExceptionHandler.h
//  mipci
//
//  Created by NansenZhang on 15/10/28.
//
//

#import <Foundation/Foundation.h>
#include <sys/signal.h>
#import "mipc_agent.h"

@interface Exception : NSObject<NSCoding>

@property(strong, nonatomic) NSString *mode;
@property(strong, nonatomic) NSString *exception_name;
@property(strong, nonatomic) NSString *exception_reason;
@property(strong, nonatomic) NSString *call_stack;

@end


@interface MNUncaughtExceptionHandler : NSObject{
    BOOL dismissed;
}
@property (strong, nonatomic) mipc_agent *agent;

+ (NSString *)getCurrentDeviceModel;
@end
void HandleException(NSException *exception);
void SignalHandler(int signal);

void InstallUncaughtExceptionHandler(void);

