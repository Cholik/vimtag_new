/*!
\file       melib_libhelixaacdec.h
\brief      libhelixaacdec include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_libhelixaacdec_h__)
#define __melib_libhelixaacdec_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#define HELIX_CONFIG_AAC_GENERATE_TRIGTABS_FLOAT
#include "aacdec.h"

#if defined(_MSC_VER)   /* add by czy */
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "libhelixaacdec.debug.a")
#       else
#           pragma comment(lib, "libhelixaacdec.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "libhelixaacdec.debug.dll.lib")
#       else
#           pragma comment(lib, "libhelixaacdec.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_libhelixaacdec_h__) */

