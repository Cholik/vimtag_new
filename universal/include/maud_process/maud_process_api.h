/*!
\file       maud_process_api.h
\brief      audio process unit
----history----
\author     chengzhiyong
\date       2013-01-10
\version    0.01
\desc       create

$Author: chengzhiyong $
*/
#if !defined(__maud_process_api_h__)
#define __maud_process_api_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct maud_process;

#define maud_process_flag_aec                0x001    /* enable Acoustic Echo Cancellation */
#define maud_process_flag_eq                 0x002    /* enable PCM time-domain equalizer */
#define maud_process_flag_agc                0x004    /* enable auto gain control */
#define maud_process_flag_ans                0x008    /* enable Automatic Noise Suppression */
#define maud_process_flag_debug_play_raw     0x010    /* enable debug flag, if enable will write wave file */
#define maud_process_flag_debug_capt_raw     0x040
#define maud_process_flag_debug_capt_aec     0x080
#define maud_process_flag_debug_capt_eq      0x100
#define maud_process_flag_debug_all          (maud_process_flag_debug_play_raw \
                                             | maud_process_flag_debug_capt_raw \
                                             | maud_process_flag_debug_capt_aec \
                                             | maud_process_flag_debug_capt_eq)
#if !defined(__maud_process_desc_defined)
#define __maud_process_desc_defefined
typedef struct maud_process_desc
{
    /* base params, need setting by caller */
    unsigned long           flag;               /*!< ref maud_process_flag_xxx */
    long                    sample_rate;        /*!< just support 16000 now */
    long                    frame_samples;      /*!< 1024 plz */
    long                    sample_bits;        /*!< sample bits */
    struct
    {
        unsigned long       len;
        char                *data;              /*!< if session exist, return exist one. */
    }session;

    /* proc params, can be set as zero as default */
    struct
    {
        long                frame_counts;       /*!< frame counts */
        unsigned long       tail_length;        /*!< 0: tail length, filter length, default as (room audio back 300ms/3) sample counts */
        long                suppress;           /*!< 0: default as -40 */ 
        long                suppress_active;    /*!< 0: default as -15 */ 
    }aec;
    struct
    {
         long               suppress;           /*!< 0: default as -30 */
    }ans;
    struct
    {
         float              level;              /*!< 0: default as 24000.0F */
         float              target;             /*!< 0: default as 24000.0F; */
         long               max_gain;           /*!< 0: default as 30 */
         long               increment;          /*!< 0: default as 12 */
         long               decrement;          /*!< 0: default as -40 */
    }agc;
    struct
    {
         unsigned long      counts;             /*!< 0: default as 10, eq setting counts */
         float              *values;            /*!< 0: default -20, -20, -20, -20, -10, 0, 0, 5, 10, 5 */
    }eq;

    /* debug params */
    struct
    {
        unsigned long       len;
        char                *data;              /*!< if session exist, return exist one. */
    }debug_path;
}_maud_process_desc;
#endif /* !defined(__maud_process_desc_defined) */
#define maud_process_desc_format_s   "%p{flag[%lx], sample_rate[%ld], frame_samples[%ld], session[%s]}"
#define maud_process_desc_format(_desc)  (_desc), (_desc)?(_desc)->flag:0, (_desc)?(_desc)->sample_rate:0, \
                                        (_desc)?(_desc)->frame_samples:0, \
                                        ((_desc) && (_desc)->session.len)?(_desc)->session.data:""

/*!
func    maud_process_create
\brief  create audio processor
\param  desc[in]                the desc
\return create result
        #NULL                   failed
        #<0                     error code
*/
struct maud_process *maud_process_create(struct maud_process_desc *desc);

/*!
func    maud_process_destroy
\brief  destroy audio process
\param  process[in]             the processor
\return destroy result
        #0                      succeed
        #other                  error code
*/
long maud_process_destroy(struct maud_process *proc);

/*!
func    maud_process_push
\brief  push 
\param  proc[in]                the audio processor
\param  is_capture[in]          is capture data, 0: play data, 1:capture data
\param  len[in]                 the data length
\param  data[in/out]            the audio pcm data
\param  tick[in]                the tick
\return destroy result
        #0                      succeed
        #other                  error code
*/
long maud_process_push(struct maud_process *proc, long is_capture, unsigned long len, unsigned char *data, unsigned long tick);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__maud_process_api_h__) */


