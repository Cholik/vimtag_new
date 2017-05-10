#if !defined(__mhal_api_h__)
#define __mhal_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/* Type in mhal_video_ctrl_param */
#define mhal_video_ctrl_type_brightness           1
#define mhal_video_ctrl_type_contrast             2
#define mhal_video_ctrl_type_saturation           3
#define mhal_video_ctrl_type_sharpness            4
#define mhal_video_ctrl_type_denoise_2d           5
#define mhal_video_ctrl_type_denoise_3d           6
#define mhal_video_ctrl_type_ae                   7
#define mhal_video_ctrl_type_flip                 10
#define mhal_video_ctrl_type_mirror               11
#define mhal_video_ctrl_type_power_freq           12
#define mhal_video_ctrl_type_fps                  13
#define mhal_video_ctrl_type_light_mode           14

/* Type in mhal_audio_ctrl_param */
#define mhal_audio_ctrl_type_volume_in              1
#define mhal_audio_ctrl_type_volume_out             2


/* Type in mhal_video_chl_ctrl_param */
#define mhal_video_chl_ctrl_type_idr               1
#define mhal_video_chl_ctrl_type_bitrate           2
#define mhal_video_chl_ctrl_type_fps               3
#define mhal_video_chl_ctrl_type_ip_interval       4

/* Module  in mhal_bitrate_param */
#define mhal_bitrate_mode_cbr      1
#define mhal_bitrate_mode_vbr      2
#define mhal_bitrate_mode_ecbr     3
#define mhal_bitrate_mode_evbr     4

/* Value of mhal_video_ctrl_type_power_freq */
#define mhal_power_freq_60hz        0
#define mhal_power_freq_50hz        1

#define mhal_max_gpio_counts        128

/* Mode in mhal_osd_create_param */
#define mhal_osd_mode_text                  1
#define mhal_osd_mode_img                   2

/* Type in mhal_osd_ctrl_param */
#define mhal_osd_ctrl_type_content          1

/* Type in mhal_gpio_ctrl_param */
#define mhal_gpio_ctrl_type_get                 1
#define mhal_gpio_ctrl_type_set                 2
#define mhal_gpio_ctrl_type_direction_input     3
#define mhal_gpio_ctrl_type_direction_output    4

/* Type in mhal_adc_ctrl_param */
#define mhal_adc_ctrl_type_get                 1

/* Type in mhal_watchdog_ctrl_param */
#define mhal_watchdog_ctrl_type_keeplive        1

/* Type in mhal_flash_ctrl_param */
#define mhal_flash_ctrl_type_read_data_len      1
#define mhal_flash_ctrl_type_write_data_len     2
#define mhal_flash_ctrl_type_read_data          3
#define mhal_flash_ctrl_type_write_data         4
#define mhal_flash_ctrl_type_read_exdata        5
#define mhal_flash_ctrl_type_write_exdata       6

/* Partion in mhal_flash_ctrl_param */
#define mhal_flash_partion_uboot                1
#define mhal_flash_partion_kernel               2
#define mhal_flash_partion_rootfs               3
#define mhal_flash_partion_user                 4
#define mhal_flash_partion_cfg                  5

typedef struct mhal_create_param
{
    long                    reserve;            /* Reserve field. Not use */
}_mhal_create_param;

typedef struct mhal_destroy_param
{
    void                    *mod;               /* Module  return by mhal_create */
}_mhal_destroy_param;

typedef struct mhal_video_ctrl_param
{
    void                    *mod;               /* Module  return by mhal_create */
    long                    type;               /* mhal_video_ctrl_type_xxxx */
    long                    value;              /* Param value for ctrl */
    long                    data_len;           /* Extend param data length */
    char                    *data;              /* Extend param data */
}_mhal_video_ctrl_param;

typedef struct mhal_bitrate_param
{
    long                    mode;               /* mhal_bitrate_mode_xxx */
    long                    bitrate;            /* target bitrate */
    long                    bitrate_max;        /* max bitrate */
    long                    quant;              /* Image quant */
}_mhal_bitrate_param;

typedef struct mhal_video_create_param
{
    void                    *mod;               /* Module  return by mhal_create */
}_mhal_video_create_param;

typedef struct mhal_video_destroy_param
{
    void                    *mod;               /* Module  return by mhal_create */
}_mhal_video_destroy_param;

typedef struct mhal_video_chl_create_param
{
    void                    *mod;               /* Module  return by mhal_create */
    long                    chl_id;             /* Video channel id */
    long                    fps;                /* Encode fps */
    long                    src_x;              /* Encode offset x value */
    long                    src_y;              /* Image offset y value */
    long                    src_width;          /* Encode source width */
    long                    src_height;         /* Encode source height */
    long                    dst_width;          /* Encode destination width */
    long                    dst_height;         /* Encode destination height */
    long                    ip_interval;        /* Interval for I-P frame */
    struct mhal_bitrate_param   bitrate_param;  /* Param for bitrate control */
}_mhal_video_chl_create_param;

typedef struct mhal_video_chl_destroy_param
{
    void                    *mod;               /* Module  return by mhal_create */
    long                    chl_id;             /* Video channel id */
}_mhal_video_chl_destroy_param;

typedef struct mhal_video_chl_ctrl_param
{
    void                    *mod;               /* Module  return by mhal_create */
    long                    chl_id;             /* Video channel id */
    long                    type;               /* mhal_video_chl_ctrl_type_xxxx */
    long                    value;              /* Param value for ctrl */
    long                    data_len;           /* Extend param data length */
    char                    *data;              /* Extend param data */
}_mhal_video_chl_ctrl_param;

typedef struct mhal_video_chl_read_param
{
    void                    *mod;               /* Module  return by mhal_create */
    char                    *buf;               /* Buffer for read. */
    long                    buf_len;            /* Buffer length. */

    long                    chl_id;             /* Video channel id for data return[out] */
    long                    data_len;           /* Read data length[out] */
}_mhal_video_chl_read_param;

typedef struct mhal_osd_create_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    chl_id;             /* Video channel id */
    long                    mode;               /* mhal_osd_mode_xxx */
    long                    x;                  /* Display offset x */
    long                    y;                  /* Display offset y */
    long                    data_len;           /* Display content length */
    char                    *data;              /* Display content */
}_mhal_osd_create_param;

typedef struct mhal_osd_destroy_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    chl_id;             /* Video channel id */
}_mhal_osd_destroy_param;

typedef struct mhal_osd_ctrl_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    chl_id;             /* Video channel id */
    long                    type;               /* mhal_osd_ctrl_type_xxxx */
    long                    value;              /* Param value for ctrl */
    long                    data_len;           /* Extend param data length */
    char                    *data;              /* Extend param data */
}_mhal_osd_ctrl_param;

typedef struct mhal_md_create_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    chl_id;             /* Video channel id */
    long                    sensitive;          /* Sensitive for motion detect */
}_mhal_md_create_param;

typedef struct mhal_md_destroy_param
{
    void                    *mod;               /* Module return by mhal_create */
}_mhal_md_destroy_param;

typedef struct mhal_md_read_param
{
    void                    *mod;               /* Module return by mhal_create */
    char                    *buf;               /* Buffer for read. */
    long                    buf_len;            /* Buffer length. */

    long                    chl_id;             /* Video channel id for data return[out] */
    long                    data_len;           /* Read data length[out] */
}_mhal_md_read_param;

typedef struct mhal_md_check_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    data_len;           /* Data length */
    char                    *data;              /* Data */
    long                    flag;               /* Check result. 1 indicate motion have been detected */
}_mhal_md_check_param;

typedef struct mhal_audio_create_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    sample_size;        /* Bit count for each sample */
    long                    speed;              /* Sample counts every minute */
    long                    buf_size;           /* Buffer size for audio[out] */
}_mhal_audio_create_param;

typedef struct mhal_audio_destroy_param
{
    void                    *mod;               /* Module return by mhal_create */
}_mhal_audio_destroy_param;

typedef struct mhal_audio_read_param
{
    void                    *mod;               /* Module return by mhal_create */
    char                    *buf;               /* Buffer for read. */
    long                    buf_len;            /* Buffer length. */
    long                    data_len;           /* Read data length[out] */
}_mhal_audio_read_param;

typedef struct mhal_audio_write_param
{
    void                    *mod;               /* Module return by mhal_create */
    char                    *buf;               /* Buffer for read. */
    long                    buf_len;            /* Buffer length. */
    long                    data_len;           /* Write data length[out] */
}_mhal_audio_write_param;

typedef struct mhal_audio_denoise_param
{
    void                    *mod;               /* Module return by mhal_create */
    char                    *buf;               /* Buffer for read. */
    long                    buf_len;            /* Buffer length. */
}_mhal_audio_denoise_param;

typedef struct mhal_audio_ctrl_param
{
    void                    *mod;               /* Module  return by mhal_create */
    long                    type;               /* mhal_audio_ctrl_type_xxxx */
    long                    value;              /* Param value for ctrl */
    long                    data_len;           /* Extend param data length */
    char                    *data;              /* Extend param data */
}_mhal_audio_ctrl_param;

typedef struct mhal_gpio_create_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    ids_counts;         /* Port count that need been change to gpio mode */
    long                    ids[mhal_max_gpio_counts];  /* Gpio port list */
}_mhal_gpio_create_param;

typedef struct mhal_gpio_destroy_param
{
    void                    *mod;               /* Module return by mhal_create */
}_mhal_gpio_destroy_param;

typedef struct mhal_gpio_ctrl_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    id;                 /* Gpio port id */
    long                    type;               /* mhal_gpio_ctrl_type_xxxx */
    long                    value;              /* Param value for ctrl */
    long                    data_len;           /* Extend param data length */
    char                    *data;              /* Extend param data */
}_mhal_gpio_ctrl_param;

typedef struct mhal_adc_create_param
{
    void                    *mod;               /* Module return by mhal_create */
}_mhal_adc_create_param;

typedef struct mhal_adc_destroy_param
{
    void                    *mod;               /* Module return by mhal_create */
}_mhal_adc_destroy_param;

typedef struct mhal_adc_ctrl_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    id;                 /* ADC port id */
    long                    type;               /* mhal_adc_ctrl_type_xxxx */
    long                    value;              /* Param value for ctrl */
    long                    data_len;           /* Extend param data length */
    char                    *data;              /* Extend param data */
}_mhal_adc_ctrl_param;

typedef struct mhal_watchdog_create_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    timeout;            /* Timeout for watchdog keeplive */
}_mhal_watchdog_create_param;

typedef struct mhal_watchdog_destroy_param
{
    void                    *mod;               /* Module return by mhal_create */
}_mhal_watchdog_destroy_param;

typedef struct mhal_watchdog_ctrl_param
{
    void                    *mod;               /* Module return by mhal_create */
    long                    type;               /* mhal_watchdog_ctrl_type_xxxx */
    long                    value;              /* Param value for ctrl */
    long                    data_len;           /* Extend param data length */
    char                    *data;              /* Extend param data */
}_mhal_watchdog_ctrl_param;

typedef struct mhal_flash_ctrl_param
{
    long                    type;               /* mhal_flash_ctrl_type_xxx */
    long                    partion;            /* Flash partion type. mhal_flash_partion_xxx */
    long                    offset;             /* Read or write offset */
    long                    value;              /* Value for write_data_len/read_data_len[in/out] */
    char                    *buf;               /* Buffer for read/write. */
    long                    buf_len;            /* Buffer length. */
    long                    data_len;           /* Write data length[out] */
}_mhal_flash_ctrl_param;

typedef void *(*mhal_api_create)( struct mhal_create_param *param );
typedef long (*mhal_api_destroy)( struct mhal_destroy_param *param );
typedef long (*mhal_api_video_create)( struct mhal_video_create_param *param );
typedef long (*mhal_api_video_destroy)( struct mhal_video_destroy_param *param );
typedef long (*mhal_api_video_ctrl)( struct mhal_video_ctrl_param *param );
typedef long (*mhal_api_video_chl_create)( struct mhal_video_chl_create_param *param );
typedef long (*mhal_api_video_chl_destroy)( struct mhal_video_chl_destroy_param *param );
typedef long (*mhal_api_video_chl_ctrl)( struct mhal_video_chl_ctrl_param *param );
typedef long (*mhal_api_video_chl_read)( struct mhal_video_chl_read_param *param );
typedef long (*mhal_api_osd_create)( struct mhal_osd_create_param *param );
typedef long (*mhal_api_osd_destroy)( struct mhal_osd_destroy_param *param );
typedef long (*mhal_api_osd_ctrl)( struct mhal_osd_ctrl_param *param );
typedef long (*mhal_api_md_create)( struct mhal_md_create_param *param );
typedef long (*mhal_api_md_destroy)( struct mhal_md_destroy_param *param );
typedef long (*mhal_api_md_read)( struct mhal_md_read_param *param );
typedef long (*mhal_api_md_check)( struct mhal_md_check_param *param );
typedef long (*mhal_api_audio_create)( struct mhal_audio_create_param *param );
typedef long (*mhal_api_audio_destroy)( struct mhal_audio_destroy_param *param );
typedef long (*mhal_api_audio_read)( struct mhal_audio_read_param *param );
typedef long (*mhal_api_audio_write)( struct mhal_audio_write_param *param );
typedef long (*mhal_api_audio_denoise)( struct mhal_audio_denoise_param *param );
typedef long (*mhal_api_audio_ctrl)( struct mhal_audio_ctrl_param *param );
typedef long (*mhal_api_gpio_create)( struct mhal_gpio_create_param *param );
typedef long (*mhal_api_gpio_destroy)( struct mhal_gpio_destroy_param *param );
typedef long (*mhal_api_gpio_ctrl)( struct mhal_gpio_ctrl_param *param );
typedef long (*mhal_api_adc_create)( struct mhal_adc_create_param *param );
typedef long (*mhal_api_adc_destroy)( struct mhal_adc_destroy_param *param );
typedef long (*mhal_api_adc_ctrl)( struct mhal_adc_ctrl_param *param );
typedef long (*mhal_api_watchdog_create)( struct mhal_watchdog_create_param *param );
typedef long (*mhal_api_watchdog_destroy)( struct mhal_watchdog_destroy_param *param );
typedef long (*mhal_api_watchdog_ctrl)( struct mhal_watchdog_ctrl_param *param );
typedef long (*mhal_api_flash_ctrl)( struct mhal_flash_ctrl_param *param );

#define mhal_video_channel_counts_max       4

typedef struct mhal_class
{
    long                    video_enc_channel_counts;
    long                    video_enc_width[mhal_video_channel_counts_max];
    long                    video_enc_height[mhal_video_channel_counts_max];
    
    mhal_api_create create;
    mhal_api_destroy destroy;
    mhal_api_video_create video_create;
    mhal_api_video_destroy video_destroy;
    mhal_api_video_ctrl video_ctrl;
    mhal_api_video_chl_create video_chl_create;
    mhal_api_video_chl_destroy video_chl_destroy;
    mhal_api_video_chl_ctrl video_chl_ctrl;
    mhal_api_video_chl_read video_chl_read;
    mhal_api_osd_create osd_create;
    mhal_api_osd_destroy osd_destroy;
    mhal_api_osd_ctrl osd_ctrl;
    mhal_api_md_create md_create;
    mhal_api_md_destroy md_destroy;
    mhal_api_md_read md_read;
    mhal_api_md_check md_check;
    mhal_api_audio_create audio_create;
    mhal_api_audio_destroy audio_destroy;
    mhal_api_audio_read audio_read;
    mhal_api_audio_write audio_write;
    mhal_api_audio_denoise audio_denoise;
    mhal_api_audio_ctrl audio_ctrl;
    mhal_api_gpio_create gpio_create;
    mhal_api_gpio_destroy gpio_destroy;
    mhal_api_gpio_ctrl gpio_ctrl;
    mhal_api_adc_create adc_create;
    mhal_api_adc_destroy adc_destroy;
    mhal_api_adc_ctrl adc_ctrl;
    mhal_api_watchdog_create watchdog_create;
    mhal_api_watchdog_destroy watchdog_destroy;
    mhal_api_watchdog_ctrl watchdog_ctrl;
    mhal_api_flash_ctrl flash_ctrl;
}_mhal_class;

extern struct mhal_class   mhal_obj;
extern long mhal_default( char *func, void *param );

#define mhal_api( func, param ) ( mhal_obj.func?mhal_obj.func(param):mhal_default( #func, (param)))
#define mhal_api_is_null( func ) ( mhal_obj.func == NULL )

#define mhal_create( param ) ( mhal_obj.create?mhal_obj.create(param):NULL)
#define mhal_destroy( param ) mhal_api( destroy, (param))
#define mhal_video_create( param ) mhal_api( video_create, (param))
#define mhal_video_destroy( param ) mhal_api( video_destroy, (param))
#define mhal_video_ctrl( param ) mhal_api( video_ctrl, (param))
#define mhal_video_chl_create( param ) mhal_api( video_chl_create, (param))
#define mhal_video_chl_destroy( param ) mhal_api( video_chl_destroy, (param))
#define mhal_video_chl_ctrl( param ) mhal_api( video_chl_ctrl, (param))
#define mhal_video_chl_read( param ) mhal_api( video_chl_read, (param))
#define mhal_osd_create( param ) mhal_api( osd_create, (param))
#define mhal_osd_destroy( param ) mhal_api( osd_destroy, (param))
#define mhal_osd_ctrl( param ) mhal_api( osd_ctrl, (param))
#define mhal_md_create( param ) mhal_api( md_create, (param))
#define mhal_md_destroy( param ) mhal_api( md_destroy, (param))
#define mhal_md_read( param ) mhal_api( md_read, (param))
#define mhal_md_check( param ) mhal_api( md_check, (param))
#define mhal_audio_create( param ) mhal_api( audio_create, (param))
#define mhal_audio_destroy( param ) mhal_api( audio_destroy, (param))
#define mhal_audio_read( param ) mhal_api( audio_read, (param))
#define mhal_audio_write( param ) mhal_api( audio_write, (param))
#define mhal_audio_denoise( param ) mhal_api( audio_denoise, (param))
#define mhal_audio_ctrl( param ) mhal_api( audio_ctrl, (param))
#define mhal_gpio_create( param ) mhal_api( gpio_create, (param))
#define mhal_gpio_destroy( param ) mhal_api( gpio_destroy, (param))
#define mhal_gpio_ctrl( param ) mhal_api( gpio_ctrl, (param))
#define mhal_adc_create( param ) mhal_api( adc_create, (param))
#define mhal_adc_destroy( param ) mhal_api( adc_destroy, (param))
#define mhal_adc_ctrl( param ) mhal_api( adc_ctrl, (param))
#define mhal_watchdog_create( param ) mhal_api( watchdog_create, (param))
#define mhal_watchdog_destroy( param ) mhal_api( watchdog_destroy, (param))
#define mhal_watchdog_ctrl( param ) mhal_api( watchdog_ctrl, (param))
#define mhal_flash_ctrl( param ) mhal_api( flash_ctrl, (param))

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif

