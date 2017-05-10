/*!
\file       depository.h
\brief      depository unit

 ----history----
\author     chengzhiyong
\date       2007-09-24
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: depository.h,v 1.14 2008-08-12 10:33:43 chengzhiyong Exp $
*/
#if !defined(__depository_h__)
#define __depository_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct depository;

#define dps_hash_level_size                                 (1<<8)
#define dps_hash_level_counts                               (32/8)
typedef enum dps_query_item_type                    /* if not special, output type is unsinged long */
{
    dps_query_item_key_type,                        /* char* */
    dps_query_item_path,                            /* char* */
    dps_query_item_hash_bucket_counts,
    dps_query_item_hash_levels,                     /* unsigned long* [dps_hash_level_counts][dps_hash_level_size] */

    dps_query_item_cache_counts,
    dps_query_item_cache_his_counts,                /* unsigned int64 */
    dps_query_item_cache_pool_size,
    dps_query_item_cache_pool_used_size,
    dps_query_item_cache_his_size,                  /* unsigned int64 */

    dps_query_item_cache_link_counts,
    dps_query_item_cache_pool_free_block_counts,
    dps_query_item_cache_pool_key_total_size,
    dps_query_item_cache_pool_data_valid_size,      /* unsigned int64 */
    dps_query_item_cache_pool_data_cached_size,
    dps_query_item_pool_defrag_times,

    dps_query_item_idx_total_size,                  /* unsigned int64 */
    dps_query_item_dat_total_size,                  /* unsigned int64 */
    dps_query_item_dat_file_no,

    dps_query_item_get_counts,
    dps_query_item_get_cache_hit_counts,
    dps_query_item_set_counts,
    dps_query_item_dat_defrag_counts,
    dps_query_item_dat_defrag_block_counts,
    dps_query_item_dat_defrag_auto
}_dps_query_item_type;

#define dps_flag_asyn_start_bit             0
#define dps_flag_asyn_bits                  1
#define dps_flag_asyn_get(flag)             ((flag) & (((1 << (dps_flag_asyn_bits)) - 1) << (dps_flag_asyn_start_bit)))

#define dps_flag_method_start_bit           (dps_flag_asyn_start_bit + dps_flag_asyn_bits)
#define dps_flag_method_bits                6
#define dps_flag_method_get(flag)           ((flag) & (((1 << (dps_flag_method_bits)) - 1) << (dps_flag_method_start_bit)))

/* dps flag, set:  flag |= dps_flag_*** | dps_flag***, or flag = dps_flag_**** | dps_flag_**** */
typedef enum dps_flag
{
    dps_flag_default                = 0,

    /* if dps_flag_default: dealwith it as dps_flag_asyn_disable */
    dps_flag_asyn_disable           = dps_flag_default,
    dps_flag_asyn_enable            = (1 << dps_flag_asyn_start_bit),

    /* dps flag for method, if dps_flag_default: same as dps_flag_method_force_write */
    dps_flag_method_force_write     = dps_flag_default,
    dps_flag_method_dis_overwrite   = (1 << dps_flag_method_start_bit),
    dps_flag_method_write_uflag_only = (2 << dps_flag_method_start_bit),

    dps_flag_method_append          = (3 << dps_flag_method_start_bit),
    dps_flag_method_calc_start      = dps_flag_method_append,
    dps_flag_method_insert          = (4 << dps_flag_method_start_bit),
    dps_flag_method_remove          = (5 << dps_flag_method_start_bit),
    
    dps_flag_method_add             = (6 << dps_flag_method_start_bit),
    dps_flag_method_sub             = (7 << dps_flag_method_start_bit),
    dps_flag_method_mul             = (8 << dps_flag_method_start_bit),
    dps_flag_method_div             = (9  << dps_flag_method_start_bit),
    dps_flag_method_shl             = (10  << dps_flag_method_start_bit), /* 10 */

    dps_flag_method_shr             = (11 << dps_flag_method_start_bit),
    dps_flag_method_abs             = (12 << dps_flag_method_start_bit),
    dps_flag_method_max             = (13 << dps_flag_method_start_bit),
    dps_flag_method_min             = (14 << dps_flag_method_start_bit),
    dps_flag_method_power           = (15 << dps_flag_method_start_bit),

    dps_flag_method_fadd            = (16 << dps_flag_method_start_bit),
    dps_flag_method_fsub            = (17 << dps_flag_method_start_bit),
    dps_flag_method_fmul            = (18 << dps_flag_method_start_bit),
    dps_flag_method_fdiv            = (19 << dps_flag_method_start_bit),
    dps_flag_method_fshl            = (20 << dps_flag_method_start_bit), /* 20 */

    dps_flag_method_fshr            = (21 << dps_flag_method_start_bit),
    dps_flag_method_fabs            = (22 << dps_flag_method_start_bit),
    dps_flag_method_facos           = (23 << dps_flag_method_start_bit),
    dps_flag_method_fsin            = (24 << dps_flag_method_start_bit),
    dps_flag_method_fatan           = (25 << dps_flag_method_start_bit),

    dps_flag_method_fatan2          = (26 << dps_flag_method_start_bit),
    dps_flag_method_fcos            = (27 << dps_flag_method_start_bit),
    dps_flag_method_fcosh           = (28 << dps_flag_method_start_bit),
    dps_flag_method_fexp            = (29 << dps_flag_method_start_bit),
    dps_flag_method_fmod            = (30 << dps_flag_method_start_bit), /* 30 */

    dps_flag_method_flog            = (31 << dps_flag_method_start_bit),
    dps_flag_method_flog10          = (32 << dps_flag_method_start_bit),
    dps_flag_method_fpow            = (33 << dps_flag_method_start_bit),
    dps_flag_method_fsinh           = (34 << dps_flag_method_start_bit),
    dps_flag_method_ftan            = (35 << dps_flag_method_start_bit),

    dps_flag_method_ftanh           = (36 << dps_flag_method_start_bit),
    dps_flag_method_fsqrt           = (37 << dps_flag_method_start_bit),
    dps_flag_method_overflow        = (38 << dps_flag_method_start_bit)
}_dps_flag;

#define dps_err_base                -1
#define dps_err_invalid_param       (dps_err_base - 0)
#define dps_err_not_support         (dps_err_base - 1)
#define dps_err_not_exist           (dps_err_base - 2)
#define dps_err_invalid_path        (dps_err_base - 3)
#define dps_err_inner_mem_broken    (dps_err_base - 4)
#define dps_err_set_cache_failed    (dps_err_base - 5)
#define dps_err_load_data_failed    (dps_err_base - 6)
#define dps_err_calc_failed         (dps_err_base - 7)
#define dps_err_prepare_buf_failed  (dps_err_base - 8)
#define dps_err_write_file_failed   (dps_err_base - 9)
#define dps_err_pointer_in_cache    (dps_err_base - 10)
#define dps_err_prepare_fpos_failed (dps_err_base - 11)
#define dps_err_data_too_large      (dps_err_base - 12)
#define dps_err_del_cache_failed    (dps_err_base - 13)
#define dps_err_save_data_failed    (dps_err_base - 14)
#define dps_err_save_index_failed   (dps_err_base - 15)
#define dps_err_unknown_handle      (dps_err_base - 16)
#define dps_err_flush_failed        (dps_err_base - 17)
#define dps_err_fetch_failed        (dps_err_base - 18)
#define dps_err_invalid_index       (dps_err_base - 19)

/*!?
func    dps_create
\brief  load depository from file. if file not exists build new empty one. 
\param  key_type[in]            the key type, just support "string"|"binary"|"int" now!
\param  path[in]                the directory.
\param  hash_bucket_counts[in]  the counts of the hash bucket
\param  cache_size[in]          the cache buffer size
\return the depository
        #NULL                   file, memory not enough or param valid.
        #other                  the depository
*/
struct depository *dps_create(char          *key_type/* string,binary,int */,
                              char          *path,
                              unsigned long hash_bucket_counts,
                              unsigned long cache_size);

/*!
func    dps_destroy
\brief  destroy depository
\param  tbl[in]                 the depository table
\return destroy result
        #0                      succeed
        #other                  error code
*/
long dps_destroy(struct depository* tbl);

/*!
func    dps_query
\brief  query depository refer info
\param  tbl[in]                 the depository table
\param  item[in]                the item, refer to dps_query_item
\param  value[out]              the value, plz take care of data type pointer, refer to dps_query_item
\return the result
        #0                      succeed
        #other                  error code
*/
long dps_query(struct depository *tbl, unsigned long item, void *value);

/*!
func    dps_ctrl
\brief  ctrl depository refer info
\param  tbl[in]                 the depository table
\param  item[in]                the item, refer to dps_query_item
\param  value[in]               the value, plz take care of data type pointer, refer to dps_query_item,
                                just support dps_query_item_dat_defrag_auto now
\return the result
        #0                      succeed
        #other                  error code
*/
long dps_ctrl(struct depository *tbl, unsigned long item, void *value);

/*!
func    dps_set
\brief  save a data into table, if exist old data will be replaced
\param  tbl[in]                 the storage table
\param  flag[in]                asynchronism, disable-overwrite ... etc.
                                see dps_flag_xxxx
\param  key[in]                 the key
\param  klen[in]                the length of the key
\param  data[in]                the data, if data_size not ZERO:can not be NULL
\param  dlen[in]                the length of the data, if 0 will delete
\param  uflag[in]               user flag, can used for distribution auto sync database,
                                just 32 bits valiable, other part will be pad ZERO
\param  data_last[out]          the last saved data if in cache, can be NULL, if NULL ignore
\param  dlen_last[out]          the last saved data length of the data, can be NULL, if NULL ignore
\param  out_flag[out]           the out-flag, can be NULL, if NULL ignore.
                                out-value 1: means key already exist
\return set result
        #0                      succeed
        #other                  error code
*/
long dps_set(struct depository  *tbl,       unsigned long   flag,
             void               *key,       unsigned long   klen,
             void               *data,      unsigned long   dlen,
             void               **data_last, unsigned long  *dlen_last,
             unsigned long      *out_flag);
long dps_set_ex(struct depository  *tbl,       unsigned long   flag,
             void               *key,       unsigned long   klen,
             void               *data,      unsigned long   dlen,
             unsigned long      uflag,
             void               **data_last, unsigned long  *dlen_last,
             unsigned long      *out_flag);


/*!
func    dps_get
\brief  get a data with key from table, if in cache update to newest position
\param  tbl[in]                 the storage table
\param  flag[in]                asynchronism etc. see dps_flag_xxxx
\param  key[in]                 the key
\param  klen[in]                the length of the key
\param  data[out]               the data, if have not data or not in cache will out NULL
\param  dlen[out]               the length of the data
\param  uflag[out]              user flag, can used for distribution auto sync database
                                just 32 bits valiable, other part will be pad ZERO
\return get result
        #0                      succeed
        #other                  error code
*/
long dps_get(struct depository  *tbl, unsigned long     flag,
             void               *key, unsigned long     klen,
             void               **data, unsigned long   *dlen);
long dps_get_ex(struct depository  *tbl, unsigned long     flag,
             void               *key, unsigned long     klen,
             void               **data, unsigned long   *dlen,
             unsigned long      *uflag);

/*!
func    dps_fetch_open
\brief  open the a fetch from depository, if fetch-list full will destroy oldest one
\param  tbl[in]                 the storage table
\return the fetch handle, will be save in disk and still valid after reboot.
        #<0                     error code
        #other                  fetch handle
*/
long dps_fetch_open(struct depository *tbl);

/*!
func    dps_fetch_close
\brief  close the fetch object
\param  tbl[in]                 the storage table
\param  handle[in]              the handle
\return the fetch handle
        #<0                     error code
        #other                  fetch handle
*/
long dps_fetch_close(struct depository *tbl, long handle);

/*!
func    dps_fetch
\brief  fetch depository record
\param  tbl[in]                 the storage table
\param  handle[in]              the fetch handle
\param  flag[in]                asynchronism etc. see dps_flag_xxxx
\param  key[out]                the key
\param  klen[out]               the length of the key
\param  data[out]               the data, if have not data or not in cache will out NULL
\param  dlen[out]               the length of the data
\param  uflag[out]              user flag, can used for distribution auto sync database
                                just 32 bits valiable, other part will be pad ZERO
\return fetch result
        #0                      get valid record
        #1(>0)                  fetch finished
        #other                  error code
*/
long dps_fetch(struct depository    *tbl,   long            handle, unsigned long flag,
               void                 **key,  unsigned long   *klen,
               void                 **data, unsigned long   *dlen);
long dps_fetch_ex(struct depository    *tbl,   long            handle, unsigned long flag,
               void                 **key,  unsigned long   *klen,
               void                 **data, unsigned long   *dlen,
               unsigned long        *uflag);

/*!
func    dps_check
\brief  check depository data is correct
\param  tbl[in]                 the storage table
\param  file[in]                the file name
\param  line[in]                line
\return check result
        #0                      succeed
        #other                  data error
*/
long dps_check(struct depository *tbl, char *file, int line);
#define dps_do_check(tbl) dps_check(tbl, __FILE__, __LINE__)

/*!
func    dps_save
\brief  flush data to disk
\param  tbl[in]                 the storage table
\return flush result
        #0                      succeed
        #other                  error code
*/
long dps_save(struct depository *tbl);

/*!
func    dps_defrag
\brief  defrag data
\param  tbl[in]                 the storage table
\param  defrag_size[in]         defrage data size
\return flush result
        #1                      finished
        #0                      succeed
        #<0                     error code
*/
long dps_defrag(struct depository *tbl, unsigned long defrag_size);

/*!
func    dps_get_string_hash_value
\brief  calculate 32bits string hash value for level, ignore case,
        can used to ds diliver by key hash
\param  init_value[in]          init value
\param  key[in]                 the key
\param  klen[in]                the length of the key
\return the hash value(32 bits)
*/
unsigned long dps_get_string_hash_value(unsigned long init_value, void *data, unsigned long len);

/*!
func    dps_bucket_calc_for_level
\brief  Calculate bucket id for levle
\param  key[in]                 the key
\param  klen[in]                the length of the key
\param  levle[in]               level
\return the bucket id
*/
unsigned long dps_bucket_calc_for_level(void *key, unsigned long klen, unsigned long level );

unsigned long dps_get_max_bit(unsigned long value /* NON-ZERO */);/* return max bit index */
unsigned long dps_dump_static(struct depository *tbl );

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__depository_h__) */
