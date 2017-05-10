/*!
\file       p2pex.h
\brief      

*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__p2pex_link_h__)
#define __p2pex_link_h__

#include <stdio.h>

/* link state */
#define P2PEX_LINK_STATE_OUTGOING_WAIT_TUNNEL       1
#define P2PEX_LINK_STATE_INCOMING_WAIT_ACCEPT       2
#define P2PEX_LINK_STATE_OUTGOING_WAIT_ACCEPT       3
#define P2PEX_LINK_STATE_CONNECTED                  4

/* link notify type */
#define P2PEX_LINK_NOTIFY_TYPE_SEND_READY           1
#define P2PEX_LINK_NOTIFY_TYPE_LINK_DESTROY         2
#define P2PEX_LINK_NOTIFY_TYPE_MODIFY_BANDWIDTH     3
#define P2PEX_LINK_NOTIFY_TYPE_OVERLOAD_WARN        11
#define P2PEX_LINK_NOTIFY_TYPE_OVERLOAD_REMOVE      12
#define P2PEX_LINK_NOTIFY_TYPE_OVERLOAD_DISCARD     13

#define P2PEX_LINK_OVERLOAD_TIME_MAX_DEFAULT        10000
#define P2PEX_LINK_OVERLOAD_TIME_HIGH_DEFAULT       7000
#define P2PEX_LINK_OVERLOAD_TIME_LOWER_DEFAULT      2000
#define P2PEX_LINK_OVERLOAD_SIZE_MAX_DEFAULT        0x4000000
#define P2PEX_LINK_OVERLOAD_SIZE_HIGH_DEFAULT       0x3000000
#define P2PEX_LINK_OVERLOAD_SIZE_LOWER_DEFAULT      0x1000000

/* link msg type( link == 0. else mean msg_data ). */
#define P2PEX_LINK_MSG_TYPE_CONNECT                 1
#define P2PEX_LINK_MSG_TYPE_CONNECT_ACK             2
#define P2PEX_LINK_MSG_TYPE_RELEASE                 3
#define P2PEX_LINK_MSG_TYPE_KEEPLIVE                4

/* link id mask */
#define P2PEX_LINK_ID_MASK_INVITER                  0x80000000      /* 1:inviter part; 0:invited part */
#define P2PEX_LINK_ID_MASK_BIG_P2PID                0x40000000      /* 1:inviter have big p2pid; 0:inviter have little p2pid */

#define p2pex_link_manage_format_s    "%p[%4.4s]{%s<-->%s}"
#define p2pex_link_manage_format( _cb )  \
                (_cb), (_cb)?(char*)&(_cb)->magic:0,\
                (p2pex_cb_check_valid( (_cb), LINK_MANAGE_CB )&&p2pex_cb_check_valid( (_cb)->tunnel_cb, TUNNEL_CB ))?(_cb)->tunnel_cb->cb->p2pid.data:NULL,\
                (p2pex_cb_check_valid( (_cb), LINK_MANAGE_CB )&&p2pex_cb_check_valid( (_cb)->tunnel_cb, TUNNEL_CB ))?(_cb)->tunnel_cb->remote_p2pid.data:NULL

#define p2pex_link_format_s    "%p[%4.4s]{%s<-->%s[0x%lx]}"
#define p2pex_link_format( _cb )  \
                (_cb), (_cb)?(char*)&(_cb)->magic:0,\
                ( p2pex_cb_check_valid( (_cb), LINK_CB ) && p2pex_cb_check_valid( (_cb)->link_manage_cb, LINK_MANAGE_CB ) && p2pex_cb_check_valid( (_cb)->link_manage_cb->tunnel_cb, TUNNEL_CB ))?(_cb)->link_manage_cb->tunnel_cb->cb->p2pid.data:NULL,\
                ( p2pex_cb_check_valid( (_cb), LINK_CB ) && p2pex_cb_check_valid( (_cb)->link_manage_cb, LINK_MANAGE_CB ) && p2pex_cb_check_valid( (_cb)->link_manage_cb->tunnel_cb, TUNNEL_CB ))?(_cb)->link_manage_cb->tunnel_cb->remote_p2pid.data:NULL,\
                ( p2pex_cb_check_valid( (_cb), LINK_CB ) && p2pex_cb_check_valid( (_cb)->link_manage_cb, LINK_MANAGE_CB ) && p2pex_cb_check_valid( (_cb)->link_manage_cb->tunnel_cb, TUNNEL_CB ))?((long)(_cb)->link_id):((long)0)

/* link_manage section */
#define P2PEX_MAGIC_LINK_MANAGE_CB_ACTIVE          (*(long*)"lkma    ")
#define P2PEX_MAGIC_LINK_MANAGE_CB_INACTIVE        (*(long*)"lkmi    ")
#define P2PEX_MAGIC_LINK_MANAGE_CB_FREE            (*(long*)"lkmf    ")
typedef struct p2pex_link_manage_cb
{
    char                    magic[sizeof(long)];    /*!< magic */
    struct p2pex_tunnel_cb  *tunnel_cb;             /*!< tunnel cb */
    struct hash_map         *map_link_cb;           /*!< link_cb map */
    uint32_t                latest_link_id;         /*!< latest link_id allocate local */
    unsigned long           bw_auto_detect;         /*!< detect bw that request zero */
    unsigned long           bw_req_min;             /*!< request bandwidth min */
    unsigned long           bw_req_max;             /*!< request bandwidth max */
    unsigned long           bw_valid;               /*!< current valid bandwidth */
    unsigned long           bw_notify_counts;       /*!< bw notify counts recv from tunnel */
    unsigned long           unlimited_bandwidth;    /*!< unlimited bandwidth */

    struct
    {
        struct p2pex_link_manage_cb   *prev;
        struct p2pex_link_manage_cb   *next;
    }delay_destroy_node;                                          /*!< node in inactive p2pex_link list */
    long                        ref_counts;
}_p2pex_link_manage_cb;

/* link section */
struct p2pex_link_notify;
typedef long (*p2pex_link_on_data)( struct p2pex_link_cb *link_cb, void *ref, char *data, int len );
typedef long (*p2pex_link_on_notify)( struct p2pex_link_cb *link_cb, void *ref, struct p2pex_link_notify *notify );

typedef struct p2pex_link_create_param
{
    struct p2pex_link_manage_cb *link_manage_cb;    /*!< p2pex link_manage_cb. */

    unsigned long           link_id;                /*!< link_id. p2pex module use internal, user module no need care */
    
    struct p2pex_cb         *cb;                    /*!< p2pex cb */
    struct len_str          remote_p2pid;           /*!< remote p2pid */
    struct len_str          remote_addr;            /*!< p2pex remote addr */
    unsigned long           remote_port;            /*!< p2pex remote port */
    struct len_str          proxy_addr;             /*!< p2pex server ip or domain */
    unsigned long           proxy_port;             /*!< p2pex server local_port */

    unsigned long           min_kbps;               /*!< request bandwidth min */
    unsigned long           max_kbps;               /*!< request bandwidth max */
    unsigned long           urgent;                 /*!< urgent flag */
    unsigned long           keeplive_interval;      /*!< timer len for send keeplive */

    unsigned long           overload_size_max;      /*!< overload size(byte) threahold for start discard */
    unsigned long           overload_size_high;     /*!< overload size(byte) threahold for overload warn */
    unsigned long           overload_size_lower;    /*!< overload size(byte) threahold for remove overload warn */
    unsigned long           overload_time_max;      /*!< overload time(ms) threahold for start discard */
    unsigned long           overload_time_high;     /*!< overload time(ms) threahold for overload warn */
    unsigned long           overload_time_lower;    /*!< overload time(ms) threahold for remove overload warn */
    unsigned long           packet_speed_max;       /*!< max packet per second */

    p2pex_link_on_data      on_data;                /*!< callback to process arrive data */
    p2pex_link_on_notify    on_notify;              /*!< callback to process p2pex_link_notify */
    void                    *refer;                 /*!< refer of user module */
    unsigned long           data_len;               /*!< user data len */
    char                    *data;                  /*!< user data */
}_p2pex_link_create_param;

typedef struct p2pex_link_get_param
{
    struct p2pex_link_manage_cb *link_manage_cb;    /*!< p2pex link_manage_cb. p2pex module use internal, user module no need care */
    
    struct p2pex_cb         *cb;                    /*!< p2pex cb */
    struct len_str          remote_p2pid;           /*!< remote p2pid */
    
    unsigned long           link_id;                /*!< link_id */
}_p2pex_link_get_param;


typedef struct p2pex_link_accept_param
{
    struct p2pex_link_cb    *link_cb;               /*!< p2pex link_cb */

    unsigned long           overload_size_max;      /*!< overload size(byte) threahold for start discard */
    unsigned long           overload_size_high;     /*!< overload size(byte) threahold for overload warn */
    unsigned long           overload_size_lower;    /*!< overload size(byte) threahold for remove overload warn */
    unsigned long           overload_time_max;      /*!< overload time(ms) threahold for start discard */
    unsigned long           overload_time_high;     /*!< overload time(ms) threahold for overload warn */
    unsigned long           overload_time_lower;    /*!< overload time(ms) threahold for remove overload warn */
    unsigned long           packet_speed_max;       /*!< max packet per second */

    p2pex_link_on_data      on_data;                /*!< callback to process arrive data */
    p2pex_link_on_notify    on_notify;              /*!< callback to process p2pex_link_notify */
    void                    *refer;                 /*!< refer of user module */
    unsigned long           min_kbps;               /*!< request bandwidth min */
    unsigned long           max_kbps;               /*!< request bandwidth max */
    unsigned long           urgent;                 /*!< urgent flag */
    unsigned long           keeplive_interval;     /*!< timer len for send keeplive */
}_p2pex_link_accept_param;

typedef struct p2pex_link_bw_cb
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

    unsigned long           overload_counts_max;    /*!< overload counts threahold for start discard */
    unsigned long           overload_counts_high;   /*!< overload counts threahold for overload warn */
    unsigned long           overload_counts_lower;  /*!< overload counts threahold for remove overload warn */

    unsigned long           counts_in_queue;        /*!< sending data counts */
    unsigned long           size_in_queue;          /*!< sending data size */

    unsigned long           overload;               /*!< flag to indicate link is overload now */

    unsigned long           current_slot;           /* current slot */
    unsigned long           enqueue_size_record[P2PEX_BW_CALC_SLOT_COUNTS];     /* total pack size dequeue this calc peroid */
    unsigned long           enqueue_speed_average;                              /* average dequeue speed */
}_p2pex_link_bw_cb;

#define P2PEX_MAGIC_LINK_CB_ACTIVE          (*(long*)"lnka    ")
#define P2PEX_MAGIC_LINK_CB_INACTIVE        (*(long*)"lnki    ")
#define P2PEX_MAGIC_LINK_CB_FREE            (*(long*)"lnkf    ")
typedef struct p2pex_link_cb
{
    char                    magic[sizeof(long)];    /*!< magic */
    struct p2pex_link_manage_cb *link_manage_cb;    /*!< p2pex_link_manage_cb */
    p2pex_link_on_data      on_data;                /*!< callback to process arrive data */
    p2pex_link_on_notify    on_notify;              /*!< callback to process p2pex_link_notify */
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
    unsigned long           packet_speed_max;       /*!< max packet per second */

    unsigned long           link_id;                /*!< link id */
    unsigned long           remote_link_id;         /*!< remote link id. can be calculate */
    
    struct
    {
        struct p2pex_link_cb   *prev;
        struct p2pex_link_cb   *next;
    }delay_destroy_node;                                          /*!< node in inactive p2pex_link list */
    
    struct
    {
        unsigned long       counts;
        struct p2pex_link_suspend_cb    *list;
    }suspend_list;                                  /*!< suspend list */

    /* send section */
    unsigned long           send_counts;            /*!< send data counts */
    unsigned long           send_size;              /*!< send total size */
    unsigned long           reject_counts;          /*!< send reject counts( delay is large than reject threshold ) */

    unsigned long           tick_recent_data;       /*!< local tick of receive or send data*/
    unsigned long           keeplive_interval;     /*!< timer len for send keeplive */
    struct timer_ex         *timer_keeplive;        /*!< timer for connect */

    /* Receive section */
    unsigned long           recv_counts;            /*!< receive data counts */
    unsigned long           recv_size;              /*!< receive data size */

    struct p2pex_link_bw_cb bw_cb;                  /*!< bandwidth cb */
    long                        ref_counts;
}_p2pex_link_cb;

typedef struct p2pex_link_suspend_cb
{
    unsigned long           data_len;              /*!< msg_data_size and pack head size */
    struct
    {
        struct p2pex_link_suspend_cb    *prev;
        struct p2pex_link_suspend_cb    *next;
    }node;                                          /*!< send cb list node */
    char                    cdata[0];  /*!< buffer to store pack */
}_p2pex_link_suspend_cb;

typedef struct p2pex_link_msg
{
    uint32_t                link_id;                /*!< link_id, 0 indicate control message */
    char                    cdata[0];               /*!< messag array */
}_p2pex_link_msg;

typedef struct p2pex_link_ctrl_msg
{
    uint32_t                type;                   /*!< control message type */
    char                    cdata[0];               /*!< p2pid data */
}_p2pex_link_ctrl_msg;

typedef struct p2pex_link_msg_connect
{
    uint32_t                inviter_link_id;        /*!< inviter part link_id */
    uint32_t                len;                    /*!< cdata len */
    char                    cdata[0];               /*!< p2pid data */
}_p2pex_link_msg_connect;

typedef struct p2pex_link_msg_connect_ack
{
    uint32_t                inviter_link_id ;       /*!< inviter part link_id */
    uint32_t                invited_link_id;        /*!< invited part link_id */
}_p2pex_link_msg_connect_ack;

typedef struct p2pex_link_msg_release
{
    uint32_t                link_id;                /*!< link_id */
}_p2pex_link_msg_release;

typedef struct p2pex_link_msg_keeplive
{
    uint32_t                link_id;                /*!< link_id */
}_p2pex_link_msg_keeplive;

typedef struct p2pex_link_notify
{
    int                     notify_type;            /*!< notify type */
    unsigned long           bandwidth;              /*!< expect bandwidth */
}_p2pex_link_notify;

extern long p2pex_link_accept( struct p2pex_link_accept_param *param );
extern struct p2pex_link_cb * p2pex_link_create( struct p2pex_link_create_param *param );
extern long p2pex_link_destroy( struct p2pex_link_cb *link_cb );
extern struct p2pex_link_cb * p2pex_link_get( struct p2pex_link_get_param *param );
extern long p2pex_link_manage_on_tunnel_create( void *ref, struct p2pex_tunnel_cb *tunnel_cb );
extern struct p2pex_link_manage_cb * p2pex_link_manage__create( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_link_manage__destroy( struct p2pex_link_manage_cb *link_manage_cb );
extern long p2pex_link_manage__modify_bandwidth( struct p2pex_link_manage_cb *link_manage_cb );
extern long p2pex_link_manage__on_tunnel_data( struct p2pex_link_manage_cb *link_manage_cb, char *data, int len );
extern long p2pex_link_manage__on_tunnel_notify( struct p2pex_link_manage_cb *link_manage_cb, struct p2pex_tunnel_notify *notify );
extern long p2pex_link_send( struct p2pex_link_cb *link_cb, const char *buf1, int buf_len1, const char *buf2, int buf_len2 );
extern long  p2pex_link__accept( struct p2pex_link_accept_param *param );
extern long p2pex_link__adjust_param( struct p2pex_link_cb *link_cb );
extern long p2pex_link__bw_calc( struct p2pex_link_cb *link_cb );
extern struct p2pex_link_cb * p2pex_link__create( struct p2pex_link_create_param *param );
extern long p2pex_link__dequeue_counts( struct p2pex_link_cb *link_cb, unsigned long data_size );
extern long p2pex_link__destroy( struct p2pex_link_cb *link_cb );
extern long p2pex_link__enqueue_counts( struct p2pex_link_cb *link_cb, unsigned long data_size );
extern struct p2pex_link_cb * p2pex_link__get( struct p2pex_link_get_param *param );
extern long p2pex_link__inactive( struct p2pex_link_cb *link_cb, unsigned long send_notfiy );
extern long p2pex_link__on_msg_connect( struct p2pex_link_manage_cb *link_manage_cb, struct p2pex_link_msg_connect *link_msg_connect );
extern long p2pex_link__on_msg_connect_ack( struct p2pex_link_manage_cb *link_manage_cb, struct p2pex_link_msg_connect_ack *link_msg_connect_ack );
extern long p2pex_link__on_msg_data( struct p2pex_link_cb *link_cb, char *data, unsigned long data_len );
extern long p2pex_link__on_msg_release( struct p2pex_link_manage_cb *link_manage_cb, struct p2pex_link_msg_release *link_msg_release );
extern long p2pex_link__on_msg_keeplive( struct p2pex_link_manage_cb *link_manage_cb, struct p2pex_link_msg_keeplive *link_msg_keeplive );
extern long p2pex_link__send_msg_connect( struct p2pex_link_cb *link_cb );
extern long p2pex_link__send_msg_connect_ack( struct p2pex_link_cb *link_cb );
extern long p2pex_link__send_msg_data( struct p2pex_link_cb *link_cb, const char *buf1, int buf_len1, const char *buf2, int buf_len2 );
extern long p2pex_link__send_msg_release( struct p2pex_link_cb *link_cb );
extern long p2pex_link__set_link_state( struct p2pex_link_cb *link_cb, unsigned long state );
extern long p2pex_link_get_status( struct p2pex_link_cb *link_cb, char *buffer, long *buffer_size );

#endif /* !defined(__p2pex_link_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
