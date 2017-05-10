#if !defined(__mlocation_api_h__)
#define __mlocation_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#define mlocation_magic_cb_active                    (*(long*)"accb    ")
#define mlocation_magic_cb_inactive                  (*(long*)"iacb    ")
#define mlocation_magic_cb_free                      (*(long*)"frcb    ")
#define mlocation_magic_cb_is_active( cb )           (( (cb) != NULL ) && ( *(long *)&(cb)->magic == mlocation_magic_cb_active ))
#define mlocation_magic_cb_set( cb, status )         *(long*)&(cb)->magic = mlocation_magic_cb_##status
#define mlocation_magic_cb_check( cb, status )       (( (cb) != NULL ) && ( *(long *)&(cb)->magic == mlocation_magic_cb_##status ))
#define mlocation_magic_cb_is_valid( cb )           (( (cb) != NULL ) && ((( *(long *)&(cb)->magic == mlocation_magic_cb_active ))||( *(long *)&(cb)->magic == mlocation_magic_cb_inactive)))

#define mlocation_res_format_s    "%p{[%4.4s] res:0x%lx, priority:%ld}"
#define mlocation_res_format( cb ) (cb), mlocation_magic_cb_is_valid(cb)?(char*)&(cb)->magic:0, \
                                (long)(mlocation_magic_cb_is_valid(cb)?(cb)->res:0), \
                                (long)(mlocation_magic_cb_is_valid(cb)?(cb)->priority:0)

#define mlocation_loc_format_s    "%p{[%4.4s] loc:%s, desc:%s, parent:%s, autonomy:%ld, res:"mlocation_res_format_s"}"
#define mlocation_loc_format( cb ) (cb), mlocation_magic_cb_is_valid(cb)?(char*)&(cb)->magic:0, \
                                mlocation_magic_cb_is_valid(cb)?(cb)->loc.data:"null", \
                                mlocation_magic_cb_is_valid(cb)?(cb)->desc.data:"null", \
                                (mlocation_magic_cb_is_valid(cb)&&mlocation_magic_cb_is_valid(cb->parent))?(cb)->parent->loc.data:"null", \
                                (long)(mlocation_magic_cb_is_valid(cb)?(cb)->autonomy:0), \
                                mlocation_res_format( mlocation_magic_cb_is_valid(cb)?(cb)->res_default:NULL )

#define mlocation_loc_simple_format_s    "%p{[%4.4s] loc:%s, desc:%s}"
#define mlocation_loc_simple_format( cb ) (cb), mlocation_magic_cb_is_valid(cb)?(char*)&(cb)->magic:0, \
                                mlocation_magic_cb_is_valid(cb)?(cb)->loc.data:"null", \
                                mlocation_magic_cb_is_valid(cb)?(cb)->desc.data:"null"

#define mlocation_count_size   64
#define mlocation_mod_count_get( mod, pos ) ( mlocation_magic_cb_is_valid(mod) && pos < mlocation_count_size)?(mod)->count[pos]:0
#define mlocation_loc_count_get( cb, pos ) ( mlocation_magic_cb_is_valid(cb) && pos < mlocation_count_size)?(cb)->count[pos]:0
#define mlocation_loc_count_inc( cb, pos ) if( mlocation_magic_cb_is_valid(cb) && pos < mlocation_count_size){(cb)->count[pos]++; (cb)->mod->count[pos]++;}
#define mlocation_loc_count_dec( cb, pos ) if( mlocation_magic_cb_is_valid(cb) && pos < mlocation_count_size && (cb)->count[pos] > 0 ){(cb)->count[pos]--; (cb)->mod->count[pos]--;}

struct mlocation_loc_cb;
struct mlocation_mod;
typedef long (*mlocation_res_ref_format)( long ref, char *buf, int buf_len );
typedef long (*mlocation_loc_count_format)( struct mlocation_loc_cb *loc_cb, char *buf, int buf_len );
typedef long (*mlocation_mod_count_format)( struct mlocation_mod *mod, char *buf, int buf_len );
typedef struct mlocation_create_param
{
    mlocation_mod_count_format      mod_count_format;
    mlocation_loc_count_format      loc_count_format;
    mlocation_res_ref_format        res_ref_format;
}_mlocation_create_param;


typedef struct mlocation_res_cb
{
    char                    magic[sizeof(long)];    /*!< magic */

    long                    res;

    struct mlocation_loc_cb *loc;
    struct
    {
        struct mlocation_res_cb   *prev;
        struct mlocation_res_cb   *next;
    }in_loc;

    long                    priority;
}_mlocation_res_cb;

typedef struct mlocation_loc_cb
{
    char                    magic[sizeof(long)];    /*!< magic */

    struct len_str          loc;                /* location */
    struct len_str          desc;               /* location description */

    struct mlocation_loc_cb   *parent;
    long                    autonomy;
    long                    flag;
    struct
    {
        struct mlocation_loc_cb   *prev;
        struct mlocation_loc_cb   *next;
    }in_parent;

    struct
    {
        unsigned long       counts;
        struct mlocation_loc_cb   *list;
    }sub_locs;

    struct
    {
        unsigned long       counts;
        struct mlocation_res_cb   *list;
    }reses;

    long                    count[mlocation_count_size];
    struct mlocation_res_cb   *res_default;
    long                    res_default_local;
    struct mlocation_mod        *mod;
}_mlocation_loc_cb;

typedef struct mlocation_mod
{
    char                    magic[sizeof(long)];    /*!< magic */
    struct hash_map         *map_loc;
    struct hash_map         *map_res;

    long                    count[mlocation_count_size];
    struct mlocation_loc_cb *loc_tree;
    mlocation_res_ref_format    res_ref_format;
    mlocation_loc_count_format  loc_count_format;
    mlocation_mod_count_format  mod_count_format;
}_mlocation_mod;

extern struct mlocation_mod *mlocation_create( struct mlocation_create_param *param );
extern long mlocation_destroy( struct mlocation_mod *mod );
extern long mlocation_loc_cb_create( struct mlocation_mod *mod, struct len_str *loc, struct len_str* desc, long autonomy, long flag );
extern long mlocation_loc_cb_add( struct mlocation_mod *mod, struct len_str *parent, struct len_str *loc );
extern struct mlocation_loc_cb * mlocation_loc_cb_get( struct mlocation_mod *mod, struct len_str *loc );
extern long mlocation_res_cb_create( struct mlocation_mod *mod, struct len_str *loc, long res, long priority );
extern struct mlocation_res_cb * mlocation_res_cb_get( struct mlocation_mod *mod, long res );
extern long mlocation_res_select( struct mlocation_mod *mod );
extern long mlocation_res_cb_destroy( struct mlocation_mod *mod, long res );


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif
