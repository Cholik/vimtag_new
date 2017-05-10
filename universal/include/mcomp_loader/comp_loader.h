/*!
\file       comp_loader.c
\brief      map base on hash

 ----history----
\author     chengzhiyong
\date       2008-12-25
\version    0.01
\desc       create
*/

#if defined(__cplusplus)
extern "C" {
#endif

#if !defined(__comp_loader_h__)
#define __comp_loader_h__

#define __comp_info_def_str \
    "<comp_info  type=\"comp_info\">\r\n"\
    "       <id         type=\"int32\"    info=\"component id\"/>\r\n"\
    "       <name       type=\"lenstr\" info=\"component name\"/>\r\n"\
    "       <obj_file   type=\"lenstr\" info=\"component obj(dll/so) file\"/>\r\n"\
    "       <key        type=\"lenstr\" info=\"license key file\"/>\r\n"\
    "       <conf_file  type=\"lenstr\" info=\"component config file\"/>\r\n"\
    "       <trc_flag   type=\"int32\" info=\"Trace flag to indicate which information should be traced local\"/>\r\n"\
    "       <cid_trace_trap type=\"int32\"    info=\"component id of ps_trace_trap\"/>\r\n"\
    "       <cid_trace_trans type=\"int32\"    info=\"component id of ps_trans_trace\"/>\r\n"\
    "       <process	type=\"int32\"    info=\"running as process\"/>\r\n"\
    "       <sch_mode    type=\"uint32\"                     info=\"schedule mode. 0:normal; 1:external\"/>\r\n"\
    "</comp_info>\r\n"

#define __cont_config_def_str   \
    __comp_info_def_str \
        "<cont_config	        type=\"cont_config\">\r\n"\
        "    <components         type=\"comp_info\"         counts=\"0-100\"/>\r\n"\
        "    <cid_trace_trap     type=\"int32\"             info=\"component id of ps_trace_trap\"/>\r\n"\
        "    <cid_trace_trans    type=\"int32\"             info=\"component id of ps_trans_trace\"/>\r\n"\
        "    <mq_name            type=\"lenstr\"            info=\"message queue list name, default is mq\"/>\r\n"\
        "    <mq_size            type=\"uint32\"            info=\"message queue list size, default is 256M\"/>\r\n"\
        "    <process	         type=\"uint32\"            info=\"running every component as seprate process\"/>\r\n"\
        "    <sch_mode            type=\"uint32\"           info=\"schedule mode. 0:normal; 1:external\"/>\r\n"\
        "</cont_config>\r\n"

#if !defined(__comp_info_type_magic)
#define __comp_info_type_magic 0x35c46e51
#pragma pack(push, 1)
    typedef struct comp_info
    {
        int32_t             id;                 /* component id */
        struct pack_lenstr  name;               /* component name */
        struct pack_lenstr  obj_file;           /* component obj(dll/so) file */
        struct pack_lenstr  key;                /* license key file */
        struct pack_lenstr  conf_file;          /* component config file */
        int32_t             trc_flag;           /* Trace flag to indicate which information should be traced local */
        int32_t             cid_trace_trap;     /* component id of ps_trace_trap */
        int32_t             cid_trace_trans;    /* component id of ps_trans_trace */
        int32_t             process;            /* running as process */
        uint32_t            sch_mode;           /* schedule mode. 0:normal; 1:external */
    }_comp_info;
#pragma pack(pop)
#elif (__comp_info_type_magic != 0x35c46e51)
#error comp_info type defined but not match
#endif /* !defined(__comp_info_type_magic) */


#define comp_info_format_s  "%p{id[%d], name[%*.*s], obj_file[%*.*s], conf_file[%*.*s], trc_flag[%08x], cid_trace_trap[%08x], cid_trace_trans[%08x], process[%d]}"
#define comp_info_format(_cinfo) (_cinfo), (_cinfo)?(_cinfo)->id:0,\
                            0, (_cinfo)?(_cinfo)->name.len:0, (_cinfo)?(_cinfo)->name.data:NULL, \
                            0, (_cinfo)?(_cinfo)->obj_file.len:0, (_cinfo)?(_cinfo)->obj_file.data:NULL,\
                            0, (_cinfo)?(_cinfo)->conf_file.len:0, (_cinfo)?(_cinfo)->conf_file.data:NULL,\
                            (_cinfo)?(_cinfo)->trc_flag:0, (_cinfo)?(_cinfo)->cid_trace_trap:0, (_cinfo)?(_cinfo)->cid_trace_trans:0,\
                            (_cinfo)?(_cinfo)->process:0

#if !defined(__cont_config_type_magic)
#define __cont_config_type_magic 0xd1002ccc
#pragma pack(push, 1)
typedef struct cont_config
{
    uint32_t            components_counts;              /* components counts */
    struct comp_info    pack_def_pointer(components);   /* [0-100] */
    int32_t             cid_trace_trap;                 /* component id of ps_trace_trap */
    int32_t             cid_trace_trans;                /* component id of ps_trans_trace */
    struct pack_lenstr  mq_name;                        /* message queue list name, default is mq */
    uint32_t            mq_size;                        /* message queue list size, default is 256M */
    uint32_t            process;                        /* running every component as seprate process */
    uint32_t            sch_mode;                        /* schedule is trigge be external module */
}_cont_config;
#pragma pack(pop)
#elif (__cont_config_type_magic != 0xd1002ccc)
#error cont_config type defined but not match
#endif /* !defined(__cont_config_type_magic) */
    
#if !defined(__gw_comp_regist_type_magic)
#define __gw_comp_regist_type_magic 0x10ac48c1
#pragma pack(push, 1)
    typedef struct gw_comp_regist
    {
        struct pack_lenstr	def_xml;	/* def description */ 
    }_gw_comp_regist;
#pragma pack(pop)
#elif (__gw_comp_regist_type_magic != 0x10ac48c1)
#error gw_comp_regist type defined but not match
#endif /* !defined(__gw_comp_regist_type_magic) */

struct comp_process;
struct compset_cb;


/*!
func    comp_load_as_thread
\brief  load component as thread
        bother succeed or failed, this function will return at once.
        caller can do other things, such as load other component
\param  cinfo[in]               the component description info
\param  mqlst[in]               the message queue list                 
\param  comp_interface[in]      the component interface, can be NULL
                                if NULL load library, not NULL for such as execute component
\return the component
        #NULL                   load component failed
        #other                  the error code */
struct component *comp_load_as_thread(struct comp_info *cinfo, struct mmq_list *mqlst, component_interface comp_interface);

/*!
func    comp_unload_thread
\brief  unload the component thread
\param  process[in]             the thread component 
\return unload result
        #0                      succeed
        #other                  the error code
*/
long comp_unload_thread(struct component *comp);

/*!
func    comp_load_as_process
\brief  load component running in new sub process
\param  cinfo[in]               the component description info
\param  mqlst[in]               the message queue list                 
\return the process
        #NULL                   failed
        #other                  the process
*/
struct comp_process *comp_load_as_process(struct comp_info *cinfo, struct mmq_list *mqlst);

/*!
func    comp_unload_process
\brief  unload the component process
\param  process[in]             the process component 
\return unload result
        #0                      succeed
        #other                  the error code
*/
long comp_unload_process(struct comp_process *process);

/*!
func    comp_check_process
\brief  check the component process is still active
\param  process[in]             the process component 
\return check result
        #0                      still active
        #other                  the error code, should be exit
*/
long comp_check_process(struct comp_process *process);

/*!
func    comp_load_as_self
\brief  load component running in current thread.
        the function will not return until component create failed or finished
\param  cinfo[in]               the component description info
\param  mqlst[in]               the message queue list                 
\param  comp_interface[in]      the component interface, can be NULL
                                if NULL load library, not NULL for such as execute component
\return load result
        #0                      sub thread run finished succeed
        #other                  the error code, create component failed or 
                                component running failed. 
*/
long comp_load_as_self(struct comp_info *cinfo, struct mmq_list *mqlst, component_interface comp_interface);

long comp_destroy_all();

#define compset_magic   (*(long*)"coms    ")

typedef struct component_interface_list
{
    unsigned long           counts;
    struct  
    {
        struct len_str      name;
        long                comp_id;
        component_interface comp_interface;
    }list[1];               /* counts should not be 1 */
}_component_interface_list;

typedef struct compset_cb
{
    char                    magic[sizeof(long)];/* magic */
    unsigned long           comp_counts;        /* component counts */
    unsigned long           running_comp_counts;/* running component counts */
    struct component        **comps;            /* component array */
    unsigned long           mmq_size;            /* message queue size */
    char                    *mmq_name;           /* message queue name */
    unsigned long           mmq_max_queue_counts;/* message queue queue max counts */
    struct mmq_list         *mqlst_create_here; /* message queue create here */
    struct mmq_list         *mqlst;             /* message queue */
    unsigned                sch_mode;           /* schedule is trigge be external module */
}_compset_cb;

/*!
func    comp_cont_ctx_reset
\brief  component container context reset, if try load as thread directly, should
        call this function to reset context, or will let thread auto exit.
\return 
        #0                      ok
        #other                  error code
*/
long comp_cont_ctx_reset();

/*!
func    compset_create
\brief  Start component according to config file
\param  conf_file[in]           config file
\param  mqlst[in]               the message queue list, can be NULL, if NULL ignore
                                else use it.
\param  if_list[in]             interface list, can be NULL, if NULL ignore
                                for build multi component with static link
\return 
        #NULL                   fail
        #other                  components cb
*/
struct compset_cb* compset_create( char *conf_file, struct mmq_list *mqlst, struct component_interface_list *if_list);

/*!
func    compset_destroy
\brief  Stop all component
\param  cb[in]                  components cb
\return 
        #0                      ok
        #other                  fail
*/
long compset_destroy( struct compset_cb *cb );

/*!
func    compset_search
\brief  Search an component in the components
\param  cb[in]                  components cb
\param  name[in]                component name
\return 
        #NULL                   fail
        #other                  component cb
*/
struct component *compset_search( struct compset_cb *cb, char *name );

/*!
func    compset_sch
\brief  trigger comp schedule
\param  cb[in]                  compset cb
\param  timeout[in]             timeout length
\return 
        #0                      ok
        #other                  fail
*/
int compset_sch( struct compset_cb *cb, int timeout );

/*!
func    comp_single_main
\brief  component single main entry
\param  argc[in]                the argc
\param  argv[in]				the argv list
\param  comp_interface[in]      the component interface, can be NULL,
                                if not NULL will not load libraray
\return 
        #0                      ok
        #other                  error code
*/
long comp_single_main(long argc, char **argv, component_interface comp_interface);

/*!
func    comp_container_main
\brief  component container main entry
\param  argc[in]                the argc
\param  argv[in]				the argv list
\param  in_comp_counts[in]      the counts of inner component, if 0 ignore in_comp_names and in_comp_interfaces
\param  in_comp_names[in]       the component names, can be NULL
\param  in_comp_interfaces[in]  the component interface list, can be NULL
\return 
        #0                      ok
        #other                  error code
*/
long comp_container_main(long argc, char **argv, unsigned long in_comp_counts, char **in_comp_names, component_interface *in_comp_interfaces);

#endif /* !defined(__comp_loader_h__) */

#if defined(__cplusplus)
}
#endif



