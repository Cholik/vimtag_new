//
//  mipc_data_object.m
//  mipci
//
//  Created by mining on 14-7-25.
//
//

#import "mipc_data_object.h"
#include "mpack_file/mpack_file.h"
#import "mlicense/mlicense.h"
#import "MIPCUtils.h"

@interface mmq_task()

@end
@implementation mmq_task

@end


@interface mjson_msg()
//
@end

@implementation mjson_msg

-(mjson_msg*)initWithJson:(struct json_object*)json
{
    if(self = [super init])
    {
        _json = json;
        if(_json)
        {
            long            l_value;
            struct len_str  type;
            _data = json_get_child_by_name(_json, NULL, len_str_def_const("data"));
            if((0 == json_get_child_string(_json, "type", &type)) && type.len)
            {
                _type = [[NSString alloc] initWithUTF8String:type.data];
            }
            _from           = (json_get_child_long(_json, "from",           &l_value))?0:l_value;
            _from_handle    = (json_get_child_long(_json, "from_handle",    &l_value))?0:l_value;
            _to             = (json_get_child_long(_json, "to",             &l_value))?0:l_value;
            _to_handle      = (json_get_child_long(_json, "to_handle",      &l_value))?0:l_value;
        }
    }
    return self;
}
@end

#pragma mark- mdec_msg
@interface mdev_msg()
//- (mdev_msg *)initWithJson:(struct json_object*)obj;
@end

@implementation mdev_msg

- (mdev_msg *)initWithJson:(struct json_object*)obj
{
    if(self = [super init])
    {
        struct len_str   s_user = {0}, s_code = {0}, s_sn = {0}, s_type = {0};
        long l_msg_id = 0, l_data = 0, l_lenght = 0;
        
        json_get_child_string(obj, "user", &s_user);
        json_get_child_string(obj, "sn", &s_sn);
        json_get_child_long(obj, "date", &l_data);
        json_get_child_string(obj, "code", &s_code);
        json_get_child_string(obj, "type", &s_type);
        json_get_child_long(obj, "msg_id", &l_msg_id);
        
        struct json_object  *params = json_get_child_by_name(obj, NULL, len_str_def_const("p"));
        l_lenght = json_get_field_long(params, len_str_def_const("video_length"));
        
        long            duration = l_lenght /1000, hours, minutes, seconds;
        hours = duration / 3600, minutes = duration  / 60, seconds = duration % 60;
        NSString *ns_duration = [[NSString alloc] init];
        if (hours) {
            ns_duration = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
        } else {
            ns_duration = [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
        }
        
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateFormatter *hms_formatter = [[NSDateFormatter alloc] init];
        [hms_formatter setCalendar:calendar];
        [hms_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:l_data];
        NSString *ns_date = [hms_formatter stringFromDate:detaildate];
        
        self.type            = s_type.len?[NSString stringWithUTF8String:s_type.data]:@"";
        self.user            = s_user.len?[NSString stringWithUTF8String:s_user.data]:@"";
        self.sn              = s_sn.len?[NSString stringWithUTF8String:s_sn.data]:@"";
        self.date            = l_data;
        self.code            = s_code.len?[NSString stringWithUTF8String:s_code.data]:@"";
        self.msg_id          = l_msg_id;
        if (params) {
            self.thumb_img_token = json_get_field_string(params, len_str_def_const("img_thumb_token"));
            self.min_img_token   = json_get_field_string(params, len_str_def_const("img_min_token"));
            self.record_token    = json_get_field_string(params, len_str_def_const("video_token"));
            self.img_token       = json_get_field_string(params, len_str_def_const("img_token"));
            self.length          = l_lenght;
            self.format_length   = ns_duration;
            self.format_data     = ns_date;
            self.status          = json_get_field_string(params, len_str_def_const("status"));
            self.nick            = json_get_field_string(params, len_str_def_const("nick"));
            self.version         = json_get_field_string(params, len_str_def_const("version"));
            self.exsw            = json_get_field_long(params, len_str_def_const("s.exsw"));
            self.mode            = json_get_field_string(params, len_str_def_const("purify_mode"));
            self.windSpeed       = json_get_field_string(params, len_str_def_const("fan"));
            self.bp              = json_get_field_string(params, len_str_def_const("bp"));
            self.alert          = json_get_field_string(params, len_str_def_const("s.alert"));
            self.accessory_sn   = json_get_field_string(params, len_str_def_const("sn"));
            self.accessory_type   = json_get_field_string(params, len_str_def_const("type"));
            self.ok            = json_get_field_long(params, len_str_def_const("ok"));
            self.exit            = json_get_field_long(params, len_str_def_const("exit"));
            self.event   = json_get_field_string(params, len_str_def_const("event"));
            self.exnick = json_get_field_string(params, len_str_def_const("exnick"));
        }
        
        
//        struct json_object  *value = json_get_child_by_name(params, NULL, len_str_def_const("s.motion"));
//        struct json_object  *value = json_get_field(params, (sizeof("s.motion") - 1), (char*)("s.motion"));
        
    }
    return self;
}

@end

/*-----------------------------device--------------------------------*/

@implementation m_dev

- (instancetype)initWithJson:(struct json_object*)obj
{
    if(self = [super init])
    {
        struct json_object *parma = NULL;
        struct len_str     type = {0}, sn = {0}, status = {0}, nick = {0}, img_ver = {0}, mfc = {0}, model = {0};
        
        json_get_child_string(obj, "sn", &sn);
        json_get_child_string(obj, "stat", &status);
        json_get_child_string(obj, "img_ver", &img_ver);
        json_get_child_string(obj, "nick", &nick);
        json_get_child_string(obj, "mfc", &mfc);
        json_get_child_string(obj, "model", &model);
        json_get_child_string(obj, "type", &type);
        parma = json_get_child_by_name(obj, NULL, len_str_def_const("p"));
        
        self.sn       = sn.len ? [NSString stringWithUTF8String:sn.data] :nil;
        self.status   = status.len ? [NSString stringWithUTF8String:status.data] : nil;
        self.nick     = nick.len ? [NSString stringWithUTF8String:nick.data] : nil;
        self.img_ver  = img_ver.len ? [NSString stringWithUTF8String:img_ver.data] : nil;
        self.mfc      = mfc.len ? [NSString stringWithUTF8String:mfc.data] : nil;
        self.model    = model.len ? [NSString stringWithUTF8String:model.data] : nil;
        self.type     = type.len ? [NSString stringWithUTF8String:type.data] : nil;
        
        if(parma)
        {
            self.msg_id_min = json_get_field_long(parma, len_str_def_const("s.minid"));
            self.msg_id_max = json_get_field_long(parma, len_str_def_const("s.maxid"));
            self.exsw = json_get_field_long(parma, len_str_def_const("s.exsw"));
            self.wifi_status = json_get_field_string(parma, len_str_def_const("s.wifs"));
            self.wifi_quality = json_get_field_string(parma, len_str_def_const("s.wifq"));
            self.model = [json_get_field_string(parma, len_str_def_const("s.model")) isEqualToString:@""] ? self.model : json_get_field_string(parma, len_str_def_const("s.model"));
            self.spv = json_get_field_long(parma, len_str_def_const("s.spv"));
            self.ubx = json_get_field_long(parma, len_str_def_const("s.ubx"));
            self.alert = json_get_field_string(parma, len_str_def_const("s.alert"));
//            self.windSpeed = json_get_field_string(parma, len_str_def_const("s."));
            self.p0 = json_get_field_string(parma, len_str_def_const("p0"));
            self.p1 = json_get_field_string(parma, len_str_def_const("p1"));
            self.p2 = json_get_field_string(parma, len_str_def_const("p2"));
            self.p3 = json_get_field_string(parma, len_str_def_const("p3"));
            self.ratio = json_get_field_long(parma, len_str_def_const("s.ratio"));

            if ([self.type isEqualToString:@"IPC"]) {
                self.scene   = json_get_field_string(parma, len_str_def_const("s.scene"));
                self.support_scene = json_get_field_long(parma, len_str_def_const("s.oscene"));
                self.add_accessory = json_get_field_long(parma, len_str_def_const("s.rffreq"));
            }
            self.timeZone = json_get_field_string(parma, len_str_def_const("timezone"));
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_sn forKey:@"sn"];
    [aCoder encodeObject:_nick forKey:@"nick"];
    [aCoder encodeObject:_img_ver forKey:@"imgView"];
    [aCoder encodeObject:_model forKey:@"model"];
    [aCoder encodeObject:_mfc forKey:@"mfc"];
    [aCoder encodeObject:_status forKey:@"status"];
    [aCoder encodeObject:_img_token forKey:@"img_token"];
    [aCoder encodeInteger:_msg_id_max forKey:@"max"];
    [aCoder encodeInteger:_msg_id_min forKey:@"min"];
    [aCoder encodeInteger:_read_id forKey:@"read"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.sn = [aDecoder decodeObjectForKey:@"sn"] ;
        self.nick = [aDecoder decodeObjectForKey:@"nick"];
        self.img_ver = [aDecoder decodeObjectForKey:@"imgView"];
        self.model = [aDecoder decodeObjectForKey:@"model"];
        self.mfc = [aDecoder decodeObjectForKey:@"mfc"];
        self.status = [aDecoder decodeObjectForKey:@"status"];
        self.img_token = [aDecoder decodeObjectForKey:@"img_token"];
        self.msg_id_max = [aDecoder decodeIntegerForKey:@"max"];
        self.msg_id_min = [aDecoder decodeIntegerForKey:@"min"];
        self.read_id = [aDecoder decodeIntegerForKey:@"read"];
    }
    return self;
}

@end



@interface mdev_devs()
@property(strong) NSMutableArray       *arr;
@property(strong) NSMutableDictionary  *dic;
@property(strong) NSMutableArray       *local_arr;
@property(strong) NSMutableDictionary  *local_dic;
- (void)add_dev:(m_dev*)dev;
- (void)del_dev:(NSString*)sn;
@end

@implementation mdev_devs

- (id)init
{
    if(self = [super init])
    {
        _arr = [NSMutableArray array];
        _dic = [NSMutableDictionary dictionary];
        
//        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//        NSArray *cache_arr = [user objectForKey:@"mipci_devs"];
//        if(cache_arr && cache_arr.count)
//        {
//            [cache_arr enumerateObjectsUsingBlock:^(NSData *dev_data, NSUInteger index, BOOL *stop){
//                m_dev *dev = [NSKeyedUnarchiver unarchiveObjectWithData:dev_data];
//                [_arr addObject:dev];
//                [_dic setObject:dev forKey:dev.sn];
//            }];
//        }
    }
    return self;
}

- (void)save
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableArray *cache_arr = [NSMutableArray arrayWithCapacity:_arr.count];
    [_arr enumerateObjectsUsingBlock:^(m_dev *dev, NSUInteger index, BOOL *stop){
        NSData *dev_data = [NSKeyedArchiver archivedDataWithRootObject:dev];
        [cache_arr addObject:dev_data];
    }];
    [user setObject:cache_arr forKey:@"mipci_devs"];
    [user synchronize];
}

- (void)unsave
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"mipci_devs"];
    [user synchronize];
}

- (void)reset
{
    [_arr removeAllObjects];
    [_dic removeAllObjects];
}

- (NSInteger)getCounts
{
    return _arr.count;
}

- (m_dev*)get_dev_by_index:(NSInteger)index
{
    return [_arr objectAtIndex:index];
}

- (m_dev*)get_dev_by_sn:(NSString *)sn
{
    return [_dic objectForKey:sn.lowercaseString];
}

- (void)del_dev:(NSString *)sn
{
    m_dev *dev = [_dic objectForKey:sn.lowercaseString];
    if(dev)
    {
        [_arr removeObject:dev];
        [_dic removeObjectForKey:sn.lowercaseString];
    }
}

- (void)add_dev:(m_dev*)dev
{
    m_dev *old_dev = [_dic objectForKey:dev.sn];
    if(nil == dev || [dev isEqual:old_dev])
        return;
    
//    if(old_dev)
//    {
//        [_arr removeObject:old_dev];
//    }
//
//    if (NSOrderedSame == [dev.status caseInsensitiveCompare:@"offline"] || _arr.count == 0) {
//        [_arr addObject:dev];
//    }
//    else if (NSOrderedSame == [dev.status caseInsensitiveCompare:@"InvalidAuth"]) {
//        for (int i = 0; i < _arr.count; i++) {
//            m_dev *temp_dev = [_arr objectAtIndex:i];
//            if (NSOrderedSame == [temp_dev.status caseInsensitiveCompare:@"offline"]) {
//                [_arr insertObject:dev atIndex:i];
//                return;
//            }
//            else if (i == _arr.count-1){
//                [_arr addObject:dev];
//                return;
//            }
//        }
//    }
//    else{
//        if ([dev.type isEqualToString:@"BOX"]) {
//            for (int i = 0; i < _arr.count; i++) {
//                m_dev *temp_dev = [_arr objectAtIndex:i];
//                if (NSOrderedSame == [temp_dev.status caseInsensitiveCompare:@"InvalidAuth"]) {
//                    [_arr insertObject:dev atIndex:i];
//                    return;
//                }
//                else if (i == _arr.count-1){
//                    [_arr addObject:dev];
//                    return;
//                }
//            }
//        }
//        else{
//            [_arr insertObject:dev atIndex:0];
//            
//        }
//    
//    }

    
    if(old_dev)
    {
        NSUInteger index = [_arr indexOfObject:old_dev];
        [_arr insertObject:dev atIndex:index];
        [_arr removeObject:old_dev];
    }
    else
    {
        [_arr addObject:dev];
    }
    [_dic setObject:dev forKey:dev.sn];
}

@end

/*-----------------------------device--------------------------------*/

struct len_str;
struct json_object;

@implementation mdev_call_ctx

@end

@implementation mdev_call_ret

@end

@implementation mcall_ctx_sign_up

@end

@implementation mcall_ret_sign_up
@end

@implementation mcall_ctx_sign_in

-(instancetype)init
{
    self = [super init];
    if (self) {
//        self.sync = NO;
    }
    
    return self;
}

@end

@implementation mcall_ret_sign_in
@end

@implementation mcall_ctx_sign_out
@end

@implementation mcall_ret_sign_out
@end

@implementation mcall_ctx_devs_refresh
@end

@implementation mcall_ret_devs_refresh

@end

@implementation mcall_ctx_play

@end

@implementation mcall_ret_play

@end

@implementation mcall_ctx_playback

@end

@implementation mcall_ret_playback

@end

@implementation mcall_ctx_pushtalk

@end

@implementation mcall_ret_pushtalk

@end

@implementation mcall_ctx_pic_get

-(instancetype)init
{
    self = [super init];
    if (self) {
        _flag = 0;//default value
    }
    
    return self;
}

@end

@implementation mcall_ret_pic_get

@end

@implementation mcall_ctx_snapshot

@end

@implementation mcall_ret_snapshot

@end

@implementation mcall_ctx_ptz_ctrl

@end

@implementation mcall_ret_ptz_ctrl

@end

@implementation mcall_ctx_dev_msg_listener_add

@end

@implementation mcall_ctx_dev_msg_listener_del

@end

@implementation mcall_ctx_cam_get
@end

@implementation mcall_ret_cam_get

@end

@implementation mcall_ctx_cam_set

@end

@implementation mcall_ret_cam_set

@end

@implementation mcall_ctx_dev_info_get

@end

@implementation mcall_ret_dev_info_get

@end

@implementation mcall_ctx_nick_set

@end

@implementation mcall_ret_nick_set

@end

@implementation  mcall_ctx_dev_add

@end

@implementation mcall_ret_dev_add

@end

@implementation mcall_ctx_dev_del

@end

@implementation mcall_ret_dev_del

@end

@implementation mcall_ctx_account_passwd_set

@end

@implementation mcall_ret_account_passwd_set

@end

@implementation mcall_ctx_msgs_get

@end

@implementation mcall_ret_msgs_get

@end

@implementation mcall_ctx_record

@end

@implementation mcall_ret_record

@end

@implementation mcall_ctx_dev_passwd_set

@end

@implementation mcall_ret_dev_passwd_set

@end

@implementation mcall_ctx_trigger_action_get

@end

@implementation mcall_ret_trigger_action_get

@end

@implementation mcall_ctx_trigger_action_set

@end

@implementation mcall_ret_trigger_action_set

@end

@implementation mcall_ctx_osd_get

@end

@implementation mcall_ret_osd_get

@end

@implementation mcall_ctx_osd_set

@end

@implementation mcall_ret_osd_set

@end

@implementation mcall_ret_sd_get

@end

@implementation mcall_ctx_sd_get

@end

@implementation mcall_ctx_sd_set

@end

@implementation mcall_ret_sd_set

@end

@implementation mcall_ctx_time_get

@end

@implementation mcall_ret_time_get

@end

@implementation mcall_ctx_time_set

@end

@implementation mcall_ret_time_set

@end

@implementation alarm_action

@end

@implementation mcall_ctx_alarm_action_get

@end

@implementation mcall_ret_alarm_action_get

@end

@implementation mcall_ctx_alarm_action_set

@end

@implementation mcall_ret_alarm_action_set

@end

@implementation mdev_time

@end

@implementation mcall_ctx_record_get

@end

@implementation mcall_ret_record_get

@end

@implementation mcall_ctx_record_set

@end

@implementation mcall_ret_record_set

@end

@implementation mcall_ctx_upgrade_set

@end

@implementation mcall_ret_upgrade_set

@end

@implementation mcall_ctx_upgrade_get

@end

@implementation mcall_ret_upgrade_get

@end

@implementation mcall_ctx_restore

@end

@implementation mcall_ret_restore

@end

@implementation mcall_ctx_reboot

@end

@implementation mcall_ret_reboot

@end

@implementation mcall_ctx_audio_set

@end

@implementation mcall_ret_audio_set

@end

@implementation mcall_ctx_audio_get

@end

@implementation mcall_ret_audio_get

@end

@implementation mcall_ctx_video_set
@end

@implementation mcall_ret_video_set

@end

@implementation mcall_ctx_video_get

@end

@implementation mcall_ret_video_get

@end

@implementation wifi_obj

@end

@implementation ip_obj

@end

@implementation net_info_obj

@end

@implementation dhcp_srv_obj

@end

@implementation net_obj

@end

@implementation dns_obj

@end

@implementation mcall_ctx_net_get

@end

@implementation mcall_ret_net_get

@end

@implementation mcall_ctx_net_set

@end

@implementation mcall_ret_net_set

@end


@implementation mcall_ctx_alarm_mask_get

@end

@implementation mcall_ctx_alarm_mask_set

@end

@implementation mcall_ret_alarm_mask_get

@end

@implementation mcall_ret_alarm_mask_set

@end

@implementation mcall_ctx_notification_get

@end

@implementation mcall_ret_notification_get

@end

@implementation mcall_ctx_notification_set

@end

@implementation mcall_ret_notification_set

@end

@implementation mcall_ctx_cursise_get

@end

@implementation curise_point

@end

@implementation mcall_ret_curise_get

@end


@implementation mcall_ctx_cursise_set

@end

@implementation mcall_ret_curise_set

@end

@implementation mcall_ctx_play_segs_get

@end

@implementation mcall_ret_play_segs_get

@end

@implementation seg_obj

@end

@implementation mcall_ctx_ipcs_get

@end

@implementation mcall_ret_ipcs_get

@end

@implementation ipc_obj

@end

@implementation mcall_ctx_exsw_get

@end

@implementation mcall_ret_exsw_get
@end

@implementation mcall_ctx_exsw_set
@end

@implementation mcall_ret_exsw_set

@end

@implementation box_conf

@end

@implementation mcall_ctx_box_conf_get

@end

@implementation mcall_ret_box_conf_get

@end

@implementation mcall_ctx_box_login

@end

@implementation mcall_ret_box_login

@end

@implementation mcall_ctx_box_get

@end
@implementation mcall_ctx_box_set

@end

@implementation date_info_obj

@end

@implementation seg_sdc_obj

@end

@implementation mcall_ret_box_get

@end
@implementation mcall_ret_box_set

@end

//-----------------------------------
@implementation mipc_data_object

@end

//-----------------------------------
@implementation mcall_ctx_alert_task_get

@end

@implementation mcall_ret_alert_task_get

@end

@implementation mcall_ctx_alert_task_set

@end

@implementation mcall_ret_alert_task_set

@end

@implementation mcall_ctx_cap_get

@end
@implementation mcall_ret_cap_get

@end
@implementation mcall_ctx_uart_set

@end

@implementation mcall_ret_uart_set

@end
//--------------------------
@implementation mcall_ctx_log_reg

@end

@implementation mcall_ret_log_reg

@end

@implementation mcall_ctx_email_set

@end

@implementation mcall_ret_email_set

@end

@implementation mcall_ctx_email_get

@end

@implementation mcall_ret_email_get

@end

@implementation mcall_ctx_recovery_password

@end
@implementation mcall_ret_recovery_password

@end
@implementation mcall_ctx_get_desc

@end
@implementation mcall_ret_get_desc

@end

@implementation post_item

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.action = [aDecoder decodeObjectForKey:@"action"];
        self.time = [aDecoder decodeInt64ForKey:@"time"];
        self.num = [aDecoder decodeObjectForKey:@"num"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.action forKey:@"action"];
    [aCoder encodeInt64:self.time forKey:@"time"];
    [aCoder encodeObject:self.num forKey:@"num"];
    
}


@end
@implementation mcall_ctx_post_get

@end
@implementation mcall_ret_post_get

@end

@implementation address_obj

@end

@implementation zone_obj : NSObject

- (instancetype)initWithJson:(struct json_object*)obj
{
    if(self = [super init])
    {
        struct len_str     utc = {0}, city = {0}, file = {0};
        json_get_child_string(obj, "utc", &utc);
        json_get_child_string(obj, "city", &city);
        json_get_child_string(obj, "file", &file);
        
        self.utc      = utc.len ? [NSString stringWithUTF8String:utc.data] :nil;
        self.city     = city.len ? [NSString stringWithUTF8String:city.data] : nil;
        self.file     = file.len ? [NSString stringWithUTF8String:file.data] : nil;
        
    }
    
    return self;
}


@end


@implementation mcall_ctx_timezone_get

@end
@implementation mcall_ret_timezone_get

@end
//-------------------------
@implementation mSchedule_obj

@end

@implementation mcall_ctx_schedule_get

@end

@implementation mcall_ret_schedule_get

@end

@implementation mcall_ctx_schedule_set

@end

@implementation mcall_ret_schedule_set

@end

@implementation mScene_obj

@end

@implementation mcall_ctx_scene_get

@end

@implementation mcall_ret_scene_get

@end

@implementation mcall_ctx_scene_set

@end

@implementation mcall_ret_scene_set

@end

@implementation mcall_ctx_exdev_discover

@end

@implementation mcall_ret_exdev_discover

@end

@implementation mExDev_obj

@end

@implementation mcall_ctx_exdev_get

@end

@implementation mcall_ret_exdev_get

@end

@implementation mcall_ctx_exdev_set

@end

@implementation mcall_ret_exdev_set

@end

@implementation mcall_ctx_exdev_add

@end

@implementation mcall_ret_exdev_add

@end

@implementation mcall_ctx_exdev_del

@end
@implementation mcall_ret_exdev_del

@end

@implementation mcall_ctx_version_get

@end
@implementation mcall_ret_version_get

@end
@implementation sceneExdev_obj

@end

@implementation mcall_ctx_change_interface

@end

@implementation mcall_ret_change_interface

@end
