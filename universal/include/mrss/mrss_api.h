#if !defined(__mrss_api_h__)
#define __mrss_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

typedef struct mrss_creat_param{
    struct len_str          path_dbip;          /* path of dbip */
    struct len_str          path_loc;           /* path of loc */
    struct len_str          path_mrss;          /* path of mrss */
    long                    delay_active;       /* tick delay from inactive to active */
    long                    delay_inactive;     /* tick delay from active to inactive */
}_mrss_creat_param;

typedef struct mrss_user_param{
    struct len_str          name;               /* param name */
    struct len_str          value;              /* param value */
    long                    hash_key;           /* use as key for select resource in resource_group */
}_mrss_user_param;

#define mrss_status_init            0
#define mrss_status_inactive        1
#define mrss_status_active          2

struct mrss_cb;
struct mrss_cb *mrss_create( struct mrss_creat_param*param );
long mrss_destroy( struct mrss_cb *cb );
long mrss_refresh( struct mrss_cb *cb );
long mrss_res_status_set( struct mrss_cb *cb, struct len_str*name, long status );
struct len_str *mrss_res_select( struct mrss_cb *cb, long param_counts, struct mrss_user_param* param );
long mrss_res_status_get( struct mrss_cb *cb, struct len_str*name );
extern long mrss_user_group_match( struct mrss_cb *cb, struct len_str *user_group, struct len_str *ctx, long param_counts, struct mrss_user_param* param );
long mrss_is_ip_le_area( struct mrss_cb *cb, struct pack_ip *ip, struct len_str *dst );

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif
