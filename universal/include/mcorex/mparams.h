/*!
\file       mparams.h
\brief      params unit
 ----history----
\author     chengzhiyong
\date       2009-09-19
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: media_channel.h,v 1.20 2009-09-19 01:46:28 chengzhiyong Exp $
*/
#if !defined(__mparams_h__)
#define __mparams_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct len_str;
#if !defined(__len_str_defined)
#   define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */

#define mparams_type_multi_lines        0
#define mparams_type_single_line        1
#define mparams_type_multi_lines_misc   2
/* mparams_type_multi_lines: multi lines: xxx = xxx\r\nyyy=yyy
   mparams_type_single_line: single lines: xxx=xxx,xxx=yyy
        NEW-LINE: \n
        ENTER: \r
        TAB: \t
        ZERO: \0
        OTHER: \x[HEX][HEX] 
            SPACE: \x20
*/
/* mparams_type_multi_lines_misc media-channels params.
    multi lines misc: xxx = xxx\r\nyyy=yyy
        SPACE: \s
        NEW-LINE: \n
        ENTER: \r
        TAB: \t
        ZERO: \0
        */
/*!
func    mparams_create
\brief  create media params, after use call mparams_detroy to free resource
\param  len[in]                 the text length
\param  text[in]                should be output by mparams_encode, can be NULL
\param  type[in]                the type, ref mparams_type_xxx
\brief  create media params
\return the media params
        #NULL                   failed
        #other                  the media params
*/
struct mparams *mparams_create(unsigned long len, char *text, unsigned long type);

/*!
func    mparams_dup
\brief  dup media params from a exist media params, same as mparams_create 
        should call mparams_destroy after use
\param  prams[in]               the src media params, can be NULL
                                if NULL create a empty params
\brief  create media params
\return the media params
        #NULL                   failed
        #other                  the media params
*/
struct mparams *mparams_dup(struct mparams *params);

/*!
func    mparams_encode
\brief  encode media params to desc text
\param  params[in]              the media channel create parameters
\param  buf[in]                 the buffer
\param  size[in]                the buffer size.
\param  type[in]                the type, ref mparams_type_xxx
\return encode result
        #>0                     the size
        #other                  the error code
*/
long mparams_encode(struct mparams *params, unsigned char *buf, unsigned long size, unsigned long type);

/*!
func    mparams_set
\brief  set media param
\param  params[in]              the media channel create parameters
\param  key_len[in]             the param name length
\param  key[in]                 the param name
\param  value_len[in]           the value string length, if 0 means delete
\param  value[in]               the param value, if NULL means delete
\return the result
        #0                      succeed
        #other                  the error code
*/
long mparams_set(struct mparams *params, unsigned long key_len, char *key, unsigned long value_len, char *value);

/*!
func    mparams_get
\brief  get media param
\param  params[in]              the media channel create parameters
\param  key_len[in]             the param name length
\param  key[in]                 the param 
\return the value
        #NULL                   not found
        #other                  the value string
*/
struct len_str  *mparams_get(struct mparams *params, unsigned long key_len, char *key);

/*!
func    mparams_set_int
\brief  set media integer param
\param  params[in]              the media channel create parameters
\param  key_len[in]             the param name length
\param  key[in]                 the param name
\param  value[in]               the param value
\return the result
        #0                      succeed
        #other                  the error code
*/
long mparams_set_int(struct mparams *params,  unsigned long key_len, char *key, long value);

/*!
func    mparams_get_int
\brief  get integer param
\param  params[in]              the media channel create parameters
\param  key_len[in]             the param name length
\param  key[in]                 the param key
\param  default_value[in]       if not exist return default value
\return the result
*/
long mparams_get_int(struct mparams *params, unsigned long key_len, char *key, long default_value);

/*!
func    mparams_destroy
\brief  destroy media params
\param  params[in]              the media channel create parameters
\return the result
        #0                      succeed
        #other                  the error code
*/
long mparams_destroy(struct mparams *params);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mparams_h__) */

