/*!
\file       melib_libeq.h
\brief      libeq include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_libeq_h__)
#define __melib_libeq_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "libeq/eq.h"

#if defined(_MSC_VER)   /* add by czy */
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "libeq.debug.a")
#       else
#           pragma comment(lib, "libeq.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "libeq.debug.dll.lib")
#       else
#           pragma comment(lib, "libeq.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_libeq_h__) */
