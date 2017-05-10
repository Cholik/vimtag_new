/*!
\file       mcore.h
\brief      mcore include file list

 ----history----
\author     dakota
\date       2007-09-10
\version    0.01
\desc       create
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__mcore_h__)
#define __mcore_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1500)
#define _CRT_SECURE_NO_WARNINGS /* disable warning from VS2010 */
#endif

#if defined(_WIN32)
#   include <windows.h>
#   include <winsock.h>
#else
#   include <sys/types.h>
#   include <fcntl.h>
#endif
    
#include <stdio.h>
#include <stdlib.h>
#ifdef WINCE
    #define strerror(a) "error"
    #define errno GetLastError()
#else
    #include <errno.h>
#endif
#include <stdarg.h>
#include <string.h>
#include <time.h>
#include <assert.h>
#include <string.h>

#ifndef _MPRINTF_DEBUG_DISABLE
#define  _mprintf_debug_enable
#endif
#include "mcore/print_utils.h"
/* #define  _mmem_debug_enable */
#include "mcore/mem_debug.h"

#include "mcore/avl.h"
#include "mcore/ascii.h"
#include "mcore/base64.h"
#include "mcore/bpnn.h"
#include "mcore/buffer.h"
#include "mcore/component.h"
#include "mcore/depository.h"
#include "mcore/dir.h"
#include "mcore/event.h"
#include "mcore/file.h"
#include "mcore/fsm.h"
#include "mcore/handle.h"
#include "mcore/hash_table.h"
#include "mcore/html.h"
#include "mcore/http.h"
#include "mcore/http_param.h"
#include "mcore/increase_buffer.h"
#include "mcore/img_file.h"
#include "mcore/json.h"
#include "mcore/lock.h"
#include "mcore/macro_list.h"
#include "mcore/mime.h"
#include "mcore/net_ex.h"
#include "mcore/pack.h"
#include "mcore/qsort_ex.h"
#include "mcore/query_parse.h"
#include "mcore/share_lib.h"
#include "mcore/share_memory.h"
#include "mcore/string_ex.h"
#include "mcore/str_num.h"
#include "mcore/table.h"
#include "mcore/time_ex.h"
#include "mcore/timer_ex.h"
#include "mcore/md5_ex.h"
#include "mcore/thread.h"
#include "mcore/url.h"
#include "mcore/words.h"
#include "mcore/xml.h"
#include "mcore/utf8.h"
#include "mcore/extract_name.h"
#include "mcore/extract_keyline.h"
#include "mcore/extract_fields.h"
#include "mcore/extract_price.h"
#include "mcore/crc.h"
#include "mcore/sha256.h"
#include "mcore/gzip_file.h"
#include "mcore/speed_statistic.h"
#include "mcore/wave_file.h"

#if !defined(NULL)
#   define NULL ((void*)0)
#endif

#if defined(_MSC_VER) /* !for VC */
#   if !defined(inline)
#       define inline  __forceinline 
#   endif
#endif

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "mcore.debug.a")
#       else
#           pragma comment(lib, "mcore.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "mcore.debug.dll.lib")
#       else
#           pragma comment(lib, "mcore.dll.lib")
#       endif
#   endif
#endif


#endif /* !defined(__mcore_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

