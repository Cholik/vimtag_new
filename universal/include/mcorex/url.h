/*!
\file       url.h
\brief      url parse unit

 ----history----
\author     chengzhiyong
\date       2008-05-23
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: url.h,v 1.3 2008-07-11 10:43:46 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__url_h__)
#define __url_h__

#define url_max_len         2048
#define url_domain_max_len  64
#define url_host_max_len    1024

#if !defined(__len_str_defined)
#define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */

/*! \brief url scheme */
typedef struct url_scheme
{
    struct len_str  protocol;       /*!< protocol, HTTP, FTP, EMAIL, TELNET ... */
    struct len_str  specific_part;  /*!< scheme special part */
    struct len_str  username;       /*!< username */
    struct len_str  password;       /*!< password */
    struct len_str  host;           /*!< host */
    struct len_str  port;           /*!< port */
    unsigned long   port_value;     /*!< port value */
    struct len_str  path;           /*!< resource path, without file name */
    struct len_str  file_name;      /*!< file name */
}_url_scheme;

/*!
func    url_parse
\brief  parse url string
\param  url[in]                 the url string
\param  len[in]                 the url len
\param  scheme[out]             the url scheme, parse result
\return parse result
        #0                      succeed
        #other                  error code
*/
long url_parse(char *url, unsigned len, struct url_scheme *scheme);

/*!
func    url_get_domain
\brief  get domain name from host
\param  host[in]                the host string
\param  host_len[in]            the host string length
\param  country[out]            the country node, such as "cn,jp", if missing output NULL
\param  top[out]                the domain type, such as "net,com,gov", if missing output NULL
\param  domain[out]             domain start pointer
\param  sub[out]                sub domain start pointer, if missing output NULL
\return get domain result
        #0                      succeed
        #other                  error code
*/
long url_get_domain(char *host, unsigned long host_len,
                    char **country, char **top, char **domain, char **sub);

/*!
func    url_is_in_domain
\brief  check url is in special domain
\param  domain[in]              the domain string
\param  domain_len[in]          the domain string length
\param  url[in]                 the check url string
\param  url_len[in]             the check url string length
\return check result
        #0                      url is in this domain
        #other                  error code
*/
long url_is_in_domain(char *domain, unsigned long domain_len,
                      char *url,    unsigned long url_len);

/*!
func    url_encode_param
\brief  encode url param
\param  param[in]               the param string
\param  param_len[in]           the param string length
\param  buf[out]                the output buffer
\param  buf_size[in]            the output buffer size
\return encode result
        #<0                     error code
        #other                  encode result string length
*/
long url_encode_param(char *param,  unsigned long param_len,
                      char *buf,    unsigned long buf_size);

#endif /* !defined(__url_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
    
