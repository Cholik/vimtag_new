/*!
\file       msg_vhost.h
\brief      virtual host unit

 ----history----
\author     chengzhiyong
\date       2007-04-03
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: msg_vhost.h,v 1.2 2008-09-01 11:45:04 chengzhiyong Exp $
*/
#if !defined(__msg_vhost_h__)
#define __msg_vhost_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct len_str;
struct pack_def;
struct hash_map;
struct vhost_table;
struct vpath_entity;

#define vhost_table_magic *(long*)"vtbl   "
typedef struct vhost_table
{
    char                    magic[sizeof(long)];    /* vhost table magic, "vtbl" */
    struct hash_map         *vpe_map;               /* vpath entity map */
    struct hash_map         *dvpp_wildcard_map;     /* Wildcard dynamic vpath pattern map. */
    struct hash_map         *dvpp_comp_map;         /* Component dynamic vpath pattern map. */
    struct hash_map         *dvpp_msg_map;          /* Message dynamic vpath pattern pamap. */
    struct hash_map         *dvpp_compmsg_map;      /* Component message dynamic vpath pattern map. */
}_vhost_table;

typedef struct vpath_entity
{
    struct len_str          vpath;          /* virtual path */
    struct len_str          local_path;     /* Local path, null indicate dynamic vpath, if start with ["http:/","https:/","ftp:/"] will be a redirect action */

    long                    cid;            /* component id */
    struct len_str          msg_type;       /* message type */
    struct pack_def         *def;           /* def */
    struct  
    {
        unsigned long       msysenv_enabled:1,          /*!< is enable mining system environment */
                            msysenv_rawname:1,          /*!< raw name flag, not start with 'd'|'h' flag, for 3rd system link */
                            msysenv_file_exchange:1,    /*!< content exchange by file */
                            msysenv_req_protocol,

                            msysenv_remote_ip:1,
                            msysenv_remote_port:1,
                            msysenv_local_ip:1,
                            msysenv_local_port:1,

                            msysenv_referer:1,
                            msysenv_host:1,
                            msysenv_url:1,
                            msysenv_user_agent:1,

                            msysenv_qid:1,
                            msysenv_content:1,
                            redirect_url:1,             /*!< local path is redirect url */
                            trace_flag:1,
                            reserved:((sizeof(long)*8) - 14);
    }flag;
}_vpath_entity;

typedef struct dvpp_comp
{
    long                    cid;            /* component id */
    struct hash_map         *vpath_map;     /* vpath that refer this component */
}_dvpp_comp;

typedef struct dvpp_msg
{
    struct len_str          msg_type;       /* message type */
    struct hash_map         *vpath_map;     /* vpath that refer this message */
}_dvpp_msg;

typedef struct dvpp_compmsg
{
    long                    cid;            /* component id */
    struct len_str          msg_type;       /* message type */
    struct hash_map         *vpath_map;     /* vpath refer to msg_type on this component  */
}_dvpp_compmsg;

extern long vhost_add_def(struct vhost_table *table, long cid, struct pack_def *def );
extern long vhost_add_dvpe_comp( struct vhost_table *table, struct len_str *vpath, long cid, struct len_str *msg_type, struct pack_def *def );
extern long vhost_add_dvpe_compmsg( struct vhost_table *table, struct len_str *vpath, long cid, struct len_str *msg_type, struct pack_def *def );
extern long vhost_add_dvpe_msg( struct vhost_table *table, struct len_str *vpath, long cid, struct len_str *msg_type, struct pack_def *def );
extern long vhost_add_dvpe_wildcard( struct vhost_table *table, struct len_str *vpath, long cid, struct len_str *msg_type, struct pack_def *def );
extern long vhost_add_dvpp_comp(struct vhost_table *table, struct len_str *host_name, struct len_str *vpath, long cid );
extern long vhost_add_dvpp_compmsg(struct vhost_table *table, struct len_str *host_name, struct len_str *vpath, long cid, struct len_str *msg_type );
extern long vhost_add_dvpp_msg(struct vhost_table *table, struct len_str *host_name, struct len_str *vpath, struct len_str *msg_type );
extern long vhost_add_dvpp_wildcard(struct vhost_table *table, struct len_str *host_name, struct len_str *vpath );
extern long vhost_add_mapping(struct vhost_table *table, struct len_str *host_name, struct len_str *vpath, struct len_str *local_path, long cid, struct len_str *msg_type );
extern long vhost_add_vpe(struct vhost_table *table, struct len_str *vpath, struct len_str *local_path, long cid, struct len_str *msg_type, struct pack_def *def );
extern long vhost_add_vpe_static( struct vhost_table *table, struct len_str *host_name, struct len_str *vpath, struct len_str *local_path );
extern struct vhost_table *vhost_create();
extern long vhost_del_def_xml( struct vhost_table *table, long cid );
extern long vhost_del_dvpe_comp( struct vhost_table *table, struct len_str *vpath, struct len_str *msg_type );
extern long vhost_del_dvpe_compmsg( struct vhost_table *table, struct len_str *vpath );
extern long vhost_del_dvpe_msg( struct vhost_table *table, struct len_str *vpath, long cid );
extern long vhost_del_dvpe_wildcard( struct vhost_table *table, struct len_str *vpath, long cid, struct len_str *msg_type );
extern long vhost_del_vpe(struct vhost_table *table, struct len_str *vpath );
extern long vhost_destroy(struct vhost_table *tbl);
extern struct vpath_entity *vhost_get_uri(struct vhost_table *tbl, struct len_str *host, struct len_str *uri,
                                          unsigned long *path_size/* if 0 ignore [in/out] */,
                                          char          *path/* [out], can be NULL, if NULL ignore */);
extern struct pack_def* vhost_get_def( struct vhost_table *tbl, long cid, char *type );
extern long vhost_del_def( struct vhost_table *table, long cid, struct pack_def *def );


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
#endif /* !defined(__msg_vhost_h__) */
