
/*!
\file       maace_api.h
\brief      mining aac encoder api

 ----history----
\author     chengzhiyong
\date       2013-01-30
\version    0.01
\desc       create
*/
#if !defined(__maace_api_h__)
#define __maace_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct maace_encoder;

typedef struct maace_desc
{
    unsigned long   sample_bits;    /*!< sample bits */
    unsigned long   channels;       /*!< channels */
    unsigned long   sample_rate;    /*!< sample rates */
    unsigned long   frame_samples;  /*!< frame samples */
    long            adts;           /*!< is output as adts */
}_maace_desc;

typedef struct maace_info
{
    unsigned long   conf_len;
    unsigned char   *conf;
    unsigned long   max_out_bytes;
}_maace_info;

typedef struct maace_pack
{
    unsigned long       len;    /*!< buffer size, or data length */
    unsigned char       *buf;   /*!< buffer */
}_maace_pack;

/*!
func    maace_create
\brief  create aac encoder
\param  desc[in]                the audio desc
\param  info[out]               the encoder refer info
\return create result
        #NULL                   failed
        #<0                     error code
*/
typedef struct maace_encoder *(*maace_create_routine)(struct maace_desc *desc, struct maace_info *info);

/*!
func    maace_destroy
\brief  destroy aac encoder
\param  encoder[in]             the encoder
\return destroy result
        #0                      succeed
        #<0                     error code
*/
typedef long (*maace_destroy_routine)(struct maace_encoder *encoder);

/*!
func    maace_encode
\brief  encode audio from pcm to aac(/adts)
\param  encoder[in]             the encoder
\param  in[in]                  in pack
\param  out[out]                out pack
\return encoder result
        #0                      succeed
        #other                  error code
*/
typedef long (*maace_encode_routine)(struct maace_encoder *encoder, struct maace_pack *in, struct maace_pack *out);

#define maace_codec_magic   (*(long*)"maec   ")
typedef struct maace_codec
{
    char                    magic[sizeof(long)];
    struct 
    {
        unsigned long       len;
        char                *data; 
    }name;                                  /*!< name */
    maace_create_routine    create;         /*!< create decoder object */
    maace_destroy_routine   destroy;        /*!< destroy decoder object */
    maace_encode_routine    encode;         /*!< encode a frame */
}_maace_codec;

/*!
func    maace_init
\brief  init aac decode codec
\param  codec[in]               the codec
\return init result
        #0                      succeed
        #<0                     error code
*/
long maace_init(struct maace_codec *codec);

/*!
func    maace_uninit
\brief  uninit aac decode codec
\param  codec[in]               the codec
\return init result
        #0                      succeed
        #<0                     error code
*/
long maace_uninit(struct maace_codec *codec);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__maace_api_h__) */

