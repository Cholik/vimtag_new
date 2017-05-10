/*!
\file       mdumpf.h
\brief      runtime objects dump print format unit

 ----history----
\author     chengzhiyong
\date       2014-05-31
\version    0.01
\desc       split from print_utils.h::snapshot_printfxxx

*/
#if !defined(__mdumpf_h__)
#define __mdumpf_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */


#include <stdio.h>

#if defined(_MSC_VER) && !defined(snprintf)
#   define snprintf     _snprintf
#endif

/*----------------------mdump-printf-util------------------------------*/
typedef struct mdumpf_ctx
{
    unsigned long   record_start;
    unsigned long   record_counts;
    unsigned long   record_max;
    unsigned long   record_no;

    unsigned long   size;
    unsigned long   len;
    unsigned long   overflow;

    char            *buf;
    void            *fp;
    long            _sub_len;   /* tmp value */
    long            _sub_max;   /* tmp value */
}_mdumpf_ctx;

#define mdumpf_init(_ctx, _filename, _buf, _size, _start, _counts)\
    do{\
        (_ctx)->record_start    = (unsigned long)(_start);\
        (_ctx)->record_counts   = (unsigned long)(_counts);\
        (_ctx)->record_max      = (_ctx)->record_counts?(((_ctx)->record_counts >= (0xffffffff - (_ctx)->record_start))?0xffffffff:((_ctx)->record_start + (_ctx)->record_counts)):((_ctx)->record_start + 0x100);\
        (_ctx)->record_no       = 0;\
        (_ctx)->size            = (size)?(size):(buf?0:0x10000);\
        (_ctx)->len             = 0;\
        (_ctx)->overflow        = 0;\
        (_ctx)->buf             = buf;\
        (_ctx)->fp              = ((_ctx)->buf)?NULL:(((_filename) && (*(_filename)))?fopen((_filename), "wb"):NULL);\
        if(NULL == (_ctx)->fp){ (_ctx)->fp = stdout; };\
    }while(0)

#define mdumpf_uninit(_ctx)\
    do{\
        if((_ctx)->fp && ((_ctx)->fp != stdout))\
        {\
            fclose((FILE*)(_ctx)->fp);\
            (_ctx)->fp = NULL; \
        }\
        if((_ctx)->buf && ((unsigned long)(_ctx)->size < (_ctx)->len))\
        { \
            (_ctx)->buf[(_ctx)->len] = 0;\
        };\
    }while(0)

#define mdumpf(_ctx, _is_record, _filter_express, _format_s, _format) \
    do\
    {\
        if(_filter_express)\
        {\
            if((0 == (_ctx)->overflow) && \
                ((0 == (_is_record)) || ((((_ctx)->record_no >= (_ctx)->record_start) && ((_ctx)->record_no < (_ctx)->record_max)))))\
            {\
                (_ctx)->_sub_max = (_ctx)->size - (_ctx)->len - 1;\
                if((_ctx)->buf)\
                {\
                    (_ctx)->_sub_len = snprintf(&(_ctx)->buf[(_ctx)->len], (_ctx)->_sub_max, _format_s, _format);\
                    if((_ctx)->_sub_max < (_ctx)->_sub_len){ (_ctx)->_sub_len = -1; };\
                }\
                else\
                {\
                    (_ctx)->_sub_len = fprintf((FILE*)(_ctx)->fp, _format_s, _format);\
                }\
                if((0 > (_ctx)->_sub_len) || ((_ctx)->_sub_len > (_ctx)->_sub_max)){ (_ctx)->overflow = 1; };\
                if(0 < (_ctx)->_sub_len){ (_ctx)->len += (_ctx)->_sub_len; }\
            }\
            if(_is_record){ ++(_ctx)->record_no; };\
        }\
    }while(0)

/*----------------------mdump-printf-util------------------------------*/




#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined( __mdumpf_h__) */

