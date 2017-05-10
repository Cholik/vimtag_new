/*!
\file       mlight_queue_api.h
\brief      mining light queue, a simple queue module

 ----history----
\author     chengzhiyong
\date       2013-07-09
\version    0.01
\desc       create
*/

#if !defined(__mlight_queue_api_h__)
#define __mlight_queue_api_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

#include "mcore/mcore.h"

struct mlq_runner;
struct mlq_queue;
struct mlq_msg;
struct mlq_msg_class;

/*! \brief mlq msg base object, must start with this struct */
typedef struct mlq_msg
{
    struct mlq_msg_class        *cls;               /*!< msg class */
    unsigned long               used;               /*!< refs counts */
}_mlq_msg;
#define mlq_msg_format_s        "%p"
#define mlq_msg_format(_msg)    (_msg)


/*!
func    mlq_queue_on_run
\brief  queue run callback routine, when have msg arrived 
        runner will call this function
\param  queue[in]               the queue object
\param  queue_ref[in]           the queue refer object set by caller 
                                when mlq_queue_create
\param  msg[in]                 the msg 
\return run result
        #0                      succeed
        #other                  error code
*/
typedef long (*mlq_queue_on_run)(struct mlq_queue *queue, void *queue_ref, struct mlq_msg *msg);

/*!
func    mlq_msg_on_free
\brief  msg callback routine, when msg used finished will call this function
\param  cls[in]                 the msg class
\param  cls_ref[in]             the msg class refer object input when mlq_msg_class_create()
\param  msg[in]                 the msg 
\return free result
        #0                      succeed
        #other                  error code
*/
typedef long (*mlq_msg_on_free)(struct mlq_msg_class *cls, void *cls_ref, struct mlq_msg *msg);

/*!
func    mlq_msg_class_create
\brief  create msg class
\param  name_len[in]            the name string length
\param  name[in]                the name string
\param  on_free[in]             free callback function
\param  ref[in]                 the refer object for caller
\return create result
        #NULL                   create failed
        #other                  the msg class object
*/
struct mlq_msg_class *mlq_msg_class_create(mlq_msg_on_free on_free, 
                                           unsigned long       name_len, char *name,
                                           void                *ref);

/*!
func    mlq_msg_destroy
\brief  destroy msg class
\param  cls[in]                 the msg class object
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mlq_msg_destroy(struct mlq_msg_class *cls);

/*!
func    mlq_runner_create
\brief  create runner
\param  name_len[in]            the name string length
\param  name[in]                the name string
\return create result
        #NULL                   create failed
        #other                  the runner object
*/
struct mlq_runner *mlq_runner_create(unsigned long name_len, char *name, void *ref);

/*!
func    mlq_runner_destroy
\brief  destroy runner
\param  runner[in]              the runner object
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mlq_runner_destroy(struct mlq_runner *runner);

/*!
func    mlq_runner_schedule
\brief  scdule runner
\param  runner[in]              the runner object
\return scudule result
        #0                      succeed
        #other                  dispatched msg counts
*/
long mlq_runner_schedule(struct mlq_runner *runner, unsigned long timeout);

/*!
func    mlq_queue_create
\brief  create queue
\param  runner[in]              the runner object
\param  on_run[in]              the run routine
\param  name_len[in]            the name length
\param  name[in]                the name
\param  ref[in]                 the refer data
\return the queue object
        #NULL                   failed
        #other                  the queue object
*/
struct mlq_queue *mlq_queue_create(struct mlq_runner    *runner, 
                                   mlq_queue_on_run     on_run, 
                                   unsigned long        name_len, char *name,
                                   void                 *ref);
/*!
func    mlq_queue_destroy
\brief  scdule runner
\param  runner[in]              the runner object
\param  run[in]                 the run routine
\param  name_len[in]            the name length
\param  name[in]                the name
\param  ref[in]                 the refer data
\return the queue object
        #NULL                   failed
        #other                  the queue object
*/
long mlq_queue_destroy(struct mlq_queue *que);

/*!
func    mlq_msg_class_create
\brief  create msg class
\param  name_len[in]            the name string length
\param  name[in]                the name string
\param  on_free[in]             free callback function 
\param  ref[in]                 the refer object for caller
\return create result
        #NULL                   create failed
        #other                  the msg class object
*/
struct mlq_msg_class *mlq_msg_class_create(mlq_msg_on_free  on_free, 
                                           unsigned long    name_len, char *name,
                                           void             *ref);

/*!
func    mlq_msg_class_destroy
\brief  destroy msg class
\param  cls[in]                 the msg class object
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mlq_msg_class_destroy(struct mlq_msg_class *cls);

/*!
func    mlq_msg_init
\brief  destroy msg class
\param  msg[in]                 the msg data
\param  cls[in]                 the msg class object
\param  retain[in]              is need retain this msg after init,
                                if:1 same as {mlq_msg_init(msg,cls,0);mlq_msg_retain(msg)};
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mlq_msg_init(struct mlq_msg *msg, struct mlq_msg_class *cls, long retain);

/*!
func    mlq_msg_retain
\brief  retain msg, inc ref-counts
\param  msg[in]                 the msg data
\return retain result
        #0                      succeed
        #other                  error code
*/
long mlq_msg_retain(struct mlq_msg *msg);

/*!
func    mlq_msg_release
\brief  dec ref counts, and will free if ref-counts == 0
\param  msg[in]                 the msg data
\return release result
        #0                      succeed
        #other                  error code
*/
long mlq_msg_release(struct mlq_msg *msg);

/*!
func    mlq_msg_post
\brief  scdule runner, can post a msg into multi queue.
        example:
            msg_init(msg, msg_cls, 1);
            msg_msg_post(queue, msg);
            mmq_msg_relesae(msg);
\param  que[in]                 the queue object
\param  msg[in]                 the msg
\return post result
        #0                      succeed
        #other                  error code
*/
long mlq_msg_post(struct mlq_queue *que, struct mlq_msg *msg);

/*!
func    mlq_dump
\brief  dump inner info from msg queue module
\param  mod[in]                 the module, can be NULL, if NULL ignore
\param  argc[in]                the arg counts
\param  argv[in]                the arg list, if(argc == 0) can be NULL if NULL default
                                --help      : get help
                                --filter    : filter string, if empty all items will be matched.
                                --type      : type list split by ","
                                    module          : output module
                                    client          : output factory
                                    task            : output channel class
                                    all             : output all type
                                    default         : same as client
\param  buf[in]                 the output buffer, can be NULL, if NULL output into file 
\param  start[in]               the start record no
\param  counts[in]              max output records counts
\param  size[in]                the buf size or max content size output to file
\return content length
        #<0                     error code
        #other                  content length
*/
long mlq_dump(struct mlq_runner *runner,
              unsigned long     argc,
              char              *argv[],
              char              *buf,
              char              *file,
              unsigned long     start,
              unsigned long     counts,
              unsigned long     size);

/*!
func    mlq_test_entry
\brief  queue module test entry
\param  argc[in]            the arg counts, come from command line usually
\param  argv[in]            the arg values, come from command line usually
\return detroy result
        #0                  succeed
        #other              error code
*/
long mlq_test_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__mlight_queue_api_h__) */
