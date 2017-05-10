//
//  mipc_def_manager.m
//  mipci
//
//  Created by mining on 14-7-24.
//
//

#import "mipc_def_manager.h"
#import "mios_core_frameworks.h"
#include "mpack_file/mpack_file.h"
#import "mipc_data_object.h"

@interface def_obj : NSObject
@property(nonatomic,assign) struct pack_def *n_def;
@property(nonatomic,assign) struct pack_def *o_def;
@property(nonatomic,strong) NSString        *n_type;
@property(nonatomic,strong) NSString        *o_type;
@end

//------------------------------old and new pdef convert----------------
@implementation def_obj

@end

//全局静态变量
static mipc_def_manager *def_manager;

@interface mipc_def_manager()

//@property (assign, nonatomic) struct pack_def_list *new_def_list;
//@property (assign, nonatomic) struct pack_def_list *old_def_list;

@end

@implementation mipc_def_manager

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self create_def_list];
    }
    
    return self;
}

+ (mipc_def_manager*)shared_def_manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        def_manager = [[super allocWithZone:nil] init];
    });
    return def_manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self shared_def_manager];
}

//check the msg is old or not, tranfer to the same
- (void)checkMsgRsp:(mjson_msg*)msg
{ 
    char *oldmsg = malloc(20480);
    if (NULL != oldmsg && msg && msg.data)
    {
        if (0 != json_encode(msg.data, oldmsg, 20480))
        {
            char *newmsg = [self def_o2n:msg.type dataJson:oldmsg];
            if (NULL == newmsg || 0 == strlen(newmsg) || NULL == (msg.data = json_decode(strlen(newmsg), newmsg)))
            {
                msg.data = NULL;
            }
            free(newmsg);
        }
        else
        {
            msg.data = NULL;
        }
        free(oldmsg);
    }
    else
    {
        msg.data = NULL;
    }
}

- (void)checkMsgRqt:(NSString**)type dataJson:(NSString**)dataJson
{
    *dataJson = [self def_n2o:*type dataJson:*dataJson];
    *type = DEFLIST_N2O[*type];
}

- (NSString*)def_n2o:(NSString*)type dataJson:(NSString*)dataJson
{
    if (nil == type || nil == dataJson)
    {
        return nil;
    }
    
    if (_def_obj_list || [self create_def_list])
    {
        def_obj *obj;
        if (nil != (obj = _def_obj_list[type]))
        {
            struct pack_def *new = obj.n_def, *old = obj.o_def;
            if (new && old)
            {
                char *buf = malloc(20480);
                
                if (NULL == buf)
                    return nil;
                
                if (0 != pack_file_json_convert(new, dataJson.length, (char*)[dataJson UTF8String], old, 20480, buf,0))
                {
                    NSString *ret = [NSString stringWithFormat:@"%s",buf];
                    free(buf);
                    return ret;
                }
                free(buf);
                return nil;
            }
        }
    }
    return nil;
}

- (char*)def_o2n:(NSString*)type dataJson:(char*)dataJson
{
    if (nil == type || NULL == dataJson)
    {
        return NULL;
    }
    
    if (_def_obj_list || [self create_def_list])
    {
        def_obj *obj;
        
        if (nil != (obj = _def_obj_list[DEFLIST_O2N[type]]))
        {
            struct pack_def *new = obj.n_def, *old = obj.o_def;
            if (new && old)
            {
                char *buf = malloc(20480);
                
                if (NULL == buf) return nil;
                
                if (0 != pack_file_json_convert(old,
                                                strlen(dataJson),
                                                dataJson,
                                                new,
                                                20480,
                                                buf,
                                                0))
                {
                    return buf;
                }
            }
        }
    }
    return NULL;
}

- (BOOL)create_def_list
{
    struct xml_node *xml_node;
    NSString *path;
    
    if (NULL == _new_def_list)
    {
        path = [[NSBundle mainBundle] pathForResource:@"mipci_new_def" ofType:@"pdef"];
        
        if (NULL != (xml_node = xml_create((char*)[[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] UTF8String])))
        {
            _new_def_list = pack_def_list_create(xml_node);
            xml_destroy(xml_node);
        }
    }
    
    if (NULL == _old_def_list)
    {
        path = [[NSBundle mainBundle] pathForResource:@"mipci_old_def" ofType:@"pdef"];
        
        if (NULL !=(xml_node = xml_create((char*)[[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] UTF8String])))
        {
            _old_def_list = pack_def_list_create(xml_node);
            xml_destroy(xml_node);
        }
    }
    
    if (NULL == _new_def_list || NULL == _old_def_list)
    {
        return NO;
    }
    
    self.def_obj_list = [NSMutableDictionary dictionaryWithCapacity:40];
    
    [DEFLIST_N2O enumerateKeysAndObjectsUsingBlock:^(id new,id old,BOOL *stop){
        NSString *ns_new_type = new, *ns_old_type = old;
        
        def_obj *ojb = [[def_obj alloc] init];
        ojb.o_type = ns_new_type;
        ojb.n_type   = ns_old_type;
        ojb.n_def  = pack_def_get(_new_def_list, ns_new_type.length, (char*)[ns_new_type UTF8String]);
        ojb.o_def  = pack_def_get(_old_def_list, ns_old_type.length, (char*)[ns_old_type UTF8String]);
        [_def_obj_list setObject:ojb forKey:ns_new_type];
    }];
    
    return YES;
}

@end
