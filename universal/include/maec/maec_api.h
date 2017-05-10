#if !defined(__maec_api_h__)
#define __maec_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#define MAEC_SAMPLATE_RATE              16000
#define MAEC_SAMPLE_ARRIVE_INTERVAL_MAX 400

/* TSA: Time Synchronous Averaging */
#define MAEC_TSA_WINDOW_BIT             9
#define MAEC_TSA_WINDOW_SIZE            (1<<MAEC_TSA_WINDOW_BIT)
#define MAEC_TSA_STEP_SIZE              160

#define MAEC_SAMPLE_BUF_SEC             2
#define MAEC_SAMPLE_BUF_TICK            (MAEC_SAMPLE_BUF_SEC*1000)
#define MAEC_SAMPLE_BUF_SIZE            (MAEC_SAMPLE_BUF_SEC*MAEC_SAMPLATE_RATE)

#define MAEC_VSEEK_SEC                  3
#define MAEC_VSEEK_TICK                 (MAEC_VSEEK_SEC*1000)
#define MAEC_VSEEK_BUF_SIZE             (MAEC_SAMPLATE_RATE*MAEC_VSEEK_SEC/MAEC_TSA_STEP_SIZE)
#define MAEC_VSEEK_VOICE_COUNT_MAX      ( MAEC_VSEEK_BUF_SIZE/3 )
#define MAEC_VSEEK_VOICE_COUNT_MIN      ( MAEC_VSEEK_BUF_SIZE/10 )
#define MAEC_VSEEK_TSA_DELTA_MIN_BIT    3
#define MAEC_VSEEK_VOICE_TH_MIN         256
#define MAEC_VSEEK_VOICE_TH_MAX         2048
#define MAEC_VSEEK_VOICE_DELTA_MIN      512
#define MAEC_VSEEK_VOICE_HOWL_TH        20000

#define MAEC_VOICE_MONITOR_SEC          2
#define MAEC_VOICE_MONITOR_TICK         (MAEC_VOICE_MONITOR_SEC*1000)
#define MAEC_VOICE_MONITOR_SIZE         (MAEC_SAMPLATE_RATE*MAEC_VOICE_MONITOR_SEC/MAEC_TSA_STEP_SIZE)

#define MAEC_SUPRESS_VOICE_MIN          47
#define MAEC_SUPRESS_TICK               700
#define MAEC_SUPRESS_TICK_DELTA         300

typedef struct maec_create_param
{
    long                    reserve;
}_maec_create_param;

typedef struct maec_queue
{
    int32_t                 capacity;       /* buf capacity */
    uint32_t                total;          /* enque counts */
    int32_t                 *buf;
    int32_t                 pos;            /* current pos */

    long                    flag_sum;       /* whether need sum */
    int32_t                 sum;            /* sum of all value */

    long                    flag_sort;      /* whether need sort */
    int32_t                 *sort_buf;
    uint32_t                counts;         /* valid counts */
    int32_t                 min;            /* min value */
    int32_t                 max;            /* max value */

    long                    tick;           /* tick */
}_maec_queue;

typedef struct maec_channel
{
    struct maec_queue       queue_sample;
    struct maec_queue       queue_noise;
    struct maec_queue       queue_abs_sample;
    struct maec_queue       queue_tsa;
    struct maec_queue       queue_voice;

    long                    tsa_samples_counts;     /* sample counts of latest tsa step */

    long                    voice_th;
    long                    voice_on;
    long                    voice_on_tsa;

    long                    supress_tick;
    long                    supress;
}_maec_chnnel;

typedef struct maec_mod
{
    struct maec_create_param    create_param;

    struct maec_channel     chl_remote;
    struct maec_channel     chl_local;

    long                    aec_enable;
    long                    ns_enable;
    long                    tick_current;
}_maec_mod; 

extern struct maec_mod *maec_create( struct maec_create_param *param );
extern long maec_destroy( struct maec_mod *mod );
extern long maec_local_write( struct maec_mod *mod, char *buf, long buf_len );
extern long maec_remote_write( struct maec_mod *mod, char *buf, long buf_len );
extern long maec_aec_enable( struct maec_mod *mod, long enable  );
extern long maec_ns_enable( struct maec_mod *mod, long enable  );

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif
