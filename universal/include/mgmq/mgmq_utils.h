/*!
\file       mgmq_utils.h
\brief      gmq utils unit

 ----history----
\author     chengzhiyong 
\date       2012-12-08
\version    0.01
\desc       create

\author     chengzhiyong
\date       2013-12-01
\version    0.02
\desc       add dynmiac sync functions

$Author: chengzhiyong $
$Id: lock.c,v 1.25 2008-08-20 09:07:42 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif

struct mgmq_mod;
struct mgmq_watch;
struct mgmq_notify;
struct trans_obj;
struct gw_route_add_ack;
struct len_str;
struct pack_def;


#define mgmq_notify_flag_fulllist       0x01

#define mgmq_on_flag_send_ack           0x01
#define mgmq_on_flag_send_notify        0x02
#define mgmq_on_flag_send_route_add_ack 0x03
#define mgmq_on_flag_need_ack           0x04

/*!
func    mgmq_mod_srv_mqid_set
\brief  set server mqid list
\param  mod[in]                 the gmq module 
\param  counts[in]              srv mqid counts, if client just accept 0~1.
\param  mqid[in]                srv mqid list, if NULL clear
                                if client: set as new gmq-srv id
                                if server: set as connected sync-srvs' mqid
\return set result
        #0                      succeed
        #<0                     error code
*/
long mgmq_mod_srv_mqid_set(struct mgmq_mod *mod, unsigned long counts, long *srv_mqid);

typedef struct mgmq_checksums
{
    struct mgmq_watcher     *watcher;
    uint32_t                sum;
    uint32_t                xors;
}_mgmq_checksums;

/*!
func    mgmq_checksums_calc
\brief  calc checksum
\param  mod[in]                 the module
\param  watcher_filter[in]      the filter watcher, can be NULL
\param  winfo_filter[in]        the filter type with watcher-info, can be NULL
                                    if watcher_filter ignore winfo_filter
                                    if watcher_filter and winfo_filter both NULL, output all
\param  counts[in]              the max counts of out items
\param  checksums_list[out]     the all checksums result, can be NULL, if NULL ignore
\param  checksums_info_list[out] the checksums info, can be NULL, if NULL ignore
                                    checksums or checksums_info at least have one.
                                    if NULL ignore checksums_info_pbuf too.
\parma  checksums_info_list_pbuf[out] just for checksums_info, can be NULL, if NULL ignore.
                                    if checksums_info_pbuf, checksums_info must be alloced from 
                                    checksums_info_pbuf. can be used to build message.
\return calc result
        #<0                     error code
        #other                  the out checksums counts
*/
long mgmq_calc_checksums(struct mgmq_mod            *mod,
                         struct mgmq_watcher        *watcher_filter, 
                         struct mgmq_watcher_info   *winfo_filter,
                         unsigned long              counts, 
                         struct mgmq_checksums      *checksums_list,
                         struct mgmq_checksums_info *checksums_info_list,
                         struct mpack_buf           *checksums_info_list_pbuf);

/*!
func    mgmq_on_route_add_ack
\brief  gmq on route add ack dealwith function for gmq-clent.
\param  mod[in]                 the gmq module 
\param  route_add_ack[in]       the notify data
\param  trans[in]               current trans-object
\return deal with result
        #0                      succeed
        #<0                     error code
*/
long mgmq_on_route_add_ack(struct mgmq_mod *mod, struct gw_route_add_ack *route_add_ack, struct trans_obj *trans);

/*!
func    mgmq_on_route_notify
\brief  gmq on route notify for gmq server
\param  mod[in]                 the gmq module 
\param  notify[in]              the notify data
\param  trans[in]               current trans-object
\return deal with result
        #0                      succeed
        #<0                     error code
*/
struct gw_route_notify;
long mgmq_on_route_notify(struct mgmq_mod *mod, struct gw_route_notify *notify, struct trans_obj *trans);

#define mgmq_notify_flag_srv_sync            1

typedef struct mgmq_on_ctx
{
    unsigned long           verify_send_ack;
    struct
    {
        unsigned long       notify_counts;
        unsigned long       verify_counts;
        unsigned long       sync_counts;
        unsigned long       notify_ack_counts;
        unsigned long       verify_ack_counts;
        unsigned long       sync_ack_counts;
    }ack;
    struct
    {
        struct
        {
            unsigned long   enable_ack;
        }flag;
        unsigned long       notify_counts;
        unsigned long       verify_counts;
        unsigned long       sync_counts;
    }forward;
    struct
    {
        unsigned long       add_counts;
    }route;
    unsigned long           wait_ack_counts;

    unsigned long           node_changed_counts;
    struct
    {
        long                prepare_notify;
        long                from_mqid;
        struct mgmq_notify  *notify;
        unsigned long       node_counts;
        struct mgmq_node    **nodes;
    }_runtime;
}_gmq_on_ctx;

/*!
func    mgmq_on_ctx_clear
\brief  clear mgmq_on_ctx
\param  ctx[in]                 the ctx
\return clear ctx
        #0                      succeed
        #other                  error code
*/
long mgmq_on_ctx_clear(struct mgmq_on_ctx *ctx);

/*!
func    mgmq_on_notify
\brief  gmq on notify dealwith function
        for client: will auto add route to cgw
        for server: will notify to other refer watcher, and tell report refer watchers,
                    and maybe sync to another mirror server
\param  mod[in]                 the gmq module 
\param  notify[in]              the notify data
\param  trans[in]               current trans-object, can be NULL, if NULL will not send route-add to gw.
\param  on_ctx[in]              the gmq-on-ctx, input as ={0} plz
\return deal with result
        #0                      succeed
        #other                  error code
*/
long mgmq_on_notify(struct mgmq_mod *mod, struct mgmq_notify *notify, struct trans_obj *trans, struct mgmq_on_ctx *on_ctx);

#define mgmq_verify_flag_send_ack    0x01
/*!
func    mgmq_on_verify
\brief  gmq on verify dealwith function for gmq-server.
\param  mod[in]                 the gmq module
\param  verify[in]              the verify data
\param  trans[in]               current trans-object
\param  on_ctx[in]              the gmq-on-ctx, input as ={0} plz
\return deal with result
        #0                      succeed
        #other                  error code
*/
long mgmq_on_verify(struct mgmq_mod *mod, struct mgmq_verify *verify, struct trans_obj *trans, struct mgmq_on_ctx *on_ctx);

/*!
func    mgmq_on_sync
\brief  gmq on sync dealwith function, just for server
\param  mod[in]                 the gmq module 
\param  sync[in]                the watch data
\param  trans[in]               current trans-object
\return deal with result
        #<0                     error code
        #other                  send out mgmq_notify message counts
*/
long mgmq_on_sync(struct mgmq_mod *mod, struct mgmq_sync *sync, struct trans_obj *trans, struct mgmq_on_ctx *on_ctx);

#define mgmq_notify_msg_flag_mute  0x01  /* don't send out mgmq_notify, just update local records */
/*!
func    mgmq_send_notify_msg
\brief  send out gmq notify message to gmq server
\param  mod[in]                 the gmq module 
\param  counts[in]              the item counts
\param  group_id[in]            the group-id array start pointer, array size == "counts" param
\param  role[in]                the role array start pointer, array size == "counts" param
\param  ctx[in]                 the ctx data array start pointer, can be NULL, if NULL ignore
                                if have ctx will send to all refer watcher
\param  trans[in]               the current trans-object
\param  flag[in]                the flag, refer mgmq_notify_msg_flag_xxx
\return send resulet
        #<0                     error code
        #other                  send out message counts
*/
long mgmq_send_notify_msg(struct mgmq_mod *mod, 
                         unsigned long counts, struct len_str *group_id, unsigned long *role, struct len_str *ctx,
                         struct trans_obj *trans, unsigned long flag);

#define mgmq_sync_msg_flag_begin               0x01    /* begin flag */
#define mgmq_sync_msg_flag_end                 0x02    /* end flag */
#define mgmq_sync_msg_flag_del                 0x04    /* delete flag */
/*!
func    mgmq_send_sync_msg
\brief  send out gmq sync refer message to gmq server
\param  mod[in]                 the gmq module 
\param  trans[in]               the current trans-object
\param  flag[in]                verify flag,
                                #first call when start verify should set mgmq_sync_msg_flag_begin
                                    if(gmq_sync_msg_flag_begin) will restart.
\return send resulet
        #<0                     error code
        #0                      succeed and finished
        #other                  send out message counts
*/
long mgmq_send_sync_msg(struct mgmq_mod *mod, struct trans_obj *trans, unsigned long flag);

#define mgmq_send_msg_flag_ignore_local_watcher      0x01 /* remote client connect to this gateway */
#define mgmq_send_msg_flag_ignore_remote_watcher     0x02 /* self is client connect to remote gateway */
#define mgmq_send_msg_flag_ignore_self_watcher       0x04 /* self */
/*!
func    mgmq_send_msg
\brief  gmq send message to all read-watcher on special group-id
\param  mod[in]                 the gmq module 
\param  group_id[in]            the group id
\param  def[in]                 the message's def
\param  data[in]                the message data
\param  trans[in]               the current trans-object
                                if "comp"be setted, this param can be NULL, if you have not a current trans
                                    and just have component, set this param as NULL and set "comp" param plz
\param  comp[in]                the current component,
                                if "trans" be setted will ignore this param, then can be NULL
\param  flag[in]                the flag, ref mgmq_send_msg_flag_xxxx
\return send out message counts
        #<0                     error code
        #other                  the message counts be sent
*/
long mgmq_send_msg(struct mgmq_mod *mod, struct len_str *group_id, struct pack_def *def, void *data, struct trans_obj *trans, struct component *comp, unsigned long flag);

#if defined(__cplusplus)
}
#endif

