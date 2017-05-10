/*!
\file       msg_queue.h
\brief      message queue unit, compatible ipc(share-memory)

 ----history----
\author     chengzhiyong
\date       2007-03-16
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: msg_queue.h,v 1.4 2008-11-13 02:05:15 chengzhiyong Exp $
*/
#if !defined(__mmq_list_h__)
#define __mmq_list_h__
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct mmq_queue;
struct mmq_list;

typedef struct mmq_list_info
{
    struct
    {
        struct
        {
            unsigned long   len;
            char            *data;
        }key;                                       /*!< key */
        unsigned long       size;                   /*!< the size */
        unsigned long       max_queue_counts;       /*!< max queue counts */
        unsigned long       counts;                 /*!< current queue counts */
        unsigned long       his_counts;             /*!< total history queue counts */
        unsigned long       float_msg_counts;       /*!< picked message counts */

        unsigned long       alloc_succs;            /*!< alloc succeed counts */
        unsigned long       alloc_fails;            /*!< alloc failed action times count */
        unsigned long       continue_alloc_fails;   /*!< Continuous allocation failure times count */
    }map;

    unsigned long           alloc_counts;           /*!< alloc in this mq-list object */
    unsigned long           free_counts;            /*!< alloc in this mq-list object */
    unsigned long           realloc_counts;         /*!< alloc in this mq-list object */
}_mmq_list_info;

/*!
func    mmq_list_create
\brief  create a message queue list, 
\param  key[in]                 the message queue key
                                NULL : only use in the process
                                other: can use in IPC
\param  map_size[in]            the queue list size
\param  max_queue_counts[in]    the max queue counts, include max_dynqueue_counts
\return result
        #NULL                   have not enought space
        #other                  message queue 
*/
struct mmq_list *mmq_list_create(char *key, unsigned long map_size, unsigned long max_queue_counts);

/*!
func    mmq_list_destroy
\brief  destroy message queue list
\param  mqlst[in]               the message quene list
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mmq_list_destroy(struct mmq_list *mqlst);

#if 0
#define mmq_query_item_key       0   /* char* */
#define mmq_query_item_size      1   /* unsigned long */
/*!
func    mmq_query
\brief  query mmq_list refer info
\param  mqlst[in]               the message quene list
\param  item[in]                the item
\param  value[out]              the value
\return the result
        #0                      succeed
        #other                  error code
*/
long mmq_query(struct mmq_list *mqlst, unsigned long item, void **value);
#endif

/*!
func    mmq_open
\brief  open a message queue. if exist return it, else add new one.
\param  mqlst[in]               the message quene list
\param  queue_id[in]            the queue id
                                if >= 0 will be static queue
                                if < 0 will be dynamic queue
\param  connection[in]          connection
\return open result
        #NULL                   failed
        #other                  the queue object
*/
struct mmq_queue *mmq_open(struct mmq_list *mqlst, long queue_id);

/*!
func    mmq_close
\brief  close queue, and all sub queue will be close.
\param  mqlst[in]               the message quene list
\param  queue_id[in]            the queue id
\return close result
        #0                      succeed
        #other                  error code
*/
long mmq_close(struct mmq_list *mqlst, unsigned long queue_id);


/*!
func    mmq_alloc
\brief  alloc a message from queue list
\param  mqlst[in]               the message quene list
\param  size[in]                the size
\param  file[in]                the file name
\param  line[in]                the file line
\return result
        #NULL                   have not enought space
        #other                  start pointer
*/
void *mmq_alloc(struct mmq_list *mqlst, unsigned long size, const char *file, long line);

/*!
func    mmq_realloc
\brief  realloc message space
\param  mqlst[in]               the message quene list
\param  msg[in]                 the message
\param  size[in]                the new size, must smaller than old size
\return result
        #0                      succeed
        #other                  error code.
*/
long mmq_realloc(struct mmq_list *mqlst, void* msg, unsigned long size);

/*!
func    mmq_free
\brief  free message
\param  mqlst[in]               the message quene list
\param  msg[in]                 the message
\return result
        #0                      succeed
        #other                  error code.
*/
long mmq_free(struct mmq_list *mqlst, void *msg);

#define mmq_save_flag_dis_transfer_agent     1
/*!
func    mmq_save
\brief  save a message into queue list by special id, if special id
        not exist, will save to default transfer queue list.
\param  mqlst[in]               the message quene list
\param  queue_id[in]            the id of the message queue.
\param  msg[in]                 the message
\param  flag[in]                the message save flag
\return save result
        #0                      succeed
        #other                  error code
*/
long mmq_save(struct mmq_list *mqlst, long queue_id, void *msg, unsigned long flag);

/*!
func    mmq_pick
\brief  pick a message from queue list by special id, 
        if get will be delete from queue, pick imply a claim action.
\param  mqlst[in]               the message queue list
\param  queue[in]               the message queue.
\param  size[out]               the message size, if NULL will be ignore
\param  timeout[in]             the time out value(ms)
\param  owner_queue_id[out]     owner queue id. if in transfer queue maybe not same as queue-id.
\return result
        #NULL                   have not message
        #other                  start pointer
*/
void* mmq_pick(struct mmq_list *mqlst, struct mmq_queue *queue, unsigned long timeout, unsigned long *size, long *owner_queue_id);

/*!
func    mmq_pick_cancel
\brief  cancel pick action, to end mq-queue owner
\param  mqlst[in]               the message queue list
\param  queue[in]               the message queue.
\return result
        #0                      succeed
        #other                  error code
*/
long mmq_pick_cancel(struct mmq_list *mqlst, struct mmq_queue *queue);

/*!
func    mmq_check
\brief  check message queue data is correct
\param  mqlst[in]               the message queue list
\param  file[in]                the file name
\param  line[in]                line
\return check result
        #0                      succeed
        #other                  data error
*/
long mmq_check(struct mmq_list *mqlst, char *file, int line);
#define mmq_do_check(mqlst) mmq_check(mqlst, __FILE__, __LINE__)

/*!
func    mmq_query
\brief  check message queue data is correct
\param  mqlst[in]               the message queue list
\param  info[out]               the info
\return query result
        #0                      succeed
        #other                  data error
*/
long mmq_query(struct mmq_list *mqlst, struct mmq_list_info *info);

/*!
func    mmq_dump
\brief  dump message queue info from msg queue module
\param  mqlst[in]               the malst, can be NULL, if NULL ignore
\param  argc[in]                the arg counts
\param  argv[in]                the arg list, if(argc == 0) can be NULL if NULL default
                                --help      : get help
                                --filter    : filter string, if empty all items will be matched.
                                --type      : type list split by ","
                                    list            : output mq-list
                                    queue           : output queue
                                    msg             : output message
                                    float-msg       : output float message
                                    all             : output all type
                                    default         : same as queue
\param  buf[in]                 the output buffer, can be NULL, if NULL output into file 
\param  start[in]               the start record no
\param  counts[in]              max output records counts
\param  size[in]                the buf size or max content size output to file
\return content length
        #<0                     error code
        #other                  content length
*/
long mmq_dump(struct mmq_list    *mqlst,
             unsigned long     argc,
             char              *argv[],
             char              *buf,
             char              *file,
             unsigned long     start,
             unsigned long     counts,
             unsigned long     size);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
#endif /* !defined(__mmq_list_h__) */
