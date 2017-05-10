/*!
\file       utp.h
\brief      

*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__utp_h__)
#define __utp_h__

#include <stdio.h>
#if defined(_WIN32)
#include <winsock.h>
#endif

/* message define */
/*
    message struct:
    bit_a: 1:big_endian; 0:little_endian
    ver: 2
    type: connect, release, keepalive, data, ack, ack_req
    recv_msg_seq: latest received message sequence
    msg_seq: message sequence 
    checksum: message checksum
    
    0                   1                   2                   3 
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    |a| ver |  type |    reserve    |    recv_msg_seq        | 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    |           msg_seq             |           checksum            | 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
*/
typedef struct utp_msg
{
    uint8_t                 flag;               /*!< flag */
    uint8_t                 reserve;            /*!< reserve */
    uint16_t                recv_msg_seq;       /*!< latest received message sequence */
    uint16_t                msg_seq;            /*!< message sequence */
    uint16_t                checksum;           /*!< message checksum */
    char                    cdata[0];           /*!< message data */
}_utp_msg;

#define UTP_MSG_FLAG_MASK_ENDIAN          0x80    /*!< endian mask */
#define UTP_MSG_FLAG_BIG_ENDIAN           0x80    /*!< big endian */

#define UTP_MSG_FLAG_MASK_VER             0x70    /*!< ver mask */
#define UTP_MSG_FLAG_VER_CURRENT          2       /*!< current ver */
#define UTP_MSG_FLAG_VER_CONFUSION        3       /*!< current confusion ver */

#define UTP_MSG_FLAG_MASK_TYPE            0x0f    /*!< type mask */
#define UTP_MSG_FLAG_TYPE_CONNECT         0x01    /*!< connect message */
#define UTP_MSG_FLAG_TYPE_RELEASE         0x02    /*!< release message */
#define UTP_MSG_FLAG_TYPE_KEEPALIVE       0x03    /*!< keepalive message */
#define UTP_MSG_FLAG_TYPE_DATA            0x0a    /*!< data message( with ack ) */
#define UTP_MSG_FLAG_TYPE_ACK             0x0b    /*!< ack message */
#define UTP_MSG_FLAG_TYPE_ACK_REQ         0x0c    /*!< ack request message */

#define UTP_SEQ_FLAG_MASK_URGENT              0x8000  /*!< mask for sequence for urgent data */
#define UTP_SEQ_FLAG_MASK_VALUE               0x7fff  /*!< mask for sequence value */

#define UTP_MSG_MAGIC (*(uint16_t*)"pm    ")

#define UTP_MSG_MAX_SIZE              1400
#define UTP_MSG_MAX_PAYLOAD_SIZE ( UTP_MSG_MAX_SIZE - sizeof( struct utp_msg ))

/* connect define */
typedef struct utp_msg_connect
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
}_utp_msg_connect;
#define utp_msg_connect_get_size( msg )  ( sizeof( struct utp_msg ) \
                                        + sizeof( struct utp_msg_connect ) \
                                        + (((struct utp_msg_connect *)( msg ))->from_p2pid_len?(((struct utp_msg_connect *)( msg ))->from_p2pid_len+ 1):0) \
                                        + (((struct utp_msg_connect *)( msg ))->to_p2pid_len?(((struct utp_msg_connect *)( msg ))->to_p2pid_len + 1):0))

#define utp_msg_connect_get_from_p2pid( msg, from_p2pid ) (from_p2pid)->data = (( struct utp_msg_connect* )(msg))->cdata; (from_p2pid)->len = (( struct utp_msg_connect* )(msg))->from_p2pid_len
#define utp_msg_connect_get_to_p2pid( msg, to_p2pid ) (to_p2pid)->data = &(( struct utp_msg_connect* )(msg))->cdata[(( struct utp_msg_connect* )(msg))->from_p2pid_len?((( struct utp_msg_connect* )(msg))->from_p2pid_len+1):0]; (to_p2pid)->len = (( struct utp_msg_connect* )(msg))->to_p2pid_len

/*
    data message struct:
    bit_a: 1:restruct head;
    bit_b: 1:restruct tail
    freg_seq: fragment sequence
    frag_len: fragment length
    0                   1                   2                   3 
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    |a|b|        frag_seq           |         frag_len              | 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
*/
typedef struct utp_msg_data
{
    uint16_t                frag_seq;           /*!< fragement sequence */
    uint16_t                frag_len;           /*!< fragment data len */
    char                    cdata[0];           /*!< fragment data */
}_utp_msg_data;

#define UTP_DATA_MSG_FLAG_MASK_FRAG_HEAD      0x80    /*!< mask for indicate fragment head */
#define UTP_DATA_MSG_FLAG_MASK_FRAG_TAIL      0x40    /*!< mask for indicate fragment tail */
#define UTP_DATA_MSG_FLAG_MASK_FRAGMENT       0xc0    /*!< mask for fragment head and tail */

/*
    ack or data with_ack struct:
    0                   1                   2                   3 
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    |      urgent_frag_seq          |         frag_seq              | 
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    | u_bitmap_len  | bitmap_len    |  tick_counts  |   reserve     |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    | u_bitmap...                                                   |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    | bitmap...                                                     |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
    | tick...                                                       |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
*/
typedef struct utp_msg_ack
{
    uint16_t                urgent_frag_seq;    /*!< latest urgent sequence that no need commit to user */
    uint16_t                frag_seq;           /*!< latest sequence that no need commit to user */
    uint8_t                 urgent_bitmap_len;  /*!< latest urgent sequence that no need commit to user */
    uint8_t                 bitmap_len;         /*!< latest urgent sequence that no need commit to user */
    uint8_t                 tick_counts;        /*!< reserved */
    uint8_t                 reserve;            /*!< reserved */
    char                    cdata[0];           /*!< seq bitmap */
}_utp_msg_ack;


/* max port counts for utp */
#define UTP_MAX_SOCKET                100

/* schedule wati time */
#define UTP_WAIT_TIME_DEFAULT         10      /*!< ms */
#define UTP_SCH_TIMER_MAX             50      /*!< how many timer can be schedule each time */

/* max data size in pack */
#define UTP_MAX_MSG_DATA_PAYLOAD      ( UTP_MSG_MAX_PAYLOAD_SIZE - 100 - sizeof( struct utp_msg_data ) - sizeof( struct utp_msg_ack ) - (UTP_WRAP_MAX( RECV_CB ) + 7)/8*2 - 20 )

/* max data delay to be ack */
#define UTP_TUNNEL_UNACK_DATA_MAX             5

/* timer length */
#define UTP_TUNNEL_TIMER_LENGTH_ACK           90
#define UTP_TUNNEL_TIMER_LENGTH_ACK_REQ       150
#define UTP_TUNNEL_TIMER_LENGTH_TRANSMIT      100
#define UTP_TUNNEL_TIMER_LENGTH_RETRANSMIT    2000
#define UTP_TUNNEL_TIMER_LENGTH_CONNECT       2000
#define UTP_TUNNEL_TIMER_LENGTH_KEEPALIVE     10000
#define UTP_TUNNEL_TIMER_LENGTH_RELEASE       ( UTP_TUNNEL_TIMER_LENGTH_KEEPALIVE * 3 + 2000 )

/* common cb state */
#define UTP_CB_STATE_ACTIVE           1
#define UTP_CB_STATE_INACTIVE         2
#define UTP_CB_STATE_INVALID          3

#define UTP_FLAG_MASK_LOCAL_NEW_PORT           1
#define UTP_FLAG_MASK_REMOTE_NEW_PORT          2

/* Address type to indicate the connect receiver */
#define UTP_ADDR_TYPE_PROXY     1
#define UTP_ADDR_TYPE_PUBLIC    2
#define UTP_ADDR_TYPE_PRIVATE   3
#define UTP_ADDR_TYPE_REMOTE    4
#define UTP_ADDR_TYPE_POLL      5

#define UTP_POLL_PORT_MAX         65535
#define UTP_POLL_PORT_STEP        100

/* tunnel connect mode */
#define UTP_TUNNEL_CONNECT_MOD_DIRECTLY       1
#define UTP_TUNNEL_CONNECT_MOD_PROXY          2

/* tunnel connect role */
#define UTP_TUNNEL_CONNECT_ROLE_CALLER        1
#define UTP_TUNNEL_CONNECT_ROLE_CALLED        2

/* tunnel connect state */
#define UTP_TUNNEL_CONNECT_STATE_INIT                 0
#define UTP_TUNNEL_CONNECT_STATE_CONNECTING_PROXY     1
#define UTP_TUNNEL_CONNECT_STATE_CONNECTING_REMOTE    2
#define UTP_TUNNEL_CONNECT_STATE_CONNECTED            3
#define UTP_TUNNEL_CONNECT_STATE_CONNECTING_POLL      4

/* tunnel connect retry max times */
#define UTP_TUNNEL_CONNECT_THRESHOLD_PROXY    5
#define UTP_TUNNEL_CONNECT_THRESHOLD_REMOTE   5
#define UTP_TUNNEL_CONNECT_THRESHOLD_PORT     3

/* tunnel notify type */
#define UTP_TUNNEL_NOTIFY_TYPE_CONNECTED          1
#define UTP_TUNNEL_NOTIFY_TYPE_SEND_OK            2
#define UTP_TUNNEL_NOTIFY_TYPE_DESTROY            3
#define UTP_TUNNEL_NOTIFY_TYPE_MODIFY_BANDWIDTH   4

#define UTP_WRAP_BITS_SEQ     14
#define UTP_WRAP_BITS_US      28
#define UTP_WRAP_BITS_TICK    28
#define UTP_WRAP_BITS_TICK_RECORD    6
#define UTP_WRAP_BITS_MSG_RECORD    12
#define UTP_WRAP_BITS_RECV_CB 6

#define UTP_WRAP_MAX( TYPE ) ( 1 << UTP_WRAP_BITS_##TYPE )
#define UTP_WRAP_ADJUST( TYPE, VALUE )   (((long)( VALUE )) & ( UTP_WRAP_MAX( TYPE ) -1 ))
#define UTP_WRAP_ADD( TYPE, A, B ) ( UTP_WRAP_ADJUST( TYPE, ((long)(A)) + ((long)(B))))
#define UTP_WRAP_SUB( TYPE, A, B ) ( UTP_WRAP_ADJUST( TYPE, ((long)(A)) - ((long)(B))))
#define UTP_WRAP_CMP( TYPE, A, B ) ( ((UTP_WRAP_ADJUST( TYPE, A)) == (UTP_WRAP_ADJUST( TYPE, B)))?0:(UTP_WRAP_SUB( TYPE,(A),(B))<( 1 << ( UTP_WRAP_BITS_##TYPE - 2 ))))

#define utp_tick_sub( a, b ) (unsigned long)((a) - (b))
#define utp_tick_add( a, b ) (unsigned long)((a) + (b))
#define utp_tick_cmp( a, b ) (long)((utp_tick_sub((a),(b)) > 0x80000000)?(-1):utp_tick_sub((a),(b)))

#define utp_cb_check_active( _cb, _cb_type) ((NULL != ( _cb )) && ((UTP_MAGIC_##_cb_type##_ACTIVE == *(long*)&(_cb)->magic)))
#define utp_cb_check_valid( _cb, _cb_type) ((NULL != ( _cb )) && ((UTP_MAGIC_##_cb_type##_ACTIVE == *(long*)&(_cb)->magic) || (UTP_MAGIC_##_cb_type##_INACTIVE == *(long*)&(_cb)->magic)))

#define utp_p2pid_format_s   "%p{%*.*s}"
#define utp_p2pid_format(_p2p_id)   (_p2p_id), 0, ((_p2p_id) && (_p2p_id)->data)?(int)(_p2p_id)->len:0, (_p2p_id)?(_p2p_id)->data:NULL

#define utp_format_s    "%p{[%4.4s]{%s}}"
#define utp_format( _cb )  \
                (_cb), (_cb)?(char*)&(_cb)->magic:0,\
                utp_cb_check_valid( (_cb), CB )?(_cb)->p2pid.data:NULL

#define utp_addrin_format_s    "%s:%d"
#define utp_addrin_format( _addr )  inet_ntoa((_addr)->sin_addr), ntohs((_addr)->sin_port)

#define utp_tunnel_format_s    "%p{[%4.4s]{"len_str_format_s"}<-->{"len_str_format_s"}}"
#define utp_tunnel_format( _cb )  \
                (_cb), (_cb)?(char*)&(_cb)->magic:0,\
                len_str_format((struct len_str*)(utp_cb_check_valid( (_cb), TUNNEL_CB )?&(_cb)->cb->p2pid:NULL)),\
                len_str_format((struct len_str*)(utp_cb_check_valid( (_cb), TUNNEL_CB )?&(_cb)->remote_p2pid:NULL))

struct utp_tunnel_cb;
struct utp_link_cb;
typedef long (*utp_on_tunnel_create)( void *ref, struct utp_tunnel_cb *tunnel_cb );
typedef long (*utp_on_link_create)( void *ref, struct utp_link_cb *link_cb, char *data, unsigned long data_len );
typedef long (*utp_on_link_forward)( void *ref, char *from_p2pid, unsigned long from_p2pid_len, char *data, unsigned long data_len );
typedef long (*utp_on_link_forward_ack)( char *ref, char *from_p2pid, unsigned long from_p2pid_len, char *data, unsigned long data_len );

typedef struct utp_create_param
{
    struct len_str          p2pid;              /*!< p2pid */
    unsigned                enable_proxy;       /*!< whether act as proxy for connect */
    struct in_addr          listen_ip;          /*!< proxy listen ip */
    unsigned long           *listen_port;       /*!< proxy listen port list */
    unsigned long           listen_port_counts; /*!< proxy listen port counts */
    unsigned long           wait_time;          /*!< wait time for shedule */
    unsigned long           uniform_send;       /*!< whether send uniform */

    unsigned long           enabel_schedule;    /*!< whether utp schedule self */
    utp_on_tunnel_create  on_tunnel_create;   /*!< callback for tunnel_create */
    utp_on_link_create    on_link_create;     /*!< callback for link_create */
    utp_on_link_forward   on_link_forward;    /*!< callback for link_create */
    utp_on_link_forward_ack   on_link_forward_ack;/*!< callback for link_create */
    void                    *on_tunnel_create_refer;/*!< refer for on_tunnel_create */
    void                    *on_link_create_refer;  /*!< refer for on_link_create */
    void                    *on_link_forward_refer;  /*!< refer for on_link_forward */
}_utp_create_param;

#define UTP_MAGIC_CB_ACTIVE        (*(long*)"p2pa    ")
#define UTP_MAGIC_CB_INACTIVE      (*(long*)"p2pi    ")
#define UTP_MAGIC_CB_FREE          (*(long*)"p2pf    ")
typedef struct utp_cb
{
    char                    magic[sizeof(long)];/*!< magic */

    unsigned long           wait_time;          /*!< wait time for shedule */
    struct len_str          p2pid;              /*!< p2pid */
    unsigned                enable_proxy;       /*!< whether act as proxy for connect */
    struct in_addr          listen_ip;          /*!< proxy listen ip */
    unsigned long           *listen_port;       /*!< proxy listen port list */
    unsigned long           listen_port_counts;  /*!< proxy listen port counts */

    unsigned long           uniform_send;       /*!< whether send uniform */

    struct in_addr          local_ip;           /*!< utp local ip addr */
    
    utp_on_tunnel_create  on_tunnel_create;   /*!< callback for tunnel_create */
    utp_on_link_create    on_link_create;     /*!< callback for link_create */
    utp_on_link_forward   on_link_forward;    /*!< callback for link_forward */
    utp_on_link_forward_ack   on_link_forward_ack;    /*!< callback for link_forward_ack */
    void                    *on_tunnel_create_refer;/*!< refer for on_tunnel_create */
    void                    *on_link_create_refer;  /*!< refer for on_link_create */
    void                    *on_link_forward_refer; /*!< refer for on_link_forward */

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
    struct utp_recv_cb    *free_recv_cb;      /*!< free recv_cb */
    struct timer_ex_cb      *timer_mod;         /*!< timer module  */

    struct
    {
        unsigned long       counts;
        struct utp_tunnel_cb    *list;
    }delay_send_tunnel_list;                  /*!< uniform send tunnel list */
    
    struct
    {
        unsigned long       counts;
        struct utp_tunnel_cb    *list;
    }delay_destroy_tunnel_list;                      /*!< inactive tunnel list that delay to be destroy */
    struct
    {
        unsigned long       counts;
        struct utp_link_manage_cb    *list;
    }delay_destroy_link_manage_list;                        /*!< inactive link_manage list that delay to be destroy */
    struct
    {
        unsigned long       counts;
        struct utp_link_cb    *list;
    }delay_destroy_link_list;                        /*!< inactive link list that delay to be destroy */
}_utp_cb;

typedef struct utp_socket_create_param
{
    struct utp_cb         *cb;
    struct in_addr          local_ip;           /*!< utp local ip addr */
    unsigned long           local_port;         /*!< utp local_port */
}_utp_socket_create_param;

typedef struct utp_socket_cb
{
    struct utp_cb         *cb;                /*!< utp cb */
    long                    socket;             /*!< utp socket */
    struct in_addr          local_ip;           /*!< utp local ip addr */
    long                    local_port;         /*!< utp local_port */
    long                    ref_counts;         /*!< utp ref counts */
    unsigned long           block_counts;       /*!< block counts */

    struct
    {
        unsigned long       counts;
        struct utp_socket_data_cb   *list;
    }wait_send_data_list;                              /*!< send cb list head */
    
    struct
    {
        unsigned long       counts;
        struct utp_tunnel_cb   *list;
    }wait_send_tunnel_list;
}_utp_socket_cb;

typedef struct utp_socket_data_cb
{
    struct sockaddr_in      addr;
    unsigned long           data_len;
    struct
    {
        struct utp_socket_data_cb    *prev;
        struct utp_socket_data_cb    *next;
    }node;
    char                    cdata[0];  /*!< buffer to store data */
}_utp_socket_send_cb;

/* tunnel section */
struct utp_tunnel_notify;
typedef long (*utp_tunnel_on_data)( void *ref, char *data, int len );
typedef long (*utp_tunnel_on_notify)( void *ref, struct utp_tunnel_notify *notify );

typedef struct utp_tunnel_create_param
{
    struct utp_cb         *cb;                /*!< utp cb */
    struct len_str          remote_p2pid;       /*!< remote p2pid */
    struct len_str          remote_addr;        /*!< utp remote addr */
    unsigned long           remote_port;        /*!< utp remote port */
    struct len_str          proxy_addr;         /*!< utp server ip or domain */
    unsigned long           proxy_port;         /*!< utp server local_port */
    struct utp_socket_cb  *socket_cb;         /*!< utp socket_cb */
    struct sockaddr_in      remote_addr_private;/*!< private addr */
    struct sockaddr_in      remote_addr_public; /*!< public addr */
    long                    enable_confusion;   /* Indicate whether enabel confusion */

    utp_tunnel_on_data      on_data;            /*!< callback to process arrive data */
    utp_tunnel_on_notify    on_notify;          /*!< callback to process utp_tunnel_notify */
    void                    *refer;             /*!< refer of user module */

    long                    dump_sample;
    struct len_str          dump_sample_path;
    long                    dump_sample_counts;
}_utp_tunnel_create_param;

typedef struct utp_tunnel_get_param
{
    struct utp_cb         *cb;                /*!< utp cb */
    struct len_str          remote_p2pid;       /*!< remote p2pid */
    struct len_str          remote_addr;        /*!< utp remote addr */
    unsigned long           remote_port;        /*!< utp remote port */
}_utp_tunnel_get_param;

typedef struct utp_remote_addr_cb
{
    struct sockaddr_in      remote_addrin;        /*!< remote address */
    struct utp_tunnel_cb  *tunnel_cb;         /*!< tunnel cb */
}_utp_remote_addr_cb;

typedef struct utp_recv_cb
{
    unsigned long           tick_recv;          /*!< tick for tunnel create */
    uint16_t                frag_seq;           /*!< data sequence */
    char                    reserve[2];
    long                    data_size;          /*!< data size */
    struct
    {
        struct utp_recv_cb   *prev;
        struct utp_recv_cb   *next;
    }node;                                      /*!< node in range_cb */
    
    char                    cdata[UTP_MSG_MAX_SIZE];  /*!< buffer to store msg */
}_utp_recv_cb;

typedef struct utp_tunnel_transmit_cb
{
    uint16_t                send_frag_seq_latest;    /*!< latest send sequence */
    uint16_t                send_frag_seq_finish;    /*!< latest sequence that no need retransmit */
    struct
    {
        unsigned long       counts;
        struct utp_tunnel_data_cb    *list;
    }data_cb_list;                              /*!< user data cb list */
    
    struct
    {
        unsigned long       counts;
        struct utp_tunnel_fragment_cb   *list;
    }send_window;                              /*!< send cb list head */

    struct
    {
        unsigned long       counts;
        struct utp_tunnel_fragment_cb   *list;
    }wait_send_window;                              /*!< send cb list head */
    
    uint16_t                commit_frag_seq_finish; /*!< frag_seq that have commit to user */
    uint16_t                recv_frag_seq_finish;   /*!< frag_seq tail continous */
    unsigned long           tick_recv_frag_seq_finish;/*!< tick for receive recv_frag_seq_finish */
    struct
    {
        unsigned long       counts;
        struct utp_recv_cb    *list;
    }wait_commit;                                   /*!< recv_cb continous wait to be commit to user */
    struct utp_recv_cb    *recv_window[UTP_WRAP_MAX( RECV_CB )];    /*!< recv_window to store received data, not continuous */
    unsigned long           recv_window_size;   /*!< size */
    struct speed_statistic  *send_static;
    struct speed_statistic  *recv_static;
}_utp_tunnel_transmit_cb;

#define UTP_MAGIC_TUNNEL_CB_ACTIVE          (*(long*)"tnla    ")
#define UTP_MAGIC_TUNNEL_CB_INACTIVE        (*(long*)"tnli    ")
#define UTP_MAGIC_TUNNEL_CB_FREE            (*(long*)"tnlf    ")

typedef struct utp_tunnel_cb
{
    char                    magic[sizeof(long)];/*!< magic */
    struct utp_cb         *cb;                /*!< utp cb */
    struct len_str          remote_p2pid;       /*!< utp id */
    struct utp_socket_cb  *socket_cb;         /*!< utp socket_cb */
    struct sockaddr_in      remote_addr_in;     /*!< remote addr */
    struct sockaddr_in      remote_addr_in_private; /*!< private addr */
    struct sockaddr_in      remote_addr_in_public;  /*!< public addr */
    struct sockaddr_in      remote_addr_in_his[2];  /*!< remote addr history */
    struct sockaddr_in      proxy_addr_in;      /*!< proxy addr */
    long                    enable_confusion;   /* Indicate whether enabel confusion */

    struct len_str          remote_addr;        /*!< utp remote addr. */
    unsigned long           remote_port;        /*!< utp remote port.  */
    struct len_str          proxy_addr;         /*!< utp server ip or domain. */
    unsigned long           proxy_port;         /*!< utp server local_port. */

    unsigned long           unlimited_bandwidth;/*!< unlimited bandwidth for same private network */      
    unsigned long           disable_unlimited_bandwidth;/*!< disable unlimited_bandwidth */      
    unsigned long           loopback;           /*!< indicate loopback tunnel. */
    unsigned long           connect_mode;       /*!< 1:conect_dirctly; 2:connect through proxy */
    unsigned long           connect_role;       /*!< 1:caller; 2:called */
    unsigned long           connect_fail_times; /*!< connect times */
    unsigned long           connect_state;      /*!< connect state */
    unsigned long           sub_connect_fail_times; /*!< try times for sub state */
    unsigned long           connect_poll_port;  /*!< next poll connect port */
    struct timer_ex         *timer_connect;     /*!< timer for connect */

    unsigned long           internal_user_module;   /*!< whether user module is internal module.  */    
    utp_tunnel_on_data    on_data;            /*!< callback to process arrive data */
    utp_tunnel_on_notify  on_notify;          /*!< callback to process utp_tunnel_notify */
    void                    *refer;             /*!< refer of user module */

    struct utp_tunnel_transmit_cb urgent_transmit_cb;   /*!< urgent transmit cb. i.e. audio */
    struct utp_tunnel_transmit_cb transmit_cb;        /*!< transmit cb. */
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
    uint16_t                ack_msg_seq_latest; /*!< latest msg_seq that remote have ack */
    unsigned long           unack_data_counts;  /*!< unack data counts */
    unsigned long           unack_msg_counts;   /*!< unack data counts */

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
        struct utp_tunnel_cb   *prev;
        struct utp_tunnel_cb   *next;
    }delay_destroy_node;                                      /*!< node */
    
    struct
    {
        struct utp_tunnel_cb   *prev;
        struct utp_tunnel_cb   *next;
    }delay_send_node;                                 /*!< node */

    struct
    {
        struct utp_tunnel_cb   *prev;
        struct utp_tunnel_cb   *next;
    }wait_sock_node;                                      /*!< node */
    
    struct utp_bw             *bw_cb;
    unsigned long               tick[UTP_WRAP_MAX( TICK_RECORD )];
    long                    dump_sample;
    struct len_str          dump_sample_path;
    long                    dump_sample_counts;
    long                        ref_counts;
}_utp_tunnel_cb;


typedef struct utp_tunnel_data_cb
{
    void                    *refer;             /*!< refer for send result */
    unsigned long           counts_wait_ack;    /*!< fragment wait ack */
    unsigned long           tick_enque;         /*!< tick receive send request from user module */
    unsigned long           data_len;           /*!< msg_data_size and pack head size */
    struct
    {
        struct utp_tunnel_data_cb    *prev;
        struct utp_tunnel_data_cb    *next;
    }node;                                      /*!< send cb list node */
}_utp_tunnel_userdata_cb;

typedef struct utp_tunnel_fragment_cb
{
    struct utp_tunnel_data_cb *data_cb;       /*!< user data cb */
    unsigned long           urgent;             /*!< urgent flag */
    unsigned long           seq;                /*!< data sequence */
    unsigned long           msg_seq;            /*!< data sequence */
    unsigned long           msg_size;          /*!< msg_data_size and pack head size */
    unsigned long           data_size;          /*!< user_data_size */
    unsigned long           send_tick;          /*!< tick latest send */
    struct
    {
        struct utp_tunnel_fragment_cb   *prev;
        struct utp_tunnel_fragment_cb   *next;
    }node;                                      /*!< send cb list node */
    
    char                    cdata[UTP_MSG_MAX_SIZE];  /*!< buffer to store pack */
}_utp_tunnel_fragment_send_cb;

typedef struct utp_range_cb
{
    struct
    {
        struct utp_range_cb   *prev;
        struct utp_range_cb   *next;
    }node;                                      /*!< node in range_list */

    struct
    {
        unsigned long       counts;
        struct utp_recv_cb    *list;
    }recv_cb_list;
}_utp_range_cb;

typedef struct utp_tunnel_notify
{
    int                     notify_type;        /*!< notify type */
    void                    *refer;             /*!< data */
    unsigned long           bandwidth;          /*!< expect bandwidth */
    unsigned long           unlimited_bandwidth;/*!< unlimited bandwidth */
    unsigned long           data_size;          /*!< valid for send_ok */
    unsigned long           delay;              /*!< valid for send_ok */
    unsigned long           user_destroy;       /*!< whether user have destroy this tunnel */
}_utp_tunnel_notify;

#define UTP_BW_MAX_SIZE    1500

#define UTP_BW_MAX_LOSE_RATE (float)0.3

#define UTP_BW_STEP_TIME              1000000
#define UTP_BW_SECTION_PHYSICAL_STEP  120
#define UTP_BW_SECTION_VALID_STEP     5
#define UTP_BW_HIS_COUNTS             10
#define UTP_BW_MIN_DELTA_LEN          500

#define UTP_SPEED_STEP_TICK           1000
#define UTP_SPEED_SECTION_SIZE        10
#define UTP_SPEED_SECTION_STEP        5

#define UTP_BW_CALC_PERIOD            1000
#define UTP_BW_CALC_SLOT_COUNTS       5

#define UTP_BW_GET_BYTE_PUS_FROM_KBPS( N ) ((N)/(float)7812.5)
#define UTP_BW_GET_KBPS_FROM_BYTE_PUS( N ) ((long)((N)*(float)7812.5))
#define UTP_BW_KBPS_DEFAULT                512
#define UTP_BW_KBPS_MAX                1048576
#define UTP_BW_NOTIFY_SCALE           ((float)1)
#define UTP_BW_NOTIFY_MIN_SCALE       ((float)0.1)
#define UTP_BW_NOTIFY_MIN_KBPS        10
#define UTP_BW_MSG_COUNTS_MIN_STEP    5

#define UTP_BW_UNIFORM_SEND_KBPS_DEFAULT   UTP_BW_KBPS_DEFAULT
#define UTP_BW_UNIFORM_SEND_KBPS_MIN  64
#define UTP_BW_UNIFORM_SEND_PERIOD    5000
#define UTP_BW_UNIFORM_SEND_SCALE     ((float)1/(1-UTP_BW_MAX_LOSE_RATE))
#define UTP_BW_HEAD_SIZE              50

typedef struct utp_bw_msg
{
    long                seq;                    /* message seq */
    long                len;                    /* message len( include header of pppoe, ip, udp, and p2p ) */
    long                data_len;               /* user data len( p2p_link ) */
    long                time_send;              /* send time(us) */
    long                time_arrive;            /* arrive time at receiver(us) */
    long                time_sch_start;         /* forecast start send time according to physical_bw */
    long                time_sch_end;           /* forecast start finish time according to physical_bw */
    long                time_cache;             /* delay time by other user */
}_utp_bw_msg;

typedef struct utp_bw_step
{
    long                time_start_next;        /* next step start time */
    long                time_cast[UTP_BW_MAX_SIZE];   /* transmit cast for all message length */
    long                bw_time_1;              /* refer time_cast 1( minimize time_cast with larger message len ) for calculate physical bw */
    long                bw_len_1;               /* refer len 1( minimize time_cast with larger message len ) for calculate physical bw */
    long                bw_time_2;              /* refer time_cast 2( max speed calculate by 1 ) for calculate physical bw */
    long                bw_len_2;               /* refer len 2( max speed calculate by 1 ) for calculate physical bw */
    long                msg_send_counts;        /* message send counts */
    long                msg_send_len;           /* message send len */
    long                msg_arrive_len;         /* message arrive len */
    long                msg_recv_counts;        /* message recv counts */
    long                msg_recv_len;           /* message recv len */
    long                data_send_len;          /* data send len */
    long                time_cache;             /* delay time by other user */
    float               lose_rate;              /* lose rate */
    long                refer_time;             /* refer time for calculate */
}_utp_bw_step;

typedef struct utp_bw
{
    struct utp_tunnel_cb  *tunnel_cb;         /* tunnel cb */
    long                    time_step;          /* time each step */
    long                    time_adjust;        /* refer time for adjust time_arrive to calculate time_cast */
    long                    time_start;         /* step start time */
    struct utp_bw_msg     msgs[UTP_WRAP_MAX(MSG_RECORD)];  /* latest message record */
    struct utp_bw_step    step;               /* current step */
    struct
    {
        long                max_step_counts;    /* max refer step */
        long                max_his_counts;     /* max history record */
        long                step_counts;        /* step counts */
        long                his_counts;         /* history record counts */
        struct utp_bw_step *steps;            /* steps */
        struct utp_bw_step step_summary;      /* step summary for calculate bw */
        float              bw;                  /* result bw */
        float              bw_calc;             /* original bw calclulate, need to be formated to result bw. only for physical. */
        float              *his;                /* history result bw */
    }sections[2],*section_physical, *section_valid;

    float                   uniform_send_speed; /* uniform send speed */
    long                    notify_bw;          /* bw latest notify to user module */
}_utp_bw;

extern struct utp_bw* utp_bw__create( struct utp_tunnel_cb *tunnel_cb, unsigned long time_step, unsigned long physical_step, unsigned long valid_step, unsigned long max_his_counts );
extern long utp_bw__destroy( struct utp_bw *cb );
extern long utp_bw__dump( char *path, long max_counts, char *data );
extern float utp_bw__format( float bw );
extern long utp_bw__notify( struct utp_tunnel_cb *tunnel_cb);
extern long utp_bw__push_arrive( struct utp_bw *cb, long seq, long time_local, long time_arrive );
extern long utp_bw__push_send( struct utp_bw *cb, long seq, long len, long data_len, long time_send );
extern long utp_bw__push_recv( struct utp_bw *cb, long len );
extern long utp_bw__push_step( struct utp_bw *cb );
extern struct utp_cb *utp_create( struct utp_create_param *param );
extern long utp_destroy( struct utp_cb *cb );
extern long utp_schedule( struct utp_cb *cb );
extern struct utp_socket_cb * utp_socket__create( struct utp_socket_create_param *param );
extern long utp_socket__destroy( struct utp_socket_cb *socket_cb );
extern long utp_socket__ref( struct utp_socket_cb *socket_cb, void *ref );
extern long utp_socket__unref( struct utp_socket_cb *socket_cb, void *ref );
extern long utp_thread_routine( struct utp_cb *cb );
extern struct utp_tunnel_cb * utp_tunnel_create( struct utp_tunnel_create_param *param );
extern long utp_tunnel_destroy( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel_send( struct utp_tunnel_cb *tunnel_cb, const char *buf, int len, unsigned long time_out, void *refer, unsigned long urgent );
extern long utp_tunnel__add_remote_addr( struct utp_tunnel_cb *tunnel_cb, struct sockaddr_in *remote_addr  );
extern long utp_tunnel__build_ack_bitmap( struct utp_tunnel_cb *tunnel_cb, struct utp_msg *msg, char *buf, unsigned long buf_len );
extern long utp_tunnel__connect( struct utp_tunnel_cb *tunnel_cb );
extern struct utp_tunnel_cb * utp_tunnel__create( struct utp_tunnel_create_param *param );
extern long utp_tunnel__del_remote_addr( struct utp_tunnel_cb *tunnel_cb, struct sockaddr_in *remote_addr  );
extern long utp_tunnel__destroy( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__forward_msg_connect( struct utp_socket_cb *socket_cb, struct utp_msg *msg, struct sockaddr_in *remote_addrin );
extern long utp_tunnel__free_fragment( struct utp_tunnel_cb *tunnel_cb, unsigned long seq );
extern struct utp_tunnel_cb * utp_tunnel__get( struct utp_tunnel_get_param *param );
extern long utp_tunnel__get_status( struct utp_tunnel_cb *tunnel_cb, char *buffer, long *buffer_size );
extern long utp_tunnel__inactive( struct utp_tunnel_cb *tunnel_cb, unsigned long user_destroy );
extern long utp_tunnel__on_connected( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__on_msg_ack( struct utp_tunnel_cb *tunnel_cb, struct utp_msg *msg, unsigned long offset, unsigned long size );
extern long utp_tunnel__on_msg_ack_req( struct utp_tunnel_cb *tunnel_cb, struct utp_msg *msg );
extern long utp_tunnel__on_msg_connect( struct utp_socket_cb *socket_cb, struct utp_recv_cb *recv_cb, struct utp_msg *msg, struct sockaddr_in *remote_addrin, long flag_confusion );
extern long utp_tunnel__on_msg_data( struct utp_tunnel_cb *tunnel_cb, struct utp_recv_cb *recv_cb, struct utp_msg *msg, unsigned long found_hole );
extern long utp_tunnel__on_msg_keepalive( struct utp_tunnel_cb *tunnel_cb, struct utp_msg *msg );
extern long utp_tunnel__on_msg_release( struct utp_tunnel_cb *tunnel_cb, struct utp_msg *msg );
extern long utp_tunnel__on_timeout_ack( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__on_timeout_connect( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__on_timeout_keepalive( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__on_timeout_release( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__on_timeout_transmit( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__on_user_data( struct utp_tunnel_cb *tunnel_cb, unsigned long urgent );
extern long utp_tunnel__send_fragment( struct utp_tunnel_cb *tunnel_cb, struct utp_tunnel_fragment_cb *tunnel_fragment_cb );
extern long utp_tunnel__send_msg( struct utp_tunnel_cb *tunnel_cb, struct sockaddr_in *addr, uint8_t msg_type, struct utp_msg *msg, unsigned long msg_len );
extern long utp_tunnel__send_msg_ack( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__send_msg_ack_req( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__send_msg_connect( struct utp_tunnel_cb *tunnel_cb, unsigned char flag, unsigned long connect_type );
extern long utp_tunnel__send_msg_connect_back( struct utp_tunnel_cb *tunnel_cb, struct sockaddr_in *remote_addrin );
extern long utp_tunnel__send_msg_keepalive( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__send_msg_release( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__send_user_data( struct utp_tunnel_cb *tunnel_cb, const char *buf0, int buf_len0, const char *buf1, int buf_len1, const char *buf2, int buf_len2, void *refer, unsigned urgent );
extern long utp_tunnel__set_connect_state( struct utp_tunnel_cb *tunnel_cb, unsigned long connect_state );
extern long utp_tunnel__start_timer_connect( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__stop_timer_connect( struct utp_tunnel_cb *tunnel_cb );
extern long utp_tunnel__transmit( struct utp_tunnel_cb *tunnel_cb, unsigned long tail_msg_seq, unsigned long urgent );
extern struct utp_cb *utp__create( struct utp_create_param *param );
extern long utp__destroy( struct utp_cb *cb );
extern long utp__get_local_addr( struct utp_socket_cb *socket_cb, struct sockaddr_in *local_private_addr );
extern long utp__get_sockaddr_in_by_addr( struct len_str *addr_in, unsigned long port, struct sockaddr_in *addr_out );
extern long utp__hash_compare_by_sockaddr_in( struct sockaddr_in *key1, struct sockaddr_in *key2, void *ref );
extern unsigned long utp__hash_get_value_by_sockaddr_in( struct sockaddr_in *key, void *ref );
extern long utp__inactive( struct utp_cb *cb );
/*
extern inline void utp__lock_release();
extern inline void utp__lock_wait();
*/
extern long utp__on_recv( struct utp_socket_cb *socket_cb, struct utp_recv_cb *recv_cb, struct sockaddr_in *remote_addrin );
extern long utp__on_send( struct utp_socket_cb *socket_cb );
extern long utp__schedule( struct utp_cb *cb );
extern long utp__send_msg_release( struct utp_socket_cb *socket_cb, struct sockaddr_in *remote_addrin, long flag_confusion );
extern long utp_tunnel__disable_ulimited_bandwidth( struct utp_tunnel_cb *tunnel_cb );
extern long utp_frame__base_confusion_encode(unsigned char *buf, unsigned long size);
extern long utp_frame__base_confusion_decode(unsigned char *buf, unsigned long size);

#endif /* !defined(__utp_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
