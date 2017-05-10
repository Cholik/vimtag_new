/*!
\file       http.h
\brief      http unit

 ----history----
\author     chengzhiyong
\date       2007-03-16
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: http.h,v 1.14 2008-09-02 08:27:27 chengzhiyong Exp $
*/
#if !defined(__http_h__)
#define __http_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__len_str_defined)
#define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */
    
/*! \brief http field */
#if !defined(__http_msg_header_defined)
#define __http_msg_header_defined
typedef struct http_msg_header
{
    struct len_str name;           /*!< name */
    struct len_str value;          /*!< value */
}_http_msg_header;
#endif

/*! \brief http field type, all symbal char must in lower case
if change this, should change http_msg_header_type_str[] */
typedef enum http_msg_header_type
{
    ehmht_start_line,           /*!< start line, start value */
        
    /*------------------general header------------------- */
    ehmht_cache_control,        /*!< cache control */
    ehmht_connection,           /*!< connection */
    ehmht_date,                 /*!< date */
    ehmht_pragma,               /*!< pragma */
    ehmht_trailer,              /*!< trailer */
    ehmht_transfer_encoding,    /*!< transfer encoding */
    ehmht_upgrade,              /*!< upgrade */
    ehmht_via,                  /*!< via */
    ehmht_warning,              /*!< warning */
    /*------------------general header------------------- */

    /*------------------request header------------------- */
    ehmht_accept,               /*!< accept */
    ehmht_accept_charset,       /*!< accept charset */
    ehmht_accept_encoding,      /*!< accept encoding */
    ehmht_accept_lanuage,       /*!< accept language */
    ehmht_authorization,        /*!< authorization */
    ehmht_expect,               /*!< expect */
    ehmht_from,                 /*!< from */
    ehmht_host,                 /*!< host */
    ehmht_if_match,             /*!< if match */
    
    ehmht_if_modified_since,    /*!< if modified since */
    ehmht_if_none_match,        /*!< if none match */
    ehmht_if_range,             /*!< if range */
    ehmht_if_unmodified_since,  /*!< if unmodified since */
    ehmht_max_forwards,         /*!< max forwards */
    ehmht_proxy_authorization,  /*!< proxy authorization */
    ehmht_range,                /*!< range */
    ehmht_referer,              /*!< referer */
    ehmht_te,                   /*!< te */
    ehmht_user_agent,           /*!< user angent */
    /*------------------request header------------------- */

    /*------------------response header------------------ */
    ehmht_accpet_range,         /*!< accept range */
    ehmht_age,                  /*!< age */
    ehmht_etag,                 /*!< etag */
    ehmht_location,             /*!< location */
    ehmht_proxy_authenticate,   /*!< proxy authenticate */
    
    ehmht_retry_after,          /*!< retry after */
    ehmht_server,               /*!< server */
    ehmht_vary,                 /*!< vary */
    ehmht_www_authenticate,     /*!< www authenticate */
    /*------------------response header------------------ */

    /*------------------entity header-------------------- */
    ehmht_allow,                /*!< allow */
    ehmht_content_encoding,     /*!< content encoding */
    ehmht_content_language,     /*!< content language */
    ehmht_content_length,       /*!< content length */
    ehmht_content_location,     /*!< content location */
    ehmht_content_md5,          /*!< content md5 */
    ehmht_content_range,        /*!< content range */
    ehmht_content_type,         /*!< content type */
    ehmht_expires,              /*!< expires */
    ehmht_last_modified,        /*!< last modified */
    ehmht_extension_header,     /*!< extension header */
    /*------------------entity header-------------------- */

    /*------------------cookie header-------------------- */
    ehmht_cookie,               /*!< cookie */
    ehmht_set_cookie,           /*!< set cookie */
    /*------------------cookie header-------------------- */

    /*------------------access via----------------------- */
    ehmht_http_x_forwarded_for,     /*!< remote address pass proxy */
    /*------------------access via----------------------- */

    /*------------------for rtsp------------------------- */
    ehmht_session,
    ehmht_transport,
    ehmht_rtp_info,
    ehmht_cseq,
    ehmht_public,
    ehmht_x_sessioncookie,          /*!< apple quick time */
    ehmht_method,                   /*!< by mining method */
    ehmht_params,                   /*!< by mining params */
    /*------------------for rtsp------------------------- */

    ehmht_max_known_header          /*!< max known header counts */
}_http_msg_header_type;

typedef struct http_msg_buf_pos
{
    unsigned long   index;                          /*!< the recv buffer index */
    unsigned long   pos;                            /*!< the recv buffer position in current block */
    unsigned long   total_pos;                      /*!< total position in whole buffer list */
}_http_msg_buf_pos;

/*!< define max entity counts */
#define http_msg_header_max_counts           64
#define http_msg_magic              (*(long*)"http    ")
/*! \brief http request */
typedef struct http_msg
{
    char                            magic[sizeof(long)];            /*!< http header magic */

    unsigned long                   finished;                       /*!< is finished */
    struct  
    {
        unsigned long               is_rsp;                         /*!< is response */
        unsigned long               finished;                       /*!< header finished */

        struct  
        {
            struct len_str          text;                           /*!< first header line */
            union
            {
                struct{
                    struct len_str  method;                         /*!< method */
                    struct len_str  full_uri;                       /*!< full uri, include ext type */
                    struct len_str  uri;                            /*!< uri, not include ext type */
                    struct len_str  ext_type;                       /*!< ext type, ".htm, .js" */
                    struct len_str  query_str;                      /*!< query string */
                    struct len_str  version;                        /*!< http version */
                }req;
                struct  
                {
                    struct len_str  version;                        /*!< http version */
                    struct len_str  info;                           /*!< status code */
                    struct len_str  code;                           /*!< reason phrase */
                    unsigned long   code_value;                          /*!< status value*/
                }rsp;
            }desc;
        }start_line;
        
        unsigned long               counts;                         /*!< fields counts */
        struct http_msg_header  list[http_msg_header_max_counts];   /*!< field list */
        unsigned long               known[ehmht_max_known_header];   /*!< known fields, value index in fields[], if 0 means not exists */
        unsigned long               content_length;                 /*!< content length in fields */
    }headers;    

    struct                                                          /*!< recv buffer refer data */
    {        
        struct len_str              list[0x10];                     /*!< list buffers, alloc in http unit */
        unsigned long               total_size;                     /*!< list valid buffer total size */
        struct  
        {
            struct http_msg_buf_pos write, read;                    /* write/read position */
            unsigned long           his_len;                        /*!< total received history length */
        }raw;

        /* transfer refer */
        struct  
        {
            struct http_msg_buf_pos base, start;                    /*!< base:empty line, start:content start, after base-line */

            struct http_msg_buf_pos write, read;                    /*!< write/read position */
            unsigned long           his_len;                        /*!< total received history length */

            struct  
            {/* for chunked transfer encoding runtime data */
                unsigned long       status;                         /*!< transfer chunked status */
                unsigned long       size;                           /*!< transfer chunked data size */
                unsigned long       len;                            /*!< transfer chunked data received data length */
            }chunked;

            struct
            {/* sprintf(&path[format_index], format?format:"%ld", id?((*id)++)):([start-0]++) --> path */
                unsigned long       ref_dup;                        /*!< path and format is dup */
                struct len_str      path;                           /*!< save path */
                long                format_index;                   /*!< format index in path */
                unsigned long       *id;                            /*!< file name id counter */

                struct
                {
                    unsigned long   counts;
                    struct len_str  *list;
                }files;                                             /*!< file name counts */

                struct len_str      boundary;                       /*!< boundary */
                unsigned long       boundary_matched_len;           /*!< boundary line length */

                struct http_msg_buf_pos line;
                struct http_msg_buf_pos line_end;

                struct http_msg_buf_pos lock;                           /*!< content lock start base position */
                struct http_msg_buf_pos out;                            /*!< out position, file write arrived here */

                unsigned long       is_file;                        /*!< is file */
                unsigned long       status;                         /*!< file exchange status */
                void                *fp;                            /*!< FILE struct */
            }file_exchange;
        }content;
    }buf;
}_http_msg;
#define http_msg_format_s           "%p{%0.4s}"
#define http_msg_format(_hmsg)       (_hmsg), (_hmsg)?&(_hmsg)->magic:0
#define http_msg_get_known_header(_hmsg, _header_type) (  (NULL != (_hmsg)) \
                                                    &&(((_header_type) < ehmht_max_known_header) \
                                                    && (_hmsg)->headers.known[(_header_type)])?\
                                                        &(_hmsg)->headers.list[(_hmsg)->headers.known[(_header_type)]].value:\
                                                        (struct len_str*)NULL)
#define http_msg_get_header_content_length(_hmsg)           ((_hmsg)->headers.content_length)
#define http_msg_set_header_content_length(_hmsg, _value)   ((_hmsg)->headers.content_length) = (_value)
#define http_msg_get_content_len(_hmsg)          ((_hmsg)->buf.content.write.total_pos - (_hmsg)->buf.content.start.total_pos)
#define http_msg_get_total_len(_hmsg)            (_hmsg)->buf.raw.write.total_pos
#define http_msg_get_remained_data_len(_hmsg)    ((_hmsg)->buf.raw.write.total_pos - (_hmsg)->buf.raw.read.total_pos)
#define http_msg_get_file_exchange_counts(_hmsg) (_hmsg)->buf.content.file_exchange.files.counts
#define http_msg_get_file_exchange_list(_hmsg)   (_hmsg)->buf.content.file_exchange.files.list /* return struct len_str * */
#define http_msg_get_chunked_status(_hmsg)       (_hmsg)->buf.content.chunked.status
#define http_msg_get_headers_len(_hmsg)          (_hmsg)->buf.content.start.total_pos
#define http_msg_finished(_hmsg)                 (_hmsg)->finished
#define http_msg_header_finished(_hmsg)          (_hmsg)->headers.finished
#define http_msg_is_rsp(_hmsg)                   (_hmsg)->headers.is_rsp
#define http_msg_is_req(_hmsg)                   (0 == (_hmsg)->headers.is_rsp)
#define http_msg_get_full_uri(_hmsg)             &(_hmsg)->headers.start_line.desc.req.full_uri
#define http_msg_get_req_method(_hmsg)           &(_hmsg)->headers.start_line.desc.req.method
#define http_msg_get_req_version(_hmsg)          &(_hmsg)->headers.start_line.desc.req.version
#define http_msg_get_rsp_version(_hmsg)          &(_hmsg)->headers.start_line.desc.rsp.version
#define http_msg_get_rsp_code_value(_hmsg)       (_hmsg)->headers.start_line.desc.rsp.code_value

typedef struct http_msg_params
{
    struct  
    {
        unsigned long                   file_exchange:1,
                                        file_exchange_path_none_dup:1,
                                        file_exchange_path_format:1,
                                        reserved:29;
    }flag;
    struct  
    {/* sprintf(&path[format_index], format?format:"%ld", id?((*id)++)):([start-0]++) --> path */
        struct len_str                  path;           /* if flags:file_exchange_format need format */
        unsigned long                   *id;            /* if NULL will inc from zero with whole module. */
    }file_exchange;
}_http_msg_params;
#define http_msg_params_format_s         "%p{[%s %*.*s]}"
#define http_msg_params_format(_params)  (_params), ((_params) && (_params)->flag.file_exchange)?"file_exchange,":"", \
                                         0, (int)((_params)?(_params)->file_exchange.path.len:0), \
                                         (_params)?(_params)->file_exchange.path.data:NULL


/*!
func    http_msg_create
\brief  create http message
\param  old[in]                 the older header, can be NULL
                                if NULL ignore
                                if not NULL get remained data
\param  params[in]              params, can be NULL, if NULL ignore,
                                #NULL: call http_ctrl to set later
\return the http message
        #NULL                   failed
        #other                  the header
*/
struct http_msg *http_msg_create(struct http_msg *old, struct http_msg_params *params);

/*!
func    http_msg_destroy
\brief  destroy http message
\param  hmsg[in]                the http message
\return destroy result
        #0                      succeed
        #other                  error code
*/
long http_msg_destroy(struct http_msg *hmsg);

/*!
func    http_msg_buf_prepare
\brief  http prepare buffer used to append data
\param  hmsg[in]                the http message
\param  size[out]               output the recv buffer size, just return first block
\return the buffer start pointer
        #NULL                   failed
        #other                  the buffer start pointer
*/
void *http_msg_buf_prepare(struct http_msg *hmsg, unsigned long *size);

/*!
func    http_append
\brief  append and parse data in receive buffer
\param  hmsg[in]                the http message
\param  len[in]                 append data length, should be the received data length,
                                can be zero, can used to test is finished
\return parse result
        #0                      succeed
        #<0                     error code
        #>0                     data not enough, still need recv data
*/
long http_msg_append(struct http_msg *hmsg, unsigned long len);

/*!
func    http_msg_ctrl
\brief  ctrl http header
\param  hmsg[in]                the http message
\param  params[in]              the ctrl params
\return ctrl result
        #0                      succeed
        #<0                     error code
*/
long http_msg_ctrl(struct http_msg *hmsg, struct http_msg_params *params);

/*!
func    http_msg_get_content
\brief  get content
\param  hmsg[in]                the http message
\param  buf[out]                the buffer will be used to save content,
                                size at least be header->buf.content.len
\return get result
        #<0                     error code
        #other                  content length
*/
long http_msg_get_content(struct http_msg *hmsg, unsigned long buf_size, char *buf);

long http_msg_test_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__http_h__) */

