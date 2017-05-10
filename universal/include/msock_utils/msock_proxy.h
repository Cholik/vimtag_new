/*!
\file       msock_proxy.h
\brief      tcp socket proxy srv, used to analysis and debug network protocol

 ----history----
\author     chengzhiyong
\date       2012-04-29
\version    0.01
\desc       create
*/

#if !defined(__msock_proxy_h__)
#define __msock_proxy_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

struct msock_proxy;

typedef struct msock_proxy_statistic
{
    unsigned long   max_online_counts;  /*!< max history online counts */
    unsigned long   active_counts;      /*!< active connection counts. if NULL ignore */
    unsigned long   disconnect_counts;  /*!< disconnect counts, if NULL ignore */
    unsigned long   exchange_bytes;     /*!< exchange bytes, if NULL ignore */
}_msock_proxy_statistic;

#define msock_proxy_item_type_local          0
#define msock_proxy_item_type_remote         1
#define msock_proxy_item_type_passive_remote 2

typedef struct msock_proxy_item
{
    unsigned long           type;           /*!< msock_proxy_peer_type_xxx */
    struct  
    {
        unsigned long       len;
        char                *data;
    }host, header;                          /*!< host string, header data */
    unsigned long           port;           /*!< port, if ! in[0,-1] ignore */
}_msock_proxy_item;

#define msock_proxy_desc_item_counts 2
typedef struct msock_proxy_desc
{
    struct  
    {
        long                        link_by_id:1,   /*!< is auto link by name, default:0 directly, just for both server mode(local) */
                                    dump_enabled:1, /*!< dump file log, default:0 don't dump */
                                    log_enabled:1,  /*!< enable log */
                                    reserved:29;
    }flags;
    struct
    { 
        unsigned long               len;
        char                        *data;
    }log_dir, admin_key;                       /*!< admin key, dump need this, if NULL can not dump by remote connection */
    unsigned long                   keepalive;      /*!< keepalive tick */
    struct msock_proxy_statistic    *statistic;     /*!< statistic out buffer, if NULL ignore */
    struct msock_proxy_item         items[msock_proxy_desc_item_counts];       /*!< items */
}_msock_proxy_desc;
#define msock_proxy_desc_format_s        "%p{peers[{%ld:%*.*s:%ld},{%ld:%*.*s:%ld}]}"
#define msock_proxy_desc_format(_desc)   (_desc), \
                                        (_desc)?(_desc)->items[0].type:0, 0, (_desc)?(_desc)->items[0].host.len:0, (_desc)?(_desc)->items[0].host.data:NULL,\
                                        (_desc)?(_desc)->items[0].port:0, \
                                        (_desc)?(_desc)->items[1].type:0, 0, (_desc)?(_desc)->items[1].host.len:0, (_desc)?(_desc)->items[1].host.data:NULL,\
                                        (_desc)?(_desc)->items[1].port:0


/*!
func    msock_proxy_destroy
\brief  destroy socket proxy
\param	proxy[in]           the proxy return by msock_proxy_create
\return destroy result
        #0                  succeed
        #other              error code
*/
long msock_proxy_destroy(struct msock_proxy *proxy);

/*!
func    msock_proxy_create
\brief  create socket proxy
\param	desc[in]            the proxy description
\return create result
        #NULL               failed
        #other              the socket proxy object
*/
struct msock_proxy *msock_proxy_create(struct msock_proxy_desc *desc);

/*!
func    msock_proxy_wait
\brief  wait sock proxy event, and deal with it
\param	proxy[in]           the socket proxy object
\param  timeout[in]         the waitted time out, return have any event
                            or wait the timeout ms then return.
\return wait result
        #0                  succeed
        #other              error code
*/
long msock_proxy_wait(struct msock_proxy *proxy, unsigned long timeout);

/*!
func    msock_proxy_util_entry
\brief  socket porxy simple entry, function will block running until finished
\param	argc[in]            the args counts
\param  argv[in]            the args list
\return util run result
        #0                  succeed
        #other              error code
*/
long msock_proxy_util_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */


#endif /* !defined(__msock_proxy_h__) */

