//
//  mipc_agent.h
//  mipci
//
//  Created by mining on 14-7-23.
//
//

#import <Foundation/Foundation.h>
#import "mipc_data_object.h"

#define MIPC_MIN_VERSION_MESSAGE_PICK           @"13.03.28.00.00"
#define MIPC_MIN_VERSION_DEVICE_PICK            @"13.03.22.17.01"
#define MIPC_MIN_VERSION_OLD_VER                @"12.12.31.59.59"
#define MIPC_MIN_VERSION_RECORD_VER             @"13.05.15.00.00"
#define MIPC_MIN_VERSION_RECORD_SEGMENT_VER     @"13.05.20.00.00"
#define MIPC_MIN_VERSION_TIMEZONE_VER           @"13.06.01.00.00"
#define MIPC_MIN_PERMISSION_DENIED              @"13.09.02.00.00"
#define MIPC_MIN_IPC_CONFIG                     @"13.09.04.00.00"

#define LOG_TYPE_REQUEST        101
#define LOG_TYPE_RESPONSE       102
#define LOG_TYPE_EXCEPTION      103

@interface mipc_agent : NSObject <NSURLConnectionDelegate>

//----- mjson_msg_agent.h  -----  start
@property (assign, nonatomic) long m_from_handle;//for each network request

//----- mjson_msg_agent.h  -----  end

@property (strong, nonatomic) mdev_devs            *devs;
@property (strong, nonatomic) NSString             *device_token;

//@property (strong, nonatomic) mdev_msgs            *msgs;
//@property (strong, nonatomic) mdev_msg *msg;以后再修改

@property (strong, nonatomic) mmq_task             *mmq_task;
@property(strong, nonatomic) NSString                *srv;
@property(strong, nonatomic) NSString                *qid;
@property(strong, nonatomic) NSString                *shareKey;
@property(assign, nonatomic) int64_t                 sid;
@property(assign, nonatomic) int64_t                 lid;
@property(strong, nonatomic) NSString                *webLid;


@property(assign)          BOOL                    devs_need_cache;// use NSUserDefaults
@property(assign,setter=setMsgs_need_cacheA:) BOOL msgs_need_cache;// use sqlite3
@property(strong,readonly) NSString                *user;
@property(assign,readonly) unsigned char           *passwd;// need - (void)passwd_encrypt:..  encrypt;
@property(strong,readonly) NSString                *srv_type;
//@property(strong)          NSOperationQueue        *queue;

+ (mipc_agent *)shared_mipc_agent;

+ (void)passwd_encrypt:(NSString*)pwd encrypt_pwd:(unsigned char*)encrypt_pwd/*--out--*/;
- (void)get_result:(struct json_object*)data result:(struct len_str *)result /* [out] */;
- (NSString*)mipc_build_nid;

- (NSString *)mipcGetSrv:(NSString*)srv
                    user:(NSString*)user
                    cert:(NSString**)cert /* [out], can be NULL */
                    name:(NSString**)name /* [out], can be NULL */
                    pubk:(NSString**)pubk; /* [out], can be NULL */

- (NSData*)build_mining64_data:(mcall_ctx_log_reg *)ctx;

//notification
- (void)mmqTaskDestory;
- (void)mmqTaskCreate;
- (long)createFromHandle;

- (long)sign_up:(mcall_ctx_sign_up*)ctx;//ret:mcall_ret_SignUp
//- (long)sign_in:(mcall_ctx_sign_in*)ctx;//ret:mcall_ret_sign_in
- (long)local_sign_in:(mcall_ctx_sign_in *)ctx switchMmq:(BOOL)operation;
- (long)sign_in:(mcall_ctx_sign_in *)ctx;
- (long)sign_out:(mcall_ctx_sign_out*)ctx;

- (long)devs_refresh:(mcall_ctx_devs_refresh*)ctx;//ret:mcall_ret_devs_refresh
- (long)play:(mcall_ctx_play*)ctx;//ret:mcall_ret_play
- (long)pushtalk:(mcall_ctx_pushtalk*)ctx;//mcall_ret_pushtalk
- (long)playback:(mcall_ctx_playback*)ctx;//ret:mcall_ret_playback
- (NSString *)pic_url_create:(mcall_ctx_pic_get*)ctx;
- (long)pic_get:(mcall_ctx_pic_get*)ctx;
- (long)snapshot:(mcall_ctx_snapshot*)ctx;
- (long)ptz_ctrl:(mcall_ctx_ptz_ctrl*)ctx;
- (long)dev_add:(mcall_ctx_dev_add*)ctx;
- (long)dev_del:(mcall_ctx_dev_del*)ctx;
- (long)account_passwd_set:(mcall_ctx_account_passwd_set*)ctx;
- (long)msgs_get:(mcall_ctx_msgs_get*)ctx;
- (long)record:(mcall_ctx_record*)ctx;


- (long)dev_msg_listener_add:(mcall_ctx_dev_msg_listener_add*)add;//mcall_ret_MsgListen;
- (long)dev_msg_listener_del:(mcall_ctx_dev_msg_listener_del*)del;

- (long)cam_get:(mcall_ctx_cam_get*)ctx;
- (long)cam_set:(mcall_ctx_cam_set*)ret;
- (long)dev_info_get:(mcall_ctx_dev_info_get*)ctx;
- (long)nick_set:(mcall_ctx_nick_set*)ctx;
- (long)dev_passwd_set:(mcall_ctx_dev_passwd_set*)ctx;
- (long)alarm_trigger_get:(mcall_ctx_trigger_action_get*)ctx;
- (long)alarm_trigger_set:(mcall_ctx_trigger_action_set*)ctx;
- (long)osd_get:(mcall_ctx_osd_get*)ctx;
- (long)osd_set:(mcall_ctx_osd_set*)ctx;
- (long)sd_get:(mcall_ctx_sd_get*)ctx;
- (long)sd_set:(mcall_ctx_sd_set*)ctx;
- (long)time_get:(mcall_ctx_time_get*)ctx;
- (long)time_set:(mcall_ctx_time_set*)ctx;
- (long)alarm_action_get:(mcall_ctx_alarm_action_get*)ctx;
- (long)alarm_action_set:(mcall_ctx_alarm_action_set*)ctx;
- (long)record_get:(mcall_ctx_record_get*)ctx;
- (long)record_set:(mcall_ctx_record_set*)ctx;
- (long)upgrade_set:(mcall_ctx_upgrade_set*)ctx;
- (long)upgrade_get:(mcall_ctx_upgrade_get*)ctx;
- (long)restore:(mcall_ctx_restore*)ctx;
- (long)reboot:(mcall_ctx_reboot*)ctx;
- (long)audio_get:(mcall_ctx_audio_get*)ctx;
- (long)audio_set:(mcall_ctx_audio_set*)ctx;
- (long)video_get:(mcall_ctx_video_get*)ctx;
- (long)video_set:(mcall_ctx_video_set*)ctx;
- (long)net_get:(mcall_ctx_net_get*)ctx;
- (long)net_set:(mcall_ctx_net_set*)ctx;
- (long)alarm_mask_get:(mcall_ctx_alarm_mask_get*)ctx;
- (long)alarm_mask_set:(mcall_ctx_alarm_mask_set*)ctx;
- (long)notification_get:(mcall_ctx_notification_get*)ctx;
- (long)notification_set:(mcall_ctx_notification_set*)ctx;
- (long)alarm_curise_get:(mcall_ctx_cursise_get*)ctx;
- (long)alarm_curise_set:(mcall_ctx_cursise_set*)ctx;
- (long)ipcs_get:(mcall_ctx_ipcs_get*)ctx;
- (long)play_segs_get:(mcall_ctx_play_segs_get*)ctx;
- (long)exsw_get:(mcall_ctx_exsw_get*)ctx;
- (long)exsw_set:(mcall_ctx_exsw_set*)ctx;
- (long)box_conf_get:(mcall_ctx_box_conf_get*)ctx;
- (long)box_login:(mcall_ctx_box_login*)ctx;
- (long)box_get:(mcall_ctx_box_get*)ctx;
- (long)box_set:(mcall_ctx_box_set*)ctx;
//----------------------------------
- (long)alert_task_get:(mcall_ctx_alert_task_get*)ctx;
- (long)alert_task_set:(mcall_ctx_alert_task_set *)ctx;

- (long)cap_get:(mcall_ctx_cap_get *)ctx;
- (long)uart_set:(mcall_ctx_uart_set *)ctx;

- (long)log_req:(mcall_ctx_log_reg *)ctx;

- (long)bind_email_set:(mcall_ctx_email_set *)ctx;
- (long)bind_email_get:(mcall_ctx_email_get *)ctx;
- (long)email_set:(mcall_ctx_email_set *)ctx;
- (long)email_get:(mcall_ctx_email_get *)ctx;
- (long)recovery_password:(mcall_ctx_recovery_password *)ctx;
- (long)get_desc:(mcall_ctx_get_desc *)ctx;
- (long)post_get:(mcall_ctx_post_get *)ctx;
- (long)timezone_get:(mcall_ctx_timezone_get *)ctx;
- (long)version_get:(mcall_ctx_version_get *)ctx;

- (long)dev_timezone_get:(mcall_ctx_time_get *)ctx;
- (long)dev_timezone_set:(mcall_ctx_time_set *)ctx;
- (long)logo_get:(mcall_ctx_snapshot*)ctx;

-(long)exdev_add:(mcall_ctx_exdev_add *)ctx;
-(long)exdev_del:(mcall_ctx_exdev_del *)ctx;
-(long)exdev_set:(mcall_ctx_exdev_set *)ctx;
-(long)exdev_get:(mcall_ctx_exdev_get *)ctx;
-(long)exdev_discover:(mcall_ctx_exdev_discover *)ctx;
-(long)scene_set:(mcall_ctx_scene_set *)ctx;
-(long)scene_get:(mcall_ctx_scene_get *)ctx;
-(long)schedule_get:(mcall_ctx_schedule_get *)ctx;
-(long)schedule_set:(mcall_ctx_schedule_set *)ctx;


@end
