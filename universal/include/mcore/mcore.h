/*!
\file       mcore.h
\brief      mcore include file list

 ----history----
\author     dakota
\date       2007-09-10
\version    0.01
\desc       create
*/
#if !defined(__mcore_h__)
#define __mcore_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(mframework_version_disable)
#   include "mcore/mframework_version.h"
#endif

#if defined(_MSC_VER) && (_MSC_VER >= 1500)
#   define _CRT_SECURE_NO_WARNINGS /* disable warning from VS2010 */
#endif

#if defined(_WIN32)
#   include <windows.h>
#   include <winsock.h>
#elif defined(__ucos__)
#elif defined(__rtthread__)
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
#if defined(__rtthread__)
#   include <rtdef.h>
#else
#   include <stdarg.h>
#endif
#include <string.h>
#include <time.h>
#if !defined(__rtthread__)
#   include <assert.h>
#else
#   define assert(_x) do{if(!(_x)){printf("assert at: %s:%d\r\n", __FILE__, __LINE__);};}while(0)
#endif
#if defined(__rtthread__) && !defined(getenv)
#   define getenv(_a)  (0)
#endif

#if !defined(_mprintf_debug_enable)
#   if !defined(_MPRINTF_DEBUG_DISABLE) || (!_MPRINTF_DEBUG_DISABLE)
#      define  _mprintf_debug_enable    1
#   else
#   endif
#endif

#include "mcore/print_utils.h"
#if !defined(_mmem_debug_enable)
#if 0
#   if ((!defined(_MMEM_DEBUG_DISABLE) || (!_MMEM_DEBUG_DISABLE)) && defined(_DEBUG)) || defined(__gm8135__)
#       define  _mmem_debug_enable      1
#   else
#   endif
#else
#   if (!defined(_MMEM_DEBUG_DISABLE) || (!_MMEM_DEBUG_DISABLE)) && defined(_DEBUG)
#       define  _mmem_debug_enable      1
#   else
#   endif
#endif
#endif
#include "mcore/mmem_debug.h"

#include "mcore/avl.h"
#include "mcore/ascii.h"
#include "mcore/base64.h"
#include "mcore/bpnn.h"
#include "mcore/component.h"
#include "mcore/depository.h"
#include "mcore/dir.h"
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
#include "mcore/macro_list.h"
#include "mcore/mime.h"
#include "mcore/net_ex.h"
#include "mcore/pack.h"
#include "mcore/pack_def.h"
#include "mcore/process.h"
#include "mcore/query_parse.h"
#include "mcore/share_lib.h"
#include "mcore/share_memory.h"
#include "mcore/string_ex.h"
#include "mcore/str_num.h"
#include "mcore/table.h"
#include "mcore/timer_ex.h"
#include "mcore/md5_ex.h"
#include "mcore/url.h"
#include "mcore/words.h"
#include "mcore/xml.h"
#include "mcore/utf8.h"
#include "mcore/extract_name.h"
#include "mcore/extract_keyline.h"
#include "mcore/extract_fields.h"
#include "mcore/extract_price.h"
#include "mcore/sha256.h"
#include "mcore/gzip_file.h"
#include "mcore/speed_statistic.h"
#include "mcore/wave_file.h"
#include "mcore/data_confusion.h"
#include "mcore/tlv.h"

#include "mcore/margs.h"
#include "mcore/mbits.h"
#include "mcore/mbytes.h"
#include "mcore/mcrc.h"
#include "mcore/mdumpf.h"
#include "mcore/mjson.h"
#include "mcore/mlogf.h"
#include "mcore/mparams.h"
#include "mcore/mqsort_ex.h"
#include "mcore/mbuffer.h"
#include "mcore/mtime_ex.h"
#include "mcore/mlock.h"
#include "mcore/mevent.h"
#include "mcore/mthread.h"
#include "mcore/mhash_table.h"
#include "mcore/mserial.h"
#include "mcore/mregx.h"

#include "mcore/manti_interference_coding.h"

#if !defined(NULL)
#   define NULL ((void*)0)
#endif

#if defined(_MSC_VER) /* !for VC */
#   if !defined(inline)
#       define inline  __forceinline 
#   endif
#endif

#if defined(_MSC_VER)
/* get mframework prefix */
#   undef  mlib_mframework_prefix__local
#   if !defined(mlib_mframework_prefix)
#       define mlib_mframework_prefix__local
#       define mlib_mframework_prefix   "mcore"
#   endif
/* comment lib */
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, mlib_mframework_prefix".debug.a")
#       else
#           pragma comment(lib, mlib_mframework_prefix".a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, mlib_mframework_prefix".debug.dll.lib")
#       else
#           pragma comment(lib, mlib_mframework_prefix".dll.lib")
#       endif
#   endif
/* clear flag */
#   if defined(mlib_mframework_prefix__local)
#       undef  mlib_mframework_prefix__local
#       undef  mlib_mframework_prefix
#   endif
#endif  /* defined(_MSC_VER) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mcore_h__) */

