/*!
\file       melib_libxml.h
\brief      libxml include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_libxml_h__)
#define __melib_libxml_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if defined(_MSC_VER)   /* add by czy */
#   if defined(_LIB)
#       pragma comment(lib, "libxml2_a.lib")
#   else
#       pragma comment(lib, "libxml2.lib")
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_libxml_h__) */
