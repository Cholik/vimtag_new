/*!
\file       license.h
\brief      license unit

 ----history----
\author     TSH
\date       2011-12-1
\version    0.01
\desc       create

\author     chengzhiyong
\data       2012-06-10
\version    0.02
\desc       change data struct to json. support encrypto chip and more app
*/
#if !defined(__license_h__)
#define __license_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct json_object;

/*!
func mlic_req_code_encode
\brief encode register request code
\param key_bits[in]             key bits counts
\param pubk_len[in]             public key length
\param pubk[in]                 the RSA public key
\param content[in]              the content,
                                [mod] module name
                                [url] the url
                                [host] host
\param encode_type[in]          the encode type output into buffer, can be NULL
                                #"hex"      : output "data:application/octet-stream;hex..."
                                #"base64"   : output "data:application/octet-stream;base64..."
                                #"mining64" : output "data:application/octet-stream;mining64..."
                                #other      : raw
\param buf_size[in]             request code buffer size
\param buf[out]                 request code cert buffer
\return request code length
        #<0                     error code
        #other                  request code length
*/
long mlic_req_code_encode(unsigned long key_bits, 
                          unsigned long pubk_len,   unsigned char *pubk,
                          struct json_object *content,
                          char          *encode_type,
                          unsigned long buf_size,   unsigned char *buf);

/*!
func mlic_req_code_decode
\brief decode register request code, should call mlic_destroy to free result
\param key_bits[in]             key bits counts
\param prik_len[in]             private key length
\param prik[in]                 the RSA private key
\param data_len[in]             the request code length
\param data[in]                 the request code data
                                #start with "data:application/octet-stream;hex" is hex
                                #start with "data:application/octet-stream;base64" is base64
                                #start with "data:application/octet-stream;mining64" is mining64
                                #other raw
\return request json object
        #NULL                   failed
        #other                  json object
*/
struct json_object *mlic_req_code_decode(unsigned long key_bits, 
                                         unsigned long prik_len,   unsigned char *prik,
                                         unsigned long data_len,   unsigned char *data);

/*!
func mlic_cert_encode
\brief encode cert
\param key_bits[in]             key bits counts
\param prik_len[in]             private key length
\param prik[in]                 the RSA private key
\param content[in]              the content json
\param encode_type[in]          the encode type output into buffer, can be NULL
                                #"hex"      : output "data:application/octet-stream;hex..."
                                #"base64"   : output "data:application/octet-stream;base64..."
                                #"mining64" : output "data:application/octet-stream;mining64..."
                                #other      : raw
\param buf_size[in]             the cert buffer size
\param buf[out]                 the cert buffer
\return cert length
        #<0                     error code
        #other                  cert length
*/
long mlic_cert_encode(unsigned long key_bits, 
                      unsigned long prik_len,   unsigned char *prik,
                      struct json_object *content,
                      char          *encode_type, 
                      unsigned long buf_size,   unsigned char *buf);

/*!
func mlic_cert_decode
\brief decode cert, should call mlic_destroy to free result
\param key_bits[in]             key bits counts
\param prik_len[in]             private key length
\param prik[in]                 the RSA private key
\param data_len[in]             the data length
\param data[in]                 the data
                                #start with "data:application/octet-stream;hex" is hex
                                #start with "data:application/octet-stream;base64" is base64
                                #start with "data:application/octet-stream;mining64" is mining64
                                #other raw
\return cert json object
        #NULL                   failed
        #other                  json object
*/
struct json_object *mlic_cert_decode(unsigned long key_bits, 
                                     unsigned long pubk_len,    unsigned char *pubk,
                                     unsigned long len,         unsigned char *data);

/*!
func mlic_destroy
\brief mining license util entry
\param obj[in]                  return by mlic_xxx
\return destroy result
        #<0                     error code
        #other                  succeed
*/
long mlic_destroy(struct json_object *obj);

/*!
func mlic_build_key
\brief create key 
\param key_bits[in]             RSA private key and public digits
\param pubk_file[in]            public key file name
\param prik_file[in]            private key file name
\return create result
        #<0                     error code
        #other                  succeed
*/
long mlic_build_key(unsigned long key_bits, char *pubk_file, char *prik_file);

/*!
func mlic_check
\brief license check
\param cert[in]                 cert object
\param identify[in]             device identify
\return check result
        #0                      succeed
        #other                  error code
*/
long mlic_check(struct json_object *cert, struct json_object *identify);


/*!
func mlic_utils_entry
\brief mining license util entry
\param argc[in]                 arg counts
\param argv[in]                 arg value list
\return create result
        #<0                     error code
        #other                  succeed
*/
long mlic_utils_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif


#endif /* !defined(__license_h__) */

