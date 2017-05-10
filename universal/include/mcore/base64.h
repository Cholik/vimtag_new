/*!
\file       base64.h
\brief      base64 parse unit

 ----history----
\author     chengzhiyong
\date       2010-10-08
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: base64.h,v 1.3 2008-07-11 10:43:46 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__base64_h__)
#define __base64_h__

#define basex_flag_base64               0x00
#define basex_flag_mining64             0x01
#define basex_flag_mining32             0x02
#define basex_flag_type_mask            0x03
#define basex_flag_encode_pad           0x04
#define basex_flag_encode_try_A         0x08
#define basex_flag_encode_lf            0x00
#define basex_flag_encode_crlf          0x20

#define base64_encode( data, data_len, buf, buf_size ) basex_encode( (data), (data_len), (buf), (buf_size), 0, basex_flag_base64 )
#define base64_decode( data, data_len, buf, buf_size ) basex_decode( (data), (data_len), (buf), (buf_size), basex_flag_base64 )
#define mining64_encode( data, data_len, buf, buf_size ) basex_encode( (data), (data_len), (buf), (buf_size), 0, basex_flag_mining64 )
#define mining64_decode( data, data_len, buf, buf_size ) basex_decode( (data), (data_len), (buf), (buf_size), basex_flag_mining64 )
#define mining32_encode( data, data_len, buf, buf_size ) basex_encode( (data), (data_len), (buf), (buf_size), 0, basex_flag_mining32 )
#define mining32_decode( data, data_len, buf, buf_size ) basex_decode( (data), (data_len), (buf), (buf_size), basex_flag_mining32 )
#define mining32A_encode( data, data_len, buf, buf_size ) basex_encode( (data), (data_len), (buf), (buf_size), 0, basex_flag_mining32 | basex_flag_encode_try_A)


/*!
func    basex_decode
\brief  decode base64/mining64/mining32 string as binary data
\param  data[in]                the source data to be encoded
\param  data_len[in]            length of source data
\param  buf[out]                the encoded string output buffer
\param  buf_size[in]            length of encoded string
\param  flag[in]                the flag, refer basex_flag_xxxx
\return decoded data length
        #-1                     error
        #other                  the encoded result string length
*/
long basex_decode(unsigned char *data, unsigned long data_len, 
                  unsigned char *buf,  unsigned long buf_size, 
                  unsigned long flag);

/*!
func    basex_encode
\brief  encode data to base64/mining64/mining32 string
\param  data[in]                the source data to be encoded
\param  data_len[in]            length of source data
\param  buf[out]                the encoded string output buffer
\param  buf_size[in]            length of encoded string
\param  flag[in]                the flag, refer basex_flag_xxxx
\param  line_len[in]            line length, if ZERO will not insert new line
\return encoded string length
        #-1                     error
        #other                  the encoded result string length
*/
long basex_encode(unsigned char *data,    unsigned long data_len,
                  unsigned char *buf,     unsigned long buf_size,
                  unsigned long line_len, unsigned long flag);

#endif /* !defined(__base64_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
    
