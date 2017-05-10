//
//  mipc_agent.m
//  mipci
//
//  Created by mining on 14-7-23.
//
//
#include "mpack_file/mpack_file.h"
#import "mipc_agent.h"
#import "mios_core_frameworks.h"
#import "mencrypt/mencrypt.h"
#import "mlicense/mlicense.h"
#import "SQLiteUtils.h"
#import "mipc_def_manager.h"
#import "MIPCUtils.h"
#import "sdc_api.h"
#import "mh264_jpg/mh264_jpg.h"
#import <objc/runtime.h>
#import "CoreDataUtils.h"
#import "MNMdevMsg.h"
#import "AppDelegate.h"
#import "MNHTTPRequestOperationManager.h"

#ifdef DEBUG
#define PUBK "477274209664063906332728006973015493"
#else
#define PUBK "310105909413485164588026905566175959"
#endif

#if 1
#define xNSLog(value,type) if(type)NSLog(@"%s---%@",#type,value)
#else
#define xNSLog(value,type)
#endif


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"



//static dispatch_queue_t mmq_task_request_operation_processing_queue() {
//    static dispatch_queue_t mmq_task_peration_processing_queue;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        mmq_task_peration_processing_queue = dispatch_queue_create("com.mmq.task.processing", DISPATCH_QUEUE_SERIAL);
//    });
//    
//    return mmq_task_peration_processing_queue;
//}

//static global variable
static mipc_agent *agent;

//----- mjson_msg_agent.m  -----  start   ----------------
//static mjson_msg_agent *msg_agent;

//----- mjson_msg_agent.m  -----  end    -------------------

typedef NS_ENUM(NSInteger, MNSubscribeNumber) {
    MNSubscribeZero,
    MNSubscribeFirst,
    MNSubscribeMore
};

@interface mipc_agent()
{
//    BOOL                            _do_mmq;
    BOOL                            _resign;
    dispatch_queue_t mmq_task_peration_processing_queue;
}

//----- mjson_msg_agent.m  -----  start    -------------------
@property (assign, nonatomic) int subscribe_fail_count;

//----- mjson_msg_agent.m  -----  end    -------------------



//@property(nonatomic,strong) NSMutableDictionary   *def_ojb_list;
//@property(strong, nonatomic) NSString                *srv;

@property(strong, nonatomic) NSString                *signal_srv;
@property(strong, nonatomic, readwrite) NSString     *srv_type;

@property(assign, nonatomic) int64_t                 tid;

@property(assign, nonatomic) long                    seq;

@property(strong, nonatomic) NSString                *srvSerialNumber;
@property(strong, nonatomic) NSString                *srvNick;
@property(strong, nonatomic) NSString                *srvVersion;
@property(assign, nonatomic) BOOL                    isNewSrv;
@property(strong, nonatomic) NSMutableArray          *msg_listen_arr;//save the message listener

//@property (assign, nonatomic) int testCounts;
@property (strong, nonatomic) NSOperationQueue *mmqOperationQueue;
@property (strong, nonatomic) NSBlockOperation *mmqBlockOperation;
@property (assign, nonatomic) BOOL mmq_stop;
@property (strong, nonatomic) NSURLConnection *mmq_connection;
@property (strong, nonatomic) NSMutableData *mmq_data;
@property (assign, nonatomic) BOOL mmq_downloading;
@property (strong, nonatomic) NSOperationQueue *picOperationQueue;
@property (weak, nonatomic) AppDelegate *app;
@property (assign, nonatomic) MNSubscribeNumber subscribeNumber;

@end


@implementation mipc_agent
@synthesize msgs_need_cache = _msgs_need_cache;
- (AppDelegate *)app
{
    if (!_app) {
        _app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _app;
}
+(mipc_agent *)shared_mipc_agent
{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        agent = [[super allocWithZone:nil] init];
//    });

    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (app.isLocalDevice) {
        agent = app.localAgent;
    }
    else{
        agent = app.cloudAgent;
    }

    return agent;
}
//
//
//
//+(id)allocWithZone:(struct _NSZone *)zone
//{
////    return [self shared_mipc_agent];
//    
//    return agent = [[super allocWithZone:nil] init];
//}

//----- mjson_msg_agent.m  -------------  start    -------------------------------------
#pragma mark- mjson_msg_agent.m ------  start

//+ (mjson_msg_agent*)shared_msg_agent
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        msg_agent = [[super allocWithZone:nil] init];
//    });
//    
//    return msg_agent;
//}
//
//+(id)allocWithZone:(struct _NSZone *)zone
//{
//    return [self shared_msg_agent];
//}

//-(id)init
//{
//    self = [super init];
//    if (self) {
//        _m_from_handle = 0;
//        _subscribe_fail_count = 0;
//    }
//    
//    return self;
//}

#pragma mark- build
- (NSString*)build_url:(NSString*)srv
                    to:(NSString*)to
             to_handle:(long)to_handle
                  mqid:(NSString*)mqid
           from_handle:(long)from_handle
                  type:(NSString*)type
              dataJson:(NSString*)dataJson
{
#undef func_format_s
#undef func_format
#define func_format_s   "buildURL(self[%p], srv["NSString_format_s"], to["NSString_format_s"], to_handle[%ld], "\
"mqid["NSString_format_s"], from_handle[%ld], "\
"type["NSString_format_s"], dataJson["NSString_format_s"]"
#define func_format()   self, NSString_format(srv), NSString_format(to), to_handle, NSString_format(mqid), from_handle, \
NSString_format(type), NSString_format(dataJson)
    
    NSString            *url;
    long                content_len = 0;
    unsigned long       buf_size = 1024 * 1024 * 3;
    char                *buf = (char*)malloc(buf_size);
    unsigned long       data_json_len = dataJson?[dataJson lengthOfBytesUsingEncoding:NSUTF8StringEncoding]:0;
    
    struct json_object  *root = NULL;
    root = data_json_len?json_decode(data_json_len, (char*)[dataJson UTF8String]):NULL;
    
    if(NULL == buf)
    {
        print_log1(err, "failed when malloc(%ld) url buf.", buf_size);
        return nil;
    }
    if(data_json_len && (NULL == root))
    {
        print_log0(err, "failed when json_decode() .");
        free(buf);
        return nil;
    }
    
    content_len = pack_file_json_export_as_http_url(srv?[srv length]:0,
                                                    (char*)(srv?[srv UTF8String]:NULL),
                                                    to?[to length]:0,
                                                    (char*)(to?[to UTF8String]:NULL),
                                                    to_handle,
                                                    mqid?mqid.length:0,
                                                    (char*)(mqid?mqid.UTF8String:NULL),
                                                    from_handle,
                                                    type?[type length]:0,
                                                    (char*)(type?[type UTF8String]:NULL),
                                                    root,
                                                    0,
                                                    buf_size,
                                                    buf);
    
    
    if(0 > content_len)
    {
        print_log0(err, "failed when pack_file_json_export_as_http_url().");
        free(buf);
        return nil;
    }
    url = [NSString stringWithUTF8String:(const char*)buf];
    if(nil == url)
    {
        print_log0(err, "failed when stringWithUTF8String().");
    }
    free(buf);
    
      return url;
    
}

#pragma mark- call_syn && download(Use http)
- (NSData*)download_url:(NSString*)url timeout:(long)timeout/* ms */
{
#undef func_format_s
#undef func_format
#define func_format_s   "downloadURL(self[%p], url["NSString_format_s"], timeout[%ld])"
#define func_format()   self, NSString_format(url), timeout
    
    //    NSString * encodingString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    timeout = timeout?timeout:60;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:timeout];
    
    NSHTTPURLResponse   *response = nil;
    NSError             *connectionError = nil;
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"request----->%@", url);
#else
    if (self.app.developerOption.printLogSwitch) {
        NSLog(@"request----->%@", url);
    }
    if (self.app.startSaveLog || self.app.developerOption.saveLogSwitch) {
        [self saveLogWithType:LOG_TYPE_REQUEST content:url];
    }
#endif
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&connectionError];
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"response<-----%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#else
    if (self.app.developerOption.printLogSwitch) {
        NSLog(@"response<-----%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
    if (self.app.startSaveLog || self.app.developerOption.saveLogSwitch) {
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (content.length > 0) {
            [self saveLogWithType:LOG_TYPE_RESPONSE content:[content substringToIndex:content.length - 1]];
        }
    }
#endif

    //check the connection
    if(connectionError)
    {
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"ret[%ld], err[%@], reason[%@], errorFailingURLStringKey[%@]", (long)(data?data.length:0), connectionError.localizedDescription, connectionError.localizedFailureReason, connectionError.userInfo[@"NSErrorFailingURLStringKey"]);
#else
        if (self.app.developerOption.printLogSwitch) {
            NSLog(@"ret[%ld], err[%@], reason[%@], errorFailingURLStringKey[%@]", (long)(data?data.length:0), connectionError.localizedDescription, connectionError.localizedFailureReason, connectionError.userInfo[@"NSErrorFailingURLStringKey"]);
        }
        if (self.app.startSaveLog || self.app.developerOption.saveLogSwitch) {
            //Write request to file
            [self saveLogWithType:LOG_TYPE_RESPONSE content:[NSString stringWithFormat:@"ret[%ld], err[%@], reason[%@], errorFailingURLStringKey[%@]", (long)(data?data.length:0), connectionError.localizedDescription, connectionError.localizedFailureReason, connectionError.userInfo[@"NSErrorFailingURLStringKey"]]];
        }
#endif
    }
    
    return data;
}

- (mjson_msg*)call:(NSString*)srv
                to:(NSString*)to
         to_handle:(long)to_handle
              mqid:(NSString*)mqid
       from_handle:(long)from_handle
              type:(NSString*)type
          dataJson:(NSString*)dataJson
           timeout:(long)timeout
{
#undef func_format_s
#undef func_format
#define func_format_s   "send(self[%p], srv["NSString_format_s"], to["NSString_format_s"], to_handle[%ld], "\
"mqid["NSString_format_s"], from_handle[%ld], "\
"type["NSString_format_s"], dataJson["NSString_format_s"])"
#define func_format()   self, NSString_format(srv), NSString_format(to), to_handle, NSString_format(mqid), from_handle, \
NSString_format(type), NSString_format(dataJson)
    
    if((nil == srv) || (nil == type))
    {
        print_log0(err, "failed with invalid param.");
        return nil;
    }
    
    //check network statu
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (!app.isNetWorkAvailable) {
        NSLog(@"NetWork unavailable");
        return nil;
    }
    
    NSString *url = [self build_url:srv
                                 to:to
                          to_handle:to_handle
                               mqid:mqid
                        from_handle:from_handle
                               type:type
                           dataJson:dataJson];
    
    NSData *data = [self download_url:url timeout:timeout];
    NSString *srt_data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    print_log1(debug, "NSString_format_s.%@",srt_data);
    struct json_object *data_json = MIPC_DataTransformToJson(data);
    __block mjson_msg *msg  = [[mjson_msg alloc] initWithJson:data_json];
    print_log2(debug, "ret[%p{json[%p]}].", msg, msg?msg.json:NULL);
    
    if (msg && msg.data)
    {
        struct len_str s_result = {0};
        
        //        mipc_agent *agent = [mipc_agent shared_mipc_agent];
        [self get_result:msg.data result:&s_result];
        
        if (s_result.len
            &&((0 == len_str_casecmp_const(&s_result, "InvalidSession"))
               || (0 == len_str_casecmp_const(&s_result, "accounts.sid.invalid"))
               || (0 == len_str_casecmp_const(&s_result, "accounts.nid.invalid"))
               || (0 == len_str_casecmp_const(&s_result, "accounts.lid.invalid"))
               || (0 == len_str_casecmp_const(&s_result, "ccms.sess.invalid"))))
        {
            //lock msg
            NSCondition* msg_lock = [[NSCondition alloc] init];
            
            mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
            ctx.srv = self.srv;
            ctx.user = self.user;
            ctx.passwd = self.passwd;
            ctx.target = self;
            
            if([@"ccm_subscribe" isEqualToString:type])
            {
                self.subscribe_fail_count +=1;
                if (_subscribe_fail_count >= 10) {
                    //send signal
                    [msg_lock lock];
                    [msg_lock signal];
                    [msg_lock unlock];
                    return msg;
                }
            }
            
            
            __weak typeof(self) weakSelf = self;
            [weakSelf create_nid:ctx block:^(mcall_ret_sign_in *ret){
                long dataJson_len = [dataJson lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                buf_size   = dataJson_len + 1024;
                struct  json_object *new_data_json_obj = json_decode(dataJson_len, (char*)dataJson.UTF8String),
                *sess = new_data_json_obj?json_get_child_by_name(new_data_json_obj, NULL, len_str_def_const("sess")):NULL,
                *new_nid, *nid = sess?json_get_child_by_name(sess, NULL, len_str_def_const("nid")):NULL;
                if (nid)
                {
                    json_destroy(nid);
                    
                    char        *temp = malloc(buf_size);
                    NSString    *newNidStr = [agent mipc_build_nid];
                    if ((NULL == temp) || (nil == newNidStr) || (0 == newNidStr.length))
                    {/* if(new_dataJson) need json_destroy it, then can return */
                        if(temp){
                            free(temp);
                            temp = nil;
                        };
                        json_destroy(new_data_json_obj);
                        
                        
                        //                        return msg;
                    }
                    else
                    {
                        new_nid = json_create_string(sess,len_str_def_const("nid"), newNidStr.length, (char*)newNidStr.UTF8String);
                        if((NULL == new_nid)|| (0 > json_encode(new_data_json_obj, temp, buf_size)))
                        { /* need check result */
                            if(temp){
                                free(temp);
                                temp = nil;
                            };
                            
                            json_destroy(new_data_json_obj);
                            
                            
                            //                        return msg;
                        }
                    }
                    
                    NSString *fixedDataJson = [NSString stringWithUTF8String:temp];
                    NSString *url = [self build_url:srv
                                                 to:to
                                          to_handle:to_handle
                                               mqid:mqid
                                        from_handle:from_handle
                                               type:type
                                           dataJson:fixedDataJson];
                    
                    NSData *data = [self download_url:url timeout:timeout];
                    NSString *srt_data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        
                    print_log1(debug, "NSString_format_s.%@",srt_data);
                    struct json_object *data_json = MIPC_DataTransformToJson(data);
                    msg  = [[mjson_msg alloc] initWithJson:data_json];
                    print_log2(debug, "ret[%p{json[%p]}].", msg, msg?msg.json:NULL);
                }
            
                //send signal
                [msg_lock lock];
                [msg_lock signal];
                [msg_lock unlock];
            }];
            
            //wait ending block
            [msg_lock lock];
            [msg_lock wait];
            [msg_lock unlock];
        }
    }
    
    return msg;
}

#pragma mark- call_asyn && download
-(long)download_url:(NSString *)url timeout:(long)timeout completionBlock:(void (^)(NSData* data))block
{
    timeout = timeout?timeout:60;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:timeout];
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"request----->%@", url);
#else
    if (self.app.developerOption.printLogSwitch) {
        NSLog(@"request----->%@", url);
    }
    if (self.app.startSaveLog || self.app.developerOption.saveLogSwitch) {
        [self saveLogWithType:LOG_TYPE_REQUEST content:url];
    }
#endif
    MNHTTPRequestOperationManager *testRequestOperationManager = [MNHTTPRequestOperationManager manager];
    [testRequestOperationManager HTTPRequestOperationWithRequest:request success:^ void(MNHTTPRequestOperation * operation, id responseData) {
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"response<-----%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
#else
        if (self.app.developerOption.printLogSwitch) {
            NSLog(@"response<-----%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }
        if (self.app.startSaveLog || self.app.developerOption.saveLogSwitch) {
            NSString *content = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            if (content.length > 0) {
                [self saveLogWithType:LOG_TYPE_RESPONSE content:[content substringToIndex:content.length - 1]];
            }
        }
#endif
        if (block)
        {
            block(responseData);
        }
    } failure:^ void(MNHTTPRequestOperation * operation, NSError *error) {
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"response<-----HTTPRequestOperationWithRequest.data[%ld], localizedDescription[%@], localizedFailureReason[%@], NSErrorFailingURLStringKey[%@]",
              (long)(operation.responseData?operation.responseData.length:0),
              error.localizedDescription,
              error.localizedFailureReason,
              error.userInfo[@"NSErrorFailingURLStringKey"]);
#else
        if (self.app.developerOption.printLogSwitch) {
            NSLog(@"response<-----HTTPRequestOperationWithRequest.data[%ld], localizedDescription[%@], localizedFailureReason[%@], NSErrorFailingURLStringKey[%@]",
                  (long)(operation.responseData?operation.responseData.length:0),
                  error.localizedDescription,
                  error.localizedFailureReason,
                  error.userInfo[@"NSErrorFailingURLStringKey"]);
        }
        if (self.app.startSaveLog || self.app.developerOption.saveLogSwitch) {
            [self saveLogWithType:LOG_TYPE_RESPONSE content:[NSString stringWithFormat:@"ret[%ld], err[%@], reason[%@], errorFailingURLStringKey[%@]", (long)(operation.responseData?operation.responseData.length:0), error.localizedDescription, error.localizedFailureReason, error.userInfo[@"NSErrorFailingURLStringKey"]]];
        }
#endif
        if (block)
        {
            block(operation.responseData);
        }
    }];
    
    return 0;
}

- (long)call_asyn:(NSString*)srv
               to:(NSString*)to
        to_handle:(long)to_handle
             mqid:(NSString*)mqid
      from_handle:(long)from_handle
             type:(NSString*)type
         dataJson:(NSString*)dataJson
          timeout:(long)timeout
       usingBlock:(void(^)(mjson_msg *msg))block
{
#undef func_format_s
#undef func_format
#define func_format_s   "sendAsyn(self[%p], srv["NSString_format_s"], to["NSString_format_s"], to_handle[%ld], "\
"mqid["NSString_format_s"], from_handle[%ld], "\
"type["NSString_format_s"], dataJson["NSString_format_s"])"
#define func_format()   self, NSString_format(srv), NSString_format(to), to_handle, NSString_format(mqid), from_handle, \
NSString_format(type), NSString_format(dataJson)
    
    if((nil == srv) || (nil == type))
    {
        print_log0(err, "failed with invalid param.");
        if (block) {
            block(nil);
        }
        return 0;
    }
    
    //check network statu
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (!app.isNetWorkAvailable) {
        NSLog(@"NetWork unavailable");
        if (block) {
            block(nil);
        }
        return 0;
    }
    
    NSString *url = [self build_url:srv
                                 to:to
                          to_handle:to_handle
                               mqid:mqid
                        from_handle:from_handle
                               type:type
                           dataJson:dataJson];
    
    [self download_url:url timeout:timeout completionBlock:^(NSData *data) {
        NSString *str_data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        print_log1(debug, "NSString_format_s.%@",str_data);
        struct json_object *data_json = MIPC_DataTransformToJson(data);
        __block mjson_msg *msg  = [[mjson_msg alloc] initWithJson:data_json];
        print_log2(debug, "ret[%p{json[%p]}].", msg, msg?msg.json:NULL);
        
        if (msg && msg.data)
        {
            struct len_str s_result = {0};
            
            mipc_agent *agent = [mipc_agent shared_mipc_agent];
            [agent get_result:msg.data result:&s_result];
            
            if (s_result.len
                &&((0 == len_str_casecmp_const(&s_result, "InvalidSession"))
                   || (0 == len_str_casecmp_const(&s_result, "accounts.sid.invalid"))
                   || (0 == len_str_casecmp_const(&s_result, "accounts.nid.invalid"))
                   || (0 == len_str_casecmp_const(&s_result, "accounts.lid.invalid"))
                   || (0 == len_str_casecmp_const(&s_result, "ccms.sess.invalid"))))
            {
                mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
                ctx.srv = agent.srv;
                ctx.user = agent.user;
                ctx.passwd = agent.passwd;
                ctx.target = self;
                //                ctx.sync = YES;
                
                if([@"ccm_subscribe" isEqualToString:type])
                {
                    self.subscribe_fail_count +=1;
                    if (_subscribe_fail_count >= 10) {
                        if (block) {
                            block(msg);
                        }
                        //                        return msg;
                        return ;
                    }
                }
                
                __weak typeof(self) weakSelf = self;
                [weakSelf create_nid:ctx block:^(mcall_ret_sign_in *ret){
                    long dataJson_len = [dataJson lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                    buf_size   = dataJson_len + 1024;
                    struct  json_object *new_data_json_obj = json_decode(dataJson_len, (char*)dataJson.UTF8String),
                    *sess = new_data_json_obj?json_get_child_by_name(new_data_json_obj, NULL, len_str_def_const("sess")):NULL,
                    *new_nid, *nid = sess?json_get_child_by_name(sess, NULL, len_str_def_const("nid")):NULL;
                    if (nid)
                    {
                        json_destroy(nid);
                        
                        char        *temp = malloc(buf_size);
                        NSString    *newNidStr = [agent mipc_build_nid];
                        if ((NULL == temp) || (nil == newNidStr) || (0 == newNidStr.length))
                        {/* if(new_dataJson) need json_destroy it, then can return */
                            if(temp){
                                free(temp);
                                temp = nil;
                            };
                            json_destroy(new_data_json_obj);
                            
                            
                            //                        return msg;
                        }
                        else
                        {
                            new_nid = json_create_string(sess,len_str_def_const("nid"), newNidStr.length, (char*)newNidStr.UTF8String);
                            if((NULL == new_nid)|| (0 > json_encode(new_data_json_obj, temp, buf_size)))
                            { /* need check result */
                                if(temp){
                                    free(temp);
                                    temp = nil;
                                };
                                
                                json_destroy(new_data_json_obj);
                                
                                
                                //                        return msg;
                            }
                        }
                        
                        if(![@"ccm_subscribe" isEqualToString:type])
                        {
                            NSString *fixedDataJson = [NSString stringWithUTF8String:temp];
                            NSString *url = [self build_url:srv
                                                         to:to
                                                  to_handle:to_handle
                                                       mqid:mqid
                                                from_handle:from_handle
                                                       type:type
                                                   dataJson:fixedDataJson];
                            
                            [self download_url:url timeout:timeout completionBlock:^(NSData *data) {
                                NSString *srt_data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                
                                print_log1(debug, "NSString_format_s.%@",srt_data);
                                struct json_object *data_json = MIPC_DataTransformToJson(data);
                                msg  = [[mjson_msg alloc] initWithJson:data_json];
                                print_log2(debug, "ret[%p{json[%p]}].", msg, msg?msg.json:NULL);
                                if (block) {
                                    block(msg);
                                }
                            }];
                            return ;
                        }
                    }

                    if (block) {
                        block(msg);
                    }
                }];
                return ;
            }
        }

        if (block) {
            block(msg);
        }
    }];
    
    return 0;
}

- (long)post_download_url:(NSString *)url request:(NSString *)requestString timeout:(long)timeout completionBlock:(void (^)(NSData* data))block
{
    timeout = timeout?timeout:60;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:timeout];
    request.HTTPMethod=@"POST";
    request.HTTPBody = [url dataUsingEncoding:NSUTF8StringEncoding];
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Request----->%@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
#else
    if (self.app.developerOption.printLogSwitch) {
        NSLog(@"Request<-----%@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    }
#endif
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"response<-----%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#else
        if (self.app.developerOption.printLogSwitch) {
            NSLog(@"response<-----%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
#endif
        //check the connection
        if(error)
        {
#if TARGET_IPHONE_SIMULATOR
            NSLog(@"error[%@]", error);
#else
            if (self.app.developerOption.printLogSwitch) {
                NSLog(@"error[%@]", error);
            }
#endif
        }
        
        if (block) {
            block(data);
        }
    }];
    
    [dataTask resume];
    
    return 0;
}

- (long)post_asyn:(NSString*)srv
               to:(NSString*)to
        to_handle:(long)to_handle
             mqid:(NSString*)mqid
      from_handle:(long)from_handle
             type:(NSString*)type
          request:(NSString*)requestString
         dataJson:(NSString*)dataJson
          timeout:(int)timeout
       usingBlock:(void(^)(mjson_msg *msg))block
{
    if((nil == srv) || (nil == type))
    {
        print_log0(err, "failed with invalid param.");
        if (block) {
            block(nil);
        }
        return -1;
    }
    
    NSString *url = [self build_url:srv
                                 to:to
                          to_handle:to_handle
                               mqid:mqid
                        from_handle:from_handle
                               type:type
                           dataJson:dataJson];
    [self post_download_url:url request:requestString timeout:60 completionBlock:^(NSData *data) {
        NSString *str_data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        print_log1(debug, "NSString_format_s.%@",str_data);
        struct json_object *data_json = MIPC_DataTransformToJson(data);
        __block mjson_msg *msg  = [[mjson_msg alloc] initWithJson:data_json];
        print_log2(debug, "ret[%p{json[%p]}].", msg, msg?msg.json:NULL);
        
        if (block) {
            block(msg);
        }
        
    }];
    
    return 0;
}

#pragma mark - Save Log
- (long)saveLogWithType:(long)type content:(NSString *)content
{
    if ((LOG_TYPE_REQUEST == type) || (LOG_TYPE_RESPONSE == type)) {
        @try {
            if (content.length > 100 * 1024) {
                return 0;
            }
            //Write request to file
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *currentDateStr = [dateFormat stringFromDate:[NSDate date]];
            NSString *requestUrl = [currentDateStr stringByAppendingFormat:@"%@, %@, %@",(type == LOG_TYPE_REQUEST ?@"Request----->" : @"response<-----"), content, @"\r\n"];
            
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
            
            if ([[[NSFileManager defaultManager] attributesOfItemAtPath:networkRequestPath error:nil] fileSize] > (2*1024.0*1024.0)) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *tmp_log = MIPC_GetFileFullPath(@"NetworkRequest");
                BOOL isDirectory;
                BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:tmp_log isDirectory:&isDirectory];
                if (isFileExist || isDirectory)
                {
                    NSError *logError = nil;
                    [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@",tmp_log] error:&logError];
                    if (logError) {
                        NSLog(@"download_url:timeout:%@", [logError localizedDescription]);
                    }
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"exception:%@", exception);
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *tmp_log = MIPC_GetFileFullPath(@"NetworkRequest");
            BOOL isDirectory;
            BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:tmp_log isDirectory:&isDirectory];
            if (isFileExist || isDirectory)
            {
                NSError *logError = nil;
                [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@",tmp_log] error:&logError];
                if (logError) {
                    NSLog(@"download_url:timeout:%@", [logError localizedDescription]);
                }
            }
        } @finally {
        }
    }
    
    return 0;
}

- (NSData*)build_mining64_data:(mcall_ctx_log_reg *)ctx
{
    struct len_str      s_dh_prime = {len_str_def_const(dh_default_prime)},
    s_dh_root = {len_str_def_const(dh_default_root)},
    s_dh_es_pubk = {len_str_def_const("310105909413485164588026905566175959")};
    struct dh_mod       *es_dh_mod = dh_create(&s_dh_prime, &s_dh_root);
    struct len_str      *s_dh_pubk = es_dh_mod?dh_get_public_key(es_dh_mod):NULL,
    *s_dh_share_key = es_dh_mod?dh_get_share_key(es_dh_mod, &s_dh_es_pubk):NULL;
    NSString            *exParams = nil, *encode_sys = s_dh_share_key?MIPC_BuildEncryptExceptionInfo(ctx.log_type,ctx.mode,ctx.exception_name,ctx.exception_reason,ctx.call_stack,_user,[NSString stringWithUTF8String:s_dh_share_key->data]):nil;
    
    if(encode_sys)
    {
        exParams = [NSString stringWithFormat:@"{p:[{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"}]}",
                    "uctx", encode_sys?encode_sys.UTF8String:"",
                    "root", s_dh_root.data,
                    "prime", s_dh_prime.data,
                    "pubk", s_dh_pubk?s_dh_pubk->data:""];
    }
    
    return [exParams dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark- fromHandle Create
- (long)createFromHandle
{
    return ++_m_from_handle;
}

#pragma mark- mjson_msg_agent.m ------  end
//----- mjson_msg_agent.m  -----  end    -------------------------------------

+ (void)passwd_encrypt:(NSString *)pwd encrypt_pwd:(unsigned char *)encrypt_pwd
{
    md5_ex_encrypt((unsigned char*)[pwd UTF8String], (long)[pwd length], &encrypt_pwd[0]);
}

- (id)init
{
    if (self = [super init])
    {
//        //notification
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(applicationDidEnterBackground:)
//                                                     name:UIApplicationDidEnterBackgroundNotification
//                                                   object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(applicationWillEnterForeground:)
//                                                     name:UIApplicationWillEnterForegroundNotification
//                                                   object:nil];
//----- mjson_msg_agent.m  -----  start    -------------------------------------
        _m_from_handle = 0;
        _subscribe_fail_count = 0;
//----- mjson_msg_agent.m  -----  end    -------------------------------------

        _devs = [[mdev_devs alloc] init];
//        _queue = [[NSOperationQueue alloc] init];
//        _queue.maxConcurrentOperationCount = 1;
        _msg_listen_arr = [[NSMutableArray alloc] initWithCapacity:1];
        //initializing msg_agent
//        _msg_agent = [[mjson_msg_agent alloc] init];
    }
    return  self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSOperationQueue *)mmqOperationQueue
{
    @synchronized(self){
        if (nil == _mmqOperationQueue) {
            _mmqOperationQueue = [[NSOperationQueue alloc] init];
            _mmqOperationQueue.maxConcurrentOperationCount = 1;
        }
        
        return _mmqOperationQueue;
    }
}

- (NSOperationQueue *)picOperationQueue
{
    @synchronized(self){
        if (nil == _picOperationQueue) {
            _picOperationQueue = [[NSOperationQueue alloc] init];
            _picOperationQueue.maxConcurrentOperationCount = 1;
        }
        
        return _picOperationQueue;
    }
}

- (void)setMsgs_need_cache:(BOOL)msgs_need_cache
{
    if(NO == msgs_need_cache)
    {
        [self.devs unsave];
    }
    _msgs_need_cache = msgs_need_cache;
}

- (void)get_result:(struct json_object*)data result:(struct len_str *)result /* [out] */
{
    struct json_object *jsonData = data, *jsonResult = NULL;

    if(jsonData)
    {
        jsonResult = json_get_child_by_name(jsonData, NULL, len_str_def_const("ret"));
        if(NULL == jsonResult){
            jsonResult = json_get_child_by_name(jsonData, NULL, len_str_def_const("result"));
            if(NULL == jsonResult)
                jsonResult = json_get_child_by_name(jsonData, NULL, len_str_def_const("Result"));
        }
    }

    result->len  = 0;
    result->data = NULL;

    if(jsonResult)
    {
        if(ejot_object == jsonResult->type)
        {

            json_get_child_string(jsonResult, "sub", result);
            if(0 == result->len)
            {
                json_get_child_string(jsonResult, "reason", result);
                if(0 == result->len)
                {
                    json_get_child_string(jsonResult, "code", result);
                    if(0 == result->len)
                    {
                        json_get_child_string(jsonResult, "SubCode", result);
                        if(0 == result->len)
                        {
                            json_get_child_string(jsonResult, "Reason", result);
                        }
                    }

                }
            }
        }
        else
        {
            json_get_string(jsonResult, result);
        }
    }
    return;
}

- (NSString*)check_result:(mjson_msg *)msg
{
    struct len_str result = {0};
    [self get_result:msg.data result:&result];
    
    if(NULL != msg.data && result.len == 0)
    {
        return nil;
    }
    else if(NULL == msg.data)
    {
        return  @"ret.no.rsp";
    }
    else if((0 == len_str_casecmp_const(&result, "Device offline"))
            ||(0 == len_str_casecmp_const(&result, "accounts.user.offline")))
    {
        return @"ret.dev.offline";
    }
    else if((0 == len_str_casecmp_const(&result, "Invalid user"))
            ||(0 == len_str_casecmp_const(&result, "accounts.user.unknown"))
            ||(0 == len_str_casecmp_const(&result, "accounts.user.invalid")))
    {
        return @"ret.user.unknown";
    }
    else if((0 == len_str_casecmp_const(&result, "Invalid pass"))
            ||(0 == len_str_casecmp_const(&result, "accounts.pass.invalid")))
    {
        return @"ret.pwd.invalid";
    }
    else if (0 == len_str_casecmp_const(&result, "subdev.exceed.device"))
    {
        return @"ret.subdev.exceed";
    }
    else if(((0 == len_str_casecmp_const(&result, "InvalidSession"))
             || (0 == len_str_casecmp_const(&result, "accounts.sid.invalid"))
             || (0 == len_str_casecmp_const(&result, "accounts.nid.invalid"))
             || (0 == len_str_casecmp_const(&result, "accounts.lid.invalid"))
             || (0 == len_str_casecmp_const(&result, "ccms.sess.invalid"))))
    {
        return @"ret.nid.invalid";
    }
    else if(0 == len_str_casecmp_const(&result, "ccms.param.invalid"))
    {
        return @"ret.parma.invalid";
    }
    else if(0 == len_str_casecmp_const(&result, "permission.denied"))
    {
        return @"ret.permission.denied";
    }
    else if (0 == len_str_casecmp_const(&result, "SdIsNotReady"))
    {
        return @"ret.sdcard.notready";
    }
    else if (0 == len_str_casecmp_const(&result, "accounts.user.existed"))
    {
        return @"ret.user.existed";
    }
    else if (0 == len_str_casecmp_const(&result, "accounts.bind.email.exist"))
    {
        return @"ret.user.binded.byemail";
    }
    else if (0 == len_str_casecmp_const(&result, "accounts.bind.email.busy"))
    {
        return @"ret.email.binded";
    }
    else if (0 == len_str_casecmp_const(&result, "accounts.recovery.email.inactive"))
    {
        return @"ret.email.inactive";
    }
    else if (0 == len_str_casecmp_const(&result, "accounts.recovery.email.unbind"))
    {
        return @"ret.email.unbind";
    }
    else if (0 == len_str_casecmp_const(&result, "accounts.recovery.email.unmatch"))
    {
        return @"ret.email.unmatch";
    }
    else if (0 == len_str_casecmp_const(&result, "accounts.mail.invalid"))
    {
        return @"ret.mail.invalid";
    }
    else if (0 == len_str_casecmp_const(&result, "accounts.user.inactive"))
    {
        return @"ret.user.inacgtive";
    }
    else
    {
        return @"ret.other.reason";
    }
}

- (BOOL)check_ver:(NSString *)type sn:(NSString *)sn;
{
//    m_dev *dev = [self.devs get_dev_by_sn:sn];
//
//    if(dev.img_ver && dev.img_ver.length)
//    {
//        if([type isEqualToString:@"ccm_dev_info_get"]
//           || [type isEqualToString:@"ccm_nick_set"]
//           || [type isEqualToString:@"ccm_net_get"]
//           || [type isEqualToString:@"ccm_net_set"]
//           || [type isEqualToString:@"ccm_osd_get"]
//           || [type isEqualToString:@"ccm_osd_set"]
//           || [type isEqualToString:@"ccm_osd_get"]
//           || [type isEqualToString:@"ccm_mic_get"]
//           || [type isEqualToString:@"ccm_mic_set"]
//           || [type isEqualToString:@"ccm_speaker_get"]
//           || [type isEqualToString:@"ccm_speaker_set"]
//           || [type isEqualToString:@"ccm_misc_get"]
//           || [type isEqualToString:@"ccm_misc_set"]
//           || [type isEqualToString:@"ccm_img_get"]
//           || [type isEqualToString:@"ccm_img_set"]
//           || [type isEqualToString:@"ccm_video_srcs_get"])
//        {
//            if((0 <= [dev.img_ver caseInsensitiveCompare:@"13.01.01.00.00"]))
//                return YES;
//        }
//        else if([type isEqualToString:@"ccm_replay"]
//                || [type isEqualToString:@"ccm_disk_get"]
//                || [type isEqualToString:@"ccm_disk_ctl"]
//                || [type isEqualToString:@"ccm_alert_dev_get"]
//                || [type isEqualToString:@"ccm_alert_dev_set"]
//                || [type isEqualToString:@"ccm_alert_action_get"]
//                || [type isEqualToString:@"ccm_alert_action_set"]
//                || [type isEqualToString:@"ccm_date_get"]
//                || [type isEqualToString:@"ccm_date_set"]
//                || [type isEqualToString:@"ccm_ntp_get"]
//                || [type isEqualToString:@"ccm_ntp_set"]
//                || [type isEqualToString:@"ccm_record_task_get"]
//                || [type isEqualToString:@"ccm_record_task_set"])
//        {
//            if((0 <= [dev.img_ver caseInsensitiveCompare:@"13.06.01.00.00"]))
//                return YES;
//        }
//        else if([type isEqualToString:@"ccm_talk"])
//        {
//            if((0 <= [dev.img_ver caseInsensitiveCompare:@"13.09.01.00.00"]))
//                return YES;
//        }
//        else if([type isEqualToString:@"ccm_pwd_set"])
//        {
//            if(0 <= [dev.img_ver caseInsensitiveCompare:@"13.10.01.00.00"])
//                return YES;
//        }
//    }
//    return NO;
    
    /* ------- test ---------*/
    return YES;
}

- (NSString*)mipc_build_nid
{
    unsigned char   nid_data[64];
    long            nid_len = 0;
    struct nid_info nid = {0};
    if((nil != _shareKey) && _sid)
    {
        nid.flag = nid_flag_seq | nid_flag_id | nid_flag_sharekey;
        nid.seq = ++_seq;
        nid.id = _sid;
        nid.sharekey.len    = [_shareKey length];
        nid.sharekey.data   = (unsigned char*)[_shareKey UTF8String];

        nid_len = nid_encode(&nid, sizeof(nid_data), &nid_data[0]);
    }
    return (nid_len > 0)? [NSString stringWithUTF8String:(const char*)&nid_data[0]] : nil;
}

- (NSString*)mipc_build_nid_by_lid
{
    unsigned char   nid_data[64];
    long            nid_len = 0;
    struct nid_info nid = {0};

    if((nil != _shareKey) && _lid)
    {
        nid.flag = nid_flag_seq | nid_flag_id | nid_flag_sharekey | nid_flag_id_type;
        nid.seq = ++_seq;
        nid.id = _lid;
        nid.id_type = nid_id_type_lid;
        nid.sharekey.len    = [_shareKey length];
        nid.sharekey.data   = (unsigned char*)[_shareKey UTF8String];
        nid_len = nid_encode(&nid, sizeof(nid_data), &nid_data[0]);
    }

    return (nid_len > 0) ? [NSString stringWithUTF8String:(const char*)&nid_data[0]] : nil;
}

//- (void)check_msg_ret_result:(mjson_msg*)msg
//{
//    /*----debug print-------*/
//    if(request_log)
//    {
//        char *nsdata = malloc(20480);
//        if(nsdata)
//        {
//            json_encode(msg.data, nsdata, 20480);
//            xNSLog([NSString stringWithUTF8String:nsdata],request_log);
//        }
//        free(nsdata);
//    }
//
//    if (msg && msg.data)
//    {
//        struct len_str s_result = {0};
//
//        [self get_result:msg.data result:&s_result];
//
//        if (s_result.len
//            &&((0 == len_str_casecmp_const(&s_result, "InvalidSession"))
//               || (0 == len_str_casecmp_const(&s_result, "accounts.sid.invalid"))
//               || (0 == len_str_casecmp_const(&s_result, "accounts.nid.invalid"))
//               || (0 == len_str_casecmp_const(&s_result, "accounts.lid.invalid"))
//               || (0 == len_str_casecmp_const(&s_result, "ccms.sess.invalid"))))
//        {
//            mcall_ctx_sign_in *ctx = [[mcall_ctx_sign_in alloc] init];
//            ctx.srv = _srv;
//            ctx.user = _user;
//            ctx.passwd = _passwd;
//            ctx.target = self;
//            [self sign_in:ctx];
//
//            msg.data = NULL;
//        }
//    }
//}

- (NSString *)mipcGetSrv:(NSString*)srv
                    user:(NSString*)user
                    cert:(NSString**)cert /* [out], can be NULL */
                    name:(NSString**)name /* [out], can be NULL */
                    pubk:(NSString**)pubk /* [out], can be NULL */
{
    /* url lenght not > 50 */
#define _dc(_c)         (_c - '0')
#define _dchttp()       _dc('h'),_dc('t'),_dc('t'),_dc('p'),_dc(':'),_dc('/'),_dc('/')
    //#define _dchttp()       _dc('h'),_dc('t'),_dc('t'),_dc('p'),_dc('s'),_dc(':'),_dc('/'),_dc('/')
#define _dchttp3w()     _dchttp(),_dc('w'),_dc('w'),_dc('w'),_dc('.')
#define _dchttpes0()    _dchttp(),_dc('e'),_dc('s'),_dc('0'),_dc('.')
#define _dcdotcom(_s)   _dc('.'),_dc('c'),_dc('o'),_dc('m')
#define _dcdotcomcmipggw() _dcdotcom(_s),_dc('/'),_dc('c'),_dc('m'),_dc('i'),_dc('p'),_dc('c'),_dc('g'),_dc('w')
#define _dcdotcmipggw() _dc('/'),_dc('c'),_dc('m'),_dc('i'),_dc('p'),_dc('c'),_dc('g'),_dc('w')
#define _dcdotcomces()  _dcdotcom(_s),_dc('/'),_dc('c'),_dc('e'),_dc('s')
#define _dlens(_s)      {sizeof(_s) - 1, &_s[0]}
#define _dlenslist(_list) {sizeof(_list)/sizeof(_list[0]), &_list[0]}
    
    //    static char s_mipcgw_old[] = {_dchttpes0(),_dc('m'),_dc('i'),_dc('p'),_dc('c'),_dc('g'),_dc('w'),_dcdotcomcmipggw(),0};
    //    static char s_mipcgw[] = {_dchttpes0(),_dc('m'),_dc('i'),_dc('p'),_dc('c'),_dc('g'),_dc('w'),_dcdotcomces(),0};
    
    /*-----new first-----*/
    static char s_54[] =  {_dchttp(), _dc('5'), _dc('4'), _dc('.'), _dc('1'), _dc('5'), _dc('3'), _dc('.'), _dc('8'), _dc('2'), _dc('.'), _dc('1'), _dc('0'), _dc('7'), _dc(':'), _dc('7'), _dc('0'), _dc('8'), _dc('0'), _dcdotcmipggw(), 0};
    static char s_96[] =  {_dchttp(), _dc('2'), _dc('0'), _dc('9'), _dc('.'), _dc('1'), _dc('3'), _dc('3'), _dc('.'), _dc('2'), _dc('1'), _dc('2'),_dc('.'), _dc('1'), _dc('7'), _dc('0'), _dc(':'), _dc('7'), _dc('0'), _dc('8'), _dc('0'), _dcdotcmipggw(), 0};
    static char s_49[] =  {_dchttp(), _dc('1'), _dc('4'), _dc('9'), _dc('.'), _dc('2'), _dc('0'), _dc('2'), _dc('.'), _dc('2'), _dc('0'), _dc('1'),_dc('.'), _dc('8'), _dc('7'), _dc(':'), _dc('7'), _dc('0'), _dc('8'), _dc('0'), _dcdotcmipggw(), 0};
    static char s_58[] =  {_dchttp(), _dc('5'), _dc('8'), _dc('.'), _dc('6'), _dc('1'), _dc('.'), _dc('1'),_dc('5'), _dc('3'), _dc('.'), _dc('2'), _dc('3'), _dc('0'), _dc(':'), _dc('7'), _dc('0'), _dc('8'), _dc('0'), _dcdotcmipggw(), 0};
    
    /*-----new first-----*/
    
    /*-----change-----*/
    static char s_61ping[] = {_dchttp(), _dc('6'), _dc('1'), _dc('.'), _dc('1'), _dc('4'), _dc('7'), _dc('.'), _dc('1'), _dc('0'), _dc('9'), _dc('.'), _dc('9'), _dc('2'), _dc(':'), _dc('7'), _dc('0'), _dc('8'), _dc('0'), _dcdotcmipggw(), 0};
    
    static char s_mipcgw_new[]  = {_dchttp3w(), _dc('m'),_dc('i'),_dc('p'),_dc('c'),_dc('m'), _dcdotcom(), _dc(':'), _dc('7'), _dc('0'), _dc('8'), _dc('0'), _dcdotcmipggw(), 0};
    static char s0_mipcgw[] = {_dchttp(), _dc('s'), _dc('0'), _dc('.'), _dc('m'),_dc('i'),_dc('p'),_dc('c'),_dc('g'), _dc('w'), _dcdotcomcmipggw(), 0};
    /*-----change-----*/
    
    
    static char s_google[]      = {_dchttp3w(),_dc('g'),_dc('o'),_dc('o'),_dc('g'),_dc('l'),_dc('e'),_dcdotcom(),0};
    static char s_apple[]       = {_dchttp3w(),_dc('a'),_dc('p'),_dc('p'),_dc('l'),_dc('e'),_dcdotcom(),0};
    static char s_microsoft[]   = {_dchttp3w(),_dc('m'),_dc('i'),_dc('c'),_dc('r'),_dc('o'),_dc('s'),_dc('o'),_dc('f'),_dc('t'),_dcdotcom(),0};
    static char s_yahoo[]       = {_dchttp3w(),_dc('y'),_dc('a'),_dc('h'),_dc('o'),_dc('o'),_dcdotcom(),0};
    
    static char s_mipcm_ccm[]   = {_dchttp3w(),_dc('m'),_dc('i'),_dc('p'),_dc('c'),_dc('m'),_dcdotcom(),_dc('/'),_dc('c'),_dc('c'),_dc('m'),0};
    
    static struct len_str s_list_active[] =
    {
        {0},_dlens(s_54),_dlens(s_96), _dlens(s_49), _dlens(s_58)
    },
    s_list_backup[] =
    {
        _dlens(s_61ping), _dlens(s_mipcgw_new), _dlens(s0_mipcgw)
    },
    s_list_3rd[] =
    {
        _dlens(s_google),_dlens(s_apple),_dlens(s_microsoft),_dlens(s_yahoo)
    },
    s_list_other[] =
    {
        _dlens(s_mipcm_ccm)
    };
    
    static struct
    {
        unsigned long   counts;
        struct len_str  *list;
    }s_list[] = {_dlenslist(s_list_active), _dlenslist(s_list_backup), _dlenslist(s_list_3rd),_dlenslist(s_list_other)};
    
    static long s_list_inited;
    
    if(0 == s_list_inited)
    {
        char        *s;
        long        i, j, k, len;
        s_list_inited = 1;
        for(i = 0; i < (sizeof(s_list)/sizeof(s_list[0])); ++i)
        {
            for(j = 0; j < s_list[i].counts; ++j)
            {
                if (0 == s_list[i].list[j].len) continue;
                len = s_list[i].list[j].len;
                s = s_list[i].list[j].data;
                for(k = 0; k < len; ++k){ s[k] += '0'; }
            }
        }
        s_list_inited = 1;
    }
    
    if(cert && *cert){ *cert = nil; };
    if(pubk && *pubk){ *pubk = nil; };
    
    NSString    *curSrv = nil;
    if((nil == srv) || (0 == srv.length))
    {/* get default server */
        unsigned long       counts;
        long                i, network_working;
        struct json_object  *signal_item = NULL, *servers = NULL, *eservers = NULL, *signal = NULL;
        struct len_str      *list = NULL, s_cert = {0};
        
        /* build encrypt sys info */
        struct len_str      s_dh_prime = {len_str_def_const(dh_default_prime)},
        s_dh_root = {len_str_def_const(dh_default_root)},
        s_dh_es_pubk = {len_str_def_const("310105909413485164588026905566175959")};
        struct dh_mod       *es_dh_mod = dh_create(&s_dh_prime, &s_dh_root);
        struct len_str      *s_dh_pubk = es_dh_mod?dh_get_public_key(es_dh_mod):NULL,
        *s_dh_share_key = es_dh_mod?dh_get_share_key(es_dh_mod, &s_dh_es_pubk):NULL;
        NSString            *exParams = nil, *encode_sys = s_dh_share_key?MIPC_BuildEncryptSysInfo(user, [NSString stringWithUTF8String:s_dh_share_key->data]):nil;
        
        if(encode_sys)
        {
            exParams = [NSString stringWithFormat:@",param:[{name:\"%s\",value:\"%s\"},{name:\"%s\",value:\"%s\"},{name:\"%s\",value:\"%s\"},{name:\"%s\",value:\"%s\"}]",
                        "uctx", encode_sys?encode_sys.UTF8String:"",
                        "root", s_dh_root.data,
                        "prime", s_dh_prime.data,
                        "pubk", s_dh_pubk?s_dh_pubk->data:""];
        }
        
        if(es_dh_mod)
        {
            dh_destroy(es_dh_mod); es_dh_mod = NULL;
        };
        
        /* get cache sever ip */
        struct mipci_conf *conf = MIPC_ConfigLoad();
        struct len_str ip = {0};
        char tempip[50];
        
        if (conf && conf->exSrv.len)/* current exsrv url lenght never > 50*/
        {
            ip.len = conf->exSrv.len;
            memcpy(tempip, conf->exSrv.data, 50);
            ip.data = tempip;
        }
        s_list_active[0] = ip;
        
        /* get server info */
        for(int step = 0; step < 2; ++step)
        {
            if(step)
            {/* check network connection status */
                network_working = 0;
                for(i = 0; i < (sizeof(s_list_3rd)/sizeof(s_list_3rd[0])); ++i)
                {
                    NSData *contentData = [self download_url:[NSString stringWithUTF8String:s_list_3rd[i].data] timeout:30];
                    
                    if(contentData && contentData.length)
                    {
                        network_working = 1;
                        break;
                    }
                }
                if(0 == network_working)
                {/* netowrk not working */
                    break;
                }
                counts = (sizeof(s_list_backup)/sizeof(s_list_backup[0]));
                list = s_list_backup;
            }
            else
            {
                counts = (sizeof(s_list_active)/sizeof(s_list_active[0]));
                list = s_list_active;
            }
            
            for(i = 0; i < counts; ++i)
            {
                if (0 == list[i].len)
                {
                    continue;
                }
                
                if (i > 0)
                {
                    struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
                    
                    if(conf && (*conf).exSrv.len)
                    {
                        conf_new = *conf;
                        conf_new.exSrv.len = 0;
                        conf_new.exSrv.data = nil;
                        
                        MIPC_ConfigSave(&conf_new);
                    }
                }
                
                mjson_msg *ipcgw_msg = [self call:(self.app.developerOption.portalServer.length != 0) ? (self.app.developerOption.portalServer) :[NSString stringWithFormat:@"%s", list[i].data]
                                               to:nil
                                        to_handle:0
                                             mqid:0
                                      from_handle:0
                                             type:@"cmipcgw_get_req"
                                         dataJson:[NSString stringWithFormat: @"{client:{mode:\"user\",id:\"%@\"%@}}", user, exParams?exParams:@""]
                                          timeout:30];
                
                if(ipcgw_msg)
                {
                    struct json_object *jsonObj = ipcgw_msg.data;
                    /* prepare server list */
                    servers = json_get_child_by_name(jsonObj, NULL, len_str_def_const("server")),
                    /* get cert */
                    json_get_child_string(jsonObj, "cert", &s_cert);
                    
                    /* home&faq url get */
                    struct json_object *param_obj = json_get_child_by_name(servers, NULL, len_str_def_const("param"));
                    NSString *home_url = json_get_old_field_string(param_obj, len_str_def_const("u_home"));
                    NSString *faq_url = json_get_old_field_string(param_obj, len_str_def_const("faq_url"));
                    NSString *vimtag_user = json_get_old_field_string(param_obj, len_str_def_const("t_a"));
                    NSString *vimtag_pwd = json_get_old_field_string(param_obj, len_str_def_const("t_p"));
                    NSString *scene_open = json_get_old_field_string(param_obj, len_str_def_const("f_profile"));
                    NSString *accessory_open = json_get_old_field_string(param_obj, len_str_def_const("f_exdev"));
                    NSString *web_mode = json_get_old_field_string(param_obj, len_str_def_const("f_web"));
                    NSString *f_ticket = json_get_old_field_string(param_obj, len_str_def_const("f_ticket"));
                    NSString *f_log = json_get_old_field_string(param_obj, len_str_def_const("f_log"));
                    NSString *log_url = json_get_old_field_string(param_obj,len_str_def_const("u_log"));
                    NSString *feedback_url = json_get_old_field_string(param_obj, len_str_def_const("u_ticket"));
                    NSString *f_ota = json_get_old_field_string(param_obj, len_str_def_const("f_ota"));
                    NSString *f_mall = json_get_old_field_string(param_obj, len_str_def_const("f_mall"));
                    NSString *u_privacy = json_get_old_field_string(param_obj, len_str_def_const("u_privacy"));

                    NSUserDefaults *urlUserDefaults = [NSUserDefaults standardUserDefaults];
                    
//                    if (vimtag_user.length && vimtag_pwd.length) {
                        [urlUserDefaults setObject:vimtag_user forKey:@"t_a"];
                        [urlUserDefaults setObject:vimtag_pwd forKey:@"t_p"];
//                    }
                    [urlUserDefaults setObject:home_url forKey:@"u_home"];
                    [urlUserDefaults setObject:faq_url forKey:@"faq_url"];
                    [urlUserDefaults setObject:scene_open forKey:@"f_profile"];
                    [urlUserDefaults setObject:accessory_open forKey:@"f_exdev"];
                    [urlUserDefaults setObject:web_mode forKey:@"f_web"];
                    [urlUserDefaults setObject:f_ticket forKey:@"f_ticket"];
                    [urlUserDefaults setObject:f_log forKey:@"f_log"];
                    [urlUserDefaults setObject:log_url forKey:@"u_log"];
                    [urlUserDefaults setObject:feedback_url forKey:@"u_ticket"];
                    [urlUserDefaults setObject:f_ota forKey:@"f_ota"];
                    [urlUserDefaults setObject:f_mall forKey:@"f_mall"];
                    [urlUserDefaults setObject:u_privacy forKey:@"u_privacy"];
                    [urlUserDefaults synchronize];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProductInformationChange" object:nil];

                    if(0 == s_cert.len)
                    {
                        struct json_object *param_obj = json_get_child_by_name(jsonObj, NULL, len_str_def_const("param")),
                        *cert_obj = param_obj?json_get_field(jsonObj, len_str_def_const("cert")):NULL;
                        
                        if(cert_obj && (ejot_array != cert_obj->type) && (ejot_object != cert_obj->type))
                        {
                            s_cert = cert_obj->v.string;
                        }
                    }
                    
                    /* decode cert */
                    if(s_cert.len)
                    {
                        struct len_str      s_srv_pubk = {0}, s_srv_name = {0}, s_srv_ref_user = {0};
                        unsigned long       pubk_bits = 0, pubk_len = 0;
                        unsigned char       *pubk = mlic_pubk_query(mlic_pubk_id_ccms_root, &pubk_bits, &pubk_len);
                        eservers = mlic_cert_decode(pubk_bits, pubk_len, pubk, s_cert.len, (unsigned char*)s_cert.data);
                        if(eservers)
                        {
                            json_get_child_string(eservers, "user", &s_srv_ref_user);
                        }
                        if((NULL == eservers)
                           || (s_srv_ref_user.len != user.length)
                           || strncasecmp((const char*)s_srv_ref_user.data, (const char*)user.UTF8String, s_srv_ref_user.len))
                        {
                            if(eservers){ mlic_destroy(eservers); eservers = NULL; };
                        }
                        else
                        {
                            json_get_child_string(eservers, "name", &s_srv_name);
                            json_get_child_string(eservers, "pubk", &s_srv_pubk);
                            if(cert && s_cert.len)
                            {
                                *cert = [NSString stringWithUTF8String:s_cert.data];
                            }
                            if(name && s_srv_name.len)
                            {
                                *name = [NSString stringWithUTF8String:s_srv_name.data];
                            }
                            if(pubk && s_srv_pubk.len)
                            {/* set pubk failed */
                                
                                NSString        *type = @"RSA PUBLIC KEY";
                                long            pemk_len = 0;
                                unsigned long   buf_size = (s_srv_pubk.len * 4 / 3) + (s_srv_pubk.len / 48) + 512;
                                unsigned char   *buf = (unsigned char*)malloc(buf_size);
                                
                                if((NULL == buf)
                                   || (0 >= (pemk_len = mlic_pemk_encode(s_srv_pubk.len, (unsigned char*)s_srv_pubk.data, type.length, (char*)type.UTF8String, buf_size, buf))))
                                {
                                    if(buf)
                                    {
                                        free(buf);
                                    };
                                }
                                
                                *pubk = *buf;
                                free(buf);
                            }
                        }
                    }
                    
                    /* search http signal server */
                    signal = (eservers || servers)?json_get_child_by_name(eservers?eservers:servers, NULL, len_str_def_const("signal")):NULL;
                    
                    if(signal && (ejot_array == signal->type) && signal->v.array.counts)
                    {
                        signal_item = signal->v.array.list;
                        do
                        {
                            if(0 == strncasecmp(signal_item->v.string.data,"https",5))
                            {
                                const char *entra_data = list[i].data;
                                const char *signal_data = signal_item->v.string.data;
                                /* cache entrance ip */
                                if(entra_data && strlen(entra_data) > 0){
                                    char entra_ip[50];
                                    
                                    struct url_scheme entra_scheme;
                                    url_parse((char*)entra_data, (int)strlen(entra_data), &entra_scheme);
                                    
                                    NSString *hostString = [NSString stringWithFormat:@"%s", entra_scheme.host.data];
                                    const char *entra_host = hostString.length >= entra_scheme.host.len ? [hostString substringToIndex:entra_scheme.host.len].UTF8String : nil;
                                    
                                    char *entra_later = entra_scheme.path.data;
                                    
                                    struct hostent *entra_addr = entra_host == nil ? nil : gethostbyname(entra_host);
                                    char entra_buf[INET6_ADDRSTRLEN];
                                    
                                    if ((entra_addr != NULL)&&(NULL != inet_ntop (entra_addr->h_addrtype, *entra_addr->h_addr_list, entra_buf, sizeof (entra_buf))))
                                    {
                                        sprintf(entra_ip, "https://%s%s",entra_buf, entra_later);
                                        
                                        struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
                                        
                                        if(conf)
                                        {
                                            conf_new = *conf;
                                        }
                                        
                                        conf_new.exSrv.len = (uint32_t)strlen(entra_data);
                                        conf_new.exSrv.data =(char *) entra_data;
                                        
                                        MIPC_ConfigSave(&conf_new);
                                    }
                                }
                                
                                
                                if(signal_data && strlen(signal_data) > 0){
                                    /*cache server ip*/
                                    char signal_ip[50];
                                    /*-----new-----*/
                                    struct url_scheme signal_scheme;
                                    url_parse((char*)signal_data, (int)strlen(signal_data), &signal_scheme);
                                    
                                    NSString *hostString = [NSString stringWithFormat:@"%s", signal_scheme.host.data];
                                    const char *signal_host = hostString.length >= signal_scheme.host.len ? [hostString substringToIndex:signal_scheme.host.len].UTF8String : nil;
                                    
                                    char *signal_later = signal_scheme.path.data;
                                    
                                    //                                    sscanf(url+7, "%s%s", host, later);
                                    struct hostent *signal_addr = signal_host == nil ? nil : gethostbyname(signal_host);
                                    char signal_buf[INET6_ADDRSTRLEN];
                                    
                                    if ((signal_addr != NULL)&&(NULL != inet_ntop (signal_addr->h_addrtype, *signal_addr->h_addr_list, signal_buf, sizeof (signal_buf))))
                                    {
                                        sprintf(signal_ip, "https://%s%s",signal_buf, signal_later);
                                        /*-----new-----*/
                                        
                                        struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
                                        
                                        if(conf)
                                        {
                                            conf_new = *conf;
                                        }
                                        
                                        conf_new.exSignal_Srv.len = (UInt32)strlen(signal_data);
                                        conf_new.exSignal_Srv.data =(char *)signal_data;
                                        MIPC_ConfigSave(&conf_new);
                                        
                                    }
                                }
                                
                                curSrv = [NSString stringWithUTF8String:signal_item->v.string.data];
                                return curSrv;
                            }
                        } while ((signal_item = signal_item->in_parent.next) != signal->v.array.list);
                        
                        do
                        {
                            if(0 == strncasecmp(signal_item->v.string.data,"http",4))
                            {
                                const char *entra_data = list[i].data;
                                const char *signal_data = signal_item->v.string.data;
                                /* cache entrance ip */
                                if(entra_data && strlen(entra_data) > 0){
                                    char entra_ip[50];
                                    
                                    struct url_scheme entra_scheme;
                                    url_parse((char*)entra_data, (int)strlen(entra_data), &entra_scheme);
                                    
                                    NSString *hostString = [NSString stringWithFormat:@"%s", entra_scheme.host.data];
                                    const char *entra_host = hostString.length >= entra_scheme.host.len ? [hostString substringToIndex:entra_scheme.host.len].UTF8String : nil;
                                    
                                    char *entra_later = entra_scheme.path.data;
                                    
                                    struct hostent *entra_addr = entra_host == nil ? nil : gethostbyname(entra_host);
                                    char entra_buf[INET6_ADDRSTRLEN];
                                    
                                    if ((entra_addr != NULL)&&(NULL != inet_ntop (entra_addr->h_addrtype, *entra_addr->h_addr_list, entra_buf, sizeof (entra_buf))))
                                    {
                                        sprintf(entra_ip, "http://%s%s",entra_buf, entra_later);
                                        
                                        struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
                                        
                                        if(conf)
                                        {
                                            conf_new = *conf;
                                        }
                                        
                                        conf_new.exSrv.len = (uint32_t)strlen(entra_data);
                                        conf_new.exSrv.data =(char *) entra_data;
                                        
                                        MIPC_ConfigSave(&conf_new);
                                    }
                                }
                                
                                
                                if(signal_data && strlen(signal_data) > 0){
                                    /*cache server ip*/
                                    char signal_ip[50];
                                    /*-----new-----*/
                                    struct url_scheme signal_scheme;
                                    url_parse((char*)signal_data, (int)strlen(signal_data), &signal_scheme);
                                    
                                    NSString *hostString = [NSString stringWithFormat:@"%s", signal_scheme.host.data];
                                    const char *signal_host = hostString.length >= signal_scheme.host.len ? [hostString substringToIndex:signal_scheme.host.len].UTF8String : nil;
                                    
                                    char *signal_later = signal_scheme.path.data;
                                    
                                    //                                    sscanf(url+7, "%s%s", host, later);
                                    struct hostent *signal_addr = signal_host == nil ? nil : gethostbyname(signal_host);
                                    char signal_buf[INET6_ADDRSTRLEN];
                                    
                                    if ((signal_addr != NULL)&&(NULL != inet_ntop (signal_addr->h_addrtype, *signal_addr->h_addr_list, signal_buf, sizeof (signal_buf))))
                                    {
                                        sprintf(signal_ip, "http://%s%s",signal_buf, signal_later);
                                        /*-----new-----*/
                                        
                                        struct mipci_conf *conf = MIPC_ConfigLoad(), conf_new = {0};
                                        
                                        if(conf)
                                        {
                                            conf_new = *conf;
                                        }
                                        
                                        conf_new.exSignal_Srv.len = (UInt32)strlen(signal_data);
                                        conf_new.exSignal_Srv.data =(char *)signal_data;
                                        MIPC_ConfigSave(&conf_new);
                                        
                                    }
                                }
                                
                                curSrv = [NSString stringWithUTF8String:signal_item->v.string.data];
                                return curSrv;
                            }
                        } while ((signal_item = signal_item->in_parent.next) != signal->v.array.list);
                        
                        
                    }
                    
                    if(eservers)
                    {
                        mlic_destroy(eservers);
                    }
                }
            }
        }
    }
    else
    {
        curSrv = [NSString stringWithString:srv];
    }
    
    if((nil == curSrv) || (0 == curSrv.length))
    {
        curSrv = [NSString stringWithUTF8String:&s_mipcm_ccm[0]];
    }
    
    return curSrv;
}

- (long)cacs_dh_req_asyn:(NSString*)srv
              usingBlock:(void(^)(NSString* result,  NSString *outShareKey, int64_t outTid, int64_t outLid))block

{
    //    *outLid      = 0;
    //    *outTid      = 0;
    //    *outShareKey = nil;
    
    /* cacs_dh_req */
    
    struct len_str  str_prime = {len_str_def_const(dh_default_prime)};
    struct len_str  str_root = {len_str_def_const(dh_default_root)};
    struct dh_mod   *dh_mod = dh_create(&str_prime, &str_root);
    struct len_str  *pub_key = dh_get_public_key(dh_mod);
    
    [self call_asyn:srv to:nil to_handle:0 mqid:0 from_handle:0 type:@"cacs_dh_req" dataJson:[NSString stringWithFormat:@"{bnum_prime:\"%s\",root_num:\"%s\",key_a2b:\"%*.*s\", tid:1}", dh_default_prime, dh_default_root, 0, (int)pub_key->len, pub_key->data] timeout: 30 usingBlock:^(mjson_msg *dh_ack_msg) {
        struct json_object *dh_ack = dh_ack_msg.data;
        struct len_str  *share_key = {0}, result_str = {0};
        struct len_str  key_b2a = {0};
        
        int64_t outLid = 0,  outTid = 0;
        NSString     *outShareKey = nil;
        
        if((NULL == dh_ack)
           || json_get_child_string(dh_ack_msg.data, "result", &result_str)
           || result_str.len)
        {
            NSString *result = result_str.len ? [NSString stringWithUTF8String:result_str.data] : nil;
            dh_destroy(dh_mod);
            block(result, nil, 0, 0);
            //            return result;
        }
        else
        {
            json_get_child_string(dh_ack, "key_b2a", &key_b2a);
            json_get_child_int64(dh_ack, "lid", &outLid);
            json_get_child_int64(dh_ack, "tid", &outTid);
            
            share_key = dh_get_share_key(dh_mod, &key_b2a);
            if (share_key && share_key->data) {
                outShareKey = [[NSString alloc] initWithBytes:share_key->data length:share_key->len encoding:NSUTF8StringEncoding];
            }
            dh_destroy(dh_mod);
            block(nil, outShareKey, outTid, outLid);
            //        return nil;
        }
    }];
    return 0;
}

#pragma mark-
#pragma mark- mmq
- (void)mmq_task_create:(NSString*)srv usingBlock:(void(^)(mjson_msg *msg))block
{
#undef func_format_s
#undef func_format
#define func_format_s   "mmq_task_create(self[%p], srv["NSString_format_s"])"
#define func_format()   self, NSString_format(srv)
    
    if(nil == srv)
    {
        if (block) {
            block(nil);
        }
        print_log0(err, "failed with invalid param.");
        return;
    }
    
    if (_mmq_task) {
        _mmq_task = nil;
    }
    
    //special definition to be used in block
    //create mmq_task
    _mmq_task = [[mmq_task alloc] init];
    _mmq_task.isRun = YES;
    _mmq_task.srv = [[NSString alloc] initWithString:srv];
    
    __weak typeof(self) weakSelf = self;
    
    self.mmq_stop = NO;
    self.mmqBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        struct json_object  *dataObj;
        mjson_msg           *mmq_create_ret_msg;
        struct len_str      s_qid = {0};
        
        mjson_msg           *mmq_pick_ret_msg;
        struct len_str      s_result;
        
        while(weakSelf.mmq_task.isRun && !_mmq_stop)
        {
            //mmq_create
            if(nil == weakSelf.mmq_task.qid)
            {
                //get return value of mmq_create in order to get qid value
                mmq_create_ret_msg = [weakSelf call:srv
                                                 to:nil
                                          to_handle:0
                                               mqid:0
                                        from_handle:0
                                               type:@"mmq_create"
                                           dataJson:[NSString stringWithFormat:@"{timeout:\"%d\"}", 60000]
                                            timeout:60+30];
                
                if((nil == mmq_create_ret_msg)
                   || (NULL == mmq_create_ret_msg.json)
                   ||(NULL == (dataObj = json_get_child_by_name(mmq_create_ret_msg.json, NULL, len_str_def_const("data"))))
                   ||json_get_child_string(dataObj, "qid", &s_qid)
                   || (0 == s_qid.len)
                   || (nil == s_qid.data))
                {
                    print_log0(err, "failed when mmq-create");
                    //if fail, skip and continue next
                    mthread_sleep(5000);
                    continue;
                }
                else
                {
                    //set the value for qid of mmqTask
                    weakSelf.mmq_task.qid = [NSString stringWithUTF8String:s_qid.data];
                }
                
                //FIXME: main
                if((0 == [mmq_create_ret_msg.type caseInsensitiveCompare:@"mmq_create_ack"])
                   && (json_get_child_string(mmq_create_ret_msg.data, "result", &s_result) || (0 == s_result.len))
                   && (0 == json_get_child_string(mmq_create_ret_msg.data, "qid", &s_qid))
                   && (s_qid.len > 0))
                {
                    
                    if(
//                       weakSelf.srvVersion &&
                       (weakSelf.qid = [NSString stringWithUTF8String:s_qid.data])
//                       && (0 < [weakSelf.srvVersion compare:MIPC_MIN_VERSION_MESSAGE_PICK])
                       )
                    {
                        NSString *type = @"ccm_subscribe";
                        NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"\"},apns_type:\"%@\",apns_token:\"%@\",apns_token_prev:\"%@\"}", [weakSelf mipc_build_nid], [[NSBundle mainBundle] bundleIdentifier], weakSelf.device_token?weakSelf.device_token:@"", @""];
                        
                        if (!weakSelf.isNewSrv) {
                            [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
                        }
                        
                        mjson_msg *subscribe_msg = [weakSelf call:weakSelf.srv
                                                               to:nil
                                                        to_handle:0
                                                             mqid:weakSelf.qid
                                                      from_handle:[weakSelf createFromHandle]
                                                             type:type
                                                         dataJson:data_json
                                                          timeout:30];
                        
                        struct json_object  *dataObj;
                        struct len_str      result = {0};
                        dataObj = json_get_child_by_name(subscribe_msg.json, NULL, len_str_def_const("data"));
                        json_get_child_string(dataObj, "result", &result);
                        
                        if (0 == result.len)
                        {
                            NSLog(@"subscribe is success");
                            if (MNSubscribeFirst == _subscribeNumber) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshDeviceList" object:nil];
                                _subscribeNumber = MNSubscribeMore;
                            }
                        }
                    }
                    
                    NSLog(@"mmq_create req is result:[%s] qid:[%s]",s_result.len?s_result.data:"", s_qid.len?s_qid.data:NULL);
                }
                
                //continue other mission
                //after get the qid back, at the same time run mmq_pick
            }
            else
            {
                //mmq_pick
                NSString *url = [weakSelf build_url:srv to:0 to_handle:0 mqid:0 from_handle:0 type:@"mmq_pick" dataJson:[NSString stringWithFormat:@"{timeout:\"%d\",qid:\"%@\"}",300000,weakSelf.mmq_task.qid]];
                
                NSMutableURLRequest *mmq_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
                [mmq_request setHTTPMethod:@"GET"];
                [mmq_request setTimeoutInterval:((300000 / 1000) + 30)];
                self.mmq_data = [[NSMutableData alloc] init];
                
                self.mmq_connection = [[NSURLConnection alloc] initWithRequest:mmq_request delegate:self];
                self.mmq_downloading = YES;
                
                while(weakSelf.mmq_task.isRun && weakSelf.mmq_task.qid && self.mmq_downloading)
                {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                             beforeDate:[[NSDate alloc] initWithTimeIntervalSinceNow:3]];
                    
                }
#if TARGET_IPHONE_SIMULATOR
                NSLog(@"Recieve mmq:%@",[[NSString alloc] initWithData:self.mmq_data encoding:NSUTF8StringEncoding]);
#else
                if (self.app.developerOption.printLogSwitch) {
                    NSLog(@"Recieve mmq:%@",[[NSString alloc] initWithData:self.mmq_data encoding:NSUTF8StringEncoding]);
                }
                if (self.app.developerOption.saveLogSwitch) {
                    [self saveLogWithType:LOG_TYPE_REQUEST content:[[NSString alloc] initWithData:self.mmq_data encoding:NSUTF8StringEncoding]];
                }
#endif
                struct json_object *data_json = MIPC_DataTransformToJson(self.mmq_data);
                mmq_pick_ret_msg = [[mjson_msg alloc] initWithJson:data_json];
                
                //                mmq_pick_ret_msg =[weakSelf call:srv
                //                                                        to:0
                //                                                 to_handle:0
                //                                                      mqid:0
                //                                               from_handle:0
                //                                                      type:@"mmq_pick"
                //                                                  dataJson:[NSString stringWithFormat:@"{timeout:\"%d\",qid:\"%@\"}",
                //                                                            300000,
                //                                                            weakSelf.mmq_task.qid]
                //                                                   timeout:((300000 / 1000) + 30)];
                //check run or not
                if(!weakSelf.mmq_task.isRun || nil == weakSelf.mmq_task.qid)
                {/* finished */
                    print_log0(err, "mmq_pick ret nothing.");
                    break;
                }
                
                long is_pick_ack , pick_err;
                struct len_str      result = {0};
                
                is_pick_ack = mmq_pick_ret_msg && mmq_pick_ret_msg.type && [mmq_pick_ret_msg.type isEqualToString:@"mmq_pick_ack"];
                
                //check for whether the mmq_pick_ret_msg null or not
                if(is_pick_ack
                   || (nil == mmq_pick_ret_msg)
                   || (nil == mmq_pick_ret_msg.json)
                   || (nil == mmq_pick_ret_msg.data)
                   || (nil == mmq_pick_ret_msg.type))
                {
                    pick_err = (0 == is_pick_ack)
                    || json_get_child_string(mmq_pick_ret_msg.data, "result", &result)
                    || (result.len && len_str_cmp_const(&result, "0"));
                    
                    //send the message for call-back
                    if(weakSelf.mmq_task.isRun
                       && weakSelf.mmq_task.qid
                       && pick_err)
                    {
                        if (block) {
                            block(mmq_pick_ret_msg);
                        }
                    }
                    //print error
                    if(pick_err)
                    {
                        print_log1(err, "mmq_pick end with result[%s].", result.data);
                        //if error, destroy qid
                        weakSelf.mmq_task.qid = nil;
                        return;
                    }
                    
                    print_log0(debug, "get empty pick ack, continue.");
                    return;
                }
                
                /* mmq_pick has data callback */
                if(weakSelf.mmq_task.isRun
                   && weakSelf.mmq_task.qid
                   && mmq_pick_ret_msg.data)
                {
                    //FIXME: main
                    if (block) {
                        block(mmq_pick_ret_msg);
                    }
                }
                
                //if wrong, sleep thread
                if((nil == mmq_pick_ret_msg)
                   || (nil == mmq_pick_ret_msg.data)
                   || (nil == mmq_pick_ret_msg.type)
                   || ((0 == [mmq_pick_ret_msg.type caseInsensitiveCompare:@"mmq_pick_ack"])
                       && (0 == json_get_child_string(mmq_pick_ret_msg.data, "result", &s_result))
                       && s_result.len))
                {
                    for(int i = 0; (i < 50) && weakSelf.mmq_task.isRun; ++i)
                    {
                        mthread_sleep(100);
                    }
                }
            }
            
        }
        
    }];
    
    [self.mmqOperationQueue addOperation:_mmqBlockOperation];
    
}

//- (void)mmq_task_create:(NSString*)srv usingBlock:(void(^)(mjson_msg *msg))block
//{
//#undef func_format_s
//#undef func_format
//#define func_format_s   "mmq_task_create(self[%p], srv["NSString_format_s"])"
//#define func_format()   self, NSString_format(srv)
//    
//    if(nil == srv)
//    {
//        if (block) {
//            block(nil);
//        }
//        print_log0(err, "failed with invalid param.");
//        return;
//    }
//    
//    if (_mmq_task) {
//        _mmq_task = nil;
//    }
//    
//    //special definition to be used in block
//    //create mmq_task
//    _mmq_task = [[mmq_task alloc] init];
//    _mmq_task.isRun = YES;
//    _mmq_task.srv = [[NSString alloc] initWithString:srv];
//    
//    __weak typeof(self) weakSelf = self;
//    
//    self.mmq_stop = NO;
//    self.mmqBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
//        
//        mjson_msg           *mmq_pick_ret_msg;
//        struct len_str      s_result;
//        //continue other mission
//        //after get the qid back, at the same time run mmq_pick
//        //mmq_create
//        __block BOOL isSend = NO;
//        do {
//            if (!isSend) {
//
//             isSend = YES;
//                //get return value of mmq_create in order to get qid value
//                [weakSelf call_asyn:srv
//                                 to:nil
//                          to_handle:0
//                               mqid:0
//                        from_handle:0
//                               type:@"mmq_create"
//                           dataJson:[NSString stringWithFormat:@"{timeout:\"%d\"}", 60000] timeout:60+30
//                         usingBlock:^(mjson_msg *mmq_create_ret_msg) {
//                             struct json_object  *dataObj;
//                             struct len_str      s_qid = {0};
//                             struct len_str      s_result;
//                             
//                             if((nil == mmq_create_ret_msg)
//                                || (NULL == mmq_create_ret_msg.json)
//                                ||(NULL == (dataObj = json_get_child_by_name(mmq_create_ret_msg.json, NULL, len_str_def_const("data"))))
//                                ||json_get_child_string(dataObj, "qid", &s_qid)
//                                || (0 == s_qid.len)
//                                || (nil == s_qid.data))
//                             {
//                                 print_log0(err, "failed when mmq-create");
//                                 //if fail, skip and continue next
//                                 mthread_sleep(5000);
//                                 isSend = NO;
//                                 return ;
//                                 //                        continue;
//                             }
//
//                             //FIXME: main
//                             if((0 == [mmq_create_ret_msg.type caseInsensitiveCompare:@"mmq_create_ack"])
//                                && (json_get_child_string(mmq_create_ret_msg.data, "result", &s_result) || (0 == s_result.len))
//                                && (0 == json_get_child_string(mmq_create_ret_msg.data, "qid", &s_qid))
//                                && (s_qid.len > 0))
//                             {
//                                 
//                                 if(weakSelf.srvVersion
//                                    && (weakSelf.qid = [NSString stringWithUTF8String:s_qid.data])
//                                    && (0 < [weakSelf.srvVersion compare:MIPC_MIN_VERSION_MESSAGE_PICK]))
//                                 {
//                                     NSString *type = @"ccm_subscribe";
//                                     NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"\"},apns_type:\"%@\",apns_token:\"%@\",apns_token_prev:\"%@\"}", [weakSelf mipc_build_nid], [[NSBundle mainBundle] bundleIdentifier], weakSelf.device_token?weakSelf.device_token:@"", @""];
//                                     
//                                     if (!weakSelf.isNewSrv) {
//                                         [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
//                                     }
//                                     
//                                     
//                                     [weakSelf call_asyn:weakSelf.srv
//                                                      to:nil
//                                               to_handle:0
//                                                    mqid:weakSelf.qid
//                                             from_handle:[weakSelf createFromHandle]
//                                                    type:type
//                                                dataJson:data_json
//                                                 timeout:30
//                                              usingBlock:^(mjson_msg *subscribe_msg) {
//                                         struct json_object  *dataObj;
//                                         struct len_str      result = {0};
//                                         dataObj = json_get_child_by_name(subscribe_msg.json, NULL, len_str_def_const("data"));
//                                         json_get_child_string(dataObj, "result", &result);
//                                         
//                                         if (0 == result.len)
//                                         {
//                                             NSLog(@"subscribe is success");
//                                         }
//                                                  
//                                        //set the value for qid of mmqTask
//                                        weakSelf.mmq_task.qid = [NSString stringWithUTF8String:s_qid.data];
//                                         NSLog(@"mmq_create req is result:[%s] qid:[%s]",s_result.len?s_result.data:"", s_qid.len?s_qid.data:NULL);
//                                     }];
//                                 }
//                                 else
//                                 {
//                                     //set the value for qid of mmqTask
//                                     weakSelf.mmq_task.qid = [NSString stringWithUTF8String:s_qid.data];
//                                     NSLog(@"mmq_create req is result:[%s] qid:[%s]",s_result.len?s_result.data:"", s_qid.len?s_qid.data:NULL);
//                                 }
//                             }
//                             
//                         }];
//            }
//        } while (nil == weakSelf.mmq_task.qid);
//        
//        while(weakSelf.mmq_task.isRun && !_mmq_stop && weakSelf.mmq_task.qid)
//        {
//                        //mmq_pick
//            NSString *url = [weakSelf build_url:srv to:0 to_handle:0 mqid:0 from_handle:0 type:@"mmq_pick" dataJson:[NSString stringWithFormat:@"{timeout:\"%d\",qid:\"%@\"}",300000,weakSelf.mmq_task.qid]];
//            
//            NSMutableURLRequest *mmq_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//            [mmq_request setHTTPMethod:@"GET"];
//            [mmq_request setTimeoutInterval:((300000 / 1000) + 30)];
//            self.mmq_data = [[NSMutableData alloc] init];
//            
//            self.mmq_connection = [[NSURLConnection alloc] initWithRequest:mmq_request delegate:self];
//            self.mmq_downloading = YES;
//            
//            while(weakSelf.mmq_task.isRun && weakSelf.mmq_task.qid && self.mmq_downloading)
//            {
//                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                                         beforeDate:[[NSDate alloc] initWithTimeIntervalSinceNow:3]];
//                
//            }
//            
//            struct json_object *data_json = MIPC_DataTransformToJson(self.mmq_data);
//            mmq_pick_ret_msg = [[mjson_msg alloc] initWithJson:data_json];
//            
//            //                mmq_pick_ret_msg =[weakSelf call:srv
//            //                                                        to:0
//            //                                                 to_handle:0
//            //                                                      mqid:0
//            //                                               from_handle:0
//            //                                                      type:@"mmq_pick"
//            //                                                  dataJson:[NSString stringWithFormat:@"{timeout:\"%d\",qid:\"%@\"}",
//            //                                                            300000,
//            //                                                            weakSelf.mmq_task.qid]
//            //                                                   timeout:((300000 / 1000) + 30)];
//            //check run or not
//            if(!weakSelf.mmq_task.isRun || nil == weakSelf.mmq_task.qid)
//            {/* finished */
//                print_log0(err, "mmq_pick ret nothing.");
//                break;
//            }
//            
//            long is_pick_ack , pick_err;
//            struct len_str      result = {0};
//            
//            is_pick_ack = mmq_pick_ret_msg && mmq_pick_ret_msg.type && [mmq_pick_ret_msg.type isEqualToString:@"mmq_pick_ack"];
//            
//            //check for whether the mmq_pick_ret_msg null or not
//            if(is_pick_ack
//               || (nil == mmq_pick_ret_msg)
//               || (nil == mmq_pick_ret_msg.json)
//               || (nil == mmq_pick_ret_msg.data)
//               || (nil == mmq_pick_ret_msg.type))
//            {
//                pick_err = (0 == is_pick_ack)
//                || json_get_child_string(mmq_pick_ret_msg.data, "result", &result)
//                || (result.len && len_str_cmp_const(&result, "0"));
//                
//                //send the message for call-back
//                if(weakSelf.mmq_task.isRun
//                   && weakSelf.mmq_task.qid
//                   && pick_err)
//                {
//                    if (block) {
////                        struct json_object *items = json_get_child_by_name(mmq_pick_ret_msg.data, NULL, len_str_def_const("items"));
////                        
////                        if(items && items->type == ejot_array && items->v.array.counts)
////                        {
////                            struct json_object *item = items->v.array.list;
////                            
////                            for (int i = 0; i < items->v.array.counts; i++,item = items->in_parent.next)
////                            {
////                                mdev_msg *msg = [[mdev_msg alloc] initWithJson:item];
////                                
////                                NSMutableArray *msg_listen_arr = [_msg_listen_arr mutableCopy];
////                                for(mcall_ctx_dev_msg_listener_add *lis_msg in msg_listen_arr)
////                                {
////                                    if(msg && msg.sn && msg.type && ([lis_msg.type rangeOfString:msg.type].location != NSNotFound) && lis_msg.target)
////                                    {
////                                        if ([lis_msg.target respondsToSelector:lis_msg.on_event]) {
////                                            [lis_msg.target performSelectorOnMainThread:lis_msg.on_event withObject:msg waitUntilDone:YES];
////                                        }
////                                    }
////                                }
////                            }
////                        }
//
//                        block(mmq_pick_ret_msg);
//                    }
//                }
//                //print error
//                if(pick_err)
//                {
//                    print_log1(err, "mmq_pick end with result[%s].", result.data);
//                    //if error, destroy qid
//                    weakSelf.mmq_task.qid = nil;
//                    return;
//                }
//                
//                print_log0(debug, "get empty pick ack, continue.");
//                return;
//            }
//            
//            /* mmq_pick has data callback */
//            if(weakSelf.mmq_task.isRun
//               && weakSelf.mmq_task.qid
//               && mmq_pick_ret_msg.data)
//            {
//                //FIXME: main
//                if (block) {
//                    block(mmq_pick_ret_msg);
//                }
//            }
//            
//            //if wrong, sleep thread
//            if((nil == mmq_pick_ret_msg)
//               || (nil == mmq_pick_ret_msg.data)
//               || (nil == mmq_pick_ret_msg.type)
//               || ((0 == [mmq_pick_ret_msg.type caseInsensitiveCompare:@"mmq_pick_ack"])
//                   && (0 == json_get_child_string(mmq_pick_ret_msg.data, "result", &s_result))
//                   && s_result.len))
//            {
//                for(int i = 0; (i < 50) && weakSelf.mmq_task.isRun; ++i)
//                {
//                    mthread_sleep(100);
//                }
//            }
//        }
//        
//        
//    }];
//    
//    [self.mmqOperationQueue addOperation:_mmqBlockOperation];
//    
//}

- (void)mmq_task_destory:(mmq_task*)mmqTask
{
    [self.mmq_connection cancel];
    [self.mmqBlockOperation cancel];
    [self.mmqOperationQueue cancelAllOperations];
    self.mmqBlockOperation = nil;
    self.mmqOperationQueue = nil;
    self.mmq_stop = YES;
    
    
    if (mmqTask.srv && mmqTask.qid)
    {
        [self call_asyn:mmqTask.srv
                     to:nil
              to_handle:0
                   mqid:mmqTask.qid
            from_handle:[self createFromHandle]
                   type:@"mmq_destroy"
               dataJson:[NSString stringWithFormat:@"{qid:\"%@\"}", mmqTask.qid]
                timeout:0
             usingBlock:^(mjson_msg *msg) {
                 
                 struct json_object  *dataObj;
                 struct len_str      result = {0};
                 dataObj = json_get_child_by_name(msg.json, NULL, len_str_def_const("data"));
                 json_get_child_string(dataObj, "result", &result);
                 
                 NSLog(@"%lu",result.len);
             }];
    }
    ////FIXME: has to test
    //cancel run the mmq_pick
    mmqTask.isRun = NO;
}

#pragma mark - connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
     if(_mmq_task)
    {
        [self.mmq_data appendData:data];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithor:(NSError *)error
{
    if(_mmq_task)
    {
        self.mmq_downloading = NO;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(_mmq_task)
    {
        self.mmq_downloading = NO;
    }
}

- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection __unused *)connection
{
    return NO;
}

#pragma mark-
#pragma mark- interface for outside
- (long)create_nid:(mcall_ctx_sign_in *)ctx
             block:(void(^)(mcall_ret_sign_in *ret))block
{
    __weak typeof(self) weakSelf = self;
    /* cacs_dh_req */
    
    [weakSelf cacs_dh_req_asyn:weakSelf.srv
                    usingBlock:^(NSString *result, NSString *shareKey, int64_t tid, int64_t lid) {
                        if(result)
                        {
                            mcall_ret_sign_in *ret = [[mcall_ret_sign_in alloc] init];
                            ret.result = result;
                            block(ret);
                            return;
                        }
                        if(shareKey)
                        {
                            weakSelf.shareKey = shareKey;
                        };
                        
                        if (tid) {
                            weakSelf.tid = tid;
                        }
                        
                        if (lid) {
                            weakSelf.lid = lid;
                        }
                        
                        //URL参数的拼接
                        int64_t         i64_value = 0;
                        char            pass_enc[256] = {0};
                        long            pass_enc_len = sizeof(pass_enc);
                        
                        //password transform
                        mdes_enc_hex((char*)ctx.passwd , 16, (char*)weakSelf.shareKey.UTF8String, weakSelf.shareKey.length, (char*)&pass_enc[0], &pass_enc_len);
                        
                        NSString    *srvUCTXparams = MIPC_BuildEncryptSysInfo(weakSelf.user, weakSelf.shareKey);
                        
                        NSString    *srvExParams = srvUCTXparams?[NSString stringWithFormat:@",param:[{name:\"%@\",value:\"%@\"},{name:\"spv\",value:\"v1\"}]",
                                                                  @"uctx",
                                                                  srvUCTXparams?srvUCTXparams:@""]:@" ";
                        
                        NSString    *params = [NSString stringWithFormat:@"{lid:%lld,nid:\"%@\",user:\"%@\",pass:\"%s\",session_req:1%@}",weakSelf.lid ,[weakSelf mipc_build_nid_by_lid], weakSelf.user, (char*)&pass_enc[0], srvExParams];
                        
                        [weakSelf call_asyn:weakSelf.srv
                                         to:nil
                                  to_handle:0
                                       mqid:0
                                from_handle:[weakSelf createFromHandle]
                                       type:@"cacs_login_req"
                                   dataJson:params
                                    timeout:0
                                 usingBlock:^(mjson_msg *login_req_msg) {
                                     struct len_str str_result = {0};
                                     if(json_get_child_string(login_req_msg.data, "result", &str_result)
                                        || (0 == str_result.len))
                                     {
                                         json_get_child_int64(login_req_msg.data, "sid", (int64_t*)&i64_value);
                                         weakSelf.sid = i64_value;
                                     }
                                     
                                     
                                     mcall_ret_sign_in *ret = [[mcall_ret_sign_in alloc] init];
                                     ret.result = [weakSelf check_result:login_req_msg];
                                     if (block) {
                                         block(ret);
                                     }
                                 }];
                    }];
    
    return 0;
}

- (long)sign_up:(mcall_ctx_sign_up*)ctx
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *srvCert = nil, *srvName = nil, *srvPubk = nil;//, *shareKey = nil;
        
        NSString *regSrv = [weakSelf mipcGetSrv:ctx.srv
                                           user:@"regist@mipcm.com"
                                           cert:&srvCert
                                           name:&srvName
                                           pubk:&srvPubk];
         [weakSelf cacs_dh_req_asyn:regSrv
                         usingBlock:^(NSString *result, NSString *shareKey, int64_t tid, int64_t lid) {
                             if(result)
                             {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     mcall_ret_sign_up *ret = [[mcall_ret_sign_up alloc] init];
                                     ret.result = result;
                                     
                                     if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                                         [ctx.target performSelector:ctx.on_event withObject:ret];
                                     }
                                 });
                                 return;
                             }
                             char pass_enc[256] = {0};
                             long pass_enc_len = sizeof(pass_enc);
                             
                             mdes_enc_hex((char*)ctx.passwd, 16, (char*)shareKey.UTF8String, shareKey.length, (char*)&pass_enc[0], &pass_enc_len);
                             
                             //                            struct len_str  result = {0};
                             //                            unsigned char   pass_md5[16];
                             //                            char            pass_enc[256] = {0};
                             //                            long            pass_enc_len = sizeof(pass_enc);
                             //                            md5_ex_encrypt((unsigned char*)[task.password UTF8String], (long)[task.password length], &pass_md5[0]);
                             //                            mdes_enc_hex((char*)&pass_md5[0], sizeof(pass_md5), (char*)shareKey.UTF8String, shareKey.length, (char*)&pass_enc[0], &pass_enc_len);
                             NSString            *exParams = nil, *encode_sys = shareKey?MIPC_BuildEncryptSysInfo(ctx.user, shareKey):nil;
                             if(encode_sys)
                             {
                                 exParams = [NSString stringWithFormat:@",p:[{name:\"%@\",value:\"%@\"}]", @"uctx", encode_sys?encode_sys:@""];
                             }
                             NSString *currentLanuage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
                             if ([currentLanuage isEqualToString:@"zh-Hans"]) {
                                 currentLanuage=@"zh";
                             }
                             if ([currentLanuage isEqualToString:@"zh-Hant"]) {
                                 currentLanuage=@"tw";
                             }
                             
                             NSString *params = [NSString stringWithFormat:@"{lid:%lld,user:\"%@\",lang:\"%@\",pass:\"%s\",sess_req:1%@}",
                                                 lid , ctx.user, currentLanuage, &pass_enc[0],exParams?exParams:@""];
                             
                             [weakSelf call_asyn:regSrv to:0 to_handle:0 mqid:0 from_handle:[weakSelf createFromHandle] type:@"cacs_reg_req" dataJson:params timeout:30 usingBlock:^(mjson_msg *msg) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     mcall_ret_sign_up *ret = [[mcall_ret_sign_up alloc] init];
                                     ret.result = [weakSelf check_result:msg];
                                     
                                     if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                                         [ctx.target performSelector:ctx.on_event withObject:ret];
                                     }
                                 });
                                 
                             }];
                             
                         }];
    });
    
    return 1;
}

- (long)local_sign_in:(mcall_ctx_sign_in *)ctx switchMmq:(BOOL)operation
{
    /* clear cache data */
    if(_shareKey){ _shareKey = nil; }
    if(_sid){ _sid = 0; }
    if(_lid){ _lid = 0; }
    if(_tid){ _tid = 0; }
    if(_user){ _user = nil; }
    
    _user = ctx.user;
    
    //get devicetoken
    self.device_token = ctx.token;
    
#define md5_checksum_size  16
    _passwd = (unsigned char*)calloc(1, md5_checksum_size);
    memcpy(_passwd, ctx.passwd, md5_checksum_size);
    
    __weak typeof(self) weakSelf = self;
    //login
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //FIXME: 8.1
        
        NSString *srvCert = nil;
        NSString *srvName = nil;
        NSString *srvPubk = nil;
        
        /* get cache sever ip */
        struct mipci_conf *conf = MIPC_ConfigLoad();
        struct len_str ip = {0};
        char tempip[50];
        
        if (ctx.srv && ctx.srv.length > 0) {
            weakSelf.srv = [NSString stringWithFormat:@"%@", ctx.srv];
        }
        else
        {
            if (conf && conf->exSignal_Srv.len)/* current exsrv url lenght never > 50*/
            {
                ip.len = conf->exSignal_Srv.len;
                memcpy(tempip, conf->exSignal_Srv.data, 50);
                ip.data = tempip;
                
                weakSelf.srv = (self.app.developerOption.signalServer.length != 0) ? self.app.developerOption.signalServer : [NSString stringWithFormat:@"%s", ip.data];;
                
                dispatch_queue_t mipc_server_peration_processing_queue = dispatch_queue_create("com.mipc.server.processing", DISPATCH_QUEUE_SERIAL);
                
                dispatch_async(mipc_server_peration_processing_queue, ^{
                    NSString *srvCert = nil;
                    NSString *srvName = nil;
                    NSString *srvPubk = nil;
                    //get server
                    
                    [weakSelf mipcGetSrv:ctx.srv
                                    user:ctx.user
                                    cert:&srvCert
                                    name:&srvName
                                    pubk:&srvPubk];
                });
            }
            else
            {
                weakSelf.srv = (self.app.developerOption.signalServer.length != 0) ? self.app.developerOption.signalServer : [weakSelf mipcGetSrv:ctx.srv
                                                                                                                                             user:ctx.user
                                                                                                                                             cert:&srvCert
                                                                                                                                             name:&srvName
                                                                                                                                             pubk:&srvPubk];
            }
        }
        /* CcmGetDeviceRequest */
        [weakSelf call_asyn:weakSelf.srv
                         to:nil
                  to_handle:0
                       mqid:nil
                from_handle:[weakSelf createFromHandle]
                       type:@"CcmGetDeviceRequest"
                   dataJson:@"{}"
                    timeout:30
                 usingBlock:^(mjson_msg *dev_req_msg) {
                     struct json_object  *get_dev_data = dev_req_msg.data;
                     struct json_object *get_dev_result = get_dev_data?json_get_child_by_name(get_dev_data, NULL, len_str_def_const("Result")):NULL;
                     
                     struct len_str
                     srv_type = {0},
                     srv_SerialNumber = {0},
                     srv_nick = {0},
                     srv_version = {0},
                     srv_pubk = {0},
                     srv_spv = {0};
                     struct len_str str_result = {0};
                     if((NULL == get_dev_result)
                        || json_get_child_string(get_dev_result, "Code", &str_result)
                        || str_result.len)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             mcall_ret_sign_in *ret = [[mcall_ret_sign_in alloc] init];
                             ret.result = [weakSelf check_result:dev_req_msg];
                             ret.ref = ctx.ref;
                             if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                                 [ctx.target performSelector:ctx.on_event withObject:ret];
                             }
                         });
                         return;
                     }
                     
                     json_get_child_string(get_dev_data, "Type",         &srv_type);
                     json_get_child_string(get_dev_data, "SerialNumber", &srv_SerialNumber);
                     json_get_child_string(get_dev_data, "Nick",         &srv_nick);
                     json_get_child_string(get_dev_data, "Version",      &srv_version);
                     json_get_child_string(get_dev_data, "PubKey",       &srv_pubk);
                     json_get_child_string(get_dev_data, "spv",          &srv_spv);
                     
                     weakSelf.srv_type = srv_type.len?[[NSString alloc] initWithUTF8String:srv_type.data]:nil;
                     weakSelf.srvSerialNumber = srv_SerialNumber.len?[[NSString alloc] initWithUTF8String:srv_SerialNumber.data]:nil;
                     weakSelf.srvNick = srv_nick.len?[[NSString alloc] initWithUTF8String:srv_nick.data]:nil;
                     weakSelf.srvVersion = srv_version.len?[[NSString alloc] initWithUTF8String:srv_version.data]:nil;
                     
                     //check new or old
                     weakSelf.isNewSrv = (srv_spv.len && 0 == len_str_casecmp_const(&srv_spv, "v1"))?YES:NO;
                     [weakSelf create_nid:ctx block:^(mcall_ret_sign_in *ret){
                         if (operation) {
                             if(nil == ret.result && [UIApplication sharedApplication].applicationState == UIApplicationStateActive)//nil is success
                             {
                                 //FIXME:fix for mmqpick
                                 if (weakSelf.mmq_task.isRun) {
                                     [weakSelf mmq_task_destory:_mmq_task];
                                 }
                                 
                                 //mmq
                                 [weakSelf mmq_task_create:weakSelf.srv usingBlock:^(mjson_msg *msg) {
                                     
                                     if(msg && msg.type && msg.data)
                                     {/* active and valid message */
                                         struct len_str s_result = {0};
                                         
                                         if((0 == [msg.type caseInsensitiveCompare:@"mmq_pick_ack"])
                                            && (0 == json_get_child_string(msg.data, "result", &s_result))
                                            && (0 == len_str_cmp_const(&s_result, "err.mmq.qid.invalid")))
                                         {
                                             //mmq
                                             NSLog(@"mmq_create req is invalid and again create mmq");
                                             return;
                                         }
                                         else if(([msg.type isEqualToString:@"ccm_msg"] || [msg.type isEqualToString:@"ccm_message"])
                                                 && msg.data
                                                 && weakSelf.msg_listen_arr
                                                 && weakSelf.msg_listen_arr.count)
                                         {
                                             //check information
                                             //                            [weakSelf check_msg_ret_result:msg];
                                             [weakSelf check_mmq:msg];
                                         }
                                     }
                                     
                                 }];
                             }
                         }
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                             {
                                 [ctx.target performSelector:ctx.on_event withObject:ret];
                             }
                         });
                     }];
                 }];
    });
    
    return 0;
}

- (long)sign_in:(mcall_ctx_sign_in *)ctx
{
    /* clear cache data */
    if(_shareKey){ _shareKey = nil; }
    if(_sid){ _sid = 0; }
    if(_lid){ _lid = 0; }
    if(_tid){ _tid = 0; }
    if(_user){ _user = nil; }
    
    _user = ctx.user;
    
    //get devicetoken
    self.device_token = ctx.token;
    
#define md5_checksum_size  16
    _passwd = (unsigned char*)calloc(1, md5_checksum_size);
    memcpy(_passwd, ctx.passwd, md5_checksum_size);
    
    __weak typeof(self) weakSelf = self;
    //login
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //FIXME: 8.1
        
        NSString *srvCert = nil;
        NSString *srvName = nil;
        NSString *srvPubk = nil;
        
        /* get cache sever ip */
        /* get cache sever ip */
        struct mipci_conf *conf = MIPC_ConfigLoad();
        struct len_str ip = {0};
        char tempip[50];
        
        if (ctx.srv && ctx.srv.length > 0) {
            weakSelf.srv = [NSString stringWithFormat:@"%@", ctx.srv];
        }
        else
        {
            if (conf && conf->exSignal_Srv.len)/* current exsrv url lenght never > 50*/
            {
                ip.len = conf->exSignal_Srv.len;
                memcpy(tempip, conf->exSignal_Srv.data, 50);
                ip.data = tempip;
                
                weakSelf.srv = (self.app.developerOption.signalServer.length != 0) ? self.app.developerOption.signalServer : [NSString stringWithFormat:@"%s", ip.data];;
                
                dispatch_queue_t mipc_server_peration_processing_queue = dispatch_queue_create("com.mipc.server.processing", DISPATCH_QUEUE_SERIAL);
                
                dispatch_async(mipc_server_peration_processing_queue, ^{
                    NSString *srvCert = nil;
                    NSString *srvName = nil;
                    NSString *srvPubk = nil;
                    //get server
                    [weakSelf mipcGetSrv:ctx.srv
                                    user:ctx.user
                                    cert:&srvCert
                                    name:&srvName
                                    pubk:&srvPubk];
                });
            }
            else
            {
                weakSelf.srv = (self.app.developerOption.signalServer.length != 0) ? self.app.developerOption.signalServer : [weakSelf mipcGetSrv:ctx.srv
                                                                                                                                             user:ctx.user
                                                                                                                                             cert:&srvCert
                                                                                                                                             name:&srvName
                                                                                                                                             pubk:&srvPubk];
            }
        }

        /* CcmGetDeviceRequest */
        [self call_asyn:weakSelf.srv
                     to:nil
              to_handle:0
                   mqid:nil
            from_handle:[weakSelf createFromHandle]
                   type:@"CcmGetDeviceRequest"
               dataJson:@"{}"
                timeout:0
             usingBlock:^(mjson_msg *dev_req_msg) {
                 struct len_str str_result = {0};
                 struct json_object  *get_dev_data = dev_req_msg.data;
                 struct json_object *get_dev_result = get_dev_data?json_get_child_by_name(get_dev_data, NULL, len_str_def_const("Result")):NULL;
                 
                 struct len_str
                 srv_type = {0},
                 srv_SerialNumber = {0},
                 srv_nick = {0},
                 srv_version = {0},
                 srv_pubk = {0},
                 srv_spv = {0};
                 
                 if((NULL == get_dev_result)
                    || json_get_child_string(get_dev_result, "Code", &str_result)
                    || str_result.len)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         mcall_ret_sign_in *ret = [[mcall_ret_sign_in alloc] init];
                         ret.result = [weakSelf check_result:dev_req_msg];
                         
                         if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                             [ctx.target performSelector:ctx.on_event withObject:ret];
                         }
                     });
                     return;
                 }
                 
                 json_get_child_string(get_dev_data, "Type",         &srv_type);
                 json_get_child_string(get_dev_data, "SerialNumber", &srv_SerialNumber);
                 json_get_child_string(get_dev_data, "Nick",         &srv_nick);
                 json_get_child_string(get_dev_data, "Version",      &srv_version);
                 json_get_child_string(get_dev_data, "PubKey",       &srv_pubk);
                 json_get_child_string(get_dev_data, "spv",          &srv_spv);
                 
                 weakSelf.srv_type = srv_type.len?[[NSString alloc] initWithUTF8String:srv_type.data]:nil;
                 weakSelf.srvSerialNumber = srv_SerialNumber.len?[[NSString alloc] initWithUTF8String:srv_SerialNumber.data]:nil;
                 weakSelf.srvNick = srv_nick.len?[[NSString alloc] initWithUTF8String:srv_nick.data]:nil;
                 weakSelf.srvVersion = srv_version.len?[[NSString alloc] initWithUTF8String:srv_version.data]:nil;
                 
                 //check new or old
                 weakSelf.isNewSrv = (srv_spv.len && 0 == len_str_casecmp_const(&srv_spv, "v1"))?YES:NO;
                 
                 [weakSelf create_nid:ctx block:^(mcall_ret_sign_in *ret){
                     
                     if(nil == ret.result && (self.app.is_jump || [UIApplication sharedApplication].applicationState == UIApplicationStateActive))//nil is success
                     {
                         //FIXME:fix for mmqpick
                         if (weakSelf.mmq_task.isRun) {
                             [weakSelf mmq_task_destory:_mmq_task];
                         }
                         
                         //mmq
                         _subscribeNumber = MNSubscribeFirst;
                         [weakSelf mmq_task_create:weakSelf.srv usingBlock:^(mjson_msg *msg) {
                             
                             if(msg && msg.type && msg.data)
                             {/* active and valid message */
                                 struct len_str s_result = {0};
                                 
                                 if((0 == [msg.type caseInsensitiveCompare:@"mmq_pick_ack"])
                                    && (0 == json_get_child_string(msg.data, "result", &s_result))
                                    && (0 == len_str_cmp_const(&s_result, "err.mmq.qid.invalid")))
                                 {
                                     //mmq
                                     NSLog(@"mmq_create req is invalid and again create mmq");
                                     return;
                                 }
                                 else if(([msg.type isEqualToString:@"ccm_msg"] || [msg.type isEqualToString:@"ccm_message"])
                                         && msg.data
                                         && weakSelf.msg_listen_arr
                                         && weakSelf.msg_listen_arr.count)
                                 {
                                     //check information
                                     //                            [weakSelf check_msg_ret_result:msg];
                                     [weakSelf check_mmq:msg];
                                 }
                             }
                             
                         }];
//
                     }
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                         {
                             [ctx.target performSelector:ctx.on_event withObject:ret];
                         }
                     });
                 }];
             }];
    });
    
    return 0;
}

- (long)sign_out:(mcall_ctx_sign_out *)ctx
{
//    [_queue cancelAllOperations];
//     dispatch_release(mmq_task_request_operation_processing_queue());
//    [self.mmqBlockOperation cancel];
//    [self.mmqOperationQueue cancelAllOperations];
//    self.mmqBlockOperation = nil;
//    self.mmqOperationQueue = nil;
//    self.mmq_stop = YES;
//
//    [self.mmq_connection cancel];
    
    _subscribeNumber = MNSubscribeZero;
    [self mmq_task_destory:_mmq_task];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:0
              from_handle:0
                     type:@"cacs_logout_req"
                 dataJson:[NSString stringWithFormat:@"{nid:\"%@\"}",[self mipc_build_nid]]
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //block
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }
                   
                   mcall_ret_sign_out *ret =  [[mcall_ret_sign_out alloc] init]  ;
                   ret.result = [weakSelf check_result:msg];
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
                   
               }];
    
    return 1;
}

- (void)check_mmq:(mjson_msg*)msg
{
    //  NSLog(@"%@", [[NSString alloc] initWithData:msg.data encoding:NSUTF8StringEncoding]);
    struct json_object *items = json_get_child_by_name(msg.data, NULL, len_str_def_const("items"));

    if(items && items->type == ejot_array && items->v.array.counts)
    {
        struct json_object *item = items->v.array.list;

        for (int i = 0; i < items->v.array.counts; i++,item = items->in_parent.next)
        {
            mdev_msg *msg = [[mdev_msg alloc] initWithJson:item];
            
            NSMutableArray *msg_listen_arr = [_msg_listen_arr mutableCopy];
            for(mcall_ctx_dev_msg_listener_add *lis_msg in msg_listen_arr)
            {
                if(msg && msg.sn && msg.type && ([lis_msg.type rangeOfString:msg.type].location != NSNotFound) && lis_msg.target)
                {
                    if ([lis_msg.target respondsToSelector:lis_msg.on_event]) {
                        [lis_msg.target performSelectorOnMainThread:lis_msg.on_event withObject:msg waitUntilDone:YES];
                    }
                }
            }
        }
    }
}

//add listener for mmq_pick return
- (long)dev_msg_listener_add:(mcall_ctx_dev_msg_listener_add *)ctx
{
    for(mcall_ctx_dev_msg_listener_add *add in _msg_listen_arr)
    {
        if(nil == ctx.target
           || nil == ctx.on_event
           || nil == ctx.type
           || (ctx.on_event == add.on_event
               && ctx.target == add.target
               && [ctx.type isEqualToString:add.type]))
            return -1;
    }

    [_msg_listen_arr addObject:ctx];

    return 1;
}
//del listener for mmq_pick return
- (long)dev_msg_listener_del:(mcall_ctx_dev_msg_listener_del *)ctx
{
    for(int i= 0; i < _msg_listen_arr.count; i++)
    {
        mcall_ctx_dev_msg_listener_add *add = _msg_listen_arr[i];
//        if(ctx.on_event == add.on_event
//           && ctx.target == add.target
//           && [ctx.type isEqualToString:add.type])
//        {
//            [_msg_listen_arr removeObject:add];
//            return 1;
//        }
        if(ctx.target == add.target)
        {
            [_msg_listen_arr removeObject:add];
            return 1;
        }
    }

    return -1;
}

#pragma mark - mmq
//- (void)applicationDidEnterBackground:(NSNotification*)notification
- (void)mmqTaskDestory
{
    self.subscribe_fail_count = 0;
    if (!self.app.is_userOnline)
    {
        return;
    }
    [self mmq_task_destory:_mmq_task];
}

//- (void)applicationWillEnterForeground:(NSNotification*)notification
- (void)mmqTaskCreate
{
    if (!self.app.is_userOnline)
    {
        return;
    }
    if(_mmq_task.isRun) {
        [self mmq_task_destory:_mmq_task];
    }
    
    __weak typeof(self) weakSelf = self;
    [self mmq_task_create:_srv usingBlock:^(mjson_msg *msg) {
        
        if(msg && msg.type && msg.data)
        {/* active and valid message */
            struct len_str s_result = {0};
            
            if((0 == [msg.type caseInsensitiveCompare:@"mmq_pick_ack"])
                    && (0 == json_get_child_string(msg.data, "result", &s_result))
                    && (0 == len_str_cmp_const(&s_result, "err.mmq.qid.invalid")))
            {
                //mmq
                NSLog(@"mmq_create req is invalid and again create mmq");
                return;
            }
            else if(([msg.type isEqualToString:@"ccm_msg"] || [msg.type isEqualToString:@"ccm_message"])
                    && msg.data
                    && weakSelf.msg_listen_arr
                    && weakSelf.msg_listen_arr.count)
            {
                //check information
//                [weakSelf check_msg_ret_result:msg];
                [weakSelf check_mmq:msg];
            }
        }
        
    }];
}

/*----------------------------------------------------------*/
#pragma mark- to be used for the 3rd developer

- (long)devs_refresh:(mcall_ctx_devs_refresh*)ctx
{  
    NSString *nid = [self mipc_build_nid];
    NSString *type = @"ccm_devs_get";
    NSString *data_josn  = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},start:\"0\",counts:\"512\"}",nid, _srvSerialNumber];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_josn];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_josn
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
           
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }
                   
                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //block
                   NSString *result = [weakSelf check_result:msg];

                   mcall_ret_devs_refresh *devsOjb = [[mcall_ret_devs_refresh alloc] init];

                   if(nil == (devsOjb.result = result))
                   {
                       [weakSelf.devs reset];

                       struct json_object *devices = json_get_child_by_name(msg.data, NULL, len_str_def_const("devs"));

                       if(devices
                          && (devices->type == ejot_array)
                          && devices->v.array.counts)
                       {
                           struct json_object *obj = devices->v.array.list;
                           for (int i = 0; i < devices->v.array.counts; i++, obj = obj->in_parent.next)
                           {
                               m_dev *dev = [[m_dev alloc] initWithJson:obj];
                               NSUserDefaults *user = [NSUserDefaults standardUserDefaults];

                               //TODO: get from NSUserDefaults
                               NSArray *cache_arr = [user objectForKey:@"mipci_devs"];

                               if(cache_arr && cache_arr.count)
                               {
                                   [cache_arr enumerateObjectsUsingBlock:^(NSData *dev_data,NSUInteger index,BOOL *stop){

                                       //avoid crash
                                       m_dev *cache_dev;
                                       if (dev_data)
                                       {
                                           @try {
                                               cache_dev = [NSKeyedUnarchiver unarchiveObjectWithData:dev_data];
                                           } @catch (NSException *exception) {
                                               NSLog(@"[agent devs_refresh] Exception:%@", exception);
                                               
                                           } @finally {
                                               
                                           }
                                       }

                                       if([cache_dev.sn isEqualToString:dev.sn])
                                       {
                                           dev.read_id = cache_dev.read_id;
                                       }
                                   }];
                               }

                               if(dev)
                               {
                                   [weakSelf.devs add_dev:dev];
                               }

                           }
                       }

                       devsOjb.devs = weakSelf.devs;

                       if(weakSelf.devs_need_cache)
                           [weakSelf.devs performSelectorInBackground:@selector(save) withObject:nil];
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:devsOjb];
                   }

    }];

    return 1;
}

- (long)play:(mcall_ctx_play*)ctx
{
    NSString *token;
    if([ctx.token isEqualToString:@"p0"])
    {
        token = @"p0";
    }
    else if([ctx.token isEqualToString:@"p1"])
    {
        token = @"p1";
    }
    else if([ctx.token isEqualToString:@"p2"])
    {
        token = @"p2";
    }
    else
    {
        token = @"p3";
    }

    NSString *type = @"ccm_play";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},setup:{stream:\"RTP_Unicast\",trans:{proto:\"%@\"}},token:\"%@\"}}",[self mipc_build_nid], ctx.sn, ctx.protocol, token];
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv to:nil to_handle:0 mqid:_qid from_handle:[self createFromHandle] type:type dataJson:data_json timeout:0 usingBlock:^(mjson_msg * msg) {
                   
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }
                   
                   //check information
//                   [weakSelf check_msg_ret_result:msg];

                   NSString *result = [weakSelf check_result:msg];
                   mcall_ret_play *play = [[mcall_ret_play alloc] init];
                   if(nil == (play.result = result))
                   {
                       struct len_str url = {0};
                       struct json_object *uri = json_get_child_by_name(msg.data, NULL, len_str_def_const("uri"));
                       json_get_child_string(uri, "url", &url);
                       play.url = url.len?[NSString stringWithUTF8String:url.data]:@"";
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                        [ctx.target performSelector:ctx.on_event withObject:play];
                   }
    }];

    return 1;
}

- (long)dev_add:(mcall_ctx_dev_add*)ctx
{
    char            pass_enc[256] = {0};
    long            pass_enc_len = sizeof(pass_enc);
    mdes_enc_hex((char*)ctx.passwd, 16, (char*)_shareKey.UTF8String, _shareKey.length, &pass_enc[0], &pass_enc_len);

    NSString *type = @"ccm_dev_add";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},sn:\"%@\",pwd:\"%s\"}",[self mipc_build_nid], ctx.sn, ctx.sn, (char*)&pass_enc[0]];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_dev_add *add = [[mcall_ret_dev_add alloc] init];

                   if(nil == (add.result = [weakSelf check_result:msg]))
                   {
                       struct json_object *info = json_get_child_by_name(msg.data, NULL, len_str_def_const("info"));
                       m_dev *dev = [[m_dev alloc] initWithJson:info];

                       if(dev)
                       {
                           [weakSelf.devs add_dev:dev];
                           add.dev = dev;
                           if(weakSelf.devs_need_cache)
                               [weakSelf.devs performSelectorInBackground:@selector(save) withObject:nil];
                       }
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:add];
                   }

    }];

    return 1;
}

- (long)dev_del:(mcall_ctx_dev_del *)ctx
{
    NSString *type = @"ccm_dev_del";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},sn:\"%@\"}", [self mipc_build_nid], ctx.sn, ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_dev_del *ret = [[mcall_ret_dev_del alloc] init];

                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       [weakSelf.devs del_dev:ctx.sn];//FIXME: the parameter should be serial number of device
                       ret.devs = weakSelf.devs;
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)account_passwd_set:(mcall_ctx_account_passwd_set*)ctx
{

    char            pass_old[256] = {0}, pass_new[256] = {0};
    long            pass_enc_len = sizeof(pass_old);
    mdes_enc_hex((char*)ctx.old_encrypt_pwd , 16, (char*)_shareKey.UTF8String, _shareKey.length, (char*)&pass_old[0], &pass_enc_len);
    mdes_enc_hex((char*)ctx.new_encrypt_pwd , 16, (char*)_shareKey.UTF8String, _shareKey.length, (char*)&pass_new[0], &pass_enc_len);

    NSString *type =@"cacs_passwd_req";
    NSString *data_json = [NSString stringWithFormat:@"{nid:\"%@\",old_pass:\"%s\",new_pass:\"%s\",guest:%d}",[self mipc_build_nid],pass_old, pass_new ,ctx.is_guest];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_account_passwd_set *ret = [[mcall_ret_account_passwd_set alloc] init];
                   ret.ref = ctx.ref;
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)pushtalk:(mcall_ctx_pushtalk *)ctx
{
    if(![self check_ver:@"ccm_talk" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_talk";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},setup:{stream:\"RTP_Unicast\",trans:{proto:\"%@\"}},token:\"%@\"}}",[self mipc_build_nid], ctx.sn, ctx.protocol, @""];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
             usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_pushtalk *ret = [[mcall_ret_pushtalk alloc] init];
                   ret.ref = ctx.ref;

                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       struct json_object  *media_uri = json_get_child_by_name(msg.data, NULL, len_str_def_const("uri"));
                       struct len_str      uri = {0};
                       if(media_uri)
                       {
                           json_get_child_string(media_uri, "url", &uri);
                       };
                       ret.url = uri.len?[NSString stringWithUTF8String:uri.data]:@"";
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)ptz_ctrl:(mcall_ctx_ptz_ctrl *)ctx
{
    NSString *type = @"ccm_ptz_ctl";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},token:\"%@\",trans:{pan_tilt:{x:%ld,y:%ld, z:%ld}},speed:{pan_tilt:{x:%d,y:%d}}}",
                           [self mipc_build_nid], ctx.sn, @"ptz0", ctx.x, ctx.y, ctx.z, 48, 16];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_ptz_ctrl *ret = [[mcall_ret_ptz_ctrl alloc] init];
                   ret.result = [weakSelf check_result:msg];
                   ret.ref = ctx.ref;

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)record_get:(mcall_ctx_record_get *)ctx
{
    if(![self check_ver:@"ccm_record_task_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        return 0;
    }

    NSString *type = @"ccm_record_task_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_record_get *ret =  [[mcall_ret_record_get alloc] init]  ;
                   ret.ref = ctx.ref;

                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       struct json_object *task = json_get_child_by_name(msg.data, NULL, len_str_def_const("task")),
                       *sch = task?json_get_child_by_name(task, NULL, len_str_def_const("sch")):NULL,
                       *times = sch?json_get_child_by_name(sch, NULL, len_str_def_const("times")):NULL;
                       long      enable = 0, full_time = 0, sd_ready = 0;
                       json_get_child_long(sch, "enable", &enable);
                       json_get_child_long(sch, "full_time", &full_time);
                       json_get_child_long(msg.data, "sd_ready", &sd_ready);
                       
                       NSMutableArray *times_arr = nil;
                       if (enable != 0) {
                           if (times && ejot_array == times->type && times->v.array.counts)
                           {
                               struct json_object  *next = times->v.array.list;
                               times_arr = [NSMutableArray arrayWithCapacity:3];
                               for (int i = 0; i < times->v.array.counts;i++, next = next->in_parent.next)
                               {
                                   long start = 0, end = 0, wday = 0 ;
                                   json_get_child_long(next, "wday", &wday);
                                   json_get_child_long(next, "start", &start);
                                   json_get_child_long(next, "end", &end);

                                   mdev_time *time = [[mdev_time alloc] init];
                                   time.start_time = start;
                                   time.end_time = end;
                                   time.time = (mdev_time_type)wday;
                                   [times_arr addObject:time];
                               }
                           }
                       }
                       ret.enable = enable;
                       ret.full_time = full_time;
                       ret.times = times_arr;
                       ret.sd_ready = sd_ready;
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)record:(mcall_ctx_record *)ctx
{
    if(![self check_ver:@"ccm_record_task_set" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_record_task_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},task:{keep:\"%d\"}}",[self mipc_build_nid], ctx.sn, ctx.keep_time];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_record *ret =  [[mcall_ret_record alloc] init]  ;
                   ret.ref = ctx.ref;
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)record_set:(mcall_ctx_record_set *)ctx
{
    if(![self check_ver:@"ccm_record_task_set" sn:ctx.sn])
    {//xxxxxxxxxx result
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString  *ns_times = @"";

    for(mdev_time *time in ctx.times)
    {
        ns_times = [NSString stringWithFormat:@"%@%@%@",ns_times, ns_times.length?@",":@"", [NSString stringWithFormat:@"{wday:\"%d\",start:\"%ld\",end:\"%ld\"}",time.time,time.start_time,time.end_time]];
    }

    //NSString *task_json = ctx.full_time ? [NSString stringWithFormat:@"sch:{enable:\"%d\",full_time:\"%d\"}", ctx.enable, ctx.full_time] : [NSString stringWithFormat:@"sch:{enable:\"%d\",full_time:\"%d\",times:[%@]}", ctx.enable, ctx.full_time,ns_times];
    NSString *task_json = [NSString stringWithFormat:@"sch:{enable:\"%d\",full_time:\"%d\",times:[%@]}", ctx.enable, ctx.full_time,ns_times];

    NSString *type = @"ccm_record_task_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},task:{%@}}}",[self mipc_build_nid], ctx.sn, task_json];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
             usingBlock:^(mjson_msg *msg) {
                     //check old to new
                     if (!weakSelf.isNewSrv) {
                         [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                     }

                     //check information
//                     [weakSelf check_msg_ret_result:msg];
                     //coding in block
                     mcall_ret_record_set *ret =  [[mcall_ret_record_set alloc] init]  ;
                     ret.result = [weakSelf check_result:msg];
                     ret.ref = ctx.ref;

                     if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                     {
                         [ctx.target performSelector:ctx.on_event withObject:ret];
                     }

    }];

    return 1;
}

- (long)dev_info_get:(mcall_ctx_dev_info_get *)ctx
{
    
    //    if(![self check_ver:@"ccm_dev_info_get" sn:ctx.sn])
    //    {//xxxxxxxxxx result
    //        [ctx.target performSelector:ctx.on_event withObject:nil];
    //
    //        return 0;
    //    }
    
    NSString *type = @"ccm_dev_info_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[self mipc_build_nid], ctx.sn];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:0
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //check information
                 //                   [weakSelf check_msg_ret_result:msg];
                 //coding in block
                 mcall_ret_dev_info_get *ret =  [[mcall_ret_dev_info_get alloc] init]  ;
                 ret.ref = ctx.ref;
                 
                 if(nil == ([weakSelf check_result:msg]))
                 {
                     struct len_str s_sn = {0}, s_model = {0}, s_fv = {0}, s_bfv = {0}, s_nick = {0} ,s_type = {0};
                     json_get_child_string(msg.data, "sn", &s_sn);
                     json_get_child_string(msg.data, "model", &s_model);
                     json_get_child_string(msg.data, "img_ver", &s_fv);
                     json_get_child_string(msg.data, "bimg_ver", &s_bfv);
                     json_get_child_string(msg.data, "nick", &s_nick);
                     json_get_child_string(msg.data, "type", &s_type);
                     
                     ret.sn = s_sn.len?[NSString stringWithUTF8String:s_sn.data]:nil;
                     ret.model = s_model.len?[NSString stringWithUTF8String:s_model.data]:nil;
                     ret.img_ver = s_fv.len?[NSString stringWithUTF8String:s_fv.data]:nil;
                     ret.bimg_ver = s_bfv.len?[NSString stringWithUTF8String:s_bfv.data]:nil;
                     ret.nick = s_nick.len?[NSString stringWithUTF8String:s_nick.data]:nil;
                     ret.type = s_type.len?[NSString stringWithUTF8String:s_type.data]:nil;

                     
                     struct json_object *param = json_get_child_by_name(msg.data, NULL, len_str_def_const("p"));
                     
                     if(param)
                     {
                         ret.sensor_status = json_get_field_string(param, len_str_def_const("s.sensor"));
                         ret.spv = json_get_field_long(param, len_str_def_const("s.spv"));
                         ret.wifi_status = json_get_field_string(param, len_str_def_const("s.wifs"));
                         ret.p0 = json_get_field_string(param, len_str_def_const("p0"));
                         ret.support_scene = json_get_field_long(param, len_str_def_const("s.oscene"));
                         ret.add_accessory = json_get_field_long(param, len_str_def_const("s.rffreq"));
                         ret.timezone = json_get_field_string(param, len_str_def_const("timezone"));
                         ret.ratio = json_get_field_long(param, len_str_def_const("s.ratio"));
                         ret.s_model = json_get_field_string(param, len_str_def_const("s.model"));
                         ret.s_mfc = json_get_field_string(param, len_str_def_const("s.mfc"));
                         ret.s_logo = json_get_field_string(param, len_str_def_const("s.logo"));

                         long feature = json_get_field_long(param, len_str_def_const("feature"));
                         ret.del_ipc = feature ? ((feature>>1)&1) : 0;
                         
//                         NSArray *langArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
//                         
//                         NSString *lang = [langArr objectAtIndex:0], *mfc, *logo;
//                         
//                         if([lang isEqualToString:@"zh-Hant"])
//                         {
//                             lang = @"tw";
//                         }else
//                         {
//                             lang = [lang substringToIndex:2];
//                         }
//                         
//                         char cmfc[9];
//                         sprintf(cmfc,"s.mfc_%s", (char*)[lang UTF8String]);
//                         mfc = json_get_field_string(param, strlen(cmfc), cmfc);
//
//                         if(0 == mfc.length)
//                         {
//                             mfc = json_get_field_string(param, len_str_def_const("s.mfc"));
//                         }
//                         
//                         ret.mfc = mfc;
//                         logo = json_get_field_string(param, len_str_def_const("s.logo"));
//                         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                         NSData *logo_data = [userDefaults objectForKey:logo];
//                         UIImage *img = [UIImage imageWithData:logo_data];
//                         ret.logo = img;
//                         
//                         if(nil == img && logo.length)
//                         {
//                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                 [weakSelf download_url:logo timeout:ctx.timeout completionBlock:^(NSData *data) {
//                                     UIImage *img = [UIImage imageWithData:data];
//                                     if(img)
//                                     {
//                                         ret.logo = img;
//                                         [userDefaults setObject:data forKey:logo];
//                                         [userDefaults synchronize];
//                                     }
//                                     dispatch_async(dispatch_get_main_queue(), ^{
//                                         if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
//                                         {
//                                             [ctx.target performSelector:ctx.on_event withObject:ret];
//                                             
//                                         }
//                                     });
//                                 }];
//                                 
//                             });
//                             return;
//                         }
                     }
                 }
                 
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                 {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
                 
                 
             }];
    
    return 1;
}
- (NSString *)pic_url_create:(mcall_ctx_pic_get *)ctx
{
    __weak typeof(self) weakSelf = self;
    //
//    [_queue addOperationWithBlock:^{
            mcall_ret_pic_get *ret = [[mcall_ret_pic_get alloc] init];
            ret.ref = ctx.ref;
            ret.sn = ctx.sn;
            ret.token = ctx.token;

            int size;
            if([@"720p" isEqualToString:ctx.size])
                size = 0;
            else if([@"d1" isEqualToString:ctx.size])
                size = 1;
            else if ([@"qcif" isEqualToString:ctx.size])
                size = 3;
            else
                size = 2;

            NSString *type;
            NSString *data_json;

            switch (ctx.type) {

                case mdev_pic_thumb:
                {
                    type = @"ccm_pic_get";
                    data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},token:\"p%d_xxxxxxxxxx\",flag:\"1\"}",[weakSelf mipc_build_nid], ctx.sn, size];
                }
                    break;

                case mdev_pic_album:
                {
                    type = @"ccm_pic_get";
                    data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},token:\"%@\", flag:\"1\"}",[weakSelf mipc_build_nid], ctx.sn, ctx.token];
                }
                    break;
                    
                case mdev_pic_seg_album:
                {
                    type = @"ccm_pic_get";
                    data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},token:\"%@\",flag:\"1\"}",[weakSelf mipc_build_nid], ctx.sn, ctx.token];
                }
                    break;

                default:
                {
                    ret.result = @"need to select a type";/* not type */
//                    [ctx.target performSelector:ctx.on_event withObject:ret];
                    return nil;
                }
                    break;
            }

            if (!weakSelf.isNewSrv) {
                [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
            }

            NSString *imageURL = [weakSelf build_url:_srv to:nil to_handle:0 mqid:_qid from_handle:[weakSelf createFromHandle] type:type dataJson:data_json];

//            NSData *data_img = [weakSelf download_url:url timeout:ctx.timeout];
//        
//        if (ctx.type == mdev_pic_seg_album) {
//            struct json_object *json_msg = MIPC_DataTransformToJson(data_img);
//            struct json_object  *data_json = json_get_child_by_name(json_msg, NULL, len_str_def_const("data"));
//            struct len_str data_str = {0};
//            json_get_child_string(data_json, "frame", &data_str);
//            
//            if (NULL != data_str.data)
//            {
//                uchar *buf_data = (uchar*)malloc(100 * 1024 * sizeof(uchar));
//                long buf_len = 100 * 1024;
//                long dec_success = mh264_jpg_decode(mh264_decode_type_jpg, (uchar*)data_str.data, data_str.len, buf_data, &buf_len);
//                NSData *data_dec = [NSData dataWithBytes:buf_data length:buf_len];
//                ret.img = [UIImage imageWithData:data_dec];
//                free(buf_data);
//            }
//        }
//        else
//        {
//            ret.img = [UIImage imageWithData:data_img];
//        }
//        
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
//            {
//                [ctx.target performSelector:ctx.on_event withObject:ret];
//            }
//
//        }];
//    }];
    return imageURL;
}

- (long)pic_get:(mcall_ctx_pic_get *)ctx
{
    __weak typeof(self) weakSelf = self;
    //creat Queue
    
    [self.picOperationQueue addOperationWithBlock:^{
        mcall_ret_pic_get *ret = [[mcall_ret_pic_get alloc] init];
        ret.ref = ctx.ref;
        ret.sn = ctx.sn;
        ret.token = ctx.token;
        
//        int size;
//        if([@"720p" isEqualToString:ctx.size])
//            size = 0;
//        else if([@"d1" isEqualToString:ctx.size])
//            size = 1;
//        else if ([@"qcif" isEqualToString:ctx.size])
//            size = 3;
//        else
//            size = 2;
        
        
        
        NSString *type = @"ccm_pic_get";
        NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},token:\"%@\",flag:\"1\"}",[weakSelf mipc_build_nid], ctx.sn, ctx.token];
        
        if (!weakSelf.isNewSrv) {
            [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
        }
        
        NSString *imageURL = [weakSelf build_url:_srv
                                              to:nil
                                       to_handle:0
                                            mqid:_qid
                                     from_handle:[weakSelf createFromHandle]
                                            type:type
                                        dataJson:data_json];
        
        [weakSelf download_url:imageURL timeout:ctx.timeout completionBlock:^(NSData *data_img) {
            NSString *imgString = [[NSString alloc] initWithData:data_img encoding:NSUTF8StringEncoding];
            if (imgString.length && [imgString rangeOfString:@"ccm_pic_get_ack"].length)
            {
                struct json_object *json_msg = MIPC_DataTransformToJson(data_img);
                struct json_object  *ret_data_json = json_get_child_by_name(json_msg, NULL, len_str_def_const("data"));
                struct len_str data_str = {0};
                json_get_child_string(ret_data_json, "frame", &data_str);
                
                if (NULL != data_str.data)
                {
                    uchar *buf_data = (uchar*)malloc(500 * 1024 * sizeof(uchar));
                    long buf_len = 500 * 1024;
                    long dec_success = mh264_jpg_decode(mh264_decode_type_jpg, (uchar*)data_str.data, data_str.len, buf_data, &buf_len);
                    NSData *data_dec = [NSData dataWithBytes:buf_data length:buf_len];
                    ret.img = [UIImage imageWithData:data_dec];
                    free(buf_data);
                }
            }
            else
            {
                ret.img = [UIImage imageWithData:data_img];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                {
                    [ctx.target performSelector:ctx.on_event withObject:ret];
                }
                
            }];
        }];
        
    }];
    
    return 0;
}

- (long)snapshot:(mcall_ctx_snapshot*)ctx
{
    
    mcall_ret_snapshot *ret = [[mcall_ret_snapshot alloc] init];
    ret.ref = ctx.ref;
    ret.sn = ctx.sn;
    ret.token = ctx.token;
    
    int size;
    if([@"720p" isEqualToString:ctx.size])
        size = 0;
    else if([@"d1" isEqualToString:ctx.size])
        size = 1;
    else if ([@"qcif" isEqualToString:ctx.size])
        size = 3;
    else
        size = 2;
    
    
    NSString *type = @"ccm_snapshot";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},token:\"p%d\"}",[self mipc_build_nid], ctx.sn, size];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //        mjson_msg *msg = [weakSelf call:weakSelf.srv
        //                                       to:nil
        //                                to_handle:0
        //                                     mqid:weakSelf.qid
        //                              from_handle:[weakSelf createFromHandle]
        //                                     type:type
        //                                 dataJson:data_json
        //                                  timeout:30];
        [weakSelf call_asyn:weakSelf.srv
                         to:nil
                  to_handle:0
                       mqid:weakSelf.qid
                from_handle:[weakSelf createFromHandle]
                       type:type
                   dataJson:data_json
                    timeout:30
                 usingBlock:^(mjson_msg *msg) {
                     
                     struct len_str token = {0};
                     json_get_child_string(msg.data, "token", &token);
                     
                     if(nil != (ret.result = [weakSelf check_result:msg]) && token.len)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                                 [ctx.target performSelector:ctx.on_event withObject:ret];
                             }
                         });
                         
                         return;
                     }
                     
                     NSString *s_type = @"ccm_pic_get";
                     NSString *s_data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},token:\"%s\", flag:\"1\"}",[weakSelf mipc_build_nid], ctx.sn, token.data];
                     
                     
                     if (!weakSelf.isNewSrv) {
                         [[mipc_def_manager shared_def_manager] checkMsgRqt:&s_type dataJson:&s_data_json];
                     }
                     
                     NSString *url = [weakSelf build_url:weakSelf.srv to:nil to_handle:0 mqid:weakSelf.qid from_handle:[weakSelf createFromHandle] type:s_type dataJson:s_data_json];
                     [weakSelf download_url:url timeout:30 completionBlock:^(NSData *data_img) {
                         NSString *imgString = [[NSString alloc] initWithData:data_img encoding:NSUTF8StringEncoding];
                         if (imgString.length && [imgString rangeOfString:@"ccm_pic_get_ack"].length)
                         {
                             struct json_object *json_msg = MIPC_DataTransformToJson(data_img);
                             struct json_object  *ret_data_json = json_get_child_by_name(json_msg, NULL, len_str_def_const("data"));
                             struct len_str data_str = {0};
                             json_get_child_string(ret_data_json, "frame", &data_str);
                             
                             if (NULL != data_str.data)
                             {
                                 uchar *buf_data = (uchar*)malloc(500 * 1024 * sizeof(uchar));
                                 long buf_len = 500 * 1024;
                                 long dec_success = mh264_jpg_decode(mh264_decode_type_jpg, (uchar*)data_str.data, data_str.len, buf_data, &buf_len);
                                 NSData *data_dec = [NSData dataWithBytes:buf_data length:buf_len];
                                 ret.img = [UIImage imageWithData:data_dec];
                                 free(buf_data);
                             }
                         }
                         else
                         {
                             ret.img = [UIImage imageWithData:data_img];
                         }
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                                 [ctx.target performSelector:ctx.on_event withObject:ret];
                             }
                         });
                     }];
                     
                 }];
        
    });
    
    return 0;
}

- (long)nick_set:(mcall_ctx_nick_set *)ctx
{

    if(![self check_ver:@"ccm_nick_set" sn:ctx.sn])
    {//xxxxxxxxxx result
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_nick_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},nick:\"%@\"}",[self mipc_build_nid], ctx.sn, ctx.nick?ctx.nick:@""];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_nick_set *ret =  [[mcall_ret_nick_set alloc] init]  ;
                   ret.result = [weakSelf check_result:msg];
                   ret.ref = ctx.ref;

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }


    }];

    return 1;
}

- (long)dev_passwd_set:(mcall_ctx_dev_passwd_set *)ctx
{

    if(![self check_ver:@"ccm_pwd_set" sn:ctx.sn] && ctx.is_guest)
    {   //xxxxxxxxxx result
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    char            old_pass_enc[256] = {0},new_pass_enc[256] = {0};
    long            pass_enc_len = sizeof(old_pass_enc);
    mdes_enc_hex((char*)ctx.old_encrypt_pwd, 16, (char*)_shareKey.UTF8String, _shareKey.length, &old_pass_enc[0], &pass_enc_len);
    mdes_enc_hex((char*)ctx.new_encrypt_pwd, 16, (char*)_shareKey.UTF8String, _shareKey.length, &new_pass_enc[0], &pass_enc_len);

    NSString *type = @"ccm_pwd_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},user:{username:\"%@\",old_pwd:\"%s\",pwd:\"%s\",level:\"\",guest:%d}}",
                           [self mipc_build_nid], ctx.sn, ctx.sn, old_pass_enc, new_pass_enc,ctx.is_guest];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_dev_passwd_set *ret =  [[mcall_ret_dev_passwd_set alloc] init]  ;
                   ret.result = [weakSelf check_result:msg];
                   ret.ref = ctx.ref;

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)msgs_get:(mcall_ctx_msgs_get *)ctx
{
    if (_msgs_need_cache) {
        CoreDataUtils *coreData = [CoreDataUtils deflautMIPCCoreData];
        m_dev *dev = [_devs get_dev_by_sn:ctx.sn];
        int start_id = ctx.start_id - 1;
        NSLog(@"dev.msg_id_min:%ld   [coreData minMsgIDBydeviceID:ctx.sn]:%ld", dev.msg_id_min, [coreData minMsgIDBydeviceID:ctx.sn]);
        if (dev.msg_id_min > [coreData minMsgIDBydeviceID:ctx.sn]) {
            //delete
            [coreData delete_mdev_msg_by_id:ctx.sn msg_id_min:dev.msg_id_min];
        }
        if (([coreData numberOfMsgIDBydeviceID:ctx.sn] >= ABS(ctx.counts)) && start_id <= [coreData maxMsgIDBydeviceID:ctx.sn]) {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:ABS(ctx.counts)];
            long prev_id = ctx.start_id;
            for (int i = 0; [coreData numberOfMsgIDBydeviceID:ctx.sn]; i++) {
                mdev_msg *msg = [coreData select_mdev_msg_by_id:ctx.sn msg_id:start_id - i flag:ctx.flag];
                
                if (msg && (prev_id - msg.msg_id == 1)) {
                    prev_id = msg.msg_id;
                    [arr addObject:msg];
                    if (arr.count == ABS(ctx.counts)) {
                        mcall_ret_msgs_get *ret =  [[mcall_ret_msgs_get alloc] init]  ;
                        ret.msg_arr = arr;
                        [ctx.target performSelector:ctx.on_event withObject:ret];
                        return 1;
                    }
                } else {
                    break;
                }
                
            }
            
        }
        
    }
    NSString *type = @"ccm_msg_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},flag:\"%d\",start_time:0,end_time:0,filter:\"%@\",start:%d,counts:%d}",[self mipc_build_nid], ctx.sn, ctx.flag, ctx.flag?@"record":@"", ctx.start_id, ctx.counts];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }
                   
                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_msgs_get *ret =  [[mcall_ret_msgs_get alloc] init]  ;
                   ret.ref = ctx.ref;
                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       long bound = 0, max_id = 0, min_id = 0;
                       struct json_object *messages = json_get_child_by_name(msg.data, NULL, len_str_def_const("messages")),*obj_msg = NULL;
                       json_get_child_long(msg.data, "bound", &bound);
                       json_get_child_long(msg.data, "max_id", &max_id);
                       json_get_child_long(msg.data, "min_id", &min_id);
                       
                       m_dev *dev = [weakSelf.devs get_dev_by_sn:ctx.sn];
                       
                       if(dev)
                       {
                           dev.msg_id_max = max_id;
                           dev.msg_id_min = min_id;
                       }
                       ret.bound = bound;
                       
                       if(messages
                          && (messages->type == ejot_array)
                          && (obj_msg = messages->v.array.list)
                          && (obj_msg->v.array.counts))
                       {
                           NSMutableArray *arr = [NSMutableArray arrayWithCapacity:obj_msg->v.array.counts];;
                           for (int i = 0; i < messages->v.array.counts; i++, obj_msg = obj_msg->in_parent.next)
                           {
                               mdev_msg *msg = [[mdev_msg alloc] initWithJson:obj_msg];
                               [arr addObject:msg];
                           }
                           ret.msg_arr = arr;
                           
                           if(weakSelf.msgs_need_cache)
                           {
                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                   CoreDataUtils *coreData = [CoreDataUtils deflautMIPCCoreData];
                                   
                                   for (mdev_msg *msg in arr) {
                                       if (nil == [coreData select_mdev_msg_by_id:msg.sn msg_id:msg.msg_id flag:NO]) {
                                           [coreData insert_mdev_msg:msg.sn mdev_msg:msg];
                                       }
                                   }
                               });
                           }
                       }
                   }
                   
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
                   
               }];
    
    return 1;
}

- (long)playback:(mcall_ctx_playback *)ctx
{

    if(![self check_ver:@"ccm_replay" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_replay";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},setup:{stream:\"RTP_Unicast\",trans:{proto:\"%@\"}},token:\"%@\"}}",
                           [self mipc_build_nid], ctx.sn, ctx.protocol, ctx.token];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_playback *ret =  [[mcall_ret_playback alloc] init]  ;
                   ret.ref = ctx.ref;
                   if(nil == ([weakSelf check_result:msg]))
                   {
                       struct len_str uri = {0};
                       json_get_child_string(msg.data, "url", &uri);
                       ret.url = uri.len?[NSString stringWithUTF8String:uri.data]:nil;
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)osd_get:(mcall_ctx_osd_get *)ctx
{

    if(![self check_ver:@"ccm_osd_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_osd_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_osd_get *ret =  [[mcall_ret_osd_get alloc] init]  ;
                   ret.ref = ctx.ref;
                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       struct len_str      s_text = {0}, s_date_format = {0};
                       int64_t s_text_enable = 0, s_week = 0, s_enable_12h = 0, s_date_enable = 0, s_time_enable = 0;
                       struct json_object  *obj_osd= (msg && msg.data)?json_get_child_by_name(msg.data, NULL, len_str_def_const("osd")):NULL,
                       *obj_datetime = obj_osd?json_get_child_by_name(obj_osd, NULL, len_str_def_const("date")):NULL;

                       json_get_child_string(obj_osd, "text", &s_text);
                       json_get_child_int64(obj_osd, "text_enable", &s_text_enable);
                       json_get_child_int64(obj_osd, "week", &s_week);
                       json_get_child_string(obj_datetime, "format", &s_date_format);
                       json_get_child_int64(obj_datetime, "enable_12h", &s_enable_12h);
                       json_get_child_int64(obj_datetime, "date_enable", &s_date_enable);
                       json_get_child_int64(obj_datetime, "time_enable", &s_time_enable);

                       ret.date_format  = s_date_format.len?[NSString stringWithUTF8String:s_date_format.data]:nil;
                       ret.date_enable  = s_date_enable;
                       ret.time_12h     = s_enable_12h;
                       ret.time_enable  = s_time_enable;
                       ret.week_enable  = s_week;
                       ret.text         = s_text.len?[NSString stringWithUTF8String:s_text.data]:nil;
                       ret.text_enable  = s_text_enable;
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)osd_set:(mcall_ctx_osd_set *)ctx
{

    if(![self check_ver:@"ccm_osd_set" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }
    NSString *userRegex = @"[A-Za-z0-9]{0,20}";
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userRegex];

    if(ctx.text && ![userPredicate evaluateWithObject:ctx.text])
    {
        mcall_ret_osd_get *ret =  [[mcall_ret_osd_get alloc] init]  ;
        ret.result = @"xxxxxxxxx";
        [ctx.target performSelector:ctx.on_event withObject:ret];
    }

    NSString *osd_json = [NSString stringWithFormat:@"osd:{text:\"%@\",text_enable:\"%d\",date:{format:\"%@\",enable_12h:\"%d\",date_enable:\"%d\",time_enable:\"%d\"},week:\"%d\"}", ctx.text?ctx.text:@"", ctx.text_enable, ctx.date_format, ctx.time_12h, ctx.date_enable, ctx.time_enable, ctx.week_enable];

    NSString *type = @"ccm_osd_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},%@}",[self mipc_build_nid], ctx.sn, osd_json];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_osd_set *ret =  [[mcall_ret_osd_set alloc] init]  ;
                   ret.ref = ctx.ref;
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)sd_get:(mcall_ctx_sd_get *)ctx
{

    if(![self check_ver:@"ccm_disk_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_disk_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",
                           [self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_sd_get *ret =  [[mcall_ret_sd_get alloc] init]  ;
                   ret.ref = ctx.ref;
                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       struct json_object *disks  = (msg && msg.data)?json_get_child_by_name(msg.data, NULL,len_str_def_const("disks")):NULL,
                       *sd_conf = disks?json_get_child_by_name(disks->v.array.list, NULL,len_str_def_const("conf")):NULL;
                       struct len_str status = {0};
                       long enable = 0, total_size = 0, used_size = 0, available_size = 0;

                       if(disks
                          && (disks->type == ejot_array)
                          && disks->v.array.counts)
                       {
                           json_get_child_string(disks->v.array.list, "stat", &status);
                           json_get_child_long(disks->v.array.list, "size", &total_size);
                           json_get_child_long(disks->v.array.list, "used_size", &used_size);
                           json_get_child_long(disks->v.array.list, "available_size", &available_size);
                           ret.status = status.len?[NSString stringWithUTF8String:status.data]:nil;
                           ret.capacity = total_size;
                           ret.usage = used_size;
                           ret.available_size = available_size;
                       }
                       json_get_child_long(sd_conf, "enable", &enable);
                       ret.enable = enable;
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)sd_set:(mcall_ctx_sd_set *)ctx
{

    if(![self check_ver:@"ccm_disk_ctl" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_disk_ctl";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},token:\"sd\",conf:{enable:%d},type:\"%@\"}",[self mipc_build_nid], ctx.sn, ctx.enable, ctx.ctrl?ctx.ctrl:@""];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_sd_set *ret =  [[mcall_ret_sd_set alloc] init]  ;
                   ret.ref = ctx.ref;
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)reboot:(mcall_ctx_reboot *)ctx
{

    NSString *type = @"ccm_reboot";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",
                           [self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_reboot *ret =  [[mcall_ret_reboot alloc] init]  ;
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)restore:(mcall_ctx_restore *)ctx
{

    NSString *type = @"ccm_restore";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},backup:\"%d\"}}",
    [self mipc_build_nid], ctx.sn, ctx.keep_base_cofig];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_restore *ret =  [[mcall_ret_restore alloc] init]  ;
                   ret.ref = ctx.ref;
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)upgrade_get:(mcall_ctx_upgrade_get *)ctx
{

    NSString *type = @"ccm_upgrade_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},check:\"1\"}",[self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:120
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_upgrade_get *ret =  [[mcall_ret_upgrade_get alloc] init]  ;
                   ret.ref = ctx.ref;
                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       struct json_object *task = json_get_child_by_name(msg.data, NULL, len_str_def_const("task"));
                       struct len_str cur_ver = {0}, valid_ver = {0},  img_ver = {0}, hw_ext = {0}, img_ext = {0},  prj_ext = {0}, status = {0};
                       long progress = 0;
                       json_get_child_string(msg.data, "_cur_ver", &cur_ver);
                       json_get_child_string(msg.data, "_valid_ver", &valid_ver);
                       json_get_child_string(msg.data, "img_ver", &img_ver);
                       json_get_child_string(msg.data, "hw_ext", &hw_ext);
                       json_get_child_string(msg.data, "img_ext", &img_ext);
                       json_get_child_string(msg.data, "prj_ext", &prj_ext);
                       json_get_child_long(task?task:msg.data, "progress", &progress);
                       json_get_child_string(task?task:msg.data, "stat", &status);
                      
                       ret.ver_current = cur_ver.len?[NSString stringWithUTF8String:cur_ver.data]:nil;
                       ret.ver_valid = valid_ver.len?[NSString stringWithUTF8String:valid_ver.data]:nil;
                       ret.ver_base = img_ver.len?[NSString stringWithUTF8String:img_ver.data]:nil;
                       ret.hw_ext = hw_ext.len?[NSString stringWithUTF8String:hw_ext.data]:nil;
                       ret.img_ext = img_ext.len?[NSString stringWithUTF8String:img_ext.data]:nil;
                       ret.prj_ext = prj_ext.len?[NSString stringWithUTF8String:prj_ext.data]:nil;
                       ret.status = status.len?[NSString stringWithUTF8String:status.data]:nil;
                       ret.progress = progress;
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)upgrade_set:(mcall_ctx_upgrade_set *)ctx
{

    NSString *type = @"ccm_upgrade";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},img_src:download}",[self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_upgrade_set *ret =  [[mcall_ret_upgrade_set alloc] init]  ;
                   ret.result = [weakSelf check_result:msg];
                   ret.ref = ctx.ref;

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
    }];

    return 1;
}

- (long)time_get:(mcall_ctx_time_get *)ctx
{
    
    if(![self check_ver:@"ccm_date_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    if(![self check_ver:@"ccm_ntp_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *type = @"ccm_date_get";
        NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[weakSelf mipc_build_nid], ctx.sn];
        
        if (!weakSelf.isNewSrv) {
            [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
        }
        [weakSelf call_asyn:weakSelf.srv
                         to:nil
                  to_handle:0
                       mqid:weakSelf.qid
                from_handle:[weakSelf createFromHandle]
                       type:type dataJson:data_json
                    timeout:30 usingBlock:^(mjson_msg *time_msg) {
                        
                        //check information
                        //[weakSelf check_msg_ret_result:time_msg];
                        mcall_ret_time_get *ret =  [[mcall_ret_time_get alloc] init]  ;
                        ret.ref = ctx.ref;
                        
                        if(nil == (ret.result = [weakSelf check_result:time_msg]))
                        {
                            struct json_object *UTCDateTime = json_get_child_by_name(time_msg.data, NULL, len_str_def_const("utc_date")),
                            *time = UTCDateTime?json_get_child_by_name(UTCDateTime, NULL, len_str_def_const("time")):NULL,
                            *date = UTCDateTime?json_get_child_by_name(UTCDateTime, NULL, len_str_def_const("date")):NULL;
                            long hour = 0, minute = 0, second = 0, year = 0, month = 0, day = 0;
                            
                            json_get_child_long(time, "hour", &hour);
                            json_get_child_long(time, "min", &minute);
                            json_get_child_long(time, "sec", &second);
                            json_get_child_long(date, "year", &year);
                            json_get_child_long(date, "mon",&month);
                            json_get_child_long(date, "day", &day);
                            
                            ret.hour = hour;
                            ret.min = minute;
                            ret.sec = second;
                            ret.year = year;
                            ret.mon = month;
                            ret.day = day;
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(),^{
                                if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                                {
                                    [ctx.target performSelector:ctx.on_event withObject:ret];
                                }
                                
                            });
                            return;
                        }
                        
                        NSString *ntp_type = @"ccm_ntp_get";
                        NSString *ntp_data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[weakSelf mipc_build_nid], ctx.sn];
                        
                        if (!weakSelf.isNewSrv) {
                            [[mipc_def_manager shared_def_manager] checkMsgRqt:&ntp_type dataJson:&ntp_data_json];
                        }
                        
                        [weakSelf call_asyn:weakSelf.srv
                                         to:nil
                                  to_handle:0
                                       mqid:weakSelf.qid
                                from_handle:[weakSelf createFromHandle]
                                       type:ntp_type
                                   dataJson:ntp_data_json
                                    timeout:30
                                 usingBlock:^(mjson_msg *ntp_msg) {
                                     //check information
                                     //[weakSelf check_msg_ret_result:ntp_msg];
                                     if(nil == (ret.result = [weakSelf check_result:ntp_msg]))
                                     {
                                         long auto_sync_enable = 0;
                                         struct len_str s_ip = {0}, s_timezone = {0};
                                         struct json_object  *info = json_get_child_by_name(ntp_msg.data, NULL, len_str_def_const("info")),
                                         *manual = info?json_get_child_by_name(info, NULL, len_str_def_const("manual")):NULL;
                                         json_get_child_long(info, "auto_sync_enable",&auto_sync_enable);
                                         if(manual && manual->type == ejot_array && manual->v.array.counts){json_get_child_string(manual->v.array.list, "ip", &s_ip);};
                                         json_get_child_string(info, "timezone",&s_timezone);
                                         
                                         ret.auto_sync = auto_sync_enable;
                                         ret.ntp_addr = s_ip.len?[NSString stringWithUTF8String:s_ip.data]:nil;
                                         ret.time_zone = s_timezone.len?[NSString stringWithUTF8String:s_timezone.data]:nil;
                                     }
                                     
                                     dispatch_async(dispatch_get_main_queue(),^{
                                         if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                                         {
                                             [ctx.target performSelector:ctx.on_event withObject:ret];
                                         }
                                         
                                     });
                                 }];
                    }];
        
        
    });
    
    return 2;
}

- (long)time_set:(mcall_ctx_time_set *)ctx
{
    
    if(![self check_ver:@"ccm_date_set" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    if(![self check_ver:@"ccm_ntp_set" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *time_json = [NSString stringWithFormat:@"type:\"%@\",timezone:\"%@\",utc_date:{time:{hour:\"%d\",min:\"%d\",sec:\"%d\"},date:{year:\"%d\",mon:\"%d\",day:\"%d\"}}",ctx.auto_sync?@"NTP":@"manually",ctx.time_zone,ctx.hour,ctx.min,ctx.sec,ctx.year,ctx.mon,ctx.day];
        NSString *ntp_json = [NSString stringWithFormat:@"auto_sync:\"%d\",dhcp:\"0\",manual:[{ip:\"%@\"}]",ctx.auto_sync, ctx.ntp_addr?ctx.ntp_addr:@""];
        
        NSString *type = @"ccm_date_set";
        NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},%@}",[weakSelf mipc_build_nid], ctx.sn, time_json];
        
        if (!weakSelf.isNewSrv) {
            [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
        }
        [weakSelf call_asyn:weakSelf.srv to:nil to_handle:0 mqid:weakSelf.qid from_handle:[weakSelf createFromHandle] type:type dataJson:data_json timeout:30 usingBlock:^(mjson_msg *time_msg) {
            //check information
            //[weakSelf check_msg_ret_result:time_msg];
            mcall_ret_time_get *ret =  [[mcall_ret_time_get alloc] init]  ;
            ret.ref = ctx.ref;
            if(nil != (ret.result = [weakSelf check_result:time_msg]))
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                    {
                        [ctx.target performSelector:ctx.on_event withObject:ret];
                    }
                    
                });
                
                return;
            }
            
            NSString *ntp_type = @"ccm_ntp_set";
            NSString *ntp_data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},%@}",[weakSelf mipc_build_nid], ctx.sn, ntp_json];
            
            if (!weakSelf.isNewSrv) {
                [[mipc_def_manager shared_def_manager] checkMsgRqt:&ntp_type dataJson:&ntp_data_json];
            }
            
            //check information
            //[weakSelf check_msg_ret_result:ntp_msg];
            [weakSelf call_asyn:weakSelf.srv to:nil to_handle:0 mqid:weakSelf.qid from_handle:[weakSelf createFromHandle] type:ntp_type dataJson:ntp_data_json timeout:30 usingBlock:^(mjson_msg *ntp_msg) {
                ret.result = [weakSelf check_result:ntp_msg];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                    {
                        [ctx.target performSelector:ctx.on_event withObject:ret];
                    }
                    
                });
            }];
        }];
        
    });
    
    return 2;
}

- (long)alarm_trigger_get:(mcall_ctx_trigger_action_get *)ctx
{

    if(![self check_ver:@"ccm_alert_dev_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_alert_dev_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_trigger_action_get*ret =  [[mcall_ret_trigger_action_get alloc] init]  ;
                   ret.ref = ctx.ref;
                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       struct json_object  *config = json_get_child_by_name(msg.data, NULL, len_str_def_const("conf"));
                       struct len_str  input = {0}, output = {0};
                       int64_t  sensitivity = 0, night_sensitivity = 0;

                       json_get_child_string(config, "io_in_mode", &input);
                       json_get_child_string(config, "io_out_mode", &output);
                       json_get_child_int64(config, "motion_level", &sensitivity);
                       json_get_child_int64(config, "motion_level_night", &night_sensitivity);

                       ret.input = input.len?[NSString stringWithUTF8String:input.data]:nil;
                       ret.output = output.len?[NSString stringWithUTF8String:output.data]:nil;
                       ret.sensitivity = (int)sensitivity;
                       ret.night_sensitivity = (int)night_sensitivity;
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)alarm_trigger_set:(mcall_ctx_trigger_action_set *)ctx
{

    if(![self check_ver:@"ccm_alert_dev_set" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_alert_dev_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},conf:{io_in_mode:\"%@\",io_out_mode:\"%@\",motion_level:\"%d\",motion_level_night:\"%d\"}}",
                           [self mipc_build_nid], ctx.sn, ctx.input , ctx.output, ctx.sensitivity,ctx.night_sensitivity];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_trigger_action_set *ret =  [[mcall_ret_trigger_action_set alloc] init]  ;
                   ret.ref = ctx.ref;
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)alarm_action_get:(mcall_ctx_alarm_action_get *)ctx
{

    if(![self check_ver:@"ccm_alert_action_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_alert_action_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //block
                   mcall_ret_alarm_action_get *ret =  [[mcall_ret_alarm_action_get alloc] init];
                   ret.ref = ctx.ref;

                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       struct json_object  *actions = json_get_child_by_name(msg.data, NULL, len_str_def_const("actions")), *action;
                       long l_enable = 0;
                       json_get_child_long(msg.data, "enable", &l_enable);
                       ret.enable = l_enable;
                       if(actions && (ejot_array == actions->type) && actions->v.array.counts)
                       {
                           NSMutableArray *actions_arr = [NSMutableArray arrayWithCapacity:2];
                           ret.alarm_items = actions_arr;
                           int i = 0;
                           for(action = actions->v.array.list,i = 0; (i<actions->v.array.counts); action = action->in_parent.next,i++)
                           {
                               alarm_action *_alarm_action =  [[alarm_action alloc] init]  ;
                               [actions_arr addObject:_alarm_action];
                               struct len_str      s_token={0}, s_name;
                               long l_enable = 0, l_iooutputenable = 0, l_snapshotenable = 0 , l_recordenable = 0, l_snapshotinterval = 0, l_prerecordtime = 0,
                               l_ioalerttime = 0;

                               json_get_child_string(action, "name", &s_name);
                               json_get_child_string(action, "token", &s_token);
                               json_get_child_long(action, "enable", &l_enable);
                               json_get_child_long(action, "io_out_enable", &l_iooutputenable);
                               json_get_child_long(action, "snapshot_enable", &l_snapshotenable);
                               json_get_child_long(action, "record_enable", &l_recordenable);
                               json_get_child_long(action, "snapshot_interval", &l_snapshotinterval);
                               json_get_child_long(action, "pre_record_time", &l_prerecordtime);
                               json_get_child_long(action, "io_alert_time", &l_ioalerttime);

                               _alarm_action.name              = s_name.len?[NSString stringWithUTF8String:s_name.data]:nil;
                               _alarm_action.token             = s_token.len?[NSString stringWithUTF8String:s_token.data]:nil;
                               _alarm_action.enable            = l_enable;
                               _alarm_action.io_out_enable     = l_iooutputenable;
                               _alarm_action.snapshot_enable   = l_snapshotenable;
                               _alarm_action.record_enable     = l_recordenable;
                               _alarm_action.snapshot_interval = (int)l_snapshotinterval;
                               _alarm_action.pre_record_lenght = (int)l_prerecordtime;
                               _alarm_action.io_alart_lenght = (int)l_ioalerttime;
                               struct  json_object *srcs = json_get_child_by_name(action, NULL, len_str_def_const("srcs")),*src = NULL,*devs = NULL,*dev = NULL;

                               if(srcs && (srcs->type == ejot_array) && srcs->v.array.counts)
                               {
                                   int j = 0;
                                   for (src = srcs->v.array.list; j < 1;src = src->in_parent.next, j++)
                                   {
                                       devs = json_get_child_by_name(src, NULL, len_str_def_const("devs"));
                                       if(devs && (ejot_array == devs->type) && devs->v.array.counts)
                                       {
                                           NSMutableArray *arr = [NSMutableArray arrayWithCapacity:3];
                                           dev = devs->v.array.list;
                                           do {
                                               struct len_str s_dev = {0};
                                               json_get_string(dev, &s_dev);
                                               if(s_dev.len)
                                               {
                                                   [arr addObject:[NSString stringWithUTF8String:s_dev.data]];
                                               }
                                           } while ((dev = dev->in_parent.next) != devs->v.array.list);
                                           _alarm_action.alarm_src = arr;
                                       }
                                   }
                               }

                           }
                       }
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)alarm_action_set:(mcall_ctx_alarm_action_set *)ctx
{

    if(![self check_ver:@"ccm_alert_action_set" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *json_actions = @"";
    for(alarm_action *action in ctx.alarm_items)
    {
        NSString *json_src = @"";
        for(NSArray *src in action.alarm_src)
        {
            json_src = [NSString stringWithFormat:@"%@%@%@",json_src,json_src.length?@",":@"",[NSString stringWithFormat:@"\"%@\"",src]];
        }
        NSString *json_srcs = json_src.length?[NSString stringWithFormat:@"srcs:[{devs:[%@]}]",json_src]:@"";

        NSString *json_action = [NSString stringWithFormat:@"token:\"%@\",enable:\"%d\",name:\"%@\",io_out_enable:\"%d\",snapshot_enable:\"%d\",record_enable:\"%d\",snapshot_interval:\"%d\",pre_record_time:\"%d\",io_alert_time:\"%d\"%@%@",action.token.length?action.token:@"",action.enable,action.name.length?action.name:@"",action.io_out_enable,action.snapshot_enable,action.record_enable,action.snapshot_interval,action.pre_record_lenght, action.io_alart_lenght, json_srcs.length?@",":@"",json_srcs.length?json_srcs:@""];

        json_actions = [NSString stringWithFormat:@"%@%@%@",json_actions,json_actions.length?@",":@"",[NSString stringWithFormat:@"{%@}",json_action]];
    }

    NSString *type = @"ccm_alert_action_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},enable:%d,actions:[%@]}",
                           [self mipc_build_nid], ctx.sn, ctx.enable,json_actions];
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //block
                   mcall_ret_alarm_action_set *ret =  [[mcall_ret_alarm_action_set alloc] init]  ;
                   ret.ref = ctx.ref;
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)audio_get:(mcall_ctx_audio_get *)ctx
{
    
    if(![self check_ver:@"ccm_mic_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    if(![self check_ver:@"ccm_speaker_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *type = @"ccm_mic_get";
        NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}", [weakSelf mipc_build_nid], ctx.sn];
        
        if (!weakSelf.isNewSrv) {
            [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
        }
        
        [weakSelf call_asyn:weakSelf.srv
                         to:nil
                  to_handle:0
                       mqid:weakSelf.qid
                from_handle:[weakSelf createFromHandle]
                       type:type
                   dataJson:data_json
                    timeout:30
                 usingBlock:^(mjson_msg *mic_msg) {
                     //check information
                     //[weakSelf check_msg_ret_result:mic_msg];
                     
                     mcall_ret_audio_get *ret =  [[mcall_ret_audio_get alloc] init]  ;
                     ret.ref = ctx.ref;
                     if(nil != (ret.result = [weakSelf check_result:mic_msg]))
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                             {
                                 [ctx.target performSelector:ctx.on_event withObject:ret];
                             }
                             
                         });
                         return;
                     }
                     else
                     {
                         struct json_object *conf = json_get_child_by_name(mic_msg.data, NULL, len_str_def_const("conf"));
                         long s_mic = 0;
                         if (conf && conf->type == ejot_array && conf->v.array.counts)
                         {
                             json_get_child_long(conf->v.array.list, "level", &s_mic);
                         }
                         ret.mic_level = (int)s_mic;
                     }
                     
                     NSString *s_type = @"ccm_speaker_get";
                     NSString *s_data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},token:\"ao0\"}", [weakSelf mipc_build_nid], ctx.sn];
                     
                     if (!weakSelf.isNewSrv) {
                         [[mipc_def_manager shared_def_manager] checkMsgRqt:&s_type dataJson:&s_data_json];
                     }
                     
                     [weakSelf call_asyn:weakSelf.srv to:nil to_handle:0 mqid:weakSelf.qid from_handle:[weakSelf createFromHandle] type:s_type dataJson:s_data_json timeout:30 usingBlock:^(mjson_msg *speaker_msg) {
                         //check information
                         //            [weakSelf check_msg_ret_result:speaker_msg];
                         
                         if(nil == (ret.result = [weakSelf check_result:speaker_msg]))
                         {
                             long s_speaker = 0;
                             struct json_object *audio = json_get_child_by_name(speaker_msg.data, NULL, len_str_def_const("conf"));
                             json_get_child_long(audio, "level", &s_speaker);
                             ret.speaker_level = (int)s_speaker;
                         }
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                             {
                                 [ctx.target performSelector:ctx.on_event withObject:ret];
                             }
                             
                         });
                     }];
                 }];
        
    });
    return 2;
}

- (long)audio_set:(mcall_ctx_audio_set *)ctx
{
    
    if(![self check_ver:@"ccm_mic_set" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    if(![self check_ver:@"ccm_speaker_set" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *type = @"ccm_mic_set";
        NSString * data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},conf:{entity:{name:\"asc3\",use_counts:\"0\",token:\"asc3\"},token:\"dev3\",level:\"%d\",silent:\"0\"}}",[weakSelf mipc_build_nid],ctx.sn,ctx.mic_level];
        
        if (!weakSelf.isNewSrv) {
            [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
        }
        
        [weakSelf call_asyn:weakSelf.srv to:nil to_handle:0 mqid:weakSelf.qid from_handle:[weakSelf createFromHandle] type:type dataJson:data_json timeout:30 usingBlock:^(mjson_msg *mic_msg) {
            //check information
            //[weakSelf check_msg_ret_result:mic_msg];
            
            mcall_ret_audio_set *ret =  [[mcall_ret_audio_set alloc] init]  ;
            ret.ref = ctx.ref;
            if(nil != (ret.result = [weakSelf check_result:mic_msg]))
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                    {
                        [ctx.target performSelector:ctx.on_event withObject:ret];
                    }
                    
                });
                return;
            }
            
            NSString *s_type = @"ccm_speaker_set";
            NSString *s_data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},conf:{token:\"ao0\",level:\"%d\"}}",[weakSelf mipc_build_nid],ctx.sn,ctx.speaker_level];
            
            if (!weakSelf.isNewSrv) {
                [[mipc_def_manager shared_def_manager] checkMsgRqt:&s_type dataJson:&s_data_json];
            }
            
            [weakSelf call_asyn:weakSelf.srv to:nil to_handle:0 mqid:weakSelf.qid from_handle:[weakSelf createFromHandle] type:s_type dataJson:s_data_json timeout:30 usingBlock:^(mjson_msg *speaker_msg) {
                //check information
                //[weakSelf check_msg_ret_result:speaker_msg];
                
                ret.result = [weakSelf check_result:speaker_msg];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                    {
                        [ctx.target performSelector:ctx.on_event withObject:ret];
                    }
                    
                });
            }];
        }];
    });
    
    return 2;
}

- (long)cam_get:(mcall_ctx_cam_get *)ctx
{
    
    if(![self check_ver:@"ccm_video_srcs_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    if(![self check_ver:@"ccm_misc_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *type = @"ccm_video_srcs_get";
        NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}", [weakSelf mipc_build_nid], ctx.sn];
        
        if (!weakSelf.isNewSrv) {
            [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
        }
        
        [weakSelf call_asyn:weakSelf.srv
                         to:nil
                  to_handle:0
                       mqid:weakSelf.qid
                from_handle:[weakSelf createFromHandle]
                       type:type
                   dataJson:data_json
                    timeout:30
                 usingBlock:^(mjson_msg *img_msg) {
                     //check information
                     //        [weakSelf check_msg_ret_result:img_msg];
                     
                     mcall_ret_cam_get *ret =  [[mcall_ret_cam_get alloc] init]  ;
                     ret.ref = ctx.ref;
                     
                     if(nil != (ret.result = [weakSelf check_result:img_msg]))
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                             {
                                 [ctx.target performSelector:ctx.on_event withObject:ret];
                             }
                             
                         });
                         return;
                     }
                     else
                     {
                         struct json_object  *vss = json_get_child_by_name(img_msg.data, NULL, len_str_def_const("vss")),
                         *extension = vss?json_get_child_by_name(vss->v.array.list, NULL, len_str_def_const("extension")):NULL,
                         *conf = extension?json_get_child_by_name(extension, NULL, len_str_def_const("conf")):NULL;
                         
                         long brightness = 50, color_saturation = 70, contrast = 60, sharpness = 6;
                         struct len_str mode = {0};
                         
                         json_get_child_long(conf, "brightness", &brightness);
                         json_get_child_long(conf, "color_saturation", &color_saturation);
                         json_get_child_long(conf, "contrast", &contrast);
                         json_get_child_long(conf, "sharpness", &sharpness);
                         json_get_child_string(conf, "mode", &mode);
                         
                         ret.brightness = (int)brightness;
                         ret.saturation = (int)color_saturation;
                         ret.contrast = (int)contrast;
                         ret.sharpness = (int)sharpness;
                         ret.day_night = mode.len?[NSString stringWithUTF8String:mode.data]:@"auto";
                     }
                     
                     NSString *m_type = @"ccm_misc_get";
                     NSString *m_data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}", [weakSelf mipc_build_nid], ctx.sn];
                     
                     if (!weakSelf.isNewSrv) {
                         [[mipc_def_manager shared_def_manager] checkMsgRqt:&m_type dataJson:&m_data_json];
                     }
                     [weakSelf call_asyn:weakSelf.srv to:nil
                               to_handle:0 mqid:weakSelf.qid from_handle:[weakSelf createFromHandle] type:m_type dataJson:m_data_json timeout:30 usingBlock:^(mjson_msg *misc_msg) {
                                   //check information
                                   //[weakSelf check_msg_ret_result:misc_msg];
                                   
                                   if(nil == (ret.result = [weakSelf check_result:misc_msg]))
                                   {
                                       struct len_str resolute = {0};
                                       struct json_object *info = json_get_child_by_name(misc_msg.data, NULL, len_str_def_const("info"));
                                       json_get_child_string(misc_msg.data, "resolute", &resolute);
                                       long flip = 0, power = 0;
                                       json_get_child_long(info, "flip", &flip);
                                       json_get_child_long(info, "power_freq", &power);

                                       ret.flip = flip;
                                       ret.flicker_freq = (int)power;
                                       ret.resolute = resolute.len ? [NSString stringWithUTF8String:resolute.data] : nil;
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                                       {
                                           [ctx.target performSelector:ctx.on_event withObject:ret];
                                       }
                                       
                                   });
                               }];
                     
                 }];
        
    });
    
    return 2;
}

- (long)cam_set:(mcall_ctx_cam_set *)ctx
{
    
    if(![self check_ver:@"ccm_img_set" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    if(![self check_ver:@"ccm_misc_set" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *conf = [NSString stringWithFormat:@"{brightness:%d,color_saturation:%d,contrast:%d,sharpness:%d,mode:\"%@\"}",ctx.brightness,ctx.saturation,ctx.contrast,ctx.sharpness,ctx.day_night.length?ctx.day_night:@"auto"];
        
        NSString *type = @"ccm_img_set";
        NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},token:\"vs0\",conf:%@}",[weakSelf mipc_build_nid], ctx.sn, conf];
        
        if (!weakSelf.isNewSrv) {
            [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
        }
        
        [weakSelf call_asyn:weakSelf.srv to:nil to_handle:0 mqid:weakSelf.qid from_handle:[weakSelf createFromHandle] type:type dataJson:data_json timeout:30 usingBlock:^(mjson_msg *img_msg) {
            //check information
            //        [weakSelf check_msg_ret_result:img_msg];
            
            mcall_ret_cam_get *ret =  [[mcall_ret_cam_get alloc] init]  ;
            ret.ref = ctx.ref;
            if(nil != (ret.result = [weakSelf check_result:img_msg]))
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                    {
                        [ctx.target performSelector:ctx.on_event withObject:ret];
                    }
                    
                });
                return;
            }
            
            NSString *m_type = @"ccm_misc_set";
            NSString *m_data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},info:{flip:\"%d\",power_freq:\"%d\"},resolute:\"%@\"}",[weakSelf mipc_build_nid], ctx.sn, ctx.flip,ctx.flicker_freq,ctx.resolute];
            
            if (!weakSelf.isNewSrv) {
                [[mipc_def_manager shared_def_manager] checkMsgRqt:&m_type dataJson:&m_data_json];
            }
            
            //check information
            //[weakSelf check_msg_ret_result:misc_msg];
            [weakSelf call_asyn:weakSelf.srv to:nil to_handle:0 mqid:weakSelf.qid from_handle:[weakSelf createFromHandle] type:m_type dataJson:m_data_json timeout:30 usingBlock:^(mjson_msg *misc_msg) {
                ret.result = [weakSelf check_result:misc_msg];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                    {
                        [ctx.target performSelector:ctx.on_event withObject:ret];
                    }
                    
                });
            }];
        }];
    });
    
    return 2;
}

- (long)net_get:(mcall_ctx_net_get *)ctx
{

//    if(![self check_ver:@"ccm_net_get" sn:ctx.sn])
//    {
//        [ctx.target performSelector:ctx.on_event withObject:nil];
//
//        return 0;
//    }

    NSString *type = @"ccm_net_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},tokens:[\"eth0\",\"ra0\"],items:[\"all\",\"all\"],force_scan:\"%d\"}",[self mipc_build_nid], ctx.sn, ctx.force_scan];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //block
                   mcall_ret_net_get *ret =  [[mcall_ret_net_get alloc] init]  ;
                   ret.ref = ctx.ref;
                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       struct json_object  *net_info = json_get_child_by_name(msg.data, NULL, len_str_def_const("info")),*ifs = net_info?json_get_child_by_name(net_info, NULL, len_str_def_const("ifs")):NULL;
                       if(ifs && ifs->type == ejot_array && ifs->v.array.counts)
                       {
                           NSMutableArray *nets_arr = [NSMutableArray arrayWithCapacity:2];
                           ret.networks = nets_arr;
                           struct json_object *obj_ifs = ifs->v.array.list;
                           for (int i = 0; i < ifs->v.array.counts; i++, obj_ifs = obj_ifs->in_parent.next)
                           {
                               net_obj *net =  [[net_obj alloc] init]  ;
                               [nets_arr addObject:net];
                               struct len_str ifs_token = {0};
                               long ifs_enabled = 0;
                               json_get_child_string(obj_ifs, "token", &ifs_token);
                               json_get_child_long(obj_ifs, "enabled", &ifs_enabled);
                               net.token = ifs_token.len?[NSString stringWithUTF8String:ifs_token.data]:nil;
                               net.enable = ifs_enabled;

                               /*----------------- phy -------------*/
                               struct json_object *phy = json_get_child_by_name(obj_ifs, NULL, len_str_def_const("phy")),
                               *phy_info = json_get_child_by_name(phy, NULL, len_str_def_const("info")),
                               *phy_conf = json_get_child_by_name(phy, NULL, len_str_def_const("conf"));
                               struct len_str phy_mode = {0}, phy_name = {0}, phy_type = {0}, phy_mac = {0}, phy_status = {0};
                               net_info_obj *info =  [[net_info_obj alloc] init]  ;
                               net.info = info;
                               json_get_child_string(phy_info, "name", &phy_name);
                               json_get_child_string(phy_info, "type", &phy_type);
                               json_get_child_string(phy_info, "mac", &phy_mac);
                               json_get_child_string(phy_info, "stat", &phy_status);
                               json_get_child_string(phy_conf, "mode", &phy_mode);
                               info.name = phy_name.len?[NSString stringWithUTF8String:phy_name.data]:nil;
                               info.type = phy_type.len?[NSString stringWithUTF8String:phy_type.data]:nil;
                               info.mode = phy_mode.len?[NSString stringWithUTF8String:phy_mode.data]:nil;
                               info.status = phy_status.len?[NSString stringWithUTF8String:phy_status.data]:nil;
                               info.mac =  phy_mac.len?[NSString stringWithUTF8String:phy_mac.data]:nil;

                               /* ---------------- ipv4 -------------*/
                               struct json_object *ipv4 = json_get_child_by_name(obj_ifs, NULL, len_str_def_const("ipv4")),
                               *ipv4_info = json_get_child_by_name(ipv4, NULL, len_str_def_const("info")),
                               *ipv4_conf = json_get_child_by_name(ipv4, NULL, len_str_def_const("conf")),*ipv4_static_ip = NULL,*ipv4_ip = NULL;
                               struct len_str ipv4_mode = {0}, ipv4_status = {0}, ipv4_addr = {0}, ipv4_gw = {0}, ipv4_mask = {0};
                               long ipv4_enable = 0;
                               ip_obj *ip =  [[ip_obj alloc] init]  ;
                               net.ip = ip;
                               json_get_child_long(ipv4_conf, "enabled", &ipv4_enable);
                               json_get_child_string(ipv4_info, "stat", &ipv4_status);
                               json_get_child_string(ipv4_conf, "mode", &ipv4_mode);
                               if(!len_str_casecmp_const(&ipv4_mode, "static"))
                               {
                                   ipv4_static_ip = json_get_child_by_name(ipv4_conf, NULL, len_str_def_const("static_ip"));
                                   json_get_child_string(ipv4_static_ip, "addr",&ipv4_addr);
                                   json_get_child_string(ipv4_static_ip, "gw",&ipv4_gw);
                                   json_get_child_string(ipv4_static_ip, "mask",&ipv4_mask);
                               }
                               else
                               {
                                   ipv4_ip = json_get_child_by_name(ipv4_info, NULL, len_str_def_const("ip"));
                                   json_get_child_string(ipv4_ip, "addr",&ipv4_addr);
                                   json_get_child_string(ipv4_ip, "gw",&ipv4_gw);
                                   json_get_child_string(ipv4_ip, "mask",&ipv4_mask);
                               }
                               ip.enable = ipv4_enable;
                               ip.status = ipv4_status.len?[NSString stringWithUTF8String:ipv4_status.data]:nil;
                               ip.dhcp = !len_str_casecmp_const(&ipv4_mode, "dhcp");
                               ip.ip = ipv4_addr.len?[NSString stringWithUTF8String:ipv4_addr.data]:nil;
                               ip.mask = ipv4_mask.len?[NSString stringWithUTF8String:ipv4_mask.data]:nil;
                               ip.gateway = ipv4_gw.len?[NSString stringWithUTF8String:ipv4_gw.data]:nil;

                               /* -------------by wifi ----------*/
                               if(!len_str_casecmp_const(&ifs_token, "ra0"))
                               {
                                   /*--------------wifi_client-----------*/
                                   struct json_object *wifi_client = json_get_child_by_name(obj_ifs, NULL, len_str_def_const("wifi_client")),
                                   *wifi_client_conf = json_get_child_by_name(wifi_client, NULL, len_str_def_const("conf")),
                                   *wifi_client_info = json_get_child_by_name(wifi_client, NULL, len_str_def_const("info"));
                                   long wifi_enable = 0;
                                   struct len_str ssid = {0}, key = {0}, wifi_status = {0};
                                   json_get_child_long(wifi_client_conf, "enabled", &wifi_enable);
                                   json_get_child_string(wifi_client_conf, "ssid", &ssid);
                                   json_get_child_string(wifi_client_conf, "key", &key);
                                   json_get_child_string(wifi_client_info, "stat", &wifi_status);


                                   net.use_wifi_enable = wifi_enable;
                                   net.use_wifi_passwd = key.len?[NSString stringWithCString:key.data encoding:NSASCIIStringEncoding]:nil;
                                   net.use_wifi_ssid = ssid.len?[NSString stringWithCString:ssid.data encoding:NSASCIIStringEncoding]:nil;
                                   net.use_wifi_status = wifi_status.len?[NSString stringWithCString:wifi_status.data encoding:NSASCIIStringEncoding]:nil;

                                   /*------------wifi_client -> wifi list -----------*/
                                   struct json_object *wifi_list = json_get_child_by_name(wifi_client, NULL, len_str_def_const("ap_list"));
                                   if(wifi_list && wifi_list->type == ejot_array && wifi_list->v.array.counts)
                                   {
                                       NSMutableArray *wifi_list_arr = [NSMutableArray arrayWithCapacity:wifi_list->v.array.counts];
                                       struct json_object *wifi_list_obj = wifi_list->v.array.list;
                                       for(int i = 0; i < wifi_list->v.array.counts; i++, wifi_list_obj = wifi_list_obj->in_parent.next)
                                       {
                                           struct len_str wifi_ssid = {0};
                                           long quality = 0, signal_level = 0;
                                           json_get_child_long(wifi_list_obj, "quality", &quality);
                                           json_get_child_long(wifi_list_obj, "signal_level", &signal_level);
                                           json_get_child_string(wifi_list_obj, "ssid", &wifi_ssid);
                                           wifi_obj *wifi =  [[wifi_obj alloc] init]  ;
                                           wifi.ssid = wifi_ssid.len?[NSString stringWithUTF8String:wifi_ssid.data]:nil;
                                           wifi.signal_level = (int)signal_level;
                                           wifi.quality = (int)quality;
                                           [wifi_list_arr addObject:wifi];
                                       }
                                       net.wifi_list = wifi_list_arr;
                                   }

                                   /*------------dhcp_srv----------------*/
                                   struct json_object *dhcp_srv_json = json_get_child_by_name(obj_ifs, NULL, len_str_def_const("dhcp_srv")),
                                   *dhcp_srv_conf = json_get_child_by_name(dhcp_srv_json, NULL, len_str_def_const("conf"));
                                   long dhcp_srv_enable = 0;
                                   struct len_str dhcp_srv_gw = {0}, dhcp_srv_start = {0}, dhcp_srv_end = {0};
                                   json_get_child_long(dhcp_srv_conf, "enabled", &dhcp_srv_enable);
                                   json_get_child_string(dhcp_srv_conf, "gw", &dhcp_srv_gw);
                                   json_get_child_string(dhcp_srv_conf, "ip_start", &dhcp_srv_start);
                                   json_get_child_string(dhcp_srv_conf, "ip_end", &dhcp_srv_end);

                                   dhcp_srv_obj *dhcp_srv =  [[dhcp_srv_obj alloc] init]  ;
                                   dhcp_srv.enable = dhcp_srv_enable;
                                   dhcp_srv.gateway = dhcp_srv_gw.len?[NSString stringWithUTF8String:dhcp_srv_gw.data]:nil;
                                   dhcp_srv.start_ip = dhcp_srv_start.len?[NSString stringWithUTF8String:dhcp_srv_start.data]:nil;
                                   dhcp_srv.end_ip = dhcp_srv_end.len?[NSString stringWithUTF8String:dhcp_srv_end.data]:nil;
                                   net.dhcp_srv = dhcp_srv;
                               }
                           }
                       }

                       struct json_object *dns_json = json_get_child_by_name(net_info, NULL, len_str_def_const("dns")),
                       *dns_conf = json_get_child_by_name(dns_json, NULL, len_str_def_const("conf")),
                       *dns_info = json_get_child_by_name(dns_json, NULL, len_str_def_const("info"));
                       long dns_enable = 0;
                       struct len_str dns_mode = {0}, dns_status = {0}, dns_ip = {0}, dns_secondary = {0};
                       json_get_child_long(dns_conf, "enabled",&dns_enable);
                       json_get_child_string(dns_conf, "mode", &dns_mode);
                       json_get_child_string(dns_info, "stat", &dns_status);
                       if(len_str_casecmp_const(&dns_mode, "dhcp"))
                       {
                           struct json_object *dns_ip_json = json_get_child_by_name(dns_conf, NULL, len_str_def_const("static_dns"));
                           if(dns_ip_json && dns_ip_json->type == ejot_array && dns_ip_json->v.array.counts)
                           {
                               struct json_object *dns_ip_obj = dns_ip_json->v.array.list;
                               json_get_string(dns_ip_obj, &dns_ip);
                               if(dns_ip_json->v.array.counts > 1)
                               {
                                   json_get_string(dns_ip_obj->in_parent.next, &dns_secondary);
                               }
                           }
                       }
                       else
                       {
                           struct json_object *dns_ip_json = json_get_child_by_name(dns_info, NULL, len_str_def_const("dns"));
                           if(dns_ip_json && dns_ip_json->type == ejot_array && dns_ip_json->v.array.counts)
                           {
                               struct json_object *dns_ip_obj = dns_ip_json->v.array.list;
                               json_get_string(dns_ip_obj, &dns_ip);
                               if(dns_ip_json->v.array.counts > 1)
                               {
                                   json_get_string(dns_ip_obj->in_parent.next, &dns_secondary);
                               }
                           }
                       }
                       dns_obj *dns =  [[dns_obj alloc] init]  ;
                       dns.enable = dns_enable;
                       dns.dhcp = !len_str_casecmp_const(&dns_mode, "dhcp");
                       dns.status = dns_status.len?[NSString stringWithUTF8String:dns_status.data]:nil;
                       dns.dns = dns_ip.len?[NSString stringWithUTF8String:dns_ip.data]:nil;
                       dns.secondary_dns = dns_secondary.len?[NSString stringWithUTF8String:dns_secondary.data]:nil;
                       ret.dns = dns;
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)net_set:(mcall_ctx_net_set *)ctx
{

//    if(![self check_ver:@"ccm_net_set" sn:ctx.sn])
//    {
//        [ctx.target performSelector:ctx.on_event withObject:nil];
//
//        return 0;
//    }

    NSString *ifss = @"";
    for(net_obj *net in ctx.networks)
    {
        NSString *ipv4, *info, *ifs;
        if(net.enable)
        {
            if(net.ip.dhcp)
            {
                ipv4 = [NSString stringWithFormat:@"ipv4:{conf:{enabled:\"%d\",mode:\"dhcp\"}}",net.ip.enable];
            }
            else
            {

                ipv4 = [NSString stringWithFormat:@"ipv4:{conf:{enabled:\"%d\",mode:\"static\",static_ip:{addr:\"%@\",gw:\"%@\",mask:\"%@\"}}}",net.ip.enable,net.ip.ip.length?net.ip.ip:@"",net.ip.gateway.length?net.ip.gateway:@"",net.ip.mask.length?net.ip.mask:@""];
            }

            if([@"ra0" isEqualToString:net.token])
            {

                if([net.info.mode isEqualToString:@"wificlient"])
                {
                    const char *wifiName = [net.use_wifi_ssid UTF8String];
                    const char *wifiPassword = [net.use_wifi_passwd UTF8String];
                    struct json_object *obj_con = json_create_object(NULL, 0, NULL);
                    json_create_string(obj_con, strlen("ssid"), "ssid", strlen(wifiName), (char *)wifiName);
                    json_create_string(obj_con, strlen("key"), "key", strlen(wifiPassword), (char *)wifiPassword);
                    unsigned long buf_size = 20480;
                    char *buf_con = malloc(buf_size);
                    json_encode(obj_con, buf_con, buf_size);
                    
                    info = [NSString stringWithFormat:@"phy:{conf:{mode:\"wificlient\",mtu:\"1500\"}},wifi_client:{conf:%s}", buf_con];
                }
                else
                {
                    info = [NSString stringWithFormat:@"phy:{conf:{mode:\"adhoc\",mtu:\"1500\"}}"];
                }
            }
            else
            {
                info = @"phy:{conf:{mode:\"ether\",mtu:\"1500\"}}";
            }
            
            ifs = [NSString stringWithFormat:@"ifs:{token:\"%@\",enabled:\"1\",%@,%@}",net.token, ipv4, info];
//          ifs = [NSString stringWithFormat:@"ifs:{token:\"%@\",enabled:\"1\",%@}",net.token, info];
        }
        else
        {
            ifs = [NSString stringWithFormat:@"ifs:{token:\"%@\",enabled:\"0\"}",net.token];
        }

        ifss = [NSString stringWithFormat:@"%@%@%@",ifss, ifss.length?@",":@"", ifs];
    }
    
    NSString *dns, *net_json;
    if(ctx.dns.dhcp)
    {
        dns = [NSString stringWithFormat:@"dns:{conf:{enalbed:\"%d\",mode:\"dhcp\"}}", ctx.dns.enable];
    }
    else
    {
        dns = [NSString stringWithFormat:@"dns:{conf:{enalbed:\"%d\",mode:\"static\",static_dns:[\"%@\",\"%@\"]}}", ctx.dns.enable, ctx.dns.dns.length?ctx.dns.dns:@"", ctx.dns.secondary_dns.length?ctx.dns.secondary_dns:@""];
    }

    net_json = [NSString stringWithFormat:@"info:{%@,%@}", ifss, dns];

    NSString *type = @"ccm_net_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},%@}",[self mipc_build_nid], ctx.sn,net_json];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //block
                   mcall_ret_net_set *ret =  [[mcall_ret_net_set alloc] init]  ;
                   ret.ref = ctx.ref;
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

//{sess:{nid:"MB6XWc4iRXhkNmuZegsjBBxBCmMBo3k",sn:"1jfiegbpweehq"},info:{ifs:{token:"eth0",enabled:"1",phy:{conf:{mode:"ether",mtu:"1500"}}},dns:{conf:{enalbed:"1",mode:"dhcp"}}}}
//{nid:"MH_b9KA4woUP7QYyRgz5ijJBTmMBWcA",sn:"1jfiegbpweehq"},info:{ifs:{token:"eth0",enabled:"1",phy:{conf:{mode:"ether",mtu:"1500"}}},dns:{conf:{enalbed:"1",mode:"dhcp"}}}}
//{nid:MDuFwrik03Wjk8CXS1nMf9dCF9pjAXUw, sn:1jfiegbpweehq}, info:{ifs:{token:'eth0', enabled:1,ipv4:{conf:{mode:dhcp, enabled:1}}},dns:{conf:{enabled:1, mode:'dhcp', static_dns:['null', 'null']}}}}. mcld_agent.java:2068
//
//{nid:MOuzyVQ6bu_xCOR2VF5P0T1CBzdjBmw2, sn:1jfiegbpxqmfa}, info:{ifs:{token:'ra0', enabled:1,ipv4:{conf:{mode:dhcp, enabled:1}},phy:{conf:{ mode:'wificlient', mtu:1500}},wifi_client:{conf:{enabled:1, ssid:'null',key:'ÃÂÃÂ¾ÃÂÃÂ¾'}}},dns:{conf:{enabled:1, mode:'dhcp', static_dns:['192.168.1.1', '8.8.8.8']}}}}. mcld_agent.java:2068
- (long)video_get:(mcall_ctx_video_get *)ctx
{

    if(![self check_ver:@"ccm_profiles_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];

        return 0;
    }

    NSString *type = @"ccm_profiles_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}", [self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //block
                   mcall_ret_video_get *ret =  [[mcall_ret_video_get alloc] init]  ;

                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       // srv bug
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

- (long)video_set:(mcall_ctx_video_set *)ctx
{

    NSString *type = @"ccm_profiles_set";
    NSString *data_json = @"";

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //block
                   mcall_ret_video_get *ret =  [[mcall_ret_video_get alloc] init]  ;
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

-(long)alarm_mask_get:(mcall_ctx_alarm_mask_get *)ctx
{
    NSString *type = @"ccm_motion_mask_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_alarm_mask_get *ret = [[mcall_ret_alarm_mask_get alloc] init];
                   ret.result = [weakSelf check_result:msg];

                   if (nil == ret.result) {
                       struct json_object *obj_mask = json_get_child_by_name(msg.data, NULL, len_str_def_const("conf"));

                       long enable, matrix_height, matrix_width;
                       json_get_child_long(obj_mask, "enable", &enable);
                       json_get_child_long(obj_mask, "matrix_height", &matrix_height);
                       json_get_child_long(obj_mask, "matrix_width", &matrix_width);

                       ret.enable = enable;
                       ret.matrix_height = matrix_height;
                       ret.matrix_width = matrix_width;

                       struct json_object *obj_pos = json_get_child_by_name(obj_mask, NULL, len_str_def_const("pos"));

                       if (obj_pos && obj_pos->type == ejot_array && obj_pos->v.array.counts)
                       {
                           struct json_object *obj_list = obj_pos->v.array.list;

                           NSMutableDictionary *masks = [NSMutableDictionary dictionary];

                           for (int i = 0; i < obj_pos->v.array.counts; i++, obj_list = obj_list->in_parent.next)
                           {
                               long index = 0;
                               json_get_child_long(obj_list, "index", &index);

                               struct json_object *obj_bitmap = json_get_child_by_name(obj_list, NULL, len_str_def_const("bitmap"));
                               if (obj_bitmap->type == ejot_array && obj_bitmap->v.array.counts) {
                                   struct json_object *bitmap_list = obj_bitmap->v.array.list;
                                   NSMutableArray *bitmapArray = [NSMutableArray array];

                                   for (int i = 0; i < obj_bitmap->v.array.counts; i++, bitmap_list = bitmap_list->in_parent.next) {
                                       NSString *bit = [NSString stringWithUTF8String:bitmap_list->v.string.data];
                                       [bitmapArray addObject:bit];
                                   }

                                   [masks setObject:bitmapArray forKey:[NSString stringWithFormat:@"%ld", index]];

                               }
                           }

                           ret.masks = masks;
                       }

                       if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                           [ctx.target performSelector:ctx.on_event withObject:ret];
                       }
                   }
    }];


    return 1;
}

-(long)alarm_mask_set:(mcall_ctx_alarm_mask_set *)ctx
{
    NSString *type = @"ccm_motion_mask_set";
    NSString *data_json =  [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},conf:{enable:\"%ld\",matrix_width:\"%ld\",matric_height:\"%ld\",pos:[", [self mipc_build_nid], ctx.sn, ctx.enable, ctx.matrix_width , ctx.matrix_height];
    
    NSArray *indexKeys = ctx.masks.allKeys;
    for (int j = 0; j < indexKeys.count; j++) {
        NSString *key = [indexKeys objectAtIndex:j];
        data_json = [data_json stringByAppendingFormat:@"{index:\"%@\",bitmap:[", key];
        
        NSArray *pos = [ctx.masks objectForKey:key];
        for (int i = 0; i < pos.count; i++) {
            if (i < pos.count - 1) {
                data_json = [data_json stringByAppendingFormat:@"%@,", pos[i]];
            }
            else if (j != indexKeys.count - 1)
            {
                data_json = [data_json stringByAppendingFormat:@"%@]},", pos[i]];
            }else{
                data_json = [data_json stringByAppendingFormat:@"%@]}", pos[i]];
            }
        }
    }
    data_json = [data_json stringByAppendingString:@"]}}"];
    NSLog(@"%@", data_json);
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }
                   
//                   [weakSelf check_msg_ret_result:msg];
                   
                   mcall_ret_alarm_mask_set *ret = [[mcall_ret_alarm_mask_set alloc] init];
                   ret.result = [weakSelf check_result:msg];
                   
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
                   
               }];
    
    return 1;
}

- (long)notification_get:(mcall_ctx_notification_get*)ctx;
{
    NSString *type = @"ccm_msg_filter_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}", [self mipc_build_nid], ctx.sn];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];
                   
                   mcall_ret_notification_get *ret = [[mcall_ret_notification_get alloc] init];
                   ret.result = [self check_result:msg];
                   
                   if (nil == ret.result) {
                       struct len_str filter = {0};
                       json_get_child_string(msg.data, "pub_filter", &filter);
                       
                       NSString *filerStr = filter.len ? [NSString stringWithUTF8String:filter.data]:nil;
                       if (filerStr) {
                           ret.alert = [filerStr rangeOfString:@"alert"].length?NO:YES;
                           ret.snapshot = [filerStr rangeOfString:@"snapshot"].length?NO:YES;
                           ret.record = [filerStr rangeOfString:@"record"].length?NO:YES;
                       }
                   }
                   
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
                   
               }];
    
    return 1;
}

- (long)notification_set:(mcall_ctx_notification_set*)ctx
{
    NSString *type = @"ccm_msg_filter_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},gen_filter:'{type:[]}',pub_filter:'{type:[\"%@\",\"%@\",\"%@\"]}'}", [self mipc_build_nid], ctx.sn, ctx.alert?nil:@"alert", ctx.snapshot?nil:@"snapshot", ctx.record?nil:@"record"];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof (self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];
                   
                   mcall_ret_notification_set *ret = [[mcall_ret_notification_set alloc] init];
                   ret.result = [weakSelf check_result:msg];
                   
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
               }];
    
    return 1;
}

- (long)alarm_curise_get:(mcall_ctx_cursise_get*)ctx
{
    NSString *type = @"ccm_curise_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}", [self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;

    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_curise_get *ret = [[mcall_ret_curise_get alloc] init];
                   ret.result = [weakSelf check_result:msg];

                   if(nil == ret.result) {
                       struct json_object *obj_curise = json_get_child_by_name(msg.data, NULL, len_str_def_const("curise_info"));
                       struct json_object *obj_points = json_get_child_by_name(obj_curise, NULL, len_str_def_const("points"));

                       long enable = 0;
                       json_get_child_long(obj_curise, "enable", &enable);
                       ret.enable = enable;

                       if (obj_points
                           &&obj_points->type == ejot_array
                           && obj_points->v.array.counts) {
                           struct json_object *point_list = obj_points->v.array.list;

                           NSMutableArray *curise_points = [NSMutableArray array];

                           for (int i = 0; i < obj_points->v.array.counts; i++, point_list = point_list->in_parent.next) {
                               curise_point * curise = [[curise_point alloc] init];
                               long enable = 0, index = 0, x = 0, y = 0;
                               json_get_child_long(point_list, "enable", &enable);
                               json_get_child_long(point_list, "index", &index);
                               json_get_child_long(point_list, "x", &x);
                               json_get_child_long(point_list, "y", &y);

                               curise.enable = enable;
                               curise.index = index;
                               curise.x = x;
                               curise.y = y;

                               [curise_points addObject:curise];
                           }

                           ret.curise_points = curise_points;
                       }

                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

    }];

    return 1;
}

-(long)alarm_curise_set:(mcall_ctx_cursise_set*)ctx
{
    NSString *type = @"ccm_curise_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},type:\"%@\",index:\"%d\"}", [self mipc_build_nid], ctx.sn, ctx.type, ctx.index];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof (self) weakSelf = self;

    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_curise_set *ret = [[mcall_ret_curise_set alloc] init];
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
               }];

    return 1;
}

- (long)ipcs_get:(mcall_ctx_ipcs_get*)ctx
{
    NSString *type = @"ccm_ipcs_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}", [self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;

    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_ipcs_get * ret = [[mcall_ret_ipcs_get alloc] init];
                   ret.result = [weakSelf check_result:msg];

                   if (nil == ret.result) {
                       struct json_object *ipcs_json = json_get_child_by_name(msg.data , NULL, len_str_def_const("ipcs"));
                       if (ipcs_json
                           && ipcs_json->type == ejot_array
                           && ipcs_json->v.array.counts) {

                           NSMutableArray *ipc_array = [NSMutableArray array];
                           struct json_object *ipcs_list = ipcs_json->v.array.list;
                           for (int i = 0; i < ipcs_json->v.array.counts; i++, ipcs_list = ipcs_list->in_parent.next) {
                               ipc_obj *ipc = [[ipc_obj alloc] init];

                               struct len_str sn = {0};
                               long online;

                               json_get_child_string(ipcs_list, "sn", &sn);
                               json_get_child_long(ipcs_list, "online", &online);

                               ipc.sn = sn.len ? [NSString stringWithUTF8String:sn.data]:nil;
                               ipc.online = online;

                               [ipc_array addObject:ipc];
                           }

                           ret.ipc_array = ipc_array;
                       }
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

               }];

    return 1;
}
- (long)play_segs_get:(mcall_ctx_play_segs_get*)ctx
{
    NSString *type = @"ccm_segs_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},sn:\"%@\",start_time:\"%ld\",end_time:\"%ld\"}", [self mipc_build_nid], ctx.sn, ctx.dev_sn, ctx.start_time, ctx.end_time];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_play_segs_get *ret = [[mcall_ret_play_segs_get alloc] init];
                   ret.result = [weakSelf check_result:msg];

                   if (nil == ret.result) {
                       struct json_object *segs_json = json_get_child_by_name(msg.data, NULL, len_str_def_const("segs"));
                       if (segs_json
                           && segs_json->type == ejot_array
                           && segs_json->v.array.counts) {

                           NSMutableArray *segs_array = [NSMutableArray array];
                           struct json_object *segs_list = segs_json->v.array.list;
                           for (int i = 0; i < segs_json->v.array.counts; i++, segs_list = segs_list->in_parent.next) {
                               long sid  = 0, cid = 0, stm = 0, etm = 0, flag = 0;

                               json_get_child_long(segs_list, "cid", &cid);
                               json_get_child_long(segs_list, "sid", &sid);
                               json_get_child_long(segs_list, "stm", &stm);
                               json_get_child_long(segs_list, "etm", &etm);
                               json_get_child_long(segs_list, "f", &flag);

                               seg_obj *seg = [[seg_obj alloc] init];
                               seg.cluster_id = cid;
                               seg.seg_id = sid;
                               seg.start_time = stm;
                               seg.end_time = etm;
                               seg.flag = flag;

                               [segs_array addObject:seg];
                           }

                           ret.segs_array = segs_array;
                       }
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
               }];

    return 1;
}

- (long)exsw_get:(mcall_ctx_exsw_get*)ctx;
{
    NSString *type = @"ccm_exsw_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}", [self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;

    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_exsw_get *ret = [[mcall_ret_exsw_get alloc] init];
                   ret.result = [weakSelf check_result:msg];

                   if (nil == ret.result) {
                       long enable = 0;
                       json_get_child_long(msg.data, "enable", &enable);
                       ret.enable = enable;
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

               }];

    return 1;
}

- (long)exsw_set:(mcall_ctx_exsw_set*)ctx;
{
    NSString *type = @"ccm_exsw_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},  enable:\"%ld\"}", [self mipc_build_nid], ctx.sn, ctx.enable];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;

    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_exsw_set *ret = [[mcall_ret_exsw_set alloc] init];
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

               }];

    return 1;
}

- (long)box_conf_get:(mcall_ctx_box_conf_get*)ctx
{
    NSString *type = @"ccm_box_conf_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}", [self mipc_build_nid], ctx.sn];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;

    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_box_conf_get *ret = [[mcall_ret_box_conf_get alloc] init];
                   ret.result = [weakSelf check_result:msg];

                   if (nil == ret.result) {
                       struct json_object *box_conf_obj = json_get_child_by_name(msg.data, NULL, len_str_def_const("conf"));
                       struct len_str username = {0}, password = {0};
                       long enable = 0, connect = 0;

                       json_get_child_string(box_conf_obj, "username", &username);
                       json_get_child_string(box_conf_obj, "password", &password);
                       json_get_child_long(box_conf_obj, "enable", &enable);
                       json_get_child_long(msg.data, "connect", &connect);
                       box_conf *box = [[box_conf alloc] init];
                       box.enable = enable;
                       box.username = username.len?[NSString stringWithUTF8String:username.data]:nil;
                       box.password = password.len?[NSString stringWithUTF8String:password.data]:nil;

                       ret.box_conf = box;
                       ret.connect = connect;
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

               }];

    return 1;
}

- (long)box_login:(mcall_ctx_box_login*)ctx
{
//    char            pass_enc[256] = {0};
//    long            pass_enc_len = sizeof(pass_enc);
//    mdes_enc_hex((char*)ctx.password, 16, (char*)_shareKey.UTF8String, _shareKey.length, &pass_enc[0], &pass_enc_len);

    NSString *type = @"ccm_box_login";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}, enable:\"%ld\", username:\"%@\", password:\"%@\"}", [self mipc_build_nid], ctx.sn, ctx.enable, ctx.username, ctx.password];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;

    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_box_login *ret = [[mcall_ret_box_login alloc] init];
                   ret.result = [weakSelf check_result:msg];

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

               }];

    return 1;
}

-(long)box_get:(mcall_ctx_box_get *)ctx
{
    NSString *type = @"ccm_box_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},sn:\"%@\",flag:\"%ld\",start_time:\"%lld\",end_time:\"%lld\"}", [self mipc_build_nid], ctx.sn, ctx.dev_sn, ctx.flag, ctx.start_time, ctx.end_time];

    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }

    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];

                   mcall_ret_box_get *ret = [[mcall_ret_box_get alloc] init];
                   ret.result = [weakSelf check_result:msg];

                   if (nil == ret.result) {
                       struct json_object *segs_json = json_get_child_by_name(msg.data, NULL, len_str_def_const("segs"));
                       if (segs_json
                           && segs_json->type == ejot_array
                           && segs_json->v.array.counts) {

                           NSMutableArray *segs_array = [NSMutableArray array];
                           struct json_object *segs_list = segs_json->v.array.list;
                           for (int i = 0; i < segs_json->v.array.counts; i++, segs_list = segs_list->in_parent.next) {
                               long sid  = 0, cid = 0, stm = 0, etm = 0, flag = 0;

                               json_get_child_long(segs_list, "cid", &cid);
                               json_get_child_long(segs_list, "sid", &sid);
                               json_get_child_long(segs_list, "stm", &stm);
                               json_get_child_long(segs_list, "etm", &etm);
                               json_get_child_long(segs_list, "f", &flag);

                               seg_obj *seg = [[seg_obj alloc] init];
                               seg.cluster_id = cid;
                               seg.seg_id = sid;
                               seg.start_time = stm;
                               seg.end_time = etm;
                               seg.flag = flag;

                               [segs_array addObject:seg];
                           }

                           ret.seg_array = segs_array;
                       }

                       struct json_object *ipcs_json = json_get_child_by_name(msg.data , NULL, len_str_def_const("ipcs"));
                       if (ipcs_json
                           && ipcs_json->type == ejot_array
                           && ipcs_json->v.array.counts) {

                           NSMutableArray *ipc_array = [NSMutableArray array];
                           struct json_object *ipcs_list = ipcs_json->v.array.list;
                           for (int i = 0; i < ipcs_json->v.array.counts; i++, ipcs_list = ipcs_list->in_parent.next) {
                               ipc_obj *ipc = [[ipc_obj alloc] init];

                               struct len_str sn = {0};
                               struct len_str nick = {0};
                               long online;

                               json_get_child_string(ipcs_list, "sn", &sn);
                               json_get_child_string(ipcs_list, "nick", &nick);
                               json_get_child_long(ipcs_list, "online", &online);

                               ipc.sn = sn.len ? [NSString stringWithUTF8String:sn.data]:nil;
                               ipc.nick = nick.len ? [NSString stringWithUTF8String:nick.data]:nil;
                               ipc.online = online;

                               [ipc_array addObject:ipc];
                           }

                           ret.ipc_array = ipc_array;
                       }


                       struct json_object *date_infos_json = json_get_child_by_name(msg.data, NULL, len_str_def_const("date_infos"));
                       if (date_infos_json
                           && date_infos_json->type == ejot_array
                           && date_infos_json->v.array.counts) {
                           NSMutableArray *date_info_array = [NSMutableArray array];
                           struct json_object *date_info_list = date_infos_json->v.array.list;
                           for (int i = 0; i < date_infos_json->v.array.counts; i++, date_info_list = date_info_list->in_parent.next) {
                               long date = 0, info = 0, flag = 0;

                               json_get_child_long(date_info_list, "date", &date);
                               json_get_child_long(date_info_list, "info", &info);
                               json_get_child_long(date_info_list, "f", &flag);
                               
                               date_info_obj *date_info = [[date_info_obj alloc] init];
                               date_info.date = date;
                               date_info.info = info;
                               date_info.flag = flag;

                               [date_info_array addObject:date_info];
                           }

                           ret.date_info_array = date_info_array;
                       }
                       
                       struct json_object *segs_sdc_json = json_get_child_by_name(msg.data, NULL, len_str_def_const("segs_sdc"));
                       if (segs_sdc_json) {
                           struct len_str cid = {0}, sid = {0}, stm = {0}, etm = {0}, flag = {0};
                           long record_num = 0;

                           json_get_child_long(segs_sdc_json, "record_num", &record_num);
                           json_get_child_string(segs_sdc_json, "cid", &cid);
                           json_get_child_string(segs_sdc_json, "sid", &sid);
                           json_get_child_string(segs_sdc_json, "stm", &stm);
                           json_get_child_string(segs_sdc_json, "etm", &etm);
                           json_get_child_string(segs_sdc_json, "f", &flag);

                           ulong decoded_cid_num = 0, decoded_sid_num = 0, decoded_stm_num = 0, decoded_etm_num = 0, decoded_flag_num = 0;
                           int32_t *sdc_cid = (int32_t *)malloc(record_num * sizeof(int32_t));
                           int32_t *sdc_sid = (int32_t *)malloc(record_num * sizeof(int32_t));
                           int64_t *sdc_stm = (int64_t *)malloc(record_num * sizeof(int64_t));
                           int64_t *sdc_etm = (int64_t *)malloc(record_num * sizeof(int64_t));
                           int32_t *sdc_flag = (int32_t *)malloc(record_num * sizeof(int32_t));

                           //sdc_decode
                           long dc_cid_success = sdc_decode((const uchar*)cid.data, cid.len, record_num, data_type_4bytes, (uchar*)sdc_cid, sizeof(int32_t), &decoded_cid_num);
                           long dc_sid_success = sdc_decode((const uchar*)sid.data, sid.len, record_num, data_type_4bytes, (uchar*)sdc_sid, sizeof(int32_t), &decoded_sid_num);
                           long dc_stm_success = sdc_decode((const uchar*)stm.data, stm.len, record_num, data_type_8bytes, (uchar*)sdc_stm, sizeof(int64_t), &decoded_stm_num);
                           long dc_etm_success = sdc_decode((const uchar*)etm.data, etm.len, record_num, data_type_8bytes, (uchar*)sdc_etm, sizeof(int64_t), &decoded_etm_num);
                           long dc_flag_success = sdc_decode((const uchar*)flag.data, flag.len, record_num, data_type_4bytes, (uchar*)sdc_flag, sizeof(int32_t), &decoded_flag_num);
                           
                           //test : save data in each array
                           NSMutableArray *cidArray = [[NSMutableArray alloc] init];
                           NSMutableArray *sidArray = [[NSMutableArray alloc] init];
                           NSMutableArray *stmArray = [[NSMutableArray alloc] init];
                           NSMutableArray *etmArray = [[NSMutableArray alloc] init];
                           NSMutableArray *flagArray = [[NSMutableArray alloc] init];

                           for (int i = 0; i < record_num; i++) {
                               NSNumber *num1 = [[NSNumber alloc] initWithLong:sdc_cid[i]];
                               NSNumber *num2 = [[NSNumber alloc] initWithLong:sdc_sid[i]];
                               NSNumber *num3 = [[NSNumber alloc] initWithLongLong:sdc_stm[i]];
                               NSNumber *num4 = [[NSNumber alloc] initWithLongLong:sdc_etm[i]];
                               NSNumber *num5 = [[NSNumber alloc] initWithLong:sdc_flag[i]];

                               [cidArray addObject:num1];
                               [sidArray addObject:num2];
                               [stmArray addObject:num3];
                               [etmArray addObject:num4];
                               [flagArray addObject:num5];
                           }
                           
                           NSMutableArray *seg_array = [NSMutableArray array];
                           for (int i = 0; i < record_num; i++) {
                               seg_obj *seg = [[seg_obj alloc] init];
                               seg.cluster_id = [[[NSNumber alloc] initWithLong:sdc_cid[i]] longValue];
                               seg.seg_id = [sidArray[i] longValue];
                               seg.start_time = [stmArray[i] longLongValue];
                               seg.end_time = [etmArray[i] longLongValue];
                               seg.flag = [flagArray[i] longValue];
                               
                               [seg_array addObject:seg];
                           }
                           
                           ret.seg_sdc_array = seg_array;
                           
                           free(sdc_cid);
                           free(sdc_sid);
                           free(sdc_stm);
                           free(sdc_etm);
                           free(sdc_flag);
//                           ret.seg_sdc_array = [seg_array mutableCopy];
//                           
//                           if (sdc_cid != nil) {
//                               free(sdc_cid);
//                               sdc_cid = nil;
//                           }
//                           if (sdc_sid != nil) {
//                               free(sdc_sid);
//                               sdc_sid = nil;
//                           }
//                           if (sdc_stm != nil) {
//                               free(sdc_stm);
//                               sdc_stm = nil;
//                           }
//                           if (sdc_etm != nil) {
//                               free(sdc_etm);
//                               sdc_etm = nil;
//                           }
//                           if (sdc_flag != nil) {
//                               free(sdc_flag);
//                               sdc_flag = nil;
//                           }
                       }
                   }

                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }

               }];
    
    return 1;
}

-(long)box_set:(mcall_ctx_box_set *)ctx
{
    NSString *type = @"ccm_box_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},sn:\"%@\",cmd:\"%@\",start_time:\"%lld\",end_time:\"%lld\"}", [self mipc_build_nid], ctx.sn, ctx.dev_sn, ctx.cmd, ctx.start_time, ctx.end_time];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }
                   
                   //                   [weakSelf check_msg_ret_result:msg];
                   
                   mcall_ret_box_set *ret = [[mcall_ret_box_set alloc] init];
                   ret.result = [weakSelf check_result:msg];
                   
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
                   
               }];
    
    return 1;
}

- (long)alert_task_get:(mcall_ctx_alert_task_get *)ctx
{
    if(![self check_ver:@"ccm_alert_action_get" sn:ctx.sn])
    {
        [ctx.target performSelector:ctx.on_event withObject:nil];
        return 0;
    }
    
    NSString *type = @"ccm_alert_action_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[self mipc_build_nid], ctx.sn];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

                   //check information
//                   [weakSelf check_msg_ret_result:msg];
                   //coding in block
                   mcall_ret_alert_task_get *ret =  [[mcall_ret_alert_task_get alloc] init]  ;
                   ret.ref = ctx.ref;
                   
                   if(nil == (ret.result = [weakSelf check_result:msg]))
                   {
                       struct json_object  *enableResult = json_get_child_by_name(msg.data, NULL, len_str_def_const("enable"));
                       struct json_object *sch = json_get_child_by_name(msg.data, NULL, len_str_def_const("sch")),
                       *times = sch?json_get_child_by_name(sch, NULL, len_str_def_const("times")):NULL;
                       long      enable = 0, full_time = 0, sd_ready = 0, l_enable = 0;;
                       json_get_child_long(sch, "enable", &enable);
                       json_get_child_long(sch, "full_time", &full_time);
                       //json_get_child_long(msg.data, "sd_ready", &sd_ready);
                       json_get_child_long(msg.data, "enable", &l_enable);
                           
                       
                       NSMutableArray *times_arr = nil;
                       if (enable != 0)
                       {
                           if (times && ejot_array == times->type && times->v.array.counts)
                           {
                               struct json_object  *next = times->v.array.list;
                               times_arr = [NSMutableArray arrayWithCapacity:3];
                               for (int i = 0; i < times->v.array.counts;i++, next = next->in_parent.next)
                               {
                                   long start = 0, end = 0, wday = 0 ;
                                   json_get_child_long(next, "wday", &wday);
                                   json_get_child_long(next, "start", &start);
                                   json_get_child_long(next, "end", &end);
                               
                                   mdev_time *time = [[mdev_time alloc] init];
                                   time.start_time = start;
                                   time.end_time = end;
                                   time.time = (mdev_time_type)wday;
                                   [times_arr addObject:time];
                               }
                           }
                       }
                       ret.enable = enable;
                       ret.full_time = full_time;
                       ret.times = times_arr;
                       ret.sd_ready = sd_ready;
                       ret.enableAlert = l_enable;
                   }
                   
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                   {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
                   
               }];
    
    return 1;

}

- (long)alert_task_set:(mcall_ctx_alert_task_set *)ctx
{
    if(![self check_ver:@"ccm_alert_action_set" sn:ctx.sn])
    {//xxxxxxxxxx result
        [ctx.target performSelector:ctx.on_event withObject:nil];
        
        return 0;
    }
    
    NSString  *ns_times = @"";
    
    for(mdev_time *time in ctx.times)
    {
        ns_times = [NSString stringWithFormat:@"%@%@%@",ns_times, ns_times.length?@",":@"", [NSString stringWithFormat:@"{wday:\"%d\",start:\"%ld\",end:\"%ld\"}",time.time,time.start_time,time.end_time]];
    }
    
    NSString *task_json = [NSString stringWithFormat:@"sch:{enable:\"%d\",full_time:\"%d\",times:[%@]}", ctx.enable, ctx.full_time,ns_times];
    
    NSString *type = @"ccm_alert_action_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},enable:\"%d\",%@}}",[self mipc_build_nid], ctx.sn, ctx.enableAlert,  task_json];
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                     //check old to new
                     if (!weakSelf.isNewSrv) {
                         [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                     }

                     //check information
//                     [weakSelf check_msg_ret_result:msg];
                     //coding in block
                     mcall_ret_alert_task_set *ret =  [[mcall_ret_alert_task_set alloc] init]  ;
                     ret.result = [weakSelf check_result:msg];
                     ret.ref = ctx.ref;
                     
                     if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                     {
                         [ctx.target performSelector:ctx.on_event withObject:ret];
                     }
                     
                 }];
    
    return 1;

}

- (long)cap_get:(mcall_ctx_cap_get *)ctx;
{
    NSString *type = @"ccm_cap_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},filter:\"%@\"}", [self mipc_build_nid], ctx.sn, ctx.filter];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }

//                   [weakSelf check_msg_ret_result:msg];
                   
                   mcall_ret_cap_get *ret = [[mcall_ret_cap_get alloc] init];
                   ret.result = [weakSelf check_result:msg];
                   
                   if (nil == ret.result)
                   {
                       struct len_str cap_str = {0};
                       json_get_child_string(msg.data, "cap", &cap_str);
                       
                       NSData *cap_data = [NSData dataWithBytes:cap_str.data length:cap_str.len];
                       struct json_object *cap = MIPC_DataTransformToJson(cap_data);
                       
                       long wfc = 0, snc = 0, qrc = 0, wfcnr = 0;
                       struct len_str sncf = {0};
                       json_get_child_long(cap, "wfc", &wfc);
                       json_get_child_long(cap, "snc", &snc);
                       json_get_child_long(cap, "qrc", &qrc);
                       json_get_child_string(cap, "sncf", &sncf);
                       json_get_child_long(cap, "wfcnr", &wfcnr);
                       ret.wfc = wfc;
                       ret.snc = snc;
                       ret.qrc = qrc;
                       ret.sncf = sncf.len ? [[NSString alloc] initWithUTF8String:sncf.data]:nil;
                       ret.wfcnr = wfcnr;
                   }
                   
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
                   
               }];
    
    return 1;

}

- (long)uart_set:(mcall_ctx_uart_set *)ctx
{
    NSString *type = @"ccm_uart_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\", sn:\"%@\"}, cmd:\"cmd=ctrl,code=\"%@\",\"%@\"=\"%@\"\"}", [self mipc_build_nid], ctx.sn, ctx.code, ctx.filter, ctx.value];

    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }
                   
//                    [weakSelf check_msg_ret_result:msg];
                   
                    mcall_ret_uart_set *ret = [[mcall_ret_uart_set alloc] init];
                    ret.result = [weakSelf check_result:msg];
                    
                    if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                        [ctx.target performSelector:ctx.on_event withObject:ret];
                    }
    }];
    
    return 1;
}

- (long)log_req:(mcall_ctx_log_reg *)ctx
{
    //    NSString *data_json = [NSString stringWithFormat:@"{p:[{n:\'model\', v:\'%@\'},{n:\'os\', v:\'%@\'},{n:\'app_ver\', v:\'%@\'},{n:\'exception_name\', v:\'%@\'},{n:\'exception_reason\', v:\'%@\'},{n:\'call_stack\', v:\'%@\'}]}", ctx.mode, ctx.os, ctx.app_ver, ctx.exception_name, ctx.exception_reason,ctx.call_stack];
    
    //    NSString *data_json = [NSString stringWithFormat:@"{p:[{n:\"%s\", v:\"%s\"},{n:\"%s\", v:\"%s\"},{n:\"%s\", v:\"%s\"},{n:\"%s\", v:\"%s\"},{n:\"%s\", v:\"%s\"},{n:\"%s\", v:\"%s\"}]}",
    //                           "model",ctx.mode.UTF8String,
    //                           "os", ctx.os.UTF8String,
    //                           "app_ver",ctx.app_ver.UTF8String,
    //                           "exception_name",ctx.exception_name.UTF8String,
    //                           "exception_reason",ctx.exception_reason.UTF8String,
    //                           "call_stack",ctx.call_stack.UTF8String];
    
    /* build encrypt sys info */
    struct len_str      s_dh_prime = {len_str_def_const(dh_default_prime)},
    s_dh_root = {len_str_def_const(dh_default_root)},
    s_dh_es_pubk = {len_str_def_const("310105909413485164588026905566175959")};
    struct dh_mod       *es_dh_mod = dh_create(&s_dh_prime, &s_dh_root);
    struct len_str      *s_dh_pubk = es_dh_mod?dh_get_public_key(es_dh_mod):NULL,
    *s_dh_share_key = es_dh_mod?dh_get_share_key(es_dh_mod, &s_dh_es_pubk):NULL;
    NSString            *exParams = nil, *encode_sys = s_dh_share_key?MIPC_BuildEncryptExceptionInfo(ctx.log_type,ctx.mode,ctx.exception_name,ctx.exception_reason,ctx.call_stack,_user,[NSString stringWithUTF8String:s_dh_share_key->data]):nil;
    
    if(encode_sys)
    {
        exParams = [NSString stringWithFormat:@"{p:[{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"}]}",
                    "type", "ios",
                    "uctx", encode_sys?encode_sys.UTF8String:"",
                    "root", s_dh_root.data,
                    "prime", s_dh_prime.data,
                    "pubk", s_dh_pubk?s_dh_pubk->data:""];
    }
    
    NSString *srv_url = [[NSUserDefaults standardUserDefaults] stringForKey:@"u_log"];
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *srv = ([srv_url isEqualToString:@""] || srv_url == nil) ? (app.is_vimtag ? @"http://log.vimtag.com" : @"http://log.mipcm.com") : srv_url;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([srv isEqualToString:@"http://log.vimtag.com"] || [srv isEqualToString:@"http://log.mipcm.com"]) {
            [self post_asyn:srv
                         to:@"ccm"
                  to_handle:0
                       mqid:_qid
                from_handle:[self createFromHandle]
                       type:@"ccms_log_req"
                    request:[NSString stringWithFormat:@"%@/ccm/ccms_log_req.js", srv]
             
                   dataJson:exParams
                    timeout:0
                 usingBlock:^(mjson_msg *msg) {
                     mcall_ret_log_reg *ret = [[mcall_ret_log_reg alloc] init];
                     ret.result = [weakSelf check_result:msg];
                     
                     if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                         [ctx.target performSelector:ctx.on_event withObject:ret];
                     }
                 }];
        }
        else
        {
            [self post_asyn:srv
                         to:nil
                  to_handle:0
                       mqid:_qid
                from_handle:[self createFromHandle]
                       type:@"ccms_log_req"
                    request:[NSString stringWithFormat:@"%@/ccms_log_req.js", srv]
             
                   dataJson:exParams
                    timeout:0
                 usingBlock:^(mjson_msg *msg) {
                     mcall_ret_log_reg *ret = [[mcall_ret_log_reg alloc] init];
                     ret.result = [weakSelf check_result:msg];
                     
                     if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                         [ctx.target performSelector:ctx.on_event withObject:ret];
                     }
                 }];
        }
    });
    
    return 1;
}

- (long)bind_email_set:(mcall_ctx_email_set *)ctx
{
    char            pass_enc[256] = {0};
    long            pass_enc_len = sizeof(pass_enc);
    mdes_enc_hex((char*)ctx.encrypt_pwd , 16, (char*)_shareKey.UTF8String, _shareKey.length, (char*)&pass_enc[0], &pass_enc_len);
    
    NSString    *srvUCTXparams = MIPC_BuildEncryptSysInfo(self.user, self.shareKey);
    
    NSString    *srvExParams = srvUCTXparams?[NSString stringWithFormat:@",p:[{n:\"%@\",v:\"%@\"},{n:\"spv\",v:\"v1\"}]",
                                              @"uctx",
                                              srvUCTXparams?srvUCTXparams:@""]:@" ";
    
    NSString *type = @"cacs_bind_req";
    NSString *data_json = [NSString stringWithFormat:@"{nid:\"%@\", user:\"%@\",  email:\"%@\",mobile:\"%@\", pass:\"%s\", lang:\"%@\"%@}", [self mipc_build_nid_by_lid], ctx.user, ctx.email, ctx.mobile, (char*)&pass_enc[0], ctx.lang, srvExParams];
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }
                   
                   //                    [weakSelf check_msg_ret_result:msg];
                   
                   mcall_ret_email_set *ret = [[mcall_ret_email_set alloc] init];
                   ret.result = [weakSelf check_result:msg];
                   struct len_str p = {0};
                   json_get_child_string(msg.data, "p", &p);
                   
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
               }];
    
    return 1;
}

- (long)bind_email_get:(mcall_ctx_email_get *)ctx
{
    NSString *type = @"cacs_query_req";
    NSString    *srvUCTXparams = MIPC_BuildEncryptSysInfo(self.user, self.shareKey);
    
    NSString    *srvExParams = srvUCTXparams?[NSString stringWithFormat:@",p:[{n:\"%@\",v:\"%@\"},{n:\"spv\",v:\"v1\"}]",
                                              @"uctx",
                                              srvUCTXparams?srvUCTXparams:@""]:@" ";
    NSString *data_json = [NSString stringWithFormat:@"{nid:\"%@\", user:\"%@\"%@}", [self mipc_build_nid_by_lid], self.user, srvExParams];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }
                   
                   //                    [weakSelf check_msg_ret_result:msg];
                   
                   struct len_str s_user = {0}, s_email = {0}, s_mobile = {0};
                   long l_user_type = 0, l_active_user = 0,  l_active_email = 0, l_active_mobile = 0;
                   mcall_ret_email_get *ret = [[mcall_ret_email_get alloc] init];
                   ret.result = [weakSelf check_result:msg];
                   if (nil == ret.result) {
                       json_get_child_string(msg.data, "user", &s_user);
                       json_get_child_string(msg.data, "email", &s_email);
                       json_get_child_string(msg.data, "mobile", &s_mobile);
                       json_get_child_long(msg.data, "user_type", &l_user_type);
                       json_get_child_long(msg.data, "active_user", &l_active_user);
                       json_get_child_long(msg.data, "active_email", &l_active_email);
                       json_get_child_long(msg.data, "active_mobile", &l_active_mobile);
                       ret.user = s_user.len?[[NSString alloc] initWithUTF8String:s_user.data]:nil;
                       ret.email = s_email.len?[[NSString alloc] initWithUTF8String:s_email.data]:nil;
                       ret.mobile = s_mobile.len?[[NSString alloc] initWithUTF8String:s_mobile.data]:nil;
                       ret.user_type = l_user_type;
                       ret.active_user = l_active_user;
                       ret.active_email = l_active_email;
                       ret.active_mobile = l_active_mobile;
                   }
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
               }];
    
    return 1;
}

- (long)email_set:(mcall_ctx_email_set *)ctx
{
    /* clear cache data */
    if(_shareKey){ _shareKey = nil; }
    if(_sid){ _sid = 0; }
    if(_lid){ _lid = 0; }
    if(_tid){ _tid = 0; }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _user = ctx.user;
        NSString *srvCert = nil;
        NSString *srvName = nil;
        NSString *srvPubk = nil;
        if (!_srv) {
            _srv = [weakSelf mipcGetSrv:@""
                                   user:ctx.user
                                   cert:&srvCert
                                   name:&srvName
                                   pubk:&srvPubk];
        }
        
        [weakSelf cacs_dh_req_asyn:_srv
                        usingBlock:^(NSString *result, NSString *shareKey, int64_t tid, int64_t lid) {
                            if(shareKey)
                            {
                                self.shareKey = shareKey;
                            };
                            
                            if (tid) {
                                self.tid = tid;
                            }
                            
                            if (lid) {
                                self.lid = lid;
                            }
                            
                            char            pass_enc[256] = {0};
                            long            pass_enc_len = sizeof(pass_enc);
                            mdes_enc_hex((char*)ctx.encrypt_pwd , 16, (char*)_shareKey.UTF8String, _shareKey.length, (char*)&pass_enc[0], &pass_enc_len);
                            
                            NSString    *srvUCTXparams = MIPC_BuildEncryptSysInfo(self.user, self.shareKey);
                            
                            NSString    *srvExParams = srvUCTXparams?[NSString stringWithFormat:@",p:[{n:\"%@\",v:\"%@\"},{n:\"spv\",v:\"v1\"}]",
                                                                      @"uctx",
                                                                      srvUCTXparams?srvUCTXparams:@""]:@" ";
                            
                            NSString *data_json = [NSString stringWithFormat:@"{nid:\"%@\", user:\"%@\",  email:\"%@\",mobile:\"%@\", pass:\"%s\", lang:\"%@\"%@}", [self mipc_build_nid_by_lid], ctx.user, ctx.email, ctx.mobile, (char*)&pass_enc[0], ctx.lang, srvExParams];
                            
                            [weakSelf call_asyn:_srv
                                             to:nil
                                      to_handle:0
                                           mqid:_qid
                                    from_handle:[self createFromHandle]
                                           type:@"cacs_bind_req"
                                       dataJson:data_json
                                        timeout:0
                                     usingBlock:^(mjson_msg *msg) {
                                         
                                         mcall_ret_email_set *ret = [[mcall_ret_email_set alloc] init];
                                         ret.result = [weakSelf check_result:msg];
                                         struct len_str p = {0};
                                         json_get_child_string(msg.data, "p", &p);
                                         
                                         if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                                             [ctx.target performSelector:ctx.on_event withObject:ret];
                                         }
                                     }];
                        }];
    });
    
    return 1;
}

- (long)email_get:(mcall_ctx_email_get *)ctx
{
    /* clear cache data */
    if(_shareKey){ _shareKey = nil; }
    if(_sid){ _sid = 0; }
    if(_lid){ _lid = 0; }
    if(_tid){ _tid = 0; }
    if(_user){ _user = nil; }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        _user = ctx.user;
        NSString *srvCert = nil;
        NSString *srvName = nil;
        NSString *srvPubk = nil;
        _srv = [weakSelf mipcGetSrv:@""
                           user:ctx.user
                           cert:&srvCert
                           name:&srvName
                           pubk:&srvPubk];
        
        [weakSelf cacs_dh_req_asyn:_srv
                        usingBlock:^(NSString *result, NSString *shareKey, int64_t tid, int64_t lid) {
                            if(shareKey)
                            {
                                self.shareKey = shareKey;
                            };
                            
                            if (tid) {
                                self.tid = tid;
                            }
                            
                            if (lid) {
                                self.lid = lid;
                            }
                            
                            NSString *type = @"cacs_query_req";
                            NSString    *srvUCTXparams = MIPC_BuildEncryptSysInfo(self.user, self.shareKey);
                            
                            NSString    *srvExParams = srvUCTXparams?[NSString stringWithFormat:@",p:[{n:\"%@\",v:\"%@\"},{n:\"spv\",v:\"v1\"}]",
                                                                      @"uctx",
                                                                      srvUCTXparams?srvUCTXparams:@""]:@" ";
                            NSString *data_json = [NSString stringWithFormat:@"{nid:\"%@\", user:\"%@\"%@}", [self mipc_build_nid_by_lid], self.user, srvExParams];
                            [weakSelf call_asyn:_srv
                                             to:nil
                                      to_handle:0
                                           mqid:_qid
                                    from_handle:[self createFromHandle]
                                           type:type
                                       dataJson:data_json
                                        timeout:0
                                     usingBlock:^(mjson_msg *msg) {
                                         
                                         struct len_str s_user = {0}, s_email = {0}, s_mobile = {0};
                                         long l_user_type = 0, l_active_user = 0,  l_active_email = 0, l_active_mobile = 0;
                                         mcall_ret_email_get *ret = [[mcall_ret_email_get alloc] init];
                                         ret.result = [weakSelf check_result:msg];
                                         if (nil == ret.result) {
                                             json_get_child_string(msg.data, "user", &s_user);
                                             json_get_child_string(msg.data, "email", &s_email);
                                             json_get_child_string(msg.data, "mobile", &s_mobile);
                                             json_get_child_long(msg.data, "user_type", &l_user_type);
                                             json_get_child_long(msg.data, "active_user", &l_active_user);
                                             json_get_child_long(msg.data, "active_email", &l_active_email);
                                             json_get_child_long(msg.data, "active_mobile", &l_active_mobile);
                                             ret.user = s_user.len?[[NSString alloc] initWithUTF8String:s_user.data]:nil;
                                             ret.email = s_email.len?[[NSString alloc] initWithUTF8String:s_email.data]:nil;
                                             ret.mobile = s_mobile.len?[[NSString alloc] initWithUTF8String:s_mobile.data]:nil;
                                             ret.user_type = l_user_type;
                                             ret.active_user = l_active_user;
                                             ret.active_email = l_active_email;
                                             ret.active_mobile = l_active_mobile;
                                         }
                                         if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                                             [ctx.target performSelector:ctx.on_event withObject:ret];
                                         }
                                     }];
                        }];
    
    });

    return 1;
}

- (long)recovery_password:(mcall_ctx_recovery_password *)ctx
{
    /* clear cache data */
    if(_shareKey){ _shareKey = nil; }
    if(_sid){ _sid = 0; }
    if(_lid){ _lid = 0; }
    if(_tid){ _tid = 0; }
    if(_user){ _user = nil; }

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _user = ctx.user;
        
        NSString *srvCert = nil;
        NSString *srvName = nil;
        NSString *srvPubk = nil;
        _srv = [self mipcGetSrv:@""
                           user:ctx.user
                           cert:&srvCert
                           name:&srvName
                           pubk:&srvPubk];
        [weakSelf cacs_dh_req_asyn:_srv
                        usingBlock:^(NSString *result, NSString *shareKey, int64_t tid, int64_t lid) {
                            if(shareKey)
                            {
                                self.shareKey = shareKey;
                            };
                            
                            if (tid) {
                                self.tid = tid;
                            }
                            
                            if (lid) {
                                self.lid = lid;
                            }
                            NSString    *srvUCTXparams = MIPC_BuildEncryptSysInfo(self.user, self.shareKey);
                            NSString    *srvExParams = srvUCTXparams?[NSString stringWithFormat:@",p:[{n:\"%@\",v:\"%@\"},{n:\"spv\",v:\"v1\"}]",
                                                                      @"uctx",
                                                                      srvUCTXparams?srvUCTXparams:@""]:@" ";
                            
                            NSString *type = @"cacs_recovery_req";
                            NSString *data_json = [NSString stringWithFormat:@"{nid:\"%@\", user:\"%@\",  email:\"%@\",mobile:\"%@\", lang:\"%@\"%@}", [self mipc_build_nid_by_lid], ctx.user, ctx.email, ctx.mobile, ctx.lang, srvExParams];
                            [weakSelf call_asyn:_srv
                                             to:nil
                                      to_handle:0
                                           mqid:0
                                    from_handle:[self createFromHandle]
                                           type:type
                                       dataJson:data_json
                                        timeout:0
                                     usingBlock:^(mjson_msg *msg) {
                                         
                                         struct len_str s_email = {0}, s_mobile = {0};
                                         mcall_ret_recovery_password *ret = [[mcall_ret_recovery_password alloc] init];
                                         ret.result = [weakSelf check_result:msg];
                                         if (!ret.result) {
                                             json_get_child_string(msg.data, "email", &s_email);
                                             json_get_child_string(msg.data, "mobile", &s_mobile);
                                             ret.email = s_email.len?[[NSString alloc] initWithUTF8String:s_email.data]:nil;
                                             ret.mobile = s_mobile.len?[[NSString alloc] initWithUTF8String:s_mobile.data]:nil;
                                         }
                                         if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                                             [ctx.target performSelector:ctx.on_event withObject:ret];
                                         }
                                     }];
                            
                        }];
    });
    return 1;
}
- (long)get_desc:(mcall_ctx_get_desc *)ctx
{
    NSString *type = @"ccvs_get_desc_req";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},ver_type:\"ios\",ver_from:\"%@\", ver_to:\"%@\", lang:\"%@\"}",[self mipc_build_nid],ctx.sn, ctx.ver_from, ctx.ver_to, ctx.lang];
    
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                       to:nil
                to_handle:0
                     mqid:_qid
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                  timeout:0
               usingBlock:^(mjson_msg *msg) {
                   //check old to new
                   if (!weakSelf.isNewSrv) {
                       [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                   }
                   
                   //                    [weakSelf check_msg_ret_result:msg];
                   mcall_ret_get_desc *ret = [[mcall_ret_get_desc alloc] init];
                   ret.result = [weakSelf check_result:msg];
               
                   if (ret.result == nil)
                   {
                       NSString *descString = [[NSString alloc] init];
                       struct json_object *descs = json_get_child_by_name(msg.data, NULL, len_str_def_const("desc"));
                       if(descs
                          && (descs->type == ejot_array)
                          && descs->v.array.counts)
                       {
                           struct json_object *obj = descs->v.array.list;
                           for (int i = 0; i < descs->v.array.counts; i++, obj = obj->in_parent.next)
                           {
                               struct len_str desc = {0};
                               json_get_string(obj, &desc);
                               descString = [[descString stringByAppendingString:desc.len?[[NSString alloc] initWithUTF8String:desc.data]:nil] stringByAppendingString:@"\n"];
                               
                           }
                       }
                       if ([descString hasSuffix:@"\n"])
                       {
                           descString = [descString substringToIndex:[descString length] - 1];
                       }
                       ret.desc = descString;
                   }
                   
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
               }];
    
    return 1;
}

- (long)post_get:(mcall_ctx_post_get *)ctx
{
    /* build encrypt sys info */
    struct len_str      s_dh_prime = {len_str_def_const(dh_default_prime)},
    s_dh_root = {len_str_def_const(dh_default_root)},
    s_dh_es_pubk = {len_str_def_const(PUBK)};
    struct dh_mod       *es_dh_mod = dh_create(&s_dh_prime, &s_dh_root);
    struct len_str      *s_dh_pubk = es_dh_mod?dh_get_public_key(es_dh_mod):NULL,
    *s_dh_share_key = es_dh_mod?dh_get_share_key(es_dh_mod, &s_dh_es_pubk):NULL;
    
    NSString            *exParams = nil, *encode_sys = s_dh_share_key?MIPC_BuildEncryptSysInfo(ctx.user, [NSString stringWithUTF8String:s_dh_share_key->data]):nil;
    
#ifdef DEBUG
    if(encode_sys)
    {
        exParams = [NSString stringWithFormat:@",p:[{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"}]",
                    "uctx", encode_sys?encode_sys.UTF8String:"",
                    "root", s_dh_root.data,
                    "prime", s_dh_prime.data,
                    "pubk", s_dh_pubk?s_dh_pubk->data:"",
                    "keyid","id_debug"];
    }
#else
    if(encode_sys)
    {
        exParams = [NSString stringWithFormat:@",p:[{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"},{n:\"%s\",v:\"%s\"}]",
                    "uctx", encode_sys?encode_sys.UTF8String:"",
                    "root", s_dh_root.data,
                    "prime", s_dh_prime.data,
                    "pubk", s_dh_pubk?s_dh_pubk->data:"",
                    "keyid","id_release"];
    }
#endif
    if(es_dh_mod)
    {
        dh_destroy(es_dh_mod); es_dh_mod = NULL;
    };
    
    NSString *type = @"cpns_get_req";
    NSString *data_json = [NSString stringWithFormat:@"{start:\"%ld\", counts:\"%ld\"%@}", ctx.start, ctx.counts, exParams];
    
    __weak typeof(self) weakSelf = self;
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *srv = app.is_vimtag ? @"http://cpns.vimtag.com/cpns" : @"http://cpns.mipcm.com/cpns";
    [weakSelf call_asyn:srv
                       to:nil
                to_handle:0
                     mqid:0
              from_handle:[self createFromHandle]
                     type:type
                 dataJson:data_json
                timeout:0
               usingBlock:^(mjson_msg *msg) {
                   
                   NSMutableArray *keyArray = [[NSMutableArray alloc] init];
                   NSString *postInfoDerectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/postInfo"];
                   
                   BOOL isDirectory;
                   BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:postInfoDerectory isDirectory:&isDirectory];
                   
                   if (isDirectory && isFileExist)
                   {
                       NSError *error = nil;
                       NSArray *videoInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:postInfoDerectory error:&error];
                       if (error)
                       {
                           NSLog(@"%@", [error localizedDescription]);
                       }
                       
                       for (NSString *videoInfo in videoInfos)
                       {
                           if ([videoInfo hasSuffix:@".inf"])
                           {
                               NSString *videoInfoPath = [postInfoDerectory stringByAppendingPathComponent:videoInfo];
                               post_item *item = [NSKeyedUnarchiver unarchiveObjectWithFile:videoInfoPath];
                               if (item.key != nil)
                               {
                                   [keyArray addObject:item.key];
                               }
                           }
                       }
                   }
                   
                   struct json_object *items = {0};
                   long start = 0, total = 0, time = 0;
                   mcall_ret_post_get *ret = [[mcall_ret_post_get alloc] init];
                   ret.result = [weakSelf check_result:msg];
                   if (!ret.result)
                   {
                       json_get_child_long(msg.data, "start", &start);
                       json_get_child_long(msg.data, "total", &total);
                       
                       items = json_get_child_by_name(msg.data, NULL, len_str_def_const("item"));
                       NSMutableArray *items_arr = [NSMutableArray array];
                       
                       if (items && ejot_array == items->type && items->v.array.counts)
                       {
                           struct json_object *next = items->v.array.list;
                           for (int i = 0; i < items->v.array.counts; i++, next = next->in_parent.next)
                           {
                               struct len_str s_key = {0}, s_url = {0}, s_action = {0},  s_num = {0};
                               json_get_child_string(next, "key", &s_key);
                               json_get_child_string(next, "url", &s_url);
                               json_get_child_string(next, "action", &s_action);
                               json_get_child_long(next, "time", &time);
                               json_get_child_string(next, "num", &s_num);
                               
                               post_item *item = [[post_item alloc] init];
                               item.key = s_key.len ? [NSString stringWithUTF8String:s_key.data] : nil;
                               item.url = s_url.len ? [NSString stringWithUTF8String:s_url.data] : nil;
                               item.action = s_action.len ? [NSString stringWithUTF8String:s_action.data] : nil;
                               item.time = time;
                               item.num =  s_num.len ? [NSString stringWithUTF8String:s_num.data] : nil;
                               int j;
                               for (j = 0; j < keyArray.count; j++)
                               {
                                   if ([keyArray[j] isEqualToString:item.key])
                                   {
                                       break;
                                   }
                               }
                               if (j >= keyArray.count)
                               {
                                   [item.action caseInsensitiveCompare:@"logout"] == NSOrderedSame ? [items_arr insertObject:item atIndex:0] : [items_arr addObject:item];
                               }
                           }
                           
                       }
                       ret.item = [NSMutableArray array];
                       for (int i = 0; i < items_arr.count; i++) {
                           [((post_item *)items_arr[i]).action caseInsensitiveCompare:@"exit"] == NSOrderedSame ? [ret.item insertObject:items_arr[i] atIndex:0] : [ret.item addObject:items_arr[i]];
                       }
                       ret.start = start;
                       ret.total = total;
                   }
                
                   if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                       [ctx.target performSelector:ctx.on_event withObject:ret];
                   }
               }];
    return 1;
}

- (long)timezone_get:(mcall_ctx_timezone_get *)ctx
{
    NSString *type = @"ccm_zone_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[self mipc_build_nid],ctx.sn];
    
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:0
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //                    [weakSelf check_msg_ret_result:msg];
                 mcall_ret_timezone_get *ret = [[mcall_ret_timezone_get alloc] init];
                 ret.result = [weakSelf check_result:msg];
                 NSMutableArray *zone_arr = [NSMutableArray array];
                 if (ret.result == nil)
                 {
                     struct json_object *address = json_get_child_by_name(msg.data, NULL, len_str_def_const("address"));
                     if (address && (address->type == ejot_object) && address->v.array.counts) {
                         struct json_object *zones = json_get_child_by_name(address, NULL, len_str_def_const("zones"));
                         if(zones
                            && (zones->type == ejot_array)
                            && zones->v.array.counts)
                         {
                             struct json_object *obj = zones->v.array.list;
                             for (int i = 0; i < zones->v.array.counts; i++, obj = obj->in_parent.next)
                             {
                                 zone_obj *zone = [[zone_obj alloc] initWithJson:obj];
                                 //                             NSString *zone_str = [NSString stringWithFormat:@"%@  %@",zone.utc,zone.city];
                                 [zone_arr addObject:zone];
                                 
                             }
                         }
                         
                     }
                     
                 }
                 ret.address = zone_arr;
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
             }];
    
    return 1;
}

- (long)version_get:(mcall_ctx_version_get *)ctx
{
    NSString *ssrv;
    struct mipci_conf *conf = MIPC_ConfigLoad();
    if (conf && conf->exSignal_Srv.len)/* current exsrv url lenght never > 50*/
    {
        struct len_str ip = {0};
        char tempip[50];
        ip.len = conf->exSignal_Srv.len;
        memcpy(tempip, conf->exSignal_Srv.data, 50);
        ip.data = tempip;
        
        ssrv = [NSString stringWithFormat:@"%s", ip.data];;
    }
    else
    {
        NSString *srvCert = nil;
        NSString *srvName = nil;
        NSString *srvPubk = nil;
        ssrv = [self mipcGetSrv:nil
                            user:nil
                            cert:&srvCert
                            name:&srvName
                            pubk:&srvPubk];
    }

    NSString *type = @"ccvs_get_version_req";
    NSString *data_json = [NSString stringWithFormat:@"{ver_type:\"%@\",ver_from:\"%@\",lang:\"%@\"}",ctx.appid,ctx.appVersion,ctx.lang];
    __weak typeof(self) weakSelf = self;
    [weakSelf call_asyn:ssrv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:30
             usingBlock:^(mjson_msg *msg) {
                 mcall_ret_version_get *ret = [[mcall_ret_version_get alloc]init];
                 ret.result = [weakSelf check_result:msg];

                 if (ret.result == nil) {
                     struct json_object *infoDic = json_get_child_by_name(msg.data, NULL, len_str_def_const("info"));

                     struct len_str ver_to = {0},link_text = {0},link_type = {0},link_url = {0},desc = {0};
                     json_get_child_string(infoDic, "ver_to", &ver_to);
                     json_get_child_string(infoDic, "link_text", &link_text);
                     json_get_child_string(infoDic, "link_type", &link_type);
                     json_get_child_string(infoDic, "link_url", &link_url);
                     json_get_child_string(infoDic, "desc", &desc);

                     NSString *verto = ver_to.len ? [NSString stringWithUTF8String:ver_to.data]:nil;
                     NSString *linktext = link_text.len ? [NSString stringWithUTF8String:link_text.data] : nil;
                     NSString *linktype = link_type.len ? [NSString stringWithUTF8String:link_type.data] : nil;
                     NSString *linkurl = link_url.len ? [NSString stringWithUTF8String:link_url.data] : nil;
                     NSString *app_desc = desc.len ? [NSString stringWithUTF8String:desc.data] : nil;
                     
                     ret.info = [NSDictionary dictionaryWithObjectsAndKeys:verto,@"ver_to", linkurl,@"link_url" ,app_desc,@"desc" ,linktext,@"link_text",linktype,@"link_type", nil];
                 }
                 
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
                 
             }];
    
    return 1;
}

- (long)dev_timezone_get:(mcall_ctx_time_get *)ctx
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *ntp_type = @"ccm_ntp_get";
        NSString *ntp_data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[weakSelf mipc_build_nid], ctx.sn];
        
        if (!weakSelf.isNewSrv) {
            [[mipc_def_manager shared_def_manager] checkMsgRqt:&ntp_type dataJson:&ntp_data_json];
        }
        
        [weakSelf call_asyn:weakSelf.srv
                         to:nil
                  to_handle:0
                       mqid:weakSelf.qid
                from_handle:[weakSelf createFromHandle]
                       type:ntp_type
                   dataJson:ntp_data_json
                    timeout:30
                 usingBlock:^(mjson_msg *ntp_msg) {
                     //check information
                     mcall_ret_time_get *ret =  [[mcall_ret_time_get alloc] init]  ;
                     ret.ref = ctx.ref;
                     
                     if(nil == (ret.result = [weakSelf check_result:ntp_msg]))
                     {
                         long auto_sync_enable = 0;
                         struct len_str s_ip = {0}, s_timezone = {0};
                         struct json_object  *info = json_get_child_by_name(ntp_msg.data, NULL, len_str_def_const("info")),
                         *manual = info?json_get_child_by_name(info, NULL, len_str_def_const("manual")):NULL;
                         json_get_child_long(info, "auto_sync_enable",&auto_sync_enable);
                         if(manual && manual->type == ejot_array && manual->v.array.counts){json_get_child_string(manual->v.array.list, "ip", &s_ip);};
                         json_get_child_string(info, "timezone",&s_timezone);
                         
                         ret.auto_sync = auto_sync_enable;
                         ret.ntp_addr = s_ip.len?[NSString stringWithUTF8String:s_ip.data]:nil;
                         ret.time_zone = s_timezone.len?[NSString stringWithUTF8String:s_timezone.data]:nil;
                     }
                     
                     dispatch_async(dispatch_get_main_queue(),^{
                         if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                         {
                             [ctx.target performSelector:ctx.on_event withObject:ret];
                         }
                         
                     });
                 }];
    });
    
    return 1;
}

- (long)dev_timezone_set:(mcall_ctx_time_set *)ctx
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *ntp_type = @"ccm_ntp_set";
        NSString *ntp_json = [NSString stringWithFormat:@"auto_sync:\"%d\",dhcp:\"0\",manual:[{ip:\"%@\"}]",ctx.auto_sync, ctx.ntp_addr?ctx.ntp_addr:@""];
        NSString *ntp_data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},%@}",[weakSelf mipc_build_nid], ctx.sn, ntp_json];
        
        if (!weakSelf.isNewSrv) {
            [[mipc_def_manager shared_def_manager] checkMsgRqt:&ntp_type dataJson:&ntp_data_json];
        }
        
        [weakSelf call_asyn:weakSelf.srv
                         to:nil
                  to_handle:0
                       mqid:weakSelf.qid
                from_handle:[weakSelf createFromHandle]
                       type:ntp_type
                   dataJson:ntp_data_json
                    timeout:30
                 usingBlock:^(mjson_msg *ntp_msg) {
                    mcall_ret_time_get *ret =  [[mcall_ret_time_get alloc] init]  ;
                    ret.ref = ctx.ref;
                    ret.result = [weakSelf check_result:ntp_msg];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (ctx.target && [ctx.target respondsToSelector:ctx.on_event])
                        {
                            [ctx.target performSelector:ctx.on_event withObject:ret];
                        }
                    });
        }];
    });
    
    return 1;
}

- (long)logo_get:(mcall_ctx_snapshot*)ctx
{
    mcall_ret_snapshot *ret = [[mcall_ret_snapshot alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = ctx.token;
        [weakSelf download_url:url timeout:30 completionBlock:^(NSData *data_img) {
            ret.img = [UIImage imageWithData:data_img];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                    [ctx.target performSelector:ctx.on_event withObject:ret];
                }
            });
        }];
    });
    
    return 0;
}

#pragma mark - Accessory Interface
-(long)exdev_add:(mcall_ctx_exdev_add *)ctx
{
    NSString *type = @"ccm_exdev_add";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},id:\"%@\",model:\"%ld\",timeout:\"%ld\",light:\"%ld\",dark:\"%ld\"}",[self mipc_build_nid],ctx.sn,ctx.exdev_id,ctx.model,ctx.addTimeout,ctx.lightTime,ctx.darkTime];
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:90
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //                                     [weakSelf check_msg_ret_result:msg];
                 mcall_ret_exdev_add *ret = [[mcall_ret_exdev_add alloc] init];
                 ret.result = [weakSelf check_result:msg];
                 
                 if (ret.result == nil)
                 {
                     //                     ret.ref = ctx.ref;
                     
                 }
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
             }];
    
    
    return 1;
}


-(long)exdev_del:(mcall_ctx_exdev_del *)ctx
{
    NSString *type = @"ccm_exdev_del";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},id:\"%@\"}",[self mipc_build_nid],ctx.sn,ctx.exdev_id];
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:0
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //                                     [weakSelf check_msg_ret_result:msg];
                 mcall_ret_exdev_add *ret = [[mcall_ret_exdev_add alloc] init];
                 ret.result = [weakSelf check_result:msg];
                 
                 if (ret.result == nil)
                 {
                     //                     ret.ref = ctx.ref;
                     
                 }
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
             }];
    
    
    return 1;
}


-(long)exdev_set:(mcall_ctx_exdev_set *)ctx
{
    NSString *type = @"ccm_exdev_set";
    
    NSMutableString *exdevstring;

    for (mExDev_obj *exdev in ctx.exdevs) {
        if ([exdev.exdev_id isEqualToString:ctx.exdev_id]) {
            exdevstring = [NSMutableString stringWithFormat:@"dev:[{id:\"%@\",nick:\"%@\",model:%ld,type:%ld,key:%ld,stat:%ld,rtime:%ld,flag:[%ld,%ld]}]", exdev.exdev_id, exdev.nick.length ? exdev.nick : @"", exdev.model, exdev.type, exdev.key,exdev.stat, exdev.rtime, exdev.outFlag, exdev.activeFlag];
        }
    }
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},%@}", [self mipc_build_nid], ctx.sn, exdevstring];
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:0
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //                                     [weakSelf check_msg_ret_result:msg];
                 mcall_ret_exdev_set *ret = [[mcall_ret_exdev_set alloc] init];
                 ret.result = [weakSelf check_result:msg];
                 
                 if (ret.result == nil)
                 {
                     //                     ret.ref = ctx.ref;
                     
                 }
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
             }];
    
    
    return 1;
    
}


-(long)exdev_get:(mcall_ctx_exdev_get *)ctx
{
    NSString *type = @"ccm_exdev_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},flag:\"%ld\",id:\"%@\",start:\"%ld\",counts:\"%ld\"}",[self mipc_build_nid],ctx.sn,ctx.flag,ctx.exdev_id,ctx.start,ctx.counts];
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:ctx.timeout
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //                                     [weakSelf check_msg_ret_result:msg];
                 mcall_ret_exdev_get *ret = [[mcall_ret_exdev_get alloc] init];
                 ret.result = [weakSelf check_result:msg];
                 
                 if (ret.result == nil)
                 {
                     long total = 0;
                     long start = 0;
                     json_get_child_long(msg.data, "total", &total);
                     json_get_child_long(msg.data, "start", &start);
                     ret.total = total;
                     ret.start = start;
                     
                     
                     struct json_object *exDevs = json_get_child_by_name(msg.data, NULL, len_str_def_const("devs"));
                     
                     if(exDevs
                        && (exDevs->type == ejot_array)
                        && exDevs->v.array.counts)
                     {
                         ret.exDevs = [NSMutableArray array];
                         struct json_object *obj = exDevs->v.array.list;
                         for (int i = 0; i < exDevs->v.array.counts; i++, obj = obj->in_parent.next)
                         {
                             mExDev_obj *dev = [[mExDev_obj alloc] init];
                             
                             struct len_str nick = {0};
                             struct len_str exDev_id = {0};
                             long status;
                             long model;
                             long type;
                             long rtime;
                             long key;
                             
                             json_get_child_string(obj, "nick", &nick);
                             json_get_child_string(obj, "id", &exDev_id);
                             json_get_child_long(obj, "stat", &status);
                             json_get_child_long(obj, "model", &model);
                             json_get_child_long(obj, "type", &type);
                             json_get_child_long(obj, "rtime", &rtime);
                             json_get_child_long(obj, "key", &key);
                             
                             struct json_object *flags = json_get_child_by_name(obj, NULL, len_str_def_const("flag"));
                             if(flags
                                && (flags->type == ejot_array)
                                && flags->v.array.counts)
                             {
                                 struct json_object *obj = flags->v.array.list;
                                 for (int i = 0; i < flags->v.array.counts; i++, obj = obj->in_parent.next)
                                 {
                                     if (i == 0) {
                                         dev.outFlag = obj->v.string.len ? [NSString stringWithUTF8String:obj->v.string.data].intValue : 0;
                                     } else if (i == 1) {
                                         dev.activeFlag = obj->v.string.len ? [NSString stringWithUTF8String:obj->v.string.data].intValue : 0;
                                     }
                                 }
                             }
                             
                             dev.nick = nick.len ? [NSString stringWithUTF8String:nick.data] : nil;
                             dev.exdev_id = exDev_id.len ? [NSString stringWithUTF8String:exDev_id.data] : nil;
                             dev.type = type;
                             dev.stat = status;
                             dev.model = model;
                             dev.rtime = rtime;
                             dev.key = key;
                             
                             [ret.exDevs addObject:dev];
                         }
                     }
                     
                 }
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
             }];
    
    
    return 1;
    
}
-(long)exdev_discover:(mcall_ctx_exdev_discover *)ctx
{
    NSString *type = @"ccm_exdev_discover";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},flag:\"%ld\",timeout:\"%ld\",light:\"%ld\",dark:\"%ld\"}",[self mipc_build_nid],ctx.sn,ctx.flag,ctx.SearchTimeout,ctx.lightTime,ctx.darkTime];
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:0
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //                                     [weakSelf check_msg_ret_result:msg];
                 mcall_ret_exdev_discover *ret = [[mcall_ret_exdev_discover alloc] init];
                 ret.result = [weakSelf check_result:msg];
                 
                 if (ret.result == nil)
                 {
                     //                     ret.ref = ctx.ref;
                     
                     
                 }
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
             }];
    
    
    return 1;
    
}


-(long)scene_set:(mcall_ctx_scene_set *)ctx
{

    NSString *type = @"ccm_scene_set";

    
    NSMutableString *scenes = [NSMutableString stringWithFormat:@"{select:\"%@\",scene:[",ctx.select];
    int index = 0;
    for (mScene_obj *obj in ctx.sceneArray)
    {
        index ++;
        [scenes appendFormat:@"{name:\"%@\",flag:%ld",obj.name,obj.flag];
        [scenes appendString:@",dev:["];
        
        for (int i = 0; i < obj.exDevs.count; i++) {
            sceneExdev_obj *exdev = obj.exDevs[i];
            if (i == obj.exDevs.count - 1) {
                [scenes appendFormat:@"{id:\"%@\",flag:%ld}",exdev.exdev_id,exdev.flag];
            } else {
                [scenes appendFormat:@"{id:\"%@\",flag:%ld},",exdev.exdev_id,exdev.flag];
            }
            
        }
        if (index == ctx.sceneArray.count) {
            [scenes appendString:@"]}"];
        } else {
            [scenes appendString:@"]},"];
        }
    }
    
    [scenes appendString:@"]}"];

    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},all:%ld,info:%@}",[self mipc_build_nid],ctx.sn,ctx.all,scenes];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:ctx.timeout
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //                                     [weakSelf check_msg_ret_result:msg];
                 mcall_ret_scene_set *ret = [[mcall_ret_scene_set alloc] init];
                 ret.result = [weakSelf check_result:msg];
                 
                 if (ret.result == nil)
                 {
                     
                     
                 }
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
             }];
    
    
    return 1;
    
    
}

-(long)scene_get:(mcall_ctx_scene_get *)ctx
{
    NSString *type = @"ccm_scene_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[self mipc_build_nid],ctx.sn];
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:0
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //                                     [weakSelf check_msg_ret_result:msg];
                 mcall_ret_scene_get *ret = [[mcall_ret_scene_get alloc] init];
                 ret.result = [weakSelf check_result:msg];
                 
                 if (ret.result == nil)
                 {
                     struct len_str now = {0};
                     json_get_child_string(msg.data, "now", &now);
                     ret.now = now.len ? [NSString stringWithUTF8String:now.data] : nil;
                     
                     struct json_object *info = json_get_child_by_name(msg.data, NULL, len_str_def_const("info"));
                     struct len_str select = {0};
                     json_get_child_string(info, "select", &select);
                     ret.select = select.len ? [NSString stringWithUTF8String:select.data] : nil;
                     
                     struct json_object *sceneArray = json_get_child_by_name(info, NULL, len_str_def_const("scene"));
                     if(sceneArray
                        && (sceneArray->type == ejot_array)
                        && sceneArray->v.array.counts)
                     {
                         NSMutableArray *scene_array = [NSMutableArray array];
                         struct json_object *obj = sceneArray->v.array.list;
                         for (int i = 0; i < sceneArray->v.array.counts; i++, obj = obj->in_parent.next)
                         {
                             mScene_obj *sceneObj = [[mScene_obj alloc] init];
                             
                             
                             struct len_str name = {0};
                             long flag;
                             json_get_child_string(obj, "name", &name);
                             json_get_child_long(obj, "flag", &flag);
                             
                             sceneObj.name = name.len ? [NSString stringWithUTF8String:name.data] : nil;
                             sceneObj.flag = flag;
                             
                             struct json_object *exDevs = json_get_child_by_name(obj, NULL, len_str_def_const("dev"));
                             if(exDevs
                                && (exDevs->type == ejot_array)
                                && exDevs->v.array.counts)
                             {
                                 NSMutableArray *exDev_array = [NSMutableArray array];
                                 struct json_object *obj = exDevs->v.array.list;
                                 for (int i = 0; i < exDevs->v.array.counts; i++, obj = obj->in_parent.next)
                                 {
                                     sceneExdev_obj *dev = [[sceneExdev_obj alloc] init];
                                     
                                     struct len_str exDev_id = {0};
                                     struct len_str exDev_nick = {0};
                                     long exDev_type;
                                     long flag;
                                 
                                    json_get_child_string(obj, "id", &exDev_id);
                                    json_get_child_long(obj, "type", &exDev_type);
                                    json_get_child_long(obj, "flag", &flag);
                                     json_get_child_string(obj, "nick", &exDev_nick);
                                     
//                                     //filter fdt
//                                     if (exDev_type == 2) {
//                                         continue;
//                                     }
                                     
                                     dev.exdev_id = exDev_id.len ? [NSString stringWithUTF8String:exDev_id.data] : nil;
                                     dev.exdev_type = exDev_type;
                                     dev.flag = flag;
                                     dev.nick = exDev_nick.len ? [NSString stringWithUTF8String:exDev_nick.data] : nil;
                                     
                                     [exDev_array addObject:dev];
                                 }
                                 sceneObj.exDevs = exDev_array;
                             }
                             
                             
                             [scene_array addObject:sceneObj];
                         }
                         ret.sceneArray = scene_array;
                         
                     }
                     
                 }
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
             }];
    
    return 1;
}

-(long)schedule_get:(mcall_ctx_schedule_get *)ctx
{
    NSString *type = @"ccm_schedule_get";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"}}",[self mipc_build_nid],ctx.sn];
    
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:0
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //                                     [weakSelf check_msg_ret_result:msg];
                 mcall_ret_schedule_get *ret = [[mcall_ret_schedule_get alloc] init];
                 ret.result = [weakSelf check_result:msg];
                 
                 if (ret.result == nil)
                 {
                     struct json_object *scheduleArray = json_get_child_by_name(msg.data, NULL, len_str_def_const("sch"));
                     
//                     long enable;
                     long degree;
//                     long bit;
//                     json_get_child_long(scheduleArray, "enable", &enable);
                     json_get_child_long(scheduleArray, "degree", &degree);
//                     json_get_child_long(scheduleArray, "bit", &bit);
//                     ret.enable = enable;
                     ret.degree = degree;
//                     ret.bit = bit;
                     
                     struct len_str schedule = {0};
                     json_get_child_string(scheduleArray, "schedule", &schedule);
                     NSString *schString = schedule.len ? [NSString stringWithUTF8String:schedule.data] : nil;
                     if (schString != nil)
                     {
                         
                         unsigned char *base64_buf = (unsigned char *)[schString UTF8String];
                         unsigned char *sche = (unsigned char*)malloc(21);
                         memset(sche, 0, sizeof(char)*21);
                         unsigned long buf_size = 4096;
                         
                         mining64_decode(base64_buf,
                                         28,
                                         sche,
                                         buf_size);
                         ret.array = [NSMutableArray array];
                         
                         for (int i = 0; i < 21; i ++) {
                             unsigned char sun;
                             sun = sche[i];
                             
                             for (int i = 0; i < 8; i ++) {
                                 int j = 0;
                                 unsigned char day = sun;
                                 switch (i) {
                                     case 0:
                                         day = day & (0b00000001);
                                         j = day;
                                         break;
                                     case 1:
                                         day = day & (0b00000010);
                                         j = day >> 1;
                                         break;
                                     case 2:
                                         day = day & (0b00000100);
                                         j = day >> 2;
                                         break;
                                     case 3:
                                         day = day & (0b00001000);
                                         j = day >> 3;
                                         break;
                                     case 4:
                                         day = day & (0b00010000);
                                         j = day >> 4;
                                         break;
                                     case 5:
                                         day = day & (0b00100000);
                                         j = day >> 5;
                                         break;
                                     case 6:
                                         day = day & (0b01000000);
                                         j = day >> 6;
                                         break;
                                     case 7:
                                         day = day & (0b10000000);
                                         j = day >> 7;
                                         break;
                                     default:
                                         break;
                                 }
                                 NSNumber *hour = [[NSNumber alloc] initWithInt:j];
                                 [ret.array addObject:hour];
                             }
                             
                         }
                         free(sche);
                     }
                 }
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
             }];
    
    return 1;
}

-(long)schedule_set:(mcall_ctx_schedule_set *)ctx
{
    
    unsigned long buf_size = 4096;
    unsigned char *base64_buf = (unsigned char*)malloc(buf_size);
    unsigned char *sche = (unsigned char*)malloc(21);
    
    for (int i = 0; i < 21; i ++) {
        
        unsigned char c = 0b00000000;
        
        for (int j = 0; j < 8; j ++) {
            
            int index = i * 8 + j;
            NSNumber *number = ctx.array[index];
            int hourValue = [number intValue];
            
            switch (j) {
                case 0:
                    c = c | (hourValue);
                    break;
                case 1:
                    c = c | (hourValue << 1);
                    break;
                case 2:
                    c = c | (hourValue << 2);
                    break;
                case 3:
                    c = c | (hourValue << 3);
                    break;
                case 4:
                    c = c | (hourValue << 4);
                    break;
                case 5:
                    c = c | (hourValue << 5);
                    break;
                case 6:
                    c = c | (hourValue << 6);
                    break;
                case 7:
                    c = c | (hourValue << 7);
                    break;
                default:
                    break;
            }
        }
        sche[i] = c;
//        NSLog(@"%x", c);
    }
    mining64_encode(sche,
                    21,
                    base64_buf,
                    buf_size);
    NSString *schString = [NSString stringWithUTF8String:(char*)base64_buf];
    
    NSString *type = @"ccm_schedule_set";
    NSString *data_json = [NSString stringWithFormat:@"{sess:{nid:\"%@\",sn:\"%@\"},sch:{degree:\"%ld\",schedule:\"%@\"}}",[self mipc_build_nid],ctx.sn, ctx.degree, schString];
    
    if (!self.isNewSrv) {
        [[mipc_def_manager shared_def_manager] checkMsgRqt:&type dataJson:&data_json];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf call_asyn:_srv
                     to:nil
              to_handle:0
                   mqid:_qid
            from_handle:[self createFromHandle]
                   type:type
               dataJson:data_json
                timeout:0
             usingBlock:^(mjson_msg *msg) {
                 //check old to new
                 if (!weakSelf.isNewSrv) {
                     [[mipc_def_manager shared_def_manager] checkMsgRsp:msg];
                 }
                 
                 //                                     [weakSelf check_msg_ret_result:msg];
                 mcall_ret_exdev_set *ret = [[mcall_ret_exdev_set alloc] init];
                 ret.result = [weakSelf check_result:msg];
                 
                 if (ret.result == nil)
                 {
                     //                     ret.ref = ctx.ref;
                     
                 }
                 if (ctx.target && [ctx.target respondsToSelector:ctx.on_event]) {
                     [ctx.target performSelector:ctx.on_event withObject:ret];
                 }
             }];
    
    return 1;
    
    
}
@end

#pragma clang diagnostic pop

