#ifndef _MCARD_H
#define _MCARD_H

#ifdef __cplusplus
extern "C" {
#endif 

#include "mcard/mcard_api.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "mcard.debug.a")
#       else
#           pragma comment(lib, "mcard.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "mcard.debug.dll.lib")
#       else
#           pragma comment(lib, "mcard.dll.lib")
#       endif
#   endif
#endif

#ifdef __cplusplus
}
#endif

#endif
