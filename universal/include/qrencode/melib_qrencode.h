/*!
\file       melib_qrencode.h
\brief      qrcode encoder include header by mining

 ----history----
\author     chengzhiyong
\date       2016-09-12
\version    0.01
\desc       create
*/
#if !defined(__melib_qrencode_h__)
#define __melib_qrencode_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "qrencode.h"

#if defined(_MSC_VER)   /* add by czy */
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "qrencode.debug.a")
#       else
#           pragma comment(lib, "qrencode.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "qrencode.debug.dll.lib")
#       else
#           pragma comment(lib, "qrencode.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_qrencode_h__) */
