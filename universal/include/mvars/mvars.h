#if !defined(__mvars_h__)
#define __mvars_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "mvars/mvars_api.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "mvars.debug.a")
#       else
#           pragma comment(lib, "mvars.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "mvars.debug.dll.lib")
#       else
#           pragma comment(lib, "mvars.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mvars_h__) */

