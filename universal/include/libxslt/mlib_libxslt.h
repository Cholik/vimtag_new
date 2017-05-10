/*!
\file       melib_libxslt.h
\brief      libxslt include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_libxslt_h__)
#define __melib_libxslt_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "libxslt/libxslt.h"
#include "libxslt/xslt.h"
#include "libxslt/xsltInternals.h"
#include "libxslt/transform.h"
#include "libxslt/xsltutils.h"
#include "libxslt/imports.h"

#if defined(_MSC_VER)   /* add by czy */
#   if defined(_LIB)
#       pragma comment(lib, "libxslt_a.lib")
#   else
#       pragma comment(lib, "libxslt.lib")
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_libxslt_h__) */
