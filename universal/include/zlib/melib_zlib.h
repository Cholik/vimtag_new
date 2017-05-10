/*!
\file       melib_zlib.h
\brief      zlib include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_zlib_h__)
#define __melib_zlib_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "zlib.h"

#if defined(_MSC_VER)   /* add by czy */
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "zlib.debug.a")
#       else
#           pragma comment(lib, "zlib.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "zlib.debug.dll.lib")
#       else
#           pragma comment(lib, "zlib.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_zlib_h__) */
