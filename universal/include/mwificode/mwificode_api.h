/*!
\file       mwificode_api.h
\brief      mining wifi-code util api

 ----history----
\author     chengzhiyong
\date       2013-07-09
\version    0.01
\desc       create
*/

#if !defined(__mwificode_api_h__)
#define __mwificode_api_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

/*!
func    mwfc_create
\brief  create wifi code runner
\param  desc[in]                the runner description
\return the sender
        #NULL                   failed
        #other                  the sender
*/
struct mwfc_runner *mwfc_create(struct mwfc_runner_desc *desc);

/*!
func    mwfc_destroy
\brief  destroy wifi code runner
\param  runner[in]              the runner
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mwfc_destroy(struct mwfc_runner *runner);

/*!
func    mwfc_sch
\brief  schedule runner to send/recv data
        caller need loop to call this function again and again
\param  sender[in]              the sender
\param  timeout[in]             the timeout value, in ms
\return sechedule result
        #0                      succeed
        #other                  error code
*/
long mwfc_sch(struct mwfc_runner *runner, unsigned long timeout);

/*!
func    mwfc_push
\brief  just for recver
\param  runner[in]              the runner
\param  tick[in]                the tick
\param  len[in]                 the length
\param  src_mac[in]             src mac
\param  dst_mac[in]             dst mac
\return push result
        #<0                     error code
        #other                  mwfc_push_status_xxx
*/
long mwfc_push(struct mwfc_runner *runner, unsigned long tick, unsigned long len, unsigned char *src_mac, unsigned char *dst_mac);

/*!
func    mwfc_dump
\brief  dump inner info from runner context
\param  mod[in]                 the module, can be NULL, if NULL ignore
\param  argc[in]                the arg counts
\param  argv[in]                the arg list, if(argc == 0) can be NULL if NULL default
                                --help      : get help
                                --filter    : filter string, if empty all items will be matched.
                                --type      : type list split by ","
                                    module          : output module
                                    client          : output factory
                                    task            : output channel class
                                    all             : output all type
                                    default         : same as client
\param  buf[in]                 the output buffer, can be NULL, if NULL output into file
\param  start[in]               the start record no
\param  counts[in]              max output records counts
\param  size[in]                the buf size or max content size output to file
\return content length
        #<0                     error code
        #other                  content length
*/
long mwfc_dump(struct mwfc_runner *runner,
              unsigned long     argc,
              char              *argv[],
              char              *buf,
              char              *file,
              unsigned long     start,
              unsigned long     counts,
              unsigned long     size);

/*!
func    mwfc_util_entry
\brief  wifi code util endtry
\param  argc[in]            the arg counts, come from command line usually
\param  argv[in]            the arg values, come from command line usually
\return detroy result
        #0                  succeed
        #other              error code
*/
long mwfc_util_entry(long argc, char *argv[]);

/*!
func    mwfc_client_create
\brief  create wificode client
\param  str_param[in]       the params setting, json string
                                {
                                    magic_loop_segs:""(default:0),
                                    start_magic_counts:"" (default:8),
                                    code-payload-bits:"" (default:6),
                                    code-index-bits:"" (default:2),
                                    code-checksum-bits:"" (default:1),
                                    seg-payload-bitss:"" (default:8),
                                    seg-index-bits:"" (default:8),
                                    seg-checksum-bits:"" (default:8),
                                    port:"" (default:54321),
                                    speed:"" (default:256K byte/s),
                                    max-twins"":(default:1024),
                                    dst:""(should be gw addr),
                                    content:""
                                }
                                for example:
                                {dst:"192.168.2.2", content:"wfc test"}
\return detroy result
        #NULL               fail
        #other              client HANDLE
*/
struct mwfc_client_cb * mwfc_client_create( struct len_str *str_param );

/*!
func    mwfc_client_destroy
\brief  destroy wificode client
\param  client_cb[in]           client handle
\return the media channel
        #0                      ok
        #other                  fail
*/
long mwfc_client_destroy( struct mwfc_client_cb *client_cb );

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__mwificode_api_h__) */
