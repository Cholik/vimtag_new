/*!
\file       lid.h
\brief      id allocer unit

 ----history----
\author     chengzhiyong
\date       2007-10-30
\version    0.01
\desc       create

$Author: xieyong $
$Id: lid.h,v 1.2 2008-09-28 07:28:44 xieyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__lid_h__)
#define __lid_h__

#include <stdio.h>

#if defined(_MSC_VER)
#define lid_max_id          0x7fffffffffffffff
#else
#define lid_max_id          0x7fffffffffffffffLL
#endif
#define lid_seg_size        100

#define lid_flag_key2id     0x00000001  /* Indicate need query id from key */
#define lid_flag_id2key     0x00000002  /* Indicate need query key from id */

#define lid_get_id_flag_new 0x00000001  /* Indicate new alloc an id if key does not existed */

typedef struct lid_cb
{
    uint64_t            usable_id;      /* max usable id that have been pre-allocated */
    uint64_t            next_id;        /* next id */
    unsigned long       flag;           /* flag for lid */
    FILE                *ctrl_fp;       /* control file pointer */
    struct depository   *key2id_dps;    /* dps to get id from key */
    struct depository   *id2key_dps;    /* dps to get key from id */
}_lid_cb;

extern struct lid_cb *lid_create( char *path, unsigned long bucket, unsigned long cache_size, unsigned long flag, uint64_t init_id );
extern long lid_destroy( struct lid_cb *cb );
extern long lid_get_id( struct lid_cb *cb, unsigned long flag, void *key, unsigned long klen, uint64_t *id, unsigned long *out_flag );
extern long lid_get_key( struct lid_cb *cb, uint64_t id, void **key, unsigned long *klen );
extern long lid_del_id( struct lid_cb *cb, uint64_t id );
extern long lid_del_key( struct lid_cb *cb, void *key, unsigned long klen );
extern long lid_bind_key( struct lid_cb *cb, uint64_t id, void *key, unsigned long klen );


#endif /* !defined(__lid_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
