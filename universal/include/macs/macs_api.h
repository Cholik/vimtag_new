/*!
\file       macs_api.h
\brief      macs api header file

 ----history----
\author     dakota
\date       2013-01-15
\version    0.01
\desc       create
*/
#if !defined(__macs_api_h__)
#define __macs_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "mcore/pack.h"
#include "mhashmap/mhashmap.h"
#include "mencrypt/nid.h"

typedef long (*on_macs_logout)(  int64_t lid, void *refer );
typedef long (*on_macs_link_destroy)(  int64_t lid, void *refer );
typedef long (*on_macs_link_is_busy)(  int64_t lid, void *refer );
typedef long (*on_macs_session_destroy)(  int64_t lid, int64_t sid, void *refer );
typedef long (*on_macs_session_is_busy)(  int64_t lid, int64_t sid, void *refer );

#define macs_lenstr_max_len       128

typedef struct macs_create_param
{
    struct len_str          dps_path;       /* path to store dps data */
    long                    max_user;       /* Max user number support. 0 indicate not supoort user manage */
    long                    max_cache;      /* Max cache for dps */
    long                    max_link;       /* Max cache for dps */
    long                    max_session;    /* Max cache for dps */
    long                    oneoff_pass_ttl;   /* onetime pass ttl */
    long                    oneoff_pass_len;   /* onetime pass length */
    long                    file_dps;       /* Indicate user file dps */
    struct len_str          default_user;   /* default user */
    struct len_str          default_pass;   /* default user */
    struct len_str          su_pass;        /* Supper pass for modify pass */
    struct len_str          result;         /* output. result. */
    struct macs_mod         *mod;           /* output. module */
    on_macs_link_is_busy    on_link_is_busy;   /* Hook for link destory */
    on_macs_link_destroy    on_link_destroy;   /* Hook for link destory */
    on_macs_logout          on_logout;      /* Hook for logout */
    on_macs_session_is_busy    on_session_is_busy;   /* Hook for check whether session can be destroy  */
    on_macs_session_destroy    on_session_destroy;   /* Hook for session destory */
    void                    *refer;
}_macs_create_param;

typedef struct macs_link_create_param
{
    struct macs_mod         *mod;           /* macs mod */
    struct len_str          bnum_prime;     /* big prime num */
    struct len_str          root_num;       /* primitive root */
    struct len_str          key_a2b;        /* public key. peer a to peer b */
    struct len_str          link_contex;    /* contex data */
    struct len_str          link_refer;     /* refer data */
    int64_t                 tid;            /* intput/output. terminal_id */
    struct len_str          result;         /* output. result. */
    struct len_str          *key_b2a;       /* output. public key. peer b to peer a */
    int64_t                 lid;            /* output. link_id */
}_macs_link_create_param;

typedef struct macs_link_destroy_param
{
    struct macs_mod         *mod;           /* macs mod */
    int64_t                 lid;            /* output link_id */
    struct len_str          result;         /* output. result. */
}_macs_link_destroy_param;

typedef struct macs_session_create_param
{
    struct macs_mod         *mod;           /* macs mod */
    int64_t                 lid;            /* link_id */
    struct len_str          session_contex; /* contex data */
    struct len_str          session_refer;  /* refer data */
    struct len_str          result;         /* output. result. */
    int64_t                 sid;            /* output. session id */
    int32_t                 seq;            /* output. next seq should be used for build dh nid */
}_macs_session_create_param;

typedef struct macs_session_destroy_param
{
    struct macs_mod         *mod;           /* macs mod */
    int64_t                 sid;            /* session id */
    struct len_str          result;         /* output. result. */
}_macs_session_destroy_param;

typedef struct macs_reg_param
{
    struct macs_mod         *mod;           /* macs mod */
    long                    plain;          /* 1: plaintext password; other:ciphertext password */
    int64_t                 lid;            /* link_id */
    struct len_str          user;           /* Base user name. Can be normal user, email or mobile */
    struct len_str          email;          /* email name */
    struct len_str          mobile;         /* mobile name */
    struct len_str          pass;           /* des ciphertext of md5(pass) encrypt by share_key */
    struct len_str          user_contex;    /* contex data */
    struct len_str          user_refer;     /* refer data */

    struct len_str          result;         /* output. result. */
    long                    user_type;      /* output. Base user type */
    long                    wait_active_user;   /* output. Whether base user is inactive */
    long                    wait_active_email;
    long                    wait_active_mobile;
}_macs_reg_param;

typedef struct macs_bind_param
{
    struct macs_mod         *mod;           /* macs mod */
    struct len_str          user;           /* base user name, can be normal user, email and mobile */
    struct len_str          email;          /* email user name */
    struct len_str          mobile;         /* mobile user name */

    struct len_str          result;         /* output. result. */
    long                    user_type;      /* output. User type */
    long                    wait_active_email;  /* output. whether email is wait for active */
    long                    wait_active_mobile; /* output. whether email is wait for active */
}_macs_bind_param;

typedef struct macs_login_param
{
    struct macs_mod         *mod;           /* macs mod */
    int64_t                 lid;            /* link_id */
    struct len_str          user;           /* user name */
    struct len_str          login_contex;   /* contex data */
    struct len_str          login_refer;    /* refer data */
    long                    guest;          /* guest */
    struct len_str          result;         /* output. result. */
}_macs_login_param;

typedef struct macs_logout_param
{
    struct macs_mod         *mod;           /* macs mod */
    int64_t                 lid;            /* link_id */
    struct len_str          result;         /* output. result. */
}_macs_logout_param;

typedef struct macs_encrypt_param
{
    struct macs_mod         *mod;           /* macs mod */
    int64_t                 lid;            /* link_id */
    struct len_str          plaintext;      /* plaintext */
    struct len_str          result;         /* output. result. */
    struct len_str          ciphertext;     /* output. ciphertext */
}_macs_encrypt_param;

typedef struct macs_decrypt_param
{
    struct macs_mod         *mod;           /* macs mod */
    int64_t                 lid;            /* link_id */
    struct len_str          ciphertext;     /* ciphertext */
    struct len_str          result;         /* output. result. */
    struct len_str          plaintext;      /* output. plaintext */
}_macs_decrypt_param;

typedef struct macs_crc_param
{
    struct macs_mod         *mod;           /* macs mod */
    uint32_t                flag;           /* 0:8bit; 1:32bit */
    struct len_str          user;           /* user name */
    struct len_str          key;            /* key */
    struct len_str          message;        /* message data. */
    struct len_str          result;         /* output. result. */
    uint32_t                value;          /* Output. crc value */
}_macs_crc_param;

typedef struct macs_passwd_gen_param
{
    struct macs_mod         *mod;           /* macs mod */
    struct len_str          user;           /* user name */
    long                    pass_type;      /* pass type */
    struct len_str          result;         /* output. result. */
    struct len_str          pass;           /* output. password */
}_macs_passwd_gen_param;

typedef struct macs_passwd_param
{
    struct macs_mod         *mod;           /* macs mod */
    long                    plain;           /* 1: plaintext password; other:ciphertext password */
    int64_t                 lid;            /* link_id */
    struct len_str          user;           /* user name */
    struct len_str          pass;           /* des ciphertext of md5(new_pass) encrypt by share_key */
    long                    guest;          /* guest */
    struct len_str          result;         /* output. result. */
}_macs_passwd_param;

typedef struct macs_clean_link_param
{
    struct macs_mod         *mod;           /* macs mod */
    struct len_str          user;           /* user name */
    struct len_str          result;         /* output. result. */
}_macs_clean_link_param;

#define macs_pass_type_normal               1
#define macs_pass_type_email_active         2
#define macs_pass_type_mobile_active        3
#define macs_pass_type_email_recovery       4
#define macs_pass_type_mobile_recovery      5
#define macs_pass_type_guest                6
#define macs_pass_type_other                7
typedef struct macs_check_pass_param
{
    struct macs_mod         *mod;           /* macs mod */
    long                    plain;          /* flag to indicate plaintext pass */
    int64_t                 lid;            /* link_id */
    struct len_str          user;           /* user name */
    struct len_str          pass;           /* des ciphertext of md5(old_pass) encrypt by share_key or plaintext pass */
    long                    root;           /* indicate check root password */
    struct len_str          result;         /* output. result. */
    long                    pass_type;      /* output. pass type. */
    long                    guest;      /* output. guest. */
}_macs_check_pass_param;

typedef struct macs_check_nid_param
{
    struct macs_mod         *mod;           /* macs mod */
    struct len_str          nid;            /* network id composed of tlv set that type and len is hex string(length=2), value is string. type_1=tid; type_2=sid; type_3=user; type_4=seq; type_5=md5(share_key+sid+seq); type_6=md5(md5(pass)+tid+user+seq). Current support sid+seq+md5(share_key+sid+seq)/tid+user+seq+md5(md5(pass)+tid+user+seq). */
    int32_t                 flag;           /* bit0:1 indicate no need increace seq after check */
    struct len_str          result;         /* output. result. */
    struct len_str          user;           /* output. user name */
    int64_t                 sid;            /* output. session id */
    int32_t                 seq;            /* output. session seq */
    int64_t                 lid;            /* output. link_id */
    int64_t                 tid;            /* output. terminal_id */
    struct len_str          link_contex;    /* output. contex data */
    struct len_str          link_refer;     /* output. refer data */
    struct len_str          session_contex; /* output. contex data */
    struct len_str          session_refer;  /* output. refer data */
    struct len_str          login_contex;   /* output. contex data */
    struct len_str          login_refer;    /* output. refer data */
    struct len_str          user_contex;    /* output. contex data */
    struct len_str          user_refer;     /* output. refer data */
    long                    pass_match;     /* output. result. */
    long                    guest;          /* guest */
}_macs_check_nid_param;

typedef struct macs_client_create_param
{
    struct len_str          result;         /* output. result. */
    struct macs_client_mod  *mod;           /* output. module */
}_macs_client_create_param;

typedef struct macs_client_link_create_param
{
    struct macs_client_mod  *mod;           /* macs client mod */
    struct len_str          key_b2a;        /* input. public key. peer b to peer a */
    int64_t                 lid;            /* input. link_id */
    struct len_str          result;         /* output. result. */
}_macs_client_link_create_param;

typedef struct macs_client_info_get_param
{
    struct macs_client_mod  *mod;           /* macs client mod */
    struct len_str          prime;          /* output. prime */
    struct len_str          root;           /* output. root */
    struct len_str          key_a2b;        /* output. public key. peer a to peer b */
    struct len_str          key_b2a;        /* output. public key. peer b to peer a */
    int64_t                 lid;            /* output. link_id */
    int64_t                 sid;            /* output. session_id */
    int32_t                 seq;            /* output. sequence */
    struct len_str          result;         /* output. result. */
}_macs_client_info_get_param;

typedef struct macs_client_encrypt_param
{
    struct macs_client_mod  *mod;           /* macs client mod */
    struct len_str          plaintext;      /* plaintext */
    struct len_str          result;         /* output. result. */
    struct len_str          ciphertext;     /* output. ciphertext */
}_macs_client_encrypt_param;

typedef struct macs_client_decrypt_param
{
    struct macs_client_mod  *mod;           /* macs client mod */
    struct len_str          ciphertext;     /* ciphertext */
    struct len_str          result;         /* output. result. */
    struct len_str          plaintext;      /* output. plaintext */
}_macs_client_decrypt_param;

#define macs_nid_mod_sid    0
#define macs_nid_mod_lid    1
#define macs_nid_mod_pass   2
#define macs_nid_mod_pass_md5   3
typedef struct macs_nid_calc_param
{
    struct macs_client_mod  *mod;           /* macs client mod */
    int32_t                 mode;           /* 1: lid mode; 2:sid mode; 3:pass mode */
    struct len_str          user;           /* input. user name, valid for pass mode. */
    struct len_str          pass;           /* input. pass,valid for pass mode. */
    int64_t                 sid;            /* session_id */
    int32_t                 seq;            /* sequence */
    struct len_str          result;         /* output. result. */
    struct len_str          nid;            /* output. network id composed of tlv set that type and len is hex string(length=2), value is string. type_1=tid; type_2=sid; type_3=user; type_4=seq; type_5=md5(share_key+sid+seq); type_6=md5(md5(pass)+tid+user+seq). Current support sid+seq+md5(share_key+sid+seq)/tid+user+seq+md5(md5(pass)+tid+user+seq). */
}_macs_nid_calc_param;

typedef struct macs_session_cb
{
    int64_t                 sid;            /* session id */
    int64_t                 lid;            /* link id */
    int32_t                 seq;            /* next seq should be used for dh nid */
    struct len_str          session_contex; /* contex data */
    struct len_str          session_refer;  /* refer data */
    long                    create_tick;    /* tick of create */
    long                    access_tick;    /* tick of latest access */
    long                    access_count;   /* access count */
    struct
    {
        struct macs_session_cb   *prev;
        struct macs_session_cb   *next;
    }list_node;                             /*!< node in session_list */
}_macs_session_cb;

typedef struct macs_link_cb
{
    int64_t                 lid;            /* link_id */
    int64_t                 tid;            /* terminal id */
    struct len_str          share_key;      /* share key */
    struct len_str          key_b2a;        /* public key. peer b to peer a */
    struct len_str          link_contex;    /* contex data */
    struct len_str          link_refer;     /* refer data */
    struct len_str          login_user;     /* login user */
    struct len_str          login_contex;   /* contex data */
    struct len_str          login_refer;    /* refer data */
    long                    guest;          /* guest */
    long                    create_tick;    /* tick of create */
    long                    access_tick;    /* tick of latest access */
    long                    access_count;   /* access count */
    struct
    {
        struct macs_link_cb   *prev;
        struct macs_link_cb   *next;
    }list_node;                             /*!< node in link_list */
}_macs_link_cb;

typedef struct macs_client_mod
{
    char                    magic[sizeof(long)];    /*!< magic */

    struct len_str          bnum_prime;     /* bnum_prime */
    struct len_str          root_num;       /* root_num */

    struct dh_mod           *dh_cb;

    struct len_str          key_a2b;        /* peer a to peer b */
    struct len_str          key_b2a;        /* public key. peer b to peer a */
    int64_t                 lid;            /* link_id */
    int32_t                 seq;            /* sequence */

    struct len_str          share_key;      /* dh share key */
    struct nid_info         nid_cb;
    struct len_str          nid;            /* nid */
    char                    buffer[64];
}_macs_client_mod;

#define macs_user_type_normal   0
#define macs_user_type_email    1
#define macs_user_type_mobile   2
#define macs_user_type_invalid  3


typedef struct macs_mod
{
    char                    magic[sizeof(long)];    /*!< magic */
    long                    max_link;       /* Max cache for dps */
    long                    max_session;    /* Max cache for dps */
    long                    oneoff_pass_ttl;   /* onetime pass ttl */
    long                    oneoff_pass_len;   /* onetime pass length */
    int64_t                 tid;            /* latest terminal id */
    int64_t                 lid;            /* latest link id */
    int64_t                 sid;            /* latest session id */
    on_macs_link_is_busy    on_link_is_busy;   /* Hook for link is free */
    on_macs_link_destroy    on_link_destroy;   /* Hook for link destory */
    on_macs_logout          on_logout;      /* Hook for logout */
    on_macs_session_is_busy    on_session_is_busy;   /* Hook for check whether session can be destroy  */
    on_macs_session_destroy    on_session_destroy;   /* Hook for session destory */
    void                    *refer;
    struct depository       *dps;           /* dps for store user info */
    struct pack_def_list    *def_list;      /*!< def list */
    struct pack_def         *cacs_user_info_def;    /* def for cacs_user_info_def */
    struct pack_def         *cacs_user_info_ex_def; /* def for cacs_user_info_ex_def */
    struct pack_def         *cacs_oneoff_pass_def; /* def for cacs_oneoff_pass_def */
    struct len_str          su_pass;        /* supper password */
    struct hash_map         *map_link;      /* link_cb map */
    struct hash_map         *map_session;   /* session_cb map */
    struct hash_map         *map_user;      /* user_info map */
    struct
    {
        unsigned long       counts;
        struct macs_link_cb *list;
    }link_list;                             /* link list */
    struct
    {
        unsigned long       counts;
        struct macs_session_cb *list;
    }session_list;                          /* session list */

    struct len_str          cache_user_contex;     /* just for api return cache */
    struct len_str          cache_user_refer;     /* just for api return cache */
    struct len_str          cache_user_pass;     /* just for api return cache */
    char                    buf_user_contex[macs_lenstr_max_len+1];    
    char                    buf_user_refer[macs_lenstr_max_len+1];    
    char                    buf_user_pass[macs_lenstr_max_len+1];    
}_macs_mod;

typedef struct macs_user_summary
{
    struct len_str          result;         /* output. result. */

    uint32_t                user_type;      /* user type */
    uint32_t                base_user_type; /* base user type ??*/
    long                    base;           /* whether have user_info */
    long                    active;         /* whether user_name is active */

    long                    active_base;    /* whether base user_name is active */
    long                    active_email;   /* whether email user_name is active */
    long                    active_mobile;  /* whether mobile user_name is active */

    struct len_str          *user_base;     /* base user_name */
    struct len_str          *user_email;    /* email user_name */
    struct len_str          *user_mobile;   /* mobile user_name */

    struct len_str          *user_base_abstract;   /* base user_name abstract */
    struct len_str          *user_email_abstract;   /* email user_name abstract */
    struct len_str          *user_mobile_abstract;   /* mobile user_name */

    struct len_str          *user_contex;    /* output. contex data */
    struct len_str          *user_refer;     /* output. refer data */
    struct len_str          *user_pass;      /* output. password md5 */

    unsigned long           pass_checksum;  /* output. crc of pass */
    int64_t                 create_time;    /* output. create time */
}_macs_user_summary;

extern long macs_check_nid( struct macs_check_nid_param *param );
extern long macs_check_pass( struct macs_check_pass_param *param );
extern long macs_create( struct macs_create_param *param );
extern long macs_decrypt( struct macs_decrypt_param *param );
extern long macs_des_base64_dec( struct macs_decrypt_param *param );
extern long macs_destroy( struct macs_mod *mod );
extern long macs_encrypt( struct macs_encrypt_param *param );
extern long macs_link_create( struct macs_link_create_param *param );
extern long macs_link_destroy( struct macs_link_destroy_param *param );
extern long macs_login( struct macs_login_param *param );
extern long macs_logout( struct macs_logout_param *param );
extern long macs_passwd( struct macs_passwd_param *param );
extern long macs_reg( struct macs_reg_param *param );
extern long macs_session_create( struct macs_session_create_param *param );
extern long macs_session_destroy( struct macs_session_destroy_param *param );
extern long macs_clean_link( struct macs_clean_link_param *param );
extern long macs_passwd_gen( struct macs_passwd_gen_param *param );
extern long macs_user_summary_get( struct macs_mod *mod, struct len_str *user_name, struct macs_user_summary *summary );
extern long macs_user_summary_clean( struct macs_user_summary *summary );
extern long macs_client_create( struct macs_client_create_param *param );
extern long macs_client_destroy( struct macs_client_mod *mod );
extern long macs_client_link_create( struct macs_client_link_create_param *param );
extern long macs_client_encrypt( struct macs_client_encrypt_param *param );
extern long macs_client_decrypt( struct macs_client_decrypt_param *param );
extern long macs_bind( struct macs_bind_param *param );
extern long macs_dump( struct macs_mod *mod,
                    unsigned long       argc,
                    char                *argv[],
                    char                *buf,
                    char                *file,
                    unsigned long       start,
                    unsigned long       counts,
                    unsigned long       size);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__macs_api_h__) */
