/*!
\file       mapns_api.h
\brief      Mining APNS unit

 ----history----
\author     chengzhiyong
\date       2013-07-27
\version    0.01
\desc       create
*/

#if !defined(__mapns_api_h__)
#define __mapns_api_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

#include "mcore/mcore.h"
#include "mlight_queue/mlight_queue.h"


struct mapns_ctx;

typedef struct mapns_msg
{
    struct mlq_msg              base;               /*!< base obj from mlq_msg */
    unsigned long               identify;           /*!< message identify */
    unsigned long               expiry;             /*!< expiry setting, can be (time(0) + seconds) */
    struct len_str              token;              /*!< device token */
    struct len_str              content;            /*!< json content {"aps":{"alert":{"body":"hello world!"},"sound":"default",\"badge\":3}} */
}_mapns_msg;
#define mapns_msg_format_s      "%p"
#define mapns_msg_format(_msg)  (_msg)

typedef struct mapns_desc
{
    char                        *host;              /*!< server host */
    unsigned long               port;               /*!< server port */

    unsigned long               reconnect_wait_times;/*!< how many times later try to restart apns connection. */

    char                        *client_cert;       /* client cert */
    char                        *client_key;        /* client key */
    char                        *client_key_pwd;    /* key password if have */
    char                        *ca_cert;           /* server cert if have */
}_mapns_desc;
#define mapns_desc_format_s         "%p"
#define mapns_desc_format(_desc)    (_desc)

struct mapns_ctx *mapns_ctx_create(struct mapns_desc *desc);
long mapns_ctx_destroy(struct mapns_ctx *ctx);
long mapns_queue_on_run(struct mlq_queue *queue, struct mapns_ctx *ctx, struct mapns_msg *msg);
long mapns_util_entry(long argc, char *argv[]);
long mapns_format( struct mapns_ctx *ctx, char *buf, unsigned long *size);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__mapns_api_h__) */

