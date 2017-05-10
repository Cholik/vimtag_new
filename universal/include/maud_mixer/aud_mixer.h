/*!
\file       aud_mixer.h
\brief      audio mixer unit
----history----
\author     chengzhiyong
\date       2011-11-21
\version    0.01
\desc       create

$Author: chengzhiyong $
*/
#if !defined(__aud_mixer_h__)
#define __aud_mixer_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct aud_mixer;
struct aud_mixer_line;

struct aud_mixer *aud_mixer_create(unsigned long sample_bits, unsigned long sample_rate, unsigned long channel_counts, unsigned frame_samples);
long aud_mixer_destroy(struct aud_mixer *mixer);
struct aud_mixer_line *aud_mixer_line_create(struct aud_mixer *mixer);
long aud_mixer_line_destroy(struct aud_mixer_line *line);
long aud_mixer_line_add_data(struct aud_mixer_line *line, unsigned long time_stamp, 
                             unsigned long sample_bits, unsigned long sample_rate, unsigned long channels,
                             unsigned long data_size, unsigned char *data);
long aud_mixer_get_frame(struct aud_mixer *mixer, unsigned long time_wait,
                         unsigned char *buf, unsigned long buf_size,
                         unsigned long *data_size/* [out] */, unsigned long *time_stamp/* [out] can be NULL */);


#if defined(__cplusplus)
}
#endif

#endif /* !defined(__aud_mixer_h__) */

