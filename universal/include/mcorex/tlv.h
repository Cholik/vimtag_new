#if !defined(__tlv_h__)
#define __tlv_h__

#if defined(__cplusplus)
extern "C" {
#endif

#define tlv_build_flag_auto_swap    1
typedef struct tlv_parse_info
{
    unsigned long           type;
    unsigned long           len;
    unsigned char           *data;
    unsigned long           i_value;
}_tlv_parse_info;

typedef struct tlv_build_info
{
    struct
    {
        unsigned long       len;
        unsigned char       data[9];
        unsigned char       reserved[3];
    }bytes;
    struct
    {
        unsigned long       len;
        unsigned char       *data;
    }bytes_ex;
}_tlv_build_info;

#define tlv_build( t, l, v, info ) tlv__build((t), (l), (v), 0, info )
#define tlv_build_char( t, v, info ) tlv__build((t), 1, (v), 1, info )
#define tlv_build_short( t, v, info ) tlv__build((t), 2, (v), 1, info )
#define tlv_build_long( t, v, info ) tlv__build((t), 4, (v), 1, info )

extern long tlv_parse( unsigned char *data, unsigned long data_len, struct tlv_parse_info *info  );
extern long tlv__build( unsigned char type, unsigned long len, unsigned char *value, unsigned long flag, struct tlv_build_info *build_info );


#if defined(__cplusplus)
}
#endif

#endif

