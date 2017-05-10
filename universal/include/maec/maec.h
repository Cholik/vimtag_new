#if !defined(__maec_h__)
#define __maec_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "maec/maec_api.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "maec.debug.a")
#       else
#           pragma comment(lib, "maec.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "maec.debug.dll.lib")
#       else
#           pragma comment(lib, "maec.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__maec_h__) */

