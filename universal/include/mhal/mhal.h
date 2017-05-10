#if !defined(__mhal_h__)
#define __mhal_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "mhal/mhal_api.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "mhal.debug.a")
#       else
#           pragma comment(lib, "mhal.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "mhal.debug.dll.lib")
#       else
#           pragma comment(lib, "mhal.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mhal_h__) */


