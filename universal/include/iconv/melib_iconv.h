/*!
\file       melib_iconv.h
\brief      iconv include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_iconv_h__)
#define __melib_iconv_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "iconv/iconv.h"

#if defined(_MSC_VER)   /* add by czy */
#   if defined(_LIB)
#       pragma comment(lib, "iconv_a.lib")
#   else
#       pragma comment(lib, "iconv.lib")
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_iconv_h__) */
