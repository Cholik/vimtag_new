/*!
\file       metp_mod.h
\brief      mining endpoint transport protocol

 ----history----
\author     chengzhiyong
\date       2013-07-15
\version    0.01
\desc       create
*/

#if !defined(__metp_mod_h__)
#define __metp_mod_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

#if !defined(__len_str_defined)
#   define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */

struct metp_sock_stack;
struct metp_mod;
struct metp_group;
struct metp_sock;
struct metp_forward;
struct metp_tunnel;
struct metp_queue;
struct metp_frag;

#if !defined(metp_capability_debug_tunnel_loss_enable)
#   define metp_capability_debug_tunnel_loss_enable     1       /*!< enable debug tunnel loss code */
#   define metp_debug_tunnel_loss_frames                2       /*!< debug tunnel loss defaut setting, lost 1 per this frames, 0: will not auto loss util user set it. */
#endif

/*! \brief metp window for send and recv */
#define metp_queue_size                 64
//#define metp_resend_timestamp           (1000*1000)
#define metp_resend_timestamp           (3*1000*1000)
#define metp_ack_timestamp              (500*1000)
#define metp_ack_frags                  32
#define metp_ack_max_frags              64
#define metp_frag_send_counts_per_task  1

#define metp_queue_counts       4
/*! \brief metp frag */
typedef struct metp_frag
{
    struct
    {
        struct metp_frag        *prev;              /*!< prev frag in queue */
        struct metp_frag        *next;              /*!< next frag in queue */
    }in_que;
    unsigned long               qid:2,              /*!< queue id */
                                head:1,             /*!< is head */
                                tail:1,             /*!< is tail */
                                id:12,              /*!< frag id */
                                ack:1,              /*!< ack ready */
                                send_times:15;      /*!< send times */
    unsigned long               timestamp;          /*!< time stamp */
    unsigned short              seq;                /*!< framg seq, copy from frame.head, just for recv */
    unsigned short              recv_seq;           /*!< frame recv-seq copy from frame.head, just for recv */
    struct len_str              buf;                /*!< buffer */
    struct len_str              frame;              /*!< frame data */
    struct len_str              chunk_dat;          /*!< chunk dat */
    struct len_str              chunk_ack;          /*!< chunk ack */
    struct len_str              data;               /*!< frag data */
}_metp_frag;

typedef struct metp_queue
{
    struct
    {
        unsigned short          last_seq;           /*!< last seq */
        unsigned short          seq;                /*!< start seq in bitmap acked is set as 1 */
        unsigned short          acked_seq;          /*!< acked seq */
        unsigned long           counts;             /*!< counts in frag */
        struct metp_frag        *list;              /*!< frag list */
    }send, recv;
}_metp_queue;

typedef struct metp_addr
{
    unsigned char               ip[4];              /*!< ip address */
    unsigned long               port;               /*!< server port */
}_metp_addr;
#define metp_ip_is_zero(_ip_pt)    ((0 == ((char*)(_ip_pt))[0]) && (0 == ((char*)(_ip_pt))[1]) && (0 == ((char*)(_ip_pt))[2]) && (0 == ((char*)(_ip_pt))[3]))
#define metp_ip_cmp(_ip1, _ip2) ((((char*)(_ip1))[0] != ((char*)(_ip2))[0]) || (((char*)(_ip1))[1] != ((char*)(_ip2))[1])\
                                  || (((char*)(_ip1))[2] != ((char*)(_ip2))[2]) || (((char*)(_ip1))[3] != ((char*)(_ip2))[3]))
#define metp_ip_save(_src, _dst) \
    do{\
        ((char*)_dst)[0] = ((char*)_src)[0];\
        ((char*)_dst)[1] = ((char*)_src)[1];\
        ((char*)_dst)[2] = ((char*)_src)[2];\
        ((char*)_dst)[3] = ((char*)_src)[3];\
    }while(0)
#define metp_addr_is_setted(_addr) ((_addr)->port && ((_addr)->ip.len == sizeof(((struct metp_addr*)0)->ip)) && (0 == metp_ip_is_zero((_addr)->ip.data)))
#define metp_addr_save(_addr, _metp_addr)   \
    do{\
        if(metp_addr_is_setted(_addr))\
        {\
            metp_ip_save((_addr)->ip.data, (_metp_addr)->ip);\
            (_metp_addr)->port = (_addr)->port;\
        }\
    }while(0)

#define metp_addr_format_s      "%p{%d.%d.%d.%d:%d}"
#define metp_addr_format(_addr) (_addr), (int)((_addr)?(_addr)->ip[0]:0), (int)((_addr)?(_addr)->ip[1]:0), \
                                (int)((_addr)?(_addr)->ip[2]:0), (int)((_addr)?(_addr)->ip[3]:0),\
                                (int)((_addr)?(_addr)->port:0)

#define metp_key_append_size                32
#define metp_eid_append_size                32
#define metp_dat_chunk_payload_size_default 1280
#define metp_frame_size_default             1408
#define metp_frame_buf_size                 metp_frame_size_default
#define metp_frag_size                      (sizeof(struct metp_frag) + metp_frame_buf_size)

/*! \brief transport info */
typedef struct metp_transport
{
    struct
    {
        struct metp_addr        addr;               /*!< forward server address */
        struct len_str          key;                /*!< key for forward, for fid */
    }forward;

    struct
    {
        struct
        {
            struct metp_addr    inet;               /*!< internet address */
            struct metp_addr    lan;                /*!< lan address */
        }addr;
        unsigned char           fid[6];             /*!< peer fid of the tunnel */
        unsigned short          seq;                /*!< last, frame seq self:last-send-frag peer:last-recv-frag */
        unsigned long           timestamp;          /*!< last, seq timestamp in local host */
        struct len_str          key;                /*!< the key for peer fid */
    }self, peer;
}_metp_transport;
#define metp_transport_append_size  (3 * metp_key_append_size)

typedef enum metp_tunnel_event
{
    metpte_reg,                     /*!< metp reg server */
    metpte_connect,                 /*!< metp server */
    metpte_connected,               /*!< metp client */
    metpte_attach,                  /*!< metp client: peer addr change. */
    metpte_dettach,                 /*!< all: tunnel destroy */
    metpte_data                     /*!< data */
}_metp_tunnel_event;
typedef long (*metp_tunnel_on_event)(struct metp_tunnel *tunnel, enum metp_tunnel_event evt, unsigned long len, unsigned char *data, void *ref);

typedef enum metp_tunnel_status
{
    metpts_idle,
    metpts_reg,
    metpts_connect,
    metpts_attach,
    metpts_run,
    metpts_dettach,
    metpts_destroy
}_metp_tunnel_status;

/*! \biref metp tunnel */
#define metp_tunnel_magic       (*(long*)"mett    ")
#define metp_tunnel_magic_free  (*(long*)"METT    ")
typedef struct metp_tunnel
{
    char                        magic[sizeof(long)];/*!< magic used to check is valid */
    struct
    {
        struct metp_tunnel      *next;              /*!< next tunnel in group's tunnel list */
        struct metp_tunnel      *prev;              /*!< prev tunnel in group's tunnel list */
        struct metp_group       *owner;             /*!< the group owner */
    }in_group;

    enum metp_tunnel_status     status;             /*!< tunnel status */

    struct
    {
        struct len_str          eid;                /*!< epid */
        struct len_str          key;                /*!< the key for eid */
    }self, peer;

    struct metp_transport       transport;          /*!< transport info */

    struct metp_queue           ques[metp_queue_counts];/*!< queues */

    struct metp_sock            *sock;              /*!< for send */
    struct metp_addr            *dst;               /*!< dest addresss */
    void                        *ref;               /*!< refer data */
    metp_tunnel_on_event        on_event;           /*!< on data */
    unsigned long               dat_chunk_payload_size; /*!< dat chunk payload size */

    struct
    {
        unsigned long           create_tick;        /*!< create tick */
        unsigned long           last_timestamp;     /*!< last active tick */
        unsigned long           recv_frames;        /*!< frames */
        unsigned long           recv_bytes;         /*!< recv bytes */
        unsigned long           send_frames;        /*!< frames */
        unsigned long           send_bytes;         /*!< send bytes */
        unsigned long           sending_frags;      /*!< sending frags counts */
        unsigned long           recving_frags;      /*!< sending frags counts */
        unsigned long           acking_frags;       /*!< acking frags counts */
        unsigned long           ack_timestamp;      /*!< last ack timestamp */
        unsigned long           sent_unique_frags;  /*!< sent unique frags */
        unsigned long           sent_total_frags;   /*!< send total frags */

#if defined(metp_capability_debug_tunnel_loss_enable) && metp_capability_debug_tunnel_loss_enable
        unsigned long           debug_loss_frames;      /*!< loss debug: send [frames] be lost.  */
        unsigned long           debug_loss_sub_frames; /*!< loss debug: send every [frames] will lost one.  */
        unsigned long           debug_loss_check_frames;/*!< loss debug: need loss when reach this frames */
#endif
    }statis;
}_metp_tunnel;
#define metp_tunnel_format_s        "%p{self[%*.*s],peer[%*.*s],status[%ld]}"
#define metp_tunnel_format(_tunnel) (_tunnel), 0, (int)((_tunnel)?(_tunnel)->self.eid.len:0), \
                                    ((_tunnel)?(_tunnel)->self.eid.data:0), 0, (int)((_tunnel)?(_tunnel)->peer.eid.len:0), \
                                    ((_tunnel)?(_tunnel)->peer.eid.data:0), (long)((_tunnel)?(_tunnel)->status:0)
#define metp_tunnel_append_size     (metp_transport_append_size + (metp_key_append_size * 2) + (metp_eid_append_size * 2))
#define metp_tunnel_pack_size       (sizeof(struct metp_tunnel) + metp_tunnel_append_size)

typedef struct metp_forward_desc
{
    unsigned char               fid[6];
}_metp_forward_desc;
#define metp_forward_desc_format_s      "%p"
#define metp_forward_desc_format(_desc) (_desc)

#define metp_forward_magic      (*(long*)"metf    ")
#define metp_forward_magic_free (*(long*)"METF    ")
typedef struct metp_forward
{
    char                        magic[sizeof(long)];/*!< magic */
    struct
    {
        struct metp_forward     *next;              /*!< next forward record in mod's forwards list */
        struct metp_forward     *prev;              /*!< pref forward record in mod's forwards list */
        struct metp_group       *owner;             /*!< metp group */
    }in_group;

    unsigned char               fid[6];             /*!< fid */
    struct len_str              key;                /*!< key */
    struct metp_addr            inet;               /*!< internet address */

    struct metp_sock            *sock;              /*!< sock object */

    struct
    {
        unsigned long           create_tick;        /*!< create tick */
        unsigned long           last_timestamp;     /*!< last active tick */
        unsigned long           recv_frames;        /*!< frames */
        unsigned long           recv_bytes;         /*!< recv bytes */
        unsigned long           send_frames;        /*!< frames */
        unsigned long           send_bytes;         /*!< send bytes */
    }statis;
}_metp_forward;
#define metp_forward_format_s           "%p{fid[%02x%02x%02x%02x%02x%02x],inet["metp_addr_format_s"]}"
#define metp_forward_format(_forward)   (_forward), (_forward)?(_forward)->fid[0]:0, (_forward)?(_forward)->fid[1]:0,\
                                        (_forward)?(_forward)->fid[2]:0, (_forward)?(_forward)->fid[3]:0,\
                                        (_forward)?(_forward)->fid[4]:0, (_forward)?(_forward)->fid[5]:0,\
                                        metp_addr_format((struct metp_addr*)((_forward)?&(_forward)->inet:0))
#define metp_forward_append_size        metp_key_append_size
#define metp_forward_pack_size          (sizeof(struct metp_forward) + metp_forward_append_size)


typedef void* (*metp_sock_on_open)(struct metp_sock_stack *stack, unsigned long port, void *ref);
typedef long (*metp_sock_on_close)(struct metp_sock_stack *stack, void *handle);
typedef long (*metp_sock_on_sendto)(struct metp_sock_stack *stack, void *handle,  unsigned long len, unsigned char *data, struct metp_addr *to);
typedef struct metp_sock_stack
{
    metp_sock_on_open           on_open;
    metp_sock_on_close          on_close;
    metp_sock_on_sendto         on_sendto;
    unsigned char               local_ip1[4];
    unsigned char               local_ip2[4];
    void                        *ref;
}_metp_sock_stack;
#define metp_sock_magic         (*(long*)"mets    ")
#define metp_sock_magic_free    (*(long*)"METS    ")
typedef struct metp_sock
{
    char                        magic[sizeof(long)];
    struct
    {
        struct metp_sock        *next;
        struct metp_sock        *prev;
        struct metp_group       *owner;
    }in_group;
    unsigned long               used;
    unsigned long               port;
    void                        *handle;
}_metp_sock;
#define metp_sock_format_s      "%p"
#define metp_sock_format(_sock) (_sock)

typedef struct metp_group_desc
{
    long                        srv_enable;         /*!< enable server functions, accept connect */
    long                        reg_enable;         /*!< enable server functions, accept reg  */
    long                        forward_enable;     /*!< enable forward functions, accept forward request */
    unsigned long               port;               /*!< local port */
    struct metp_addr            srv;                /*!< server port */
    metp_tunnel_on_event        on_event;           /*!< on event */
}_metp_group_desc;
#define metp_group_desc_format_s        "%p"
#define metp_group_desc_format(_desc)   (_desc)

#define metp_group_fid_inner_mask   0x0000
#define metp_group_fid_mask         0x0001

#define metp_group_magic        (*(long*)"metg    ")
#define metp_group_magic_free   (*(long*)"METG    ")
typedef struct metp_group
{
    char                        magic[sizeof(long)];/*!< magic */
    struct
    {
        struct metp_group       *next;
        struct metp_group       *prev;
        struct metp_mod         *owner;
    }in_mod;

    struct metp_group_desc      desc;

    unsigned long               fid_mask_inner;
    unsigned long               fid_mask;
    unsigned long               fid;
    unsigned long               seq;                /*!< ctl seq */

    struct
    {
        struct metp_sock        *srv;
        unsigned long           counts;
        struct metp_sock        *list;
    }socks, socks_free;

    struct
    {
        struct metp_tunnel      *main;

        unsigned long           counts;
        struct metp_tunnel      *list;
    }tunnels, tunnels_free;

    struct
    {
        unsigned long           counts;
        struct metp_forward     *list;
    }forwards, forwards_free;
}_metp_group;
#define metp_group_format_s         "%p{magic[%4.4s],srv["metp_addr_format_s"],socks[%ld],tunnels[%ld],forwords[%ld]}"
#define metp_group_format(_group)   (_group), (_group)?(_group)->magic:0, metp_addr_format((struct metp_addr*)((_group)?&(_group)->desc.srv:0)),\
                                    (_group)?(_group)->socks.counts:0,(_group)?(_group)->tunnels.counts:0, (_group)?(_group)->forwards.counts:0
typedef struct metp_mod_desc
{
    long                        srv_enable;         /*!< enable server functions, accept connect */
    long                        reg_enable;         /*!< enable server functions, accept reg  */
    long                        forward_enable;     /*!< enable forward functions, accept forward request */
    unsigned long               port;               /*!< local port */
    metp_tunnel_on_event        on_event;           /*!< on tunnel event */
    struct metp_sock_stack      *stack;             /*!< sock provider */
}_metp_mod_desc;
#define metp_mod_desc_format_s       "%p"
#define metp_mod_desc_format(_desc)  (_desc)

/*! \biref metp module */
#define metp_mod_magic       (*(long*)"metm    ")
#define metp_mod_magic_free  (*(long*)"METM    ")
typedef struct metp_mod
{
    char                        magic[sizeof(long)];/*!< magic for check is valid */
    unsigned long               callbacking;        /*!< callback counts */
    struct metp_mod_desc        desc;               /*!< module desc */
    
    struct
    {
        unsigned long           counts;             /*!< group counts in mod */
        struct metp_group       *list;              /*!< the first group in list */
    }groups, groups_free;

    void                        *ref;               /*!< refer data */

    struct
    {
        unsigned long           forwards;           /*!< forwards counts */
        unsigned long           tunnels;            /*!< tunnels counts */
        unsigned long           socks;              /*!< sockets counts */
    }statis;
}_metp_mod;
#define metp_mod_format_s        "%p{magic[%4.4s]}"
#define metp_mod_format(_mod)    (_mod), (_mod)?(_mod)->magic:0

typedef struct metp_tunnel_desc
{
    struct metp_addr            srv;                /*!< server address */

    struct
    {
        struct len_str          eid;                /*!< endpoint id */
        struct len_str          key;                /*!< key */
    }self, peer;

    metp_tunnel_on_event        on_event;           /*!< on event */
    void                        *ref;               /*!< refer data */
}_metp_tunnel_desc;
#define metp_tunnel_desc_format_s       "%p{srv["metp_addr_format_s"], self[%*.*s], peer[%*.*s]}"
#define metp_tunnel_desc_format(_desc)  (_desc), metp_addr_format((struct metp_addr*)((_desc)?&_desc->srv:0)),\
                                        0, (int)((_desc)?(_desc)->self.eid.len:0), ((_desc)?(_desc)->self.eid.data:0), \
                                        0, (int)((_desc)?(_desc)->peer.eid.len:0), ((_desc)?(_desc)->peer.eid.data:0) 

typedef struct metp_sock_ctx
{
    struct metp_group           *group;         /*!< group */
    struct metp_sock            *sock;          /*!< refer sock */
    struct metp_addr            from;           /*!< from address and port */
    unsigned long               timestamp;      /*!< us */

    struct metp_frame           *frame;         /*!< current frame */
    struct metp_tunnel          *tunnel;        /*!< refer tunnel */
    unsigned long               last_chunk;     /*!< is last chunk */
}_metp_sock_ctx;
#define metp_sock_ctx_format_s      "%p{from[%d.%d.%d.%d:%d]}"
#define metp_sock_ctx_format(_ctx)  (_ctx), (int)((_ctx)?(_ctx)->from.ip[0]:0), (int)((_ctx)?(_ctx)->from.ip[1]:0), \
                                    (int)((_ctx)?(_ctx)->from.ip[2]:0), (int)((_ctx)?(_ctx)->from.ip[3]:0),\
                                    (int)((_ctx)?(_ctx)->from.port:0)


#define metp_err_base                       (-1)
#define metp_err_invalid_param              (metp_err_base - 1)
#define metp_err_chunk_type_unknown         (metp_err_base - 2)
#define metp_err_ctl_type_unknown           (metp_err_base - 3)
#define metp_err_alloc_failed               (metp_err_base - 4)
#define metp_err_reg_disable                (metp_err_base - 5)
#define metp_err_srv_disable                (metp_err_base - 6)
#define metp_err_connect_notify_disable     (metp_err_base - 7)
#define metp_err_attach_working_tunnel      (metp_err_base - 8)
#define metp_err_fid_invalid                (metp_err_base - 9)
#define metp_err_fid_unknown                (metp_err_base - 10)
#define metp_err_key_unmatched              (metp_err_base - 11)
#define metp_err_forward_create_failed      (metp_err_base - 12)
#define metp_err_tunnel_unknown             (metp_err_base - 13)
#define metp_err_send_failed                (metp_err_base - 14)
#define metp_err_network_unready            (metp_err_base - 15)
#define metp_err_mod_callbacking            (metp_err_base - 16)
#define metp_err_send_data_empty            (metp_err_base - 17)
#define metp_err_tunnel_destroyed           (metp_err_base - 18)
#define metp_err_tunnel_not_ready           (metp_err_base - 19)
#define metp_err_send_queue_overflow        (metp_err_base - 20)
#define metp_err_buf_overflow               (metp_err_base - 21)


struct metp_mod *metp_mod_create(struct metp_mod_desc *desc);
long metp_mod_destroy(struct metp_mod *mod);
long metp_mod_schedule(struct metp_mod *mod, unsigned long timestamp);

struct metp_tunnel *metp_tunnel_create(struct metp_mod *mod, struct metp_tunnel_desc *desc);
long metp_tunnel_destroy(struct metp_tunnel *tunnel);
struct metp_tunnel *metp_tunnel_get_by_fid(struct metp_group *group, unsigned char *fid);
struct metp_tunnel *metp_tunnel_get_by_eid(struct metp_group *group, struct len_str *eid);
struct metp_tunnel *metp_tunnel_get(struct metp_mod *mod, struct metp_addr *srv, struct len_str *eid);

long metp_mod_on_data(struct metp_sock_ctx *ctx, unsigned long len, unsigned char *data);


/*!
func    metp_dump
\brief  dump inner info from metp module 
\param  mod[in]                 the module
\param  argc[in]                the arg counts
\param  argv[in]                the arg list, if(argc == 0) can be NULL if NULL default
                                --help      : get help
                                --filter    : filter string, if empty all items will be matched.
                                --type      : type list split by ","
                                    module          : output module
                                    group           : output factory
                                    sock            : output channel class
                                    tunnel          : output channel class
                                    forward         : output channel class
                                    all             : output all type
                                    default         : same as tunnel
\param  buf[in]                 the output buffer, can be NULL, if NULL output into file 
\param  start[in]               the start record no
\param  counts[in]              max output records counts
\param  size[in]                the buf size or max content size output to file
\return content length
        #<0                     error code
        #other                  content length
*/
long metp_dump(struct metp_mod  *mod,
               unsigned long    argc,
               char             *argv[],
               char             *buf,
               char             *file,
               unsigned long    start,
               unsigned long    counts,
               unsigned long    size);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__metp_mod_h__) */

