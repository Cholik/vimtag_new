/*!
\file       speed_statistic.h
\brief      speed statistic util
 ----history----
\author     chengzhiyong
\date       2011-07-24
\version    0.01
\desc       create
*/

#if !defined(__speed_statistic_h__)
#define __speed_statistic_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

typedef struct speed_statistic
{
    struct  
    {
        unsigned long       tick;
        unsigned long       tick_mul_for_fix_point; /* replace div to mul. for speed /s, refer tick. */

        long                counts;
        long                size;
        long                max;
        unsigned long       ref;

        unsigned long       start_tick;
        unsigned long       last_tick;
    }step;

    unsigned long           section_counts;
    struct
    {
        unsigned long       steps;
        unsigned long       steps_mul_for_fix_point;    /* replace div to mul. for speed /s */
        struct  
        {
            unsigned long   max_index;
            unsigned long   index;

            unsigned long   *counts;
            long            *size;
            long            *speed;
            long            *max;
            unsigned long   *ref;
        }his;

        struct  
        {
            unsigned long   steps_ready;
            unsigned long   steps_new;

            unsigned long   counts;
            long            size;
            long            speed;
            long            max;
            unsigned long   ref;
        }cur;
    }*section_1/* step 1 */, *sections;
}_speed_statistic;


#define speed_statistic_flag_his_counts 0x01
#define speed_statistic_flag_his_size   0x02
#define speed_statistic_flag_his_speed  0x04
#define speed_statistic_flag_his_max    0x08
#define speed_statistic_flag_his_ref    0x10
struct speed_statistic *speed_statistic_create(unsigned long step_tick, unsigned flag,
                                               unsigned long section_size,
                                               unsigned long section_counts, unsigned long *section_steps);
long speed_statistic_destroy(struct speed_statistic *stat);
long speed_statistic_push(struct speed_statistic *stat, unsigned long tick, long size, unsigned long ref);
long speed_statistic_log(struct speed_statistic *stat, void *fp/* FILE */);

long speed_statistic_test_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__speed_statistic_h__) */
