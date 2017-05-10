/*!
\file       mme_x.h
\brief      mining media engine x
----history----
\author     chengzhiyong
\date       2012-03-27
\version    0.01
\desc       create

$Author: chengzhiyong $
*/
#if !defined(__mining_media_engine_x_h__)
#define __mining_media_engine_x_h__

#if defined(__cplusplus)
extern "C" {
#endif

#if !defined(mframework_version_disable)
#include "mcore/mframework_version.h"
#endif
#include "mme_x/me_x.h"

#if defined(_MSC_VER)
/* get mframework prefix */
#   undef  mlib_mframework_prefix__local
#   if !defined(mlib_mframework_prefix)
#       define mlib_mframework_prefix__local
#       define mlib_mframework_prefix   "mme_x"
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
#endif

#endif /* !defined(__mining_media_engine_x_h__) */