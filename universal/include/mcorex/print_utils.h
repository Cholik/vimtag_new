/*!
\file       print_utils.h
\brief      print utils

 ----history----
\author     chengzhiyong
\date       2010-08-30
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: print_utils.h,v 1.114 2008-11-26 05:06:46 chengzhiyong Exp $
*/
#if !defined(__print_utils_h__)
#define __print_utils_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/*-------------------print_ex tool-------------------------------*/
/*
    User module redirect stdout to file through two step:
    step 1. Redefine printf to printf_ex. There have two method to get this goal:
    (1)include printf_ex.h and link mcore lib
    (2)Replace printf in stdio.h like bollow and link mcore lib
**********************************************************
#ifdef PRINTF_EX_ENABLE
    int	 printf_ex(const char *, ...);
    #ifndef printf
    #define printf printf_ex
    #endif
#else
    _CRTIMP int __cdecl printf(const char *, ...);
#endif    
**********************************************************
    step 2. Define a printf file path to "printf_ex" in environment setting. Printf result will be redirected into file like "printf_ex_2010.10.5_15.23.13.txt"
*/
extern int printf_ex(const char *, ...);
extern long printf_ex_init(const char *module_name, long *level);
/* update printf level of special module runtime, module can be part of prefix name,
 if part of name will affect all module name start with it. return matched module counts. */
extern long printf_ex_level_set(char *module_name, long level);

#define print_level_detail  6
#define print_level_debug   5
#define print_level_info    4
#define print_level_tag     3
#define print_level_warn    2
#define print_level_err     1


#if !defined(print_level)
#   if defined(_DEBUG)
#       define print_level      print_level_detail
#   else
#       define print_level      print_level_tag
#   endif
#endif

#if defined(__rtthread__) && !defined(stdout)
#   define stdout           (0)
#endif

#if defined(_mprintf_debug_enable) && _mprintf_debug_enable
#   undef  printf_sys
#   if defined(__linux__) && defined(__KERNEL__)
#       define printf       printk
#   else
#       define printf_sys   printf
#   endif
#   undef  printf
#   if defined(_mprintf_out_hack)/* can hack in ios as #define _mprintf_out_hack    NSLog */
#       define printf      _mprintf_out_hack
#   else
#       define printf      printf_ex
#   endif
#   define printf_ex_init_do(_module, _level)   printf_ex_init(_module, _level)
#else
#   define printf_ex_init_do(_module, _level)
#   if defined(__linux__) && defined(__KERNEL__)
#       define printf   printk
#   endif
#endif

#if !defined(mmodule_name)
#define mmodule_name "unknown"
#endif
#define print_util_init() \
    static long print_level_local = print_level_detail; \
    static long print_level_extern() \
    {\
        static int print_level_inited = 0; \
        if(0 == print_level_inited) \
        {\
            print_level_inited = 1; \
            printf_ex_init_do(mmodule_name, &print_level_local); \
        }\
        return print_level_local; \
    }

print_util_init()
/*-------------------print_ex tool-------------------------------*/


/*-------------------print_log tool------------------------------*/
#if !defined(func_format)
#   define func_format_s   "(%s)"
#   define func_format()   "..."
#endif

#if defined(_MSC_VER)
#   define newline_s            "\r\n"
#   define i64_format_s         "%I64d"
#   define u64_format_s         "%I64u"
#else
#   define newline_s            "\n"
#   define i64_format_s         "%lld"
#   define u64_format_s         "%llu"
#endif
#define u64_format(_u64_value)  (_u64_value)
#define i64_format(_i64_value)  (_i64_value)
#define f64_format(_f64_value)  (_f64_value)
#define fileline_format_s       "%s:%d"
#define fileline_format()       __FILE__, __LINE__
   
#if defined(_mprint_time2s_miss) && _mprint_time2s_miss
#   define mprint_time2s(_t) ""
#else
#   define mprint_time2s(_t) mtime2s(_t)
#endif

#if !defined(print_err)
#   define print_err    if((print_level >= print_level_err)     && (print_level_local >= print_level_err)    && (print_level_extern() >= print_level_err))printf
#   define print_warn   if((print_level >= print_level_warn)    && (print_level_local >= print_level_warn)   && (print_level_extern() >= print_level_warn))printf
#   define print_tag    if((print_level >= print_level_tag)     && (print_level_local >= print_level_tag)    && (print_level_extern() >= print_level_tag))printf
#   define print_info   if((print_level >= print_level_info)    && (print_level_local >= print_level_info)   && (print_level_extern() >= print_level_info))printf
#   define print_debug  if((print_level >= print_level_debug)   && (print_level_local >= print_level_debug)  && (print_level_extern() >= print_level_debug))printf
#   define print_detail if((print_level >= print_level_detail)  && (print_level_local >= print_level_detail) && (print_level_extern() >= print_level_detail))printf
#endif /* !defined(print_err) */

/* _type: err|warn|info|debug|detail */
#if !defined(_mprint_log_hack_prefix)   /* hack for ios, could #define _mprint_log_hack_prefix @ to use NSLog with %@ */
#   define _mprint_log_hack_prefix
#endif
#if !defined(print_log5)
#   define print_log5(_type, _format_s, _p1, _p2, _p3, _p4, _p5)\
        if((print_level_##_type <= print_level) && (print_level_##_type <= print_level_local) && (print_level_##_type <= print_level_extern()))\
            printf(_mprint_log_hack_prefix "[%s] "#_type": " func_format_s" "_format_s " %s:%d" newline_s,\
                   mprint_time2s(0), func_format(), _p1, _p2, _p3, _p4, _p5,__FILE__, __LINE__)
#   define print_log4(_type, _format_s, _p1, _p2, _p3, _p4)\
        if((print_level_##_type <= print_level) && (print_level_##_type <= print_level_local) && (print_level_##_type <= print_level_extern()))\
            printf(_mprint_log_hack_prefix "[%s] "#_type": " func_format_s" "_format_s " %s:%d" newline_s,\
                   mprint_time2s(0), func_format(), _p1, _p2, _p3, _p4, __FILE__, __LINE__)
#   define print_log3(_type, _format_s, _p1, _p2, _p3)\
        if((print_level_##_type <= print_level) && (print_level_##_type <= print_level_local) && (print_level_##_type <= print_level_extern()))\
            printf(_mprint_log_hack_prefix "[%s] "#_type": " func_format_s" "_format_s " %s:%d" newline_s,\
                   mprint_time2s(0), func_format(), _p1, _p2, _p3,__FILE__, __LINE__)
#   define print_log2(_type, _format_s, _p1, _p2)\
        if((print_level_##_type <= print_level) && (print_level_##_type <= print_level_local) && (print_level_##_type <= print_level_extern()))\
            printf(_mprint_log_hack_prefix "[%s] "#_type": " func_format_s" "_format_s " %s:%d" newline_s,\
                   mprint_time2s(0), func_format(), _p1, _p2, __FILE__, __LINE__)
#   define print_log1(_type, _format_s, _p1)\
        if((print_level_##_type <= print_level) && (print_level_##_type <= print_level_local) && (print_level_##_type <= print_level_extern()))\
            printf(_mprint_log_hack_prefix "[%s] "#_type": " func_format_s" "_format_s " %s:%d" newline_s,\
                   mprint_time2s(0), func_format(), _p1, __FILE__, __LINE__)
#   define print_log0(_type, _format_s)\
        if((print_level_##_type <= print_level) && (print_level_##_type <= print_level_local) && (print_level_##_type <= print_level_extern()))\
            printf(_mprint_log_hack_prefix "[%s] "#_type": " func_format_s" "_format_s " %s:%d" newline_s,\
                   mprint_time2s(0), func_format(), __FILE__, __LINE__)
#endif /* func print */
/*-------------------print_log tool------------------------------*/

#define print_debug_begin( _buf, _file, _start, _counts, _size ) \
    char                    *__buf = (_buf), *__file = (_file); \
    unsigned long           __buf_overflow = 0, __size = (_size); \
    long                    __sub_len, __out_len = 0, __out_records = 0, __out_max = (__buf?__size:0); \
    long                    __start = ( _start ), __counts = ( _counts ), __counts_pos = 0; \
    FILE                    *__fp = __buf?NULL:(__file?(FILE*)fopen(__file, "wb"):stdout);

#define print_debug_counts_inc() __counts_pos++

#define print_debug_output(_format_s, _format) \
    do\
    {\
        if(( __counts_pos < __start ) || ( __counts > 0 && __counts_pos >= ( __start + __counts ))){ break; } \
        if(__buf_overflow || ( __buf && __out_len >= __out_max)){ break; } \
        if(__buf) \
        {\
            (__sub_len) = snprintf(&(__buf)[(__out_len)], (__out_max) - (__out_len) - 1, _format_s, _format);\
            if(__sub_len >= (long)((__out_max) - (__out_len))){ __sub_len = -1; };\
            if(0 > __sub_len){ __buf_overflow = 1; };\
        }\
        else\
        {\
            (__sub_len) = fprintf(__fp, _format_s, _format);\
        }\
        if(0 < (__sub_len)){ (__out_len) += (__sub_len); }\
    }while(0)
#define print_debug_end() \
    if(__fp && (__fp != stdout)){ fclose(__fp); }; \
    if(__buf && (__out_len < __out_max)){ __buf[__out_len] = 0; };
    
#define print_debug_check_param() \
    if((__buf && (0 == __out_max))) \
    { \
        if(__fp && (__fp != stdout)){ fclose(__fp); }; \
        print_log0(err, "invalid param."); \
        return -1; \
    } \
    if((NULL == __buf) && __file && (NULL == __fp)) \
    { \
        print_log1(err, "open __file failed with syserr[%s].", strerror(errno)); \
        __fp = stdout; \
    }
    
#define print_debug_get_print_len() (__out_len)

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__print_utils_h__) */
