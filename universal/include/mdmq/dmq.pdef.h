#if !defined(__dmq_gw_info_type_magic)
#define __dmq_gw_info_type_magic 0x110c88bd
#pragma pack(push, 1)
typedef struct dmq_gw_info
{
    struct pack_lenstr  potocol;    /* protocol */
    struct pack_lenstr  host;       /* host */
    uint32_t            port;       /* port */
}_dmq_gw_info;
#pragma pack(pop)
#elif (__dmq_gw_info_type_magic != 0x110c88bd)
#error dmq_gw_info type defined but not match
#endif /* !defined(__dmq_gw_info_type_magic) */


#if !defined(__dmq_watcher_info_type_magic)
#define __dmq_watcher_info_type_magic 0xffd3d77e
#pragma pack(push, 1)
typedef struct dmq_watcher_info
{
    struct dmq_gw_info  gw;     /* dmq gateway info */
    int32_t             mq_id;  /* message local queue id, normal should be cid */
    uint32_t            role;   /* role, 1:manager, 2:reader, 4:writer, all bits zero, means detach. */
    struct pack_bytes   ctx;    /* contex data */
}_dmq_watcher_info;
#pragma pack(pop)
#elif (__dmq_watcher_info_type_magic != 0xffd3d77e)
#error dmq_watcher_info type defined but not match
#endif /* !defined(__dmq_watcher_info_type_magic) */


#if !defined(__dmq_notify_item_type_magic)
#define __dmq_notify_item_type_magic 0xda974033
#pragma pack(push, 1)
typedef struct dmq_notify_item
{
    struct pack_lenstr      group_id;                   /* dmq group id */
    uint32_t                flag;                       /* flag, 0:channge part, 1:whole watcher list */
    uint32_t                watchers_counts;            /* watchers counts */
    struct dmq_watcher_info pack_def_pointer(watchers); /* [0-100] */
}_dmq_notify_item;
#pragma pack(pop)
#elif (__dmq_notify_item_type_magic != 0xda974033)
#error dmq_notify_item type defined but not match
#endif /* !defined(__dmq_notify_item_type_magic) */


#if !defined(__dmq_notify_type_magic)
#define __dmq_notify_type_magic 0x859c17fd
#pragma pack(push, 1)
typedef struct dmq_notify
{
    uint32_t                items_counts;               /* items counts */
    struct dmq_notify_item  pack_def_pointer(items);    /* [0-100] */
}_dmq_notify;
#pragma pack(pop)
#elif (__dmq_notify_type_magic != 0x859c17fd)
#error dmq_notify type defined but not match
#endif /* !defined(__dmq_notify_type_magic) */


#if !defined(__dmq_watch_item_type_magic)
#define __dmq_watch_item_type_magic 0x9b7e7e3e
#pragma pack(push, 1)
typedef struct dmq_watch_item
{
    struct pack_lenstr  group_id;   /* dmq group id */
    int32_t             mq_id;      /* message local queue id, normal should be cid */
    uint32_t            role;       /* role, 1:manager, 2:reader, 4:writer, all bits zero, means detach. */
    struct pack_bytes   ctx;        /* contex data */
}_dmq_watch_item;
#pragma pack(pop)
#elif (__dmq_watch_item_type_magic != 0x9b7e7e3e)
#error dmq_watch_item type defined but not match
#endif /* !defined(__dmq_watch_item_type_magic) */


#if !defined(__dmq_watch_type_magic)
#define __dmq_watch_type_magic 0x36fa4e61
#pragma pack(push, 1)
typedef struct dmq_watch
{
    struct dmq_gw_info      gw;                         /* dmq gateway info */
    uint32_t                items_counts;               /* items counts */
    struct dmq_watch_item   pack_def_pointer(items);    /* [0-100] */
}_dmq_watch;
#pragma pack(pop)
#elif (__dmq_watch_type_magic != 0x36fa4e61)
#error dmq_watch type defined but not match
#endif /* !defined(__dmq_watch_type_magic) */


#if !defined(__dmq_watch_ack_type_magic)
#define __dmq_watch_ack_type_magic 0x2476f25f
#pragma pack(push, 1)
typedef struct dmq_watch_ack
{
    int32_t             result; /* result, 0:succeed, other:error code */
    struct dmq_notify   notify; /* dmq notify */
}_dmq_watch_ack;
#pragma pack(pop)
#elif (__dmq_watch_ack_type_magic != 0x2476f25f)
#error dmq_watch_ack type defined but not match
#endif /* !defined(__dmq_watch_ack_type_magic) */


