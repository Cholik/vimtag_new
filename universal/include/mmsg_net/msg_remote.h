/*!
\file       msg_remote.h
\brief      message binary network exchange module, RPC, net <==> message

----history----
\author     chengzhiyong
\date       2007-03-16
\version    0.01
\desc       create

\author     chengzhiyong
\date       2008-08-26
\version    0.02
\desc       reaname unit from msg_net to msg_bin_net, and rewrite, add timeout
            and operation network direct by net-ex unit

$Author: chengzhiyong $
$Id: msg_remote.h,v 1.3 2008-11-13 02:05:15 chengzhiyong Exp $
*/
#if !defined(__msg_remote_h__)
#define __msg_remote_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct mrmt_module;
struct mrmt_conn;
struct in_addr;
struct mmq_list;
struct message;

typedef long (*mrmt_fwd_req)( struct component* comp, struct message *msg, struct in_addr *remote_ip, long remote_port, struct in_addr *local_ip, long fwd_handle, void *refer, long *new_handle );
typedef long (*mrmt_fwd_cancel)( struct component* comp, long handle );
typedef long (*mrmt_fwd_route_notify)( struct component *comp, long fwd_handle, long reachable );
typedef struct pack_def *(*mrmt_get_def)( void *refer, struct len_str *type, unsigned long magic );

typedef struct mrmt_create_param
{
    char                    *conf_file;
    struct mmq_list         *mqlst;
    mrmt_fwd_req            fwd_req;
    mrmt_fwd_cancel         fwd_cancel;
    mrmt_fwd_route_notify   route_notify;
    mrmt_get_def            get_def;
    struct component        *refer;
    struct len_str          contex;
    long                    log_enable;
}_mrmt_create_param;

typedef struct mrmt_route_add_param
{
    struct mrmt_module      *mod;
    struct len_str          host;
    long                    port;
    long                    rmt_cid;
    long                    fwd_handle;
    long                    refer;
    long                    ext;
}_mrmt_route_add_param;

/*!
func    mrmt_create
\brief  create net module
\param  conf_file[in]           the config file
\param  mqlst[in]               the message queue list
\return the message net module
        #NULL                   failed
        #other                  the module
*/
struct mrmt_module *mrmt_create( struct mrmt_create_param *param );

/*!
func    mrmt_destroy
\brief  destroy net module
\param  mod[in]                 the message net module
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mrmt_destroy(struct mrmt_module *mod);

/*!
func    mrmt_pause
\brief  pause net module
\param  mod[in]                 the message net module
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mrmt_pause(struct mrmt_module *mod, long pause);


/*!
func    mrmt_wait
\brief  destroy net module
\param  mod[in]                 the message net module
\param  timeout[in]            the timeout value(ms)
\return wait result
        #0                      succeed
        #other                  error code
*/
long mrmt_wait(struct mrmt_module *mod, unsigned long timeout/* ms */);

/*!
func    mrmt_on_msg
\brief  raise on message routine in message net module
\param  mod[in]                 the message net module
\param  msg_addr[in/out]        message, reset to NULL if message have been destroy or save 
\return result
        #0                      succeed
        #other                  error code
*/
extern long mrmt_on_msg(struct mrmt_module *mod, struct mrmt_conn *conn, long fwd_handle, struct message **msg_addr);
extern long mrmt_route_add( struct mrmt_route_add_param *param );
extern long mrmt_route_del( struct mrmt_module *mod, long fwd_handle );
extern long mrmt_port_set( struct mrmt_module *mod, long port );
extern long mrmt_route_is_reachable( struct mrmt_module *mod, long fwd_handle );
extern long mrmt_dump( struct mrmt_module *mod,
                    unsigned long       argc,  char *argv[],
                    char                *buf,  char                *file,
                    unsigned long       start, unsigned long       counts,
                    unsigned long       size);
extern long mrmt_conn_destroy(struct mrmt_module *mod, struct mrmt_conn *conn, long fwd_handle );

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */
#endif /* !defined(__msg_remote_h__) */

