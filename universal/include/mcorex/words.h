/*!
\file       words.h
\brief      words unit, compatible ipc(share-memory);
            words tree and table in buf, this buffer will be init to both support memory
            and share memory, the node not use absolute pointer address , will node
            address use relative address
            can used to IPC, share data with different process

 ----history----
\author     chengzhiyong 
\date       2007-01-27
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: words.h,v 1.4 2008-05-31 05:32:39 chengzhiyong Exp $
*/
#if !defined(__words_h__)
#define __words_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct wrd_map;

/*! 
func    wrd_build_map
\brief  build word map
\param  map[in]                 the map object
\param  size[in]                the map size
\return init result
        #0                      succeed
        #<0                     error code
\return the map size
 */
long wrd_build_map(struct wrd_map *map, unsigned long size);

/*! 
func    wrd_create
\brief  create words table, if special dict, will wrd_load() it.
\param  size[in]                the map size
\param  base_dic[in]            the base dict file, can be NULL
\param  user_dic[in]            the user dict file, will be changed when add words, can be NULL
\return create result
        #0                      succeed
        #<0                     error code
*/
struct wrd_map *wrd_create(unsigned long size, char *base_dic, char *user_dic);

/*! 
func    wrd_destroy
\brief  destroy words table
\param  map[in]                 the words map
\return destroy result
        #0                      succeed
        #<0                     error code
 */
long wrd_destroy(struct wrd_map *map);

/*! 
func    wrd_load
\brief  load words from dict file
\param  size[in]                the map size
\param  file[in]                the file name
\param  enable_saved[in]        is enabled save into this file.
\return load result
        #0                      succeed
        #<0                     error code
 */
long wrd_load(struct wrd_map *map, char *file, unsigned long enable_saved);

/*!
func    wrd_add
\brief  add a world into table
\param  map[in]                 the words map
\param  word[in]                the word data
\param  len[in]                 the word len
\return result
        #0                      succeed
        #other                  error code
*/
long wrd_add(struct wrd_map *map, unsigned char *word, unsigned long len);

/*!
func    wrd_get
\brief  get matched words from string
\param  map[in]                 the words map
\param  str[in]                 the string try to split
\param  len[in]                 the sentence length
\param  max_counts[in]          the max counts
\param  len_list[out]           the matched word's len list
\return word counts
        #<0                     error code
        #other                  matched words count
*/
long wrd_get(struct wrd_map *map,
             unsigned char  *str,
             unsigned long  len,
             unsigned long  max_counts,
             unsigned long  *len_list);

/*!
func    wrd_fetch
\brief  get matched part words from string
\param  map[in]                 the words map
\param  str[in]                 the string try to fetch
\param  len[in]                 the word length
\param  max_counts[in]          the max words counts
\param  buf_size[in]            the buffer size
\param  buf[out]                the data buffer to save string
\param  word_list[out]          the string start pointer list
\param  len_list[out]           the matched word's len list
\return word counts
        #<0                     error code
        #other                  matched words count
*/
long wrd_fetch( struct wrd_map  *map,
                unsigned char   *str,
                unsigned long   len,
                unsigned long   max_counts,
                unsigned long   buf_size,
                unsigned char   *buf,
                unsigned char   **word_list,
                unsigned long   *len_list);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__words_h__) */
