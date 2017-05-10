/*!
\file       dmq.c
\brief      dynamic message queue unit

 ----history----
\author     chengzhiyong 
\date       2012-11-05
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: lock.c,v 1.25 2008-08-20 09:07:42 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif

#include "mcore/mcore.h"

struct dmq_group;
struct dmq_gw;
struct dmq_watcher;
struct dmq_node;
struct dmq_module;
struct dmq_module_desc;

/* dmq:dynamic message queue */

#define dmq_flag_group_new      0x01
#define dmq_flag_gw_new         0x02
#define dmq_flag_watcher_new    0x04
#define dmq_flag_node_new       0x08


typedef union dmq_ref
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
}_dmq_ref;

/*! \brief dynamic message queue */
typedef struct dmq_group
{
    struct
    {
        struct dmq_group    *prev;              /*!< prev item in module's dmqs list */
        struct dmq_group    *next;              /*!< next item in module's dmqs list */
        struct dmq_group    *hash_next;         /*!< next item in module's dmqs hash-table */
    }in_mod;
    struct len_str          group_id;           /*!< dmq group string */
    struct
    {
        struct len_str      manage;             /*!< key for manager */
        struct len_str      read;               /*!< key for reader */
        struct len_str      write;              /*!< key for writer */
    }key;                                       /*!< key */
    struct
    {
        unsigned long       reader_counts;      /*!< reader counts */
        unsigned long       writer_counts;      /*!< writer counts */
        unsigned long       counts;             /*!< counts */
        struct dmq_node     *list;              /*!< watcher list */
    }nodes;                                     /*!< readers and writer's watcher list */
    struct
    {
        unsigned long       active:1;           /*!< active flag */
        unsigned long       ex0:1,ex1:1,ex2:1,ex3:1,ex4:1,ex5:1,ex6:1,ex7:1;    /*!< for user module, extention */
        unsigned long       reserved:((sizeof(long)*4) - 1 - 8);
    }flag;
    struct
    {
        unsigned long       full_msg_size;      /*!< full update whole group watcher's message size */
        unsigned long       counts;             /*!< update counts, with same update_req */
        unsigned long       seq;                /*!< update seq */
    }update;
    union dmq_ref           ref;                /*!< ref data */
}_dmq_group;
#define dmq_group_format_s          "%p{group_id[%s], nodes[%ld]}"
#define dmq_group_format(_group)    (_group), (_group)?(_group)->group_id.data:0, (_group)?(_group)->nodes.counts:0

/*!\brief dmq gateway */
typedef struct dmq_gw                  
{
    struct
    {
        struct dmq_gw       *prev;              /*!< prev dmq gateway in module's gws list */
        struct dmq_gw       *next;              /*!< next dmq gateway in module's gws list */
        struct dmq_gw       *hash_next;         /*!< next dmq gateway in module's gws hash-table */
    }in_mod;
    struct len_str          protocol;           /*!< protocol, default is mrmt */
    struct len_str          host;               /*!< the host */
    unsigned long           port;               /*!< comunication port */
    struct
    {
        unsigned long       counts;             /*!< watcher counts from this gateway */
        struct dmq_watcher  *list;              /*!< watcher list */
    }watchers;
    struct
    {
        unsigned long       active:1;           /*!< active flag */
        unsigned long       is_local:1;         /*!< is local, by check host and port */
        unsigned long       ex0:1,ex1:1,ex2:1,ex3:1,ex4:1,ex5:1,ex6:1,ex7:1;    /*!< for user module, extention */
        unsigned long       reserved:((sizeof(long)*4) - 2 - 8);
    }flag;
    union dmq_ref           ref;                /*!< ref data */
}_dmq_gw;
#define dmq_gw_format_s     "%p{host[%s], port[%ld], watchers[%ld]}"
#define dmq_gw_format(_gw)  (_gw), (_gw)?(_gw)->host.data:0, (_gw)?(_gw)->port:0, (_gw)?(_gw)->watchers.counts:0

/*! \brief dmq watcher */
typedef struct dmq_watcher
{
    struct
    {
        struct dmq_watcher  *hash_next;         /*!< hash next in module's watcher hash table */
        struct dmq_watcher  *local_cid_hash_next;   /*!< hash next in module's watcher local-cid hash table */
        struct dmq_watcher  *prev;              /*!< prev item in gw's watcher list */
        struct dmq_watcher  *next;              /*!< next item in gw's watcher list */
    }in_mod;
    struct
    {
        struct dmq_watcher  *prev;              /*!< prev item in gw's watcher list */
        struct dmq_watcher  *next;              /*!< next item in gw's watcher list */
        struct dmq_gw       *owner;             /*!< dmq gateway */
    }in_gw;                                     /*!< in gw's watcher list */
    struct
    {
        unsigned long       reader_counts;      /*!< reader counts */
        unsigned long       writer_counts;      /*!< wirter counts */
        unsigned long       counts;             /*!< dmq node counts */
        struct dmq_node     *list;              /*!< dmq node list */
    }nodes;
    struct
    {
        unsigned long       active:1;           /*!< active flag */
        unsigned long       ex0:1,ex1:1,ex2:1,ex3:1,ex4:1,ex5:1,ex6:1,ex7:1;    /*!< for user module, extention */
        unsigned long       reserved:((sizeof(long)*4) - 1 - 8);
    }flag;
    long                    mq_id;              /*!< remote mq id, in remote container */
    long                    mq_id_mapped_local; /*!< mapped local mq id, in local container, for component send-msg */
    struct
    {
        unsigned long       msg_size;           /*!< update message size, with same update_req */
        unsigned long       counts;             /*!< update counts, with same update_req */
        unsigned long       seq;                /*!< update seq no, for high performan whole watcher list update */
    }update;
    union dmq_ref           ref;                /*!< refer data */
}dmq_watcher;
#define dmq_watcher_format_s            "%p{gw["dmq_gw_format_s"], mq_id[0x%lx], mq_id_mapped_local[0x%lx], nodes[%ld]}"
#define dmq_watcher_format(_watcher)    (_watcher), dmq_gw_format((struct dmq_gw*)((_watcher)?(_watcher)->in_gw.owner:0)), \
                                        (_watcher)?(_watcher)->mq_id:0, (_watcher)?(_watcher)->mq_id_mapped_local:0, \
                                        (_watcher)?(_watcher)->nodes.counts:0

/*! \brief dmq watcher */
typedef struct dmq_node
{
    struct
    {
        struct dmq_node     *hash_next;         /*!< hash next in module's watcher hash table */
    }in_mod;
    struct
    {
        struct dmq_node     *prev;              /*!< prev item in dmq's watcher list */
        struct dmq_node     *next;              /*!< next item in dmq's watcher list */
        struct dmq_group    *owner;             /*!< dmq group */
    }in_group;
    struct
    {
        struct dmq_node     *prev;              /*!< prev item in gw's watcher list */
        struct dmq_node     *next;              /*!< next item in gw's watcher list */
        struct dmq_watcher  *owner;             /*!< dmq watcher */
    }in_watcher;                                /*!< in gw's watcher list */
    unsigned long           role;               /*!< watcher role */
    unsigned long           prev_role;          /*!< temp field, prev role, just for on dmq-watch role reader changed node, need tell writer */
    struct len_str          ctx;                /*!< ctx */
    struct
    {
        unsigned long       active:1;           /*!< active flag */
        unsigned long       ex0:1,ex1:1,ex2:1,ex3:1,ex4:1,ex5:1,ex6:1,ex7:1;    /*!< for user module, extention */
        unsigned long       reserved:((sizeof(long)*4) - 1 - 8);
    }flag;
    struct
    {
        unsigned long       seq;                /*!< update seq no, for high performan whole watcher list update */
    }update;
    union dmq_ref           ref;                /*!< refer data */
}_dmq_node;
#define dmq_node_format_s          "%p{group["dmq_group_format_s"], watcher["dmq_watcher_format_s"], role[0x%lx], ctx[%ld]}"
#define dmq_node_format(_node)    (_node), dmq_group_format((struct dmq_group*)((_node)?(_node)->in_group.owner:0)),\
                                  dmq_watcher_format((struct dmq_watcher*)((_node)?(_node)->in_watcher.owner:0)), \
                                  (_node)?(_node)->role:0, (_node)?(_node)->ctx.len:0


/*! \brief dmq module */
typedef struct dmq_module
{
    unsigned long           is_srv;             /*!< is srv work mode */
    struct mmq_list         *mqlst;             /*!< message queue list */
    long                    mq_id;              /*!< self mq id */
    struct
    {
        struct len_str      host;               /*!< local host */
        unsigned long       port;               /*!< local port */
    }gw;
    struct
    {
        unsigned long       counts;             /*!< dmq counts */
        struct dmq_group    *list;              /*!< dmq list */
        struct hash_table   tbl;                /*!< dmq hash table */
        struct dmq_group    **tbl_buckets;      /*!< gateway hash table bucket's */
    }groups;
    struct
    {
        unsigned long       counts;             /*!< gateway counts */
        struct dmq_gw       *list;              /*!< gateway list */
        struct hash_table   tbl;                /*!< gateway hash table */
        struct dmq_gw       **tbl_buckets;      /*!< gateway hash table bucket's */

        struct dmq_gw       *self;              /*!< self */
    }gws;
    struct
    {
        unsigned long       counts;             /*!< watcher counts */
        struct dmq_watcher  *list;              /*!< watcher list */
        struct hash_table   tbl;                /*!< watcher hash table */
        struct dmq_watcher  **tbl_buckets;      /*!< watcher hash table bucket's */

        struct hash_table   local_cid_tbl;      /*!< hash table for mapped to local cid */
        struct dmq_watcher  **local_cid_tbl_buckets;      /*!< hash buckets for mapped to local cid */

        struct dmq_watcher  *self;              /*!< self watcher */
    }watchers;
    struct
    {
        unsigned long       counts;             /*!< nodes counts */
        struct hash_table   tbl;                /*!< nodes hash table */
        struct dmq_node     **tbl_buckets;      /*!< node hash table bucket's */
    }nodes;
    struct
    {
        unsigned long       active:1;           /*!< active flag */
        unsigned long       ex0:1,ex1:1,ex2:1,ex3:1,ex4:1,ex5:1,ex6:1,ex7:1;    /*!< for user module, extention */
        unsigned long       reserved:((sizeof(long)*4) - 1 - 8);
    }flag;
    struct
    {
        unsigned long       seq;                /*!< update seq no, for high performan whole watcher list update */
    }update;
    union dmq_ref           ref;                /*!< refer data */
}_dmq_module;
#define dmq_module_format_s     "%p{is_srv[%ld], groups[%ld], gws[%ld], watchers[%ld], nodes[%ld]}"
#define dmq_module_format(_mod) (_mod), (_mod)?(_mod)->is_srv:0, (_mod)?(_mod)->groups.counts:0, \
                                (_mod)?(_mod)->gws.counts:0, (_mod)?(_mod)->watchers.counts:0, \
                                (_mod)?(_mod)->nodes.counts:0

#define dmq_role_manger                 0x00000001      /* reserved manager */
#define dmq_role_reader                 0x00000002
#define dmq_role_writer                 0x00000004

#define dmq_group_flag_whole_watcher    0x00000001

typedef struct dmq_module_desc
{
    struct mmq_list             *mqlst;
    long                        is_srv;
    struct
    {
        struct len_str          host;
        unsigned long           port;
    }gw;
    long                        mq_id;
}_dmq_module_desc;

/*!
func    dmq_module_create
\brief  create dmq module
\param  desc[in]                the module desc
\return module
        #NULL                   failed
        #other                  the module
*/
struct dmq_module *dmq_module_create(struct dmq_module_desc *desc);

/*!
func    dmq_module_destroy
\brief  destroy dmq module
\param  mod[in]                 the dmq module 
\return destroy result
        #0                      succeed
        #other                  error code
*/
long dmq_module_destroy(struct dmq_module *mod);

/*!
func    dmq_group_get
\brief  get dmq group
\param  mod[in]                 the dmq module 
\param  group_id[in]            the group id
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & dmq_flag_group_new) will create one when not exist
                                [out] (*flag & dmq_flag_group_new) 0: is old, 1: new one
\return dmq group
        #NULL                   not exist
        #other                  matched dmq object
*/
struct dmq_group *dmq_group_get(struct dmq_module *mod, struct len_str *group_id, unsigned long *flag);

/*!
func    dmq_group_destroy
\brief  destroy dmq group
\param  mod[in]                 the dmq module 
\param  group[in]               the dmq
\return destroy result
        #0                      succeed
        #other                  error code
*/
long dmq_group_destroy(struct dmq_module *mod, struct dmq_group *group);

/*!
func    dmq_gw_get
\brief  get dmq gateway
\param  mod[in]                 the dmq module 
\param  host[in]                the host
\param  port[in]                the port
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & dmq_flag_gw_new) will create one when not exist
                                [out] (*flag & dmq_flag_gw_new) 0: is old, 1: new one
\return get result
        #NULL                   not exist
        #other                  matched dmq gw object
*/
struct dmq_gw       *dmq_gw_get(struct dmq_module *mod, struct len_str *host, unsigned long port, unsigned long *flag);

/*!
func    dmq_gw_destroy
\brief  destroy dmq gateway
\param  mod[in]                 the dmq module 
\param  gw[in]                  the dmq gw
\return destroy result
        #0                      succeed
        #other                  error code
*/
long dmq_gw_destroy(struct dmq_module *mod, struct dmq_gw *gw);

/*!
func    dmq_watcher_get
\brief  get dmq watcher
\param  mod[in]                 the dmq module 
\param  gw[in]                  the dmq gateway
\param  mq_id[in]               the mq id
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & dmq_flag_watcher_new) will create one when not exist
                                [out] (*flag & dmq_flag_watcher_new) 0: is old, 1: new one
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct dmq_watcher  *dmq_watcher_get(struct dmq_module *mod, struct dmq_gw *gw, long mq_id, unsigned long *flag);

/*!
func    dmq_watcher_get_by_mq_id
\brief  get dmq watcher by mq-id mapped local
\param  mod[in]                 the dmq module 
\param  mq_id_mapped_local[in]  the mq id
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct dmq_watcher  *dmq_watcher_get_by_mq_id(struct dmq_module *mod, long mq_id_mapped_local);

/*!
func    dmq_watcher_get_by_mq_id
\brief  get dmq watcher by mq-id mapped local
\param  mod[in]                 the dmq module 
\param  watcher[in]             the watcher
\param  mq_id_mapped_local[in]  the mq id
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
long dmq_watcher_set_mq_id(struct dmq_module *mod, struct dmq_watcher *watcher, long mq_id_mapped_local);

/*!
func    dmq_watcher_destroy
\brief  destroy watcher
\param  mod[in]                 the dmq module 
\param  watcher[in]             the watcher
\return destroy result
        #0                      succeed
        #other                  error code
*/
long dmq_watcher_destroy(struct dmq_module *mod, struct dmq_watcher *watcher);

/*!
func    dmq_node_get
\brief  get dmq node
\param  mod[in]                 the dmq module 
\param  group[in]               the dmq group
\param  watcher[in]             the dmq watcher
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & dmq_flag_node_new) will create one when not exist
                                [out] (*flag & dmq_flag_node_new) 0: is old, 1: new one
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct dmq_node *dmq_node_get(struct dmq_module *mod, struct dmq_group *group, struct dmq_watcher *watcher, unsigned long *flag);

/*!
func    dmq_node_get_ex
\brief  get dmq watcher extention
\param  mod[in]                 the dmq module 
\param  group_id[in]            the dmq group id
\param  host[in]                the gw host
\param  port[in]                the gw port
\param  mq_id[in]               the mq id
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & dmq_flag_node_new) will create one when not exist
                                [out] (*flag & dmq_flag_node_new) 0: is old, 1: new one
\param  group_cached[in/out]    can be NULL, if NULL ignore, if (group_cached && *group_cached) 
                                use it then ignore group_id
\param  gw_cached[in/out]       can be NULL, if NULL ignore, if (gw_cached && *gw_cached) 
                                use it then ignore host and port
\param  watcher_cached[in/out]  can be NULL, if NULL ignore, if (watcher_cached && *watcher_cached) 
                                use it then ignore host and port and mq_id
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct dmq_node *dmq_node_get_ex(struct dmq_module  *mod,     struct len_str *group_id,
                                 struct len_str     *host,    unsigned long  port,  long mq_id,
                                 unsigned long      *flag,
                                 struct dmq_group   **group_cached,
                                 struct dmq_gw      **gw_cached,
                                 struct dmq_watcher **watcher_cached);

/*!
func    dmq_node_get_ex2
\brief  get dmq node
\param  mod[in]                 the dmq module 
\param  group_id[in]            the dmq group id
\param  watcher[in]             the dmq watcher
\param  flag[in/out]            can be NULL, if NULL ignore, just return exist one,
                                [in] if(*flag & dmq_flag_node_new) will create one when not exist
                                [out] (*flag & dmq_flag_node_new) 0: is old, 1: new one
\param  group_cached[in/out]    can be NULL, if NULL ignore, if (group_cached && *group_cached) 
                                use it then ignore group_id
\return get result
        #NULL                   not exist
        #other                  the matched watcher
*/
struct dmq_node *dmq_node_get_ex2(struct dmq_module *mod, struct len_str *group_id, struct dmq_watcher *watcher, unsigned long *flag, struct dmq_group **group_cached);

/*!
func    dmq_node_destroy
\brief  destroy dmq node
\param  mod[in]                 the dmq module 
\param  node[in]                the node
\return destroy result
        #0                      succeed
        #other                  error code
*/
long dmq_node_destroy(struct dmq_module *mod, struct dmq_node *node);

/*!
func    dmq_node_role_set
\brief  set node's role
\param  mod[in]                 the dmq module 
\param  node[in]                the node
\param  role[in]                the role
\return destroy result
        #0                      succeed
        #other                  error code
*/
long dmq_node_role_set(struct dmq_module *mod, struct dmq_node *node, unsigned long role);

/*!
func    dmq_dump
\brief  get dmq object refer snapshot info, include groups, watvhers
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
long dmq_dump(struct dmq_module *mod,
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

