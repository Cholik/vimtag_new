/*!
\file       melib_libavcodec.h
\brief      libavcodec include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_libavcodec_h__)
#define __melib_libavcodec_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(WINCE)
#   include <stdint.h>
#endif
#pragma pack(push, 8)
#include "libavcodec/avcodec.h"
#pragma pack(pop)

#if defined(_MSC_VER)
    #ifdef WINCE
        #pragma comment(lib, "libavcodec_wm.lib")
    #else
        #if defined(_LIB)
            #pragma comment(lib, "libavcodec.a")
        #else
            #pragma comment(lib, "libavcodec.dll.a")
        #endif
    #endif
#endif

#endif /* __libavcodec_h__ */

