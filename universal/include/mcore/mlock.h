/*
\file       mlock.h
\brief      lock unit

 ----history----
\author     chengzhiyong 
\date       2007-01-30
\version    0.01
\desc       create

\author     chengzhiyong 
\date       2014-06-08
\version    0.02
\desc       rename lock_xxx to mlock_xxx
*/

#if !defined(__mlock_h__)
#define __mlock_h__

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(_WIN32) /* windows */
#   include <windows.h>
#elif defined(__ucos__)
#else /* linux  */
#   include <pthread.h>
#endif

/* just for multi thread, but not multi process */
/* #define mlock_simple_disable 1 */
#if !defined(mlock_simple_disable)
#   if defined(mlock_disable) && mlock_disable /* single thread, don't need lock */
#       define mlock_simple                    void*
#       define mlock_simple_init(_lock)      
#       define mlock_simple_uninit(_lock)    
#       define mlock_simple_wait(_lock)      
#       define mlock_simple_release(_lock)   
#   else/* just for multi thread, but not multi process */
#       if defined(_WIN32)                     /*!< windows */
            typedef struct mlock_simple_obj
            {
#           ifdef WINCE
                CRITICAL_SECTION        data;
#           else
                RTL_CRITICAL_SECTION    data;
#endif    
                char                    *file;
                long                    line;
            }_mlock_simple_obj;
#           define mlock_simple                struct mlock_simple_obj
#           define mlock_simple_init(_lock)    do{ InitializeCriticalSection(&((struct mlock_simple_obj*)(_lock))->data); ((struct mlock_simple_obj*)(_lock))->file = 0; ((struct mlock_simple_obj*)(_lock))->line = 0; }while(0)
#           define mlock_simple_uninit(_lock)  DeleteCriticalSection(&((struct mlock_simple_obj*)(_lock))->data)
#           define mlock_simple_wait_directly(_lock)  EnterCriticalSection(&((struct mlock_simple_obj*)(_lock))->data)
#           define mlock_simple_release_directly(_lock)  LeaveCriticalSection(&((struct mlock_simple_obj*)(_lock))->data)
#       elif defined(__ucos__)
#       else                                   /*!< linux, rt-thread */
            typedef struct mlock_simple_obj
            {
                pthread_mutex_t         data;
                char                    *file;
                long                    line;
            }_mlock_simple_obj;
#            define mlock_simple                 struct mlock_simple_obj
#            define mlock_simple_init(_lock)     do{ pthread_mutex_init(&((struct mlock_simple_obj*)(_lock))->data,NULL);  ((struct mlock_simple_obj*)(_lock))->file = 0; ((struct mlock_simple_obj*)(_lock))->line = 0; }while(0)
#            define mlock_simple_uninit(_lock)   pthread_mutex_destroy(&((struct mlock_simple_obj*)(_lock))->data)
#           define mlock_simple_wait_directly(_lock)  pthread_mutex_lock(&((struct mlock_simple_obj*)(_lock))->data)
#           define mlock_simple_release_directly(_lock)  pthread_mutex_unlock(&((struct mlock_simple_obj*)(_lock))->data)
#       endif

#       if !defined(mlock_simple_debug)
#           if defined(_DEBUG)
#               define mlock_simple_debug    1
#           else
#               define mlock_simple_debug    0
#           endif
#       endif
       
#       if defined(mlock_simple_debug) && mlock_simple_debug
#           define mlock_simple_wait_ex(_lock, _file, _line)  do{ mlock_simple_wait_directly(_lock);   ((struct mlock_simple_obj*)(_lock))->file = (char*)(_file); ((struct mlock_simple_obj*)(_lock))->line = (_line); }while(0)
#           define mlock_simple_release_ex(_lock, _file, _line)     do{    ((struct mlock_simple_obj*)(_lock))->line = -((struct mlock_simple_obj*)(_lock))->line; mlock_simple_release_directly(_lock); }while(0)
#       else
#           define mlock_simple_wait_ex(_lock, _file, _line)  mlock_simple_wait_directly(_lock)
#           define mlock_simple_release_ex(_lock, _file, _line)  mlock_simple_release_directly(_lock)
#       endif
       
#       define mlock_simple_wait(_lock)     mlock_simple_wait_ex(_lock, __FILE__, __LINE__)
#       define mlock_simple_release(_lock)  mlock_simple_release_ex(_lock, __FILE__, __LINE__)
#   endif
#endif


struct mlock_obj;
struct mlock_obj_map;

/*!
func    mlock_sizeof_obj_map
\brief  get lock object map size
\param  key_len[in]         the lock key len
\return the size
*/
unsigned long mlock_sizeof_obj_map(unsigned long key_len);

/*!
func    mlock_create
\brief  create lock(for windows now)
\param  obj_map[in]         the lock object map, if NULL will create new one
\param  key[in]             the lock key. if NULL create an unnamed key
\return create a lock
        #NULL               create lock failed
        #other              the lock object be created
*/
struct mlock_obj *mlock_create(struct mlock_obj_map *obj_map, char *key);

/*!
func    mlock_destroy
\brief  destroy lock(for windows now)
\param  obj[in]             the lock object will be destroy
\return destroy a lock
        #0                  succeed
        #other              error code
*/
long mlock_destroy(struct mlock_obj *obj);

/*!
func    mlock_wait
\brief  wait lock
\param  obj[in]             the lock object try to enter
\param  time_out[in]        time out value(ms)
\return wait a lock
        #0                  succeed, will be wait here if be locked by other thread
        #other              error code
*/
long mlock_wait(struct mlock_obj *obj, unsigned long time_out);

/*!
func    mlock_release
\brief  release lock
\param  obj[in]             the lock object try to leave
\return release a lock
        #0                  succeed
        #other              error code
*/
long mlock_release(struct mlock_obj *obj);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__mlock_h__) */

