/*
\file       audio_aac.h
\brief      audio/aac format header 

------history----------
\author     chengzhiyong
\date       2011-10-11
\version    0.01
\desc       create
*/

#if !defined(__mfmt_audio_aac_h__)
#define __mfmt_audio_aac_h__

#if defined(__cplusplus)
extern "C" {
#endif

#define     mfmt_aac_dec_spec_max_len    16

/*\brief  audio/aac format */
typedef struct mfmt_audio_aac
{
    /*!!!!!!!!!!!!those fields be send in rtdp-channel(mutp should be same), just accept little-endian 32bits data */
    unsigned int    sample_rate;                /*!< sample reate */
    unsigned int    kbps;                       /*!< kbps */
    unsigned int    dec_spec_len;               /*!< decoder specific info length */
    unsigned char   dec_spec[mfmt_aac_dec_spec_max_len]; /* decoder specific info buffer */
} _fmt_audio_aac; 
#define mfmt_audio_aac_format_s "%p{sample_rate[%ld], kbps[%ld], dec_spec_len[%ld], dec_spec[%02x,%02x,%02x,%02x...]}"
#define mfmt_audio_aac_format(_aac_fmt) (_aac_fmt), (_aac_fmt)?(_aac_fmt)->sample_rate:0, \
                                        (_aac_fmt)?(_aac_fmt)->kbps:0, (_aac_fmt)?(_aac_fmt)->dec_spec_len:0, \
                                        (_aac_fmt)?(_aac_fmt)->dec_spec[0]:0, (_aac_fmt)?(_aac_fmt)->dec_spec[1]:0, \
                                        (_aac_fmt)?(_aac_fmt)->dec_spec[2]:0, (_aac_fmt)?(_aac_fmt)->dec_spec[3]:0


/* 7 bytes 
#define mfmt_audio_aac_build_adts_header(_buf, _sample_size) \
    do \
    {\
    (_buf)[0] = 0xFF;\
    (_buf)[1] = 0xF9;\
    (_buf)[2] = 0x60;\
    (_buf)[3] = 0x40;\
    (_buf)[3] |= (unsigned char)(((_sample_size) & 0x1800) >> 11);\
    (_buf)[4] = (unsigned char)(((_sample_size) & 0x1FF8) >> 3);\
    sample->data[5] = (unsigned char)(((_sample_size) & 0x7) << 5);\
    sample->data[5] |= 0x1F;\
    sample->data[6] = 0xFC;\
    } while (0) */

typedef struct mfmt_audio_aac_config_info
{
    /* audio specific info */
    unsigned char object_type_index;
    unsigned char sample_frequency_index;
    unsigned short sample_frequency;           /* calculate from sample_frequency_index */
    unsigned char channels_configuration;
    unsigned char reserved[3];  /* for 4byte align */
}_mfmt_audio_aac_config_info;
typedef struct mfmt_audio_aac_adts_header
{
    unsigned char  *start;/*!< header start pointer to syncword start */
    unsigned long  size;  /*!< header size */

    /* fixed params */
    unsigned short syncword;                    
    unsigned char  id;
    unsigned char  layer;                /* 4byte1 */
    unsigned char  protection_absent; 
    unsigned char  private_bit;
    unsigned char  profile;
    unsigned char  sample_frequency_index;   /* 4byte1 */
    unsigned long  sample_frequency;     /* calculate from sample_frequency_index *//* 4byte1 */
    unsigned char  channels_configuration;
    unsigned char  original;
    unsigned char  home;
    unsigned char  emphasis;             /* 4byte1 */

    /* variable param */
    unsigned char  copyright_identification_bit;     
    unsigned char  copyright_identification_start;
    unsigned short aac_frame_length;    /* 4byte1 *//* include adts header 7bytes*/
    unsigned short adts_buffer_fullness;
    unsigned char  no_raw_data_blocks_in_frame;
    unsigned char  reserved1;
    unsigned short crc_check;           /* 4byte1 */
    unsigned char  reserved2[2];

}_mfmt_audio_aac_adts_header;

long mfmt_audio_aac_config_decode(unsigned char *conf/* 2 bytes or 5 bytes, normal is 2 */, unsigned long conf_len, struct mfmt_audio_aac_config_info *info);
/* <0:error code, other: return encode data length */
long mfmt_audio_aac_config_encode(unsigned char *buf,
                                  unsigned long buf_size,/* 2 or 5 bytes, normal is 2 */
                                  unsigned long object_type_index,
                                  unsigned long sample_frequency,
                                  unsigned long channels);
long mfmt_audio_aac_adts_header_decode(unsigned char *data/* 7 bytes */, unsigned long data_len, struct mfmt_audio_aac_adts_header *header);
long mfmt_audio_aac_adts_header_encode(unsigned char *buf, /* 7 bytes */
                                      unsigned long id,
                                      unsigned long layer,
                                      unsigned long profile,
                                      unsigned long sample_frequency,
                                      unsigned long channels,
                                      unsigned long frame_length/* not include adts header 7bytes*/);

#if defined(__cplusplus)
}
#endif
#endif /* !defined(__mfmt_audio_aac_h__) */

