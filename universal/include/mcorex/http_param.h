/*!
\file       http_param.h
\brief      http param unit, parse http param from http request,
            support GET/POST(multipart/form-data | application/x-www-form-urlencoded)

 ----history----
\author     chengzhiyong
\date       2008-05-30
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: http_param.h,v 1.2 2008-05-30 08:30:00 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__http_param_h__)
#define __http_param_h__

#define http_param_flag_type_mask               0x03
#define http_param_flag_type_auto_check         0x00
#if !defined(http_param_flag_type_header)
#define http_param_flag_type_header             0x01   /* header params */
#define http_param_flag_type_data               0x02   /* data params */
#endif

#define http_param_flag_separat_mask            0x18
#define http_param_flag_separat_char_amp        0x00    /* '&' is separated char, normal post */
#define http_param_flag_separat_char_semicolon  0x08    /* ';' is separated char, cookie */
#define http_param_flag_separat_char_sub        0x10    /* '-' is separated char, mining static hack */

#define http_param_flag_encode_mask             0x60
#define http_param_flag_encode_normal           0x00    /* is '+' and "%xx" encode, default */
#define http_param_flag_encode_mining           0x20    /* is '+' and "%xx" and "_xx" encode */
#define http_param_flag_encode_none             0x40    /* not encode, raw data */

#if !defined(__len_str_defined)
#define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */
    
#if !defined(__http_param_defined)
#define __http_param_defined
/*! \brief http field */
typedef struct http_param
{
    struct http_param       *next;          /*!< next param */
    struct http_param       *prev;          /*!< prev param */
    unsigned long           type;           /*!< type */
    struct len_str          name;           /*!< name */
    struct len_str          value;          /*!< value */
}_http_param;
#endif /* !defined(__http_param_defined) */

/*!
func    http_param_decode_str
\brief  decode param string, such as %30:'0'
\param  param[in]               the params string
\param  buf_size[in]            the buffer size
\param  buf[out]                the buffer
\param  flag[in]                refer http_param_flag_encode_xxx
\return decoded data size
        #<0                     error code
        #other                  the decoded data length
*/
long http_param_decode_str(struct len_str *param, unsigned long buf_size, char *buf, unsigned long flag);

/*!
func    http_param_add_line
\brief  append line into params, such as cookie, query-string
\param  params[in/out]          the http params, if(NULL == *params) will output new root
                                after use call http_param_destroy(*params) to free resource
\param  line[in]                the line content
\param  flag[in]                refer http_param_flag_xxx
\return parse result
        #0                      succeed
        #other                  error code
*/
long http_param_add_line(struct http_param **params, struct len_str *line, unsigned long flag);

/*!
func    http_param_add_block
\brief  append block into params, such as post-form-content or file-form-content
\param  params[in/out]          the http params, if(NULL == *params) will output new root
                                after use call http_param_destroy(*params) to free resource
\param  content_type[in]        the content type
\param  content[in]             the content
\param  flag[in]                refer http_param_flag_xxx
\return parse result
        #0                      succeed
        #other                  error code
*/
long http_param_add_block(struct http_param **params, struct len_str *content_type, struct len_str *content, unsigned long flag);

/*!
func    http_param_add
\brief  add http param by name
\param  params[in/out]          the http param root, if(NULL == *params) will create new one and output
                                after use call http_param_destroy(*params) to free resource
\param  name[in]                the param name
\param  flag[in]                refer http_param_flag_xxx
\return add result
        #0                      succeed
        #other                  error code
*/
long http_param_add(struct http_param **params, struct len_str *name, struct len_str *value, unsigned long flag);

/*!
func    http_param_destroy
\brief  destroy http param struct
\param  params[in]              the http param
\return destroy result
        #NULL                   failed
        #other                  the http param struct
*/
long http_param_destroy(struct http_param *params);

/*!
func    http_param_get
\brief  get http param by name, ignore char case
\param  params[in]              the http param
\param  name[in]                the param name, ignore char case
\return the param
        #NULL                   not found
        #other                  the param
*/
struct http_param *http_param_get(struct http_param *params, struct len_str *name);


#endif /* !defined(__http_param_h__) */
#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
