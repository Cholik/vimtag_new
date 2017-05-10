/*!
\file       mpubk.h
\brief      miniing public key unit

 ----history----
\author     chengzhiyong
\data       2013-04-01
\version    0.01
\desc       change data struct to json. support encrypto chip and more app
*/
#if !defined(__mining_pub_key_h__)
#define __mining_pub_key_h__

#if defined(__cplusplus)
extern "C" {
#endif

#define mlic_pubk_id_512bits_test   0
#define mlic_pubk_id_1024bits_test  1
#define mlic_pubk_id_component      2
#define mlic_pubk_id_mme            3
#define mlic_pubk_id_ipc            1
#define mlic_pubk_id_ccms_root      5
#define mlic_pubk_id_6              6
#define mlic_pubk_id_7              7
#define mlic_pubk_id_8              8
#define mlic_pubk_id_9              9
#define mlic_pubk_id_10             10

/*!
func mlic_get_pubk
\brief query public key, just save a public key,
       normal all software refer mining license need this,
       don't need free
\param id[in]                   key id, default is 0
\param bits[out]                key bits, default is 512
\param len[out]                 key length output pointer
\return the pub key
        #NULL                   failed
        #other                  the public key
*/
unsigned char *mlic_pubk_query(unsigned long id, unsigned long *bits, unsigned long *len);

/*!
func mlic_pemk_encode
\brief encode binary key to pem base64 text key
\param len[in]                  the bin data length
\param data[in]                 the bin data
\param type_len[in]             the type string lenth
\param type[in]                 the type string, such as "RSA PUBLIC KEY"
\param buf_size[in]             the out buffer size
\param buf[out]                 the out buffer
\return the pem key length
        #<0                     erro code
        #other                  the pem key length
*/
long mlic_pemk_encode(unsigned long len,        unsigned char *data, 
                      unsigned long type_len,   char          *type,
                      unsigned long buf_size,   unsigned char *buf);


/*!
func mlic_pemk_decode
\brief encode binary key to pem base64 text key
\param len[in]                  the bin data length
\param data[in]                 the bin data
\param type_len[out]            the key type
\param type[out]                the type
\param buf_size[in]             the out buffer size
\param buf[out]                 the out buffer
\return the pem key length
        #<0                     erro code
        #other                  the pem key length
*/
long mlic_pemk_decode(unsigned long len,          unsigned char *data, 
                      unsigned long *type_len,    char          **type,
                      unsigned long buf_size,     unsigned char *buf);

#if defined(__cplusplus)
}
#endif


#endif /* !defined(__mining_pub_key_h__) */

