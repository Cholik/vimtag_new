/*!
\file       mime.h
\brief      mime type unit

 ----history----
\author     chengzhiyong
\date       2008-08-24
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: mime.h,v 1.1 2008-09-01 11:22:17 chengzhiyong Exp $
*/
#if !defined(__mime_h__)
#define __mime_h__
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#define mime_octet_stream	"application/octet-stream"

/*! \breif get mime type by file ext, return const lower string */
const char *mime_get_by_ext(char *ext, unsigned long ext_len, unsigned long *type_len/* [out], can be NULL, if NULL ignore */);
/*! \breif get mime type by file name, return const lower string */
const char *mime_get_by_filename(char *file_name, unsigned long file_name_len, unsigned long *type_len/* [out], can be NULL, if NULL ignore */);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
#endif /* !defined(__mime_h__) */
