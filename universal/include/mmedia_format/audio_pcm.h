/*
\file       audio_pcm.h
\brief      audio/pcm format header 

------history----------
\author     chenxingtao
\date       2009-12-31
\version    0.01
\desc       create
*/

#if !defined(__mfmt_audio_pcm_h__)
#define __mfmt_audio_pcm_h__

#if defined(__cplusplus)
extern "C" {
#endif


/*\brief  audio/pcm format */
typedef struct mfmt_audio_pcm
{
#if 0   /*!< xxxxxxxx todo: waiting active */
    unsigned long   channel_counts;             /*!< channel counts */
    unsigned long   sample_bits;                /*!< sample bits */
#endif
    unsigned long   sample_rate;                /*!< sample reate */
} _mfmt_audio_pcm; 

#if defined(__cplusplus)
}
#endif
#endif /* !defined(__mfmt_audio_pcm_h__) */

