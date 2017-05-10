/*!
\file       melib_speex.h
\brief      openssl include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_speex_h__)
#define __melib_speex_h__

#if defined(__cplusplus)
extern "C" {
#endif

#include "speex.h"
#include "speex_preprocess.h"
#include "speex_echo.h"
#include "speex_stereo.h"
#include "speex_header.h"
#include "speex_callbacks.h"
#include "speex_bits.h"
#include "speex_jitter.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "speex.debug.a")
#       else
#           pragma comment(lib, "speex.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "speex.debug.dll.lib")
#		else
#           pragma comment(lib, "speex.dll.lib")
#		endif
#   endif
#endif


#if defined(__cplusplus)
}
#endif

#endif /* __melib_speex_h__ */

