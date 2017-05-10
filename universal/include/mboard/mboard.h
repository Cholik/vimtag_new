#if !defined(__mboard_h__)
#define __mboard_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "mboard/mboard_api.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "mboard.debug.a")
#       else
#           pragma comment(lib, "mboard.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "mboard.debug.dll.lib")
#       else
#           pragma comment(lib, "mboard.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mboard_h__) */

