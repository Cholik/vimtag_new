/*!
\file       mserial.h
\brief      serial port communication 

 ----history----
\author     chengzhiyong
\date       2014-12-18
\version    0.01
\desc       create

*/  
#if !defined(__mserial_h__)
#   define __mserial_h__

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(WIN32)
    typedef HANDLE  mserial_t;
#   define mserial_invalid_handle       INVALID_HANDLE_VALUE
#   define mserial_t_format_s           "%p"
#   define mserial_t_format(_serial)    (_serial)
#   define mserial_name_format_s        "\\\\.\\COM%ld"
#   define mserial_name_format(_index)  ((_index) + 1)
#else
    typedef long    mserial_t;
#   define mserial_invalid_handle       -1
#   define mserial_t_format_s           "%ld"
#   define mserial_t_format(_serial)    (_serial)
#   define mserial_name_format_s        "/dev/ttyS%ld"
#   define mserial_name_format(_index)  (_index)
#endif

mserial_t mserial_open(char *name, long bund_rate);
long mserial_close(mserial_t serial);
long mserial_read(mserial_t serial, unsigned long size, unsigned char *buf, unsigned long timeout);
long mserial_write(mserial_t serial, unsigned long len, unsigned char *data);

long mserial_util(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif


#endif /* !defined(__mserial_h__) */