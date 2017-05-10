/*!
\file       rtmp_msg.h
\brief

 ----history----
\author     zhengxianwei
\date       2009-09-30
\version    0.01
\desc       create

$Author: zhengxianwei $
$Id: rtmp_msg.h,v 1.3 2009-09-30 16:00:56 zhengxianwei Exp $
*/

#ifndef _RTMP_MSG_H_
#define _RTMP_MSG_H_

#define MSG_TYPE_SET_CHUNK_SIZE                 (0x01)
#define	MSG_TYPE_ABORT                          (0x02)
#define	MSG_TYPE_ACK                            (0x03)
#define	MSG_TYPE_USER_CONTROL                   (0x04)
#define	MSG_TYPE_WIN_ACK_SIZE                   (0x05)
#define MSG_TYPE_SET_PEER_BW                    (0x06)

#define	MSG_TYPE_AUDIO                          (0x08)
#define	MSG_TYPE_VIDEO                          (0x09)
#define	MSG_TYPE_AMF3_DATA                      (0x0f)
#define MSG_TYPE_AMF3_SHD_OBJ                   (0x10)
#define	MSG_TYPE_AMF3_CMD                       (0x11)
#define	MSG_TYPE_AMF0_DATA                      (0x12)
#define	MSG_TYPE_AMF0_SHD_OBJ                   (0x13)
#define	MSG_TYPE_AMF0_CMD                       (0x14)
#define	MSG_TYPE_AGGREGATE                      (0x16)

#define	EVT_TYPE_STREAM_BEGIN                   (0x00)  // 4 bytes
#define	EVT_TYPE_STREAM_EOF                     (0x01)  // 4 bytes
#define	EVT_TYPE_STREAM_DRY                     (0x02)  // 4 bytes
#define	EVT_TYPE_SET_BUF_LEN                    (0x03)  // 8 bytes
#define	EVT_TYPE_STREAM_IS_RECORDED             (0x04)  // 4 bytes
#define	EVT_TYPE_PING_REQ                       (0x05)  // 4 bytes
#define	EVT_TYPE_PING_RES                       (0x06)  // 4 bytes

struct amf_node;

typedef struct rtmp_user_ctl {
    uint16_t    evt_reserved;       /*!, not exist field, just for 4 bytes align */
    uint16_t    evt_type;
    uint32_t    evt_data1;
    uint32_t    evt_data2;
} _rtmp_user_ctl;

#define	LIM_TYPE_HARD                           (0x00)
#define	LIM_TYPE_SOFT                           (0x01)
#define	LIM_TYPE_DYM                            (0x02)
typedef struct rtmp_peer_bw {
    uint32_t        ack_win_size;
    unsigned char   limit_type;
} _rtmp_peer_bw;


// send msg

/*!
func
\brief
\param
\return
*/
long rtmp__encode_set_chunk_size (unsigned char **buf, unsigned long *len, unsigned long new_chunk_size);

/*!
func
\brief
\param
\return
*/
long rtmp__encode_abort_msg (unsigned char **buf, unsigned long *len, unsigned long chunk_id);

/*!
func
\brief
\param
\return
*/
long rtmp__encode_acknowledgement (unsigned char **buf, unsigned long *len, unsigned long recv_total);

/*!
func
\brief
\param
\return
*/
long rtmp__encode_user_ctl (unsigned char **buf, unsigned long *len, struct rtmp_user_ctl *ctl);

/*!
func
\brief
\param
\return
*/
long rtmp__encode_win_ack_size (unsigned char **buf, unsigned long *len, unsigned long ack_win_size);

/*!
func
\brief
\param
\return
*/
long rtmp__encode_set_peer_bw (unsigned char **buf, unsigned long *len, struct rtmp_peer_bw *bw);

/*!
func
\brief
\param
\return
*/
long rtmp__encode_audio (unsigned char **buf, unsigned long *buf_len, unsigned char *data, unsigned long data_len);

/*!
func
\brief
\param
\return
*/
long rtmp__encode_video (unsigned char **buf, unsigned long *buf_len, unsigned char *data, unsigned long data_len);

/*!
func
\brief
\param
\return
*/
long rtmp__encode_data (unsigned long encoding, unsigned char **buf, unsigned long *buf_len, struct amf_node *tree);

/*!
func
\brief
\param
\return
*/
long rtmp__encode_cmd (unsigned long encoding, unsigned char **buf, unsigned long *len, struct amf_node *tree);

/*!
func
\brief
\param
\return
*/
long rtmp__encode_shared_obj (unsigned long encoding, unsigned char **buf, unsigned long *buf_len, struct amf_node *tree);


/*!
func
\brief
\param
\return
*/
long rtmp__decode_set_chunk_size (unsigned char *buf, unsigned long len, unsigned long *new_chunk_size);

/*!
func
\brief
\param
\return
*/
long rtmp__decode_abort_msg (unsigned char *buf, unsigned long len, unsigned long *chunk_id);

/*!
func
\brief
\param
\return
*/
long rtmp__decode_acknowledgement (unsigned char *buf, unsigned long len, unsigned long *recv_total);

/*!
func
\brief
\param
\return
*/
long rtmp__decode_user_ctrl (unsigned char *buf, unsigned long len, struct rtmp_user_ctl *ctl);

/*!
func
\brief
\param
\return
*/
long rtmp__decode_win_ack_size (unsigned char *buf, unsigned long len, unsigned long *ack_win_size);

/*!
func
\brief
\param
\return
*/
long rtmp__decode_set_peer_bw (unsigned char *buf, unsigned long len, struct rtmp_peer_bw *bw);

/*!
func
\brief
\param
\return
*/
long rtmp__decode_data (unsigned long encoding, unsigned char *buf, unsigned long len, struct amf_node **tree);

/*!
func
\brief
\param
\return
*/
long rtmp__decode_cmd (unsigned long encoding, unsigned char *buf, unsigned long len, struct amf_node **tree);

/*!
func
\brief
\param
\return
*/
long rtmp__decode_shared_obj (unsigned long encoding, unsigned char *buf, unsigned long len, struct amf_node **tree);

#endif

