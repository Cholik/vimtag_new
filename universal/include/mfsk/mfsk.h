#ifndef _MFSK_H
#define _MFSK_H

#ifdef __cplusplus
extern "C"{
#endif 

#include "mfsk/mfsk_api.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "mfsk.debug.a")
#       else
#           pragma comment(lib, "mfsk.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "mfsk.debug.dll.lib")
#       else
#           pragma comment(lib, "mfsk.dll.lib")
#       endif
#   endif
#endif

#ifdef __cplusplus
}
#endif

#endif
