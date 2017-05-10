/*!
\file       utp.h
\brief      

*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__utp_link_h__)
#define __utp_link_h__

#include <stdio.h>

/* link state */
#define UTP_LINK_STATE_OUTGOING_WAIT_TUNNEL       1
#define UTP_LINK_STATE_INCOMING_WAIT_ACCEPT       2
#define UTP_LINK_STATE_OUTGOING_WAIT_ACCEPT       3
#define UTP_LINK_STATE_CONNECTED                  4

/* link notify type */
#define UTP_LINK_NOTIFY_TYPE_SEND_READY           1
#define UTP_LINK_NOTIFY_TYPE_LINK_DESTROY         2
#define UTP_LINK_NOTIFY_TYPE_MODIFY_BANDWIDTH     3
#define UTP_LINK_NOTIFY_TYPE_OVERLOAD_WARN        11
#define UTP_LINK_NOTIFY_TYPE_OVERLOAD_REMOVE      12
#define UTP_LINK_NOTIFY_TYPE_OVERLOAD_DISCARD     13

#define UTP_LINK_OVERLOAD_TIME_MAX_DEFAULT        10000
#define UTP_LINK_OVERLOAD_TIME_HIGH_DEFAULT       7000
#define UTP_LINK_OVERLOAD_TIME_LOWER_DEFAULT      2000

#define UTP_LINK_OVERLOAD_SIZE_MAX_DEFAULT        0x4000000
#define UTP_LINK_OVERLOAD_SIZE_HIGH_DEFAULT       0x3000000
#define UTP_LINK_OVERLOAD_SIZE_LOWER_DEFAULT      0x1000000

/* link msg type( link == 0. else mean msg_data ). */
#define UTP_LINK_MSG_TYPE_CONNECT                 1
#define UTP_LINK_MSG_TYPE_CONNECT_ACK             2
#define UTP_LINK_MSG_TYPE_RELEASE                 3
#define UTP_LINK_MSG_TYPE_FORWARD                 10
#define UTP_LINK_MSG_TYPE_FORWARD_ACK             11

/* link id mask */
#define UTP_LINK_ID_MASK_INVITER                  0x80000000      /* 1:inviter part; 0:invited part */
#define UTP_LINK_ID_MASK_BIG_P2PID                0x40000000      /* 1:inviter have big p2pid; 0:invited have little p2pid */

#define utp_link_manage_format_s    "%p[%4.4s]{%s<-->%s}"
#define utp_link_manage_format( _cb )  \
                (_cb), (_cb)?(char*)&(_cb)->magic:0,\
                (utp_cb_check_valid( (_cb), LINK_MANAGE_CB )&&utp_cb_check_valid( (_cb)->tunnel_cb, TUNNEL_CB ))?(_cb)->tunnel_cb->cb->p2pid.data:NULL,\
                (utp_cb_check_valid( (_cb), LINK_MANAGE_CB )&&utp_cb_check_valid( (_cb)->tunnel_cb, TUNNEL_CB ))?(_cb)->tunnel_cb->remote_p2pid.data:NULL

#define utp_link_format_s    "%p[%4.4s]{%s<-->%s[0x%lx]}]"
#define utp_link_format( _cb )  \
                (_cb), (_cb)?(char*)&(_cb)->magic:0,\
                ( utp_cb_check_valid( (_cb), LINK_CB ) && utp_cb_check_valid( (_cb)->link_manage_cb, LINK_MANAGE_CB ) && utp_cb_check_valid( (_cb)->link_manage_cb->tunnel_cb, TUNNEL_CB ))?(_cb)->link_manage_cb->tunnel_cb->cb->p2pid.data:NULL,\
                ( utp_cb_check_valid( (_cb), LINK_CB ) && utp_cb_check_valid( (_cb)->link_manage_cb, LINK_MANAGE_CB ) && utp_cb_check_valid( (_cb)->link_manage_cb->tunnel_cb, TUNNEL_CB ))?(_cb)->link_manage_cb->tunnel_cb->remote_p2pid.data:NULL,\
                ( utp_cb_check_valid( (_cb), LINK_CB ) && utp_cb_check_valid( (_cb)->link_manage_cb, LINK_MANAGE_CB ) && utp_cb_check_valid( (_cb)->link_manage_cb->tunnel_cb, TUNNEL_CB ))?(_cb)->link_id:0

/* link_manage section */
#define UTP_MAGIC_LINK_MANAGE_CB_ACTIVE          (*(long*)"lkma    ")
#define UTP_MAGIC_LINK_MANAGE_CB_INACTIVE        (*(long*)"lkmi    ")
#define UTP_MAGIC_LINK_MANAGE_CB_FREE            (*(long*)"lkmf    ")
typedef struct utp_link_manage_cb
{
    char                    magic[sizeof(long)];    /*!< magic */
    struct utp_tunnel_cb    *tunnel_cb;             /*!< tunnel cb */
    struct hash_map         *map_link_cb;           /*!< link_cb map */
    unsigned long           latest_link_id;         /*!< latest link_id allocate local */
    unsigned long           bw_auto_detect;         /*!< detect bw that request zero */
    unsigned long           bw_req_min;             /*!< request bandwidth min */
    unsigned long           bw_req_max;             /*!< request bandwidth max */
    unsigned long           bw_valid;               /*!< current valid bandwidth */
    unsigned long           bw_notify_counts;       /*!< bw notify counts recv from tunnel */
    unsigned long           unlimited_bandwidth;    /*!< unlimited bandwidth */

    struct
    {
        struct utp_link_manage_cb   *prev;
        struct utp_link_manage_cb   *next;
    }delay_destroy_node;                                          /*!< node in inactive utp_link list */
    long                        ref_counts;
}_utp_link_manage_cb;

/* link section */
struct utp_link_notify;
typedef long (*utp_link_on_data)( struct utp_link_cb *link_cb, void *ref, char *data, int len );
typedef long (*utp_link_on_notify)( struct utp_link_cb *link_cb, void *ref, struct utp_link_notify *notify );

typedef struct utp_link_create_param
{
    struct utp_link_manage_cb *link_manage_cb;    /*!< utp link_manage_cb. */

    unsigned long           link_id;                /*!< link_id. utp module use internal, user module no need care */
    
    struct utp_cb           *cb;                    /*!< utp cb */
    struct len_str          remote_p2pid;           /*!< remote p2pid */
    struct len_str          remote_addr;            /*!< utp remote addr */
    unsigned long           remote_port;            /*!< utp remote port */
    struct len_str          proxy_addr;             /*!< utp server ip or domain */
    unsigned long           proxy_port;             /*!< utp server local_port */
    long                    enable_confusion;       /*!< Indicate whether enabel confusion */

    unsigned long           min_kbps;               /*!< request bandwidth min */
    unsigned long           max_kbps;               /*!< request bandwidth max */
    unsigned long           urgent;                 /*!< urgent flag */

    unsigned long           overload_size_max;      /*!< overload size(byte) threahold for start discard */
    unsigned long           overload_size_high;     /*!< overload size(byte) threahold for overload warn */
    unsigned long           overload_size_lower;    /*!< overload size(byte) threahold for remove overload warn */
    unsigned long           overload_time_max;      /*!< overload time(ms) threahold for start discard */
    unsigned long           overload_time_high;     /*!< overload time(ms) threahold for overload warn */
    unsigned long           overload_time_lower;    /*!< overload time(ms) threahold for remove overload warn */

    utp_link_on_data        on_data;                /*!< callback to process arrive data */
    utp_link_on_notify      on_notify;              /*!< callback to process utp_link_notify */
    void                    *refer;                 /*!< refer of user module */
    unsigned long           data_len;               /*!< user data len */
    char                    *data;                  /*!< user data */

    long                    dump_sample;
    struct len_str          dump_sample_path;
    long                    dump_sample_counts;
}_utp_link_create_param;

#define UTP_FORWARD_REFER_SIZE      8
typedef struct utp_link_forward_param
{
    struct utp_link_manage_cb *link_manage_cb;    /*!< utp link_manage_cb. */

    uint32_t                flag_ack;               /*!< Whether need ack when data arrive dst */
    unsigned char           refer[UTP_FORWARD_REFER_SIZE];  /*!< refer */
    struct len_str          to_p2pid;               /*!< to p2pid */
    unsigned long           data_len;               /*!< user data len */
    char                    *data;                  /*!< user data */
}_utp_link_forward_param;

typedef struct utp_link_get_param
{
    struct utp_link_manage_cb *link_manage_cb;    /*!< utp link_manage_cb. utp module use internal, user module no need care */
    
    struct utp_cb           *cb;                    /*!< utp cb */
    struct len_str          remote_p2pid;           /*!< remote p2pid */
    
    unsigned long           link_id;                /*!< link_id */
}_utp_link_get_param;


typedef struct utp_link_accept_param
{
    struct utp_link_cb      *link_cb;               /*!< utp link_cb */

    unsigned long           overload_size_max;      /*!< overload size(byte) threahold for start discard */
    unsigned long           overload_size_high;     /*!< overload size(byte) threahold for overload warn */
    unsigned long           overload_size_lower;    /*!< overload size(byte) threahold for remove overload warn */
    unsigned long           overload_time_max;      /*!< overload time(ms) threahold for start discard */
    unsigned long           overload_time_high;     /*!< overload time(ms) threahold for overload warn */
    unsigned long           overload_time_lower;    /*!< overload time(ms) threahold for remove overload warn */

    utp_link_on_data        on_data;                /*!< callback to process arrive data */
    utp_link_on_notify      on_notify;              /*!< callback to process utp_link_notify */
    void                    *refer;                 /*!< refer of user module */
    unsigned long           min_kbps;               /*!< request bandwidth min */
    unsigned long           max_kbps;               /*!< request bandwidth max */
    unsigned long           urgent;                 /*!< urgent flag */
}_utp_link_accept_param;

typedef struct utp_link_bw_cb
{
    unsigned long           tick_monitor_start;     /* Tick for start monitor dequeue_speed and delay and loss rate */
    unsigned long           tick_count_start;       /* Tick for calculate start */
    unsigned long           monitor_start;          /* Indicate whether monitor have start */

    unsigned long           min_kbps;               /*!< min bandwidth(kbps) that user config */
    unsigned long           max_kbps;               /*!< max bandwidth(kbps) that user config */
    unsigned long           notify_bandwidth;       /*!< latest notify enqueue speed( kbps ) */
    unsigned long           modify_bandwidth_counts;/*!< counts to notify user module modify bandwidth */

    unsigned long           overload_size_max;      /*!< overload size(byte) threahold for start discard */
    unsigned long           overload_size_high;     /*!< overload size(byte) threahold for overload warn */
    unsigned long           overload_size_lower;    /*!< overload size(byte) threahold for remove overload warn */

    unsigned long           counts_in_queue;        /*!< sending data counts */
    unsigned long           size_in_queue;          /*!< sending data size */

    unsigned long           overload;               /*!< flag to indicate link is overload now */

    unsigned long           current_slot;           /* current slot */
    unsigned long           enqueue_size_record[UTP_BW_CALC_SLOT_COUNTS];     /* total pack size dequeue this calc peroid */
    unsigned long           enqueue_speed_average;                              /* average dequeue speed */
}_utp_link_bw_cb;

#define UTP_MAGIC_LINK_CB_ACTIVE          (*(long*)"lnka    ")
#define UTP_MAGIC_LINK_CB_INACTIVE        (*(long*)"lnki    ")
#define UTP_MAGIC_LINK_CB_FREE            (*(long*)"lnkf    ")
typedef struct utp_link_cb
{
    char                    magic[sizeof(long)];    /*!< magic */
    struct utp_link_manage_cb *link_manage_cb;    /*!< utp_link_manage_cb */
    unsigned long           link_id;                /*!< link id */
    utp_link_on_data        on_data;                /*!< callback to process arrive data */
    utp_link_on_notify      on_notify;              /*!< callback to process utp_link_notify */
    void                    *refer;                 /*!< refer of user module */
    unsigned long           state;                  /*!< link state */
    unsigned long           data_len;               /*!< user data len */
    char                    *data;                  /*!< user data */
    unsigned long           urgent;                 /*!< urgent flag */

    unsigned long           overload_size_max;      /*!< overload size(byte) threahold for start discard */
    unsigned long           overload_size_high;     /*!< overload size(byte) threahold for overload warn */
    unsigned long           overload_size_lower;    /*!< overload size(byte) threahold for remove overload warn */
    unsigned long           overload_time_max;      /*!< overload time(ms) threahold for start discard */
    unsigned long           overload_time_high;     /*!< overload time(ms) threahold for overload warn */
    unsigned long           overload_time_lower;    /*!< overload time(ms) threahold for remove overload warn */

    unsigned long           remote_link_id;         /*!< remote link id. can be calculate */
    
    struct
    {
        struct utp_link_cb  *prev;
        struct utp_link_cb  *next;
    }delay_destroy_node;                                          /*!< node in inactive utp_link list */
    
    struct
    {
        unsigned long       counts;
        struct utp_link_suspend_cb    *list;
    }suspend_list;                                  /*!< suspend list */

    /* send section */
    unsigned long           send_counts;            /*!< send data counts */
    unsigned long           send_size;              /*!< send total size */
    unsigned long           reject_counts;          /*!< send reject counts( delay is large than reject threshold ) */

    /* Receive section */
    unsigned long           recv_counts;            /*!< receive data counts */
    unsigned long           recv_size;              /*!< receive data size */

    struct utp_link_bw_cb bw_cb;                  /*!< bandwidth cb */
    long                        ref_counts;
}_utp_link_cb;

typedef struct utp_link_suspend_cb
{
    unsigned long           data_len;              /*!< msg_data_size and pack head size */
    struct
    {
        struct utp_link_suspend_cb    *prev;
        struct utp_link_suspend_cb    *next;
    }node;                                          /*!< send cb list node */
    char                    cdata[0];  /*!< buffer to store pack */
}_utp_link_suspend_cb;

typedef struct utp_link_msg
{
    uint32_t                link_id;                /*!< link_id, 0 indicate control message */
    char                    cdata[0];               /*!< messag array */
}_utp_link_msg;

typedef struct utp_link_ctrl_msg
{
    uint32_t                type;                   /*!< control message type */
    char                    cdata[0];               /*!< p2pid data */
}_utp_link_ctrl_msg;

typedef struct utp_link_msg_connect
{
    uint32_t                inviter_link_id;        /*!< inviter part link_id */
    uint32_t                len;                    /*!< cdata len */
    char                    cdata[0];               /*!< p2pid data */
}_utp_link_msg_connect;

typedef struct utp_link_msg_connect_ack
{
    uint32_t                inviter_link_id ;       /*!< inviter part link_id */
    uint32_t                invited_link_id;        /*!< invited part link_id */
}_utp_link_msg_connect_ack;

typedef struct utp_link_msg_forward
{
    uint32_t                from_p2pid_len;         /*!< from p2p id length */
    uint32_t                to_p2pid_len;           /*!< to p2p id length */
    uint32_t                flag_ack;               /*!< Whether need ack when data arrive dst */
    unsigned char           refer[UTP_FORWARD_REFER_SIZE];  /*!< refer */
    uint32_t                data_len;               /*!< forward data len */
    char                    cdata[0];               /*!< data */
}_utp_link_msg_forward;

typedef struct utp_link_msg_forward_ack
{
    uint32_t                from_p2pid_len;         /*!< from p2p id length */
    uint32_t                to_p2pid_len;           /*!< to p2p id length */
    unsigned char           refer[UTP_FORWARD_REFER_SIZE];  /*!< refer */
    uint32_t                data_len;               /*!< data len. 0 Indicate forward ok */
    char                    cdata[0];               /*!< data */
}_utp_link_msg_forward_ack;

#define utp_link_forward_err_proxy_disable_proxy      "proxy.disabel_proxy"
#define utp_link_forward_err_proxy_forward_fail       "proxy.forward_fail"
#define utp_link_forward_err_to_offline               "to.offline"
#define utp_link_forward_err_to_no_reader             "to.no_reader"

typedef struct utp_link_msg_release
{
    uint32_t                link_id;                /*!< link_id */
}_utp_link_msg_release;

typedef struct utp_link_notify
{
    int                     notify_type;            /*!< notify type */
    unsigned long           bandwidth;              /*!< expect bandwidth */
}_utp_link_notify;

extern long utp_link_accept( struct utp_link_accept_param *param );
extern struct utp_link_cb * utp_link_create( struct utp_link_create_param *param );
extern long utp_link_forward( struct utp_link_forward_param *param );
extern long utp_link__send_msg_forward( struct utp_link_manage_cb *link_manage_cb, struct len_str *from_p2pid, struct len_str *to_p2pid, char *refer, char *data, long data_len, long flag_ack );
extern long utp_link__send_msg_forward_ack( struct utp_link_manage_cb *link_manage_cb, struct len_str *from_p2pid, struct len_str *to_p2pid, char *refer, char *data, long data_len );
extern long utp_link__on_msg_forward( struct utp_link_manage_cb *link_manage_cb, struct utp_link_msg_forward *link_msg_forward );
extern long utp_link__on_msg_forward_ack( struct utp_link_manage_cb *link_manage_cb, struct utp_link_msg_forward_ack *link_msg_forward_ack );
extern long utp_link_destroy( struct utp_link_cb *link_cb );
extern struct utp_link_cb * utp_link_get( struct utp_link_get_param *param );
extern long utp_link_manage_on_tunnel_create( void *ref, struct utp_tunnel_cb *tunnel_cb );
extern struct utp_link_manage_cb * utp_link_manage__create( struct utp_tunnel_cb *tunnel_cb );
extern long utp_link_manage__destroy( struct utp_link_manage_cb *link_manage_cb );
extern long utp_link_manage__modify_bandwidth( struct utp_link_manage_cb *link_manage_cb );
extern long utp_link_manage__on_tunnel_data( struct utp_link_manage_cb *link_manage_cb, char *data, int len );
extern long utp_link_manage__on_tunnel_notify( struct utp_link_manage_cb *link_manage_cb, struct utp_tunnel_notify *notify );
extern long utp_link_send( struct utp_link_cb *link_cb, const char *buf1, int buf_len1, const char *buf2, int buf_len2 );
extern long  utp_link__accept( struct utp_link_accept_param *param );
extern long utp_link__adjust_param( struct utp_link_cb *link_cb );
extern long utp_link__bw_calc( struct utp_link_cb *link_cb );
extern struct utp_link_cb * utp_link__create( struct utp_link_create_param *param );
extern long utp_link__dequeue_counts( struct utp_link_cb *link_cb, unsigned long data_size );
extern long utp_link__destroy( struct utp_link_cb *link_cb );
extern long utp_link__enqueue_counts( struct utp_link_cb *link_cb, unsigned long data_size );
extern struct utp_link_cb * utp_link__get( struct utp_link_get_param *param );
extern long utp_link__inactive( struct utp_link_cb *link_cb, unsigned long send_notfiy );
extern long utp_link__on_msg_connect( struct utp_link_manage_cb *link_manage_cb, struct utp_link_msg_connect *link_msg_connect );
extern long utp_link__on_msg_connect_ack( struct utp_link_manage_cb *link_manage_cb, struct utp_link_msg_connect_ack *link_msg_connect_ack );
extern long utp_link__on_msg_data( struct utp_link_cb *link_cb, char *data, unsigned long data_len );
extern long utp_link__on_msg_release( struct utp_link_manage_cb *link_manage_cb, struct utp_link_msg_release *link_msg_release );
extern long utp_link__send_msg_connect( struct utp_link_cb *link_cb );
extern long utp_link__send_msg_connect_ack( struct utp_link_cb *link_cb );
extern long utp_link__send_msg_data( struct utp_link_cb *link_cb, const char *buf1, int buf_len1, const char *buf2, int buf_len2 );
extern long utp_link__send_msg_release( struct utp_link_cb *link_cb );
extern long utp_link__set_link_state( struct utp_link_cb *link_cb, unsigned long state );
extern long utp_link_get_status( struct utp_link_cb *link_cb, char *buffer, long *buffer_size );

#endif /* !defined(__utp_link_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
