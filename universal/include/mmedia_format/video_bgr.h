/*
\file       video_brg.h
\brief      video/brg format header 

------history----------
\author     chenxingtao
\date       2009-12-31
\version    0.01
\desc       create
*/

#if !defined(__mfmt_video_brg_h__)
#define __mfmt_video_brg_h__

#if defined(__cplusplus)
extern "C" {
#endif

/*\brief  video/brg format */
typedef struct mfmt_video_brg
{
    long            width_bytes;
    unsigned long   width;
    unsigned long   height;
} _mfmt_video_brg; 

#if defined(__cplusplus)
}
#endif
#endif /* !defined(__mfmt_video_brg_h__) */

