/*
\file       video_yuv.h
\brief      video/yuv format header 

------history----------
\author     chenxingtao
\date       2009-12-31
\version    0.01
\desc       create
*/

#if !defined(__mfmt_video_yuv_h__)
#define __mfmt_video_yuv_h__

#if defined(__cplusplus)
extern "C" {
#endif

/*\brief  video/yuv format */
typedef struct mfmt_video_yuv
{
    unsigned long   sample_rate;                /*!< sample reate */
    unsigned long   width;
    unsigned long   height;
} _mfmt_video_yuv; 

#if defined(__cplusplus)
}
#endif
#endif /* !defined(__mfmt_video_yuv_h__) */

