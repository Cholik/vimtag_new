/*
\file       audio_amr.h
\brief      audio/amr format header 

------history----------
\author     chenxingtao
\date       2009-12-31
\version    0.01
\desc       create
*/

#if !defined(__mfmt_audio_amr_h__)
#define __mfmt_audio_amr_h__

#if defined(__cplusplus)
extern "C" {
#endif

/*\brief  audio/amr format */
typedef struct mfmt_audio_amr
{
    unsigned long   sample_rate;                /*!< sample reate */
} _mfmt_audio_amr; 

#if defined(__cplusplus)
}
#endif
#endif /* !defined(__mfmt_audio_amr_h__) */

