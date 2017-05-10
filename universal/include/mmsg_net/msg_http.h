/*!
\file       msg_http.h
\brief      message http module, a inner webserver

 ----history----
\author     chengzhiyong
\date       2007-03-16
\version    0.01
\desc       create

\author     chengzhiyong
\date       2008-08-26
\version    0.02
\desc       rewrite, add timeout and operation network direct by net-ex unit

$Author: chengzhiyong $
$Id: msg_http.h,v 1.4 2008-11-13 02:05:15 chengzhiyong Exp $
*/
#if !defined(__msg_http_h__)
#define __msg_http_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct mhttp_module;
struct mhttp_in;
struct mmq_list;
struct message;
struct in_addr;

typedef long (*mhttp_fwd_req)( struct component* comp, struct message *msg, struct in_addr *ip, long port, long handle, void *refer, long *new_handle );
typedef long (*mhttp_fwd_cancel)( struct component* comp, long handle );
typedef struct pack_def* (*mhttp_get_def)( void *refer, struct len_str *type, unsigned long magic );

typedef struct mhttp_create_param
{
    char                    *conf_file;
    struct mmq_list         *mqlst;
    mhttp_fwd_req           fwd_req;
    mhttp_fwd_cancel        fwd_cancel;
    mhttp_get_def           get_def;
    struct component        *refer;
    long                    log_enable;
}_mhttp_create_param;

/*!
func    mhttp_create
\brief  create http module
\param  conf_file[in]           the config file
\param  mqlst[in]               the message queue list
\return the message http module
        #NULL                   failed
        #other                  the module
*/
struct mhttp_module *mhttp_create( struct mhttp_create_param *param );

/*!
func    mhttp_destroy
\brief  destroy http module
\param  mod[in]                 the message http module
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mhttp_destroy(struct mhttp_module *mod);

/*!
func    mhttp_wait
\brief  destroy http module
\param  mod[in]                 the message http module
\param  timeout[in]             the timeout value(ms)
\return wait result
        #0                      succeed
        #other                  error code
*/
long mhttp_wait(struct mhttp_module *mod, unsigned long timeout/* ms */);

/*!
func    mhttp_on_msg
\brief  raise on message routine in message http module
\param  mod[in]                 the message http module
\param  msg_addr[in/out]        message, reset to NULL if message have been destroy or save 
\return result
        #0                      succeed
        #other                  error code
*/
long mhttp_on_msg( struct mhttp_module *mod, long handle, struct message **msg_addr );

void *mhttp_get_vhost_table( struct mhttp_module *mod );

long mhttp__prepare_msg_rsp(struct mhttp_in *in, struct message *msg);


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
#endif /* !defined(__msg_http_h__) */

