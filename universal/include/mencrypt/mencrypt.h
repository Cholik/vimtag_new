/*!
\file       mencrypt.h
\brief      mencrypt unit

 ----history----
\author     xionghuatao
\date       2010-7-15
\version    0.01
\desc       create

$Author: xionghuatao $
$Id: dh.h,v 1.14 2010-7-15 10:18:27 xionghuatao Exp $
*/
#if !defined(__mencrypt_h__)
#define __mencrypt_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(mframework_version_disable)
#include "mcore/mframework_version.h"
#endif
#include "mencrypt/dh.h"
#include "mencrypt/nid.h"
#include "mencrypt/mdes.h"
#include "mencrypt/mpass.h"

#if defined(_MSC_VER)
/* get mframework prefix */
#   undef  mlib_mframework_prefix__local
#   if !defined(mlib_mframework_prefix)
#       define mlib_mframework_prefix__local
#       define mlib_mframework_prefix   "mencrypt"
#   endif
/* comment lib */
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, mlib_mframework_prefix".debug.a")
#       else
#           pragma comment(lib, mlib_mframework_prefix".a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, mlib_mframework_prefix".debug.dll.lib")
#       else
#           pragma comment(lib, mlib_mframework_prefix".dll.lib")
#       endif
#   endif
/* clear flag */
#   if defined(mlib_mframework_prefix__local)
#       undef  mlib_mframework_prefix__local
#       undef  mlib_mframework_prefix
#   endif
#endif  /* defined(_MSC_VER) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mencrypt_h__) */
