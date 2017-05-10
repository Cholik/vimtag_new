#if defined(__cplusplus)
extern "C" {
#endif

#if !defined(__timer_h__)
#define __timer_h__

#include "mcore/mlock.h"

/* Definition of timer_ex mode */
#define TIMER_MODE_LOOP         1
#define TIMER_MODE_NON_LOOP     2

#define TIMER_EX_MAGIC          (*(long*)"tmex    ")
#define TIMER_EX_CB_MAGIC       (*(long*)"tecb    ")

/* Callback function definition of time out */
typedef long (*timer_ex_callback)( void *refer );

/* Definition of timer_ex */
typedef struct timer_ex
{
    char            magic[sizeof(long)];
    struct timer_ex *next;
    timer_ex_callback   callback;       /* Time out call back */
    unsigned long   ms;             /* Timer length */
    unsigned long   mode;           /* Timer mode */
    void            *refer;         /* user refer */
    unsigned long   invoke_tick;    /* Timer out tick */
}_timer_ex;

typedef struct timer_ex_cb
{
    char            magic[sizeof(long)];
    mlock_simple    lock;
    struct mlogf_ctx    *log_ctx;
    struct timer_ex *run_head;      /* Running timer_ex list head */
    unsigned long   first_tick;     /* first tick */
    unsigned long   current_tick;   /* Current tick */
    unsigned long   callback_tick;  /* latest callback tick */
    unsigned long   insert_tick;     /* latest start tick */
    unsigned long   delete_tick;      /* latest stop tick */
    unsigned long   counts_start;   /* Counts for timer_ex_start */
    unsigned long   counts_stop;    /* Counts for timer_ex_stop */
    unsigned long   counts_sch;     /* Counts for timer_ex_sch */
    unsigned long   counts_insert;  /* Counts for timer_insert */
    unsigned long   counts_insert_loop; /* Counts for timer_insert about loop */
    unsigned long   counts_delete;  /* Counts for timer_delete from stop */
    unsigned long   counts_delete_auto; /* Counts for timer_delete from timeout */
    unsigned long   counts_callback;    /* Counts for timeout callback */
    unsigned long   counts_start_fail;  /* Counts for timer_ex_start fail */
    unsigned long   counts_stop_fail;   /* Counts for timer_ex_stop fail */
    unsigned long   counts_sch_fail;    /* Counts for timer_ex_sch fail */
    unsigned long   counts_ext[10];    /* Counts extention for user module */
}_timer_ex_cb;

struct timer_ex_cb * timer_ex_create(void);
long timer_ex_destroy( struct timer_ex_cb *cb );
long timer_ex_sch( struct timer_ex_cb *cb, unsigned long max_sch_timer, unsigned long current_tick );
struct timer_ex * timer_ex_start( struct timer_ex_cb *cb,
                                         unsigned long ms, unsigned long mode,
                                         timer_ex_callback callback, void *refer );
long timer_ex_stop( struct timer_ex_cb *cb, struct timer_ex *timer_ex );
#endif /* !defined(__timer_h__) */
#if defined(__cplusplus)
}
#endif

