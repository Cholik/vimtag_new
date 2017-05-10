/*!
\file       hash_table.h
\brief      table hash unit, just algorithm part, do not management memory
            resource here. user need management hash-table-header/buckets/items-data
            self.

 ----history----
\author     chengzhiyong
\date       2008-10-25
\version    0.01
\desc       create


$Author: chengzhiyong $
$Id: hash_table.h,v 1.5 2008-11-14 00:06:01 chengzhiyong Exp $
*/
#if !defined(__hash_table_h__)
#define __hash_table_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */


#if !defined(hash_ex_enable_bucktes_manager_auto)
#   define hash_ex_enable_bucktes_manager_auto 1
#endif

/*!
func    hash_get_value
\brief  get hash value
\param  key[in]                 the hash key pointer
\param  ref[in]                 the refer data be set in hash table when hash_ex_init()
\return the hash value
*/
typedef unsigned long(*hash_get_value)(void *key, void *ref);

/*!
func    hash_compare
\brief  compare hash key
\param  key1[in]                the hash key pointer1
\param  key2[in]                the hash key pointer2
\param  ref[in]                 the refer data be set in hash table when hash_ex_init()
\return compare result
        #0                      same
        #other                  not same
*/
typedef long (*hash_compare)(void *key1, void *key2, void *ref);

#define hash_table_magic   (*(long*)"hash    ")
/*! \brief hash table struct */
typedef struct hash_table
{
    char                    magic[sizeof(long)];        /*!< hash table magic */
    unsigned long           bucktes_manager_auto;       /*!< buckets manager auto, will auto expand */
    unsigned long           update_counts;              /*!< buckets update counts */
    unsigned long           key_pos;                    /*!< key position in item */
    unsigned long           hash_next_pos;              /*!< hash next pos in item */
    unsigned long           bucket_counts;              /*!< buckets counts */
    void                    **buckets;                  /*!< buckets */
    unsigned long           counts;                     /*!< active item counts */
    hash_get_value          get_value;                  /*!< get hash value routine */
    hash_compare            comp;                       /*!< compare routine */
    void                    *base_addr;                 /*!< base addr, if IPC in sharememory should set this value */
    void                    *ref;                       /*!< user refer data */
}_hash_table;

/*!
func    hash_ex_init
\brief  init hash table
\param  tbl[in/out]             hash table
\param  buckets[in]             the bucket array, can be NULL, if NULL will auto manage here
\param  bucket_counts[in]       the bucket counts, !rebuild_map will be ignore
\param  get_value[in]           the routine to calculate hash-value, if int can be NULL
\param  comp[in]                the routine to compare key, can be NULL
                                if NULL means long.
                                    !!!!!!!LPP LLP will not same in 64bits system.
\param  hash_next_pos[in]       the hash next pointer pos in item. equ (unsigned)&((struct item*)0)->hash_next
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
long hash_ex_init(struct hash_table *tbl,
               void                 **buckets,
               unsigned long        bucket_counts,
               hash_get_value       get_value,
               hash_compare         comp,
               unsigned long        hash_next_pos,
               unsigned long        key_pos,
               void                 *base_addr,
               void                 *ref);

/*!
func    hash_ex_uninit
\brief  uninit hash buckets, will try free buckets if manager here
\param  tbl[in/out]             hash table
\return uninit result
        #0                      succeed
        #other                  error code
*/
long hash_ex_uninit(struct hash_table *tbl);

/*!
func    hash_ex_update
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
long hash_ex_update(struct hash_table *tbl, void **buckets, unsigned long bucket_counts);

/*!
func    hash_ex_get
\brief  get hash item
\param  tbl[in]                 hash table
\param  key[in]                 the key
\return matched item
        #NULL                   nothing match this key
        #other                  the matched item
*/
void *hash_ex_get(struct hash_table *tbl, void *key);

/*!
func    hash_ex_add
\brief  add item
\param  tbl[in]                 hash table
\param  item[in]                the  hash item
\return add result
        #0                      succeed
        #other                  error code
*/
long hash_ex_add(struct hash_table *tbl, void *item);

/*!
func    hash_ex_del
\brief  delete item
\param  tbl[in]                 hash table
\param  key[in]                 the key
\return the item be delete
        #NULL                   nothing match this key
        #other                  the item be delete
*/
void *hash_ex_del(struct hash_table *tbl, void *key);

/*!
func    hash_ex_check
\brief  check hash table
\param  tbl[in]                 hash table
\return check hash table
        #0                      succeed
        #error                  error code
*/
long hash_ex_check(struct hash_table *tbl);

/* --------base hash refer routine---------------------------- */
unsigned long hash_get_value_by_string(void *key/*char **key*/, void *ref);
long hash_compare_by_string(void *key1/*char **key1*/, void *key2/*char **key2*/, void *ref);
unsigned long hash_get_value_by_case_string(void *key/*char **key*/, void *ref);
long hash_compare_by_case_string(void *key1/*char **key1*/, void *key2/*char **key2*/, void *ref);
unsigned long hash_get_value_by_len_string(void *key/*struct len_str *key*/, void *ref);
long hash_compare_by_len_string(void *key1/*struct len_str *key1*/, void *key2/*struct len_str *key2*/, void *ref);
unsigned long hash_get_value_by_case_len_string(void *key/*struct len_str *key*/, void *ref);
long hash_compare_by_case_len_string(void *key1/*struct len_str *key1*/, void *key2/*struct len_str *key2*/, void *ref);
unsigned long hash_get_value_by_int64(void *key/*int64 *key*/, void *ref);
long hash_compare_by_int64(void *key1/*int64 *key1*/, void *key2/*int32 *key2*/, void *ref);
unsigned long hash_get_value_by_int32(void *key/*int32 *key*/, void *ref);
long hash_compare_by_int32(void *key1/*int32 *key1*/, void *key2/*int32 *key2*/, void *ref);
unsigned long hash_get_value_by_int(void *key/*int *key*/, void *ref);
long hash_compare_by_int(void *key1/*int *key1*/, void *key2/*int *key2*/, void *ref);
unsigned long hash_get_value_by_long(void *key/*long *key*/, void *ref);
long hash_compare_by_long(void *key1/*long *key1*/, void *key2/*long *key2*/, void *ref);
unsigned long hash_get_value_by_sockaddr_in( void *key, void *ref );
long hash_compare_by_sockaddr_in( void *key1, void *key2, void *ref );

#define hash_field_pos(_type_name, _field_name) ((unsigned long)&(((_type_name*)0)->_field_name))
/* --------base hash refer routine---------------------------- */


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
#endif /* !defined(__hash_table_h__) */
