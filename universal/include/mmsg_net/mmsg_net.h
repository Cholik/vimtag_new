/*!
\file       mmsg_net.h
\brief      mmsg network include file list

 ----history----
\author     chengzhiyong
\date       2007-09-10
\version    0.01
\desc       distill from mmsg module
*/
#if !defined(__mmsg_net_h__)
#define __mmsg_net_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(mframework_version_disable)
#include "mcore/mframework_version.h"
#endif
#include "mmsg_net/msg_download.h"
#include "mmsg_net/msg_http.h"
#include "mmsg_net/msg_remote.h"
#include "mmsg_net/msg_vhost.h"
#include "mmsg_net/msg_mbc.h"

#if defined(_MSC_VER)
/* get mframework prefix */
#   undef  mlib_mframework_prefix__local
#   if !defined(mlib_mframework_prefix)
#       define mlib_mframework_prefix__local
#       define mlib_mframework_prefix   "mmsg_net"
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

#endif /* !defined(__mmsg_net_h__) */

