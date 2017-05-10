/*!
\file       mec.h
\brief      media engine core unit
            for all platform
            for windows
            for IE/FIREFOX/OPERA/CHROME/SAFRI web browser
            for Android
            for IOS
----history----
\author     chengzhiyong
\date       2011-11-29
\version    0.01
\desc       create

$Author: chengzhiyong $
*/
#if !defined(__media_engin_core_h__)
#define __media_engin_core_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct mec_obj;

#define mec_succeed                             0
#define mec_err_invalid_param                   -1
#define mec_err_unkonwn_chl_id                  -2
#define mec_err_missing_chl_id                  -3
#define mec_err_set_failed                      -4
#define mec_err_update_failed                   -5
#define mec_err_update_set_failed               -6
#define mec_err_unknown_method                  -7
#define mec_err_buffer_overflow                 -8
#define mec_err_chl_create_failed               -9
#define mec_err_unknown_media_type              -10
#define mec_err_not_support_scale_capability    -11
#define mec_err_scale_transform_failed          -12
#define mec_err_write_sample_failed             -13
#define mec_err_invalid_video_in_channel        -14
#define mec_err_invalid_video_format            -13
#define mec_err_invalid_audio_in_channel        -14
#define mec_err_invalid_audio_format            -15
#define mec_err_update_utils_disabled           -16
#define mec_err_malloc_failed                   -17
#define mec_err_scale_pic_failed                -18
#define mec_err_not_suppport_pic_mode           -19
#define mec_err_not_suppport_radians            -20
#define mec_err_get_json_params_failed          -21
#define mec_err_add_data_into_mixer_failed      -22
#define mec_err_play_failed                     -23
#define mec_err_license_invalid                 -24
#define mec_err_query_failed                    -25
#define mec_err_destroy_in_callbacking          -26


#if !defined(__len_str_defined)
#   define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */

#if !defined(__mec_pack_type_defined)
#define __mec_pack_type_defined
#define mec_pack_format_max     64
typedef struct mec_pack_type
{
    long                        changed_seq;        /*!< changed seq no, for changed checking */
    struct len_str              major;
    struct len_str              sub;
    union 
    {
/*        unsigned long           len;              */
        struct
        {
            long                radians;            /*!< for android video radians */

            unsigned long       width;
            unsigned long       height;
            struct
            {
                unsigned long   left;
                unsigned long   top;
                unsigned long   width;
                unsigned long   height;
            }content;                           /*! content size, video size maybe expand to power(2) or better size.
                                                    for opengl-es maybe cause it. */

            unsigned long       planers_counts;     /*!< planers counts */
            struct  
            {
                long            line_bytes;
                long            size;
                long            line_counts;
            }planers[4];

            unsigned long       ext_counts;         /*!< used to save h.264 sps/pps */
            struct  
            {
                unsigned long   len;
                unsigned char   *data;
            }ext[4];
        }video;
        struct  
        {
            unsigned long       channels;
            unsigned long       sample_rates;
            unsigned long       sample_bits;

            unsigned long       ext_counts;         /*!< used to save aac param */
            struct  
            {
                unsigned long   len;
                unsigned char   *data;
            }ext[4];
        }audio;
    }format;
}_mec_pack_type;
#endif  /* !defined(__mec_pack_type_defined) */

/*\brief frame pack, all video and audio data will be in this frame */
#if !defined(__mec_pack_defined)
#define __mec_pack_defined
#define mec_pack_flag_key_sample    0x01
#define mec_pack_flag_prev_lost     0x02
typedef struct mec_pack
{
    long                    chl_id;             /*!< media engine-channel id */

    struct mec_pack_type    *type;              /*!< type info */

    unsigned long           time_stamp;         /*!< time stamp, ms tick */
    unsigned long           sample_id;          /*!< sample id */
#if defined(__MSC_VER)
    unsigned __int64        ab_time;            /*!< absolute time, from 19700101T00:00:00 ms */
#else
    unsigned long long      ab_time;            /*!< absolute time, from 19700101T00:00:00 ms */
#endif

    struct{unsigned long    len; unsigned char *data;} data;/*!< data */

    unsigned char           flag;               /*!< flag, refer mec_pack_flag_xxx */
    unsigned char           tag;                /*!< tag, such as alarm, same field in sample header */
    unsigned char           reserved[2];        /*!< reserved field */
}_mec_pack;
#define mec_pack_format_s   "%p{chl_id[%ld], type[%*.*s/%*.*s], data[%p{%ld}]}"
#define mec_pack_format(_pack)  (_pack), (_pack)?(_pack)->chl_id:0,\
                                0, ((_pack) && (_pack)->type)?(_pack)->type->major.len:0, ((_pack) && (_pack)->type)?(_pack)->type->major.data:NULL,\
                                0, ((_pack) && (_pack)->type)?(_pack)->type->sub.len:0, ((_pack) && (_pack)->type)?(_pack)->type->sub.data:NULL,\
                                (_pack)?(_pack)->data.data:NULL, (_pack)?(_pack)->data.len:0
#endif /* !defined(__mec_pack_defined) */

/*\brief engine event */
#if !defined(__mec_event_defined)
#define __mec_event_defined
#define mec_event_magic     (*(long*)"mevt    ")
typedef struct mec_event
{
    char                    magic[sizeof(long)];/*!< event magic */

    struct len_str          type;               /*!< event type */
    long                    status;             /*!< integer status */
    struct len_str          code;               /*!< code string information */

    struct  
    {
        long                id;                 /*!< media engine-channel id */
        struct len_str      type;               /*!< media engine-channel type */
        struct len_str      url;                /*!< media engine-channel url */
    }chl;                                       /*!< chl */

    struct json_object      *data;              /*!< additional data */
}_mec_event;
#define mec_event_format_s "%p{type[%s], status[%ld], code[%s], chl[{type[%s], id[%ld], url[%s]}}"
#define mec_event_format(_evt) (_evt), (_evt)?(_evt)->type.data:NULL, (_evt)?(_evt)->status:0, (_evt)?(_evt)->code.data:NULL,\
                               (_evt)?(_evt)->chl.type.data:NULL, (_evt)?(_evt)->chl.id:0, (_evt)?(_evt)->chl.url.data:NULL
#endif /* !defined(__mec_event_defined) */

typedef struct mec_pic_range{long left, top, width, height;}_mec_pic_range;


/*!
func    mec_on_event
\brief  on event callback for media engine
\param  mec[in]                 the media engine
\param  evt[in]                 the event object
\param  refer[in]               the media engine refer data set in mec_desc
\return on-event deal with result
        #0                      succeed
        #other                  error code
*/
typedef long (*mec_on_event)(struct mec_obj *mec, struct mec_event *evt, void *refer);

/*!
func    mec_on_pack
\brief  on frame data callback for media engine
\param  mec[in]                 the media engine
\param  pack[in]                the frame pack
\param  refer[in]               the media engine refer data set in mec_desc
\return on-event deal with result
        #0                      succeed
        #other                  error code
*/
typedef long (*mec_on_pack)(struct mec_obj *mec, struct mec_pack *pack, void *refer);

/*\brief media engine description */
typedef struct mec_desc
{
    mec_on_event            on_event;           /*!< on event callback function */
    mec_on_pack             on_pack;            /*!< on frame data callback function */
    void                    *refer;             /*!< refer object */
    struct len_str          params;             /*!< json string */
}_mmedia_engin_core_desc;

/*!
func    mec_create
\brief  create media engine
\param  desc[in]                the media engine
                                the desc.params is same struct with [params] of this function.
                                desc.params is higher priority. key should in functions's [params] 
                                usually
\param  params[in]              the parameters, json string
                                params:{
                                    key: "" (key string like "data:application/octet-stream;base64,xxxx" or "data:application/octet-stream;hex,xxx", refer url param's domain),
                                    charset: ("utf-8"),
                                    url: "" (running mec url),
                                    reference: (reference, like http-reference),
                                    canvas:{
                                        type: "bgr/24" | "bgra/32" | "rgba/32" | "bgr/565" | "none" (default:"bgr/24", "none":don't display),
                                        fps: 1~60 (default:25)},
                                        width: 4~1920 (default:640),
                                        height: 4~1280 (default:640),
                                        aspect_tatio: 0.0~1024.0 (default:0.0),
                                        padding:{
                                            power_2: 0 | 1 (default:0),
                                            align: 0~1024 (default:0, if padding_power_2 ignore this param.),
                                            center: 0 | 1 (default:1, if 0 padding right and bottom.)
                                        }
                                    speaker:{
                                        type: "normal" | "none" (default:"normal", "none":don't output audio),
                                        sample_bits: 16 (default:16),
                                        sample_rate:16000 (default:16000),
                                        channels:1 (default:1),
                                        frame_samples:1024 (default:1024)
                                    },
                                    vhosts:[
                                        {
                                            type:"in"|"out"|"all" (default:"out"),
                                            name:"xxx"(such as "/live","/record")
                                        }
                                    ],
                                    module:{
                                        mutp:{
                                            id: "" (p2p-id, if empty will auto generate one),
                                            proxy:{
                                                local:0 | 1 (default 0, 0:not a proxy sever, 1:proxy server),
                                                ip:xxx.xxx.xxx.xxx (default:0.0.0.0)
                                                port:0~65535 (default:8608, 0:don't active server function)
                                            }},
                                        rtdp:{
                                            id: "" (p2p-id, if empty will auto generate one),
                                            proxy:{
                                                local:0 | 1 (default 0, 0:not a proxy sever, 1:proxy server),
                                                ip:xxx.xxx.xxx.xxx (default:0.0.0.0)
                                                port:0~65535 (default:8606, 0:don't active server function)
                                            }},
                                        rtmp:{net:{port:0~65535 (default:0, 0:don't active server function)}},
                                        rtsp:{net:{port:0~65535 (default:0, 0:don't active server function)}},
                                    }
                                }
\return the media engine
        #NULL                   failed
        #other                  the media engine
*/
struct mec_obj *mec_create(struct mec_desc *desc, struct len_str *params);

/*!
func    mec_destroy
\brief  destroy media engine
\param  mec[in]                 the media engine
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mec_destroy(struct mec_obj *mec);

/*!
func    mec_write
\brief  write frame data into media engine-channel, called when data be captured from outer module
\param  mec[in]                 the media engine
\param  pack[in]                the frame pack data
\return write result
        #0                      succeed
        #other                  error code
*/
long mec_write(struct mec_obj *mec, struct mec_pack *pack);

/*!
func    mec_on_message
\brief  post message into media engine, such as mouse event, and will let video window layout
        such as double click will let full screen
\param  mec[in]                 the media engine
\param  msg[in]                 the message id
\param  wparam[in]              the wparam
\param  lparam[in]              the lparam
\return on message result
        #0                      succeed
        #other                  error code
*/
long mec_on_message(struct mec_obj *mec, unsigned  long msg, long wparam, long lparam);

/*!
func    mec_chl_create
\brief  create media engine-channel
\param  mec[in]                 the media engine
\param  params[in]              the params setting, json string
                                params:{
                                    name:"" (default:null will auto create),
                                    src:[stream,stream],
                                    dst:[stream,stream],
                                    trans:[stream],
                                    pic:{position:"center" | "fit" | "fill" | "stretch" | "none" (default:"fit", "none":don't display)},
                                    keep:0|1 (default:0, 1: will keep when all src or dst connection be destroyed)
                                    speaker:{mute:0 | 1 (default:0)}
                                }
                                stream:(stream description json)
                                {
                                    url:"data://" | "rtmp://xxx" | "rtdp://xxx" | "rtsp://xxx" | "file://xxx" | "cam://001" | "mic://001",
                                    type:"video" | "audio" | "all" | "none" (default:"all"),

                                    ----src.cam-----
                                    cam:{
                                        position:"center" | "fit" | "full" | "stretch" (default:"center"),
                                        width:4~1920 (default:640),
                                        height:4~1280 (default:360),
                                        fps:1~60 (default:10)},
                                    ----src.mp4-----
                                    pause:0|1 (default:0, will not pause, used for FILE play channel)

                                    -----trans,dst(have istream)---------
                                    thread: "none" | "module" | "factory" | "channel" | "istream" (default: "none"),
                                    flow_ctrl: "none" | "jitter" | "delay" | "speed" (default:"none" or "jitter"),
                                    overload_size_max: bytes( default:0. Overload reject size threshold )
                                    overload_size_high:  bytes( default:0. Overload remove size threshold )
                                    overload_size_lower:  bytes( default:0. Overload remove size threshold )
                                    overload_time_max: tick ( default:0. Overload reject time threshold )
                                    overload_time_high: tick ( default:0. Overload rise time threshold )
                                    overload_time_lower: tick ( default:0. Overload remove time threshold )
                                    packet_speed_max: counts(default:0. max packet per second)
                                    disable_priority:  ( default:0. Send all data use same priority )
                                    keeplive_interval: tick ( default:0. Timer len for send keeplive. 0 Indicate no keeplive )
                                    jitter:{
                                        min:0~5000 (default:0),
                                        max:0~5000 (default:0),
                                        init:0~5000 (default:0)},
                                        range:1000~30000 (default:5000)
                                    },
                                    delay:{
                                        buf:{
                                            min:0~10000 (default:3000)
                                        }
                                    }

                                    ----dst.net------
                                    bitrates:{
                                        min:64~2048 (default:64),
                                        max:64~2048 (default:2048),
                                        init:64~2048 (default:300)
                                    },

                                    ----dst.mp4 with m3u8-----
                                    seg:{
                                        duration:0~10000000 (default:300000)
                                    }
                                }
                                for example:
                                {
                                    src:[{url:"data:/"}],
                                    dst:[{url:"rtmp://hehehi.com/live/001"},
                                         {url:"file://c://test.mp4"}]
                                }
\return media engine-channel id
        #>0                     media engine-channel id
        #other                  error code
*/
long mec_chl_create(struct mec_obj *mec, struct len_str *params);

/*!
func    mec_chl_destroy
\brief  destroy media engine-channel
\param  mec[in]                 the media engine
\param  chl_id[in]              the media engine-channel id
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mec_chl_destroy(struct mec_obj *mec, long chl_id);

/*!
func    mec_ctrl
\brief  control media engine-channel, after use call mec_event_destroy to free event
\param  mec[in]                 the media engine
\param  chl_id[in]              the media engine-channel id, if for whole media engine, let it as 0
\param  method[in]              the control method, such as "query", "full_screen", "max"
\param  params[in]              the params, json string
\return event, after use call mec_event_destroy to free
        #NULL                   failed
        #other                  JSON info string
*/
struct mec_event *mec_ctrl(struct mec_obj *mec, long chl_id, struct len_str *method, struct len_str *params);

/*!
func    mec_event_destroy
\brief  destroy event
\param  mec[in]                 the media engine
\param  evt[in]                 the event
\return free result
        #0                      succeed
        #other                  error code
*/
long mec_event_destroy(struct mec_obj *mec, struct mec_event *evt);

/*!
func    mec_event_2_json
\brief  format media engine core event into json string
\param  mec[in]                 the media engine
\param  evt[in]                 the event
\param  buf[in/out]             the buffer
\param  buf_size[in]            the buffer size
\return json string length
        #<0                     error code
        #other                  json string length
*/
long mec_event_2_json(struct mec_obj *mec, struct mec_event *evt, char *buf, unsigned long buf_size);

/* just for test */
long mec_test_entry(long argc, char *argv[]);
    
#if defined(__cplusplus)
}
#endif

#endif /* !defined(__mec_h__) */

