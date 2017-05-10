/*!
\file       msg_download.c
\brief      message down download module, down client

 ----history----
\author     chengzhiyong
\date       2007-03-16
\version    0.01
\desc       create

\author     chengzhiyong
\date       2008-08-31
\version    0.02
\desc       pick download functions from msg_down module,
            add timeout and operation network direct by net-ex unit

$Author: chengzhiyong $
$Id: msg_download.h,v 1.3 2008-09-08 04:21:39 chengzhiyong Exp $
*/
#if !defined(__msg_download_h__)
#define __msg_download_h__
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct param_field;
struct pack_lenstr;
struct mdown_module;
struct mmq_list;

/*!
func    mdown_create
\brief  create down module
\param  conf_file[in]           the http data config file
\param  mqlst[in]               the message queue list
\return the message down module
        #NULL                   failed
        #other                  the module
*/
struct mdown_module *mdown_create(char *conf_file, struct mmq_list *mqlst);

/*!
func    mdown_destroy
\brief  destroy message download module
\param  mod[in]                 the message download module
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mdown_destroy(struct mdown_module *mod);

/*!
func    mdown_wait
\brief  destroy down module
\param  mod[in]                 the message down module
\param  timeout[in]             the timeout value(ms)
\return wait result
        #0                      succeed
        #other                  error code
*/
long mdown_wait(struct mdown_module *mod, unsigned long timeout/* ms */);

#define mdown_flags_file_exchange   1
/*!
func    mdown_get
\brief  download file from remote out, when finished send message to special comp_id
\param  mod[in]                 the message down mod
\param  key[in]                 the key, just record then send back for caller, do nothing here, can be NULL
\param  url[in]                 the url string
\param  params[in]              the param list
\param  param_counts[in]        param counts
\param  content[in]             the content, if valid should send as POST, else should be GET
\param  queue_id[in]            the ack queue id
\param  handle[in]              the ack handle, for trans
\param  flags[in]               the flags, refer mdown_flags_xxx
\return start result
        #0                      succeed
        #other                  error code(error url or network error)
*/
long mdown_get(struct mdown_module  *mod, 
               struct pack_lenstr   *url,
               struct pack_lenstr   *key,
               struct param_field   *params,
               unsigned long        param_counts,
               struct pack_lenstr   *content,
               long                 queue_id,
               unsigned long        handle,
               unsigned long        flags);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */
#endif /* !defined(__msg_download_h__) */

