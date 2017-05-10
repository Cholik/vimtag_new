/*!
\file       mqsort_ex.h
\brief      mqsort_ex unit, same function with C-LIB mqsort, just add a refer param

 ----history----
\author     chengzhiyong 
\date       2008-01-10
\version    0.01
\desc       create

$Author: xieyong $
$Id: mqsort_ex.h,v 1.5 2008-04-01 09:24:27 xieyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__mqsort_ex_h__)
#define __mqsort_ex_h__

/*!
func    mqsort_ex_get_hash_value
\brief  mqsort get hash value
\param  item[in]                the start pointer of the item
\param  refer[in]               the refer data
\return hash value */
typedef unsigned long (*mqsort_ex_get_hash_value)(void *item, void *refer);

/*!
func    mqsort_ex_comp
\brief  mqsort compare routine
\param  item1[in]               the start pointer of the item1
\param  item1[in]               the start pointer of the item2
\param  refer[in]               the refer data
\return compare result
        #0                      same
        #>0                     item1 > item2
        #<0                     item1 < item2 */
typedef long (*mqsort_ex_comp)(void *item1, void *item2, void *refer);

/*!
func    mqsort_ex
\brief  mqsort, function same as mqsort in clib, just have more param named refer
\param  data[in/out]            the data array
\param  counts[in]              the item counts in data array
\param  item_size[in]           the size of the item
\param  comp[in]                the compare function pointer,can be NULL,
                                #NULL size:  1,2,4,8, compare as char/short/int/int64
                                      other: compare as binary data, same as memcmp
\param  refer[in]               the refer data 
\return void */
void mqsort_ex(void *data, unsigned long counts, unsigned long item_size, mqsort_ex_comp comp, void *refer);

/*!
func    mqsort_ex_pos
\brief  get item position index
\param  data[in/out]            the data array
\param  counts[in]              the item counts in data array
\param  item_size[in]           the size of the item
\param  item[in]                the item
\param  exist[out]              is exist the special item in list
\param  comp[in]                the compare function pointer,can be NULL,
                                #NULL size:  1,2,4,8, compare as char/short/int/int64
                                      other: compare as binary data, same as memcmp
\param  refer[in]               the refer data 
\return position index
        #<0                     error code
        #>=0                    position index, maybe not exist, should check item is same or not. */
long mqsort_ex_pos(void *data, unsigned long counts, unsigned long item_size, void *item, long *exist, mqsort_ex_comp comp, void *refer);

/*!
func    mqsort_ex_add
\brief  add item into ordered list
\param  data[in/out]            the data array
\param  counts[in]              the item counts in data array
\param  item_size[in]           the size of the item
\param  item[in]                the item
\param  exist[out]              is exist the special item in list
\param  comp[in]                the compare function pointer,can be NULL,
                                #NULL size:  1,2,4,8, compare as char/short/int/int64
                                      other: compare as binary data, same as memcmp
\param  refer[in]               the refer data 
\return position index
        #<0                     error code
        #>=0                    position index */
long mqsort_ex_add(void *data, unsigned long counts, unsigned long item_size, void *item, long *exist, mqsort_ex_comp comp, void *refer);

/*!
func    mqsort_ex_del
\brief  del item from ordered list
\param  data[in/out]            the data array
\param  counts[in]              the item counts in data array
\param  item_size[in]           the size of the item
\param  item[in]                the item
\param  exist[in]               is exist the special item
\param  comp[in]                the compare function pointer,can be NULL,
                                #NULL size:  1,2,4,8, compare as char/short/int/int64
                                      other: compare as binary data, same as memcmp
\param  refer[in]               the refer data 
\return position index
        #<0                     error code
        #>=0                    position index */
long mqsort_ex_del(void *data, unsigned long counts, unsigned long item_size, void *item, long *exist, mqsort_ex_comp comp, void *refer);

/*!
func    mqsort_ex_merge_and
\brief  merge two data lists with and operation
\param  data1[in]               the data1 array
\param  data1_counts[in]        the counts of the data1
\param  data2[in]               the data2 array 
\param  data2_counts[in]        the counts of the data2
\param  item_size[in]           the size of the item
\param  get_hash_value[in]      the call back routine to get hash value, can be NULL
                                if NULL dealwith as binary data 
\param  comp[in]                the call back routine to compare item,
                                if NULL will compare as memcmp
\param  refer[in]               the refer data, can be NULL
\param  ret_pointer[out]        the result, return matched items' pointer list
                                if NULL will ignore
\param  ret_data[out]           the data result, return matched items' data list,
                                if NULL will ignore
\return the total matched counts
        #<0                     error code
        #>=0                    total matched counts */
long mqsort_ex_merge_and(void                    *data1,
                         unsigned long           data1_counts,
                         void                    *data2,
                         unsigned long           data2_counts,
                         unsigned long           item_size,
                         mqsort_ex_get_hash_value get_hash_value,
                         mqsort_ex_comp           comp,
                         void                    *refer,
                         void                    **ret_pointer,
                         void                    *ret_data);

long mqsort_ex_merge_xor(void                    *data1,
                         unsigned long           data1_counts,
                         void                    *data2,
                         unsigned long           data2_counts,
                         unsigned long           item_size,
                         mqsort_ex_get_hash_value get_hash_value,
                         mqsort_ex_comp           comp,
                         void                    *refer,
                         void                    **ret_1sub2_pointer,
                         void                    *ret_1sub2_data,
                         unsigned long           *ret_1sub2_data_counts,
                         void                    **ret_2sub1_pointer,
                         void                    *ret_2sub1_data,
                         unsigned long           *ret_2sub1_data_counts );

/*!
func    mqsort_ex_merge_multi_and
\brief  merge multi(can more than 2) lists with and operation
\param  data_list[in]           the data list array
\param  item_counts_list[in]    the data item counts list array
\param  data_list_counts[in]    the counts of the data list     
\param  item_size[in]           the size of the item
\param  get_hash_value[in]      the call back routine to get hash value, can be NULL,
                                if NULL dealwith as binary data 
\param  comp[in]                the call back routine to compare item,
                                if NULL will compare as memcmp
\param  refer[in]               the refer data, can be NULL
\param  ret_pointer[out]        the result, return matched items' pointer list
                                if NULL will ignore
\param  ret_data[out]           the data result, return matched items' data list,
                                if NULL will ignore
\return the total matched counts
        #<0                     error code
        #>=0                    total matched counts */
long mqsort_ex_merge_multi_and( void                    **data_list,
                                unsigned long           *item_counts_list,
                                unsigned long           data_list_counts,
                                unsigned long           item_size,
                                mqsort_ex_get_hash_value get_hash_value,
                                mqsort_ex_comp           comp,
                                void                    *refer,
                                void                    **ret_pointer,
                                void                    *ret_data);

/*!
func    mqsort_ex_merge_multi_or
\brief  merge multi(can more than 2) lists with or operation
\param  data_list[in]           the data list array
\param  item_counts_list[in]    the data item counts list array
\param  data_list_counts[in]    the counts of the data list     
\param  item_size[in]           the size of the item
\param  get_hash_value[in]      the call back routine to get hash value, can be NULL
                                if NULL dealwith as binary data 
\param  comp[in]                the call back routine to compare item,
                                if NULL will compare as memcmp
\param  refer[in]               the refer data, can be NULL
\param  ret_pointer[out]        the result, return matched items' pointer list
                                if NULL will ignore
\param  ret_data[out]           the data result, return matched items' data list,
                                if NULL will ignore
\return the total matched counts
        #<0                     error code
        #>=0                    total matched counts */
long mqsort_ex_merge_multi_or(  void                    **data_list,
                                unsigned long           *item_counts_list,
                                unsigned long           data_list_counts,
                                unsigned long           item_size,
                                mqsort_ex_get_hash_value get_hash_value,
                                mqsort_ex_comp           comp,
                                void                    *refer,
                                void                    **ret_pointer,
                                void                    *ret_data);

/*!
func    mqsort_ex_counts
\brief  statistic items' counts
\param  data[in]                the data array
\param  counts[in]              the counts of the data
\param  item_size[in]           the size of the item
\param  get_hash_value[in]      the call back routine to get hash value, can be NULL
                                if NULL dealwith as binary data 
\param  comp[in]                the call back routine to compare item,
                                if NULL will compare as memcmp
\param  refer[in]               the refer data, can be NULL
\param  ret_pointer[out]        the result, return matched items' pointer list
                                if NULL will ignore
                                !!!!(ret_pointer and ret data at least have one is not NULL)
\param  ret_data[out]           the data result, return matched items' data list,
                                if NULL will ignore
                                !!!!(ret_pointer and ret data at least have one is not NULL)
\param  ret_grp_counts[out]     the grouped counts of items
\return the total result counts
        #<0                     error code
        #>=0                    total matched counts */
long mqsort_ex_counts(void                       *data,
                      unsigned long              counts,
                      unsigned long              item_size,
                      mqsort_ex_get_hash_value    get_hash_value,
                      mqsort_ex_comp              comp,
                      void                       *refer,
                      void                       **ret_pointer,
                      void                       *ret_data,
                      unsigned long              *ret_grp_counts);

#endif /* !defined(__mqsort_ex_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
