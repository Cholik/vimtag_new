/*!
\file       mhttp_client.h
\brief      mining http client module

 ----history----
\author     chengzhiyong
\date       2013-07-01
\version    0.01
\desc       create
*/

#if !defined(__mhttp_client_h__)
#define __mhttp_client_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

struct mhttp_client;
struct mhttp_task;

typedef struct mhttp_client_desc
{
    struct msock_mod                *sock_mod;
    struct len_str                  host;
    long                            port;

    void                            *ref;
}_mhttp_client_desc;
#define mhttp_client_desc_format_s      "%p{%*.*s:%ld}"
#define mhttp_client_desc_format(_desc) (_desc), 0, (int)((_desc)?(_desc)->host.len:0), (_desc)?(_desc)->host.data:0,\
                                        (_desc)?(_desc)->port:0

#define mhttp_client_magic            (*(long*)"htcl    ")
#define mhttp_client_magic_free       (*(long*)"HTCL    ")
/*! \brief mhttp-client object, is link to a msock object, transfer data on network */
typedef struct mhttp_client
{
    char                            magic[sizeof(long)];    /*!< magic */
    long                            used;                   /*!< used counts, if non 0 don't free it */
    struct
    {
        struct mhttp_client         *prev;                  /*!< prev item in mod's link */
        struct mhttp_client         *next;                  /*!< next item in mod's link */
        struct mhttp_client_mod     *owner;                 /*!< the module */
    }in_mod;
    struct msock                    *sock;                  /*!< msock object */
    struct len_str                  host;                   /*!< host name */
    long                            port;                   /*!< host port */
    long                            is_proxy;               /*!< is proxy */
    struct
    {
        unsigned long               counts;                 /*!< task counts */
        struct mhttp_task           *list;                  /*!< task list */
    }tasks;
    struct http_msg                 *recv;                  /*!< current recving http msg(response) */
}_mhttp_client;
#define mhttp_client_format_s         "%p{magic[%4.4s], host[%s], port[%ld], tasks[%ld]}"
#define mhttp_client_format(_client)  (_client), (_client)?&(_client)->magic[0]:0, \
                                      ((_client) && (mhttp_client_magic == *(long*)&(_client)->magic[0]))?(_client)->host.data:0, (_client)?(_client)->port:0, \
                                      (_client)?(_client)->tasks.counts:0

typedef enum mhttp_task_event
{
    emhte_cancel,
    emhte_error,
    emhte_finish
}_mhttp_task_event;
typedef long (*mhttp_task_on_event)(struct mhttp_task *task, enum mhttp_task_event evt);

typedef struct mhttp_task_desc
{
    struct len_str                  method;
    struct len_str                  url;
    struct len_str                  user_agent;
    struct len_str                  content_type;
    struct len_str                  content;

    struct len_str                  accept;
    struct len_str                  accept_encoding;
    struct len_str                  accept_charset;
    struct len_str                  accept_language;
    struct len_str                  boundary;
    struct
    {
        struct len_str              name;
        struct len_str              value;
    }ext_header;

    struct len_str                  connection;

    struct len_str                  out_file;  /* if setted will save content in this file, or will stdout */
    void                            *ref;
    mhttp_task_on_event             on_event;
}_mhttp_task_desc;
#define mhttp_task_desc_format_s         "%p{%*.*s}"
#define mhttp_task_desc_format(_desc)    (_desc), 0, (int)((_desc)?(_desc)->url.len:0), (_desc)?(_desc)->url.data:0

#define mhttp_task_magic            (*(long*)"mhtt    ")
#define mhttp_task_magic_free       (*(long*)"MHTT    ")
/*! \brief mhttp task object, multi tasks can be  link to eachother and save in same client */
typedef struct mhttp_task
{
    char                            magic[sizeof(long)];    /*!< magic */
    long                            used;                   /*!< used counts, if non 0, means in callback. */
    struct
    {
        struct mhttp_task           *prev;                  /*!< prev task in client */
        struct mhttp_task           *next;                  /*!< next task in client */
        struct mhttp_client         *owner;                 /*!< owner client */
    }in_client;                                             /*!< in client object */
    mhttp_task_on_event             on_event;               /*!< callback function for caller */
    struct len_str                  out_file;               /* if setted will save content in this file, or will stdout */
    void                            *ref;                   /*!< refer object for caller */

    struct len_str                  url;                    /*!< url */
    struct
    {
        unsigned long               size;                   /*!< buf size */
        unsigned long               index;                  /*!< buf index */
        unsigned char               *buf;                   /*!< buf start pointer */
    }send;
    struct http_msg                 *recv;
}_mhttp_task;
#define mhttp_task_format_s         "%p{magic[%4.4s], url[%s]}"
#define mhttp_task_format(_task)    (_task), (_task)?&(_task)->magic[0]:0, \
                                    ((_task) && (mhttp_task_magic == *(long*)&(_task)->magic[0]))?(_task)->url.data:0

typedef struct mhttp_client_mod_statistic
{
    unsigned long           client_counts;
    unsigned long           task_counts;
    unsigned long           task_err_counts;
    unsigned long           recv_bytes;
    unsigned long           send_bytes;
}_mhttp_client_mod_statistic;

typedef struct mhttp_client_mod_desc
{
    long                    reserved;
}_mhttp_client_mod_desc;
#define mhttp_client_mod_desc_format_s        "%p"
#define mhttp_client_mod_desc_format(_desc)   (_desc)


#define mhttp_client_mod_magic          (*(long*)"htcm    ")
#define mhttp_client_mod_magic_free     (*(long*)"HTCM    ")
typedef struct mhttp_client_mod
{
    char                    magic[sizeof(long)];        /*!< magic used to check obj's valid status */
    mlock_simple            lock;                       /*!< lock object */
    struct
    {
        unsigned long       counts;                     /*!< clients counts */
        struct mhttp_client *list;                      /*!< clients list */
    }clients, frees;                                    /*!< clients/frees */
    struct msock_stack      stack;                      /*!< msock stack */
    struct mhttp_client_mod_statistic   statistic;      /*!< statistic */
}_mhttp_client_mod;
#define mhttp_client_mod_format_s       "%p{clients[%ld]}"
#define mhttp_client_mod_format(_mod)   (_mod), (_mod)?(_mod)->clients.counts:0

/*!
func    mhttp_client_mod_create
\brief  create http client module
\param	desc[in]            the module description
\return the http client module
        #NULL               failed
        #other              the sock module
*/
struct mhttp_client_mod *mhttp_client_mod_create(struct mhttp_client_mod_desc *desc);

/*!
func    mhttp_client_mod_destroy
\brief  destroy http client module
\param	mod[in]             the module
\return detroy result
        #0                  succeed
        #other              error code
*/
long mhttp_client_mod_destroy(struct mhttp_client_mod *mod);

/*!
func    mhttp_client_create
\brief  create http client
\param  mod[in]             the module
\param  desc[in]            the http client desc
\return detroy result
        #0                  succeed
        #other              error code
*/
struct mhttp_client *mhttp_client_create(struct mhttp_client_mod *mod, struct mhttp_client_desc *desc);

/*!
func    mhttp_client_destroy
\brief  destroy http client
\param  client[in]          the http client
\return detroy result
        #0                  succeed
        #other              error code
*/
long                mhttp_client_destroy(struct mhttp_client *client);

/*!
func    mhttp_task_create
\brief  create http task
\param  client[in]          the http client
\param  desc[in]            the http task desc
\return detroy result
        #0                  succeed
        #other              error code
*/
struct mhttp_task   *mhttp_task_create(struct mhttp_client *client, struct mhttp_task_desc *desc);

/*!
func    mhttp_task_destroy
\brief  destroy http task
\param  mod[in]             the module
\param  task[in]            the http task
\return detroy result
        #0                  succeed
        #other              error code
*/
long                mhttp_task_destroy(struct mhttp_task *task);

/*!
func    mhttp_client_dump
\brief  dump inner info from http client module 
\param  mod[in]                 the module, can be NULL, if NULL ignore
\param  argc[in]                the arg counts
\param  argv[in]                the arg list, if(argc == 0) can be NULL if NULL default
                                --help      : get help
                                --filter    : filter string, if empty all items will be matched.
                                --type      : type list split by ","
                                    module          : output module
                                    client          : output factory
                                    task            : output task
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
long mhttp_client_dump(struct mhttp_client_mod *mod,
                       unsigned long           argc,
                       char                    *argv[],
                       char                    *buf,
                       char                    *file,
                       unsigned long           start,
                       unsigned long           counts,
                       unsigned long           size);

/*!
func    mhttp_client_utils_entry
\brief  mhttp client utils entry
\param  argc[in]            the arg counts, come from command line usually
\param  argv[in]            the arg values, come from command line usually
\return detroy result
        #0                  succeed
        #other              error code
*/
long mhttp_client_utils_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */


#endif /* !defined(__mhttp_client_h__) */

