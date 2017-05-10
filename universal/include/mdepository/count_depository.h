/*
\file       count_depository.h
\brief      count_depository header 
------history----------
\author     xieyong
\version    0.01
\desc       create
------history----------
*/
#if defined(__cplusplus)
extern "C" {
#endif

#if !defined(__count_depository_h__)
#define __count_depository_h__

typedef struct count_depository
{
    struct depository   *dps;
}_count_depository;

extern struct count_depository *count_dps_create( char *key_type, char *path, unsigned hash_bucket_counts, unsigned cached_size );
extern unsigned count_dps_get_count( struct count_depository* count_dps, void *key, unsigned klen );
extern long count_dps_inc_count( struct count_depository* count_dps, void *key, unsigned klen, unsigned count );
extern long count_dps_dec_count( struct count_depository* count_dps, void *key, unsigned klen, unsigned count );
extern long count_dps_set_count( struct count_depository* count_dps, void *key, unsigned klen, unsigned count );


#endif /* !defined(__count_depository_h__) */
#if defined(__cplusplus)
}
#endif


