
#if defined(__cplusplus)
extern "C" {
#endif

#if !defined(__hash_map_h__)
#define __hash_map_h__

#define HMAP_ITEM_COUNTS_MIN            2

#define HASH_MAP_MAX_BUF                0x6400000

#if defined(_DEBUG)
    #define HMAP_DEBUG
#endif

typedef struct hash_map
{
    struct hash_table       *hash;
    unsigned long           fixed;          /* Whether size of user data is fixed */
    unsigned long           data_size;      /* Size of user data( if it's fixed ) */
    unsigned long           item_counts;    /* Counts of item( if it's fixed ) */
    struct hash_map_buf     *buf;           /* Buffer for alloc user data( if it's fixed ) */
    struct hash_map_item    *free_item;     /* Free user data( if it's fixed ) */
    unsigned long           free_item_count;/* Free item count */

#ifdef HMAP_DEBUG
    struct
    {
        struct hash_map    *prev;
        struct hash_map    *next;
    }node;                                      /*!< send cb list node */
    unsigned long           buf_count;      /* Buffer count */
    unsigned long           buf_size;       /* Total buffer size */
    char                    *file;          /* Create file path */
    unsigned long           line;           /* Create file len */
#endif
}_hash_map;

#if defined(_MSC_VER)
#pragma warning(disable:4200)
#endif
typedef struct hash_map_buf
{
    struct hash_map_buf     *next;          /* Next buffer */
    char                    data[0];        /* Buffer data */
}_hash_map_buf;

typedef struct hash_map_item
{
    struct hash_map_item    *next;          /* Next item */
    char                    data[0];        /* user data */
}_hash_map_item;

#if defined(_MSC_VER)
#pragma warning(default:4200)
#endif

typedef struct hash_map_handle
{
    struct hash_map         *map;           /* Point to hash_map */
    unsigned long           bucket_index;   /* Current bucket index */
    struct hash_map_item    *item;          /* Current hash_map_item */
}_hash_map_handle;

#ifdef HMAP_DEBUG
#define hmap_create( FUNC_GET_VALUE, FUNC_COMPARE, FIXED, KEY_POS ) hmap_create_x( FUNC_GET_VALUE, FUNC_COMPARE, FIXED, KEY_POS, __FILE__, __LINE__ )
#else
#define hmap_create( FUNC_GET_VALUE, FUNC_COMPARE, FIXED, KEY_POS ) hmap_create_x( FUNC_GET_VALUE, FUNC_COMPARE, FIXED, KEY_POS, NULL, 0 )
#endif


#define hmap_get_count( MAP )           (MAP)->hash->counts
#define hmap_open( MAP, HANDLE)  \
{\
    struct hash_map_handle  handle_local;\
    handle_local.map = (MAP);\
    handle_local.bucket_index = 0;\
    handle_local.item = NULL;\
    *(HANDLE) = &handle_local;

#define hmap_get_first( HANDLE, DATA )  \
{\
    unsigned long i;\
    *(DATA) = NULL;\
    if( (HANDLE)->map ) \
    {\
        for( i = 0; i < (HANDLE)->map->hash->bucket_counts; i++ )\
        {\
            if( (HANDLE)->map->hash->buckets[i] != NULL )\
            {\
                (HANDLE)->item = ( struct hash_map_item * )(HANDLE)->map->hash->buckets[i];\
                (HANDLE)->bucket_index = i;\
                *(DATA) = ( void * )&(HANDLE)->item->data[0];\
                break;\
            }\
        }\
    }\
}

/* Modify *(void**)(&ptr) to *(&ptr) to avoid code be ingore when gcc -o3 */

#define hmap_get_next( HANDLE, DATA )\
{\
    unsigned long i;\
    *(DATA) = NULL;\
    if( (HANDLE)->item->next != NULL )\
    {\
        (HANDLE)->item = (HANDLE)->item->next;\
        *(DATA) = ( void * )&(HANDLE)->item->data[0];\
    }\
    else\
    {\
        for( i = (HANDLE)->bucket_index + 1; i < (HANDLE)->map->hash->bucket_counts; i++ )\
        {\
            if( (HANDLE)->map->hash->buckets[i] != NULL )\
            {\
                (HANDLE)->item = ( struct hash_map_item * )(HANDLE)->map->hash->buckets[i];\
                (HANDLE)->bucket_index = i;\
                *(DATA) = ( void * )&(HANDLE)->item->data[0];\
                break;\
            }\
        }\
    }\
}

#define hmap_close( HANDLE ) }

/*!
func    hmap_create_ex
\brief  Create hash_map, use hmap_destroy to free it
\param  get_value[in]           the routine to calculate hash-value
\param  comp[in]                the routine to compare key
\param  fixed[in]               Whether the size of user data is fixed
\param  key_pos[in]             the key position in user data. equ ((char*)data->key - (char*)data)
                                if complex item have not a special key member, u can tell as ZERO
                                and calculate hash value by whole data as a key
\param  file[in]                the source file name, __FILE__, used to debug, will record it
\param  line[in]                the file line, __LINE__, used to debug, will record it 
\return the pointer
        #NULL                   create failed
        #other                  the pointer of hash_map
*/
extern struct hash_map *hmap_create_x( hash_get_value   get_value, 
                                       hash_compare     comp,
                                       unsigned long    fixed,
                                       unsigned long    key_pos,
                                       char             *file,
                                       unsigned long    line );
extern long hmap_destroy( struct hash_map *map );
extern long hmap_add( struct hash_map *map, void *data );
extern void *hmap_del( struct hash_map *map, void *key );
extern void *hmap_get( struct hash_map *map, void *key );
extern void *hmap_malloc( struct hash_map *map, unsigned long size );
extern void *hmap_calloc( struct hash_map *map, unsigned long size );
extern long hmap_free( struct hash_map *map, void *data );
extern void hmap_dump();
extern long hmap_update( struct hash_map *map );

#endif /* !defined(__hash_map_h__) */
#if defined(__cplusplus)
}
#endif



