/*!
\file       mthread.h 
\brief      thread unit, thread

 ----history----
\author     chengzhiyong 
\date       2007-01-30
\version    0.01
\desc       create

\author     chengzhiyong 
\date       2014-06-08
\version    0.02
\desc       rename thread_xxx to mthread_xxx
*/
#if !defined(__mthread_h__)
#define __mthread_h__

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(_WIN32) /* windows */
#   include <windows.h>
#elif defined(__ucos__)
#else /* linux */
#   include <pthread.h>
#endif

#if defined(_WIN32)  /* windows */
#   define mthread_call WINAPI
#else/* linux */
#   define mthread_call
#endif

/*! \brief thread call-back routine */
typedef long (mthread_call *mthread_routine)(void* data);

/*!
func    mthread_create
\brief  create thread
\param  routine[in]         thread routine
\param  data[in]            the user data
\return thread id
        #0                  create thread failed
        #other              thread id
*/
unsigned long mthread_create(mthread_routine routine, void* data);

/*!
func    mthread_get_self
\brief  get current thread id
\return thread id
        #0                  create thread failed
        #other              thread id
*/
#if defined(_WIN32) /* windows */
#   define mthread_get_self() ((unsigned long)GetCurrentThreadId())
#elif defined(__ucos__) 
#   define mthread_get_self() (0)
#else /* linux and rtthread */
#   define mthread_get_self() ((unsigned long)pthread_self())
#endif

/*!
func    mthread_sleep
\brief  sleep special timetick in current thread
\param  time[in]            times
\return thread id
        #0                  create thread failed
        #other              thread id
*/
#if defined(_WIN32)   /* windows */
#define mthread_sleep(ms) Sleep(ms)
#elif defined(__ucos__)
#define mthread_sleep(ms) (0)
#else   /* linux */
#define mthread_sleep(ms) usleep((ms)*1000)
#endif

/*!
func    mthread_terminate
\brief  terminate thread
\param  thread_id[in]       the thread id
\return terminate result
        #0                  succeed
        #other              error code
*/
#if defined(_WIN32)   /* windows */
#define mthread_terminate(thread_id) (TerminateThread(OpenThread(THREAD_ALL_ACCESS, TRUE, thread_id),0)?0:-1)
#elif defined(__ucos__)
#define mthread_terminate(thread_id) (0)
#else   /* linux */
#define mthread_terminate(thread_id) pthread_cancel((pthread_t)thread_id)
#endif

/*!
func    get_self_image_path
\brief  get current running image path
\param  buf[in]             the path save buffer
\param  buf_size[in]        the buffer size
\return the image path length
        #>0                 image path lenth
        #other              error code
*/
#if defined(_WIN32)   /* windows */
#define get_self_image_path(buf, buf_size) GetModuleFileName(NULL, (buf), (buf_size))
#elif defined(__ucos__)
#define get_self_image_path(buf, buf_size) (0) 
#else   /* linux */
#define get_self_image_path(buf, buf_size) readlink("/proc/self/exe", (buf), (buf_size))
#endif

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__mthread_h__) */
