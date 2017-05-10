/*!
\file       metp_dat.h
\brief      mining endpoint transport protocol

 ----history----
\author     chengzhiyong
\date       2013-07-25
\version    0.01
\desc       create
*/

#if !defined(__metp_dat_h__)
#define __metp_dat_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

struct metp_tunnel;

long metp_tunnel__try_send_task(struct metp_tunnel *tunnel, unsigned long timestamp);

long metp_tunnel__on_chunk_dat(struct metp_sock_ctx *ctx, struct metp_chunk_dat *chunk);
long metp_tunnel__on_chunk_ack(struct metp_sock_ctx *ctx, struct metp_chunk_ack *chunk);

long metp_tunnel__tunnl_queue_clear(struct metp_tunnel *tunnel);

long metp_tunnel_send(struct metp_tunnel *tunnel, unsigned long qid, unsigned long timestamp, 
                      unsigned long counts, unsigned long *len, unsigned char **data);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__metp_dat_h__) */
