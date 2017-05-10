/*
\file		msg_trace.h
\brief		.
 ----history----
\author     dakota
\date       2007-09-02
\version    0.01
\desc       create

*/
#if !defined(__msg_trace_h__)
#define  __msg_trace_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct pack_def_list;
struct pack_def;
struct mmq_list;
    
typedef struct trace_trap_key
{
    long                    cid;
    long                    handle;
    unsigned long           index;
}_trace_trap_key;

#define trace_flag_mask_full        0x8
#define trace_flag_mask_msg         0x4
#define trace_flag_mask_info        0x2
#define trace_flag_mask_err         0x1
#define int_msg  0x0067734d         /* Msg */
#define int_info 0x6f666e49         /* Info */
#define int_err  0x00727245         /* Err */

typedef struct trace_cb
{
    char                    *owner_name;        /* Owner name */
    struct mmq_list          *mqlst;             /* message queue list */
    long                    cid_trace_trap;     /* Cid of ps to store trap info */
    long                    cid_trace_trans;    /* Cid of ps to store trans_trace info */
    unsigned long           flag_static;        /* Trace flag static( config ) */
    unsigned long           print_flag;         /* Indicate whether print on console */
    unsigned long           flag_dynamic;       /* Trace falg dynamic( admin ) */
    long                    trans_count;        /* How many trace_obj should be trace dynamic. */ 
    long                    flag_running;       /* Trace flag current running */
    unsigned long           default_index;      /* Default index */
    struct pack_def_list    *def_list;          /* def list for trace_trap */
    struct pack_def         *trace_trap_def;    /* def for trace_trap */
    struct pack_def         *trace_trans_def;   /* def for trace_trans */
}_trace_cb;

extern long trace( struct trace_cb *cb, unsigned type, void *data, char *pcfile, unsigned long line, long l_cid, long l_handle, long r_cid, long r_handle, unsigned long *index );
extern struct trace_cb * trace_cb_create( char *owner_name, struct mmq_list *mqlst, long cid_ps_trap, long cid_ps_obj, unsigned long trace_flag, unsigned long print_flag );
extern long trace_cb_destroy( struct trace_cb *cb );
extern char *trace_sprintf( const char* format, ... );

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__msg_trace_h__) */






