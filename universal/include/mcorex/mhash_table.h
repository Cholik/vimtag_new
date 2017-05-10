/*!
\file       mhash_table.h
\brief      table hash unit, just algorithm part, do not management memory
            resource here. user can management hash-table-header/buckets/items-data
            self.

 ----history----
\author     chengzhiyong
\date       2008-10-25
\version    0.01
\desc       create

\author     chengzhiyong
\date       2014-07-03
\version    0.02
\desc       add hash head, let it can storage in sharememory for cross process

*/
#if !defined(__mhash_table_h__)
#define __mhash_table_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */


#if !defined(mhash_enable_bucktes_manager_auto)
#   define mhash_enable_bucktes_manager_auto    1
#endif

/*!
func    mhash_get_value
\brief  get hash value
\param  key[in]                 the hash key pointer
\param  ref[in]                 the refer data be set in hash table when mhash_init()
\return the hash value
*/
typedef unsigned long(*mhash_get_value)(void *key, void *ref);

/*!
func    mhash_compare
\brief  compare hash key
\param  key1[in]                the hash key pointer1
\param  key2[in]                the hash key pointer2
\param  ref[in]                 the refer data be set in hash table when mhash_init()
\return compare result
        #0                      same
        #other                  not same
*/
typedef long (*mhash_compare)(void *key1, void *key2, void *ref);

#define mhash_table_head_magic (*(long*)"hshd    ")
typedef struct mhash_table_head
{
    char                    magic[sizeof(long)];        /*!< hash table magic */
    unsigned long           update_counts;              /*!< buckets update counts */
    unsigned long           key_pos;                    /*!< key position in item */
    unsigned long           hash_next_pos;              /*!< hash next pos in item */
    unsigned long           bucket_counts;              /*!< buckets counts */
    unsigned long           counts;                     /*!< active item counts */
}_mhash_table_head;
#define mhash_table_head_format_s       "%p{magic[%4.4s], update_counts[%ld], key_pos[%ld], "\
                                        "hash_nex_pos[%ld], bucket_counts[%ld], counts[%ld]}"
#define mhash_table_head_format(_head)  (_head), (_head)?&(_head)->magic[0]:0, \
                                        (_head)?(_head)->update_counts:0, (_head)?(_head)->key_pos:0, \
                                        (_head)?(_head)->hash_next_pos:0, (_head)?(_head)->bucket_counts:0, \
                                        (_head)?(_head)->counts:0

#define mhash_table_magic   (*(long*)"hash    ")
/*! \brief hash table struct */
typedef struct mhash_table
{
    char                    magic[sizeof(long)];        /*!< hash table magic */
    struct mhash_table_head *head;                      /*!< head */
    void                    **buckets;                  /*!< buckets */
    unsigned long           bucktes_manager_auto;       /*!< buckets manager auto, will auto expand */
    mhash_get_value         get_value;                  /*!< get hash value routine */
    mhash_compare           comp;                       /*!< compare routine */
    void                    *base_addr;                 /*!< base addr, if IPC in sharememory should set this value */
    void                    *ref;                       /*!< user refer data */
    struct mhash_table_head head_inner;                 /*!< head inner */
}_mhash_table;
#define mhash_table_format_s        "%p{magic[%4.4s], head[%p], buckets[%p], bucktes_manager_auto[%ld], "\
                                    "get_value[%p], comp[%p], base_addr[%p], ref[%p]}"
#define mhash_table_format(_tbl)    (_tbl), (_tbl)?&(_tbl)->magic[0]:0, \
                                    (_tbl)?(_tbl)->head:0, (_tbl)?(_tbl)->buckets:0, (_tbl)?(_tbl)->bucktes_manager_auto:0, \
                                    (_tbl)?(_tbl)->get_value:0, (_tbl)?(_tbl)->comp:0, \
                                    (_tbl)?(_tbl)->base_addr:0, (_tbl)?(_tbl)->ref:0

/*!
func    mhash_init
\brief  init hash table
\param  tbl[in/out]             hash table
\param  head[in]                hash table head, can be NULL, if NULL will use inner head 
\param  buckets[in]             the bucket array, can be NULL, if NULL will auto manage here
\param  bucket_counts[in]       the bucket counts, !rebuild_map will be ignore
\param  get_value[in]           the routine to calculate hash-value, if int can be NULL
\param  comp[in]                the routine to compare key, can be NULL
                                if NULL means long.
                                    !!!!!!!LPP LLP will not same in 64bits system.
\param  mhash_next_pos[in]       the hash next pointer pos in item. equ (unsigned)&((struct item*)0)->hash_next
\param  key_pos[in]             the key position in item. equ ((char*)item->key - (char*)item)
                                if complex item have not a special key member, u can tell as ZERO
                                and calculate hash value by whole item as a key
                                (unsigned long)&((struct item*)0)->key
\param  base_addr[in]           the data refer buffer start address in current process,
                                this param just used for pointer data need share with other process
                                so if value is a unsigned value, this param should be NULL.
                                if not NULL, when add data to tree, data<saved> will be convert (data - data_base_addr),
                                and when compare() will be call with (data<saved> + data_base_addr)
\param  ref[in]                 the user refer data, will tell-back when call hash get_value and comp routine
\return init result
        #0                      succeed
        #other                  error code
*/
long mhash_init(struct mhash_table       *tbl,
                struct mhash_table_head  *head,
                void                     **buckets,
                unsigned long            bucket_counts,
                mhash_get_value          get_value,
                mhash_compare            comp,
                unsigned long            mhash_next_pos,
                unsigned long            key_pos,
                void                     *base_addr,
                void                     *ref);

/*!
func    mhash_uninit
\brief  uninit hash buckets, will try free buckets if manager here
\param  tbl[in/out]             hash table
\return uninit result
        #0                      succeed
        #other                  error code
*/
long mhash_uninit(struct mhash_table *tbl);

/*!
func    mhash_update
\brief  update hash buckets, can update a new hash buckets
\param  tbl[in/out]             hash table
\param  buckets[in]             the bucket array,
                                if same as old buckets will be resize(memory is safe).
                                else will update as new buckets
\param  bucket_counts[in]       the bucket counts, !rebuild_map will be ignore
\return update result
        #0                      succeed
        #other                  error code
*/
long mhash_update(struct mhash_table *tbl, void **buckets, unsigned long bucket_counts);

/*!
func    mhash_get
\brief  get hash item
\param  tbl[in]                 hash table
\param  key[in]                 the key
\return matched item
        #NULL                   nothing match this key
        #other                  the matched item
*/
void *mhash_get(struct mhash_table *tbl, void *key);

/*!
func    mhash_add
\brief  add item
\param  tbl[in]                 hash table
\param  item[in]                the  hash item
\return add result
        #0                      succeed
        #other                  error code
*/
long mhash_add(struct mhash_table *tbl, void *item);

/*!
func    mhash_del
\brief  delete item
\param  tbl[in]                 hash table
\param  key[in]                 the key
\return the item be delete
        #NULL                   nothing match this key
        #other                  the item be delete
*/
void *mhash_del(struct mhash_table *tbl, void *key);

/*!
func    mhash_check
\brief  check hash table
\param  tbl[in]                 hash table
\return check hash table
        #0                      succeed
        #error                  error code
*/
long mhash_check(struct mhash_table *tbl);

/* --------base hash refer routine---------------------------- */
unsigned long mhash_get_value_by_string(void *key/*char **key*/, void *ref);
long mhash_compare_by_string(void *key1/*char **key1*/, void *key2/*char **key2*/, void *ref);
unsigned long mhash_get_value_by_case_string(void *key/*char **key*/, void *ref);
long mhash_compare_by_case_string(void *key1/*char **key1*/, void *key2/*char **key2*/, void *ref);
unsigned long mhash_get_value_by_len_string(void *key/*struct len_str *key*/, void *ref);
long mhash_compare_by_len_string(void *key1/*struct len_str *key1*/, void *key2/*struct len_str *key2*/, void *ref);
unsigned long mhash_get_value_by_case_len_string(void *key/*struct len_str *key*/, void *ref);
long mhash_compare_by_case_len_string(void *key1/*struct len_str *key1*/, void *key2/*struct len_str *key2*/, void *ref);
unsigned long mhash_get_value_by_int64(void *key/*int64 *key*/, void *ref);
long mhash_compare_by_int64(void *key1/*int64 *key1*/, void *key2/*int32 *key2*/, void *ref);
unsigned long mhash_get_value_by_int32(void *key/*int32 *key*/, void *ref);
long mhash_compare_by_int32(void *key1/*int32 *key1*/, void *key2/*int32 *key2*/, void *ref);
unsigned long mhash_get_value_by_int(void *key/*int *key*/, void *ref);
long mhash_compare_by_int(void *key1/*int *key1*/, void *key2/*int *key2*/, void *ref);
unsigned long mhash_get_value_by_long(void *key/*long *key*/, void *ref);
long mhash_compare_by_long(void *key1/*long *key1*/, void *key2/*long *key2*/, void *ref);
unsigned long mhash_get_value_by_sockaddr_in( void *key, void *ref );
long mhash_compare_by_sockaddr_in( void *key1, void *key2, void *ref );

#define mhash_field_pos(_type_name, _field_name) ((unsigned long)&(((_type_name*)0)->_field_name))
/* --------base hash refer routine---------------------------- */


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
#endif /* !defined(__mhash_table_h__) */
