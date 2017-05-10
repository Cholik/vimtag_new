/*!
\file       p2pex.h
\brief      

*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__p2pex_h__)
#define __p2pex_h__

#include <stdio.h>
#if defined(_WIN32)
#include <winsock.h>
#endif

/*
    message struct:
    bit_a: 1:big_endian; 0:little_endian
    ver: 
    type: 
    msg_seq: message sequence 
    checksum: message checksum
    
    0                   1                   2                   3 
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    |a| ver |  type |                  reserve                      | 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    |           msg_seq             |           checksum            | 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
*/
#define P2PEX_MSG_FLAG_MASK_ENDIAN          0x80    /*!< endian mask */
#define P2PEX_MSG_FLAG_BIG_ENDIAN           0x80    /*!< big endian */

#define P2PEX_MSG_FLAG_MASK_VER             0x70    /*!< ver mask */
#define P2PEX_MSG_FLAG_VER_CURRENT          1       /*!< current ver */
#define P2PEX_MSG_FLAG_VER_CONFUSION        4       /*!< current confusion ver */

#define P2PEX_MSG_FLAG_MASK_TYPE            0x0f    /*!< type mask */
#define P2PEX_MSG_FLAG_TYPE_CONNECT         0x01    /*!< connect message */
#define P2PEX_MSG_FLAG_TYPE_RELEASE         0x02    /*!< release message */
#define P2PEX_MSG_FLAG_TYPE_KEEPALIVE       0x03    /*!< keepalive message */
#define P2PEX_MSG_FLAG_TYPE_DATA            0x0a    /*!< data message( with ack ) */
#define P2PEX_MSG_FLAG_TYPE_ACK             0x0b    /*!< ack message */
#define P2PEX_MSG_FLAG_TYPE_ACK_REQ         0x0c    /*!< ack request message */

/*
    data message struct:
    bit_a: 1:restruct head;
    bit_b: 1:restruct tail
    0                   1                   2                   3 
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    |               |a|b|ur_bm_byte |  recv_msg_seq_latest          | 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
*/
#define P2PEX_DATA_MSG_FLAG_MASK_FRAG_HEAD      0x80    /*!< mask for indicate fragment head */
#define P2PEX_DATA_MSG_FLAG_MASK_FRAG_TAIL      0x40    /*!< mask for indicate fragment tail */
#define P2PEX_DATA_MSG_FLAG_MASK_FRAGMENT       0xc0    /*!< mask for fragment head and tail */

#define P2PEX_SEQ_FLAG_MASK_URGENT              0x8000  /*!< mask for sequence for urgent data */
#define P2PEX_SEQ_FLAG_MASK_VALUE               0x7fff  /*!< mask for sequence value */

#define P2PEX_MSG_MAGIC (*(uint16_t*)"pm    ")
typedef struct p2pex_msg
{
    uint8_t                 flag;               /*!< flag */
    uint8_t                 reserve[3];         /*!< reserve */
    uint16_t                msg_seq;            /*!< message sequence */
    uint16_t                checksum;           /*!< message checksum */
    char                    cdata[0];           /*!< message data */
}_p2pex_msg;

#define P2PEX_MSG_MAX_SIZE              1400
#define P2PEX_MSG_MAX_PAYLOAD_SIZE ( P2PEX_MSG_MAX_SIZE - sizeof( struct p2pex_msg ))
#define P2PEX_MSG_MAX_SEQ               10000

typedef struct p2pex_msg_data
{
    uint16_t                frag_seq;           /*!< fragement sequence */
    uint16_t                frag_len;           /*!< fragment data len */
    char                    cdata[0];           /*!< fragment data */
}_p2pex_msg_data;

/*
    ack or data with_ack struct:
    0                   1                   2                   3 
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    |                   |   len     |                               | 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
*/
#define P2PEX_ACK_MSG_FLAG_MASK_URGENT_LEN 0x3f    /*!< mask for urgent bitmap bytes */

#define P2PEX_GET_INT16_FROM_ARRAY( SRC ) (((SRC)[1]<<8 |(SRC)[0]))
#define P2PEX_SET_INT16_TO_ARRAY( VALUE, DST ) do{( DST )[0] = ( unsigned char )(( VALUE ) & 0xff ); ( DST )[1] = ( unsigned char )(( VALUE ) >> 8 ); }while(0)
typedef struct p2pex_msg_ack
{
    unsigned char           urgent_frag_seq[2]; /*!< latest urgent sequence that no need commit to user */
    unsigned char           frag_seq[2];        /*!< latest sequence that no need commit to user */
    char                    cdata[0];           /*!< seq range or seq bitmap */
}_p2pex_msg_ack;

typedef struct p2pex_msg_connect
{
    uint8_t                 forward_counts;     /*!< indicate this connect have been forward by proxy before arrive me */
    uint8_t                 request_new_port;   /*!< request receiver create new sock for connect */
    uint16_t                init_seq;           /*!< initial sequence */
    uint32_t                from_p2pid_len;     /*!< from p2pid len */
    uint32_t                to_p2pid_len;       /*!< to p2pid len */
    struct sockaddr_in      from_addr_private;  /*!< private addr */
    struct sockaddr_in      from_addr_public;   /*!< public addr */
    uint32_t                receive_connect;    /*!< indicate whether have receive connect directly from remote */
    uint32_t                tick_tunnel_create; /*!< tick for tunnel create */
    char                    cdata[0];           /*!< p2pid data */
}_p2pex_msg_connect;
#define p2pex_msg_connect_get_size( msg )  ( sizeof( struct p2pex_msg ) \
                                        + sizeof( struct p2pex_msg_connect ) \
                                        + (((struct p2pex_msg_connect *)( msg ))->from_p2pid_len?(((struct p2pex_msg_connect *)( msg ))->from_p2pid_len+ 1):0) \
                                        + (((struct p2pex_msg_connect *)( msg ))->to_p2pid_len?(((struct p2pex_msg_connect *)( msg ))->to_p2pid_len + 1):0))

#define p2pex_msg_connect_get_from_p2pid( msg, from_p2pid ) (from_p2pid)->data = (( struct p2pex_msg_connect* )(msg))->cdata; (from_p2pid)->len = (( struct p2pex_msg_connect* )(msg))->from_p2pid_len
#define p2pex_msg_connect_get_to_p2pid( msg, to_p2pid ) (to_p2pid)->data = &(( struct p2pex_msg_connect* )(msg))->cdata[(( struct p2pex_msg_connect* )(msg))->from_p2pid_len?((( struct p2pex_msg_connect* )(msg))->from_p2pid_len+1):0]; (to_p2pid)->len = (( struct p2pex_msg_connect* )(msg))->to_p2pid_len

#define p2pex_tlv_type_encrypt          1
#define p2pex_encrypt_type_none         0
#define p2pex_encrypt_type_confusion    1


/* max port counts for p2pex */
#define P2PEX_MAX_SOCKET                100

/* schedule wati time */
#define P2PEX_WAIT_TIME_DEFAULT         10      /*!< ms */
#define P2PEX_SCH_TIMER_MAX             100      /*!< how many timer can be schedule each time */

/* tunnel send window size( fragment counts ) */
#define P2PEX_WINDOWS_MAX               50

/* max data size in pack */
#define P2PEX_MAX_MSG_DATA_PAYLOAD      ( P2PEX_MSG_MAX_PAYLOAD_SIZE - 100 - sizeof( struct p2pex_msg_data ) - sizeof( struct p2pex_msg_ack ) - (P2PEX_WINDOWS_MAX + 7)/8*2 )

/* max data delay to be ack */
#define P2PEX_TUNNEL_UNACK_DATA_MAX             5

/* timer length */
#define P2PEX_TUNNEL_TIMER_LENGTH_ACK           90
#define P2PEX_TUNNEL_TIMER_LENGTH_ACK_REQ       150
#define P2PEX_TUNNEL_TIMER_LENGTH_TRANSMIT      100
#define P2PEX_TUNNEL_TIMER_LENGTH_RETRANSMIT    2000
#define P2PEX_TUNNEL_TIMER_LENGTH_CONNECT       2000
#define P2PEX_TUNNEL_TIMER_LENGTH_KEEPALIVE     10000
#define P2PEX_TUNNEL_TIMER_LENGTH_RELEASE       ( P2PEX_TUNNEL_TIMER_LENGTH_KEEPALIVE * 3 + 2000 )

/* common cb state */
#define P2PEX_CB_STATE_ACTIVE           1
#define P2PEX_CB_STATE_INACTIVE         2
#define P2PEX_CB_STATE_INVALID          3

#define P2PEX_FLAG_MASK_LOCAL_NEW_PORT           1
#define P2PEX_FLAG_MASK_REMOTE_NEW_PORT          2

/* Address type to indicate the connect receiver */
#define P2PEX_ADDR_TYPE_PROXY     1
#define P2PEX_ADDR_TYPE_PUBLIC    2
#define P2PEX_ADDR_TYPE_PRIVATE   3
#define P2PEX_ADDR_TYPE_REMOTE    4
#define P2PEX_ADDR_TYPE_POLL      5

#define P2PEX_POLL_PORT_MAX         65535
#define P2PEX_POLL_PORT_STEP        100

/* tunnel connect mode */
#define P2PEX_TUNNEL_CONNECT_MOD_DIRECTLY       1
#define P2PEX_TUNNEL_CONNECT_MOD_PROXY          2

/* tunnel connect role */
#define P2PEX_TUNNEL_CONNECT_ROLE_CALLER        1
#define P2PEX_TUNNEL_CONNECT_ROLE_CALLED        2

/* tunnel connect state */
#define P2PEX_TUNNEL_CONNECT_STATE_INIT                 0
#define P2PEX_TUNNEL_CONNECT_STATE_CONNECTING_PROXY     1
#define P2PEX_TUNNEL_CONNECT_STATE_CONNECTING_REMOTE    2
#define P2PEX_TUNNEL_CONNECT_STATE_CONNECTED            3
#define P2PEX_TUNNEL_CONNECT_STATE_CONNECTING_POLL      4

/* tunnel connect retry max times */
#define P2PEX_TUNNEL_CONNECT_THRESHOLD_PROXY    5
#define P2PEX_TUNNEL_CONNECT_THRESHOLD_REMOTE   5
#define P2PEX_TUNNEL_CONNECT_THRESHOLD_PORT     3

/* tunnel notify type */
#define P2PEX_TUNNEL_NOTIFY_TYPE_CONNECTED          1
#define P2PEX_TUNNEL_NOTIFY_TYPE_SEND_OK            2
#define P2PEX_TUNNEL_NOTIFY_TYPE_DESTROY            3
#define P2PEX_TUNNEL_NOTIFY_TYPE_MODIFY_BANDWIDTH   4

#define p2pex_tick_sub( a, b ) (unsigned long)((a) - (b))
#define p2pex_tick_add( a, b ) (unsigned long)((a) + (b))
#define p2pex_tick_cmp( a, b ) (long)((p2pex_tick_sub((a),(b)) > 0x80000000)?(-1):p2pex_tick_sub((a),(b)))

#define p2pex_cb_check_active( _cb, _cb_type) ((NULL != ( _cb )) && ((P2PEX_MAGIC_##_cb_type##_ACTIVE == *(long*)&(_cb)->magic)))
#define p2pex_cb_check_valid( _cb, _cb_type) ((NULL != ( _cb )) && ((P2PEX_MAGIC_##_cb_type##_ACTIVE == *(long*)&(_cb)->magic) || (P2PEX_MAGIC_##_cb_type##_INACTIVE == *(long*)&(_cb)->magic)))

#define p2pex_format_s    "%p{[%4.4s]{"len_str_format_s"}}"
#define p2pex_format( _cb )  \
                (_cb), (_cb)?(char*)&(_cb)->magic:0,\
                len_str_format((struct len_str*)(p2pex_cb_check_valid( (_cb), CB )?&(_cb)->p2pid:NULL))

#define p2pex_addrin_format_s    "%s:%d"
#define p2pex_addrin_format( _addr )  inet_ntoa((_addr)->sin_addr), ntohs((_addr)->sin_port)

#define p2pex_tunnel_format_s    "%p{[%4.4s]{"len_str_format_s"}<-->{"len_str_format_s"}}"
#define p2pex_tunnel_format( _cb )  \
                (_cb), (_cb)?(char*)&(_cb)->magic:0,\
                len_str_format((struct len_str*)(p2pex_cb_check_valid( (_cb), TUNNEL_CB )?&(_cb)->cb->p2pid:NULL)),\
                len_str_format((struct len_str*)(p2pex_cb_check_valid( (_cb), TUNNEL_CB )?&(_cb)->remote_p2pid:NULL))

struct p2pex_tunnel_cb;
struct p2pex_link_cb;
typedef long (*p2pex_on_tunnel_create)( void *ref, struct p2pex_tunnel_cb *tunnel_cb );
typedef long (*p2pex_on_link_create)( void *ref, struct p2pex_link_cb *link_cb, char *data, unsigned long data_len );

typedef struct p2pex_create_param
{
    struct len_str          p2pid;              /*!< p2pid */
    unsigned long           enable_proxy;       /*!< whether act as proxy for connect */
    struct in_addr          listen_ip;          /*!< proxy listen ip */
    unsigned long           *listen_port;       /*!< proxy listen port list */
    unsigned long           listen_port_counts; /*!< proxy listen port counts */
    unsigned long           wait_time;          /*!< wait time for shedule */
    unsigned long           uniform_send;       /*!< whether send uniform */
    unsigned long           plaintext;          /*!< whether disable confusion */

    unsigned long           enabel_schedule;    /*!< whether p2pex schedule self */
    p2pex_on_tunnel_create  on_tunnel_create;   /*!< callback for tunnel_create */
    p2pex_on_link_create    on_link_create;     /*!< callback for link_create */
    void                    *on_tunnel_create_refer;/*!< refer for on_tunnel_create */
    void                    *on_link_create_refer;  /*!< refer for on_link_create */
}_p2pex_create_param;

#define P2PEX_MAGIC_CB_ACTIVE        (*(long*)"p2pa    ")
#define P2PEX_MAGIC_CB_INACTIVE      (*(long*)"p2pi    ")
#define P2PEX_MAGIC_CB_FREE          (*(long*)"p2pf    ")
typedef struct p2pex_cb
{
    char                    magic[sizeof(long)];/*!< magic */

    unsigned long           wait_time;          /*!< wait time for shedule */
    struct len_str          p2pid;              /*!< p2pid */
    unsigned long           enable_proxy;       /*!< whether act as proxy for connect */
    struct in_addr          listen_ip;          /*!< proxy listen ip */
    unsigned long           *listen_port;       /*!< proxy listen port list */
    unsigned long           listen_port_counts;  /*!< proxy listen port counts */

    unsigned long           uniform_send;       /*!< whether send uniform */
    unsigned long           plaintext;       /*!< whether disable confusion */

    struct in_addr          local_ip;           /*!< p2pex local ip addr */
    
    p2pex_on_tunnel_create  on_tunnel_create;   /*!< callback for tunnel_create */
    p2pex_on_link_create    on_link_create;     /*!< callback for link_create */
    void                    *on_tunnel_create_refer;/*!< refer for on_tunnel_create */
    void                    *on_link_create_refer;  /*!< refer for on_link_create */

    unsigned long           in_schedule;        /*!< indicate schedule is in schedule( wait net ) */
    unsigned long           current_tick;       /*!< current tick */
    long                    net_poll;           /*!< network connect poll */
    struct netx_event       *events;            /*!< events */
    unsigned long           thread_id;          /*!< thread id */
    char                    *buf_restruct;      /*!< buf for restruct tunnel data */
    unsigned long           buf_restruct_size;  /*!< buf size for restruct tunnel data */
    char                    *buf_send;          /*!< buf for build pack to send out */
    unsigned long           buf_send_size;      /*!< buf size for buf_send */
    struct hash_map         *map_socket;        /*!< sock_cb map */
    
    struct hash_map         *map_tunnel;        /*!< tunnel_cb map. key is remote p2pid */
    struct hash_map         *map_remote_addr;   /*!< addr_cb map. key is remote addr  */
    struct hash_map         *map_recv_cb;       /*!< recv_cb map, only user malloc and free, not use hash */
    struct p2pex_recv_cb    *free_recv_cb;      /*!< free recv_cb */
    struct timer_ex_cb      *timer_mod;         /*!< timer module  */

    struct
    {
        unsigned long       counts;
        struct p2pex_tunnel_cb    *list;
    }delay_send_tunnel_list;                  /*!< uniform send tunnel list */
    
    struct
    {
        unsigned long       counts;
        struct p2pex_tunnel_cb    *list;
    }delay_destroy_tunnel_list;                      /*!< inactive tunnel list that delay to be destroy */
    struct
    {
        unsigned long       counts;
        struct p2pex_link_manage_cb    *list;
    }delay_destroy_link_manage_list;                        /*!< inactive link_manage list that delay to be destroy */
    struct
    {
        unsigned long       counts;
        struct p2pex_link_cb    *list;
    }delay_destroy_link_list;                        /*!< inactive link list that delay to be destroy */
}_p2pex_cb;

typedef struct p2pex_socket_create_param
{
    struct p2pex_cb         *cb;
    struct in_addr          local_ip;           /*!< p2pex local ip addr */
    unsigned long           local_port;         /*!< p2pex local_port */
    unsigned long           flag_listen;        /*!< flag to indicate listen port */
}_p2pex_socket_create_param;

typedef struct p2pex_socket_cb
{
    struct p2pex_cb         *cb;                /*!< p2pex cb */
    long                    socket;             /*!< p2pex socket */
    struct in_addr          local_ip;           /*!< p2pex local ip addr */
    long                    local_port;         /*!< p2pex local_port */
    long                    ref_counts;         /*!< p2pex ref counts */
    unsigned long           block_counts;       /*!< block counts */
    unsigned long           flag_listen;        /*!< flag to indicate listen port */

    struct
    {
        unsigned long       counts;
        struct p2pex_socket_data_cb   *list;
    }wait_send_data_list;                              /*!< send cb list head */
    
    struct
    {
        unsigned long       counts;
        struct p2pex_tunnel_cb   *list;
    }wait_send_tunnel_list;
}_p2pex_socket_cb;

typedef struct p2pex_socket_data_cb
{
    struct sockaddr_in      addr;
    unsigned long           data_len;
    struct
    {
        struct p2pex_socket_data_cb    *prev;
        struct p2pex_socket_data_cb    *next;
    }node;
    char                    cdata[0];  /*!< buffer to store data */
}_p2pex_socket_send_cb;

/* tunnel section */
struct p2pex_tunnel_notify;
typedef long (*p2pex_tunnel_on_data)( void *ref, char *data, int len );
typedef long (*p2pex_tunnel_on_notify)( void *ref, struct p2pex_tunnel_notify *notify );

typedef struct p2pex_tunnel_create_param
{
    struct p2pex_cb         *cb;                /*!< p2pex cb */
    struct len_str          remote_p2pid;       /*!< remote p2pid */
    struct len_str          remote_addr;        /*!< p2pex remote addr */
    unsigned long           remote_port;        /*!< p2pex remote port */
    struct len_str          proxy_addr;         /*!< p2pex server ip or domain */
    unsigned long           proxy_port;         /*!< p2pex server local_port */
    struct p2pex_socket_cb  *socket_cb;         /*!< p2pex socket_cb */
    struct sockaddr_in      remote_addr_private;/*!< private addr */
    struct sockaddr_in      remote_addr_public; /*!< public addr */

    p2pex_tunnel_on_data    on_data;            /*!< callback to process arrive data */
    p2pex_tunnel_on_notify  on_notify;          /*!< callback to process p2pex_tunnel_notify */
    void                    *refer;             /*!< refer of user module */
}_p2pex_tunnel_create_param;

typedef struct p2pex_tunnel_get_param
{
    struct p2pex_cb         *cb;                /*!< p2pex cb */
    struct len_str          remote_p2pid;       /*!< remote p2pid */
    struct len_str          remote_addr;        /*!< p2pex remote addr */
    unsigned long           remote_port;        /*!< p2pex remote port */
}_p2pex_tunnel_get_param;

typedef struct p2pex_remote_addr_cb
{
    struct sockaddr_in      remote_addrin;        /*!< remote address */
    struct p2pex_tunnel_cb  *tunnel_cb;         /*!< tunnel cb */
}_p2pex_remote_addr_cb;

typedef struct p2pex_recv_cb
{
    uint16_t                frag_seq;           /*!< data sequence */
    char                    reserve[2];
    long                    data_size;          /*!< data size */
    struct
    {
        struct p2pex_recv_cb   *prev;
        struct p2pex_recv_cb   *next;
    }node;                                      /*!< node in range_cb */
    
    char                    cdata[P2PEX_MSG_MAX_SIZE];  /*!< buffer to store msg */
}_p2pex_recv_cb;

#define P2PEX_BW_CALC_PERIOD                        1000
#define P2PEX_BW_CALC_SILENT_PERIOD_LONG            3000
#define P2PEX_BW_CALC_SILENT_PERIOD_SHORT           2000
#define P2PEX_BW_CALC_MONITOR_PERIOD_COUNTS         3
#define P2PEX_BW_CALC_SLOT_COUNTS                   5
#define P2PEX_BW_CALC_MIN_DELAY_SLOT_COUNTS         10
#define P2PEX_UNIFORM_SEND_SPEED_REFER_SLOT_COUNTS     10

#define P2PEX_UNIFORM_SEND_PERIOD                   5000
#define P2PEX_UNIFORM_SEND_SPEED_SCALE              1.3
#define P2PEX_UNIFORM_SEND_DEFAULT                  500
#define P2PEX_UNIFORM_SEND_MIN                      15

#define P2PEX_BW_DELAY_BASE                         30
#define P2PEX_BW_INC_DELAY_THREASHOLD               130
#define P2PEX_BW_DEC_DELAY_SLOW_THREASHOLD          250
#define P2PEX_BW_DEC_DELAY_SLOW_SINGLE_THREASHOLD   500
#define P2PEX_BW_DEC_DELAY_FAST_SINGLE_THREASHOLD   1000

#ifdef __ANDROID__ 
#define P2PEX_BW_INC_SCALE_WEAK                     1
#else
#define P2PEX_BW_INC_SCALE_WEAK                     0.5
#endif
#define P2PEX_BW_INC_SCALE_SLOW                     0.1
#define P2PEX_BW_INC_SCALE_MIN                      0.01
#define P2PEX_BW_INC_SCALE_FAST                     0.2
#define P2PEX_BW_DEC_SCALE_FAST                     0.5
#define P2PEX_BW_DEC_SCALE_SLOW                     0.1

#define P2PEX_BW_INC_MIN                            4

#define P2PEX_SPEED_STEP_TICK                       1000
#define P2PEX_SPEED_SECTION_SIZE                    10
#define P2PEX_SPEED_SECTION_STEP                    5

typedef struct p2pex_tunnel_bw_cb
{
    unsigned long           inc_delay_threshold;            /* inc delay threshold */
    unsigned long           dec_delay_slow_threshold;       /* dec delay slow threshold */
    unsigned long           dec_delay_slow_single_threshold;/* dec delay slow threshold */
    unsigned long           dec_delay_fast_single_threshold;/* dec delay fast threshold */
    double                  inc_scale_fast;         /* inc scale fast */
    double                  inc_scale_slow;         /* inc scale fast */
    unsigned long           tick_monitor_start;     /* Tick for start monitor dequeue_speed and delay and loss rate */
    unsigned long           monitor_start;          /* Indicate whether monitor have start */
    unsigned long           tick_count_start;       /* Tick for calculate start */
    unsigned long           calc_counts;            /* calc counts */
    unsigned long           inc_fast_counts;        /* notify counts */
    unsigned long           inc_slow_counts;        /* notify counts */
    unsigned long           dec_fast_counts;        /* notify counts */
    unsigned long           average_dec_slow_counts;/* notify counts */
    unsigned long           single_dec_slow_counts; /* notify counts */
    unsigned long           notify_counts;          /* notify counts */

    long                    size_in_queue;          /* Current data size wait to send */
    long                    current_bw;             /* Current notify bandwidth */
    long                    new_bw;                 /* New bandwidth */

    unsigned long           current_slot;           /* current slot */
    unsigned long           dequeue_size_record[P2PEX_BW_CALC_SLOT_COUNTS];     /* total pack size dequeue this calc peroid */
    unsigned long           enqueue_size_record[P2PEX_BW_CALC_SLOT_COUNTS];     /* total pack size dequeue this calc peroid */
    unsigned long           dequeue_counts_record[P2PEX_BW_CALC_SLOT_COUNTS];   /* total pack counts dequeue this calc peroid */
    unsigned long           send_counts_record[P2PEX_BW_CALC_SLOT_COUNTS];      /* total pack size send this calc peroid */
    unsigned long           resend_counts_record[P2PEX_BW_CALC_SLOT_COUNTS];    /* total pack size resend this calc peroid */
    unsigned long           delay_tick_record[P2PEX_BW_CALC_SLOT_COUNTS];       /* total delay tick this calc peroid */
    unsigned long           max_delay_record[P2PEX_BW_CALC_SLOT_COUNTS];        /* max_delay record */
    unsigned long           delay_max;                                          /* max delay this calc peroid */
    unsigned long           dequeue_speed;                                      /* average dequeue speed */
    unsigned long           enqueue_speed;                                      /* average dequeue speed */
    unsigned long           delay_average;                                      /* average delay */
    unsigned long           loss_rate_average;                                  /* average loss rate */
    unsigned long           send_total;                                         /* total send counts */
    unsigned long           resend_total;                                       /* total resend counts */
    uint64_t                enqueue_total;                                      /* total enqueue counts */
    uint64_t                dequeue_total;                                      /* total dequeue counts */

    unsigned long           latest_delay_average;                               /* latest non-zero delay_average */
    unsigned long           latest_loss_rate_average;                           /* latest loss_rate_average */

    unsigned long           min_delay_record[P2PEX_BW_CALC_MIN_DELAY_SLOT_COUNTS];          /* min_delay record */
    unsigned long           delay_min;                                          /* min delay this calc peroid */
    unsigned long           current_min_delay_slot;                             /* current min_delay record slot */

    unsigned long           dequeue_speed_record[P2PEX_UNIFORM_SEND_SPEED_REFER_SLOT_COUNTS]; /* dequeue_speed record */
    unsigned long           current_dequeue_speed_slot;                         /* current dequeue_speed record slot */
    long                    uniform_send_refer_speed;                                   /* bytes/ms max deqeue speed */
    long                    uniform_send_speed;                             /* bytes/ms max uniform send speed */
}_p2pex_tunnel_bw_cb;

typedef struct p2pex_tunnel_transmit_cb
{
    uint16_t                send_frag_seq_latest;    /*!< latest send sequence. tail */
    uint16_t                send_frag_seq_finish;    /*!< latest sequence that no need retransmit */
    struct
    {
        unsigned long       counts;
        struct p2pex_tunnel_data_cb    *list;
    }data_cb_list;                              /*!< user data cb list */
    
    struct
    {
        unsigned long       counts;
        struct p2pex_tunnel_fragment_cb   *list;
    }send_window;                              /*!< send cb list head */

    struct
    {
        unsigned long       counts;
        struct p2pex_tunnel_fragment_cb   *list;
    }wait_send_window;                              /*!< send cb list head */
    
    uint16_t                commit_frag_seq_finish; /*!< frag_seq that have commit to user */
    uint16_t                recv_frag_seq_finish;   /*!< frag_seq tail continous */
    struct
    {
        unsigned long       counts;
        struct p2pex_recv_cb    *list;
    }wait_commit;                                   /*!< recv_cb continous wait to be commit to user */
    struct p2pex_recv_cb    *recv_window[P2PEX_WINDOWS_MAX];    /*!< recv_window to store received data, not continuous */
    unsigned long           recv_window_head;   /*!< head */
    unsigned long           recv_window_size;   /*!< size */
    struct speed_statistic  *send_static;
    struct speed_statistic  *recv_static;
}_p2pex_tunnel_transmit_cb;

#define P2PEX_MAGIC_TUNNEL_CB_ACTIVE          (*(long*)"tnla    ")
#define P2PEX_MAGIC_TUNNEL_CB_INACTIVE        (*(long*)"tnli    ")
#define P2PEX_MAGIC_TUNNEL_CB_FREE            (*(long*)"tnlf    ")

typedef struct p2pex_tunnel_cb
{
    char                    magic[sizeof(long)];/*!< magic */
    struct p2pex_cb         *cb;                /*!< p2pex cb */
    struct len_str          remote_p2pid;       /*!< p2pex id */
    struct p2pex_socket_cb  *socket_cb;         /*!< p2pex socket_cb */
    struct sockaddr_in      remote_addr_in;     /*!< remote addr */
    struct sockaddr_in      remote_addr_in_private; /*!< private addr */
    struct sockaddr_in      remote_addr_in_public;  /*!< public addr */
    struct sockaddr_in      remote_addr_in_his[2];  /*!< remote addr history */

    struct sockaddr_in      proxy_addr_in;      /*!< proxy addr */

    struct len_str          remote_addr;        /*!< p2pex remote addr. */
    unsigned long           remote_port;        /*!< p2pex remote port.  */
    struct len_str          proxy_addr;         /*!< p2pex server ip or domain. */
    unsigned long           proxy_port;         /*!< p2pex server local_port. */

    unsigned long           unlimited_bandwidth;/*!< unlimited bandwidth for same private network */      
    unsigned long           disable_unlimited_bandwidth;/*!< disable unlimited_bandwidth */      
    unsigned long           encrypt_type;       /*!< encrypt type */

    unsigned long           loopback;           /*!< indicate loopback tunnel. */
    unsigned long           connect_mode;       /*!< 1:conect_dirctly; 2:connect through proxy */
    unsigned long           connect_role;       /*!< 1:caller; 2:called */
    unsigned long           connect_fail_times; /*!< connect times */
    unsigned long           connect_state;      /*!< connect state */
    unsigned long           sub_connect_fail_times; /*!< try times for sub state */
    unsigned long           connect_poll_port;  /*!< next poll connect port */
    struct timer_ex         *timer_connect;     /*!< timer for connect */

    unsigned long           internal_user_module;   /*!< whether user module is internal module.  */    
    p2pex_tunnel_on_data    on_data;            /*!< callback to process arrive data */
    p2pex_tunnel_on_notify  on_notify;          /*!< callback to process p2pex_tunnel_notify */
    void                    *refer;             /*!< refer of user module */

    struct p2pex_tunnel_transmit_cb urgent_transmit_cb;   /*!< urgent transmit cb. i.e. audio */
    struct p2pex_tunnel_transmit_cb transmit_cb;        /*!< transmit cb. */
    unsigned long           tick_uniform_send_start;    /*!< uniform send start tick */
    unsigned long           uniform_send_size;          /*!< uniform send size */
    unsigned long           delay_transmit_counts;      /*!< delay transmit counts */
    unsigned long           delay_retransmit_counts;    /*!< delay retransmit counts */
    
    /* send section */
    uint16_t                send_seq_init;      /*!< initialize send sequence */
    uint16_t                send_msg_seq_latest;   /*!< latest send sequence */
    unsigned long           send_window_size;   /*!< send window size */

    struct hash_map         *map_data_cb;       /*!< data_cb map */
    struct hash_map         *map_fragment_cb;   /*!< fragment_cb map */

    /* recv section */
    uint16_t                recv_seq_init;      /*!< initialize send sequence */
    uint16_t                recv_msg_seq_latest;/*!< pack_num of last receive pack */
    unsigned long           unack_data_counts;  /*!< unack data counts */

    unsigned long           timer_len_retransmit;   /* retransmit timer length */
    struct timer_ex         *timer_ack;         /*!< timer to send ack to remote */
    struct timer_ex         *timer_transmit;  /*!< timer to retransmit */
    struct timer_ex         *timer_keepalive;   /*!< timer for send keepalive */
    struct timer_ex         *timer_release;     /*!< timer for release tunnel */

    unsigned long           tick_create;        /*!< tick for tunnel create */
    unsigned long           tick_remote_create; /*!< tick for remote tunnel create */
    unsigned long           tick_recent_send_pack;  /*!< local tick of recent send pack */
    unsigned long           tick_recent_recv_pack;  /*!< local tick of recent recv pack */
    
    unsigned long           fragment_total;     /*!< total fragment counts */
    unsigned long           send_counts;        /*!< send counts */
    unsigned long           recv_counts;        /*!< recv counts */
    unsigned long           recv_not_in_order_counts; /*!< recv repeat not in order counts */
    unsigned long           recv_repeat_counts; /*!< recv repeat counts */
    unsigned long           found_hole_counts;  /*!< found hole counts */
    unsigned long           unack_reach_th_counts;  /*!< unack data reach threahold counts */
    unsigned long           ack_send_counts;    /*!< send ack counts */
    unsigned long           ack_recv_counts;    /*!< recv ack counts */
    unsigned long           retransmit_counts;  /*!< retransmit timer time out counts */
    unsigned long           ack_timeout;        /*!< ack timer time out counts */
    unsigned long           keepalive_send_counts;  /*!< send keep counts */
    unsigned long           ack_counts;         /*!< Ack counts temporary to judge whether ack have been send during callback */
    unsigned long           ack_req_send_counts;/*!< Ack request send counts */    
    unsigned long           tick_send_ack_req;  /*!< uniform send start tick */
    struct
    {
        struct p2pex_tunnel_cb   *prev;
        struct p2pex_tunnel_cb   *next;
    }delay_destroy_node;                                      /*!< node */
    
    struct
    {
        struct p2pex_tunnel_cb   *prev;
        struct p2pex_tunnel_cb   *next;
    }delay_send_node;                                 /*!< node */

    struct
    {
        struct p2pex_tunnel_cb   *prev;
        struct p2pex_tunnel_cb   *next;
    }wait_sock_node;                                      /*!< node */
    
    struct p2pex_tunnel_bw_cb          bw_cb;              /*!< bandwidth cb */
    long                        ref_counts;
    struct speed_statistic  *output_static;
}_p2pex_tunnel_cb;

typedef struct p2pex_tunnel_data_cb
{
    void                    *refer;             /*!< refer for send result */
    unsigned long           counts_wait_ack;    /*!< fragment wait ack */
    unsigned long           tick_enque;         /*!< tick receive send request from user module */
    unsigned long           data_len;           /*!< msg_data_size and pack head size */
    struct
    {
        struct p2pex_tunnel_data_cb    *prev;
        struct p2pex_tunnel_data_cb    *next;
    }node;                                      /*!< send cb list node */
}_p2pex_tunnel_userdata_cb;

typedef struct p2pex_tunnel_fragment_cb
{
    struct p2pex_tunnel_data_cb *data_cb;       /*!< user data cb */
    unsigned long           urgent;             /*!< urgent flag */
    unsigned long           seq;                /*!< data sequence */
    unsigned long           msg_size;          /*!< msg_data_size and pack head size */
    unsigned long           data_size;          /*!< user_data_size */
    unsigned long           send_tick;          /*!< tick latest send */
    struct
    {
        struct p2pex_tunnel_fragment_cb   *prev;
        struct p2pex_tunnel_fragment_cb   *next;
    }node;                                      /*!< send cb list node */
    
    char                    cdata[P2PEX_MSG_MAX_SIZE];  /*!< buffer to store pack */
}_p2pex_tunnel_fragment_send_cb;

typedef struct p2pex_range_cb
{
    struct
    {
        struct p2pex_range_cb   *prev;
        struct p2pex_range_cb   *next;
    }node;                                      /*!< node in range_list */

    struct
    {
        unsigned long       counts;
        struct p2pex_recv_cb    *list;
    }recv_cb_list;
}_p2pex_range_cb;

typedef struct p2pex_tunnel_notify
{
    int                     notify_type;        /*!< notify type */
    void                    *refer;             /*!< data */
    unsigned long           bandwidth;          /*!< expect bandwidth */
    unsigned long           unlimited_bandwidth;/*!< unlimited bandwidth */
    unsigned long           data_size;          /*!< valid for send_ok */
    unsigned long           delay;              /*!< valid for send_ok */
    unsigned long           user_destroy;       /*!< whether user have destroy this tunnel */
}_p2pex_tunnel_notify;

extern struct p2pex_cb *p2pex_create( struct p2pex_create_param *param );
extern long p2pex_destroy( struct p2pex_cb *cb );
extern long p2pex_dump( unsigned long       argc,                    char                *argv[],                    char                *buf,                    char                *file,                    unsigned long       start,                    unsigned long       counts,                    unsigned long       size);
extern long p2pex_frame__base_confusion_decode(unsigned char *buf, unsigned long size);
extern long p2pex_frame__base_confusion_encode(unsigned char *buf, unsigned long size);
extern uint16_t p2pex_frame__checksum(unsigned char *buf, unsigned long size);
extern long p2pex_schedule( struct p2pex_cb *cb );
extern struct p2pex_socket_cb * p2pex_socket__create( struct p2pex_socket_create_param *param );
extern long p2pex_socket__destroy( struct p2pex_socket_cb *socket_cb );
extern long p2pex_socket__ref( struct p2pex_socket_cb *socket_cb, void *ref );
extern long p2pex_socket__unref( struct p2pex_socket_cb *socket_cb, void *ref );
extern long p2pex_thread_routine( struct p2pex_cb *cb );
extern struct p2pex_tunnel_cb * p2pex_tunnel_create( struct p2pex_tunnel_create_param *param );
extern long p2pex_tunnel_destroy( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel_send( struct p2pex_tunnel_cb *tunnel_cb, const char *buf, int len, unsigned long time_out, void *refer, unsigned long urgent );
extern long p2pex_tunnel__add_remote_addr( struct p2pex_tunnel_cb *tunnel_cb, struct sockaddr_in *remote_addr  );
extern long p2pex_tunnel__build_ack_bitmap( struct p2pex_tunnel_cb *tunnel_cb, struct p2pex_msg *msg, char *buf, unsigned long buf_len );
extern long p2pex_tunnel__bw_calc( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__connect( struct p2pex_tunnel_cb *tunnel_cb );
extern struct p2pex_tunnel_cb * p2pex_tunnel__create( struct p2pex_tunnel_create_param *param );
extern long p2pex_tunnel__del_remote_addr( struct p2pex_tunnel_cb *tunnel_cb, struct sockaddr_in *remote_addr  );
extern long p2pex_tunnel__dequeue_counts( struct p2pex_tunnel_cb *tunnel_cb, unsigned long data_size, unsigned long delay, unsigned long flag_data_dequeue );
extern long p2pex_tunnel__destroy( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__disable_ulimited_bandwidth( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__enqueue_counts( struct p2pex_tunnel_cb *tunnel_cb, unsigned long data_size );
extern long p2pex_tunnel__forward_msg_connect( struct p2pex_socket_cb *socket_cb, struct p2pex_recv_cb *recv_cb, struct p2pex_msg *msg, struct sockaddr_in *remote_addrin );
extern long p2pex_tunnel__free_fragment( struct p2pex_tunnel_cb *tunnel_cb, unsigned long seq );
extern struct p2pex_tunnel_cb * p2pex_tunnel__get( struct p2pex_tunnel_get_param *param );
extern long p2pex_tunnel__get_status( struct p2pex_tunnel_cb *tunnel_cb, char *buffer, long *buffer_size );
extern long p2pex_tunnel__inactive( struct p2pex_tunnel_cb *tunnel_cb, unsigned long user_destroy );
extern long p2pex_tunnel__on_connected( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__on_msg_ack( struct p2pex_tunnel_cb *tunnel_cb, struct p2pex_msg *msg, unsigned long offset, unsigned long size );
extern long p2pex_tunnel__on_msg_ack_req( struct p2pex_tunnel_cb *tunnel_cb, struct p2pex_msg *msg );
extern long p2pex_tunnel__on_msg_connect( struct p2pex_socket_cb *socket_cb, struct p2pex_recv_cb *recv_cb, struct p2pex_msg *msg, struct sockaddr_in *remote_addrin );
extern long p2pex_tunnel__on_msg_data( struct p2pex_tunnel_cb *tunnel_cb, struct p2pex_recv_cb *recv_cb, struct p2pex_msg *msg, unsigned long found_hole, long *enqueue );
extern long p2pex_tunnel__on_msg_keepalive( struct p2pex_tunnel_cb *tunnel_cb, struct p2pex_msg *msg );
extern long p2pex_tunnel__on_msg_release( struct p2pex_tunnel_cb *tunnel_cb, struct p2pex_msg *msg );
extern long p2pex_tunnel__on_timeout_ack( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__on_timeout_connect( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__on_timeout_keepalive( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__on_timeout_release( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__on_timeout_transmit( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__on_user_data( struct p2pex_tunnel_cb *tunnel_cb, unsigned long urgent );
extern long p2pex_tunnel__send_counts( struct p2pex_tunnel_cb *tunnel_cb, unsigned flag_resend );
extern long p2pex_tunnel__send_fragment( struct p2pex_tunnel_cb *tunnel_cb, struct p2pex_tunnel_fragment_cb *tunnel_fragment_cb );
extern long p2pex_tunnel__send_msg( struct p2pex_tunnel_cb *tunnel_cb, struct sockaddr_in *addr, uint8_t msg_type, struct p2pex_msg *msg, unsigned long msg_len );
extern long p2pex_tunnel__send_msg_ack( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__send_msg_ack_req( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__send_msg_connect( struct p2pex_tunnel_cb *tunnel_cb, unsigned char flag, unsigned long connect_type );
extern long p2pex_tunnel__send_msg_connect_back( struct p2pex_tunnel_cb *tunnel_cb, struct sockaddr_in *remote_addrin );
extern long p2pex_tunnel__send_msg_keepalive( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__send_msg_release( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__send_user_data( struct p2pex_tunnel_cb *tunnel_cb, const char *buf0, int buf_len0, const char *buf1, int buf_len1, const char *buf2, int buf_len2, void *refer, unsigned urgent );
extern long p2pex_tunnel__set_connect_state( struct p2pex_tunnel_cb *tunnel_cb, unsigned long connect_state );
extern long p2pex_tunnel__start_timer_connect( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__stop_timer_connect( struct p2pex_tunnel_cb *tunnel_cb );
extern long p2pex_tunnel__transmit( struct p2pex_tunnel_cb *tunnel_cb, unsigned long tail_msg_seq, unsigned long urgent );
extern struct p2pex_cb *p2pex__create( struct p2pex_create_param *param );
extern long p2pex__destroy( struct p2pex_cb *cb );
extern long p2pex__get_local_addr( struct p2pex_socket_cb *socket_cb, struct sockaddr_in *local_private_addr );
extern long p2pex__get_sockaddr_in_by_addr( struct len_str *addr_in, unsigned long port, struct sockaddr_in *addr_out );
extern long p2pex__hash_compare_by_sockaddr_in( struct sockaddr_in *key1, struct sockaddr_in *key2, void *ref );
extern unsigned long p2pex__hash_get_value_by_sockaddr_in( struct sockaddr_in *key, void *ref );
extern long p2pex__inactive( struct p2pex_cb *cb );
extern long p2pex__on_recv( struct p2pex_socket_cb *socket_cb, struct p2pex_recv_cb *recv_cb, struct sockaddr_in *remote_addrin, long *enqueue );
extern long p2pex__on_send( struct p2pex_socket_cb *socket_cb );
extern long p2pex__schedule( struct p2pex_cb *cb );
extern long p2pex__send_msg_release( struct p2pex_socket_cb *socket_cb, struct sockaddr_in *remote_addrin, long encrypt_type );

#endif /* !defined(__p2pex_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
