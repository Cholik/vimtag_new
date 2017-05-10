/*!
\file       melib_libv8.h
\brief      libv8 library unit header

 ----history----
\author     chengzhiyong
\date       2015-06-21
\version    0.01
\desc       create
*/
#if !defined(__melib_libv8_h__)
#define __melib_libv8_h__

#if 0   /* will cause error with template */
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */
#endif

#include "libv8/v8.h"
//#define melib_libv8_enable_snapshot 1

#if defined(_MSC_VER)
#   if defined(_LIB)
#   if _MSC_VER < 1800
#       error at lease VS2013, or will cause template link error, V8 new version need at lease VS2013
#   endif
#       if defined(_DEBUG)
#           pragma comment(lib, "v8_base.debug.a")
#           pragma comment(lib, "v8_libbase.debug.a")
#           pragma comment(lib, "v8_libplatform.debug.a")
#           if defined(melib_libv8_enable_snapshot) && melib_libv8_enable_snapshot
#               pragma comment(lib, "v8_snapshot.debug.a")
#           else
#               pragma comment(lib, "v8_nosnapshot.debug.a")
#           endif
#       else
#           pragma comment(lib, "v8_base.a")
#           pragma comment(lib, "v8_libbase.a")
#           pragma comment(lib, "v8_libplatform.a")
#           if defined(melib_libv8_enable_snapshot) && melib_libv8_enable_snapshot
#               pragma comment(lib, "v8_snapshot.a")
#           else
#               pragma comment(lib, "v8_nosnapshot.a")
#           endif
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "v8_base.debug.dll.lib")
#       else
#           pragma comment(lib, "v8_base.dll.lib")
#       endif
#   endif
#endif

#if 0   /* will cause error with template */
#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
#endif

#endif /* !defined(__melib_libv8_h__) */

