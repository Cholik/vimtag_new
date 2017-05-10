/*
\file       gzip_file.h
\brief      gzip file unit

 ----history----
\author     chengzhiyong 
\date       2008-12-08
\version    0.01
\desc       create gzip unit by moving code from robot

$Author: chengzhiyong $
$Id: gzip.h,v 1.4 2008-06-02 12:54:50 chengzhiyong Exp $
*/

#if !defined(__gzip_file_h__)
#define __gzip_file_h__

#if defined(__cplusplus)
extern "C" {
#endif

/*!
func    gzip_get_file_info
\brief  get gzip file info, refer:rfc 1952
\param  data[in]            the compressed gzip file data
\param	len[in]             the length of the data
\param  start[out]          the data start pointer in gzip file
\param  data_size[out]      the size of the compressed data
\param  org_data_size[out]  the size of the origin data(uncompressed data)
\param  crc32[in]           the crc32 value of the data
\return get result
        #0                  succeed
        #other              error code
*/
long gzip_get_file_info(unsigned char   *data,
                        unsigned long   len,
                        unsigned char   **start/* [out] */,
                        unsigned long   *compress_size/* [out] */,
                        unsigned long   *uncompress_size/* [out] */,
                        unsigned long   *crc32/* [out] */);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__gzip_file_h__) */

