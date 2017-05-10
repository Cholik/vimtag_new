#if !defined(__param_field_type_magic)
#define __param_field_type_magic 0x169090d4
#pragma pack(push, 1)
typedef struct param_field
{
    struct pack_lenstr  name;   /* parameter name */
    struct pack_lenstr  value;  /* value */
}_param_field;
#pragma pack(pop)
#elif (__param_field_type_magic != 0x169090d4)
#error param_field type defined but not match
#endif /* !defined(__param_field_type_magic) */


#if !defined(__gw_download_type_magic)
#define __gw_download_type_magic 0xd8482a9a
#pragma pack(push, 1)
typedef struct gw_download
{
    uint32_t            flags;                      /* flags */
    struct pack_lenstr  key;                        /* key, can used to save document id, to dec message exchange counts */
    struct pack_lenstr  url;                        /* url */
    uint32_t            reply_comp;                 /* indicate send gw_download_ack to sender without handle */
    uint32_t            params_counts;              /* params counts */
    struct param_field  pack_def_pointer(params);   /* [0-100]parameters */
    struct pack_bytes   content;                    /* content */
}_gw_download;
#pragma pack(pop)
#elif (__gw_download_type_magic != 0xd8482a9a)
#error gw_download type defined but not match
#endif /* !defined(__gw_download_type_magic) */


#if !defined(__gw_download_ack_type_magic)
#define __gw_download_ack_type_magic 0xd8c3f9b5
#pragma pack(push, 1)
typedef struct gw_download_ack
{
    int32_t                 result;                         /* result */
    uint32_t                flags;                          /* flags */
    struct pack_lenstr      key;                            /* key, can used to save document id, to dec message exchange counts */
    struct pack_lenstr      url;                            /* url */
    uint32_t                rsp_status;                     /* server response status, if local error should be 0 */
    uint32_t                known_params_counts;            /* known_params counts */
    uint32_t                pack_def_pointer(known_params); /* [0-100]known parameters index, if zero, means have not */
    uint32_t                params_counts;                  /* params counts */
    struct param_field      pack_def_pointer(params);       /* [0-100]parameters */
    struct pack_lenstr      content;                        /* file content */
}_gw_download_ack;
#pragma pack(pop)
#elif (__gw_download_ack_type_magic != 0xd8c3f9b5)
#error gw_download_ack type defined but not match
#endif /* !defined(__gw_download_ack_type_magic) */


#if !defined(__gw_comp_regist_type_magic)
#define __gw_comp_regist_type_magic 0x10ac48c1
#pragma pack(push, 1)
typedef struct gw_comp_regist
{
    struct pack_lenstr  def_xml;    /* def description */
}_gw_comp_regist;
#pragma pack(pop)
#elif (__gw_comp_regist_type_magic != 0x10ac48c1)
#error gw_comp_regist type defined but not match
#endif /* !defined(__gw_comp_regist_type_magic) */


#if !defined(__gw_route_type_magic)
#define __gw_route_type_magic 0xb815b4d7
#pragma pack(push, 1)
typedef struct gw_route
{
    struct pack_lenstr  host;       /* host */
    int32_t             port;       /* port */
    int32_t             rmt_cid;    /* remote cid */
    int32_t             local_cid;  /* local cid */
    int32_t             subscribe;  /* whether subscribe route change */
}_gw_route;
#pragma pack(pop)
#elif (__gw_route_type_magic != 0xb815b4d7)
#error gw_route type defined but not match
#endif /* !defined(__gw_route_type_magic) */


#if !defined(__gw_route_add_type_magic)
#define __gw_route_add_type_magic 0xc699ba43
#pragma pack(push, 1)
typedef struct gw_route_add
{
    uint32_t        rflag;                      /* &0x1:do not send ack; &0x2:retuen gw_route */
    uint32_t        route_counts;               /* route counts */
    struct gw_route pack_def_pointer(route);    /* [1-100] */
}_gw_route_add;
#pragma pack(pop)
#elif (__gw_route_add_type_magic != 0xc699ba43)
#error gw_route_add type defined but not match
#endif /* !defined(__gw_route_add_type_magic) */


#if !defined(__gw_route_add_ack_type_magic)
#define __gw_route_add_ack_type_magic 0x9bede294
#pragma pack(push, 1)
typedef struct gw_route_add_ack
{
    int32_t             result;                         /*  */
    uint32_t            route_counts;                   /* route counts */
    struct gw_route     pack_def_pointer(route);        /* [0-100] */
    uint32_t            local_cid_counts;               /* local_cid counts */
    int32_t             pack_def_pointer(local_cid);    /* [0-100]local cid */
}_gw_route_add_ack;
#pragma pack(pop)
#elif (__gw_route_add_ack_type_magic != 0x9bede294)
#error gw_route_add_ack type defined but not match
#endif /* !defined(__gw_route_add_ack_type_magic) */


#if !defined(__gw_route_del_type_magic)
#define __gw_route_del_type_magic 0x6c519900
#pragma pack(push, 1)
typedef struct gw_route_del
{
    uint32_t            rflag;                          /* 1:do not send ack */
    uint32_t            local_cid_counts;               /* local_cid counts */
    int32_t             pack_def_pointer(local_cid);    /* [1-100]local cid */
}_gw_route_del;
#pragma pack(pop)
#elif (__gw_route_del_type_magic != 0x6c519900)
#error gw_route_del type defined but not match
#endif /* !defined(__gw_route_del_type_magic) */


#if !defined(__gw_route_del_ack_type_magic)
#define __gw_route_del_ack_type_magic 0x9a1f5f62
#pragma pack(push, 1)
typedef struct gw_route_del_ack
{
    int32_t result; /*  */
}_gw_route_del_ack;
#pragma pack(pop)
#elif (__gw_route_del_ack_type_magic != 0x9a1f5f62)
#error gw_route_del_ack type defined but not match
#endif /* !defined(__gw_route_del_ack_type_magic) */


#if !defined(__gw_route_subscribe_type_magic)
#define __gw_route_subscribe_type_magic 0x6c519900
#pragma pack(push, 1)
typedef struct gw_route_subscribe
{
    uint32_t        rflag;                  /* 1:do not send ack */
    uint32_t        cids_counts;            /* cids counts */
    int32_t         pack_def_pointer(cids); /* [1-100]component id */
}_gw_route_subscribe;
#pragma pack(pop)
#elif (__gw_route_subscribe_type_magic != 0x6c519900)
#error gw_route_subscribe type defined but not match
#endif /* !defined(__gw_route_subscribe_type_magic) */


#if !defined(__gw_route_subscribe_ack_type_magic)
#define __gw_route_subscribe_ack_type_magic 0x9a1f5f62
#pragma pack(push, 1)
typedef struct gw_route_subscribe_ack
{
    int32_t result; /* result */
}_gw_route_subscribe_ack;
#pragma pack(pop)
#elif (__gw_route_subscribe_ack_type_magic != 0x9a1f5f62)
#error gw_route_subscribe_ack type defined but not match
#endif /* !defined(__gw_route_subscribe_ack_type_magic) */


#if !defined(__gw_route_info_type_magic)
#define __gw_route_info_type_magic 0x001f0ced
#pragma pack(push, 1)
typedef struct gw_route_info
{
    int32_t id;         /* component id */
    int32_t reachable;  /*  */
}_gw_route_info;
#pragma pack(pop)
#elif (__gw_route_info_type_magic != 0x001f0ced)
#error gw_route_info type defined but not match
#endif /* !defined(__gw_route_info_type_magic) */


#if !defined(__gw_route_notify_type_magic)
#define __gw_route_notify_type_magic 0x834beda9
#pragma pack(push, 1)
typedef struct gw_route_notify
{
    struct gw_route_info    route;  /*  */
}_gw_route_notify;
#pragma pack(pop)
#elif (__gw_route_notify_type_magic != 0x834beda9)
#error gw_route_notify type defined but not match
#endif /* !defined(__gw_route_notify_type_magic) */


#if !defined(__gw_trace_type_magic)
#define __gw_trace_type_magic 0x167c5c3d
#pragma pack(push, 1)
typedef struct gw_trace
{
    struct pack_lenstr  trace_key;  /* trace key, refer to config */
    int32_t             cid;        /* component id, if 0 ignore */
    struct pack_lenstr  def_name;   /* def name */
    int32_t             times;      /* times counts */
    uint32_t            flag;       /* trace_flag */
}_gw_trace;
#pragma pack(pop)
#elif (__gw_trace_type_magic != 0x167c5c3d)
#error gw_trace type defined but not match
#endif /* !defined(__gw_trace_type_magic) */


#if !defined(__gw_trace_ack_type_magic)
#define __gw_trace_ack_type_magic 0x001f0ced
#pragma pack(push, 1)
typedef struct gw_trace_ack
{
    int32_t result; /* trace result */
    int32_t times;  /* remained times */
}_gw_trace_ack;
#pragma pack(pop)
#elif (__gw_trace_ack_type_magic != 0x001f0ced)
#error gw_trace_ack type defined but not match
#endif /* !defined(__gw_trace_ack_type_magic) */


#if !defined(__gw_port_set_type_magic)
#define __gw_port_set_type_magic 0x001f0ced
#pragma pack(push, 1)
typedef struct gw_port_set
{
    uint32_t    rflag;  /* 1:do not send ack */
    uint32_t    port;   /* local binary port */
}_gw_port_set;
#pragma pack(pop)
#elif (__gw_port_set_type_magic != 0x001f0ced)
#error gw_port_set type defined but not match
#endif /* !defined(__gw_port_set_type_magic) */


#if !defined(__gw_port_set_ack_type_magic)
#define __gw_port_set_ack_type_magic 0x9a1f5f62
#pragma pack(push, 1)
typedef struct gw_port_set_ack
{
    int32_t result; /*  */
}_gw_port_set_ack;
#pragma pack(pop)
#elif (__gw_port_set_ack_type_magic != 0x9a1f5f62)
#error gw_port_set_ack type defined but not match
#endif /* !defined(__gw_port_set_ack_type_magic) */


#if !defined(__mmq_create_type_magic)
#define __mmq_create_type_magic 0x9a1f5f62
#pragma pack(push, 1)
typedef struct mmq_create
{
    uint32_t    timeout;    /* timer len for destroy mq if no mq_pick arrive */
}_mmq_create;
#pragma pack(pop)
#elif (__mmq_create_type_magic != 0x9a1f5f62)
#error mmq_create type defined but not match
#endif /* !defined(__mmq_create_type_magic) */


#if !defined(__mmq_create_ack_type_magic)
#define __mmq_create_ack_type_magic 0xf78017c1
#pragma pack(push, 1)
typedef struct mmq_create_ack
{
    int32_t             result; /*  */
    struct pack_lenstr  qid;    /*  */
}_mmq_create_ack;
#pragma pack(pop)
#elif (__mmq_create_ack_type_magic != 0xf78017c1)
#error mmq_create_ack type defined but not match
#endif /* !defined(__mmq_create_ack_type_magic) */


#if !defined(__mmq_pick_type_magic)
#define __mmq_pick_type_magic 0x7f39db93
#pragma pack(push, 1)
typedef struct mmq_pick
{
    struct pack_lenstr  qid;        /*  */
    uint32_t            timeout;    /* timer len for send mmq_pick_ack if no msg arrive */
}_mmq_pick;
#pragma pack(pop)
#elif (__mmq_pick_type_magic != 0x7f39db93)
#error mmq_pick type defined but not match
#endif /* !defined(__mmq_pick_type_magic) */


#if !defined(__mmq_pick_ack_type_magic)
#define __mmq_pick_ack_type_magic 0x9a1f5f62
#pragma pack(push, 1)
typedef struct mmq_pick_ack
{
    int32_t result; /*  */
}_mmq_pick_ack;
#pragma pack(pop)
#elif (__mmq_pick_ack_type_magic != 0x9a1f5f62)
#error mmq_pick_ack type defined but not match
#endif /* !defined(__mmq_pick_ack_type_magic) */


#if !defined(__mmq_destroy_type_magic)
#define __mmq_destroy_type_magic 0x10ac48c1
#pragma pack(push, 1)
typedef struct mmq_destroy
{
    struct pack_lenstr  qid;    /*  */
}_mmq_destroy;
#pragma pack(pop)
#elif (__mmq_destroy_type_magic != 0x10ac48c1)
#error mmq_destroy type defined but not match
#endif /* !defined(__mmq_destroy_type_magic) */


#if !defined(__mmq_destroy_ack_type_magic)
#define __mmq_destroy_ack_type_magic 0x9a1f5f62
#pragma pack(push, 1)
typedef struct mmq_destroy_ack
{
    int32_t result; /*  */
}_mmq_destroy_ack;
#pragma pack(pop)
#elif (__mmq_destroy_ack_type_magic != 0x9a1f5f62)
#error mmq_destroy_ack type defined but not match
#endif /* !defined(__mmq_destroy_ack_type_magic) */


