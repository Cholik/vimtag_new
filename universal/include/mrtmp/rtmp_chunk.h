/*!
\file       rtmp_chunk.h
\brief

 ----history----
\author     zhengxianwei
\date       2009-10-11
\version    0.01
\desc       create

$Author: zhengxianwei $
$Id: rtmp_chunk.h,v 1.3 2009-10-11 16:46:40 zhengxianwei Exp $
*/

#ifndef _RTMP_CHUNK_H_
#define _RTMP_CHUNK_H_

#define MSG_CHUNK_SIZE              (0x80)      // 128
#define MSG_HEADER_SIZE             (0x0c)

#define CHANNEL_SET_CHUNK_SIZE      (0x02)
#define	CHANNEL_WIN_ACK_SIZE        (0x02)
#define	CHANNEL_ACK                 (0x02)
#define	CHANNEL_USER_CTL            (0x02)
#define	CHANNEL_SET_PEER_BW         (0x02)
#define CHANNEL_VIDEO               (0x04)
#define	CHANNEL_AUDIO               (0x10)

#define	CHANNEL_DATA                (0x05)
#define CHANNEL_CONNECT             (0x03)
#define CHANNEL_CS                  (0x03)
#define CHANNEL_PLAY                (0x08)
#define CHANNEL_PUBLISH             (0x03)
#define	CHANNEL_ONBWDONE            (0x03)
#define	CHANNEL_ONSTATUS            (0x04)
#define	CHANNEL_RESULT              (0x03)
#define CHANNEL_AGGREGATE           (0x05)


#define	CHUNK_SIZE_MIN              (0x80)
#define	CHUNK_SIZE_MAX              (0x10000)

#define	RECV_BUF_SIZE               (0x10000)

typedef struct rtmp_msg {
    unsigned long   msg_type;
    unsigned long   payload_len;
    unsigned long   timestamp;
    unsigned long   stream_id;
    unsigned long   chunk_id;
    unsigned char   *payload;
} _rtmp_msg;

typedef struct rtmp_bchunk_node {
    struct { /* node */
        struct rtmp_bchunk_node *prev;
        struct rtmp_bchunk_node *next;
    } node;

    unsigned long   len;
    unsigned char  *data;
} _rtmp_chunk_list;

typedef struct rtmp_channel {
    unsigned long   ts_delta;
    unsigned long   recv_len;
    struct rtmp_msg msg;
} _rtmp_channel;

typedef struct rtmp_chunks {
    struct { // recv
        unsigned char               buf[RECV_BUF_SIZE];
        unsigned long               start;
        unsigned long               len;
        unsigned long               total;
        struct rtmp_channel         *channels[64];
        unsigned long               max_chunk_size;
    } recv;
    struct { // send
        unsigned long               counts;
        struct rtmp_bchunk_node     *list;
        unsigned long               start;
        unsigned long               last_timestamp[64];

        struct rtmp_bchunk_node     *audio_last;
        unsigned long               total;
        unsigned long               max_chunk_size;
    } send;

    unsigned long                   win_ack_size;
    unsigned long                   report_bytes;
    long                            send_bytes;
    long                            recv_bytes;

    // debug
    FILE                            *msg_all;
} _rtmp_chunks;


/*!
func
\brief
\param
\return
*/
long rtmp__chunk_append_msg (struct rtmp_chunks *chunks, struct rtmp_msg *msg);

/*!
func
\brief
\param
\return
*/
long rtmp__chunk_get_msg (struct rtmp_chunks *chunks, struct rtmp_msg **out_msg);
#endif

