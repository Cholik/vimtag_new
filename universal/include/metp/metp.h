/*!
\file       metp.h
\brief      mining endpoint transport protocol

 ----history----
\author     chengzhiyong
\date       2013-07-27
\version    0.01
\desc       create
*/

#if !defined(__metp_h__)
#define __metp_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

#if !defined(mframework_version_disable)
#include "mcore/mframework_version.h"
#endif

#include "metp/metp_frame_codec.h"
#include "metp/metp_dat.h"
#include "metp/metp_ctl_codec.h"
#include "metp/metp_mod.h"

#if defined(_MSC_VER)
/* get mframework prefix */
#   undef  mlib_mframework_prefix__local
#   if !defined(mlib_mframework_prefix)
#       define mlib_mframework_prefix__local
#       define mlib_mframework_prefix   "metp"
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
#endif /* defined(__cplusplus) */

#endif /* !defined(__metp_h__) */

