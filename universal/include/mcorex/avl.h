/*
\file       avl.h
\brief      avl unit, compatible ipc(share-memory)
            avl tree and table in buf, this buffer will be init to both support memory
            and share memory, the node not use absolute pointer address , will node
            address use relative address
            can used to IPC, share data with different process

 ----history----
\author     chengzhiyong 
\date       2007-01-27
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: avl.h,v 1.2 2008-05-31 05:32:39 chengzhiyong Exp $
*/
#if !defined(__avl_h__)
#define __avl_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct avl_map;
struct avl_table;

/*! \brief compare key route */
typedef long (*avl_compare)(void* key, void* key_in_map);

/*! \brief avl list */
typedef struct avl_list
{
    unsigned long   counts;     /*!< total counts */
    struct
    {
        void*       key;        /*!< key */
        void*       data;       /*!< data */
    }data[1];               /*!< data, the reals size is not 1, real size is the counts */
}_avl_list;

/*! 
func    avl_sizeof_map
\brief  get size of map with max tree counts and max node counts
\param  max_trees[in]           the max tree counts
\param  max_nodes[in]           the max node counts
\return the map size
 */
unsigned long avl_sizeof_map(unsigned long max_trees, unsigned long max_nodes);

/*! 
func    avl_create
\brief  create avl table
\param  map[in]                 the avl map, buffer size should be avl_sizeof_table()
                                if NULL will create new one.
\param  rebuild_map[in]         is need rebuild map, this should be false when load from pre
                                inited sharememory, else should be true
\param  compare[in]             the compare call-back routine, this value can be NULL
                                when key is unsigned type
\param  bucket_counts[in]       the table map bucket counts
\param  max_counts[in]          the max nodes count
\param  key_base_addr[in]       the key refer buffer start address in current process,
                                this param just used for pointer data need share with other process
                                so if key is a unsigned value, this param should be NULL.
                                if not NULL, when add data to tree, key<saved> will be convert (key - key_base_addr),
                                and when compare() will be call with (key<saved> + key_base_addr)
\param  data_base_addr[in]      the data refer buffer start address in current process,
                                this param just used for pointer data need share with other process
                                so if data is a unsigned value, this param should be NULL.
                                if not NULL, when add data to tree, data<saved> will be convert (data - data_base_addr),
                                and when compare() will be call with (data<saved> + data_base_addr)
\return avl table
        #NULL                   failed
        #other                  the avl table
\return the map size
 */
struct avl_table *avl_create(struct avl_map      *map,
                             unsigned long       rebuild_map,
                             avl_compare         compare,
                             unsigned long       bucket_counts,
                             unsigned long       max_counts,
                             void                *key_base_addr,
                             void                *data_base_addr);


/*!
func    avl_destroy
\brief  destory avl table
\param  tbl[in]                 the table
\return destroy result
        #0                      succeed
        #other                  error code
*/
long avl_destroy(struct avl_table *tbl);

/*!
func    avl_add
\brief  add node into special tree
\param  tbl[in]                 the table
\param  handle[in]              the handle return by avl_create()
\param  key[in]                 the key
\param  data[in]                the data
\return add result
        #0                      succeed
        #other                  error code
*/
long avl_add(struct avl_table *tbl, unsigned long handle, void *key, void *data);

/*!
func    avl_get
\brief  get only on matched node from special tree with condition key
\param  tbl[in]                 the table
\param  handle[in]              the handle return by avl_create()
\param  key[in]                 the key
\param  data[out]               the data
\return get the only one matched result
        #0                      succeed
        #other                  error code
*/
long avl_get(struct avl_table *tbl, unsigned long handle, void *key, void **data);

/*!
func    avl_export
\brief  export all data from a list with special handle
\param  tbl[in]                 the table
\param  handle[in]              the handle return by avl_create()
\param  max_counts[in]          the max counts
\param  data_list[out]          the list used to save output data
\return export
        #0                      succeed
        #other                  error code
*/
long avl_export(struct avl_table*   tbl, 
                unsigned long       handle,
                unsigned long       max_counts,
                struct avl_list*    data_list);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__avl_h__) */
