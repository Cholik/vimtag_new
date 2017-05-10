/*!
\file       mbuffer.h
\brief      the buffer unit, compatible ipc(share-memory)
            managment smaller relative address block in large buffer,
            can use this unit to share memory or normal memory alloc/free
            and this buffer is a sample quee[get first block]/stack[get last block]

 ----history----
\author     chengzhiyong 
\date       2007-01-30
\version    0.01
\desc       create

\author     chengzhiyong
\date       2014-06-08
\version    0.02
\desc       rename buf to mbuf

*/
#if !defined(__mbuffer_h__)
#define __mbuffer_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct mbuffer;

/*!
func    mbuf_defrag_event
\brief  defrag event, when defrag action raise, will callback 
        after callback, block will be move to new_data/new_handle position
        so, before moved, user can do some action to change let user level's data
\param  buf[in]                 the buffer
\param  data[in/out]            data, use can change this data by self
\param  handle[in]              the old handle
\param  new_data[in]            don't change any data in here!!!!!!, just tell user
                                will be the new position
\param  new_handle[in]          the new handle
\param  refer[in]               the user data input when call mbuf_defrag
\return void*/
typedef void (*mbuf_defrag_event)(struct mbuffer *buf, void *data/* [in/out] */, unsigned long handle, void *new_data, unsigned long new_handle, void *refer);

#define mbuf_query_item_free_size    0   /* out value is (unsigned) */
#define mbuf_query_item_used_size    1   /* out value is (unsigned) */
#define mbuf_query_item_size         2   /* out value is (unsigned) */
#define mbuf_query_item_used_counts  3   /* out value is (unsigned) */
#define mbuf_query_item_free_counts  4   /* out value is (unsigned) */
/*!
func    mbuf_query
\brief  query information
\param  buf[in]                 the buffer
\param  item[in]                the item
\param  item_buf_size[in]       the item buffer size
\param  item_buf[out]           the item buffer
\return the size
        #>0                     buffer size
        #other                  error code
*/
long mbuf_query(struct mbuffer *buf, unsigned long item, unsigned long item_buf_size, void *item_buf);

/*!
func    mbuf_init
\brief  init buffer
\param  buf[in]                 the buffer start pointer
\param  size[in]                the size of the buf
\return create result
        #0                      succeed
        #other                  error code
*/
long mbuf_init(struct mbuffer *buf, unsigned long size);

/*!
func    mbuf_alloc
\brief  alloc a block from buffer
\param  buf[in]                 the buffer return by mbuf_create()
\param  size[in]                the size of the memory block
\param  handle[out]             the handle of the block, pointer == mbuf_get_pointer(handle)
                                if null will be ignore, you can get handle by mbuf_get_handle(pointer)
\return the pointer
        #NULL                   failed
        #other                  the pointer of the memory
*/
void *mbuf_alloc(struct mbuffer *buf, unsigned long size, unsigned long *handle);

/*!
func    mbuf_realloc
\brief  realloc a block from buffer
\param  buf[in]                 the buffer return by mbuf_create()
\param  pointer[in]             the pointer
\param  size[in]                the size of the memory block
\return realloc result
        #0                      succeed
        #other                  error code
*/
long mbuf_realloc(struct mbuffer *buf, void* pointer, unsigned long size);

/*!
func    mbuf_alloc
\brief  alloc a max-size block from buffer
\param  buf[in]                 the buffer return by mbuf_create()
\\param  size[out]               the size of the memory block
\param  handle[out]             the handle of the block, pointer == mbuf_get_pointer(handle)
                                if null will be ignore, you can get handle by mbuf_get_handle(pointer)
\return the pointer
        #NULL                   failed
        #other                  the pointer of the memory
*/
void *mbuf_alloc_max(struct mbuffer *buf, unsigned long *size, unsigned long *handle);

/*!
func    mbuf_free
\brief  free the special block
\param  buf[in]                 the buffer return by mbuf_create()
\param  pointer[in]             the pointer will be free, it's return by mbuf_alloc()
\return free result
        #0                      succeed
        #other                  the error code
*/
long mbuf_free(struct mbuffer *buf, void *pointer);

/*!
func    mbuf_get_handle
\brief  get block handle by the pointer
\param  buf[in]                 the buffer return by mbuf_create()
\paramm pointer[in]             the pointer in this process, it's return by mbuf_get_pointer() or mbuf_alloc()
\return the handle
        #0                      convert failed
        #other                  the block handle ref the pointer
*/
unsigned long mbuf_get_handle(struct mbuffer *buf, void *pointer);

/*!
func    mbuf_get_pointer
\brief  get the pointer by block handle
\param  buf[in]                 the buffer return by mbuf_create()
\param  handle[in]              the block handle, it's return by mbuf_alloc() or mbuf_get_handle()
\param  size[out]               the size of the block be alloced, if NULL will be ignore
\return the pointer
        #NULL                   convert failed
        #other                  the pointer in current process
*/
void *mbuf_get_pointer(struct mbuffer *buf, unsigned long handle, unsigned long *size);

/*!
func    mbuf_get_first_block
\brief  get first block
\param  buf[in]                 the buffer return by mbuf_create()
\param  handle[out]             the handle of the block, pointer == mbuf_get_pointer(handle)
                                if null will be ignore, you can get handle by mbuf_get_handle(pointer)
\param  size[out]               the size of the block be alloced, if NULL will be ignore
\return the pointer
        #NULL                   convert failed
        #other                  the pointer in current process
*/
void *mbuf_get_first_block(struct mbuffer *buf, unsigned long *handle, unsigned long *size);

/*!
func    mbuf_get_last_block
\brief  get last block
\param  buf[in]                 the buffer return by mbuf_create()
\param  handle[out]             the handle of the block, pointer == mbuf_get_pointer(handle)
                                if null will be ignore, you can get handle by mbuf_get_handle(pointer)
\param  size[out]               the size of the block be alloced, if NULL will be ignore
\return the pointer
        #NULL                   convert failed
        #other                  the pointer in current process
*/
void *mbuf_get_last_block(struct mbuffer *buf, unsigned long *handle, unsigned long *size);

/*!
func    mbuf_get_key_block
\brief  get key block
\param  buf[in]                 the buffer return by mbuf_create()
\param  handle[out]             the handle of the block, pointer == mbuf_get_pointer(handle)
                                if null will be ignore, you can get handle by mbuf_get_handle(pointer)
\param  size[out]               the size of the block be alloced, if NULL will be ignore
\return the pointer
        #NULL                   convert failed
        #other                  the pointer in current process
*/
void *mbuf_get_key_block(struct mbuffer *buf, unsigned long *handle, unsigned long *size);

/*!
func    mbuf_set_key_block
\brief  set key block
\param  buf[in]                 the buffer return by mbuf_create()
\param  handle[out]             the handle of the block wannt to set as key block
\return set result
        #0                      succeed
        #other                  error code
*/
long mbuf_set_key_block(struct mbuffer *buf, unsigned long handle);

/*!
func    mbuf_defrag
\brief  defrag buffer, if special defrag_event will raise defrag event
\param  buf[in]                 the buffer
\param  defrag_event[in]        the defrag event. can be NULL, if NULL ignore
\param  refer[in]               the user data refer to defrag, can be NULL, if NULL ignore
\return void*/
long    mbuf_defrag(struct mbuffer *buf, mbuf_defrag_event defrag_event, void *refer);

/*!
func    mbuf_check
\brief  check buffer data is correct
\param  tbl[in]                 the storage table
\param  file[in]                the file name
\param  line[in]                line
\return check result
        #0                      succeed
        #other                  data error
*/
long mbuf_check(struct mbuffer *buf, char *file, int line);
#define mbuf_do_check(tbl) mbuf_check(tbl, __FILE__, __LINE__)


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mbuffer_h__) */
