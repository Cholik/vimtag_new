/*!
\file       mmedia_format.h
\brief      mmedia_format include file list

 ----history----
\author     chengzhiyong
\date       2011-10-09
\version    0.01
\desc       create
*/
#if !defined(__mmedia_format_h__)
#define __mmedia_format_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(mframework_version_disable)
#include "mcore/mframework_version.h"
#endif
#include "mmedia_format/audio_aac.h"
#include "mmedia_format/audio_amr.h"
#include "mmedia_format/audio_nellymoser.h"
#include "mmedia_format/audio_pcm.h"
#include "mmedia_format/video_h264.h"
#include "mmedia_format/video_yuv.h"

#if defined(_MSC_VER)
/* get mframework prefix */
#   undef  mlib_mframework_prefix__local
#   if !defined(mlib_mframework_prefix)
#       define mlib_mframework_prefix__local
#       define mlib_mframework_prefix   "mmedia_format"
#   endif
/* comment lib */
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, mlib_mframework_prefix".debug.a")
#       else
#           pragma comment(lib, mlib_mframework_prefix".a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, mlib_mframework_prefix".debug.dll.lib")
#       else
#           pragma comment(lib, mlib_mframework_prefix".dll.lib")
#       endif
#   endif
/* clear flag */
#   if defined(mlib_mframework_prefix__local)
#       undef  mlib_mframework_prefix__local
#       undef  mlib_mframework_prefix
#   endif
#endif  /* defined(_MSC_VER) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mmedia_format_h__) */
