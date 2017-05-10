/*!
\file       id_allocer.h
\brief      id allocer unit

 ----history----
\author     chengzhiyong
\date       2007-10-30
\version    0.01
\desc       create

$Author: xieyong $
$Id: id_allocer.h,v 1.2 2008-09-28 07:28:44 xieyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__id_allocer_h__)
#define __id_allocer_h__

#include <stdio.h>

#define _id_max 0x7fffffff
#define _id_seg_size    100

typedef struct id_allocer
{
    uint64_t            usable_id,      /* max usable id that have been pre-allocated */
                        next_id;        /* next id */
    FILE                *log_fp;        /* log file pointer */
    struct depository   *id_dps;        /* dps to get id from key */
    struct depository   *key_dps;       /* dps to get key from id */
}_id_allocer;

extern struct id_allocer *id_allocer_create( char *key_type, char *path, unsigned long hash_bucket_counts, unsigned long cached_size );
extern long id_allocer_destroy( struct id_allocer *allocer );
extern long id_allocer_get_id( struct id_allocer *allocer, void *key, unsigned long klen, uint64_t *id );
extern long id_allocer_get_key( struct id_allocer *allocer, uint64_t id, void **key, unsigned long *klen );
extern long id_allocer_get_next_id( struct id_allocer *allocer, uint64_t *id );

#endif /* !defined(__id_allocer_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
