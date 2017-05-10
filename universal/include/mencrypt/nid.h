/*!
\file       nid.h
\brief      nid unit
----history----
\author     chengzhiyong
\date       2012-07-08
\version    0.01
\desc       create

$Author: chengzhiyong $
*/
#if !defined(__nid_h__)
#define __nid_h__

#if defined(__cplusplus)
extern "C" {
#endif

#include "mcore/pack.h"

#define nid_flag_checksum       0x01
#define nid_flag_seq            0x02
#define nid_flag_id             0x04
#define nid_flag_id_type        0x08
#define nid_flag_username       0x10
#define nid_flag_sharekey       0x20
#define nid_flag_password_md5   0x40
#define nid_flag_password       0x80

#define nid_id_type_sid         0x00
#define nid_id_type_tid         0x01
#define nid_id_type_lid         0x02

typedef struct nid_info
{
    unsigned long   flag;           /*!< flag, point witch value be assigned */
    unsigned long   seq;            /*!< seq no, *just for encode */
    unsigned long   id_type;        /*!< id type */
#if defined(_MSC_VER)
    unsigned __int64
#else
    unsigned long long
#endif
                    id;             /*!< session id | terminal id | login id */

    struct  
    {
        unsigned long   len;        /*!< data-length */
        unsigned char   *data;      /*!< data */
    }sharekey, username, password, password_md5, checksum, buf;
}_nid_info;

/*!
func    nid_encode
\brief  encode nid to string
\param  nid[in]                 the nid, ignore nid->checksum
\param  buf_size[in]            the buffer size
\param  buf[out]                the encoded string output buffer
\return encode data length
        #<0                     error
        #other                  the encoded result string length
*/
long nid_encode(struct nid_info *nid, unsigned long buf_size, unsigned char *buf);

/*!
func    nid_decode
\brief  decode string to nid
\param  data_len[in]            the data length
\param  data[in]                the data
\return decode result
        #NULL                   failed
        #other                  nid info, need call nid_destroy to free
*/
struct nid_info *nid_decode(unsigned long data_len, unsigned char *data);

/*!
func    nid_destroy
\brief  destroy nid
\param  nid[in]                 the nid, ignore nid->checksum
\return destroy result
        #0                      succeed
        #other                  error code
*/
long nid_destroy(struct nid_info *nid);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__nid_h__) */
