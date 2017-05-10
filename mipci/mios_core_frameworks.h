#if !defined(__mining_ios_core_frameworks_h__)
#   define __mining_ios_core_frameworks_h__

#define _mprint_log_hack_prefix @
#define _mprintf_out_hack   NSLog
#define print_level 5
#include "mcore/mcore.h"

#if defined(_mprint_log_hack_prefix)
#   define NSString_format_s   "%@"
#   define NSString_format(_s) _s
#else
#   define NSString_format_s   "%p{%*.*s}"
#   define NSString_format(_s) (_s), 0, (_s)?((int)[(_s) length]):0, (_s)?[(_s) UTF8String]:NULL
#endif


#endif
