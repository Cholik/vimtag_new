#if !defined(__melib_libpcap_h__)
#define __melib_libpcap_h__

#if defined(WIN32)
#   if defined(inline)
#       undef inline
#   endif
#endif
#include "pcap/pcap.h"

#if defined(_MSC_VER)
#    pragma comment(lib, "iphlpapi.lib")
#    pragma comment(lib, "wpcap.lib")
#endif

#endif /* __melib_libpcap_h__ */

