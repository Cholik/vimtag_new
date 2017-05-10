/*!
\file       share_memory.h
\brief      the share memory unit
            if linux plz define precompile macro _LINUX,
            else if windows plz define precompile macro WIN32

 ----history----
\author     chengzhiyong 
\date       2007-01-17
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: share_memory.h,v 1.2 2007-12-07 17:59:58 chengzhiyong Exp $
*/
#if !defined(__share_memory_h__)
#define __share_memory_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/*!
func    shm_create
\brief  create share-memory
\param  key[in]                 the key of the share-memory, identify value, can be NULL
\param  size[in]                the size of the share-memory
\param  is_create_here[out]     is create here, if NULL ignore
\return create result
        #NULL                   failed
        #other                  the pointer of the share memory
*/
void* shm_create(char *key, unsigned long size, unsigned long *is_create_here);

/*!
func    shm_destroy
\brief  destory share-memory, if multi times open will be destroy
        really when the last shm_destroy() be called
\param  addr[in]                the addr return by shm_create()
\return destroy result
        #0                      succeed
        #other                  error code
*/
long shm_destroy(void* addr); 


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__share_memory_h__) */
