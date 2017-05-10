#if !defined(__mgmq_gw_info_type_magic)
#define __mgmq_gw_info_type_magic 0x110c88bd
#pragma pack(push, 1)
typedef struct mgmq_gw_info
{
    struct pack_lenstr  potocol;    /* protocol */
    struct pack_lenstr  host;       /* host */
    uint32_t            port;       /* port */
}_mgmq_gw_info;
#pragma pack(pop)
#elif (__mgmq_gw_info_type_magic != 0x110c88bd)
#error mgmq_gw_info type defined but not match
#endif /* !defined(__mgmq_gw_info_type_magic) */


#if !defined(__mgmq_watcher_info_type_magic)
#define __mgmq_watcher_info_type_magic 0x708ce9ad
#pragma pack(push, 1)
typedef struct mgmq_watcher_info
{
    struct mgmq_gw_info gw;     /* mgmq gateway info */
    int32_t             mqid;   /* message local queue id, normal should be cid */
}_mgmq_watcher_info;
#pragma pack(pop)
#elif (__mgmq_watcher_info_type_magic != 0x708ce9ad)
#error mgmq_watcher_info type defined but not match
#endif /* !defined(__mgmq_watcher_info_type_magic) */


#if !defined(__mgmq_node_info_type_magic)
#define __mgmq_node_info_type_magic 0x521475cd
#pragma pack(push, 1)
typedef struct mgmq_node_info
{
    int32_t             vid;    /* verify id, every gmq-node should have unique vid when be changed every time */
    uint32_t            role;   /* role, 1:manager, 2:reader, 4:writer, all bits zero, means detach. */
    struct pack_bytes   ctx;    /* contex data */
}_mgmq_node_info;
#pragma pack(pop)
#elif (__mgmq_node_info_type_magic != 0x521475cd)
#error mgmq_node_info type defined but not match
#endif /* !defined(__mgmq_node_info_type_magic) */


#if !defined(__mgmq_wnode_info_type_magic)
#define __mgmq_wnode_info_type_magic 0x5ad1cbef
#pragma pack(push, 1)
typedef struct mgmq_wnode_info
{
    struct mgmq_watcher_info    watcher;    /* mgmq watcher */
    struct mgmq_node_info       node;       /* mgmq node */
}_mgmq_wnode_info;
#pragma pack(pop)
#elif (__mgmq_wnode_info_type_magic != 0x5ad1cbef)
#error mgmq_wnode_info type defined but not match
#endif /* !defined(__mgmq_wnode_info_type_magic) */


#if !defined(__mgmq_group_wnodes_type_magic)
#define __mgmq_group_wnodes_type_magic 0xc2d983e5
#pragma pack(push, 1)
typedef struct mgmq_group_wnodes
{
    struct pack_lenstr      group;                      /* mgmq group */
    uint32_t                flag;                       /* flag, 0:channge part, 1:whole watcher list */
    uint32_t                nodes_counts;               /* nodes counts */
    struct mgmq_wnode_info  pack_def_pointer(nodes);    /* [0-100] */
}_mgmq_group_wnodes;
#pragma pack(pop)
#elif (__mgmq_group_wnodes_type_magic != 0xc2d983e5)
#error mgmq_group_wnodes type defined but not match
#endif /* !defined(__mgmq_group_wnodes_type_magic) */


#if !defined(__mgmq_gnode_info_type_magic)
#define __mgmq_gnode_info_type_magic 0xddf181b8
#pragma pack(push, 1)
typedef struct mgmq_gnode_info
{
    struct pack_lenstr      group;  /* mgmq group */
    struct mgmq_node_info   node;   /* mgmq node */
}_mgmq_gnode_info;
#pragma pack(pop)
#elif (__mgmq_gnode_info_type_magic != 0xddf181b8)
#error mgmq_gnode_info type defined but not match
#endif /* !defined(__mgmq_gnode_info_type_magic) */


#if !defined(__mgmq_watcher_gnodes_type_magic)
#define __mgmq_watcher_gnodes_type_magic 0x1efe4e67
#pragma pack(push, 1)
typedef struct mgmq_watcher_gnodes
{
    struct mgmq_watcher_info    watcher;                    /* mgmq watcher */
    uint32_t                    flag;                       /* flag, 0:channge part, 1:whole watcher list */
    uint32_t                    nodes_counts;               /* nodes counts */
    struct mgmq_gnode_info      pack_def_pointer(nodes);    /* [0-100] */
}_mgmq_watcher_gnodes;
#pragma pack(pop)
#elif (__mgmq_watcher_gnodes_type_magic != 0x1efe4e67)
#error mgmq_watcher_gnodes type defined but not match
#endif /* !defined(__mgmq_watcher_gnodes_type_magic) */


#if !defined(__mgmq_watcher_vids_type_magic)
#define __mgmq_watcher_vids_type_magic 0x6919ac16
#pragma pack(push, 1)
typedef struct mgmq_watcher_vids
{
    struct mgmq_watcher_info    watcher;                /* watcher */
    uint32_t                    flag;                   /* 0 bit: begin, 1 bit: end, 2 bit: missing (just for ack), 3bit: delete */
    uint32_t                    vids_counts;            /* vids counts */
    int32_t                     pack_def_pointer(vids); /* [0-1000]verify id list, if not first seg should set vids[0] as prev vids[vids.counts - 1] to let reciver deal with simplely. */
}_mgmq_watcher_vids;
#pragma pack(pop)
#elif (__mgmq_watcher_vids_type_magic != 0x6919ac16)
#error mgmq_watcher_vids type defined but not match
#endif /* !defined(__mgmq_watcher_vids_type_magic) */


#if !defined(__mgmq_notify_type_magic)
#define __mgmq_notify_type_magic 0xe2a381d6
#pragma pack(push, 1)
typedef struct mgmq_notify
{
    uint32_t                    flag;                       /* flags, bit0: is mute mgmq_notify in mgmq_watch_ack, for gmq-server sync */
    struct mgmq_watcher_info    watcher;                    /* report watcher */
    uint32_t                    gitems_counts;              /* gitems counts */
    struct mgmq_group_wnodes    pack_def_pointer(gitems);   /* [0-100]group wnodes */
    uint32_t                    witems_counts;              /* witems counts */
    struct mgmq_watcher_gnodes  pack_def_pointer(witems);   /* [0-100]watcher gnodes */
    uint32_t                    vitems_counts;              /* vitems counts */
    struct mgmq_watcher_vids    pack_def_pointer(vitems);   /* [0-100]vids list */
}_mgmq_notify;
#pragma pack(pop)
#elif (__mgmq_notify_type_magic != 0xe2a381d6)
#error mgmq_notify type defined but not match
#endif /* !defined(__mgmq_notify_type_magic) */


#if !defined(__mgmq_notify_ack_type_magic)
#define __mgmq_notify_ack_type_magic 0xa5001c7a
#pragma pack(push, 1)
typedef struct mgmq_notify_ack
{
    int32_t             result; /* result, 0:succeed, other:error code */
    struct mgmq_notify  notify; /* mgmq notify */
}_mgmq_notify_ack;
#pragma pack(pop)
#elif (__mgmq_notify_ack_type_magic != 0xa5001c7a)
#error mgmq_notify_ack type defined but not match
#endif /* !defined(__mgmq_notify_ack_type_magic) */


#if !defined(__mgmq_verify_type_magic)
#define __mgmq_verify_type_magic 0xa6636422
#pragma pack(push, 1)
typedef struct mgmq_verify
{
    uint32_t                    flag;                       /* 0 bit: begin, 1 bit: end */
    struct mgmq_watcher_info    watcher;                    /* report watcher, if send by client:self, if send by server:empty */
    uint32_t                    vitems_counts;              /* vitems counts */
    struct mgmq_watcher_vids    pack_def_pointer(vitems);   /* [0-100]mgmq verify items */
}_mgmq_verify;
#pragma pack(pop)
#elif (__mgmq_verify_type_magic != 0xa6636422)
#error mgmq_verify type defined but not match
#endif /* !defined(__mgmq_verify_type_magic) */


#if !defined(__mgmq_verify_ack_type_magic)
#define __mgmq_verify_ack_type_magic 0xa5001c7a
#pragma pack(push, 1)
typedef struct mgmq_verify_ack
{
    int32_t             result; /* 0: succeed, other: error code */
    struct mgmq_notify  notify; /* notify to update */
}_mgmq_verify_ack;
#pragma pack(pop)
#elif (__mgmq_verify_ack_type_magic != 0xa5001c7a)
#error mgmq_verify_ack type defined but not match
#endif /* !defined(__mgmq_verify_ack_type_magic) */


#if !defined(__mgmq_sync_type_magic)
#define __mgmq_sync_type_magic 0x386744ee
#pragma pack(push, 1)
typedef struct mgmq_sync
{
    uint32_t                    flag;                       /* 0 bit: begin, 1 bit: end */
    uint32_t                    watchers_counts;            /* watchers counts */
    struct mgmq_watcher_info    pack_def_pointer(watchers); /* [0-100]report watcher, if send by client:self, if send by server:empty */
}_mgmq_sync;
#pragma pack(pop)
#elif (__mgmq_sync_type_magic != 0x386744ee)
#error mgmq_sync type defined but not match
#endif /* !defined(__mgmq_sync_type_magic) */


#if !defined(__mgmq_sync_ack_type_magic)
#define __mgmq_sync_ack_type_magic 0x874b88a5
#pragma pack(push, 1)
typedef struct mgmq_sync_ack
{
    int32_t             result; /* result, 0:succeed, other:error code */
    struct mgmq_verify  verify; /* mgmq verify */
}_mgmq_sync_ack;
#pragma pack(pop)
#elif (__mgmq_sync_ack_type_magic != 0x874b88a5)
#error mgmq_sync_ack type defined but not match
#endif /* !defined(__mgmq_sync_ack_type_magic) */


#if !defined(__mgmq_checksum_type_magic)
#define __mgmq_checksum_type_magic 0x558f19e6
#pragma pack(push, 1)
typedef struct mgmq_checksum
{
    struct mgmq_watcher_info    pack_def_pointer(watcher);  /* watcher, if wather-gw or port == 0, means return whole checksum.  */
}_mgmq_checksum;
#pragma pack(pop)
#elif (__mgmq_checksum_type_magic != 0x558f19e6)
#error mgmq_checksum type defined but not match
#endif /* !defined(__mgmq_checksum_type_magic) */


#if !defined(__mgmq_checksums_info_type_magic)
#define __mgmq_checksums_info_type_magic 0x9640c70b
#pragma pack(push, 1)
typedef struct mgmq_checksums_info
{
    struct mgmq_watcher_info    watcher;    /* watcher */
    uint32_t                    sum;        /* checksums' sum value */
    uint32_t                    xor;        /* checksums' xor value */
}_mgmq_checksums_info;
#pragma pack(pop)
#elif (__mgmq_checksums_info_type_magic != 0x9640c70b)
#error mgmq_checksums_info type defined but not match
#endif /* !defined(__mgmq_checksums_info_type_magic) */


#if !defined(__mgmq_checksum_ack_type_magic)
#define __mgmq_checksum_ack_type_magic 0x67743adf
#pragma pack(push, 1)
typedef struct mgmq_checksum_ack
{
    int32_t                     result;                         /* result, 0:succeed, other:error code */
    uint32_t                    checksums_counts;               /* checksums counts */
    struct mgmq_checksums_info  pack_def_pointer(checksums);    /* [0-100] */
}_mgmq_checksum_ack;
#pragma pack(pop)
#elif (__mgmq_checksum_ack_type_magic != 0x67743adf)
#error mgmq_checksum_ack type defined but not match
#endif /* !defined(__mgmq_checksum_ack_type_magic) */


