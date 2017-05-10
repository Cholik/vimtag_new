/*!
\file       melib_lzma.h
\brief      lzma include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_lzma_h__)
#define __melib_lzma_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "LzmaLib.h"

#if defined(_MSC_VER)   /* add by czy */
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "lzma.debug.a")
#       else
#           pragma comment(lib, "lzma.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "lzma.debug.dll.lib")
#       else
#           pragma comment(lib, "lzma.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_lzma_h__) */
