#if !defined(__mrss_h__)
#define __mrss_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "mrss/mrss_api.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "mrss.debug.a")
#       else
#           pragma comment(lib, "mrss.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "mrss.debug.dll.lib")
#       else
#           pragma comment(lib, "mrss.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mrss_h__) */

