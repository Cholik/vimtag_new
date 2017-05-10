/*!
\file       metp_frame_codec.h
\brief      mining endpoint transport protocol

 ----history----
\author     chengzhiyong
\date       2013-07-10
\version    0.01
\desc       create
*/

#if !defined(__metp_frame_codec_h__)
#define __metp_frame_codec_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

/* ---------------------fix size int define--------------------- */
#if !defined(metp_int_type_need_define)
#   define metp_int_type_need_define   1
#endif
#if defined(metp_int_type_need_define) && metp_int_type_need_define
typedef unsigned char   u8_t;
typedef unsigned short  u16_t;
typedef unsigned int    u32_t;
#endif /* !defined(metp_int_type_defined) */
/* ---------------------fix size int define--------------------- */

struct metp_frame_head;
struct metp_chunk_ctl_head;
struct metp_chunk_ack_head;
struct metp_chunk_dat_head;
struct metp_chunk_ack_record_head;
struct metp_chunk_ctl;
struct metp_chunk_dat;
struct metp_chunk_ack;
union  metp_frame_chunk;
struct metp_frame;

/* -------------netowrk bits order in/out macro tool------------ */
#define metp_u16_read(_buf) (((((unsigned char*)(_buf))[0]) << 8) | (((unsigned char*)(_buf))[1]))
#define metp_u32_read(_buf) (((((unsigned char*)(_buf))[0]) << 24) \
                                | ((((unsigned char*)(_buf))[1]) << 16) \
                                | ((((unsigned char*)(_buf))[2]) << 8) \
                                | (((unsigned char*)(_buf))[3]))
#define metp_u16_write(_buf, _val) \
    do{\
        (((unsigned char*)(_buf))[0]) = ((_val) >> 8) & 0xff;\
        (((unsigned char*)(_buf))[1]) = (_val) & 0xff;\
    }while(0)
#define metp_u32_write(_buf, _val) \
    do{\
        (((unsigned char*)(_buf))[0]) = ((_val) >> 24) & 0xff;\
        (((unsigned char*)(_buf))[1]) = ((_val) >> 16) & 0xff;\
        (((unsigned char*)(_buf))[2]) = ((_val) >> 8) & 0xff;\
        (((unsigned char*)(_buf))[3]) = (_val) & 0xff;\
    }while(0)
/* -------------netowrk bits order in/out macro tool------------ */

/* -------------bit tool---------------------------------------- */
#define metp_bit_read(_buf, _index) (((((unsigned char*)(_buf))[(_index) >> 3]) >> ((_index) & 0x7)) & 0x01)
#define metp_bit_write_1(_buf, _index) \
    do{\
        (((unsigned char*)(_buf))[(_index) >> 3]) |= 1 << (0x7 - ((_index) & 0x7));\
    }while(0)
#define metp_bit_write_0(_buf, _index) \
    do{\
        (((unsigned char*)(_buf))[(_index) >> 3]) &= ~(1 << (0x7 - ((_index) & 0x7)));\
    }while(0)
#define metp_bit_write(_buf, _index, _value) \
    do{\
        (((unsigned char*)(_buf))[(_index) >> 3]) = ((((unsigned char*)(_buf))[(_index) >> 3]) & (~(1 << (0x7 - ((_index) & 0x7))))) | ((1 & (_value)) << (0x7 - ((_index) & 0x7)));\
    while(0)
/* -------------bit tool---------------------------------------- */

/* ---------------------tlv in/out macro tool------------------- */
#define metp_tvl_pad_align  4           /*!< 4 bytes align */
#define metp_tlv_head_size  2           /*!< tlv header size */
#define metp_tlv_size_by_vlen(_vlen)    ((metp_tlv_head_size + (_vlen) + (metp_tvl_pad_align - 1)) & 0xfffffffc)
#define metp_tlv_pad_size(_vlen)        (metp_tlv_size_by_vlen(_vlen) - metp_tlv_head_size - (_vlen))
#define metp_tlv_head_type_read(_buf)    ((((unsigned char*)(_buf))[0]) >> 3)
/* size == (len + 4-bytes-align-padding) */
#define metp_tlv_head_read(_buf, _type_pt, _vlen_pt, _size_pt) \
    do{\
        *(_type_pt) = ((((unsigned char*)(_buf))[0]) >> 3); \
        *(_vlen_pt) = (((((unsigned char*)(_buf))[0]) & ((1 << 3) - 1)) << 8) | (((unsigned char*)(_buf))[1]); \
        *(_size_pt) = metp_tlv_size_by_vlen(*(_vlen_pt));\
    }while(0)
#define metp_tlv_head_write(_buf, _type, _vlen) \
    do{\
        (((unsigned char*)(_buf))[0]) = (((_type) & 0x1f) << 3) | (((_vlen)>> 8) & 0x7);\
        (((unsigned char*)(_buf))[1]) = (_vlen) & 0xff;\
    }while(0)
/* ---------------------tlv in/out macro tool------------------- */


/* ---------------------frame-------------------------------- */
/* tlv */
#define metp_frame_type_base            0   /*!< base frame */
#define metp_frame_type_base_confusion  1   /*!< base confusion frame */
#define metp_frame_type_base_encrypt    2   /*!< base encrypted frame */

#define metp_frame_type_default         metp_frame_type_base_confusion

#define metp_frame_fid_size             6   /*!< fid size */
typedef struct metp_frame_head
{
    u16_t               type:5;             /*!< frame type */
    u16_t               len:11;             /*!< frame data length */
    u8_t                fid[metp_frame_fid_size];/*!< forward id */
    u32_t               checksum;           /*!< check sum */
    u16_t               seq;                /*!< this frame seq */
    u16_t               recv_seq;           /*!< recv frame seq */
    u32_t               seq_timestamp;      /*!< the timestamp(us) when sendout this frame */
    u32_t               recv_seq_timestamp; /*!< the timestamp(us) when recived frame with recv-seq */
}_metp_frame_head;
#define metp_frame_head_size         sizeof(struct metp_frame_head)

#define metp_frame_fid_is_zero(_fid)  ((0 == ((unsigned char*)(_fid))[0]) && (0 == ((unsigned char*)(_fid))[1])\
                                       && (0 == ((unsigned char*)(_fid))[2]) && (0 == ((unsigned char*)(_fid))[3])\
                                       && (0 == ((unsigned char*)(_fid))[4]) && (0 == ((unsigned char*)(_fid))[5]))
#define metp_frame_fid_copy(_src, _dst) \
    do{\
        ((unsigned char*)(_dst))[0] = ((unsigned char*)(_src))[0];\
        ((unsigned char*)(_dst))[1] = ((unsigned char*)(_src))[1];\
        ((unsigned char*)(_dst))[2] = ((unsigned char*)(_src))[2];\
        ((unsigned char*)(_dst))[3] = ((unsigned char*)(_src))[3];\
        ((unsigned char*)(_dst))[4] = ((unsigned char*)(_src))[4];\
        ((unsigned char*)(_dst))[5] = ((unsigned char*)(_src))[5];\
    }while(0)
#define metp_frame_fid_cmp(_fid1, _fid2) \
       ((((unsigned char*)(_fid1))[0] != ((unsigned char*)(_fid2))[0]) \
        || (((unsigned char*)(_fid1))[1] != ((unsigned char*)(_fid2))[1])\
        || (((unsigned char*)(_fid1))[2] != ((unsigned char*)(_fid2))[2])\
        || (((unsigned char*)(_fid1))[3] != ((unsigned char*)(_fid2))[3])\
        || (((unsigned char*)(_fid1))[4] != ((unsigned char*)(_fid2))[4])\
        || (((unsigned char*)(_fid1))[5] != ((unsigned char*)(_fid2))[5]))
/* ---------------------frame-------------------------------- */

/* -------------------frame.chunk---------------------------- */
typedef struct metp_chunk_head
{
    u16_t               type:5;
    u16_t               dlen:11;
    u16_t               reserved;
}_metp_chunk_head;

/* tlv */
#define metp_chunk_type_ctl         0
#define metp_chunk_type_ack         1
#define metp_chunk_type_dat         2
#define metp_chunk_type_timestamp   3
/* -------------------frame.chunk---------------------------- */

/* -----------------frame.chunk.ctl-------------------------- */
typedef struct metp_chunk_ctl_head
{
    u16_t               type:5;             /*!< frame type */
    u16_t               len:11;             /*!< frame data length */
    u16_t               ctl_type;           /*!< ctl type */
}_metp_chunk_ctl_head;
#define metp_chunk_ctl_head_size    sizeof(struct metp_chunk_ctl_head)
/* -----------------frame.chunk.ctl-------------------------- */

/* -----------------frame.chunk.dat-------------------------- */
typedef struct metp_chunk_dat_head
{
    u16_t               type:5;             /*!< frame type */
    u16_t               len:11;             /*!< frame data length */
    u16_t               freq_head:1;        /*!< freq head flag */
    u16_t               freq_tail:1;        /*!< freq tail flag */
    u16_t               queue:2;            /*!< queue id */
    u16_t               freq_id:12;         /*!< freq id */
}_metp_chunk_dat_head;
#define metp_chunk_dat_head_size    sizeof(struct metp_chunk_dat_head)
#define metp_frag_id_max_delta      (1 << 11)
#define metp_frag_id_max            ((1 << 12) - 1)
/* -----------------frame.chunk.dat-------------------------- */

/* -----------------frame.chunk.ack-------------------------- */
typedef struct metp_chunk_ack_head
{
    u16_t               type:5;
    u16_t               dlen:11;
    u16_t               reserved;
}_metp_chunk_ack_head;

typedef struct metp_chunk_ack_record_head
{
    u16_t               type:2;             /*!< ack type, 0:bitmap */
    u16_t               queue:2;            /*!< queue id */
    u16_t               freq_id:12;         /*!< chunk id */
    u8_t                bitmap_bytes;       /*!< bitmap bytes length */
    u8_t                reserved;           /*!< 4byte algin */
}_metp_chunk_ack_record_head;
#define metp_chunk_ack_record_head_size 3

#define metp_chunk_ack_record_type_bitmap   0
/* -----------------frame.chunk.ack-------------------------- */


/* ---------------------metp frame------------------------------------ */
typedef struct metp_chunk_ctl
{
    struct
    {
        unsigned long           len;
        unsigned char           *data;
    }body;
    struct metp_chunk_ctl_head  head;        /*!< dat chunk head */
}_metp_chunk_ctl;

typedef struct metp_chunk_dat
{
    struct
    {
        unsigned long           len;
        unsigned char           *data;
    }body;
    struct metp_chunk_dat_head  head;        /*!< dat chunk head */
}_metp_chunk_dat;

typedef struct metp_chunk_ack
{
    struct
    {
        unsigned long           len;
        unsigned char           *data;
    }body;
    struct metp_chunk_ack_head  head;        /*!< dat chunk head */
    
    unsigned long               records_counts;
    struct
    {
        struct metp_chunk_ack_record_head head;        /*!< ack chunk ctx */
        unsigned char           *data;
    }records[4];
}_metp_chunk_ack;

typedef struct metp_chunk_base
{
    struct
    {
        unsigned long           len;
        unsigned char           *data;
    }body;
    struct metp_chunk_ack_head  head;        /*!< dat chunk head */
}_metp_chunk_base;

typedef struct metp_chunks
{
    unsigned long               counts;
    union
    {
        struct metp_chunk_base  base;
        struct metp_chunk_ctl   ctl;
        struct metp_chunk_dat   dat;
        struct metp_chunk_ack   ack;
    }list[4];
}_metp_chunks;

typedef struct metp_frame
{
    struct metp_frame_head      head;
    unsigned char               *body;
}_metp_frame;
/* ---------------------metp frame------------------------------------ */

/* ---------------------error code---------------------------------- */
#define metp_err_frame_codec_base                                 -100
#define metp_err_frame_codec_invalid_param                        (metp_err_frame_codec_base - 1)
#define metp_err_frame_codec_dlen_overflow                        (metp_err_frame_codec_base - 2)
#define metp_err_frame_codec_type_unknown                         (metp_err_frame_codec_base - 3)
#define metp_err_frame_codec_uncomplete                           (metp_err_frame_codec_base - 4)
#define metp_err_frame_codec_head_overflow                        (metp_err_frame_codec_base - 5)
#define metp_err_frame_codec_chunk_counts_overflow                (metp_err_frame_codec_base - 6)
#define metp_err_frame_codec_chunk_type_unknown                   (metp_err_frame_codec_base - 7)
#define metp_err_frame_codec_chunk_overflow                       (metp_err_frame_codec_base - 8)
#define metp_err_frame_codec_chunk_head_uncomplete                (metp_err_frame_codec_base - 9)
#define metp_err_frame_codec_chunk_uncomplete                     (metp_err_frame_codec_base - 9)
#define metp_err_frame_codec_chunk_ctl_head_overflow              (metp_err_frame_codec_base - 10)
#define metp_err_frame_codec_chunk_ctl_value_overflow             (metp_err_frame_codec_base - 11)
#define metp_err_frame_codec_chunk_dat_head_overflow              (metp_err_frame_codec_base - 12)
#define metp_err_frame_codec_chunk_ack_head_overflow              (metp_err_frame_codec_base - 12)
#define metp_err_frame_codec_chunk_ack_records_counts_overflow    (metp_err_frame_codec_base - 13)
#define metp_err_frame_codec_chunk_ack_bitmap_overflow            (metp_err_frame_codec_base - 14)
#define metp_err_frame_codec_chunk_ack_type_unknown               (metp_err_frame_codec_base - 15)
#define metp_err_frame_codec_chunk_ack_uncomplete                 (metp_err_frame_codec_base - 16)
/* ---------------------error code---------------------------------- */


/* ---------------------metp confustion----------------------------- */
/*!
func    metp_frame_base_confusion_encode
\brief  frame base confusion encode
\param  data[in]                the data
\param  len[in]                 the data length, at least >= metp_frame_header_size
\return encode result
        #0                      succeed
        #other                  error code
*/
long metp_frame_base_confusion_encode(unsigned char *data, unsigned long size);

/*!
func    metp_frame_base_confusion_decode
\brief  frame base confusion decode
\param  data[in]                the data
\param  len[in]                 the data length, at least >= metp_frame_header_size
\return decode result
        #0                      succeed
        #other                  error code
*/
long metp_frame_base_confusion_decode(unsigned char *data, unsigned long size);
/* ---------------------metp confustion----------------------------- */

/* ---------------------metp codec api------------------------------ */
/*!
func    metp_chunks_decode
\brief  deocde chunks
\param  len[in]                 the data length
\param  data[in]                the data
\param  chunks[out]             the chunks
\return decode result
        #0                      succeed
        #other                  error code
*/
long metp_chunks_decode(unsigned long len, unsigned char *data, struct metp_chunks *chunks);

/*!
func    metp_frame_decode
\brief  deocde metp frame, need loop call metp_frame_decode until ret==len
\param  len[in]                 the data length
\param  data[in]                the data
\param  frame[out]              the frame output buffer
\return decode result
        #>=0                    decoded data length
        #other                  error code
*/
long metp_frame_decode(unsigned long len, unsigned char *data, struct metp_frame *frame);

/*!
func    metp_frame_header_encode
\brief  encode frame header
\param  data_len[in]            the data length
\param  fid[in]                 the fid
\param  seq[in]                 the seq no
\param  recv_seq[in]            the recv seq no
\param  seq_timestamp[in]       the timestamp(us) when send out this frame
\param  recv_seqtimestamp[in]   the timestamp(us) when recv the frame with recv_seq
\param  buf[in/out]             the buffer start used to save frame header.
                                and chunks is save start from (buf + metp_frame_header_size)
\return total frame size
        #<0                     error code
        #other                  encoded frame size
*/
long metp_frame_header_encode(unsigned long  data_len,      unsigned char *fid,
                              unsigned short seq,           unsigned short recv_seq, 
                              unsigned long  seq_timestamp, unsigned long recv_seq_timestamp,
                              unsigned char  *buf);

/*!
func    metp_frame_dat_encode
\brief  encode dat frame
\param  len[in]                 the data length
\param  data[in]                the data
\param  buf_size[in]            the buffer size
\param  buf[out]                the buffer
\return encode result
        #<0                     error code
        #other                  encoded frame size
*/
long metp_frame_dat_encode(unsigned long len,      unsigned char *data,
                           unsigned long buf_size, unsigned char *buf);

/*!
func    metp_frame_ack_encode
\brief  deocde metp frame
\param  counts[in]              the queue counts
\param  queues[in]              the queue id list
\param  freg_counts[in]         the freq counts list
\param  freg_ids[in]            the freq ids list
\param  buf_size[in]            the buffer size
\param  buf[out]                the buffer
\return encode result
        #<0                     error code
        #other                  encoded frame size
*/
long metp_frame_ack_encode(unsigned long counts,
                           unsigned long *queues, unsigned long *freg_counts, unsigned long **freq_ids,
                           unsigned long buf_size,unsigned char *buf);
/* ---------------------metp codec api------------------------------ */

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__metp_frame_codec_h__) */

