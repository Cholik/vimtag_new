/*!
\file       melib_libx264.h
\brief      libx264 include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_libx264_h__)
#define __melib_libx264_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#pragma pack(push, 8)
#include "x264.h"
#pragma pack(pop)

#ifdef WINCE
#else
#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "libx264.a")
#           pragma comment(lib, "libmingwex.a")
#           pragma comment(lib, "libgcc.a")
#       else
#           pragma comment(lib, "libx264.a")
#           pragma comment(lib, "libmingwex.a")
#           pragma comment(lib, "libgcc.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "libx264-115.lib")
#		else
#           pragma comment(lib, "libx264-115.lib")
#		endif
#   endif
#endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_libx264_h__) */

