/*!
\file       melib_openssl.h
\brief      openssl include header by mining

 ----history----
\author     chengzhiyong
\date       2012-01-06
\version    0.01
\desc       create
*/
#if !defined(__melib_openssl_h__)
#define __melib_openssl_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "openssl/melib_cryptos.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "libcrypto.debug.a")
#           pragma comment(lib, "libssl.debug.a")
#       else
#           pragma comment(lib, "libcrypto.a")
#           pragma comment(lib, "libssl.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "libcrypto.debug.lib")
#           pragma comment(lib, "libssl.debug.lib")
#		else
#           pragma comment(lib, "libcrypto.lib")
#           pragma comment(lib, "libssl.lib")
#		endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__melib_openssl_h__) */

