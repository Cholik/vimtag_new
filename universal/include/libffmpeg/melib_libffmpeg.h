#if !defined(__libffmpeg_h__)
#define __libffmpeg_h__

#ifdef WINCE
#else
#   include <stdint.h>
#endif
#pragma pack(push, 8)
#include "libavcodec/avcodec.h"
#pragma pack(pop)

#if defined(_MSC_VER)
#   ifdef WINCE
#       pragma comment(lib, "libffmpeg_wm.lib")
#   else
#       if defined(_LIB)
#           pragma comment(lib, "libgcc.a")
#           pragma comment(lib, "libmingwex.a")
#           pragma comment(lib, "libavcodec.a")
#           pragma comment(lib, "libavformat.a")
#           pragma comment(lib, "libavutil.a")
#           pragma comment(lib, "libavcodec.a")
#       else
#           pragma comment(lib, "libavutil.dll.lib")
#           pragma comment(lib, "libswscale.dll.lib")
#           pragma comment(lib, "libavformat.dll.lib")
#           pragma comment(lib, "libavcodec.dll.lib")
#       endif
#   endif
#endif

#endif /* __libffmpeg_h__ */

