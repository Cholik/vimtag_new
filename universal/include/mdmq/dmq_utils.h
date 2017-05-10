/*!
\file       dmq_utils.h
\brief      dmq utils unit

 ----history----
\author     chengzhiyong 
\date       2012-11-05
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: lock.c,v 1.25 2008-08-20 09:07:42 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif

struct dmq_module;
struct dmq_watch;
struct dmq_notify;
struct trans_obj;
struct gw_route_add_ack;
struct len_str;
struct pack_def;

#define dmq_on_flag_send_ack            0x01
#define dmq_on_flag_send_notify         0x02
#define dmq_on_flag_send_route_add_ack  0x03
#define dmq_on_flag_need_ack            0x04

/*!
func    dmq_on_watch
\brief  dmq on watch dealwith function for dmq-server. will notify all refer watcher
\param  mod[in]                 the dmq module 
\param  watch[in]               the watch data
\param  trans[in]               current trans-object
\return deal with result
        #<0                     error code
        #other                  send out dmq_notify message counts
*/
long dmq_on_watch(struct dmq_module *mod, struct dmq_watch *watch, struct trans_obj *trans);

/*!
func    dmq_on_notify
\brief  dmq on notify dealwith function for dmq-clent. will auto add route to cgw
\param  mod[in]                 the dmq module 
\param  notify[in]              the notify data
\param  trans[in]               current trans-object, can be NULL, if NULL will not send route-add to gw.
\return deal with result
        #<0                     error code
        #other                  send out route_add to cgw message counts
*/
long dmq_on_notify(struct dmq_module *mod, struct dmq_notify *notify, struct trans_obj *trans);

/*!
func    dmq_on_route_add_ack
\brief  dmq on route add ack dealwith function for dmq-clent.
\param  mod[in]                 the dmq module 
\param  route_add_ack[in]       the notify data
\param  trans[in]               current trans-object
\return deal with result
        #0                      succeed
        #<0                     error code
*/
long dmq_on_route_add_ack(struct dmq_module *mod, struct gw_route_add_ack *route_add_ack, struct trans_obj *trans);

/*!
func    dmq_send_watch_msg
\brief  send out dmq watch message to dmq server
\param  mod[in]                 the dmq module 
\param  dmq_srv_cid[in]         the dmq server cid
\param  counts[in]              the item counts
\param  group_id[in]            the group-id array start pointer, array size == "counts" param
\param  mq_id[in]               the mq-id array start pointer, array size == "counts" param
\param  role[in]                the role array start pointer, array size == "counts" param
\param  ctx[in]                 the ctx data array start pointer, can be NULL, if NULL ignore
                                if have ctx will send to all refer watcher
\param  trans[in]               the current trans-object
\return send resulet
        #0                      succeed
        #<0                     error code
*/
long dmq_send_watch_msg(struct dmq_module *mod, long dmq_srv_cid,
                        unsigned long counts, struct len_str *group_id, long *mq_id, unsigned long *role, struct len_str *ctx,
                        struct trans_obj *trans);

#define dmq_send_msg_flag_ignore_local_watcher      0x01 /* remote client connect to this gateway */
#define dmq_send_msg_flag_ignore_remote_watcher     0x02 /* self is client connect to remote gateway */
#define dmq_send_msg_flag_ignore_self_watcher       0x04 /* self */
/*!
func    dmq_send_msg
\brief  dmq send message to all read-watcher on special group-id
\param  mod[in]                 the dmq module 
\param  group_id[in]            the group id
\param  def[in]                 the message's def
\param  data[in]                the message data
\param  trans[in]               the current trans-object
                                if "comp"be setted, this param can be NULL, if you have not a current trans
                                    and just have component, set this param as NULL and set "comp" param plz
\param  comp[in]                the current component,
                                if "trans" be setted will ignore this param, then can be NULL
\param  flag[in]                the flag, ref dmq_send_msg_flag_xxxx
\return send out message counts
        #<0                     error code
        #other                  the message counts be sent
*/
long dmq_send_msg(struct dmq_module *mod, struct len_str *group_id, struct pack_def *def, void *data, struct trans_obj *trans, struct component *comp, unsigned long flag);

#if defined(__cplusplus)
}
#endif

