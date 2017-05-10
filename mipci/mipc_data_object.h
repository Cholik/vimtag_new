//
//  mipc_data_object.h
//  mipci
//
//  Created by mining on 14-7-25.
//
//

#import <Foundation/Foundation.h>
#import "mios_core_frameworks.h"

typedef enum {
    mdev_time_null = 0,
    mdev_time_sun  = 1<<0,
    mdev_time_mon  = 1<<1,
    mdev_time_tue  = 1<<2,
    mdev_time_wed  = 1<<3,
    mdev_time_thu  = 1<<4,
    mdev_time_fri  = 1<<5,
    mdev_time_sat  = 1<<6
} mdev_time_type;

typedef enum {
    mdev_pic_snapshot = 0,
    mdev_pic_thumb,
    mdev_pic_album,
    mdev_pic_seg_album
} mdev_pic_type;

@interface mmq_task : NSObject

@property (strong, nonatomic) NSString *    qid;
@property (strong, nonatomic) NSString *    srv;

@property (assign, nonatomic) BOOL      isRun;

@end

@interface mjson_msg: NSObject

@property (assign, readonly)    long                from;
@property (assign, readonly)    long                from_handle;
@property (assign, readonly)    long                to;
@property (assign, readonly)    long                to_handle;
@property (assign, readonly)    struct json_object  *json;
@property (strong)              NSString            *type;  /* copy from json */
@property (assign)              struct json_object  *data;  /*!< pointer to json */

-(mjson_msg*) initWithJson:(struct json_object*)json;

@end


@interface mdev_msg : NSObject
@property(assign, nonatomic) long      msg_id;
@property(strong, nonatomic) NSString  *sn;
@property(strong, nonatomic) NSString  *code;
@property(strong, nonatomic) NSString  *type;
@property(strong, nonatomic) NSString  *user;
@property(assign, nonatomic) long      date;
@property(strong, nonatomic) NSString  *format_data;
@property(strong, nonatomic) NSString  *img_token;
@property(strong, nonatomic) NSString  *thumb_img_token;
@property(strong, nonatomic) NSString  *min_img_token;
@property(strong, nonatomic) UIImage   *local_thumb_img;
@property(strong, nonatomic) NSString  *record_token;
@property(assign, nonatomic) long      length;
@property(strong, nonatomic) NSString  *format_length;
@property(strong, nonatomic) NSString  *status;
@property(strong, nonatomic) NSString  *nick;
@property(strong, nonatomic) NSString  *version;
@property(assign, nonatomic) long exsw;
@property(strong, nonatomic) NSString  *windSpeed;
@property(strong, nonatomic) NSString  *mode;
@property(strong, nonatomic) NSString  *bp;
@property(strong, nonatomic) NSString  *alert;
@property(strong, nonatomic) NSString *accessory_sn;
@property(strong, nonatomic) NSString *accessory_type;
@property(assign, nonatomic) long ok;
@property(assign, nonatomic) long exit;
@property(copy,nonatomic) NSString *event;
@property (strong, nonatomic) NSString *exnick;

- (mdev_msg *)initWithJson:(struct json_object*)obj;

@end

//---------------------------------

@interface m_dev: NSObject<NSCoding>

@property(strong, nonatomic) NSString    *sn;
@property(strong, nonatomic) NSString    *nick;
@property(strong, nonatomic) NSString    *img_ver;
@property(strong, nonatomic) NSString    *model;
@property(strong, nonatomic) NSString    *mfc;
@property(strong, nonatomic) NSString    *status; /* dev online , offline, invalidAuth */
@property(strong, nonatomic) NSString    *img_token;
@property(strong, nonatomic) NSString    *wifi_status;
@property(strong, nonatomic) NSString    *wifi_quality;
@property(assign, nonatomic) long        msg_id_max;
@property(assign, nonatomic) long        msg_id_min;
@property(assign, nonatomic) long        read_id; /*This is local cache by yourself set, need call [mdev_devs save] */
@property(assign, nonatomic) long        exsw; //design for on-off light
@property(strong, nonatomic) NSString    *type;
@property(assign, nonatomic) long        spv;
@property(assign, nonatomic) long        ubx;
@property(strong, nonatomic) NSString    *alert;
@property(strong, nonatomic) NSString    *ip_addr;
@property(strong, nonatomic) NSString    *p0;
@property(strong, nonatomic) NSString    *p1;
@property(strong, nonatomic) NSString    *p2;
@property(strong, nonatomic) NSString    *p3;
@property(strong, nonatomic) NSString    *scene;
@property(assign, nonatomic) long        support_scene;
@property(assign, nonatomic) long        add_accessory;
@property(strong, nonatomic) NSString    *timeZone;
@property(assign, nonatomic) long        ratio;
@property(assign, nonatomic) long        del_ipc;

- (m_dev*)initWithJson:(struct json_object*)obj;

@end

@interface mdev_devs : NSObject

@property(assign,readonly,getter = getCounts) NSInteger   counts;

- (m_dev*)get_dev_by_sn:(NSString*)sn;
- (m_dev*)get_dev_by_index:(NSInteger)index;
- (void)save;  /* save to local */
- (void)unsave;/* delete saved */
- (void)reset;
- (void)add_dev:(m_dev*)dev;
- (void)del_dev:(NSString *)sn;

//- (void)add_local_dev:(m_dev*)dev;
//- (void)del_local_dev:(NSString*)sn;
//- (m_dev*)get_local_dev_by_index:(NSInteger)index;
//- (m_dev*)get_local_dev_by_sn:(NSString *)sn;
//- (void)add_local_dev:(m_dev*)dev;
//- (void)reset_local;

@end

//---------------------------------------------------------------

@interface mdev_call_ctx : NSObject
@property(copy, nonatomic) NSString *sn;                 /* allow nulls */
@property(nonatomic, strong) id       target;
@property(assign) SEL      on_event;
@property(nonatomic, weak) id       ref;
@property(assign) NSTimeInterval      timeout;  /* seccods defluat 30*/
@end

@interface mdev_call_ret : NSObject
@property(strong) NSString *result;
@property(assign) id       ref;
@end

//-----------------------------//
@interface mcall_ctx_sign_in : mdev_call_ctx
@property(strong) NSString      *srv;
@property(strong) NSString      *user;
@property(assign) unsigned char *passwd;//  need encrypt     unsigned char[16]
@property(strong) NSString      *token; // apns token
@property(strong) NSString      *prev_token;// if token change need set prev token,usually set nil
//@property(assign) BOOL           sync;
@end

@interface mcall_ret_sign_in : mdev_call_ret
@end

//----
@interface mcall_ctx_sign_out : mdev_call_ctx
@end

//----
@interface mcall_ret_sign_out : mdev_call_ret
@end

//----
@interface mcall_ctx_sign_up : mdev_call_ctx
@property(strong) NSString      *srv;
@property(strong) NSString      *user;
@property(assign) unsigned char *passwd; /* need encrypt */
@end

@interface mcall_ret_sign_up : mdev_call_ret
@end

//----
@interface mcall_ctx_devs_refresh : mdev_call_ctx
@end

@class mdev_devs;
@interface mcall_ret_devs_refresh : mdev_call_ret
@property(strong) mdev_devs *devs;
@end

//----
@interface mcall_ctx_play : mdev_call_ctx
@property(strong) NSString *protocol;
@property(assign) NSString *token;/* 720p:1280x720, d1:640X360, cif:320x180, qcif:160x90*/
@end

@interface mcall_ret_play : mdev_call_ret
@property(strong) NSString *url;
@end

//----
@interface mcall_ctx_playback : mdev_call_ctx
@property(strong) NSString *token;
@property(strong) NSString *protocol;
@end

@interface mcall_ret_playback : mdev_call_ret
@property(strong) NSString *url;
@end

//----
@interface mcall_ctx_pushtalk : mdev_call_ctx
@property(strong) NSString *protocol;
@end

@interface mcall_ret_pushtalk : mdev_call_ret
@property(strong) NSString *url;
@end

//----
@interface mcall_ctx_ptz_ctrl : mdev_call_ctx
@property(assign) long x;
@property(assign) long y;
@property(assign) long z;
@end

@interface mcall_ret_ptz_ctrl : mdev_call_ret
@end

//----
@interface mcall_ctx_dev_msg_listener_add : mdev_call_ctx
@property(strong) NSString *type;   /* device,io,motion,alert,snapshot    e.g. @"device,io" */
@end

@interface mcall_ctx_dev_msg_listener_del : mdev_call_ctx
@property(strong) NSString *type;   // must be absolute equals add type , e.g. @"device,io"
@end


//----
@interface mcall_ctx_cam_set : mdev_call_ctx
@property(assign) int       brightness;       /*         */
@property(assign) int       contrast;         /* 0 - 100 */
@property(assign) int       saturation;       /*         */
@property(assign) int       sharpness;        /*         */
@property(strong) NSString  *day_night;       /*auto(default),day,night*/
@property(assign) BOOL      flip;
@property(assign) int       flicker_freq;     /*0:50hz,1:60hz*/
@property(strong) NSString  *resolute;        /*4:3 or nil*/
@end

@interface mcall_ret_cam_set : mdev_call_ret
@end


//----
@interface mcall_ctx_cam_get : mdev_call_ctx

@end

@interface mcall_ret_cam_get : mdev_call_ret
@property(assign) int       brightness;       /*         */
@property(assign) int       contrast;         /* 0 - 100 */
@property(assign) int       saturation;       /*         */
@property(assign) int       sharpness;        /*         */
@property(strong) NSString  *day_night;       /*auto(default),day,night*/
@property(assign) BOOL      flip;
@property(assign) int       flicker_freq;     /*0:50hz,1:60hz*/
@property(strong) NSString  *resolute;        /*4:3 or nil*/
@end


//----
@interface mcall_ctx_dev_info_get : mdev_call_ctx
@end

@interface mcall_ret_dev_info_get : mdev_call_ret
@property(strong) NSString *sn;
@property(strong) NSString *model;
@property(strong) NSString *img_ver;
@property(strong) NSString *bimg_ver;
@property(strong) NSString *nick;
@property(strong) NSString *type;
@property(strong) NSString *sensor_status;
@property(strong) NSString *mfc;
@property(strong) UIImage  *logo;
@property(strong) NSString *contact;
@property(strong) NSString *passwd_level;
@property(assign) long      spv;

@property(strong, nonatomic) NSString    *wifi_status;
@property(strong, nonatomic) NSString    *p0;
@property(assign, nonatomic) long        support_scene;
@property(assign, nonatomic) long        add_accessory;
@property(copy, nonatomic) NSString *timezone;
@property(assign, nonatomic) long        ratio;
@property(assign, nonatomic) long        del_ipc;

@property(strong, nonatomic) NSString *s_model;
@property(strong, nonatomic) NSString *s_mfc;
@property(strong, nonatomic) NSString *s_logo;

@end

//----
@interface mcall_ctx_nick_set : mdev_call_ctx
@property(strong) NSString *nick;
@end

@interface mcall_ret_nick_set : mdev_call_ret
@end

//----
@interface mcall_ctx_dev_add : mdev_call_ctx
@property(assign) unsigned char *passwd; /*------ need encrypt */
@end

@interface mcall_ret_dev_add : mdev_call_ret
@property(strong) m_dev*dev;
@end

//----
@interface mcall_ctx_dev_del : mdev_call_ctx
@end

@interface mcall_ret_dev_del : mdev_call_ret
@property(strong) mdev_devs *devs;
@end

//----
@interface mcall_ctx_account_passwd_set : mdev_call_ctx
@property(assign) unsigned char *old_encrypt_pwd;
@property(assign) unsigned char *new_encrypt_pwd;
@property(assign) BOOL          is_guest;
@end

@interface mcall_ret_account_passwd_set : mdev_call_ret
@end

//----
@interface mcall_ctx_msgs_get : mdev_call_ctx
@property(assign) int          counts;     /* >0 desc , <0 asc */
@property(assign) int          start_id;
@property(assign) int          flag;       /*1:record ,0:all*/
@end

@interface mcall_ret_msgs_get : mdev_call_ret
@property(strong) NSMutableArray  *msg_arr;
@property(assign) long            bound;
@end

//----
@interface mcall_ctx_record : mdev_call_ctx
@property(assign) int   keep_time;/*--time(ms) ,  >0:every set keep_time add record time  , -1:stop ------*/
@end

@interface mcall_ret_record : mdev_call_ret
@end
//----
@interface mcall_ctx_pic_get : mdev_call_ctx
@property(assign) mdev_pic_type   type;
@property(strong) NSString        *token;/*mdev_pic_snapshot and mdev_pic_album need use  -*/
@property(strong) NSString        *size; /*mdev_pic_thumb need use, 720p d1 cif qcif */
@property(assign) long            flag;
@end

@interface mcall_ret_pic_get : mdev_call_ret
@property(strong) NSString *sn;
@property(strong) UIImage   *img;
@property(strong) NSString *token;
@end

@interface mcall_ctx_snapshot : mdev_call_ctx
@property(assign) mdev_pic_type   type;
@property(strong) NSString        *token;/*mdev_pic_snapshot and mdev_pic_album need use  -*/
@property(strong) NSString        *size; /*mdev_pic_thumb need use, 720p d1 cif qcif */
@property(assign) long            flag;
@property(assign) long            spv;
@end

@interface mcall_ret_snapshot : mdev_call_ret
@property(strong) NSString *sn;
@property(strong) UIImage   *img;
@property(strong) NSString *token;
@end

//----
@interface mcall_ctx_dev_passwd_set : mdev_call_ctx
@property(assign) unsigned char *old_encrypt_pwd;
@property(assign) unsigned char *new_encrypt_pwd;
@property(assign) BOOL          is_guest;
@end

@interface mcall_ret_dev_passwd_set : mdev_call_ret
@end

//----
@interface mcall_ctx_trigger_action_get : mdev_call_ctx
@end

@interface mcall_ret_trigger_action_get: mdev_call_ret
@property(strong) NSString *input;
@property(strong) NSString *output;
@property(assign) int      sensitivity;/*0-100*/
@property(assign) int      night_sensitivity;
@end

//----
@interface mcall_ctx_trigger_action_set : mdev_call_ctx
@property(strong) NSString *input;
@property(strong) NSString *output;
@property(assign) int      sensitivity;/*0-100*/
@property(assign) int      night_sensitivity;
@end

@interface mcall_ret_trigger_action_set : mdev_call_ret
@end

//----
@interface mcall_ctx_osd_get : mdev_call_ctx
@end

@interface mcall_ret_osd_get : mdev_call_ret
@property(strong) NSString  *text;
@property(assign) BOOL      text_enable;
@property(assign) BOOL      week_enable;
@property(strong) NSString  *date_format;/* MM-DD-YYYY ro YYYY-MM-DD*/
@property(assign) BOOL      date_enable;
@property(assign) BOOL      time_12h/* y:12h ro n:24h*/;
@property(assign) BOOL      time_enable;
@end

//----
@interface mcall_ctx_osd_set : mdev_call_ctx
@property(strong) NSString  *text;
@property(assign) BOOL      text_enable;
@property(assign) BOOL      week_enable;
@property(strong) NSString  *date_format;/* MM-DD-YYYY ro YYYY-MM-DD*/
@property(assign) BOOL      date_enable;
@property(assign) BOOL      time_12h     /* y:12h ro n:24h*/;
@property(assign) BOOL      time_enable;
@end

@interface mcall_ret_osd_set : mdev_call_ret
@end

//----
@interface mcall_ctx_sd_get : mdev_call_ctx
@end

@interface mcall_ret_sd_get : mdev_call_ret
@property(assign) BOOL       enable;
@property(strong) NSString   *status;
@property(assign) long        capacity;
@property(assign) long        usage;
@property(assign) long        available_size;
@end

//----
@interface mcall_ctx_sd_set : mdev_call_ctx
@property(assign) BOOL         enable;
@property(strong) NSString     *ctrl;   /*format, umount, mount, repair*/
@end

@interface mcall_ret_sd_set : mdev_call_ret
@end

//----
@interface mcall_ctx_time_get : mdev_call_ctx
@end

@interface mcall_ret_time_get : mdev_call_ret
@property(strong) NSString    *type;  /* NTP or manually*/
@property(strong) NSString    *time_zone;/* e.g.  UTC+8:00 */
@property(assign) long         hour;
@property(assign) long         min;
@property(assign) long         sec;
@property(assign) long         year;
@property(assign) long         mon;
@property(assign) long         day;

@property(assign) BOOL        auto_sync;
@property(strong) NSString    *ntp_addr;
@end

//----
@interface mcall_ctx_time_set : mdev_call_ctx
@property(strong) NSString    *type;      /* NTP or manually*/
@property(strong) NSString    *time_zone;/* e.g.  UTC+8:00 */
@property(assign) int         hour;
@property(assign) int         min;
@property(assign) int         sec;
@property(assign) int         year;
@property(assign) int         mon;
@property(assign) int         day;

@property(assign) BOOL        auto_sync;
@property(strong) NSString    *ntp_addr;
@end

@interface mcall_ret_time_set : mdev_call_ret
@end

//----
@interface alarm_action : NSObject
@property(assign) BOOL       enable;
@property(strong) NSString   *token;/* need set mcall_ctx_alarm_action_get got token */
@property(strong) NSString   *name;
@property(strong) NSArray    *alarm_src;        /* need set mcall_ctx_alarm_action_get got alarm_src */
@property(assign) BOOL       io_out_enable;
@property(assign) BOOL       snapshot_enable;
@property(assign) BOOL       record_enable;
@property(assign) int        snapshot_interval; /* Snapshot interval during Alert on. 0 indicate only take snapshot when alert raise */
@property(assign) int        pre_record_lenght; /* must be <= 6 */
@property(assign) int        io_alart_lenght;
@end

@interface mcall_ctx_alarm_action_get : mdev_call_ctx
@end

@interface mcall_ret_alarm_action_get : mdev_call_ret
@property(assign) BOOL       enable;
@property(strong) NSArray    *alarm_items; /*0:motion alert 1:i/o alert  type:alarm_action*/
@end

//----
@interface mcall_ctx_alarm_action_set : mdev_call_ctx
@property(assign) BOOL       enable;
@property(strong) NSArray    *alarm_items;
@end

@interface mcall_ret_alarm_action_set : mdev_call_ret
@end

//----
@interface mdev_time : NSObject
@property(assign) long            start_time;
@property(assign) long            end_time;
@property(assign) mdev_time_type time;
@end

@interface mcall_ctx_record_get : mdev_call_ctx
@end

@interface mcall_ret_record_get : mdev_call_ret
@property(assign) BOOL           enable;
@property(assign) BOOL           full_time; /* 7x24 */
@property(strong) NSMutableArray *times;    /* type:mdev_time */
@property(assign) BOOL           sd_ready;
@end

//----
@interface mcall_ctx_record_set : mdev_call_ctx
@property(assign) BOOL     enable;
@property(assign) BOOL     full_time; /* 7x24 */
@property(strong) NSMutableArray *times;
@end

@interface mcall_ret_record_set : mdev_call_ret
@end

//----
@interface mcall_ctx_upgrade_set : mdev_call_ctx
@end

@interface mcall_ret_upgrade_set : mdev_call_ret
@end

//----
@interface mcall_ctx_upgrade_get : mdev_call_ctx
@end

@interface mcall_ret_upgrade_get : mdev_call_ret
@property(strong) NSString   *status;/* free=null, download, erase, write */
@property(assign) long        progress; /* 0-100 */
@property(strong) NSString   *ver_current;
@property(strong) NSString   *ver_valid;
@property(strong) NSString   *ver_base;
@property(strong) NSString   *change_history;
@property(strong) NSString   *hw_ext;
@property(strong) NSString   *img_ext;
@property(strong) NSString   *prj_ext;

@end

//----
@interface mcall_ctx_restore : mdev_call_ctx
@property(assign) BOOL        keep_base_cofig;
@end

@interface mcall_ret_restore : mdev_call_ret
@end

//----
@interface mcall_ctx_reboot : mdev_call_ctx
@end

@interface mcall_ret_reboot : mdev_call_ret
@end

//----
@interface mcall_ctx_audio_set : mdev_call_ctx
@property(assign) int      mic_level;
@property(assign) int      speaker_level;
@end

@interface mcall_ret_audio_set : mdev_call_ret
@end

//----
@interface mcall_ctx_audio_get : mdev_call_ctx
@end

@interface mcall_ret_audio_get : mdev_call_ret
@property(assign) int      mic_level;
@property(assign) int      speaker_level;
@end

//----
@interface mcall_ctx_video_set : mdev_call_ctx
@end

@interface mcall_ret_video_set : mdev_call_ret
@end

//----
@interface mcall_ctx_video_get : mdev_call_ctx
@end

@interface mcall_ret_video_get : mdev_call_ret
@end

//----
@interface wifi_obj : NSObject
@property(strong) NSString   *ssid;
@property(assign) int        quality;
@property(assign) int        signal_level;
@end

@interface ip_obj : NSObject
@property(assign) BOOL     dhcp;
@property(assign) BOOL     enable;
@property(strong) NSString *ip;
@property(strong) NSString *gateway;
@property(strong) NSString *mask;
@property(strong) NSString *status;
@end

@interface net_info_obj : NSObject   /* when mcall_ctx_net_set only need set mode !!!*/
@property(strong) NSString *name;    // Network interface name, for example eth0
@property(strong) NSString *mode;    // ether:ether, wifi:wificlient,adhoc
@property(strong) NSString *type;    //ether,wifi,gprs,wcdma,lte, READONLY
@property(strong) NSString *mac;     // Network interface MAC address
@property(strong) NSString *status;  // ok;err;
@end

@interface dhcp_srv_obj : NSObject /* readonly ,  when mcall_ctx_net_set should be set nil !!!*/
@property(assign) BOOL      enable;
@property(strong) NSString  *gateway;
@property(strong) NSString  *start_ip;
@property(strong) NSString  *end_ip;
@end

@interface net_obj : NSObject
@property(assign) BOOL         enable;
@property(strong) NSString     *token;    //List of network interfaces
@property(strong) net_info_obj *info;
@property(strong) ip_obj       *ip;

/*------ only wifi ------ */
@property(strong) NSString        *use_wifi_ssid;
@property(strong) NSString        *use_wifi_passwd;
@property(strong) NSString        *use_wifi_status;//readonly
@property(assign) BOOL            use_wifi_enable; //readonly
@property(strong) NSMutableArray  *wifi_list;      //wifi_obj, readonly
@property(strong) dhcp_srv_obj    *dhcp_srv;
@end



@interface dns_obj : NSObject
@property(assign) BOOL       enable;
@property(assign) BOOL       dhcp;
@property(strong) NSString   *dns;
@property(strong) NSString   *secondary_dns;
@property(strong) NSString   *status;          // ok;err;readonly
@end

@interface mcall_ctx_net_get : mdev_call_ctx
@property(assign) BOOL       force_scan; /*yes:refresh wifi list but slow */
@end

@interface mcall_ret_net_get : mdev_call_ret
@property(strong) NSArray    *networks; /*  0:ethernet 1:wifi   type:net_obj*/
@property(strong) dns_obj    *dns;
@end

//----
@interface mcall_ctx_net_set : mdev_call_ctx
@property(strong) NSArray    *networks; /*  0:ethernet 1:wifi */
@property(strong) dns_obj    *dns;
@end

@interface mcall_ret_net_set : mdev_call_ret
@end


@interface mcall_ctx_alarm_mask_get : mdev_call_ctx

@end

@interface mcall_ctx_alarm_mask_set : mdev_call_ctx
@property (assign, nonatomic) long enable;
@property (assign, nonatomic) long matrix_width;
@property (assign, nonatomic) long matrix_height;
@property (strong, nonatomic) NSMutableDictionary *masks; /* key:index -> type:int, value:bitmaps -> type:NSArray */

@end

@interface mcall_ret_alarm_mask_get : mdev_call_ret
@property (assign, nonatomic) long enable;
@property (assign, nonatomic) long matrix_width;
@property (assign, nonatomic) long matrix_height;
@property (strong, nonatomic) NSMutableDictionary *masks; /* key:index -> type:int, value:bitmaps -> type:NSArray */
@end

@interface mcall_ret_alarm_mask_set : mdev_call_ret

@end

@interface mcall_ctx_notification_get : mdev_call_ctx

@end

@interface mcall_ret_notification_get : mdev_call_ret
@property (assign, nonatomic) BOOL record;
@property (assign, nonatomic) BOOL alert;
@property (assign, nonatomic) BOOL snapshot;
@end

@interface mcall_ctx_notification_set : mdev_call_ctx
@property (assign, nonatomic) BOOL record;
@property (assign, nonatomic) BOOL alert;
@property (assign, nonatomic) BOOL snapshot;
@end

@interface mcall_ret_notification_set : mdev_call_ret

@end

@interface mcall_ctx_cursise_get : mdev_call_ctx

@end

@interface curise_point : NSObject
@property (assign, nonatomic) long enable;
@property (assign, nonatomic) long index;
@property (assign, nonatomic) long x;
@property (assign, nonatomic) long y;

@end

@interface mcall_ret_curise_get : mdev_call_ret
@property (assign, nonatomic) BOOL enable;
@property (strong, nonatomic) NSArray *curise_points;   /*type->curise_point*/
@end


@interface mcall_ctx_cursise_set : mdev_call_ctx
@property (strong, nonatomic) NSString *type;
@property (assign, nonatomic) int index;

@end

@interface mcall_ret_curise_set : mdev_call_ret

@end

@interface mcall_ctx_play_segs_get : mdev_call_ctx
@property (strong, nonatomic) NSString *dev_sn;
@property (assign, nonatomic) long start_time;
@property (assign, nonatomic) long end_time;

@end

@interface mcall_ret_play_segs_get : mdev_call_ret
@property (strong, nonatomic) NSMutableArray *segs_array;

@end


@interface seg_obj : NSObject
@property (assign, nonatomic) long cluster_id;
@property (assign, nonatomic) long seg_id;
@property (assign, nonatomic) long long start_time;
@property (assign, nonatomic) long long end_time;
@property (assign, nonatomic) long flag;

@end

@interface mcall_ctx_ipcs_get : mdev_call_ctx

@end

@interface mcall_ret_ipcs_get : mdev_call_ret
@property (strong, nonatomic) NSMutableArray *ipc_array;

@end

@interface ipc_obj : NSObject
@property (strong, nonatomic) NSString *sn;
@property (strong, nonatomic) NSString *nick;
@property (assign, nonatomic) long online;//info="1:online"

@end

@interface mcall_ctx_exsw_get : mdev_call_ctx

@end

@interface mcall_ret_exsw_get : mdev_call_ret
@property (assign, nonatomic) long enable;
@end

@interface mcall_ctx_exsw_set : mdev_call_ctx
@property (assign, nonatomic) long enable;
@end

@interface mcall_ret_exsw_set : mdev_call_ret

@end

@interface box_conf : NSObject
@property (assign, nonatomic) long enable;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

@end

@interface mcall_ctx_box_conf_get : mdev_call_ctx

@end

@interface mcall_ret_box_conf_get : mdev_call_ret
@property (strong, nonatomic) box_conf *box_conf;
@property (assign, nonatomic) long     connect;
@end

@interface mcall_ctx_box_login : mdev_call_ctx
@property (assign, nonatomic) long     enable;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
//@property (assign, nonatomic) long     no_ack;
//@property (assign, nonatomic) long     record;

@end

@interface mcall_ret_box_login : mdev_call_ret

@end

@interface mcall_ctx_box_get : mdev_call_ctx
@property (strong, nonatomic) NSString *dev_sn;
@property (assign, nonatomic) long flag;
@property (assign, nonatomic) long long start_time;
@property (assign, nonatomic) long long end_time;

@end

@interface date_info_obj : NSObject
@property (assign, nonatomic) long date;
@property (assign, nonatomic) long info;
@property (assign, nonatomic) long flag;

@end

@interface seg_sdc_obj : NSObject
@property (assign, nonatomic) long record_num;
@property (strong, nonatomic) NSString *cid;
@property (strong, nonatomic) NSString *sid;
@property (strong, nonatomic) NSString *stm;
@property (strong, nonatomic) NSString *etm;
@property (strong, nonatomic) NSString *flag;

@end

@interface mcall_ret_box_get : mdev_call_ret
@property (copy, nonatomic) NSMutableArray *date_info_array;
@property (copy, nonatomic) NSMutableArray *ipc_array;
@property (copy, nonatomic) NSMutableArray *seg_array;
@property (copy, nonatomic) NSMutableArray *seg_sdc_array;

@end

@interface mcall_ctx_box_set : mdev_call_ctx
@property (strong, nonatomic)  NSString *dev_sn;
@property (strong, nonatomic)  NSString *cmd;
@property (assign, nonatomic) long long start_time;
@property (assign, nonatomic) long long end_time;

@end

@interface mcall_ret_box_set : mdev_call_ret

@end

//---------------------------------------------
@interface mipc_data_object : NSObject


@end

//---------------------------------------------
@interface mcall_ctx_alert_task_get : mdev_call_ctx
@end

@interface mcall_ret_alert_task_get : mdev_call_ret
@property(assign) BOOL           enableAlert;
@property(assign) BOOL           enable;
@property(assign) BOOL           full_time; /* 7x24 */
@property(strong) NSMutableArray *times;    /* type:mdev_time */
@property(assign) BOOL           sd_ready;
@end

//----
@interface mcall_ctx_alert_task_set : mdev_call_ctx
@property(assign) BOOL           enableAlert;
@property(assign) BOOL     enable;
@property(assign) BOOL     full_time; /* 7x24 */
@property(strong) NSMutableArray *times;
@end

@interface mcall_ret_alert_task_set : mdev_call_ret
@end

//------------------------
@interface mcall_ctx_cap_get : mdev_call_ctx
@property(strong, nonatomic) NSString *filter;
@end

@interface mcall_ret_cap_get : mdev_call_ret
@property (assign, nonatomic) long wfc;
@property (assign, nonatomic) long snc;
@property (assign, nonatomic) long qrc;
@property (strong, nonatomic) NSString *sncf;
@property (assign, nonatomic) long wfcnr;
@end
//----------------------------

@interface mcall_ctx_uart_set: mdev_call_ctx
@property(strong, nonatomic) NSString *mode;
@property(assign, nonatomic) NSString *windSpeed;
@property(assign, nonatomic) NSString *code;
@property(assign, nonatomic) NSString *value;
@property(assign, nonatomic) NSString *filter;
@end

@interface mcall_ret_uart_set : mdev_call_ret
@property(strong, nonatomic) NSString *mode;
@property(assign, nonatomic) float windSpeedValue;

@end
@interface mcall_ctx_email_set : mdev_call_ctx
@property(strong, nonatomic) NSString *user;
@property(strong, nonatomic) NSString *lang; //language
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *mobile;
@property(assign) unsigned char *encrypt_pwd;

@end

@interface mcall_ret_email_set : mdev_call_ret
@property(strong, nonatomic) NSString *p;
@end

@interface mcall_ctx_email_get : mdev_call_ctx
@property(strong, nonatomic) NSString *user;
@end

@interface mcall_ret_email_get : mdev_call_ret
@property(strong, nonatomic) NSString *user;
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *mobile;
@property(assign, nonatomic) long     user_type; //user_type. 0: normal; 1:email; 2:mobile"
@property(assign, nonatomic) long     active_user;
@property(assign, nonatomic) long     active_email;
@property(assign, nonatomic) long     active_mobile;

@end

@interface mcall_ctx_recovery_password_set : mdev_call_ctx
@property(strong, nonatomic) NSString *user;
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *mobile;
@property(strong, nonatomic) NSString *lang; //language
@end

@interface mcall_ret_recovery_password_get : mdev_call_ret
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *mobile;
@end

@interface mcall_ctx_log_reg: mdev_call_ctx
@property(strong, nonatomic) NSString *mode;
//@property(strong, nonatomic) NSString *os;
//@property(strong, nonatomic) NSString *app_ver;
@property(strong, nonatomic) NSString *exception_name;
@property(strong, nonatomic) NSString *exception_reason;
@property(strong, nonatomic) NSString *call_stack;
@property(strong, nonatomic) NSString *log_type;
@end

@interface mcall_ret_log_reg : mdev_call_ret
@end

@interface mcall_ctx_recovery_password : mdev_call_ctx
@property(strong, nonatomic) NSString *user;
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *mobile;
@property(strong, nonatomic) NSString *lang; //language
@end

@interface mcall_ret_recovery_password : mdev_call_ret
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *mobile;
@end

@interface mcall_ctx_get_desc : mdev_call_ctx
@property(strong, nonatomic) NSString *ver_from;
@property(strong, nonatomic) NSString *ver_to;
@property(strong, nonatomic) NSString *lang;
@end

@interface mcall_ret_get_desc : mdev_call_ret
@property(strong, nonatomic) NSString *desc;
@end

@interface post_item : NSObject
@property(strong, nonatomic) NSString *key;
@property(strong, nonatomic) NSString *url;
@property(strong, nonatomic) NSString *action;
@property(assign, nonatomic) long     time;
@property(strong, nonatomic) NSString *num;
@end

@interface mcall_ctx_post_get : mdev_call_ctx
@property(assign, nonatomic) long start;
@property(assign, nonatomic) long counts;
@property(strong, nonatomic) NSString *user;
@end

@interface mcall_ret_post_get : mdev_call_ret
@property(assign, nonatomic) long start;
@property(assign, nonatomic) long total;
@property(strong, nonatomic) NSMutableArray *item;

@end

//-----------ccm_zone
@interface address_obj : NSObject

@end

@interface zone_obj : NSObject
@property(strong, nonatomic) NSString *utc;
@property(strong, nonatomic) NSString *city;
@property(strong, nonatomic) NSString *file;

- (zone_obj*)initWithJson:(struct json_object*)obj;
@end

@interface mcall_ctx_timezone_get : mdev_call_ctx

@end

@interface mcall_ret_timezone_get : mdev_call_ret
@property(strong, nonatomic) NSMutableArray *address;

@end

//----------------------Accessory----------------------
@interface mcall_ctx_exdev_add : mdev_call_ctx

@property (nonatomic,copy) NSString *exdev_id;
@property (nonatomic,assign) long model;
//@property (nonatomic,assign) long interval;
@property (nonatomic,assign) long addTimeout;
@property (assign,nonatomic) long lightTime;
@property (assign,nonatomic) long darkTime;

@end

@interface mcall_ret_exdev_add : mdev_call_ret

@end

@interface mcall_ctx_exdev_del : mdev_call_ctx
@property (nonatomic,copy) NSString *exdev_id;

@end

@interface mcall_ret_exdev_del : mdev_call_ret

@end

@interface mcall_ctx_exdev_set : mdev_call_ctx
@property (nonatomic,copy) NSString *exdev_id;
@property (nonatomic,copy) NSString *nick;
@property (nonatomic,assign) long rtime;
@property (strong, nonatomic) NSMutableArray *exdevs;

@end

@interface mcall_ret_exdev_set : mdev_call_ret


@end


@interface mSchedule_obj : NSObject
@property (assign, nonatomic) mdev_time_type time;
@property (assign, nonatomic) NSMutableArray *degreeArray;
@end

@interface mcall_ctx_schedule_get : mdev_call_ctx

@end

@interface mcall_ret_schedule_get : mdev_call_ret
//@property (assign, nonatomic) BOOL enable;
@property (assign, nonatomic) long degree;          //degree of schedule for time, default 1h
//@property (assign, nonatomic) long bit;             //the bits of one sample, none quit active away
@property (strong, nonatomic) NSMutableArray *scheduleArray;//default Sunday
//@property (assign,nonatomic) unsigned char *sche;
@property (nonatomic,strong) NSMutableArray *array;
@end

@interface mcall_ctx_schedule_set : mdev_call_ctx
//@property (assign, nonatomic) BOOL enable;
@property (assign, nonatomic) long degree;          //degree of schedule for time, default 1h
//@property (assign, nonatomic) long bit;             //the bits of one sample, none quit active away
@property (strong, nonatomic) NSMutableArray *scheduleArray;//default Sunday
//@property (assign,nonatomic) unsigned char *sche;
@property (assign,nonatomic) NSArray *array;
@end

@interface mcall_ret_schedule_set : mdev_call_ret

@end


@interface mScene_obj : NSObject
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) long flag;            //ipc plan record
@property (strong, nonatomic) NSMutableArray *exDevs;//mExDev_obj
@end

@interface mcall_ctx_scene_get : mdev_call_ctx

@end

@interface mcall_ret_scene_get : mdev_call_ret
@property (strong, nonatomic) NSString *select;
@property (strong, nonatomic) NSMutableArray *sceneArray;//mScene_obj
@property (strong, nonatomic) NSString *now;
@end

@interface mcall_ctx_scene_set : mdev_call_ctx
@property (strong, nonatomic) NSString *select;
@property (assign, nonatomic) long all;
@property (strong, nonatomic) NSMutableArray *sceneArray;//mScene_obj
@property (assign, nonatomic) BOOL isNeed;
@end

@interface mcall_ret_scene_set : mdev_call_ret

@end


@interface mcall_ctx_exdev_discover : mdev_call_ctx
@property (assign, nonatomic) long  flag;//1:start discover,2:end discover
@property (assign,nonatomic) long SearchTimeout;
//@property (assign,nonatomic) long interval;
@property (assign,nonatomic) long lightTime;
@property (assign,nonatomic) long darkTime;
@end

@interface mcall_ret_exdev_discover : mdev_call_ret

@end


@interface mExDev_obj : NSObject
@property (strong, nonatomic) NSString *exdev_id;
@property (strong, nonatomic) NSString *nick;       //exdev nick
@property (assign, nonatomic) long      model;      //device model. 1:ASK,2:FSK
@property (assign, nonatomic) long      type;        //exdev detail type
@property (assign, nonatomic) long      stat;     //exdev status 1 means added; 2 means uadded; 3 means pass invailed
@property (assign, nonatomic) long     quietFlag;
@property (assign, nonatomic) long     outFlag;
@property (assign, nonatomic) long     activeFlag;  //exdev events, record photo or IO
@property (assign, nonatomic) long     flag;
@property (assign, nonatomic) long     rtime;
@property (assign, nonatomic) long      key;
@end

@interface sceneExdev_obj : NSObject
@property (nonatomic,copy) NSString *exdev_id;
@property (nonatomic,assign) long flag;
@property (nonatomic,assign) long exdev_type;
@property (nonatomic,copy) NSString *nick;
@end

@interface mcall_ctx_exdev_get : mdev_call_ctx
@property (assign, nonatomic) long     flag;        //1:get all device have been added,2:get all device have not bean adder,3:get single
@property (strong, nonatomic) NSString *exdev_id;   //only for get single
@property (assign, nonatomic) long     start;
@property (assign, nonatomic) long     counts;
@end

@interface mcall_ret_exdev_get : mdev_call_ret
@property (assign, nonatomic) long           total; //total data
@property (assign, nonatomic) long           start; //start from
@property (strong, nonatomic) NSMutableArray *exDevs;
@end

@interface mcall_ctx_version_get : mdev_call_ctx
@property (strong, nonatomic) NSString *lang;
@property (strong, nonatomic) NSString *appid;
@property (strong, nonatomic) NSString *appVersion;
@end

@interface mcall_ret_version_get : mdev_call_ret
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *changes;
@property (strong, nonatomic) NSDictionary *info;
@end

@interface mcall_ctx_change_interface : mdev_call_ctx
@property (strong,nonatomic) NSString *action;
@property (assign,nonatomic) NSString *param;
@end

@interface mcall_ret_change_interface : mdev_call_ret

@end

