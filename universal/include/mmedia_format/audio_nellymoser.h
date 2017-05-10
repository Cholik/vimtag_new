/*
\file       audio_nellymoser.h
\brief      audio/nellymoser format header 

------history----------
\author     chenxingtao
\date       2009-12-31
\version    0.01
\desc       create
*/

#if !defined(__mfmt_audio_nellymoser_h__)
#define __mfmt_audio_nellymoser_h__

#if defined(__cplusplus)
extern "C" {
#endif

/*\brief  audio/nellymoser format */
typedef struct mfmt_audio_nellymoser
{
    unsigned long   sample_rate;                /*!< sample reate */
} _mfmt_audio_nellymoser; 

#if defined(__cplusplus)
}
#endif
#endif /* !defined(__mfmt_audio_nellymoser_h__) */

