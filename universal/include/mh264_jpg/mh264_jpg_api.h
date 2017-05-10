#if !defined(__mh264_jpg_api_h__)
#define __mh264_jpg_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#define mh264_decode_type_yuv   0
#define mh264_decode_type_jpg   1

struct decode_param
{
    int decode_type; //mh264_decode_type_yuv | mh264_decode_type_jpg
    unsigned char *src_data;
    long src_len;
    unsigned char *buf;
    long *buf_len;
    long *yuv_width;
    long *yuv_height;
};

/*!
func    mh264_jpg_decode
\brief  decode h264 frame to jpg or yuv
\param  decode_type[in]         mh264_decode_type_yuv | mh264_decode_type_jpg
\param  h264_data[in]           h264 nal data. Include sps|pps|iframe
\param  h264_len[in]            h264_nal len
\param  buf[in]                 buf for result
\param  buf_len[in]             buf length
\return the media channel
        # 0                   success
        # other                 fail
*/
long mh264_jpg_decode( int decode_type, unsigned char *h264_data, long h264_len, unsigned char *buf, long *buf_len );

/*!
func    mh264_jpg_decode2
\brief  decode h264 frame to jpg or yuv
\param  decode_param[in]        struct decode_param *param
\return the media channel
        # 0                     success
        # other                 fail
*/
long mh264_jpg_decode2( struct decode_param *param );

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif
