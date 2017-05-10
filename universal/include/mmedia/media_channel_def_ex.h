/*!
\file       media_channel_def_ex.h
\brief      media channel unit, channel like a water pipe, can be link 
            with each other
            don't call any media function in media channel on_destroy event
 ----history----
\author     chengzhiyong
\date       2009-09-19
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: media_channel.h,v 1.20 2009-09-19 01:46:28 chengzhiyong Exp $
*/
#if !defined(__media_channel_def_ex_h__)
#define __media_channel_def_ex_h__

#if defined(__cplusplus)
extern "C" {

#endif/* defined(__cplusplus) */

struct speed_statistic;

typedef long (*media_channel_on_write)(struct media_channel *channel, struct media_istream *istream, struct media_sample *sample, struct media_event *event);

/* 0:valid other:invalid, usage: media_object_check(xxx_channel, channel) */
#define media_object_check(_obj, _obj_type) ((NULL == (_obj)) || (media_##_obj_type##_magic != *(long*)&(_obj)->obj.magic))
/* 0:type matched(maybe not valid), other:invalid pointer, usage: media_object_loose_check(xxx_channel, channel) */
#define media_obj_loose_check(_obj, _obj_type) ((NULL == (_obj)) || ((media_##_obj_type##_magic != *(long*)&(_obj)->obj.magic) && (media_##_obj_type##_magic_free != *(long*)&(_obj)->obj.magic)))

typedef struct media_lock
{
    unsigned long               use;                /*!< used refer counts */
    struct mlock_simple_obj     *obj;               /*!< lock object */
    unsigned long               thread_id;          /*!< current locked thread id */
    unsigned long               locked_counts;      /*!< locked counts */
}_media_lock;

/*! \brief media type */
#define media_type_mask_video   0x00000001
#define media_type_mask_audio   0x00000002
#if !defined(__media_type_defined)
#define __media_type_defined
#define media_type_magic        (*(long*)"type    ")
#define media_type_magic_free   (*(long*)"TYPE    ")
typedef struct media_type
{
    struct media_object obj;
    struct len_str      major;                   /*!< media major type, such as: video/audio/text */
    struct len_str      sub;                     /*!< media sub type, such as: h264, aac, plain, such as row, nal, rtp, payload, utf-8  */
    struct
    {
        unsigned long   size;                    /*!< format buffer size */
        unsigned char   *data;                   /*!< format data buffer */
        unsigned long   valid_len;               /*!< format data valid len */
    }format;
    unsigned long       mask;                    /*!< media type mask, media_type_mask_* */
    unsigned long       id;
}_media_type;
#endif
#define media_type_def_ex(_major_len, _major, _sub_len, _sub, _format_size, _format_data, _format_data_valid_len)\
{\
    {0},\
    {(_major_len), (_major)},\
    {(_sub_len), (_sub)},\
    {(_format_size), (_format_data), (_format_data_valid_len)},\
    0, 0\
}
#define media_type_def(_major_const_str, _sub_const_str, _format_size, _format_data, _format_data_valid_len) \
            media_type_def_ex( sizeof(_major_const_str) - 1, (_major_const_str), sizeof(_sub_const_str) - 1, (_sub_const_str), (_format_size), (_format_data), (_format_data_valid_len))
#define media_type_format_s "%p{%*.*s/%*.*s}"
#define media_type_format(_type) \
                (_type), 0, ((_type) && (_type)->major.data)?(int)(_type)->major.len:0, (_type)?(_type)->major.data:NULL,\
                0, ((_type) && (_type)->sub.data)?(int)(_type)->sub.len:0, (_type)?(_type)->sub.data:NULL

#if defined(__APPLE__)
#   pragma clang diagnostic push
#   pragma clang diagnostic ignored "-Wcomment"
#endif
/* description string format:
protocol(rtmp|rtsp|mms|sip|empty means pack|yp2p)[+ server|- client]:major-type(video|audio)/sub-type(h264|aac|mp3|* means any)
rtmp+:video/h264,audio/*
rtsp-:video/*,audio/*
file:video/*,audio/*
pack:video/yuv420
pack:video/h264
yp2p:video/yuv420
yp2p:video/h264
*/
#if defined(__APPLE__)
#   pragma clang diagnostic pop
#endif
/*! \brief median channel capability */
#define media_capability_magic      (*(long*)"mcap    ")
#define media_capability_magic_free (*(long*)"MCAP    ")
typedef struct media_capability
{
    struct media_object         obj;            /*!< media object */
    struct len_str              protocol;       /*!< protocol, such as rtmp/rtsp/p2p/mms/pack/file. */
    long                        direction;      /*!< must (0 == (direction + peer-direction)), 1 server, -1 client, 0:both */    
    struct  
    {
        unsigned long           counts;         /*!< in types counts */
        struct media_type       **list;          /*!< types[] */
    }types;                                     /*!< media types */
}_media_capability;


/*!!!!!! if run on big-endia chip, this struct need redefined, now, all of them are running on little-endian chip,  
  this refer media_sample and rtdp_sample_header and mutp_sample_header  */
#define media_sample_net_header_flag_key_sample_get(_header)      (((_header)->flag.base >> 0) & 0x01)
#define media_sample_net_header_flag_prev_lost_get(_header)       (((_header)->flag.base >> 1) & 0x01)
#define media_sample_net_header_flag_little_endian_get(_header)   (((_header)->flag.base >> 2) & 0x01)
#define media_sample_net_header_flag_ext_header_size_get(_header) (((_header)->flag.base & 0xf8) >> 1)
#define media_sample_net_header_flag_set(_header, _key_sample, _prev_lost, _little_endian, _ext_header_size) \
           do{ \
               (_header)->flag.base = (((_key_sample)  & 0x01) << 0) | \
                                      (((_prev_lost)   & 0x01) << 1) | \
                                      (((_little_endian)  & 0x01) << 2) | \
                                      ((((_ext_header_size) + 3) & 0x1c) << 1); /* LEN = value * 4 */\
           }while(0)

typedef struct media_sample_net_header
{
    struct
    {
        unsigned char           base;               /* base value, include following little-endian (if 0.. endif) fields */
#if 0
        unsigned char           key_sample:1;       /*!< is key sample, such I frame */
        unsigned char           prev_lost:1;        /*!< prev sample lost flag */
        unsigned char           big_endian:1;       /*!< is big endian, a mistake in old code, should be little-endian */
        unsigned char           ext_header_size:5;  /*!< header size */
#endif
        unsigned char           tag;                /*!< tag, such as alarm data, add on version 2, defined by application layer */
        unsigned char           reserved[2];        /*!< reserved */
    }flag;
    unsigned char               time_stamp[4];      /*!< time stamp */
    unsigned char               sample_id[4];       /*!< time stamp */
    struct
    {
        unsigned char           ab_time[6];         /*!< absolute time, from 19700101T00:00:00 ms */
        unsigned char           reserved[2];        /*!< reserved */
    }ext;
}_media_sample_net_header;
#define media_sample_net_header_size(_ext_size) (sizeof(struct media_sample_net_header) - sizeof(((struct media_sample_net_header*)0)->ext) + (_ext_size))


/*! \brief media data sample, should be a sample
    should call sample-destroy when used finished */
#define media_sample_magic      (*(long*)"msmp    ")
#define media_sample_magic_free (*(long*)"MSMP    ")
typedef struct media_sample               
{
    struct media_object         obj;                /*!< media object */
    struct media_type           *type;
    struct  
    {
        unsigned long           counts;
        struct media_sample_ref *list;
    }sample_refs;
    unsigned long               write_tick;         /*!< sample write tick */
    unsigned long               size;               /*!< pack size */
    /*----------------transfer data------------------------------*/
    /*!!!!!! if run on big-endia chip, this struct need redefined, now, all of them are running on little-endian chip,  
       this refer media_sample and media_sample_net_header */
    struct
    {
        unsigned char           key_sample:1;       /*!< is key sample, such I frame */
        unsigned char           prev_lost:1;        /*!< prev sample lost flag */
        unsigned char           little_endian:1;    /*!< is little endian */
        unsigned char           ext_header_size_4:5;/*!< header size, size=this*4 */
        unsigned char           tag;                /*!< tag, such as alarm data, add on version 2, defined by application layer */
        unsigned char           reserved[2];        /*!< reserved */
    }flag;
    unsigned long               time_stamp;         /*!< time stamp */
    unsigned long               sample_id;          /*!< sample id */
    struct
    {
#if defined(_MSC_VER)
        unsigned __int64        ab_time;            /*!< absolute time, from 19700101T00:00:00 ms */
#else
        unsigned long long      ab_time;            /*!< absolute time, from 19700101T00:00:00 ms */
#endif
    }ext;
    unsigned char               data[4];            /*!< the pack data, size usually not 4. */
}_media_sample;
#define media_sample_format_s           "%p{[%4.4s]%s/%s, size[%ld], time_stamp[%ld]}"
#define media_sample_format(_sample)    (_sample), (_sample)?&(_sample)->obj.magic:0,\
                                        (media_obj_loose_check(_sample, sample)||(NULL == (_sample)->type))?NULL:(_sample)->type->major.data, \
                                        (media_obj_loose_check(_sample, sample)||(NULL == (_sample)->type))?NULL:(_sample)->type->sub.data, \
                                        media_obj_loose_check(_sample, sample)?0:(_sample)->size, \
                                        media_obj_loose_check(_sample, sample)?0:(_sample)->time_stamp

#define media_sample_padding_size       8 /* !!!! at leaset 3bytes protect for crash in ffmpeg always 32 bits cache read h.264 decode faraday stream */
#define media_sample_get_type(_sample)  (_sample)->type
#define media_sample_get_total_size(_data_size) (sizeof(struct media_sample) - sizeof(((struct media_sample*)0)->data) + (_data_size) + media_sample_padding_size)

#if 0 /* deprecated, switch to media_sample_net_header */
#define media_sample_transf_data_size(_sample) (media_sample_get_size((_sample)->size) - ((unsigned long)&((struct media_sample*)0)->flag))
#define media_sample_transf_data(_sample) ((unsigned char*)&(_sample)->flag)
#define media_sample_from_transf_data(_transf_data) ((struct media_sample*)(((unsigned char*)(_transf_data)) - ((unsigned long)&((struct media_sample*)0)->flag)))
#define media_sample_data_size_from_transf_data_size(_transf_data_size) ((_transf_data_size) + ((unsigned long)&((struct media_sample*)0)->flag) - sizeof(struct media_sample) + sizeof(((struct media_sample*)0)->data))
#endif

typedef struct media_sample_jitter
{
    unsigned long               active;
    long                        min;                    /* ms */
    long                        max;                    /* ms */
    long                        value;                  /* ms */
    long                        range;                  /* ms */
    unsigned long               last_trim_tick;
    struct speed_statistic      *statistic;
}_media_sample_jitter;

typedef struct media_sample_dlybuf
{
    struct
    {
        long                    min;
        long                    max;
    }discard, buf;                                      /*!< discard/buf tick */
    long                        pause_min_samples;      /*!< pause min samples */
    unsigned long               play_tick;             /*!< start play tick in current system */
    unsigned long               play_sample_time_stamp;/*!< sample time stamp start */
    long                        is_buffering;           /*!< is buffering */
    long                        is_paused;              /*!< is paused */
}_media_sample_dlybuf;

typedef struct media_sample_queue
{
    union
    {
        struct media_module     *module;
        struct media_factory    *factory;
        struct media_channel    *channel;
        struct media_istream    *istream;
        struct media_object     *obj;
    }owner;
    unsigned long               owner_valid_magic;
    
    struct media_sample_jitter  *jitter;
    struct media_sample_dlybuf  *delay_buf;

    struct mevent_obj           *event;
    unsigned long               counts;
    struct media_sample_ref     *list; 
    unsigned long               thread_id;
    unsigned long               sample_total_size;
}_media_sample_queue;

/*! \brief media sample ref */
typedef struct media_sample_ref
{
    struct  
    {
        struct media_sample_ref     *prev;
        struct media_sample_ref     *next;
        struct media_sample         *owner;
    }in_sample;
    struct  
    {
        struct media_sample_ref     *prev;
        struct media_sample_ref     *next;
        struct media_istream        *owner;
    }in_istream;
    struct  
    {
        struct media_sample_ref     *prev;
        struct media_sample_ref     *next;
        struct media_sample_queue   *owner;
    }in_queue;
}_media_sample_ref;

/*! \brief media in-stream */
#define media_istream_magic         (*(long*)"mist    ")
#define media_istream_magic_free    (*(long*)"MIST    ")
typedef struct media_istream
{
    struct media_object         obj; /*!< media object */

    struct                      /* place here for struct align better */
    {
#if defined(_MSC_VER)
        unsigned __int64
#else
        unsigned long long
#endif
                                sample_total_counts,/*!< sample total counts */
                                sample_total_size;  /*!< sample total size */
    }statistic;

    struct  /*!< head link info in channel */
    {
        struct media_channel    *owner;             /*!< owner media channel */
        struct media_istream    *prev;              /*!< prev stream in channel, cycle list */
        struct media_istream    *next;              /*!< next stream in channel, cycle list */
    }in_channel;

    struct
    {
        struct media_ostream    *owner;             /*!< owner output pin */
        struct media_istream    *prev;              /*!< prev brother istream in ostream(source), cycle list */
        struct media_istream    *next;              /*!< next brother istream in ostream(source), cycle list */
        unsigned long           wrting_index;       /*!< index in ostream, value == (real-index + 1), or means start from 1 */
    }in_ostream;

    struct media_type           *type;              /*!< stream media type */

    struct  
    {
        unsigned long           counts;
        struct media_sample_ref *list;
    }sample_refs;

    unsigned long               start_sample_tick;
    unsigned long               last_sample_tick;
    unsigned long               last_sample_tick_played;
    unsigned long               start_tick;

    struct media_sample_queue   sample_queue;       /*!< sample queue */
    struct media_sample_queue   *asyn_queue;        /*!< write dst sample queue, for asyn write. */
}_media_istream;
#define media_istream_get_channel(_istream) (_istream)->in_channel.owner
#define media_istream_get_type(_istream)    (_istream)->type
#define media_istream_get_data(_istream) ((struct media_object*)(_istream))->data
#define media_istream_set_data(_istream, _refer_data) (((struct media_object*)(_istream))->data = (_refer_data))
#define media_istream_get_ctl_data(_istream) ((struct media_object*)(_istream))->ctl_data
#define media_istream_set_ctl_data(_istream, _refer_ctl_data) (((struct media_object*)(_istream))->ctl_data = (_refer_ctl_data))
#define media_istream_format_s    "%p{[%4.4s]%s[%s].%s/%s}]"
#define media_istream_format(_istream)  \
                (_istream), (_istream)?(char*)&((struct media_object*)(_istream))->magic:0,\
                (0 == media_obj_loose_check(_istream, istream))?(_istream)->in_channel.owner->in_class.owner->desc.name.data:NULL,\
                ((0 == media_obj_loose_check(_istream, istream)) && (_istream)->in_channel.owner->in_name.owner)?\
                    (_istream)->in_channel.owner->in_name.owner->text.data:NULL,\
                (0 == media_obj_loose_check(_istream, istream))?(_istream)->type->major.data:NULL,\
                (0 == media_obj_loose_check(_istream, istream))?(_istream)->type->sub.data:NULL

/*! \brief media out pin */
#define media_ostream_magic         (*(long*)"most    ")
#define media_ostream_magic_free    (*(long*)"MOST     ")
typedef struct media_ostream             
{
    struct media_object         obj; /*!< media object */

    struct                      /* place here for struct align better */
    {
#if defined(_MSC_VER)
        unsigned __int64
#else
        unsigned long long
#endif
                                sample_total_counts,/*!< sample total counts */
                                sample_total_size;  /*!< sample total size */
    }statistic;
    

    struct  /*!< head link info */
    {
        struct media_channel    *owner;             /*!< owner media channel */
        struct media_ostream    *prev;              /*!< prev stream in channel, cycle list */
        struct media_ostream    *next;              /*!< next stream in channel, cycle list */
    }in_channel;

    struct  
    {
        struct media_name       *owner;              /*!< in name */
        struct media_ostream    *prev;              /*!< prev stream in same name, cycle list */
        struct media_ostream    *next;              /*!< next stream in same name, cycle list */        
    }in_name;
    
    struct media_type           *type;              /*!< stream media type */
    unsigned long               sample_id;          /*!< stream id */

    struct  
    {
        /* for sample write */
        unsigned long           writing_changed_times;    /*!< writing changed times */
        unsigned long           writing_counts;     /*!< writing list counts */
        struct media_istream    **writing;          /*!< list writing */

        unsigned long           counts;             /*!< sample counts */
        struct media_istream    *list;              /*!< watch in streams */
    }watch_istreams;
}_media_ostream;
#define media_ostream_get_channel(_ostream) (_ostream)->in_channel.owner
#define media_ostream_get_type(_ostream)   (_ostream)->type
#define media_ostream_get_data(_ostream) ((struct media_object*)(_ostream))->data
#define media_ostream_set_data(_ostream, _refer_data) (((struct media_object*)(_ostream))->data = (_refer_data))
#define media_ostream_get_ctl_data(_ostream) ((struct media_object*)(_ostream))->ctl_data
#define media_ostream_set_ctl_data(_ostream, _refer_ctl_data) (((struct media_object*)(_ostream))->ctl_data = (_refer_ctl_data))
#define media_ostream_format_s    "%p{[%4.4s]%s[%s].%s/%s}"
#define media_ostream_format(_ostream)  \
                (_ostream), (_ostream)?(char*)&((struct media_object*)(_ostream))->magic:0,\
                (0 == media_obj_loose_check(_ostream, ostream))?(_ostream)->in_channel.owner->in_class.owner->desc.name.data:NULL,\
                ((0 == media_obj_loose_check(_ostream, ostream)) && (_ostream)->in_channel.owner->in_name.owner)?\
                    (_ostream)->in_channel.owner->in_name.owner->text.data:NULL,\
                (0 == media_obj_loose_check(_ostream, ostream))?(_ostream)->type->major.data:NULL,\
                (0 == media_obj_loose_check(_ostream, ostream))?(_ostream)->type->sub.data:NULL

/*! \brief media name */
#define media_name_magic        (*(long*)"mnam    ")
#define media_name_magic_free   (*(long*)"MNAM    ")
typedef struct media_name
{
    struct media_object         obj;                /*!< media object */

    struct  
    {
        struct media_name       *prev;              /*!< prev name in module */
        struct media_name       *next;              /*!< next name in module */
        struct media_module     *owner;             /*!< owner */
    }in_mod;
    struct media_name           *hash_next;         /*!< hash next */
    struct len_str              text;               /*!< channel name */
    struct  
    {
        unsigned long           counts;             /*!< channel counts */
        struct media_channel    *list;              /*!< channel list */
    }channels;
    struct
    {
        unsigned long           counts;             /*!< out stream counts */
        struct media_ostream    *list;              /*!< out stream list */
    }out_streams;
}_media_name;

typedef enum media_flow_ctrl_type
{
    emfct_none,                                     /*!< none, for encode/decode/process transform */
    emfct_jitter,                                   /*!< jitter live, for live.recver.player */
    emfct_delay,                                    /*!< delay buf, for playback.recver.player */
    emfct_speed,                                    /*!< by speed, for sender.transport */
}_media_flow_ctrl_type;

/*! \brief media channel object */
#define media_channel_magic         (*(long*)"mchl    ")
#define media_channel_magic_free    (*(long*)"MCHL    ")
typedef struct media_channel
{
    struct media_object             obj;                /*!< media object */
    struct media_lock               lock;               /*!< lock object */
    struct  
    {
        struct media_name           *owner;             /*!< the owner, channel name, can be NULL */
        struct media_channel        *prev;              /*!< prev channel, cycle list */
        struct media_channel        *next;              /*!< next channel, cycle list */
    }in_name;                                           /*!< remained to median-channel-class */

    struct  
    {
        struct media_channel_class  *owner;             /*!< the owner, channel class */
        struct media_channel        *prev;              /*!< prev channel, cycle list */
        struct media_channel        *next;              /*!< next channel, cycle list */
    }in_class;

    struct
    {
        struct media_channel        *prev;             /*!< prev channel, cycle list */
        struct media_channel        *next;             /*!< next channel, cycle list */
    }in_mod_idle_channels;

    struct len_str                  src;                /*!< media channel src */

    struct  
    {
        unsigned long               counts;             /*!< active in stream counts */
        struct media_istream        *list;              /*!< input stream list */
        unsigned long               linked_counts;      /*!< linked counts, linked istreams total counts */
    }istreams;

    struct  
    {
        unsigned long               counts;             /*!< active out streams */
        struct media_ostream        *list;              /*!< output stream list */
        unsigned long               linked_counts;      /*!< linked counts, linked istreams total counts from all ostream */
    }ostreams;

    struct  
    {
        unsigned long               destroy_when_all_istreams_unlink:1; /*!< destroy channel when all istreams unlink */
        unsigned long               destroy_when_all_ostreams_unlink:1; /*!< destroy channel when all ostreams unlink */
        unsigned long               idle_timeout_check:1;               /*!< idle time out check flag, just can be set
                                                                            when create callback(channel's(channel_class->callback) 
                                                                            and controler's(module->callback) ) */
        unsigned long               is_p2p:1;                           /*!< is p2p now, dynamic status, set by channel */
        unsigned long               reserved:((sizeof(long)*8) - 4);
    }flag;
    struct media_params             *params;                    /*!< used to save refer params, dup from media-channel create */

    struct
    {
        unsigned long               create_tick,
                                    ostream_linked_his_counts,
                                    istream_linked_his_counts;
#if defined(_MSC_VER)
        unsigned __int64
#else
        unsigned long long
#endif
                                    in_sample_total_counts,     /*!< in sample total counts */
                                    out_sample_total_counts,    /*!< out sample total counts */
                                    in_sample_total_size,       /*!< in sample total size */
                                    out_sample_total_size,      /*!< out sample total size */
                                    p2p_sample_total_counts,    /*!< p2p sample total counts, set by channel */
                                    p2p_sample_total_size;      /*!< p2p sample total size, set by channel */
    }statistic;

    enum media_object_class_type    sample_queue_owner_type;    /*!< sample queue owner type, just allow module|factory|channel|istream now */
    enum media_flow_ctrl_type       flow_ctrl_type;             /*!< in flow ctrl type */
    struct media_sample_queue       sample_queue;               /*!< sample queue */
}_media_channel;
#define media_channel_get_class(_channel) (_channel)->in_class.owner
#define media_sample_get_type(_sample)   (_sample)->type
#define media_channel_get_data(_channel) ((struct media_object*)(_channel))->data
#define media_channel_set_data(_channel, _refer_data) (((struct media_object*)(_channel))->data = (_refer_data))
#define media_channel_get_ctl_data(_channel) ((struct media_object*)(_channel))->ctl_data
#define media_channel_set_ctl_data(_channel, _refer_ctl_data) (((struct media_object*)(_channel))->ctl_data = (_refer_ctl_data))
#define media_channel_get_name(_channel) (((_channel)->in_name.owner)?(_channel)->in_name.owner->text.data:NULL)
#define media_channel_get_factory(_channel) ((_channel)->in_class.owner?(_channel)->in_class.owner->in_factory.owner:(struct media_factory*)NULL)
#define media_channel_get_factory_data(_channel) ((_channel)->in_class.owner?(_channel)->in_class.owner->in_factory.owner->obj.data:NULL)
#define media_channel_get_factory_ctl_data(_channel) ((_channel)->in_class.owner?(_channel)->in_class.owner->in_factory.owner->obj.ctl_data:NULL)
#define media_channel_get_module(_channel) (_channel)->in_class.owner->in_factory.owner->in_mod.owner
#define media_channel_get_module_data(_channel) (_channel)->in_class.owner->in_factory.owner->in_mod.owner->obj.data
#define media_channel_get_module_ctl_data(_channel) (_channel)->in_class.owner->in_factory.owner->in_mod.owner->obj.ctl_data
#define media_channel_set_flag_destroy_when_all_unlink(_channel, _destroy_when_all_istreams_unlink_enable, _destroy_when_all_ostreams_unlink_enable) \
            do{ \
                ((_channel)->flag.destroy_when_all_istreams_unlink = (_destroy_when_all_istreams_unlink_enable));\
                ((_channel)->flag.destroy_when_all_ostreams_unlink = (_destroy_when_all_ostreams_unlink_enable));\
            }while(0)
#define media_channel_set_flag_idle_timeout_check(_channel, _idle_timeout_check) \
            do{\
                (_channel)->flag.idle_timeout_check = (_idle_timeout_check);\
            }while(0)
#define media_channel_format_s      "%p{[%4.4s]%s[%s]}"
#define media_channel_format(_channel) \
                (_channel), (_channel)?(char*)&((struct media_object*)(_channel))->magic:0, \
                ((0 == media_obj_loose_check(_channel, channel)) && (_channel)->in_class.owner)?(_channel)->in_class.owner->desc.name.data:NULL,\
                ((0 == media_obj_loose_check(_channel, channel)) && (_channel)->in_name.owner)?(_channel)->in_name.owner->text.data:NULL

typedef struct media_channels_statistic
{
#if defined(_MSC_VER)
    unsigned __int64
#else
    unsigned long long
#endif
                    total_bytes;
    unsigned long   counts;                     /*!< channel counts */
    unsigned long   idle_counts;                /*!< idle channels be destroy */
    unsigned long   low_fps_counts;             /*!< low trans counts, maybe p2p */
    unsigned long   stream_links;               /*!< stream links */
    unsigned long   stream_links_levels[32];    /*!< stream link event counts */
    unsigned long   bytes_log2_levels[32];      /*!< log2 level */
    unsigned long   tick_log2_levels[32];       /*!< tick length level */
}_media_channel_statistic;
#define long8_format_s                            "%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld"
#define long8_format(_l8)                        (_l8)[0],(_l8)[1],(_l8)[2],(_l8)[3],(_l8)[4],(_l8)[5],(_l8)[6],(_l8)[7]
#define media_channels_statistic_format_s        "total_bytes["i64_format_s"],counts[%ld],idle_counts[%ld],low_fps_counts[%ld],stream_links[%ld],"\
                                                "stream_links_levels["long8_format_s","long8_format_s","long8_format_s","long8_format_s"],"\
                                                "bytes_log2_levels["long8_format_s","long8_format_s","long8_format_s","long8_format_s"],"\
                                                "tick_log2_levels["long8_format_s","long8_format_s","long8_format_s","long8_format_s"]"
#define media_channels_statistic_format(_stat)    i64_format((_stat)->total_bytes), (_stat)->counts, (_stat)->idle_counts, \
                                                (_stat)->low_fps_counts, (_stat)->stream_links, \
                                                long8_format(&(_stat)->stream_links_levels[0]),long8_format(&(_stat)->stream_links_levels[8]),\
                                                long8_format(&(_stat)->stream_links_levels[16]),long8_format(&(_stat)->stream_links_levels[24]),\
                                                long8_format(&(_stat)->bytes_log2_levels[0]),long8_format(&(_stat)->bytes_log2_levels[8]),\
                                                long8_format(&(_stat)->bytes_log2_levels[16]),long8_format(&(_stat)->bytes_log2_levels[24]),\
                                                long8_format(&(_stat)->tick_log2_levels[0]),long8_format(&(_stat)->tick_log2_levels[8]),\
                                                long8_format(&(_stat)->tick_log2_levels[16]),long8_format(&(_stat)->tick_log2_levels[24])
                                                

/*! \brief median channel class parameter */
typedef struct media_param
{
    struct  
    {
        struct media_param          *prev;          /*!< prev params */
        struct media_param          *next;          /*!< next params */
    }in_params;
    struct len_str                  key;            /*!< key name */
    struct len_str                  value;          /*!< value */
}_media_param;
#define media_params_magic          (*(long*)"mprm    ")
#define media_params_magic_free     (*(long*)"MPRM    ")
typedef struct media_params
{
    struct media_object             obj;            /*!< media object */
    struct len_str                  *__xxx_name;    /*!< name (can be used to saving url, if not EMPTY will search refer channel) */
    struct len_str                  *__xxx_src;     /*!< resource, maybe same as id, can used to save full url or file path */
    unsigned long                   counts;         /*!< parameter counts */
    struct media_param              *list;          /*!< parameter list */
}_media_params;

/*! \brief media channel class base description */
typedef struct media_channel_desc
{
    struct len_str                  name;           /*!< media channel class name */
    struct len_str                  in_types;       /*!< input types */
    struct len_str                  out_types;      /*!< output types */
    media_channel_on_event          channel_on_event;/*!< channel on event */
    media_channel_on_write          channel_on_write;/*!< istream on write */
}_media_channel_desc;

/*! \brief media channel class */
#define media_channel_class_magic       (*(long*)"mcls    ")
#define media_channel_class_magic_free  (*(long*)"MCLS    ")
typedef struct media_channel_class
{
    struct media_object             obj;            /*!< media object */
    struct  
    {
        struct media_factory        *owner;         /*!< factory owner */
        struct media_channel_class  *prev;          /*!< prev channel class, cycle list */
        struct media_channel_class  *next;          /*!< next channel class, cycle list */
    }in_factory;                                    /*!< head */

    /* description info */
    struct media_channel_desc       desc;           /*!< channel class description */

    /* in/out capability */
    struct media_capability         *in_cap;        /*!< channel in capability */
    struct media_capability         *out_cap;       /*!< channel in capability */

    struct  
    {
        unsigned long               counts;         /*!< active channel counts */
        struct media_channel        *list;          /*!< channel list */
    }channels;
    
    struct
    {
        struct media_channels_statistic    channels;    /*!< channels */
    }statistic;
}_media_channel_class;
#define media_channel_class_get_factory(_class) (_class)->in_factory.owner
#define media_channel_class_get_data(_class) ((struct media_object*)(_class))->data
#define media_channel_class_set_data(_class, _refer_data) (((struct media_object*)(_class))->data = (_refer_data))
#define media_channel_class_get_ctl_data(_class) ((struct media_object*)(_class))->ctl_data
#define media_channel_class_set_ctl_data(_class, _refer_ctl_data) (((struct media_object*)(_class))->ctl_data = (_refer_ctl_data))
#define media_channel_class_format_s      "%p{[%4.4s]%s, in[%s], out[%s]}"
#define media_channel_class_format(_class) \
                (_class), (_class)?(char*)&((struct media_object*)(_class))->magic:0, \
                (0 == media_obj_loose_check(_class, channel_class))?(_class)->desc.name.data:NULL,\
                (0 == media_obj_loose_check(_class, channel_class))?(_class)->desc.in_types.data:NULL,\
                (0 == media_obj_loose_check(_class, channel_class))?(_class)->desc.out_types.data:NULL

/*! \brief media factory */
#define media_factory_magic         (*(long*)"mfct    ")
#define media_factory_magic_free    (*(long*)"MFCT    ")
typedef struct media_factory
{
    struct media_object             obj;            /*!< media object */
    struct  
    {
        struct media_module         *owner;         /*!< median channel module */
        struct media_factory        *prev;          /*!< prev factory */
        struct media_factory        *next;          /*!< next factory */
    }in_mod;
    struct len_str                  name;           /*!< media factory name */
    struct len_str                  path;           /*!< full path */

    void                            *handle;        /*!< factory handle */
    media_factory_on_event          on_event;       /*!< the factory entry */

    struct
    {
        unsigned long               counts;         /*!< classes counts */
        struct media_channel_class  *list;          /*!< list */
    }classes;

    struct media_sample_queue       sample_queue;   /*!< sample queue */
}_media_factory;
#define media_factory_get_module(_factory) (_factory)->in_mod.owner
#define media_factory_get_data(_factory) ((struct media_object*)(_factory))->data
#define media_factory_set_data(_factory, _refer_data) (((struct media_object*)(_factory))->data = (_refer_data))
#define media_factory_get_ctl_data(_factory) ((struct media_object*)(factory))->ctl_data
#define media_factory_set_ctl_data(_factory, _refer_ctl_data) (((struct media_object*)(_factory))->ctl_data = (_refer_ctl_data))
#define media_factory_format_s      "%p{[%4.4s]%s}"
#define media_factory_format(_factory) \
                (_factory), (_factory)?(char*)&((struct media_object*)(_factory))->magic:0, \
                ((0 == media_obj_loose_check(_factory, factory)) && (0 == (_factory)->name.len))?(_factory)->name.data:NULL
                    
typedef struct media_module_desc
{
    struct len_str              conf;           /*!< config data */
    media_channel_on_event      channel_on_event;/*!< channel on event */
}_media_module_desc;

#define media_module_magic      (*(long*)"mmod     ")
#define media_module_magic_free (*(long*)"MMOD     ")
#define media_channel_idle_timeout_tick    (1000*10)        /* 10s */
typedef struct media_module
{
    struct media_object         obj;            /*!< media object */
    struct media_module_desc    desc;           /*!< media module description */
    struct  
    {
        unsigned long           counts;         /*!< name counts */
        struct media_name       *list;          /*!< name list */
        struct media_name       **buckets;      /*!< name buckets array */
        struct hash_table       *tbl;           /*!< name hash table */
    }name;
    struct  
    {
        unsigned long           counts;         /*!< factory counts */
        struct media_factory    *list;          /*!< factory list */
    }factorys;
    struct
    {
        unsigned long            his_counts;    /*!< his counts */
        unsigned long            timeout_tick;  /*!< timeout ms */
        unsigned long            counts;        /*!< idle channels counts */
        struct media_channel    *list;          /*!< idle channels list */
    }idle_channels;
    struct media_params         *params;        /*!< factory create params, load from conf */
    struct media_sample_queue   sample_queue;   /*!< sample queue */

    struct
    {
        struct media_channels_statistic    channels;    /*!< channels */
    }statistic;
}_media_module;
#define media_module_get_ctl_data(_mod) ((struct media_object*)(_mod))->ctl_data
#define media_module_set_ctl_data(_mod, _refer_ctl_data) (((struct media_object*)(_mod))->ctl_data = (_refer_ctl_data))
/* should as <factory_name>.<param_name>=<param_value> */
/* ---------- media channel class ---------------- */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__media_channel_def_ex_h__) */
