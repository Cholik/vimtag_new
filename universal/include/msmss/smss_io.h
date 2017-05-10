/*!
\file       smss_io.h
\brief     

 ----history----
\author     Liuzp
\date       2014-02-27
\version    0.01
\desc       create

*/

#if !defined(__smss_io_h__)
#define __smss_io_h__
    
#if defined(__cplusplus)
    extern "C" {
#endif/* defined(__cplusplus) */

struct smss__stor_dev;

typedef enum smss__cache_seek_type{
    smss__cache_seek_set,  /*!< Move the cursor to a absolute pos */
    smss__cache_seek_cur,  /*!< Move the cursor for <offset> base the current pos */
}_smss__cache_seek_type;

typedef enum smss__cache_type{
    smss__cache_r,  /*!< Just a memory copy of the storage */
    smss__cache_w,  /*!< Flush all the space before the current cursor */
    smss__cache_rw  /*!< Be carefull!!! this kind of cache will be flush totally even if only  
                                      *     very little of its data are modified */
}_smss__cache_type;

typedef struct smss__dirty_area
{
    ulong head, tail;
}_smss__dirty_area;

typedef struct smss__cache{
    enum smss__cache_type  cache_type;
    ulong  cache_len;      /*!< cache length  */
    uchar*  addr;          /*!< the cache mem address */

    ulong data_len;            /*!< cached data len for readable cache */
    ullong base_pos_in_stor;   /*!< Position in the storage, start from 0 */

    ulong  cursor;         /*!< the current read and write offset in the cache  */
    uchar  waiting_flush;  /*!< Some of the data are writed, if 0, the head and tail are not inited */
    uchar  resv[3];
    struct 
    {
        ulong head;       /*!< The head of wrote area */        
        ulong tail;       /*!< The tail of the wrote area */
    } dirty_area;
#define dirty_head   dirty_area.head
#define dirty_tail   dirty_area.tail
}_smss__cache;

#define smss__cache_format_s "%p{cache_type[%lu], cache_len[%lu], addr[%p], data_len[%lu], base_pos_in_stor["u64_format_s"],"\
                             "cursor[%lu], waiting_flush[%lu], dirty_area[{head[%lu], tai[%lu]}]}"
#define smss__cache_format(_cache) (_cache),\
                                   (ulong)((_cache)? (_cache)->cache_type : 0),\
                                   (_cache)? (_cache)->cache_len : 0,\
                                   (_cache)? (_cache)->addr : 0,\
                                   (_cache)? (_cache)->data_len : 0,\
                                   (_cache)? (_cache)->base_pos_in_stor : 0,\
                                   (ulong)((_cache)? (_cache)->cursor : 0),\
                                   (ulong)((_cache)? (_cache)->waiting_flush : 0),\
                                   (_cache)? (_cache)->dirty_area.head : 0,\
                                   (_cache)? (_cache)->dirty_area.tail : 0

struct smss__cache* smss__cache_create(
    struct smss__stor_dev* dev, 
    enum smss__cache_type type, 
    ulong len,
    ullong pos_in_stor
    );
long smss__cache_destroy(
    struct smss__stor_dev* dev,
    struct smss__cache* cache
    );
ulong smss__io_read(
    struct smss__stor_dev* dev,
    ullong pos,
    ullong size,
    void*  buffer
    );
long smss__io_write(
    struct smss__stor_dev* dev, 
    ullong pos,
    ullong size, 
    void *data
    );
long smss__cache_flush(
    struct smss__stor_dev* dev, 
    struct smss__cache* cache
    );
long smss__cache_stream_write(
    struct smss__stor_dev* dev, 
    struct smss__cache* cache,
    ulong size, 
    void *data
    );
ulong smss__cache_stream_read(
    struct smss__stor_dev* dev, 
    struct smss__cache* cache,
    ulong size, 
    void* pbuff
    );
long smss__cache_seek(
    struct smss__stor_dev* dev, 
    struct smss__cache* cache,
    ullong offset, /*!< offset in store */   
    enum smss__cache_seek_type type
    );
long smss__cache_cance(
    struct smss__stor_dev* dev, 
    struct smss__cache* cache
    );

#if defined(__cplusplus)
    }
#endif/* defined(__cplusplus) */

#endif  /*!> __smss_io_h__*/

