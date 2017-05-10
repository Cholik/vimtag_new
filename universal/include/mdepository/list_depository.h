/*
\file       list_depository.h
\brief      list_depository header 
------history----------
\author     xieyong
\version    0.01
\desc       create
------history----------
*/
#if defined(__cplusplus)
extern "C" {
#endif

#if !defined(__list_depository_h__)
#define __list_depository_h__

typedef struct list_depository
{
    struct depository   *dps;        /* dps to get list from key */
}_list_depository;

#if defined(_MSC_VER)
#pragma warning(disable:4200)
#endif
typedef struct list_items
{
    unsigned long           counts;
    uint64_t                items[0];
}_list_items;
#if defined(_MSC_VER)
#pragma warning(default:4200)
#endif

#define LIST_ITEMS_SIZE(COUNTS) (sizeof( struct list_items ) + sizeof(((struct list_items*)0)->items[0]) * (COUNTS) )

extern long list_dps_add_item( struct list_depository* list_dps, void *key, unsigned long klen, uint64_t item );
extern long list_dps_add_items( struct list_depository* list_dps, void *key, unsigned long klen, struct list_items *items );
extern struct list_depository *list_dps_create( char *key_type, char *path, unsigned long hash_bucket_counts, unsigned long cached_size );
extern long list_dps_del_item( struct list_depository* list_dps, void *key, unsigned long klen, uint64_t item );
extern long list_dps_del_items( struct list_depository* list_dps, void *key, unsigned long klen, struct list_items *items );
extern struct list_items* list_dps_get_items( struct list_depository* list_dps, void *key, unsigned long klen );
extern long list_dps_items_or( struct list_depository* list_dps, void **key_array, unsigned long *klen_array, unsigned long array_size, struct list_items *items );
extern long list_dps_set_items( struct list_depository* list_dps, void *key, unsigned long klen, struct list_items *items );
extern long list_dps_items_cmp( struct list_items *items1, struct list_items *items2 );
extern void list_dps_items_sort( struct list_items *items );


#endif /* !defined(__list_depository_h__) */
#if defined(__cplusplus)
}
#endif

