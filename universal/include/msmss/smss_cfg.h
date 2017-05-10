/*!
\file       smss_cfg.h
\brief     Defination for the runing time of the this moudle 

 ----history----
\author     Liuzp
\date       2014-02-25
\version    0.01
\desc       create

*/
#if !defined(__smss_cfg_h__)
#define __smss_cfg_h__
    
#if defined(__cplusplus)
    extern "C" {
#endif/* defined(__cplusplus) */

#include <string.h>

#if !defined(mcore_inner)
#   include "mcore/mcore.h"
#else
#   define mtime2s(x) "999"
#   define time2s(x)  ""
#   include "print_utils.h"
#endif

#define smss_memcp  memcpy
#define smss_memset memset

#if !defined(i64_format_s)
#if defined(_MSC_VER)
#   define newline_s            "\r\n"
#   define i64_format_s         "%I64d"
#   define u64_format_s         "%I64u"
#else
#   define newline_s            "\n"
#   define i64_format_s         "%lld"
#   define u64_format_s         "%llu"
#endif
#endif

#if !defined(print_log0)
#   define print_log0(level, fmt)  printf(fmt##"\n\r")
#   define print_log1(level, fmt, a)  printf(fmt##"\n\r",a)
#   define print_log2(level, fmt, a ,b)  printf(fmt##"\n\r",a ,b)
#   define print_log3(level, fmt, a, b ,c)  printf(fmt##"\n\r", a, b ,c)
#   define print_log4(level, fmt, a, b, c, d)  printf(fmt##"\n\r",a, b, c, d)
#   define print_log5(level, fmt, a, b, c, d, e)  printf(fmt##"\n\r", a, b, c, d, e)

#   define print_err   printf
#   define print_warn  printf
#   define print_tag   printf
#   define print_info  printf
#   define print_debug printf
#   define print_detail printf

#endif

/*\brief: the buffer length will be used when format
*/
#define DATA_ERASE_BUFF_LEN   (1024 * 1024)

#if defined(__cplusplus)
    }
#endif/* defined(__cplusplus) */

#endif  /*!> __smss_cfg_h__*/


