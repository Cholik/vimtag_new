/*!
\file       increase_buffer.h
\brief      increase buffer unit, can used to dynamic increase memory needing
			for small memory block. such as xml parse, depository...
			extract from depository unit(block_list).

 ----history----
\author     chengzhiyong
\date       2007-09-24
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: increase_buffer.h,v 1.2 2008-05-31 05:32:39 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__increase_buffer_h__)
#define __increase_buffer_h__

struct ibuffer;

/*! \brief ibuf_pos_t, if need support memory over 4G, plz define this to unsigned int64 */
typedef unsigned long ibuf_pos;

/*!
func    ibuf_get_size
\brief  get increate buffer size now
\param  ibuf[in]                the increase buffer
\return the size
        #<0                     error code
        #other                  the increase buffer size
*/
ibuf_pos ibuf_get_size(struct ibuffer *buf);

/*!
func    ibuf_create
\brief  create increase buffer
\param  init_size[in]           init block size in buffer list.
\return create result
        #NULL                   failed
        #other                  increase buffer
*/
struct ibuffer* ibuf_create(unsigned long init_size);

/*!
func    ibuf_load
\brief  load increase buffer data from file, return file size
\param  file[in]                the file name
\return load result
        #NULL                   failed
        #other                  increase buffer
*/
struct ibuffer* ibuf_load(char *file);

/*!
func    ibuf_save
\brief  save increase buffer data into file
\param  ibuf[in]                the increase buffer
\param  file[in]                the file name
\return save result
        #0                      succeed
        #other                  error code
*/
long ibuf_save(struct ibuffer *buf, char *file);

/*!
func    ibuf_destroy
\brief  destory increase buffer
\param  ibuf[in]                the increase buffer
\return destroy result
        #0                      succeed
        #other                  error code
*/
long ibuf_destroy(struct ibuffer *ibuf);

/*!
func    ibuf_get_pointer
\brief  get pointer by position from increase buffer
\param  ibuf[in]                the increase buffer
\param  pos[in]                 the position
\param  max_size[out]           the max size of this position,
                                if NULL will ignore
\return the pointer
        #NULL                   invalid position
        #other                  the pointer
*/
void *ibuf_get_pointer(struct ibuffer *ibuf, ibuf_pos pos, unsigned long *max_size);

/*!
func    ibuf_alloc
\brief  alloc space from increase buffer
\param  ibuf[in]                the increase buffer
\param  size[in]                the size
\param  pos[out]                output this buffer start pointer, if NULL, ignore
\return the pointer
        #NULL                   failed.
        #other                  the buffer start pointer
*/
void *ibuf_alloc(struct ibuffer *ibuf, unsigned long size, ibuf_pos *pos);

#endif /* !defined(__increase_buffer_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

