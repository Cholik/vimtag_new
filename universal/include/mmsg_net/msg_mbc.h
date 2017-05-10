#if !defined(__msg_mbc_h__)
#define __msg_mbc_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

typedef long (*mmbc_user_on_recv_msg)( void *ref, struct message *msg, struct sockaddr_in *remote_addrin );
typedef long (*mmbc_user_on_recv_json_msg)( void *ref, struct len_str *msg_type, struct len_str *msg_json, struct sockaddr_in *remote_addrin );

typedef struct mmbc_create_param
{
    struct len_str          broadcast_addr;
    struct len_str          multicast_addr;
    long                    port;
    void                    *refer;
    struct pack_def_list    *def_list;
    mmbc_user_on_recv_msg   on_recv_msg;
    mmbc_user_on_recv_json_msg   on_recv_json_msg;
    long                    disable_listen;
}_mmbc_create_param;

extern void *mmbc_create( struct mmbc_create_param *param );
extern long mmbc_destroy( void *handle );
extern long mmbc_send_msg_ex( void *handle, struct sockaddr_in *local_addrin, struct sockaddr_in *mask, struct sockaddr_in *remote_addrin, struct message *msg );
extern long mmbc_send_msg( void *handle, struct sockaddr_in *remote_addrin, struct message *msg );
extern long mmbc_send_data( void *handle, struct sockaddr_in *remote_addrin, struct len_str *msg_type, struct len_str *msg_data );

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif
