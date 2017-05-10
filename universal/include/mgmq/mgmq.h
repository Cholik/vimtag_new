/*!
\file       mgmq.h
\brief      mining dynamic message queue

 ----history----
\author     chengzhiyong
\date       2012-11-05
\version    0.01
\desc       create

\author     chengzhiyong
\date       2013-12-01
\version    0.02
\desc       add dynmiac sync functions
*/
#if !defined(__mgmq_h__)
#define __mgmq_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(mframework_version_disable)
#include "mcore/mframework_version.h"
#endif
#include "mgmq/gw.pdef.h"
#include "mgmq/mgmq.pdef.h"
#include "mgmq/mgmq_base.h"
#include "mgmq/mgmq_utils.h"

#if defined(_MSC_VER)
/* get mframework prefix */
#   undef  mlib_mframework_prefix__local
#   if !defined(mlib_mframework_prefix)
#       define mlib_mframework_prefix__local
#       define mlib_mframework_prefix   "mgmq"
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

#endif /* !defined(__mgmq_h__) */

