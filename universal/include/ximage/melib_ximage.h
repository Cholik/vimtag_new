/*!
\file       melib_ximage.h
\brief      ximage include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_ximage_h__)
#define __melib_ximage_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "ximage/ximage.h"

#if defined(_MSC_VER)   /* add by czy */
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "ximage.debug.a")
#       else
#           pragma comment(lib, "ximage.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "ximage.debug.dll.lib")
#       else
#           pragma comment(lib, "ximage.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_ximage_h__) */
