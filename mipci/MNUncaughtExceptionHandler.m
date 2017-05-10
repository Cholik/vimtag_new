//
//  MNUncaughtExceptionHandler.m
//  mipci
//
//  Created by NansenZhang on 15/10/28.
//
//

#import "MNUncaughtExceptionHandler.h"
#import "AppDelegate.h"
#import <libkern/OSAtomic.h>
#import <execinfo.h>
#import "sys/sysctl.h"

@implementation Exception

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.mode = [aDecoder decodeObjectForKey:@"mode"];
        self.exception_name = [aDecoder decodeObjectForKey:@"exception_name"];
        self.exception_reason = [aDecoder decodeObjectForKey:@"exception_reason"];
        self.call_stack = [aDecoder decodeObjectForKey:@"call_stack"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.mode forKey:@"mode"];
    [aCoder encodeObject:self.exception_name forKey:@"exception_name"];
    [aCoder encodeObject:self.exception_reason forKey:@"exception_reason"];
    [aCoder encodeObject:self.call_stack forKey:@"call_stack"];
}

@end



NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 20;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 0;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 15;

@implementation MNUncaughtExceptionHandler

-(mipc_agent *)agent
{
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return app.cloudAgent;
}

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    int i;
    
    //    NSArray * backtrace = nil;
    //    for (int i = 0; i<128; i++) {
    //        if ([callstack[i] isKindOfClass:[NSArray class]]) {
    //            NSException *exception = (__bridge NSException *)(callstack[i]);
    //            if ([exception isKindOfClass:[NSException class]]) {
    //                backtrace = [exception callStackSymbols];
    //            }
    //            else
    //            {
    //                exception = (__bridge NSException *)(callstack[101]);
    //                backtrace = [exception callStackSymbols];
    //            }
    //        }
    //    }
    
    
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = UncaughtExceptionHandlerSkipAddressCount;i < frames;i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    if (anIndex == 0)
    {
        dismissed = YES;
    }else if (anIndex==1) {
        NSLog(@"ssssssss");
    }
}

- (void)validateAndSaveCriticalApplicationData
{
    
}

- (void)handleException:(NSException *)exception
{
    [self validateAndSaveCriticalApplicationData];
    //Get Dev List And Version
    NSString *tmpString = [NSString string];
    for ( int i = 0; i< self.agent.devs.counts; i++) {
        m_dev *dev = [self.agent.devs get_dev_by_index:i];
        tmpString = [tmpString stringByAppendingString:[NSString stringWithFormat:@"%@:%@,",dev.sn,dev.img_ver]];
    }
    tmpString = [tmpString stringByAppendingString:[NSString stringWithFormat:@"srv:%@",self.agent.srv]];
    //Get Timezone
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    NSDate *currentDate = [NSDate date];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:currentDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:currentDate];
    NSTimeInterval interval = (destinationGMTOffset - sourceGMTOffset)/(60*60);
    
    mcall_ctx_log_reg *ctx = [[mcall_ctx_log_reg alloc] init];
    ctx.target = self;
    ctx.mode = [MNUncaughtExceptionHandler getCurrentDeviceModel];
    ctx.exception_name = [NSString stringWithFormat:@"%@,timezone: %.2f,%@", [exception name], interval, tmpString];
    ctx.exception_reason = [exception reason];
    ctx.call_stack = [[[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey] componentsJoinedByString:@"   ----->"];

    ctx.on_event = @selector(log_req_done:);
    
    NSString *dictPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [dictPath stringByAppendingPathComponent:@"appException"];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    if ([filemanager fileExistsAtPath:filePath]) {
        Exception *appException  = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        appException.mode = [MNUncaughtExceptionHandler getCurrentDeviceModel];
        appException.exception_reason = [exception reason];
        appException.exception_name = [exception name];
        appException.call_stack = [[[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey] componentsJoinedByString:@"   ----->"];
        [NSKeyedArchiver archiveRootObject:appException toFile:filePath];
        
    }
    else{
    
        Exception *appException = [[Exception alloc]init];
        appException.mode = [MNUncaughtExceptionHandler getCurrentDeviceModel];
        appException.exception_reason = [exception reason];
        appException.exception_name = [exception name];
        appException.call_stack = [[[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey] componentsJoinedByString:@"   ----->"];
        [NSKeyedArchiver archiveRootObject:appException toFile:filePath];
    }
    if (![[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        [[NSUserDefaults standardUserDefaults]setObject:@"exception" forKey:@"exception"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (app.developerOption.saveLogSwitch) {
        //Write request to file
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentDateStr = [dateFormat stringFromDate:[NSDate date]];
        NSString *requestUrl = [currentDateStr stringByAppendingFormat:@"\n ######## Log ##########\n Mode:%@ Name:%@ Resaon:%@ \nstack:%@ %@", ctx.mode, ctx.exception_name, ctx.exception_reason, ctx.call_stack,@"\r\n"];
        
        NSString *networkRequestDerectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"NetworkRequest"];
        
        BOOL isDirectory;
        BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:networkRequestDerectory isDirectory:&isDirectory];
        if (!isFileExist || !isDirectory)
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:networkRequestDerectory withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"download_url:timeout:%@", [error localizedDescription]);
            }
        }
        NSString *networkRequestPath = [networkRequestDerectory stringByAppendingPathComponent:@"NetworkRequest.txt"];
        isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:networkRequestPath];
        if (!isFileExist) {
            [[NSFileManager defaultManager] createFileAtPath: networkRequestPath contents:[@"start:" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:networkRequestPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[requestUrl dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }

    NSInteger f_log = [[[NSUserDefaults standardUserDefaults] stringForKey:@"f_log"] integerValue];
    if (f_log) {
        dismissed = YES;
    } else {
        [self.agent log_req:ctx];
        
        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
        
        while (!dismissed)
        {
            for (NSString *mode in (__bridge NSArray *)allModes)
            {
                CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
            }
        }
        
        CFRelease(allModes);
        
        NSSetUncaughtExceptionHandler(NULL);
        signal(SIGABRT, SIG_DFL);
        signal(SIGILL, SIG_DFL);
        signal(SIGSEGV, SIG_DFL);
        signal(SIGFPE, SIG_DFL);
        signal(SIGBUS, SIG_DFL);
        signal(SIGPIPE, SIG_DFL);
        
        if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
        {
            kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
        }
        else
        {
            [exception raise];
        }
    }
}

- (void)log_req_done:(mcall_ret_log_reg *)ret
{
       dismissed = YES;
//       UIAlertView *alert =[[UIAlertView alloc]
//         initWithTitle:NSLocalizedString(@"Result", nil)
//         message:[NSString stringWithFormat:NSLocalizedString(@"The following:\n%@", nil),ret.result]
//         delegate:self
//         cancelButtonTitle:NSLocalizedString(@"Exit", nil)
//         otherButtonTitles: nil];
//        [alert show];
}


+ (NSString *)getCurrentDeviceModel
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s ";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

@end

void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSArray *callStack = [exception callStackSymbols];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[MNUncaughtExceptionHandler alloc] init] performSelectorOnMainThread:@selector(handleException:)
                                                                withObject:[NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo] waitUntilDone:YES];
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary
                                     dictionaryWithObject:[NSNumber numberWithInt:signal]
                                     forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [MNUncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[MNUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:[NSException
                 exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                 reason:[NSString stringWithFormat: NSLocalizedString(@"Signal %d was raised.", nil),
                         signal]
                 userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal]
                                                      forKey:UncaughtExceptionHandlerSignalKey]]
     waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler(void)
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

