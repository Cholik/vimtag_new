#if !defined(__mptz_h__)
#define __mptz_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "mptz_api.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "mptz.debug.a")
#       else
#           pragma comment(lib, "mptz.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "mptz.debug.dll.lib")
#       else
#           pragma comment(lib, "mptz.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mptz_h__) */

