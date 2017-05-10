/*!
\file       msock.h
\brief      mining sock module

 ----history----
\author     chengzhiyong
\date       2013-07-01
\version    0.01
\desc       create
*/

#if !defined(__msock_h__)
#define __msock_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

struct msock;
struct msock_event;
struct msock_stack;
struct msock_mod;

/* \brief msock event type */
typedef enum msock_event_type
{
    meset_events,                       /*!< socket event from os network stack */
    meset_destroy                       /*!< msock will be destroy */
}_msock_event_type;

/* \brief msock event object */
typedef struct msock_event
{
    enum msock_event_type               type;           /*!< eventy type */
    union
    {
        unsigned long                   events;         /*!< event for poll */
        struct
        {
            struct msock_event_stack    *ref;           /*!< ref sock stack */
            struct{unsigned long len; char *data; }
                                        hold;           /*!< hold data */
        }transfer;                                      /*!< transfer ctx */
    }param;
}_msock_event;
#define msock_event_format_s    "%p{%ld:%x}"
#define msock_event_format(_evt)    (_evt), (_evt)?(_evt)->type:0,\
    (_evt)?((meset_events == (evt)->type)?(_evt)->param.events:0):0


typedef long (*msock_on_event)(struct msock *sock, struct msock_event *evt);
/* \brief msock stack object */
typedef struct msock_stack
{
    void                            *ref;
    struct{unsigned long len; char *data; }
                                    name;
    msock_on_event                  on_event;
}_msock_stack;
#define msock_stack_format_s          "%p{%*.*s}"
#define msock_stack_format(_stack)    (_stack), 0, (int)((_stack)?(_stack)->name.len:0), (_stack)?(_stack)->name.data:NULL

typedef enum msock_create_type
{
    mesct_open,
    mesct_connect,
    mesct_accept
}_msock_create_type;

/*!\brief msock description */
typedef struct msock_desc
{
    enum msock_create_type          create_type;    /*!< create type */
    union
    {
        struct
        {
            long                    type;       /* socket type, SOCK_DGRAM | SOCK_STREAM */
            struct in_addr          ip;
            long                    port;

            /* ssl */
            char                    *ca_cert, *cert, *prik, *prik_pwd;/* cert just used in ssl-client */
        }open;
        struct
        {
            struct{ unsigned long len; char *data; } 
                                    host;       /*!< host */
            struct in_addr          ip;
            long                    port;

            /* ssl */
            char                    *ca_cert, *cert, *prik, *prik_pwd;/* cert just used in ssl-client */
        }connect;
        struct
        {
            struct msock            *srv;
        }accept;
    }param;
    
    void                            *ref;
    struct msock_stack              *stack;
}_msock_desc;
#define msock_desc_format_s         "%p"
#define msock_desc_format(_desc)    (_desc)

#define msock_magic                 (*(long*)"msck    ")
#define msock_magic_free            (*(long*)"MSCK    ")
/* \biref msock object */
typedef struct msock
{
    char                    magic[sizeof(long)];/*!< object valid check magic */
    long                    used;               /*!< used counts */
    struct
    {
        struct msock        *prev;              /*!< prev sock in module */
        struct msock        *next;              /*!< next sock in module */
        struct msock_mod    *owner;             /*!< the sock module */
    }in_mod;
    long                    type;               /*!< socket type, SOCK_DGRAM | SOCK_STREAM */
    long                    fd;                 /*!< socket handle */

    void                    *ssl_ctx;           /*!< ssl ctx, just for SSL */
    void                    *ssl;               /*!< ssl object, just for ssl */
    void                    *bio;               /*!< bio object, just for ssl */

    void                    *ref;               /*!< refer pointer, for stack */
    struct msock_stack      *stack;             /*!< stack */
    struct netx_event       evt;                /*!< current event setting */
}_msock;
#define msock_format_s              "%p{sock[%ld{%s}], stack[%*.*s]}"
#define msock_format(_sock)         (_sock), (_sock)?(_sock)->fd:0, \
                                    ((_sock) && (msock_magic == *(long*)&(_sock)->magic[0]))?netx_stoa((_sock)->fd):"", \
                                    0, (int)(((_sock) && (_sock)->stack)?(_sock)->stack->name.len:0), \
                                    ((_sock) && (msock_magic == *(long*)&(_sock)->magic[0]))?(_sock)->stack->name.data:0

#define msock_mod_magic             (*(long*)"mskm    ")
#define msock_mod_magic_free        (*(long*)"MSKM    ")
/* \brief msock module object */
typedef struct msock_mod
{
    char                            magic[sizeof(long)];    /*!< magic, check module is valid */
    long                            poll;                   /*!< netx poll */

    mlock_simple                    lock;                   /*!< lock */
    struct
    {
        unsigned long               counts;                 /*!< current sock counts */
        struct msock                *list;                  /*!< socks list */
    }socks, frees;                                          /*!< socks, need free socks */

    struct
    {
        unsigned long               counts;                 /*!< total event counts in list */
        unsigned long               ready_counts;           /*!< raised msock/event counts */
        struct netx_event           *list;                  /*!< netx event array buffer */
    }evts;                                                  /*!< events for msock_mod_wait and msock_mod_dispatch */

    long                            ssl_inited;             /*!< ssl inited */
    void                            *ref;                   /*!< refer for caller */
}_msock_mod;
#define msock_mod_format_s      "%p{socks[%ld], evts[%ld]}"
#define msock_mod_format(_mod)  (_mod), (_mod)?(_mod)->socks.counts:0, (_mod)?(_mod)->evts.ready_counts:0

typedef struct msock_mod_desc
{
    unsigned long                   evt_counts; /*!< event counts for msock_mod_wait */
    void                            *ref;       /*!< refer */
}_msock_mod_desc;
#define msock_mod_desc_format_s         "%p"
#define msock_mod_desc_format(_desc)    (_desc)

/*!
func    msock_mod_create
\brief  create sock module
\param	desc[in]            the module description
\return the sock module
        #NULL               failed
        #other              the sock module
*/
struct msock_mod *msock_mod_create(struct msock_mod_desc *desc);

/*!
func    msock_mod_destroy
\brief  create sock module
\param	mod[in]             the module
\return destroy result
        #0                  succeed
        #other              error code
*/
long msock_mod_destroy(struct msock_mod *mod);

/*!
func    msock_mod_wait
\brief  schedule mosck module
\param	mod[in]             the module
\param  timeout[in]         the timeout tick, will return until timeout or 
                            have any event be raised
\return destroy result
        #0                  succeed
        #>0                 raised event counts
        #<0                 error code
*/
long msock_mod_wait(struct msock_mod *mod, long timeout);

/*!
func    msock_mod_dispatch
\brief  dispatch events be attached in msock module
\param	mod[in]             the module
\param  timeout[in]         the timeout tick, will return until timeout or 
                            have any event be raised
\return destroy result
        #0                  succeed
        #other              error code
*/
long msock_mod_dispatch(struct msock_mod *mod);

/*!
func    msock_create
\brief  create msock
\param	mod[in]             the module
\param  desc[in]            the sock desc
\param  sock[out]           output result object
\return error code
        #0                  succeed
        #other              the msock object
*/
long msock_create(struct msock_mod *mod, struct msock_desc *desc, struct msock **sock);

/*!
func    msock_destroy
\brief  destroy msock
\param	sock[in]            the msock object
\return destroy result
        #0                  succeed
        #other              error code
*/
long                msock_destroy(struct msock *sock);

#define msock_set(_sock, _stack, _ref)  do{ (_sock)->ref = (_ref); (_sock)->stack = (_stack); }while(0)

/*!
func    msock_dump
\brief  dump inner info from msock module 
\param  mod[in]                 the module, can be NULL, if NULL ignore
\param  argc[in]                the arg counts
\param  argv[in]                the arg list, if(argc == 0) can be NULL if NULL default
                                --help      : get help
                                --filter    : filter string, if empty all items will be matched.
                                --type      : type list split by ","
                                    module          : output module
                                    sock            : output sock object
                                    sock-freed      : output freed socket
                                    all             : output all type
                                    default         : same as sock
\param  buf[in]                 the output buffer, can be NULL, if NULL output into file 
\param  start[in]               the start record no
\param  counts[in]              max output records counts
\param  size[in]                the buf size or max content size output to file
\return content length
        #<0                     error code
        #other                  content length
*/
long msock_dump(struct msock_mod    *mod,
                unsigned long       argc,
                char                *argv[],
                char                *buf,
                char                *file,
                unsigned long       start,
                unsigned long       counts,
                unsigned long       size);
#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */


#endif /* !defined(__msock_h__) */

