/*
\file       audio_h264.h
\brief      audio/h264 format header 

------history----------
\author     chengzhiyong
\date       2011-10-11
\version    0.01
\desc       create
*/

#if !defined(__mfmt_video_h264_h__)
#define __mfmt_video_h264_h__

#if defined(__cplusplus)
extern "C" {
#endif

#define     mfmt_video_h264_sps_max_len         128
#define     mfmt_video_h264_pps_max_len         128

typedef struct mfmt_video_h264_sps_info
{
    long                    width;
    long                    height;
    long                    frame_period;
    long                    refer_frame;
}_mfmt_video_h264_sps_info;

/*\brief  video/h264 format */
typedef struct mfmt_video_h264
{
    unsigned int    fps;  /*!!!!!!!!!!!!those fields be send in rtdp-channel(mutp should be same), just accept little-endian 32bits data */
    unsigned int    bit_rate;
    unsigned int    width;
    unsigned int    height;
    unsigned int    sps_len;            /* sps length */
    unsigned char   sps[mfmt_video_h264_sps_max_len];   /* sps buffer */
    unsigned int    pps_len;            /* pps length */
    unsigned char   pps[mfmt_video_h264_pps_max_len];   /* pps buffer */    
} _mfmt_video_h264; 
#define mfmt_video_h264_format_s "%p{fps[%ld], bit_rate[%ld], width[%ld], height[%ld], "\
                                 "sps_len[%ld], sps[%02x,%02x,%02x,%02x...], "\
                                 "pps_len[%ld], pps[%02x,%02x,%02x,%02x...]}"
#define mfmt_video_h264_format(_h264_fmt) (_h264_fmt), (_h264_fmt)?(_h264_fmt)->fps:0, (_h264_fmt)?(_h264_fmt)->bit_rate:0 \
                                        (_h264_fmt)?(_h264_fmt)->width:0, (_h264_fmt)?(_h264_fmt)->height:0, \
                                        (_h264_fmt)?(_h264_fmt)->sps_len:0, \
                                        (_h264_fmt)?(_h264_fmt)->sps[0]:0, (_h264_fmt)?(_h264_fmt)->sps[1]:0 \
                                        (_h264_fmt)?(_h264_fmt)->sps[2]:0, (_h264_fmt)?(_h264_fmt)->sps[3]:0 \
                                        (_h264_fmt)?(_h264_fmt)->pps_len:0, \
                                        (_h264_fmt)?(_h264_fmt)->pps[0]:0, (_h264_fmt)?(_h264_fmt)->pps[1]:0 \
                                        (_h264_fmt)?(_h264_fmt)->pps[2]:0, (_h264_fmt)?(_h264_fmt)->pps[3]:0 \


long  mfmt_video_h264_decode_sps(unsigned char *pucSps, long spsLen, struct mfmt_video_h264_sps_info *info);
long  mfmt_video_h264_decode_slice(unsigned char *nal, long nal_len, long *first_mb);
/* split with 00,00,..,01 return NULL:not found nal; nal_len <0: not found nal end, other:nal length */
unsigned char *mfmt_video_h264_get_nal(unsigned char *stream/* annexB, split by 00,00...01*/, unsigned long len, long *nal_len, unsigned long *convert_bytes/* can be NULL, if NULL ignore */);
/* return raw data length, #<0: error code */
long mfmt_video_h264_nal_to_raw(unsigned char *nal/* one annexB nal removed 0,0,1, but maybe still have 0,0,3,x */, unsigned long len,
                                unsigned char *buf, unsigned long buf_size, unsigned long *prev_zero_counts_pt/* can be NULL */);
/* return nal data length, convert 0,0,x -> 0,0,3,x #<0: error code; */
long mfmt_video_h264_raw_to_nal(unsigned char *raw, unsigned long len/* just one nal */,
                                unsigned char *buf, unsigned long buf_size);

typedef struct mfmt_video_h264_node
{
    unsigned long       len;            /*!< string length */
    unsigned char       *data;          /*!< string data */
    unsigned long       convert_bytes;  /*!< convert bytes counts, 0,0,3,x */
}_mfmt_video_h264_node;

/* return list. need free by mfmt_video_h264_nal_list_destroy */
struct mfmt_video_h264_node *mfmt_video_h264_nal_list_create(unsigned char *stream/* annexB, split by 00,00...01*/, unsigned long len, unsigned long *counts/* [out] */);
/* return list. need free by mfmt_video_h264_nal_list_destroy */
struct mfmt_video_h264_node *mfmt_video_h264_nal_list_create2(unsigned char *data/* start with 4 byte big endian length */, unsigned long len, unsigned long *counts/* [out] */);
long mfmt_video_h264_nal_list_destroy(struct mfmt_video_h264_node *list);

#if defined(__cplusplus)
}
#endif
#endif /* !defined(__mfmt_video_h264_h__) */

