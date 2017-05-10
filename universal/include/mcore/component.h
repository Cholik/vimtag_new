/*!
\file       component.h
\brief      component unit

 ----history----
\author     chengzhiyong
\version    0.01
\desc       create

$Author: xieyong $
$Id: component.h,v 1.8 2008-11-19 07:25:54 xieyong Exp $
*/

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__component_h__)
#define __component_h__

struct component;
struct mmq_list;
struct mmq_queue;

/*! \brief component init interface */
#define comp_status_creating       1
#define comp_status_starting       2
#define comp_status_running        2
#define comp_status_stopping       3
#define comp_status_destroying     4

/*!
func    comp_interface
\brief  component interface
\param  comp[in]                the component object
\param  command[in]             command["query_name", "query_def", "query_conf", "create", "start", "stop", "dest
\return query result
        #0                      succeed
        #other                  error code
*/
typedef void* (*component_interface)(struct component* comp, char *command);

#define comp_magic (*(long*)"comp   ")
/*! \brief component */
typedef struct component
{
    /*-----------------container management data begin----------------------------*/
    /*--------(comp_info)copy from container config data---------------*/
    char                    magic[sizeof(long)];       /*!< magic should be "comp" */
    long                    id;             /*!< component id */
    long                    reserved;       /*!< reserved */
    struct
    {
        unsigned            len;
        char                *data;
    }name;                                  /*!< component name */
    struct
    {
        unsigned            len;
        char                *data;
    }obj_file;                              /*!< component obj name, binary execute code file name, .so in linux or .dll in windows */
    struct
    {
        unsigned            len;
        char                *data;
    }key;                                   /*!< key */
    struct
    {
        unsigned            len;
        char                *data;
    }conf_file;                             /*!< config file name */
    /*--------(comp_info)copy from container config data---------------*/
    
    /*--------(container data)inherit from container---------------*/
    struct mmq_list         *mqlst;         /*!< message queue list */
    struct trans_table      *trans_tbl;     /*!< trans table */
    /*--------(container data)inherit from container---------------*/

    void                    *obj_handle;     /*!< object handle, for call-back routine */
    component_interface     comp_interface; /*!< component interface */
    struct pack_def_list    *def_list;      /*!< definition list */
    void                    *conf_data;     /*!< config data struct */
    struct mmq_queue        *msg_queue;     /*!< the message queue */
    unsigned long           status;         /*!< status */
    unsigned long           thread_id;      /*!< thread id */
    struct trace_cb         *trace_cb;      /*!< control block for trace function */
    struct timer_ex_cb      *timer_ex_cb;   /*!< timer control block */
    unsigned long           sch_mode;       /*!< schedule mode. 0:normal; 1:external */
    unsigned long           start_tick;     /*!< component start tick */
    struct
    {
        unsigned long       enter_tick;     /*!< last schdule tick */
        unsigned long       warn_times;     /*!< warning times */
        struct
        {
            unsigned long   len;
            char            *data;
        }trans, msg;                        /*!< trans: trans class name, msg: msg data */
    }sch;
    long                    license_status; /*!< license status */
    /*-----------------container  management data end------------------------------*/

    void                    *data;          /*!< component data */
}_component;
#define comp_get_data(comp)         (comp)->data
#define comp_get_conf(comp)         (comp)->conf_data
#define comp_get_mqlst(comp)        (comp)->mqlst
#define comp_get_id(comp)           (comp)->id
#define comp_get_name(comp)         (comp)->name.data
#define comp_get_def_list(comp)     (comp)->def_list
#define comp_get_trans_tbl(comp)    (comp)->trans_tbl
#define comp_get_trace_cb(comp)     (comp)->trace_cb
#define comp_get_timer_ex_cb(comp)  (comp)->timer_ex_cb
#define comp_format_s               "%p{[%4.4s]%s:%08lx}"
#define comp_format(_comp)          (_comp), (_comp)?(char*)&(_comp)->magic:0, (_comp)?comp_get_name(_comp):NULL,\
                                    (_comp)?comp_get_id(_comp):0

#endif /* !defined(__component_h__) */
#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
