#if !defined(__mh264_jpg_h__)
#define __mh264_jpg_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "mh264_jpg/mh264_jpg_api.h"

#if defined(_MSC_VER)
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, "mh264_jpg.debug.a")
#       else
#           pragma comment(lib, "mh264_jpg.a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, "mh264_jpg.debug.dll.lib")
#       else
#           pragma comment(lib, "mh264_jpg.dll.lib")
#       endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mh264_jpg_h__) */

