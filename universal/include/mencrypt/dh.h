/*!
\file       D-H.h
\brief      D-H unit

 ----history----
\author     xionghuatao
\date       2010-7-15
\version    0.01
\desc       create

$Author: xionghuatao $
$Id: dh.h,v 1.14 2010-7-15 10:18:27 xionghuatao Exp $
*/
#ifndef __DH_H__
#define __DH_H__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */
    
#define dh_default_prime    "791658605174853458830696113306796803"
#define dh_default_root     "5"    

typedef struct dh_mod {
    struct len_str     prime;
    struct len_str     root;
    struct len_str     secret_key;
    struct len_str     public_key;
    struct len_str     share_key;
} _dh_mod;

/*!
func    dh_create
\brief  create dh module
\param  prime[in]               the big num prime
\param  root[in]                the primitive root of prime
\return the pointer to dh_mod
        #NULL                   failed
        #other                  dh module
*/
struct dh_mod *dh_create(struct len_str *prime, struct len_str *root);

/*!
func    dh_decode
\brief  decode a dh module from string
\param  data[in]                the dh module string
\return the pointer to dm_mod
        #NULL                   failed
        #other                  dh module
*/
struct dh_mod *dh_decode(struct len_str *data);

/*!
func    dh_encode
\brief  decode a dh module from string
\param  mod[in]                 the dh module
\param  type[in]                encode type, empty raw json-text,
                                "base64": output with mime
\param  buf_size[in]            the buffer size
\param  buf[out]                the buffer
\return the content length
        #<0                     error code
        #other                  the encoded content lenght
*/
long dh_encode(struct dh_mod *mod, char *type, unsigned long buf_size, char *buf);

/*!
func    dh_destroy
\brief  destroy dh module
\param  mod[in]                 the dh mod
\return the result
        #0                      success
        #other                  failed
*/
long dh_destroy(struct dh_mod *mod);

/*!
func    dh_get_public_key
\brief  get the public key
\param  mod[in]                 the dh mod
\return the point of public key
        #NULL                   fail
        #other                  the point
*/
struct len_str *dh_get_public_key (struct dh_mod *mod);

/*!
func    dh_get_share_key
\brief  generate the share key (equals with the remote share key)
\param  mod[in]                 the dh mod
\param  remote_key              the public key, got from the result of invoking function dh_get_public_key() remotely  
\return the point of public key
        #NULL                   fail
        #other                  the point
*/
struct len_str *dh_get_share_key (struct dh_mod *mod, struct len_str *remote_key);

/*!
func    dh_utils_entry
\brief  dh util entry
\param  argc[in]                 arg counts
\param  argv[in]                 arg value list
\return util run result
        #<0                     error code
        #other                  succeed
*/
long dh_utils_entry(long argc, char *argv[]);

long dh_generate_share_key ( struct len_str *in_prime, struct len_str *in_root,
                             struct len_str *in_secret_key_a, struct len_str *in_pub_key_b,
                             struct len_str *out_share_key );


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* defined(__DH_H__) */
