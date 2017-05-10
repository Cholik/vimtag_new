/*!
\file       melib_nodejs.h
\brief      nodejs library unit header

 ----history----
\author     chengzhiyong
\date       2015-06-21
\version    0.01
\desc       create
*/
#if !defined(__melib_nodejs_h__)
#define __melib_nodejs_h__

#if 0   /* will cause error with template */
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */
#endif

#include "nodejs/node.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "node.debug.lib")
#       else
#           pragma comment(lib, "node.lib")
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "node.debug.lib")
#       else
#           pragma comment(lib, "node.lib")
#       endif
#   endif
#endif

#if 0   /* will cause error with template */
#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
#endif

#endif /* !defined(__melib_nodejs_h__) */

