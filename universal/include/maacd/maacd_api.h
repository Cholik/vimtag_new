
/*!
\file       maacd_api.h
\brief      mining aac decoder api

 ----history----
\author     chengzhiyong
\date       2013-01-30
\version    0.01
\desc       create
*/
#if !defined(__maacd_api_h__)
#define __maacd_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct maacd_decoder;

typedef struct maacd_desc
{
    long            atds;           /*!< if 0:raw data, 1; data with adts header */
    unsigned long   conf_len;       /*!< conf data length */
    unsigned char   *conf;          /*!< conf data */
}_maacd_desc;

typedef struct maacd_info
{
    unsigned long   sample_bits;
    unsigned char   channels;
    unsigned long   sample_rate;
    unsigned long   frame_samples;
}_maacd_info;

typedef struct maacd_pack
{
    unsigned long       len;    /*!< buffer size, or data length */
    unsigned char       *buf;   /*!< buffer */
}_maacd_pack;

/*!
func    maacd_create
\brief  create aac decoder
\param  desc[in]                the decoder refer data
\param  info[out]               the decoder info
\return create result
        #NULL                   failed
        #<0                     error code
*/
typedef struct maacd_decoder *(*maacd_create_routine)(struct maacd_desc *desc, struct maacd_info *info);

/*!
func    maacd_destroy
\brief  destroy aac decoder
\param  decoder[in]             the decoder
\return destroy result
        #0                      succeed
        #<0                     error code
*/
typedef long (*maacd_destroy_routine)(struct maacd_decoder *decoder);

/*!
func    maacd_decode
\brief  decode aac audio to pcm
\param  decoder[in]             the decoder
\param  in[in]                  in pack
\param  out[out]                out pack
\return decode result
        #0                      succeed
        #other                  error code
*/
typedef long (*maacd_decode_routine)(struct maacd_decoder *decoder, struct maacd_pack *in, struct maacd_pack *out);

#define maacd_codec_magic   (*(long*)"madc   ")
typedef struct maacd_codec
{
    char                    magic[sizeof(long)];
    struct 
    {
        unsigned long       len;
        char                *data; 
    }name;                                  /*!< name */
    maacd_create_routine    create;         /*!< create decoder object */
    maacd_destroy_routine   destroy;        /*!< destroy decoder object */
    maacd_decode_routine    decode;         /*!< decode a frame */
}_maacd_codec;

/*!
func    maacd_init
\brief  init aac decode codec
\param  codec[in]               the codec
\return init result
        #0                      succeed
        #<0                     error code
*/
long maacd_init(struct maacd_codec *codec);

/*!
func    maacd_uninit
\brief  uninit aac decode codec
\param  codec[in]               the codec
\return uninit result
        #0                      succeed
        #<0                     error code
*/
long maacd_uninit(struct maacd_codec *codec);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__maacd_api_h__) */

