/*!
\file       msg_transaction.h
\brief      message transaction dealwith unit

 ----history----
\author     dakota
\date       2007-05-27
\version    0.01
\desc       create
 ---------------
\author     chengzhiyong 
\date       2007-09-04
\version    0.02
\desc       rewrite

$Author: chengzhiyong $
$Id: msg_transaction.h,v 1.5 2008-11-15 02:01:59 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__msg_transaction_h__)
#define __msg_transaction_h__

struct component;
struct message;
struct trans_obj;
struct trans_class;
struct trans_event;
struct trans_trace_obj;
struct trans_table;
struct trace_trans_key;

#define trans_max_refer     4

#define mmq_demage_check_method_full  "mmq.demage.check.full"

/* Macro used for trans_send_ack to indicate component want to send ok_ack or err_ack */
#define TRANS_FAIL          1
#define TRANS_OK            0
#define TRANS_SYS_DESTROY   -1
#define TRANS_TIMEOUT       -2
#define TRANS_KEEPLIVE      5   /* just for on-destroy, will let trans keep live */

/*!
func    on_trans_transfer_message
\brief  on transfer message arrive call-back routine, msg->to is not this component, in net gateway will happen.
\param  comp[in]                the component object
\param  msg_addr[in/out]        message, reset to NULL if message have been destroy or save 
\return dealwith result
        #0                      succeed
        #other                  error code
*/
typedef long (*trans_on_transfer_message)(struct component *comp, struct message **msg_addr);

/*!
func    trans_on_event
\brief  transaction on-event dealwith routine
\param  trans[in]               the trans object
\param  msg[in]                 the message object
\param  ref[in]                 the message refer data
\return dealwith result
        #0                      succeed
        #other                  error code
*/
typedef long (*trans_on_event)(struct trans_obj *trans);

/*! \brief trans class magic "trnc" */
#define trans_class_magic   (*(long*)"trcl    ")
/*! \brief transaction class */
typedef struct trans_class
{
    char                    magic[sizeof(long)]; /*!< class magic, "trcl" */
    struct  
    {
        struct trans_class  *next;          /*!< next item */
        struct trans_class  *prev;          /*!< prev item */
        struct trans_table  *owner;         /*!< owner trans table */
    }in_tbl;
    char                    *name;          /*!< trans class name */
    unsigned long           name_len;       /*!< trans class name length */
    struct pack_def         *create_def;    /*!< create message type refer def */
    unsigned long           user_data_size; /*!< user data size */
    unsigned long           timeout;        /*!< set timeout value ticks(ms) */
    trans_on_event          on_create;      /*!< create */
    trans_on_event          on_destroy;     /*!< destroy */
    trans_on_event          on_default;     /*!< default message, any other unregistered event */
    struct
    {
        unsigned long       counts;         /*!< message counts */
        struct trans_event  *list;          /*!< message list*/
    }events;                                /*!< refer events list */
    struct  
    {
        unsigned long       trace_counts;           /*!< run special trace task */
        unsigned long       finished_counts;        /*!< total finished transaction counts */
        unsigned long       finished_err_counts;    /*!< error transaction counts */
        unsigned long       timeout_counts;         /*!< timeout transaction counts */
        unsigned long       trans_counts;           /*!< active trans counts */
        unsigned long       msg_counts;             /*!< total recv message counts */
        double              run_average_ticks;      /*!< transaction run ticks average */
        double              run_last_check_ticks;   /*!< transaction run ticks average for last checked transaction */
        unsigned long       run_remain_check_ticks; /*!< remained transaction run tick counts */
        unsigned long       run_remain_check_counts;/*!< remained transaction counts need be check */
    }statistic;                                     /*!< statistic */
}_trans_class;

/*! \brief trans table magic "trno" */
#define trans_obj_magic     (*(long*)"tran    ")
/*! \biref transaction control block */
typedef struct trans_obj
{
    char                    magic[sizeof(long)];    /*!< trans magic, "tran" */
    struct trans_class      *cls;                   /*!< trans base class */
    struct trans_obj        *hash_next;             /*!< next in hash table */
    struct
    {
        struct trans_obj    *next;          /*!< next */
        struct trans_obj    *prev;          /*!< prev */
    }in_tbl;

    struct component        *comp;          /*!< component obj, copy from table */
    long                    close_reason;   /*!< close reason */
    struct trans_trace_obj  *trace_obj;     /*!< trace object */
    unsigned long           trace_flag;     /*!< trace flag */
    long                    local_handle;   /*!< the local handle of the trans */
    long                    reply;          /*!< reply to component id */
    long                    reply_handle;   /*!< the remote handle from invoker */
    unsigned long           create_tick;    /*!< create tick count, life time check */
    unsigned long           tick;           /*!< last tick, to time out check */
    unsigned long           total_rcv_msg_counts;   /*!< total receive message counts */
    unsigned long           total_on_destroy_counts;   /*!< total on destroy called counts */
    unsigned long           rcv_msg_counts; /*!< received message counts */
    struct message          **rcv_msgs[2];  /*!< received message, 0:base counts messages, 1:over trans_info->msgs->counts parts messages */
    struct message          *cur_msg;       /*!< current message */
    struct pack_def         *cur_msg_def;   /*!< current message refer pack type definition */
    long                    refer_long[trans_max_refer];
    void                    *refer_ptr[trans_max_refer];
}_trans_obj;
#define trans_get_trace_flag(trans)     (((struct trans_obj*)trans)->trace_flag)
#define trans_get_trace_obj(trans)      (((struct trans_obj*)trans)->trace_obj)
#define trans_get_local_handle(trans)   (((struct trans_obj*)trans)->local_handle)
#define trans_get_reply_handle(trans)   (((struct trans_obj*)trans)->reply_handle)
#define trans_get_reply(trans)          (((struct trans_obj*)trans)->reply)
#define trans_get_comp(trans)           (((struct trans_obj*)trans)->comp)
#define trans_get_comp_data(trans)      (((struct trans_obj*)trans)->comp)->data
#define trans_get_base_obj(trans)       ((struct trans_obj*)trans)
#define trans_get_msg(trans)            (((struct trans_obj*)trans)->cur_msg)
#define trans_get_msg_def(trans)        (((struct trans_obj*)trans)->cur_msg_def)
#define trans_get_destroy_reason(trans) (((struct trans_obj*)trans)->close_reason)
#define trans_get_mqlst(trans)          (((struct trans_obj*)trans)->comp)->mqlst
#define trans_get_create_tick(trans)    (((struct trans_obj*)trans)->create_tick)
#define trans_get_tick(trans)           (((struct trans_obj*)trans)->tick)

#define trans_get_cls_active_trans(trans)  (((struct trans_obj*)trans)->cls->statistic.trans_counts)

#define trans_get_total_rcv_msg_counts(trans)   (((struct trans_obj*)trans)->total_rcv_msg_counts)
#define trans_get_refer_long(trans,index)(((index)<trans_max_refer)?((struct trans_obj*)trans)->refer_long[index]:0)
#define trans_set_refer_long(trans,index,data)(((index)<trans_max_refer)?(((struct trans_obj*)trans)->refer_long[index] = data):0)
#define trans_get_refer_ptr(trans,index)(((index)<trans_max_refer)?((struct trans_obj*)trans)->refer_ptr[index]:NULL)
#define trans_set_refer_ptr(trans,index,data)(((index)<trans_max_refer)?(((struct trans_obj*)trans)->refer_ptr[index] = data):0)
#define trans_format_s                  "%p{[%4.4s]%s.%s:%08lx}"
#define trans_format(_trans)            (_trans), (_trans)?(char*)&(_trans)->magic:NULL,\
                                        ((_trans) && (trans_obj_magic == *((long*)&(_trans)->magic)) && (_trans)->comp)?comp_get_name((_trans)->comp):NULL, \
                                        ((_trans) && (trans_obj_magic == *((long*)&(_trans)->magic)) && (_trans)->cls)?(_trans)->cls->name:NULL,\
                                        ((_trans) && (trans_obj_magic == *((long*)&(_trans)->magic)))?(_trans)->local_handle:0

#define trans_refer_have_record( trans ) ( trans_get_refer_long( (trans), 0 ) || trans_get_refer_long( (trans), 1 ) || trans_get_refer_long( (trans), 2 ) || trans_get_refer_long( (trans), 3 ))
#define trans_refer_record_str( trans, str ) \
    trans_set_refer_ptr((trans), 0, (str)); \
    trans_set_refer_long((trans), 0, ((str)?strlen(str):0))

#define trans_refer_record_lenstr( trans, lenstr ) \
    trans_set_refer_ptr((trans), 0, (lenstr)->data); \
    trans_set_refer_long((trans), 0, (lenstr)->len)

#define trans_refer_record_str_3( trans, str1, str2, str3 ) \
    trans_set_refer_ptr((trans), 0, (str1)); \
    trans_set_refer_long((trans), 0, ((str1)?strlen(str1):0));\
    trans_set_refer_ptr((trans), 1, (str2)); \
    trans_set_refer_long((trans), 1, ((str2)?strlen(str2):0));\
    trans_set_refer_ptr((trans), 2, (str3)); \
    trans_set_refer_long((trans), 2, ((str3)?strlen(str3):0))

#define trans_refer_record_lenstr_3( trans, lenstr1, lenstr2, lenstr3 ) \
    trans_set_refer_ptr((trans), 0, (lenstr1)->data); \
    trans_set_refer_long((trans), 0, (lenstr1)->len);\
    trans_set_refer_ptr((trans), 1, (lenstr2)->data); \
    trans_set_refer_long((trans), 1, (lenstr2)->len);\
    trans_set_refer_ptr((trans), 2, (lenstr3)->data); \
    trans_set_refer_long((trans), 2, (lenstr3)->len)

#define trans_refer_msg_save_str( trans, msg, str )\
    trans_get_refer_long( (trans), 0 )?(((((str)->data) = msg_save_str(msg, trans_get_refer_ptr(trans,0), &(str)->len))==NULL)?1:0):(0)
#define trans_refer_msg_save_str_3( trans, msg, str1, str2, str3 )\
    ( trans_get_refer_long( (trans), 0 ) && (((((str1)->data) = msg_save_str(msg, trans_get_refer_ptr(trans,0), &(str1)->len ))==NULL))) \
    ||( trans_get_refer_long( (trans), 1 ) && (((((str2)->data) = msg_save_str(msg, trans_get_refer_ptr(trans,1), &(str2)->len ))==NULL))) \
    ||( trans_get_refer_long( (trans), 2 ) && (((((str3)->data) = msg_save_str(msg, trans_get_refer_ptr(trans,2), &(str3)->len ))==NULL)))

/*!
func    trans_create
\brief  create transaction table
\param  comp[in]                the component
\return the transaction table
        #NULL                   failed
        #other                  transaction table
*/
struct trans_table* trans_create_table();

/*!
func    trans_destroy_table
\brief  destroy transaction table
\param  tbl[in]                 the transaction table
\return destroy result
        #0                      succeed
        #other                  error code
*/
long trans_destroy_table(struct trans_table *tbl);

/*!
func    trans_ctl_table
\brief  ctrl transaction table
\param  tbl[in]                 the transaction table
\param  method[in]              the method, 
                                "mq.demage.check.full" : param "on" | "off"
\param  param[in]               the method refer param
\return control result
        #0                      succeed
        #other                  error code
*/
long trans_ctl_table(struct trans_table *tbl, char *method, char *param);

/*!
func    trans_set_on_transfer
\brief  set on transfer message
\param  tbl[in]                 the transaction table
\param  on_transfer[in]         on transfer message call-back routine
\return set result
        #0                      succeed
        #other                  error code
*/
long trans_set_on_transfer(struct trans_table *tbl, trans_on_transfer_message on_transfer);

/*!
func    trans_on_tick
\brief  for check timeout transaction
\param  tbl[in]                 the transaction table
\param  tick[in]                the tick now
\return deal with result
        #0                      succeed
        #other                  error code
*/
long trans_on_tick(struct trans_table *tbl, unsigned long tick);

/*!
func    trans_dispatch
\brief  dispatch message
\param  comp[in]                the component
\param  tbl[in]                 the transaction table
\param  timeout[in]             the timeout value(ms)
\return dispatch result
        #0                      succeed
        #other                  error code
*/
long trans_dispatch(struct component *comp, struct trans_table *tbl, unsigned long timeout);

/*!
func    trans_reg_types
\brief  register transaction types
\param  tbl[in]                 the transaction table
\param  counts[in]              the def counts
\param  defs[in]                def list
\return register result
        #0                      succeed
        #other                  error code
*/
long trans_reg_types(struct trans_table *tbl, unsigned long counts, struct pack_def **defs);

/*!
func    trans_reg_class
\brief  register a transaction class
\param  tbl[in]                 the transaction table
\param  name[in]                the trans class name
\param  create_def[in]          the create definition message, can be NULL
                                #NULL means create by any message, just allow only one trans like this
                                    if NULL, name should like xxx_default for default message.
\param  on_create[in]           the create event
\param  on_destroy[in]          the destroy event
\param  user_data_size[in]      the transaction object size expand from trans_obj
\return register result
        #0                      succeed
        #other                  error code
*/
struct trans_class *trans_reg_class(struct trans_table  *tbl,
                                    char                *name,
                                    struct pack_def     *create_def,
                                    trans_on_event      on_create,
                                    trans_on_event      on_destroy,
                                    unsigned long       user_data_size);
/*!
func    trans_reg_event
\brief  register transaction event
\param  cls[in]                 the transaction cls
\param  def[in]                 the definition, can be NULL
                                #if NULL means on_event is default(for any other unregistered event)
\param  on_event[in]            the event callback routine
\return register result
        #0                      succeed
        #other                  error code
*/
long trans_reg_event(struct trans_class *cls, struct pack_def *def, trans_on_event on_event);

#define trans_class_ctl_type_timeout        0x01
#define trans_class_ctl_type_trace_counts   0x02

/*!
func    trans_ctl_class
\brief  control type
\param  cls[in]                 the transaction class object
\param  type[in]                the ctrl type, ref trans_class_ctl_type_xxx
\param  value[in]               the control value
\return set result
        #0                      succeed
        #other                  error code
*/
long trans_ctl_class(struct trans_class *cls, unsigned long type, unsigned long value);

/*!
func    trans_destroy_obj
\brief  destroy transaction object
\param  trans[in]               the transaction object
\param  reason[in]              close reason
                                #0      succeed
                                #other  TIME_OUT or error code
\return destroy result
        #0                      succeed
        #other                  error code
*/
long trans_destroy_obj(struct trans_obj *trans, long reason);

/*!
func    trans_destroy
\brief  destroy transaction object
\param  trans[in]               the transaction object
\param  reason[in]              close reason
                                #0      succeed
                                #other  TIME_OUT or error code
\return destroy result
        #0                      succeed
        #other                  error code
*/
#define trans_destroy(trans, reason) trans_destroy_obj(trans_get_base_obj(trans), reason)

/*!
func    trans_create_msg
\brief  create a message
\param  trans[in]               the transaction object
\param  new_msg[out]            assign new_message value
\param  msg_type[in]            the message type, name not a value or string!!struct xxx_ack should be xxx_ack
\param  msg_size[in]            the message size
\return start struct
        #NULL                   failed
        #other                  the start struct
*/
#define trans_create_msg(trans, new_msg, msg_type, msg_size) \
            ((*(new_msg) = msg_create_pack(trans_get_comp(trans)->mqlst, #msg_type, sizeof(#msg_type) - 1, __##msg_type##_type_magic, msg_size, __FILE__, __LINE__))?\
                (struct msg_type*)msg_calloc(*(new_msg), sizeof(struct msg_type)):\
                ((struct msg_type*)0))

/*!
func    trans_create_msg_ex
\brief  create a message
\param  trans[in]               the transaction object
\param  new_msg[out]            assign new_message value
\param  msg_type[in]            the message type, name not a value or string!!struct xxx_ack should be xxx_ack
\param  msg_size[in]            the message size
\param  pbuf[out]               the mpack_buf, if NULL ignore
\return start struct
        #NULL                   failed
        #other                  the start struct
*/
#define trans_create_msg_ex(trans, new_msg, msg_type, msg_size, pbuf) \
            ((*(new_msg) = msg_create_pack(trans_get_comp(trans)->mqlst, #msg_type, sizeof(#msg_type) - 1, __##msg_type##_type_magic, msg_size, __FILE__, __LINE__))?\
                ((pbuf)?(mpbuf_init_ex(pbuf, msg_get_data(*new_msg), msg_get_data_size(*new_msg))?\
                          ((struct msg_type*)0)\
                          :((struct msg_type*)mpbuf_calloc(pbuf, sizeof(struct msg_type))))\
                      :((struct msg_type*)msg_calloc(*new_msg, sizeof(struct msg_type))))\
                :((struct msg_type*)0))

/*!
func    trans_destroy_msg
\brief  destroy message in transaction
\param  trans[in]               the transaction object
\param  msg[in]                 the message object
\return deal with result
        #0                      succeed
        #other                  error code
*/
#define trans_destroy_msg(trans, msg) msg_destroy_pack(trans_get_comp(trans)->mqlst, msg, __FILE__, __LINE__)

/*
func    trans_release_msg
\brief  release message be saved in transaction
\param  trans[in]               the transaction object
\param  msg[in]                 the message object
\return release result
        #0                      succeed
        #other                  error code
*/
long trans_release_msg(struct trans_obj *trans, struct message *msg);

/*!
func    trans_send_msg_with_baseaddr
\brief  send out message with baseaddr
\param  trans[in]               the transaction object
\param  to[in]                  dest component
\param  to_handle[in]           the handle on dest component, if just request should be 0
\param  msg[in]                 the message
\param  data_base_addr[in]      the data base address
\return send result
        #0                      succeed
        #other                  error code
*/
#define trans_send_msg_with_baseaddr(trans, to, to_handle, msg, data_base_addr) \
        ((0 == ((msg_set_trace_flag(msg, trans_get_trace_flag(trans)))?1:-1))?-1:\
            (msg_send_pack(trans_get_mqlst(trans),\
                           comp_get_id(trans_get_comp(trans)),\
                           trans_get_local_handle(trans),\
                           (to),\
                           (to_handle),\
                           (msg),\
                           (data_base_addr),\
                           (trans_get_trace_flag(trans)& trace_flag_mask_msg && trans_get_trace_obj(trans))?(msg_on_send_pack)trans_trace_msg:NULL,\
                           (trans),\
                           __FILE__,\
                           __LINE__)))

/*!
func    trans_send_msg_with_baseaddr_ex
\brief  send out message with baseaddr
\param  trans[in]               the transaction object
\param  to[in]                  dest component
\param  to_handle[in]           the handle on dest component, if just request should be 0
\param  msg[in]                 the message
\param  pbuf[in]                the pack buffer, if NULL ignore.
                                will update message base-address this value
\param  data_base_addr[in]      the data base address
\return send result
        #0                      succeed
        #other                  error code
*/
#define trans_send_msg_with_baseaddr_ex(trans, to, to_handle, msg, pbuf, data_base_addr) \
        (((pbuf) && (0 == (msg_set_data_base_addr(msg, ((char*)((pbuf)->index))))))?-1:\
            trans_send_msg_with_baseaddr(trans, to, to_handle, msg, data_base_addr))


/*!
func    trans_send_msg
\brief  send out message
\param  trans[in]               the transaction object
\param  to[in]                  dest component
\param  to_handle[in]           the handle on dest component, if just request should be 0
\param  msg[in]                 the message
\return send result
        #0                      succeed
        #other                  error code
*/
#define trans_send_msg(trans, to, to_handle, msg) trans_send_msg_with_baseaddr(trans, to, to_handle, msg, NULL)

/*!
func    trans_send_msg_ex
\brief  send out message
\param  trans[in]               the transaction object
\param  to[in]                  dest component
\param  to_handle[in]           the handle on dest component, if just request should be 0
\param  msg[in]                 the message
\param  pbuf[in]                the pack buffer
\return send result
        #0                      succeed
        #other                  error code
*/
#define trans_send_msg_ex(trans, to, to_handle, msg, pbuf) trans_send_msg_with_baseaddr_ex(trans, to, to_handle, msg, pbuf, NULL)


/*-----------------------Trans trace part start-------------------------------*/
typedef struct trace_trans_key
{
    long        cid;
    long        handle;
}_trace_trans_key;

typedef struct trans_trace_obj
{
    unsigned long       index;         /* Trace index */
    unsigned long       max_trans_count; /* Max reference request trans */
    unsigned long       trans_count;   /* Request trans */
    struct 
    {
        long	        comp_id;	    /* the component id */ 
        long			trans_handle;	/* the transaction handle */ 
    }*trans;	
    
    struct pack_date    start_time;	/* start time */ 
    unsigned long       start_time_us;         /* start time us */
    struct pack_date    end_time;	/* end time */ 
    unsigned long       end_time_us;           /* end time us */
    unsigned long	    total_trap_counts;	/* total trace trap counts */ 
    unsigned long	    recv_msg_counts;	/* recv message counts */ 
    unsigned long	    send_msg_counts;	/* send message counts */ 
    unsigned long	    err_log_counts;	    /* error log counts */ 
    unsigned long	    info_log_counts;	/* info log counts */ 
}_trans_trace_obj;

#define TRANS_TRC_START( trans ) ( trans_get_trace_flag(trans)?trans_trace_start( trans ):0)
#define TRANS_TRC_STOP( trans ) ( trans_get_trace_flag(trans)?trans_trace_stop( trans ):0)

#define TRANS_TRC_INFO( PARAM ) \
    ((trans_get_trace_flag(trans)& trace_flag_mask_info && trans_get_trace_obj(trans) )?\
        ++trans_get_trace_obj(trans)->info_log_counts && \
        trace( comp_get_trace_cb(trans_get_comp(trans)),\
               trace_flag_mask_info,\
               trace_sprintf PARAM,\
               __FILE__,\
               __LINE__,\
               comp_get_id(trans_get_comp(trans)),\
               trans_get_local_handle(trans),\
               trans_get_reply(trans),\
               trans_get_reply_handle(trans),\
               &trans_get_trace_obj(trans)->index):0)

#define TRANS_TRC_ERR( PARAM ) \
    ((trans_get_trace_flag(trans)& trace_flag_mask_err && trans_get_trace_obj(trans) )?\
        ++trans_get_trace_obj(trans)->err_log_counts && \
        trace( comp_get_trace_cb(trans_get_comp(trans)),\
               trace_flag_mask_err,\
               trace_sprintf PARAM,\
               __FILE__,\
               __LINE__,\
               comp_get_id(trans_get_comp(trans)),\
               trans_get_local_handle(trans),\
               trans_get_reply(trans),\
               trans_get_reply_handle(trans),\
               &trans_get_trace_obj(trans)->index):0)

#define TRANS_TRC_MSG( MSG ) \
    ((trans_get_trace_flag(trans)& trace_flag_mask_msg && trans_get_trace_obj(trans) )?\
        trans_trace_msg(trans, MSG, __FILE__, __LINE__ ):0)

extern long trans_trace_start( struct trans_obj *trans );
extern long trans_trace_stop( struct trans_obj *trans );
extern long trans_trace_msg( struct trans_obj *trans, struct message *msg, const char *file, unsigned long line );
/*-----------------------Trans trace part end-------------------------------*/
 
#endif /* !defined(__msg_transaction_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
