/*!
\file       mgmq_base.h
\brief      dynamic message queue unit

 ----history----
\author     chengzhiyong
\date       2012-11-05
\version    0.01
\desc       create

\author     chengzhiyong
\date       2013-12-01
\version    0.02
\desc       add dynmiac sync functions

$Author: chengzhiyong $
$Id: lock.c,v 1.25 2008-08-20 09:07:42 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif

#include "mcore/mcore.h"

struct mgmq_group;
struct mgmq_gw;
struct mgmq_watcher;
struct mgmq_node;
struct mgmq_mod;
struct mgmq_mod_desc;

#define mgmq_notify_flag_need_ack           0x01
#define mgmq_notify_flag_relay              0x02

/* gmq:dynamic message queue */

#define mgmq_flag_group_new      0x01
#define mgmq_flag_gw_new         0x02
#define mgmq_flag_watcher_new    0x04
#define mgmq_flag_node_new       0x08


typedef union mgmq_ref
{
    struct
    {
        long    b0:1, b1:1, b2:1, b3:1, b4:1, b5:1, b6:1, b7:1,
                b8:1, b9:1, b10:1,b11:1,b12:1,b13:1,b14:1,b15:1,
                b16:1,b17:1,b18:1,b19:1,b20:1,b21:1,b22:1,b23:1,
                b25:1,b26:1,b27:1,b28:1,b29:1,b30:1,b31:1,b32:1;
    }bits;
    unsigned long       ul;
    void                *pt;
}_mgmq_ref;

/*! \brief dynamic message queue */
typedef struct mgmq_group
{
    struct
    {
        struct mgmq_group   *prev;              /*!< prev item in module's gmqs list */
        struct mgmq_group   *next;              /*!< next item in module's gmqs list */
        struct mgmq_group   *hash_next;         /*!< next item in module's gmqs hash-table */
    }in_mod;
    struct len_str          group_id;           /*!< gmq group string */
    struct
    {
        unsigned long       watcher_reader_ex_str_size; /*!< reader watcher host str and ctx  ext size. not include '\0' padding; */
        unsigned long       watcher_ex_str_size;/*!< wathcer host str and ctx ext size, not include '\0' padding; */
        unsigned long       reader_counts;      /*!< reader counts */
        unsigned long       writer_counts;      /*!< writer counts */
        unsigned long       counts;             /*!< counts */
        struct mgmq_node    *list;              /*!< watcher list */
    }nodes;                                     /*!< readers and writer's watcher list */
    struct
    {
        unsigned long       active:1;           /*!< active flag */
        unsigned long       reader_changed:1;   /*!< reader changed */
        unsigned long       reserved:((sizeof(long)*8) - 10);
        unsigned long       ex0:1,ex1:1,ex2:1,ex3:1,ex4:1,ex5:1,ex6:1,ex7:1;    /*!< for user module, extention */
    }flag;
    struct
    {
        unsigned long       reader_changed_node_counts;/*!< reader_changed node counts */
        unsigned long       reader_changed_node_ref_watcher_str_ex_size; /*!< reader_changed watcher.gw.host.len total size */
    }update;
    union mgmq_ref          ref;                /*!< ref data */
}_mgmq_group;
#define mgmq_group_format_s          "%p{group_id[%s], nodes[%ld]}"
#define mgmq_group_format(_group)    (_group), (_group)?(_group)->group_id.data:0, (_group)?(_group)->nodes.counts:0

/*!\brief gmq gateway */
typedef struct mgmq_gw
{
    struct
    {
        struct mgmq_gw      *prev;              /*!< prev gmq gateway in module's gws list */
        struct mgmq_gw      *next;              /*!< next gmq gateway in module's gws list */
        struct mgmq_gw      *hash_next;         /*!< next gmq gateway in module's gws hash-table */
    }in_mod;
    struct len_str          protocol;           /*!< protocol, default is mrmt */
    struct len_str          host;               /*!< the host */
    unsigned long           port;               /*!< comunication port */
    struct
    {
        unsigned long       counts;             /*!< watcher counts from this gateway */
        struct mgmq_watcher *list;              /*!< watcher list */
    }watchers;
    struct
    {
        unsigned long       active:1;           /*!< active flag */
        unsigned long       reserved:((sizeof(long)*8) - 9);
        unsigned long       ex0:1,ex1:1,ex2:1,ex3:1,ex4:1,ex5:1,ex6:1,ex7:1;    /*!< for user module, extention */
    }flag;
    uint32_t                checksum;           /*!< check sum, checksum(host,port) */
    union mgmq_ref          ref;                /*!< ref data */
}_mgmq_gw;
#define mgmq_gw_format_s     "%p{host[%s], port[%ld], watchers[%ld]}"
#define mgmq_gw_format(_gw)  (_gw), (_gw)?(_gw)->host.data:0, (_gw)?(_gw)->port:0, (_gw)?(_gw)->watchers.counts:0

/*! \brief gmq watcher */
typedef struct mgmq_watcher
{
    struct
    {
        struct mgmq_watcher  *hash_next;         /*!< hash next in module's watcher hash table */
        struct mgmq_watcher  *local_mqid_hash_next;   /*!< hash next in module's watcher local-mqid hash table */
        struct mgmq_watcher  *prev;              /*!< prev item in gw's watcher list */
        struct mgmq_watcher  *next;              /*!< next item in gw's watcher list */
    }in_mod;
    struct
    {
        struct mgmq_watcher  *prev;              /*!< prev item in gw's watcher list */
        struct mgmq_watcher  *next;              /*!< next item in gw's watcher list */
        struct mgmq_gw       *owner;             /*!< gmq gateway */
    }in_gw;                                     /*!< in gw's watcher list */
    struct
    {
        unsigned long       group_reader_ex_str_size; /*!< reader watcher host and ctx str ext size, not include '\0' padding. */
        unsigned long       group_ex_str_size;  /*!< group str and ctx ext size, not include '\0' padding. */
        unsigned long       reader_counts;      /*!< reader counts */
        unsigned long       writer_counts;      /*!< wirter counts */
        unsigned long       counts;             /*!< gmq node counts */
        struct mgmq_node    *list;              /*!< gmq node list */
        struct mgmq_node    *verify_pos;        /*!< verify position */
    }nodes;
    struct
    {
        unsigned long       active:1;           /*!< active flag */
        unsigned long       reader_changed:1;   /*!< for client: need check reader local-mqid */
        unsigned long       need_notify:1;      /*!< for server: need send notify to this watcher(writer) */
        unsigned long       sync:1;             /*!< for both server and client:
                                                     for client: sync flag, if 1 means in sync tasking need sendout mgmq_verify and waiting mgmq_notify,
                                                     for server: sync flag, if 1 means in sync tasking need sendout mgmq_sync and waiting mgmq_verify(maybe in mgmq_sync_ack) */
        unsigned long       reachable:1;        /*!< is reachable */
        unsigned long       reserved:((sizeof(long)*8) - 13);
        unsigned long       ex0:1,ex1:1,ex2:1,ex3:1,ex4:1,ex5:1,ex6:1,ex7:1;    /*!< for user module, extention */
    }flag;
    unsigned long           vid;                /*!< varify id, manage by watcher(inc), set as random value when init to check watcher is restart. */
    long                    mqid;               /*!< remote mqid, in remote container */
    long                    local_mqid;         /*!< mapped local mqid, in local container, for component send-msg */
    uint32_t                checksum;           /*!< check sum checksum(gw->mqid) */
    uint32_t                checksums_sum;      /*!< check sum's sum */
    uint32_t                checksums_xor;      /*!< check sum's sum */
    struct
    {
        uint32_t            ref_checksums_sum;  /*!< for refer watcher checksum's request */
        uint32_t            ref_checksums_xor;  /*!< for refer watcher checksum's request */  
        unsigned long       need_notify_node_counts;    /*!< need notify node counts(how many group reader_changed to this watcher) */
    }update;
    union mgmq_ref          ref;                /*!< refer data */
}_mgmq_watcher;

#if defined(_MSC_VER)
#define __MGMQFI64 "I64u"
#else
#define __MGMQFI64 "llu"
#endif

#define mgmq_watcher_format_s           "%p{gw["mgmq_gw_format_s"], mqid[0x%lx], local_mqid[0x%lx], flag[%"__MGMQFI64"], nodes[%ld], "\
                                        "checksums[{sum[0x%08lx], xor[0x%08lx]}]}"
#define mgmq_watcher_format(_watcher)   (_watcher), mgmq_gw_format((struct mgmq_gw*)((_watcher)?(_watcher)->in_gw.owner:0)), \
                                        (_watcher)?(_watcher)->mqid:0, (_watcher)?(_watcher)->local_mqid:0, (_watcher)?(*((uint64_t *)&(_watcher)->flag)):0, \
                                        (_watcher)?(_watcher)->nodes.counts:0, (unsigned long)((_watcher)?(_watcher)->checksums_sum:0), \
                                        (unsigned long)((_watcher)?(_watcher)->checksums_xor:0)

/*! \brief gmq watcher */
typedef struct mgmq_node
{
    struct
    {
        struct mgmq_node    *hash_next;         /*!< hash next in module's watcher hash table */
    }in_mod;
    struct
    {
        struct mgmq_node    *prev;              /*!< prev item in gmq's watcher list */
        struct mgmq_node    *next;              /*!< next item in gmq's watcher list */
        struct mgmq_group   *owner;             /*!< gmq group */
    }in_group;
    struct
    {
        struct mgmq_node    *prev;              /*!< prev item in gw's watcher list */
        struct mgmq_node    *next;              /*!< next item in gw's watcher list */
        struct mgmq_watcher *owner;             /*!< gmq watcher */
        struct mgmq_node    *vid_hash_next;     /*!< hash next in module's watcher&vid hash table */
    }in_watcher;                                /*!< in gw's watcher list */
    unsigned long           vid;                /*!< verify id, manage by watcher(inc), for role and ctx data changed check */
    unsigned long           role;               /*!< watcher role */
    struct len_str          ctx;                /*!< ctx */
    struct
    {
        unsigned long       active:1;           /*!< active flag */
        unsigned long       vid_hash:1;         /*!< is in vid hash table */
        unsigned long       reader_changed:1;   /*!< for server: reader changed, if changed need send this node to writers */
        unsigned long       need_notify:1;      /*!< for server: need send notify message to this watcher */
        unsigned long       verify_remote_missing:1;/*!< for owner: verify flag, if 1 means in remote missing */
        unsigned long       notify_remote_missing:1;/*!< for non-owner: notify flag, if 1 means in remote-owner is missing */
        unsigned long       reserved:((sizeof(long)*8) - 12);
        unsigned long       ex0:1,ex1:1,ex2:1,ex3:1,ex4:1,ex5:1,ex6:1,ex7:1;    /*!< for user module, extention */
    }flag;
    uint32_t                checksum_base;      /*!< check sum, checksum(gw->mqid->group-id) */
    uint32_t                checksum;           /*!< check sum, checksum(gw->mqid->group-id->node-data(role,ctx) */
    union mgmq_ref          ref;                /*!< refer data */
}_mgmq_node;
#define mgmq_node_format_s          "%p{group["mgmq_group_format_s"], watcher["mgmq_watcher_format_s"], vid[%ld], role[0x%lx], ctx[%ld]}"
#define mgmq_node_format(_node)    (_node), mgmq_group_format((struct mgmq_group*)((_node)?(_node)->in_group.owner:0)),\
                                  mgmq_watcher_format((struct mgmq_watcher*)((_node)?(_node)->in_watcher.owner:0)), \
                                  (_node)?(_node)->vid:0, (_node)?(_node)->role:0, (_node)?(_node)->ctx.len:0


/*! \brief gmq module */
#define mgmq_srv_mqid_max    3
typedef struct mgmq_mod
{
    unsigned long           is_srv;             /*!< is srv work mode */
    struct mmq_list         *mqlst;             /*!< message queue list */
    long                    mqid;               /*!< self mq id */

    unsigned long           srv_mqid_counts;    /*!< srv mqids counts */
    long                    srv_mqid[mgmq_srv_mqid_max];/*!< current srv mqid */

    long                    mute_notify_until_sync;/*!< sync debug setting, if 0 auto send not notify, else only send out notify when sync */

    struct
    {
        struct len_str      host;               /*!< local host */
        unsigned long       port;               /*!< local port */
    }gw;

    struct
    {
        unsigned long       counts;             /*!< gmq counts */
        struct mgmq_group   *list;              /*!< gmq list */
        struct mhash_table  tbl;                /*!< gmq hash table */
    }groups;
    struct
    {
        unsigned long       counts;             /*!< gateway counts */
        struct mgmq_gw      *list;              /*!< gateway list */
        struct mhash_table  tbl;                /*!< gateway hash table */

        struct mgmq_gw      *self;              /*!< self */
    }gws;
    struct
    {
        unsigned long       counts;             /*!< watcher counts */

        struct mgmq_watcher *list;              /*!< watcher list */
        struct mhash_table  tbl;                /*!< watcher hash table */
        struct mhash_table  local_mqid_tbl;     /*!< hash table for mapped to local mqid */
 
        struct mgmq_watcher *self;              /*!< self watcher */
        struct mgmq_watcher *sync_pos;          /*!< fetch position for sync */
    }watchers;
    struct
    {
        unsigned long       counts;             /*!< nodes counts */
        struct mhash_table  tbl;                /*!< nodes hash table */
        struct mhash_table  vid_tbl;            /*!< nodes hash table */
    }nodes;
    struct
    {
        unsigned long       active:1;           /*!< active flag */
        unsigned long       sync:1;             /*!< sync flag */
        unsigned long       reserved:((sizeof(long)*8) - 12);
        unsigned long       ex0:1,ex1:1,ex2:1,ex3:1,ex4:1,ex5:1,ex6:1,ex7:1;    /*!< for user module, extention */
    }flag;
    unsigned long           last_watcher_vid;   /*!< last wather verify id */
    unsigned long           last_node_vid;      /*!< last node verify id */
    struct
    {
        unsigned long       sync_watcher_counts;          /*!< client sync watcher counts */
        unsigned long       reader_changed_watcher_counts;/*!< for client: reader_changed watcher counts, used to check local-mapped mqid */
        unsigned long       reader_changed_group_counts;/*!< for server: reader_changed group counts, used to clear reader_changed refer flag */
        unsigned long       need_notify_watcher_counts; /*!< for server: uneed send notify watcher counts, used to send out notify and used to clear need_notify_flag */
    }update;
    struct
    {
        unsigned long       sync_counts;                /*!< sync times */
        unsigned long       sync_failed_counts;         /*!< sync faild times */
        unsigned long       sync_succeess_counts;       /*!< sync succeed times */
    }statistic;
    uint32_t                checksums_sum;      /*!< checksum's sum, just for client */
    uint32_t                checksums_xor;      /*!< checksum's sum, just for client */
    union mgmq_ref          ref;                /*!< refer data */
}_mgmq_module;
#define mgmq_mod_format_s     "%p{is_srv[%ld], mqid[0x%lx], srv_mqid[%ld{0x%lx}] groups[%ld], gws[%ld], watchers[%ld], nodes[%ld]}"
#define mgmq_mod_format(_mod) (_mod), (_mod)?(_mod)->is_srv:0, (_mod)?(_mod)->mqid:0, \
                                (_mod)?(_mod)->srv_mqid_counts:0, (_mod)?(_mod)->srv_mqid[0]:0, \
                                (_mod)?(_mod)->groups.counts:0, \
                                (_mod)?(_mod)->gws.counts:0, (_mod)?(_mod)->watchers.counts:0, \
                                (_mod)?(_mod)->nodes.counts:0

#define mgmq_role_manger                 0x00000001      /* reserved manager */
#define mgmq_role_reader                 0x00000002
#define mgmq_role_writer                 0x00000004

#define mgmq_group_flag_whole_watcher    0x00000001

typedef struct mgmq_mod_desc
{
    struct mmq_list             *mqlst;             /*!< messge queue list */
    long                        is_srv;             /*!< is server */
    long                        mqid;               /*!< owner mqid */

    unsigned long               srv_mqid_counts;    /*!< for client is only one srv id */
    long                        srv_mqid[mgmq_srv_mqid_max];/*!< srv-mqid list */ 

    long                        mute_notify_until_sync;/*!< sync debug setting, if 0 auto send not notify, else only send out notify when sync */
    struct
    {
        struct len_str          host;
        unsigned long           port;
    }gw;                                            /*!< local gw information */
}_mgmq_mod_desc;

/*!
func    mgmq_mod_create
\brief  create gmq module
\param  desc[in]                the module desc
\return module
        #NULL                   failed
        #other                  the module
*/
struct mgmq_mod *mgmq_mod_create(struct mgmq_mod_desc *desc);

/*!
func    mgmq_mod_destroy
\brief  destroy gmq module
\param  mod[in]                 the gmq module 
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mgmq_mod_destroy(struct mgmq_mod *mod);

/*!
func    mgmq_group_get
\brief  get gmq group
\param  mod[in]                 the gmq module 
\param  group_id[in]            the group id
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & mgmq_flag_group_new) will create one when not exist
                                [out] (*flag & mgmq_flag_group_new) 0: is old, 1: new one
\return gmq group
        #NULL                   not exist
        #other                  matched gmq object
*/
struct mgmq_group *mgmq_group_get(struct mgmq_mod *mod, struct len_str *group_id, unsigned long *flag);

/*!
func    mgmq_group_destroy
\brief  destroy gmq group
\param  mod[in]                 the gmq module 
\param  group[in]               the gmq
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mgmq_group_destroy(struct mgmq_mod *mod, struct mgmq_group *group);

/*!
func    mgmq_gw_get
\brief  get gmq gateway
\param  mod[in]                 the gmq module 
\param  host[in]                the host
\param  port[in]                the port
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & mgmq_flag_gw_new) will create one when not exist
                                [out] (*flag & mgmq_flag_gw_new) 0: is old, 1: new one
\return get result
        #NULL                   not exist
        #other                  matched gmq gw object
*/
struct mgmq_gw       *mgmq_gw_get(struct mgmq_mod *mod, struct len_str *host, unsigned long port, unsigned long *flag);

/*!
func    mgmq_gw_destroy
\brief  destroy gmq gateway
\param  mod[in]                 the gmq module 
\param  gw[in]                  the gmq gw
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mgmq_gw_destroy(struct mgmq_mod *mod, struct mgmq_gw *gw);

/*!
func    mgmq_watcher_get
\brief  get gmq watcher
\param  mod[in]                 the gmq module 
\param  gw[in]                  the gmq gateway
\param  mqid[in]                the mqid
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & mgmq_flag_watcher_new) will create one when not exist
                                [out] (*flag & mgmq_flag_watcher_new) 0: is old, 1: new one
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct mgmq_watcher  *mgmq_watcher_get(struct mgmq_mod *mod, struct mgmq_gw *gw, long mqid, unsigned long *flag);

/*!
func    mgmq_watcher_get_ex
\brief  get gmq watcher
\param  mod[in]                 the gmq module 
\param  host[in]                the host
\param  port[in]                the port
\param  mqid[in]                the mqid
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & mgmq_flag_watcher_new) will create one when not exist
                                [out] (*flag & mgmq_flag_watcher_new) 0: is old, 1: new one
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct mgmq_watcher  *mgmq_watcher_get_ex(struct mgmq_mod *mod, struct len_str *host, unsigned long port, long mqid, unsigned long *flag);

/*!
func    mgmq_watcher_get_by_local_mqid
\brief  get gmq watcher by mqid mapped local
\param  mod[in]                 the gmq module 
\param  local_mqid[in]          the mqid mapped local
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct mgmq_watcher  *mgmq_watcher_get_by_local_mqid(struct mgmq_mod *mod, long local_mqid);

/*!
func    mgmq_watcher_set_local_mqid
\brief  set gmq watcher mqid mapped local
\param  mod[in]                 the gmq module 
\param  watcher[in]             the watcher
\param  local_mqid[in]          the mqid mapped local
\return set result
        #0                      succeed
        #other                  error code
*/
long mgmq_watcher_set_local_mqid(struct mgmq_mod *mod, struct mgmq_watcher *watcher, long local_mqid);

/*!
func    mgmq_watcher_destroy
\brief  destroy watcher
\param  mod[in]                 the gmq module 
\param  watcher[in]             the watcher
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mgmq_watcher_destroy(struct mgmq_mod *mod, struct mgmq_watcher *watcher);

/*!
func    mgmq_node_get
\brief  get gmq node
\param  mod[in]                 the gmq module 
\param  group[in]               the gmq group
\param  watcher[in]             the gmq watcher
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & mgmq_flag_node_new) will create one when not exist
                                [out] (*flag & mgmq_flag_node_new) 0: is old, 1: new one
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct mgmq_node *mgmq_node_get(struct mgmq_mod *mod, struct mgmq_group *group, struct mgmq_watcher *watcher, unsigned long *flag);

/*!
func    mgmq_node_get_ex
\brief  get gmq watcher extention
\param  mod[in]                 the gmq module 
\param  group_id[in]            the gmq group id
\param  host[in]                the gw host
\param  port[in]                the gw port
\param  mqid[in]                the mqid
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & mgmq_flag_node_new) will create one when not exist
                                [out] (*flag & mgmq_flag_node_new) 0: is old, 1: new one
\param  group_cached[in/out]    can be NULL, if NULL ignore, if (group_cached && *group_cached) 
                                use it then ignore group_id
\param  gw_cached[in/out]       can be NULL, if NULL ignore, if (gw_cached && *gw_cached) 
                                use it then ignore host and port
\param  watcher_cached[in/out]  can be NULL, if NULL ignore, if (watcher_cached && *watcher_cached) 
                                use it then ignore host and port and mqid
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct mgmq_node *mgmq_node_get_ex(struct mgmq_mod  *mod,     struct len_str *group_id,
                                 struct len_str     *host,    unsigned long  port,  long mqid,
                                 unsigned long      *flag,
                                 struct mgmq_group   **group_cached,
                                 struct mgmq_gw      **gw_cached,
                                 struct mgmq_watcher **watcher_cached);

/*!
func    mgmq_node_get_ex2
\brief  get gmq node
\param  mod[in]                 the gmq module 
\param  group_id[in]            the gmq group id
\param  watcher[in]             the gmq watcher
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & mgmq_flag_node_new) will create one when not exist
                                [out] (*flag & mgmq_flag_node_new) 0: is old, 1: new one
\param  group_cached[in/out]    can be NULL, if NULL ignore, if (group_cached && *group_cached) 
                                use it then ignore group_id
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct mgmq_node *mgmq_node_get_ex2(struct mgmq_mod *mod, struct len_str *group_id, struct mgmq_watcher *watcher, unsigned long *flag, struct mgmq_group **group_cached);

/*!
func    mgmq_node_get_by_vid
\brief  get node by verify id
\param  mod[in]                 the gmq module 
\param  watcher[in]             the watcher
\param  vid[in]                 the verify id
\return get result
        #NULL                   not found
        #other                  the matched node
*/
struct mgmq_node *mgmq_node_get_by_vid(struct mgmq_mod *mod, struct mgmq_watcher *watcher, unsigned long vid);

/*!
func    mgmq_node_vid_set
\brief  set gmq node's vid
\param  mod[in]                 the gmq module 
\param  node[in]                the node
\param  vid[in]                 the verify id, if 0 means delete
\return set result
        #0                      succeed
        #other                  error code
*/
long mgmq_node_vid_set(struct mgmq_mod *mod, struct mgmq_node *node, unsigned long vid);

/*!
func    mgmq_node_destroy
\brief  destroy gmq node
\param  mod[in]                 the gmq module 
\param  node[in]                the node
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mgmq_node_destroy(struct mgmq_mod *mod, struct mgmq_node *node);

/*!
func    mgmq_node_role_set
\brief  set node's role
\param  mod[in]                 the gmq module 
\param  node[in]                the node
\param  role[in]                the role
\return set result
        #0                      succeed
        #other                  error code
*/
long mgmq_node_role_set(struct mgmq_mod *mod, struct mgmq_node *node, unsigned long role);

/*!
func    mgmq_node_ctx_set
\brief  set node's ctx
\param  mod[in]                 the gmq module 
\param  node[in]                the node
\param  ctx[in]                 the ctx
\return set result
        #0                      succeed
        #other                  error code
*/
long mgmq_node_ctx_set(struct mgmq_mod *mod, struct mgmq_node *node, struct len_str *ctx);

/*!
func    mgmq_node_checksum_update
\brief  update node's checksum
\param  mod[in]                 the gmq module 
\param  node[in]                the node
\return update result
        #0                      succeed
        #other                  error code
*/
long mgmq_node_checksum_update(struct mgmq_mod *mod, struct mgmq_node *node);

/*!
func    mgmq_dump
\brief  get gmq object refer snapshot info, include groups, watvhers
\param  mod[in]                 the module
\param  argc[in]                the arg counts
\param  argv[in]                the arg list, if(argc == 0) can be NULL if NULL default
                                --help      : get help
                                --filter    : filter string, if empty all items will be matched.
                                --type      : type list split by ","
                                    module  : output module
                                    group   : output group
                                    gnode   : output group-node
                                    gw      : output gw
                                    watcher : output watcher
                                    wnode   : output watcher-node
                                    all     : output all type
                                    default : same as group
\param  buf[in]                 the output buffer, can be NULL, if NULL output into file 
\param  start[in]               the start record no
\param  counts[in]              max output records counts
\param  size[in]                the buf size or max content size output to file
\return content length
        #<0                     error code
        #other                  content length
*/
long mgmq_dump(struct mgmq_mod *mod,
               unsigned long     argc,
               char              *argv[],
               char              *buf,
               char              *file,
               unsigned long     start,
               unsigned long     counts,
               unsigned long     size);

#if defined(__cplusplus)
}
#endif

