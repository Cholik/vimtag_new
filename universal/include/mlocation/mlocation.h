#if !defined(__mlocation_h__)
#define __mlocation_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "mlocation/mlocation_api.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "mlocation.debug.a")
#       else
#           pragma comment(lib, "mlocation.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "mlocation.debug.dll.lib")
#       else
#           pragma comment(lib, "mlocation.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mlocation_h__) */

