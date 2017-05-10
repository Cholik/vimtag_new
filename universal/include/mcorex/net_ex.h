/*!
\file       net_ex.h 
\brief      network extention unit, interface same as epoll
 ----history----
\author     chengzhiyong 
\date       2008-08-21
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: net_ex.h,v 1.7 2008-09-10 03:35:31 chengzhiyong Exp $
*/
#if !defined(__net_ex_h__)
#define __net_ex_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct in_addr;
struct sockaddr_in;

#if defined(_WIN32)
#   include <windows.h>
#elif defined(__rtthread__)
#   include <rtthread.h>
#   include <lwip/netdb.h>
#   include <lwip/sockets.h>
#else
#   include <sys/types.h>
#   include <sys/socket.h>
#   include <netinet/in.h>
#   include <arpa/inet.h>
#   include <fcntl.h>
#   include <unistd.h>
#   include <netdb.h>
#endif

#if !defined(__APPLE__) && !defined(__rtthread__) &&!defined(__ANDROID__) && !defined(WIN32)
    typedef unsigned int socklen_t;
#endif

#if defined(_epoll) /* have epoll */
#   include <sys/epoll.h>
/* for struct netx_event's event */
#   define netx_event_in       EPOLLIN
#   define netx_event_out      EPOLLOUT
#   define netx_event_et       EPOLLET
/* for netx_ctl()'s operation */
#   define netx_ctl_add        EPOLL_CTL_ADD
#   define netx_ctl_del        EPOLL_CTL_DEL
#   define netx_ctl_mod        EPOLL_CTL_MOD
/* struct netx_event */
#   define netx_event          epoll_event
#   define netx_create(max_counts) epoll_create(max_counts)
#   define netx_destroy(poll)   close(poll)
#   define netx_ctl(poll, operation, handle, event) epoll_ctl(poll, operation, handle, event)
#   define netx_wait(poll, events, max_events_counts, timeout) epoll_wait(poll, events, max_events_counts, timeout)

/* -----------------------have not epoll------------------- */
#else/* have not epoll, base normal socket */
/* for struct netx_event's event */
#   define netx_event_in        0x001
#   define netx_event_out       0x002
#   define netx_event_et        0x004
/* for netx_ctl()'s operation */
#   define netx_ctl_add        1
#   define netx_ctl_del        2
#   define netx_ctl_mod        3
    /* struct netx_event */
    struct netx_event
    {
        unsigned long           events;      /*!< events */
        union
        {
            void                *ptr;
            long                fd;
            unsigned            u32;
#   if defined(_MSC_VER) /* vc++ */
            unsigned __int64    u64;
#   else
            long long           u64;
#   endif
        }data;                  /* data */
    };
    long netx_create(unsigned long max_counts);
    long netx_destroy(long poll);
    long netx_ctl(long poll, unsigned long operation, long fd, struct netx_event *event);
    long netx_wait(long poll, struct netx_event *events, unsigned long max_events_counts, unsigned long timeout);
#endif /* defined(_epoll) else  */
/* -----------------------have not epoll------------------- */

/*! get socket name, used it at once(temp data just for 2 caller), output as "192.168.1.2<->202.201.0.1" */
const char *netx_stoa(long fd);

#define netx_open_flag_reuse_addr   0x01
long netx_open(long             type,   /* socket()'s type, SOCK_STREAM... */
               struct in_addr   *ip,    /* can be NULL, bind to 0.0.0.0 */
               unsigned long    port,   /* host bit order */
               unsigned long    flag    /* default 0 */);
long netx_connect_by_addr(struct sockaddr_in *addr,
                          struct sockaddr_in *local_addr);/* local-addr, if NULL ignore */
long netx_connect(char                  *host,
                  unsigned long         port,
                  struct in_addr        *local_ip,  /* can be NULL */
                  unsigned long         local_port, /* if 0, ignore local info, host bit order */
                  struct sockaddr_in    *addr);     /* [out] if NULL ignore*/
long netx_accept(long fd, struct sockaddr_in *addr/* [out] if NULL ignore*/);
/* [idle_ms, interval_ms, times] can be zero and then use default param
   mac os x not support these params.
   linux idle_ms look like second idle_ms be changed as at least 1 minuts, first idle keep user's setting?
*/
long netx_set_keepalive(long fd, long idle_ms, long interval_ms, long times);
long netx_get_local_ip(struct in_addr *addr/* [out] */);

/* for cross platform */
#if defined(_WIN32)
#ifndef WINCE
#   pragma comment(lib,"ws2_32.lib")
#else
#   pragma comment(lib,"ws2.lib")
#endif
#   define netx_close(fd)   closesocket(fd)
#	define netx_errno       WSAGetLastError()
#   define netx_eintr       WSAEINTR
#	define netx_ewouldblock WSAEWOULDBLOCK
#	define netx_econnreset  WSAECONNRESET
#else
#   define netx_close(fd)   close(fd)
#   define netx_errno       errno
#   define netx_eintr       EINTR
#   define netx_ewouldblock EWOULDBLOCK
#   define netx_econnreset  ECONNRESET
#endif

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__net_ex_h__) */

