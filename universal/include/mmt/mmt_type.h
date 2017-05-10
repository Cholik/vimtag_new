/*!
\file       mmt_type.h
\brief      media transport type

 ----history----
\author     chengzhiyong
\date       2014-05-11
\version    0.01
\desc       create
*/

#if !defined(__mmt_type_h__)
#define __mmt_type_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

struct mmt_mod;
struct mmt_pack;
struct mmt_pack_type;
struct len_str;

#define mmt_succeed                                     0
#define mmt_err_invalid_param                           -1
#define mmt_err_unknown_chl_id                          -2
#define mmt_err_unknown_conn_id                         -3
#define mmt_err_conn_create_failed                      -4
#define mmt_err_chl_create_failed                       -5
#define mmt_err_link_to_srv_not_ready                   -6
#define mmt_err_failed_to_forward                       -7
#define mmt_err_send_data_by_mirror_link_failed         -8
#define mmt_err_unknown_media_pack_type                 -9
#define mmt_err_media_link_not_ready                    -10
#define mmt_err_send_media_data_failed                  -11
#define mmt_err_create_ctrl_link_failed                 -12
#define mmt_err_create_video_link_failed                -13
#define mmt_err_create_audio_link_failed                -14
#define mmt_err_utils_entry_disabled                    -15
#define mmt_err_save_pack_format_failed                 -16
#define mmt_err_invalid_media_pack_format               -17
#define mmt_err_params_build_failed                     -18
#define mmt_err_send_media_format_failed                -19
#define mmt_err_media_pack_type_changed                 -20
#define mmt_err_params_content_invalid                  -21
#define mmt_err_link_accept_failed                      -22
#define mmt_err_stream_link_not_ready                   -23
#define mmt_err_malloc_failed                           -24
#define mmt_err_unknown_payload_type                    -25
#define mmt_err_connection_exist                        -26
#define mmt_err_unknown_connection                      -27
#define mmt_err_connect_failed                          -28
#define mmt_err_not_support_now                         -29
#define mmt_err_srv_link_disconnected                   -30
#define mmt_err_srv_link_create_failed                  -31
#define mmt_err_invalid_data_len                        -32
#define mmt_err_conn_modify_failed                      -33
#define mmt_err_invalid_url                             -34
#define mmt_err_create_stream_failed                    -35
#define mmt_err_unknown_link_type                       -36
#define mmt_err_stream_link_create_failed               -37
#define mmt_err_invalid_chl                             -38
#define mmt_err_invalid_stream                          -38
#define mmt_err_not_support_chl_connect_directly_now    -39
#define mmt_err_accept_stream_link_failed               -40
#define mmt_err_invalid_data_params                     -41
#define mmt_err_unknown_stream_link                     -42


#if !defined(__len_str_defined)
#   define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */

#if !defined(__mmt_pack_type_defined)
#define __mmt_pack_type_defined
#define mmt_pack_format_max     64
typedef struct mmt_pack_type
{
    long                        changed_seq;        /*!< changed seq no, for changed checking */
    struct len_str              major;              /*!< video,audio */
    struct len_str              sub;                /*!< h264/nal, aac/adts */
    struct 
    {
        unsigned long           ext_counts;         /*!< used to save h.264 sps/pps; aac/header */
        struct len_str          ext[4];
    }format;
}_mmt_pack_type;
#endif  /* !defined(__mmt_pack_type_defined) */

/*\brief frame pack, all video and audio data will be in this frame */
#if !defined(__mmt_pack_defined)
#define __mmt_pack_defined
#define mmt_pack_flag_key_sample    0x01
#define mmt_pack_flag_prev_lost     0x02
#define mmt_pack_flag_trigger       0x04
typedef struct mmt_pack
{
    struct mmt_pack_type    *type;              /*!< type info */

    unsigned long           time_stamp;         /*!< time stamp, ms tick */
    unsigned long           time_stamp_high;    /*!< time stamp high part, ms tick, from 1970-01-01 GMT */
    unsigned long           sample_id;          /*!< sample id */

    struct{unsigned long    len; unsigned char *data;} data;/*!< data */

    unsigned long           flag;               /*!< flag, refer mmt_pack_flag_xxx */
}_mmt_pack;
#endif /* !defined(__mmt_pack_defined) */

/*\brief engine event */
#if !defined(__mmt_event_defined)
#define __mmt_event_defined
typedef struct mmt_event
{
    struct len_str          type;               /*!< event type */
    long                    status;             /*!< integer status */
    struct len_str          code;               /*!< code string information */

    struct len_str          data;               /*!< additional data */
    long                    idata;              /*!< idata */
}_mmt_event;
#define mmt_event_format_s "%p{type[%s], status[%ld], code[%s]}"
#define mmt_event_format(_evt) (_evt), (_evt)?(_evt)->type.data:NULL, (_evt)?(_evt)->status:0, (_evt)?(_evt)->code.data:NULL
#endif /* !defined(__mmt_event_defined) */


/*!
func    mmt_mod_on_event
\brief  callback function when event be raised with module
\param  mod[in]                 the module return by mmt_mod_create
\param  ref[in]                 the refer pointer input by desc when mmt_mod_create
\param  evt[in]                 the event data
                                type: server[code:connected,disconnected]
\return on event result
        #0                      succeed
        #other                  the error code
*/
typedef long (*mmt_mod_on_event)(struct mmt_mod *mod, void *ref, struct mmt_event *evt);

/*!
func    mmt_conn_on_data
\brief  callback function when data arriving
\param  mod[in]                 the module return by mmt_mod_create
\param  conn_id[in]             the connection id return by mmt_conn_create 
\param  ref[in]                 the refer pointer input by desc when mmt_conn_create
\param  len[in]                 the data length
\param  data[in]                the data
\return write result
        #0                      succeed
        #other                  the error code
*/
typedef long (*mmt_conn_on_data)(struct mmt_mod *mod, long conn_id, void *ref, 
                                 unsigned long len, unsigned char *data);

/*!
func    mmt_conn_on_event
\brief  callback function when event be raised with connection
\param  mod[in]                 the module return by mmt_mod_create
\param  conn_id[in]             the connection id return by mmt_conn_create 
\param  ref[in]                 the refer pointer input by desc when mmt_conn_create
\param  evt[in]                 the event data
                                type: connection[code:connected,accepted,disconnected]
\return on event result
        #0                      succeed
        #other                  the error code
*/
typedef long (*mmt_conn_on_event)(struct mmt_mod *mod, long conn_id, void *ref, 
                                  struct mmt_event *evt);

/*!
func    mmt_chl_on_pack
\brief  callback function when media pack arrived with channel, just for play channel
\param  mod[in]                 the module return by mmt_mod_create
\param  chl_id[in]              the channel id return by mmt_chl_create 
\param  ref[in]                 the refer pointer input by desc when mmt_chl_create
\param  pack[in]                the media pack
\return on event result
        #0                      succeed
        #other                  the error code
*/
typedef long (*mmt_chl_on_pack)(struct mmt_mod *mod, long chl_id, void *ref,
                                struct mmt_pack *pack);

/*!
func    mmt_chl_on_event
\brief  callback function when event be raised with channel
\param  mod[in]                 the module return by mmt_mod_create
\param  chl_id[in]              the channel id return by mmt_chl_create 
\param  ref[in]                 the refer pointer input by desc when mmt_chl_create
\param  evt[in]                 the event data
                                type: channel[code:connected, accepted, disconnected],
                                      stream [code:accepted, connected, disconnected,
                                                p2p.enter, p2p.leave,
                                                bandwidth.modify, overload.discard, overload.warn, overload.remove,
                                                play, pause, seek,
                                                idr]
\return on event result
        #0                      succeed
        #other                  the error code
*/
typedef long (*mmt_chl_on_event)(struct mmt_mod *mod, long chl_id, void *ref,
                                 struct mmt_event *evt);

typedef struct mmt_mod_desc
{
    struct len_str              srv;            /*!< server url: xxx://xxx.xxx.xxx:xxx/ */

    struct len_str              uid;            /*!< user id */
    struct len_str              key;            /*!< user key */

    void                        *ref;           /*!< refer data for user */

    mmt_mod_on_event            mod_on_event;   /*!< module on event */
    mmt_conn_on_event           conn_on_event;  /*!< connection on event */
    mmt_conn_on_data            conn_on_data;   /*!< connection on data */
    mmt_chl_on_event            chl_on_event;   /*!< channel on event */
    mmt_chl_on_pack             chl_on_pack;    /*!< channel on media pack */
}_mmt_mod_desc;

typedef struct mmt_conn_desc
{
    struct len_str              uid;            /*!< peer uid */
    void                        *ref;           /*!< refer data for connect */
}_mmt_conn_desc;

typedef struct mmt_chl_desc
{
    struct len_str              type;           /*!< publish, play */
    struct len_str              url;            /*!< xxx://xxx.xxx.xxx:xxx/xxx/xxx */

    struct mmt_pack_type        *video, *audio; /*!< media type, just for publish */
    void                        *ref;           /*!< refer data for chl */

    unsigned long               min_kbps, max_kbps, init_kbps,
                                disable_delay, disable_p2p;
}_mmt_chl_desc;

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__mmt_type_h__) */

