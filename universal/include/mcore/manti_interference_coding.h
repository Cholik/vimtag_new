/*!
\file       manti_interference_coding.h
\brief      anti interference coding unit

 ----history----
\author     chengzhiyong
\date       2014-10-08
\version    0.01
\desc       create

*/

#if !defined(__manti_interference_coding_h__)
#define __manti_interference_coding_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */


#define maicodec_err_base                       (-1)
#define maicodec_err_invalid_param              (maicodec_err_base - 0)
#define maicodec_err_buf_overflow               (maicodec_err_base - 1)
#define maicodec_err_unknown_state              (maicodec_err_base - 2)
#define maicodec_err_buf_alloc_failed           (maicodec_err_base - 3)

#define maicodec_border_type_inline             0       /*!< border inline, for big losting and inserting data, wifi config */
#define maicodec_border_type_outline            1       /*!< border outline, for continue bitstream, such as fsk */

/*!\brief codec desc */
typedef struct maicodec_desc
{
    struct
    {
        unsigned long type;                     /*!< code type, maicodec_type_xxxxx */
        unsigned long magic;                    /*!< magic value
                                                     # if maicodec_border_type_outline should bigger than the code max value, if uint8 bytes stream, should > 255(can be 256)
                                                     # if maicodec_border_type_inline, should smaller than the code min value, if wifi-code should be min udp frame size 
                                                */ 
        unsigned long start_magic_counts;       /*!< start magic counts, just for maicodec_border_type_inline */
        unsigned long magic_loop_segs;          /*!< magic loop seg distance, just for encode inline magic border */
    }border;

    struct
    {
        unsigned long payload_bits;             /* the code payload bits */
        unsigned long index_bits;               /* the code index bits
                                                   # if type == maicodec_border_type_outline, can be ZERO
                                                   # if type == maicodec_border_type_inline, power(2, index_bits) should equal or bigger than sizeof(seg)*/
        unsigned long checksum_bits;            /* the code checksum bits */
    }code;

    struct
    {
        unsigned long payload_bits;             /* the seg payload bits */
        unsigned long index_bits;               /* the seg index bits */
        unsigned long checksum_bits;            /* the seg checksum bits */
    }seg;
}_maicodec_desc;
#define maicodec_desc_format_s  "%p{border[{type[%ld], magic[%ld], start_magic_counts[%ld]}], code[{payload[%ld], index[%ld], checksum[%ld]}], "\
                                "seg[{payload[%ld], index[%ld], checksum[%ld]}]}"
#define maicodec_desc_format(_desc) (_desc), \
    (_desc)?(_desc)->border.type:0, (_desc)?(_desc)->border.magic:0, (_desc)?(_desc)->border.start_magic_counts:0,\
    (_desc)?(_desc)->code.payload_bits:0, (_desc)?(_desc)->code.index_bits:0, (_desc)?(_desc)->code.checksum_bits:0, \
    (_desc)?(_desc)->seg.payload_bits:0, (_desc)?(_desc)->seg.index_bits:0, (_desc)?(_desc)->seg.checksum_bits:0


#define maicodec_default_code_payload_bits      6
#define maicodec_default_code_index_bits        2
#define maicodec_default_code_checksum_bits     1
#define maicodec_default_seg_payload_bits       8
#define maicodec_default_seg_index_bits         8
#define maicodec_default_seg_checksum_bits      8

#define maicodec_default_start_magic_counts     8
#define maicodec_default_border_type            maicodec_border_type_inline

#define maicodec_default_border_inline_magic    44
#define maicodec_default_border_outline_magic   256

/*!
func    maicodec_encode
\brief  encode data with anti interference coding
\param  desc[in]                the codec desc, can be NULL, if NULL use default setttings
\param  len[in]                 the length of the data
\param  data[in]                the data
\param  codes_max_counts[in]    the codes max counts, refer codes buffer size
\param  codes[out]              the codes out-buffer
\return encode result
        #<=0                    error code 
        #other                  the output codes counts */
long maicodec_encode(struct maicodec_desc *desc, 
                     unsigned long len, unsigned char *data,  
                     unsigned long codes_max_counts, unsigned short *codes);

/*!
func    maicodec_decode_create 
\brief  create aicodec decode context
\param  desc[in]                the codec desc, can be NULL, if NULL use default setttings
\param  size[in]                the data buffer size
\param  buf[out]                the data buffer, can be NULL
                                #NULL  recv buffer alloc by this unit
                                #other outer recv buffer, don't free this buffer before decode finished
\return create result
        #NULL                   failed
        #other                  the context */
struct maicodec_decode_ctx *maicodec_decode_create(struct maicodec_desc *desc, unsigned long size, unsigned char *buf);

#define maicodec_decode_status_succeed      0x00
#define maicodec_decode_status_idle         0x01
#define maicodec_decode_status_loose_try    0x02
#define maicodec_decode_status_try          0x03
#define maicodec_decode_status_data         0x04
/*!
func    maicodec_decode_push
\brief  push code into decode ctx
\param  ctx[in]                 the decode ctx
\param  counts[in]              code counts
\param  codes[in]               potential codes
\param  len[out]                the length of recv data
\param  data[out]               recv data
\return decode result
        #<0                     error code
        #0                      not finished, still need more codes
        #>0                     status: maicodec_decode_status_xxx */
long maicodec_decode_push(struct maicodec_decode_ctx *ctx, unsigned long counts, unsigned short *codes,
                          unsigned long *len, unsigned char **data);

/*!
func    maicodec_decode_destroy
\brief  destroy decode ctx
\param  ctx[in]                 the decode ctx
\return destroy result
        #0                      succeed
        #<0                     error code */
long maicodec_decode_destroy(struct maicodec_decode_ctx *ctx);

/*!
func    maicodec_util_entry
\brief  maicodec util entry
\param  argc[in]                the args counts
\param  argv[in]                the args list
\return run result
        #0                      succeed
        #<0                     error code */
long maicodec_util_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__manti_interference_coding_h__) */
