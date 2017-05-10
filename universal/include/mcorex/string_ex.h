/*
\file		string_ex.h
\brief		string extendition function unit
 ----history----
\author     chengzhiyong
\date       2007-05-22
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: str_num.h,v 1.1.1.1 2007-11-25 15:09:18 chengzhiyong Exp $
*/
#if !defined(__string_ex_h__)
#define  __string_ex_h__

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(_MSC_VER) && !defined(strcasecmp)
#   define strcasecmp   _stricmp
#   define strncasecmp  _strnicmp
#endif

#if defined(_MSC_VER) && !defined(snprintf)
#   define snprintf     _snprintf
#endif
#if defined(_MSC_VER) && !defined(vsnprintf)
#   define vsnprintf    _vsnprintf
#endif

#if defined(__rtthread__) && !defined(sprintf)
#   define sprintf     rt_sprintf
#endif
#if defined(__rtthread__) && !defined(snprintf)
#   define snprintf    rt_snprintf
#endif

#if !defined(__len_str_defined)
#   define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */

#define len_str_def(_str) (_str)->len, (_str)->data
#define len_str_def_const(_const_str) (sizeof(_const_str) - 1), (char*)(_const_str)
#define len_str_def_data(_data) sizeof(_data), (char*)&(_data)
#define len_str_set(_str, _src_str)   do{(_str)->len = (_src_str)->len; (_str)->data = (_src_str)->data; }while(0)
#define len_str_set_const(_str, _const_str)   do{(_str)->len = sizeof(_const_str) - 1; (_str)->data = _const_str; }while(0)
#define len_str_set_str(_len_str, _str) do{ (_len_str)->len = (_str)?strlen(_str):0; (_len_str)->data = (_str); }while(0)
#define len_str_cmp(_str1, _str2) (int)(((_str1)->len != (_str2)->len)?((_str1)->len - (_str2)->len):memcmp((_str1)->data, (_str2)->data, (_str1)->len))
#define len_str_cmp_const(_str, _const_str) (((_str)->len != (sizeof(_const_str)-1))?((_str)->len - (sizeof(_const_str)-1)):memcmp((_str)->data, (_const_str), sizeof(_const_str) - 1))
#define len_str_casecmp(_str1, _str2) (((_str1)->len != (_str2)->len)?((_str1)->len - (_str2)->len):strncasecmp((_str1)->data, (_str2)->data, (_str1)->len))
#define len_str_casecmp_const(_str, _const_str) (((_str)->len != (sizeof(_const_str)-1))?((_str)->len - (sizeof(_const_str)-1)):strncasecmp((_str)->data, (_const_str), sizeof(_const_str) - 1))
#define len_str_begin(_str1, _str2) (((_str1)->len < (_str2)->len)||memcmp((_str1)->data, (_str2)->data, (_str2)->len))
#define len_str_begin_const(_str, _const_str) (((_str)->len < (sizeof(_const_str)-1))||memcmp((_str)->data, (_const_str), sizeof(_const_str) - 1))
#define len_str_case_begin(_str1, _str2) (((_str1)->len < (_str2)->len)||strncasecmp((_str1)->data, (_str2)->data, (_str2)->len))
#define len_str_case_begin_const(_str, _const_str) (((_str)->len < (sizeof(_const_str)-1))||strncasecmp((_str)->data, (_const_str), sizeof(_const_str) - 1))
#define len_str_end(_str1, _str2) (((_str1)->len < (_str2)->len)||memcmp((_str1)->data + (_str1)->len - (_str2)->len, (_str2)->data, (_str2)->len))
#define len_str_end_const(_str, _const_str) (((_str)->len < (sizeof(_const_str)-1))||memcmp((_str)->data + (_str)->len - (sizeof(_const_str)-1), (_const_str), sizeof(_const_str) - 1))
#define len_str_case_end(_str1, _str2) (((_str1)->len < (_str2)->len)||strncasecmp((_str1)->data + (_str1)->len - (_str2)->len, (_str2)->data, (_str2)->len))
#define len_str_case_end_const(_str, _const_str) (((_str)->len < (sizeof(_const_str)-1))||strncasecmp((_str)->data + (_str)->len - (sizeof(_const_str)-1), (_const_str), sizeof(_const_str) - 1))

#define len_str_format_s            "%p{%ld[%*.*s%s]}"
#define len_str_format(_len_str)    (_len_str), (long)((_len_str)?(_len_str)->len:0), 0, ((_len_str) && (_len_str)->data)?(((_len_str)->len>64)?64:(int)(_len_str)->len):0, \
                                     (_len_str)?(_len_str)->data:NULL, ((_len_str) && ((_len_str)->len>64))?"...":""

/*!
func    len_str_create
\brief  create length string, use len_str_destroy to free resource
\param  str[in]                 the string, if NULL will fill by '\0'
\param  len[in]                 the length, if 0 will create "" string
\return the media string 
        #NULL                   failed
        #other                  the media string
*/
struct len_str *len_str_create(char *str, unsigned long len);
#define len_str_create_from_const(_const_str) len_str_create((_const_str), sizeof(_const_str) - 1)
#define len_str_create_from_str(_str) len_str_create((_str), (_str)?strlen(_str):0)
#define len_str_create_from_len_str(_len_str) len_str_create((_len_str)?(_len_str)->data:NULL, (_len_str)?(_len_str)->len:0)

/*!
func    len_str_destroy
\brief  destroy media string
\param  str[in]                 the string try to destroy, must be return by len_str_create***
\return the result
        #0                      succeed
        #other                  failed
*/
long len_str_destroy(struct len_str *str);

/*!
func    len_str_dup_str
\brief  dup(copy) media string from string, must use len_str_clear to free resource
        if exist string data will be free
        after use, plz use len_str_clear to free memory alloc in this function,
        !!dont't used to data be alloc from other function, just allow NULl or len_str_dup_xxxx
\param  dst[in/out]             the dest media string, will malloc() and save data into
\param  str[in]                 the src string
\return result
        #0                      succeed
        #other                  failed
*/
long len_str_dup_str(struct len_str *dst, char *str); 

/*!
func    len_str_dup
\brief  copy media string from media string, must use len_str_clear to free resource
        !!dont't used to data be alloc from other function, just allow NULL or len_str_dup_xxxx
\param  dst[in]                 the dest media string, if data be alloced, will be free.
\param  len[in]                 the string length, can be zero
\param  src[in]                 the src media string, can be NULL or empty string, will malloc(len)
\return result
        #0                      succeed
        #other                  failed
*/
long len_str_dup(struct len_str *dst, unsigned long len, char *str); 
#define len_str_dup_len_str(_dst, _len_str) len_str_dup(_dst, (_len_str)?(_len_str)->len:0, (_len_str)?(_len_str)->data:NULL)

/*!
func    len_str_clear
\brief  destroy media string, just for len_str_dup_xxxxx
\param  str[in]                the media string
\return the result
        #0                      succeed
        #other                  failed
*/
long len_str_clear(struct len_str *str); 

#if !defined(WIN32)
char *strlwr(char *str); 
#endif

#ifdef _WIN32
char *unicode_str_create( char *ansi_name );
long unicode_str_free( char *unicode_name );
char *ansi_str_create( char *unicode_name );
long ansi_str_free( char *ansi_name );
#endif


#if defined(__cplusplus)
}
#endif

#endif /* !defined(__string_ex_h__) */
