/*!
\file       rtmp_mod.h
\brief

----history----
\author     zhengxianwei
\date       2009-09-29
\version    0.01
\desc       create

$Author: zhengxianwei $
$Id: rtmp_mod.h,v 1.3 2009-09-29 09:33:56 zhengxianwei Exp $
*/

#ifndef _RTMP_MOD_H_
#define _RTMP_MOD_H_

#include    "rtmp_msg.h"
#include    "rtmp_chunk.h"

struct rtmp_conn;
struct rtmp_req_params;
struct rtmp_conn;
struct json_object;
struct len_str;

typedef enum rtmp_conn_state {
    // handshake
    ercs_rtmp_start,
    ercs_c_hand1,
    ercs_s_hand1,
    ercs_s_hand2,
    ercs_c_hand2,

    // connect
    ercs_c_connect,
    ercs_s_result_connect,

    // createStream
    ercs_c_create_stream,
    ercs_s_result_create_stream,

    // play
    ercs_c_play,
    // play2        play video in new rate
    ercs_c_play2,
    ercs_s_result_play,

    // publish
    ercs_c_publish,
    ercs_s_result_publish,

    // broadcasting a shared object message
    ercs_c_soe_use,          // Shared Object Event(Use)
    ercs_s_soe_us_clear,     // UseSuccess, Clear
    ercs_c_soe_req_change,   // RequestChange
    ercs_s_soe_success,      // Success
    ercs_c_soe_send_msg,     // SendMessage
    ercs_s_soe_send_msg
} _rtmp_conn_state;

typedef long    (* rtmp_on_mdata)                   (struct rtmp_conn *conn, struct rtmp_msg *recv_msg);
typedef long    (* rtmp_on_req)                     (struct rtmp_conn *conn, struct rtmp_req_params *params);

typedef struct rtmp_req_params
{
    struct len_str          *type;
    struct len_str          *sub_type;
    struct json_object      *data;
}_rtmp_req_params;
#define rtmp_req_params_format_s        "%p"
#define rtmp_req_params_format(_params) (_params)

typedef struct rtmp_params {
    struct
    {
        unsigned long           port;                   /* if empty, means will not open server port */
        unsigned long           max_counts;
        long                    min_video_in_second;
        long                    max_video_in_second;
        long                    min_left_bytes;
        long                    max_left_bytes;
        long                    min_kbps;
        long                    max_kbps;
        long                    init_kbps;
    }net;
    struct
    {
        rtmp_on_mdata           on_data;
        rtmp_on_req             on_req;
    }events;
} _rtmp_params;

#define TYPE_PLAY                   (0x01)
#define TYPE_PUB_LIVE               (0x02)
#define	TYPE_PUB_RECORD             (0x03)
#define TYPE_SERVER                 (0x04)
#define TYPE_UNDEFINED              (0x05)

struct rtmp_mod;
struct rtmp_conn;

#define	rtmp_play(t_rtmp, t_url)        rtmp_create_conn(t_rtmp, TYPE_PLAY,  t_url, 0)
#define	rtmp_publish(t_rtmp, t_url)     rtmp_create_conn(t_rtmp, TYPE_PUB_LIVE, t_url, 0)
#define	rtmp_server(t_rtmp, t_socket)   rtmp_create_conn(t_rtmp, TYPE_SERVER, NULL, t_socket)

/*!
func    rtmp_create
\brief  create a rtmp mod, must destory by rtmp_destroy
\param  params[in]          callback function
\return get rtmp mod
        #NULL               error
        #other              success
*/
struct rtmp_mod* rtmp_create (struct rtmp_params *params);

/*!
func    rtmp_create_conn
\brief
\param  conn_type[in]
\param  mod[in]             rtmp module
\param  url[in]
\param  socket[in]
\return #NULL               error
        #other              success, get rtmp connection
*/
struct rtmp_conn* rtmp_create_conn (struct rtmp_mod *mod,
                                    unsigned long   conn_type,
                                    char            *url,
                                    long            socket);

/*!
func    rtmp_destroy_conn
\brief  destroy rtmp connection
\param  conn[in]            created by rtmp_create_conn
\return #0                  success
        #other              error
*/
long rtmp_destroy_conn (struct rtmp_conn *conn);

/*!
func    rtmp_destroy
\brief
\param  mod[in]             rtmp module
\return #0                  success
        #other              error
*/
long rtmp_destroy (struct rtmp_mod *mod);

/*!
func    rtmp_wait
\brief
\param  mod[in]             created by rtmp_create
\param  timeout[in]
\return #0                  success
        #other              error
*/
long rtmp_wait (struct rtmp_mod *mod, unsigned long timeout /* tick */);

/*!
func    rtmp_conn_get_owner
\brief  get rtmp connection's owner
\param  conn[in]            created by rtmp_create_conn
\return #NULL               error
        #error              success
*/
struct rtmp_mod* rtmp_conn_get_owner (struct rtmp_conn *conn);

/*!
func    rtmp_conn_set_speed
\brief  get rtmp connection's owner
\param  conn[in]            created by rtmp_create_conn
\param  init_kbps[in]       init speed(kbps)
\param  min_kbps[in]        init speed(kbps)
\param  max_kbps[in]        init speed(kbps)
\param  
\return #NULL               error
        #error              success
*/
long rtmp_conn_set_speed (struct rtmp_conn *conn, unsigned long init_kbps, unsigned long min_kbps, unsigned long max_kbps);

/*!
func    rtmp_mod_set_refer
\brief  rtmp_mod save external data ptr
\param  mod[in]             created by rtmp_create
\param  refer[in]           external data ptr
\return void
*/
void rtmp_mod_set_refer (struct rtmp_mod *mod, void *refer);

/*!
func    rtmp_mod_get_refer
\brief  get external data ptr saved by rtmp_mod_set_refer
\param  mod[in]             created by rtmp_create
\return #NULL               error
        #other              success
*/
void* rtmp_mod_get_refer (struct rtmp_mod *mod);

/*!
func    rtmp_conn_set_refer
\brief  external data ptr stored by rtmp_conn
\param  conn[in]            created by rtmp_create_conn
\param  refer[in]           external data ptr
\return void
*/
void rtmp_conn_set_refer (struct rtmp_conn *conn, void *refer);

/*!
func    rtmp_conn_get_refer
\brief  get external data ptr saved by rtmp_mod
\param  conn[in]            created by rtmp_create_conn
\return #NULL               error
        #other              success
*/
void* rtmp_conn_get_refer (struct rtmp_conn *conn);

/*!
func    rtmp_conn_get_refer
\brief  set detect info
\param  conn[in]                    created by rtmp_create_conn
\param  left_bytes_in_second[in]    if you dont't want to set the value, please pass in -1
\param  min_left_bytes[in]          if you dont't want to set the value, please pass in -1
\return #NULL                       error
        #other                      success
*/
void rtmp_conn_set_detect (struct rtmp_conn *conn, long left_bytes_in_second, long min_left_bytes);

/*!
func    rtmp_conn_is_ready
\brief  connection is ready to send out audio/video data
\param  conn[in]            created by rtmp_create_conn
\return #0                  ready
        #1                  not ready
        #<0                 error code
*/
long rtmp_conn_is_ready(struct rtmp_conn *conn);

/*!
func    rtmp_conn_get_state
\brief  get state
\param  conn[in]            created by rtmp_create_conn
\return #other              state value conn_state
        #<0                 error code
*/
long rtmp_conn_get_state(struct rtmp_conn *conn);

/* used by rtmp server play or client publish */

/*!
func    rtmp_send_ctrl
\brief  used by externl function to send video through rtmp protocol
\param  conn[in]            created by rtmp_create_conn
\param  params[in]          if params == NULL, build idr command
                            else if params.speed, build mbw command
\return #0                  success
        #other              error
*/
long rtmp_send_ctrl (struct rtmp_conn *conn, struct rtmp_req_params *params);

/*!
func    rtmp_send_media
\brief  used by external function to send audio through rtmp protocol
\param  conn[in]            created by rtmp_create_conn
\param  is_audio[in]        0: video, 1:audio
\param  data[in]            audio data ptr
\param  len[in]             audio data len
\param  timestamp[in]       audio data timestamp
\return #0                  success
        #other              error
*/
long rtmp_send_media (struct rtmp_conn *conn, long is_audio, unsigned char *data, unsigned long len, unsigned long timestamp);

/* only used by rtmp server play */

/*!
func    rtmp_close_stream
\brief  used by rtmp server peer to inform rtmp client close the current connection
\param  conn[in]            created by rtmp_create_conn
\param  duration[in]        stream duration
\param  bytes[in]           stream size
\return #0                  success
        #other              error
*/
long rtmp_close_stream (struct rtmp_conn *conn, double duration, double bytes);

#endif /* end of _RTMP_MOD_H_ */

