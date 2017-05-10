#if !defined(__msg_timer_h__)
#define __msg_timer_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct component;
struct timer_ex;


#if !defined(__mtimer_time_out_type_magic)
#define __mtimer_time_out_type_magic 0x001f0ced
typedef struct mtimer_time_out
{
	uint32_t	para1;	/* parameter1 */ 
	uint32_t	para2;	/* parameter2 */ 
}_mtimer_time_out;
#elif (__mtimer_time_out_type_magic != 0x001f0ced)
#error mtimer_time_out type defined but not match
#endif /* !defined(__mtimer_time_out_type_magic) */

#define msg_timer_counts_type_start         0
#define msg_timer_counts_type_stop          1
#define msg_timer_counts_type_callback      2
#define msg_timer_counts_type_start_fail    3
#define msg_timer_counts_type_callback_fail 4

#define mtimer_magic (*(long*)"timr    ")
typedef struct mtimer
{
    char                    magic[sizeof(long)];   /* magic "timr" */
    struct timer_ex         *timer;     /* Timer cb */
    struct component        *comp;      /* Component */
    unsigned long           mode;       /* Timer mode */
    long                    handle;     /* to_handle */
    unsigned long           para1;      /* parameter 1 */
    unsigned long           para2;      /* parameter 2 */
}_mtimer;

extern struct mtimer * mtimer_start( struct component *comp, unsigned long ms, unsigned long mode, long handle, unsigned long para1, unsigned long para2 );
extern long mtimer_stop( struct mtimer *timer );
extern long mtimer_dump(   struct component *comp,
                    unsigned long       argc,
                    char                *argv[],
                    char                *buf,
                    char                *file,
                    unsigned long       start,
                    unsigned long       counts,
                    unsigned long       size);

#if defined(__cplusplus)
}
#endif
#endif /* !defined(__msg_timer_h__) */


