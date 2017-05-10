/*
\file		    mbits.h
\brief		    bits functions unit
 ----history----
\author         chengzhiyong
\date           2015-11-21
\version        0.01
\desc           create

*/
#if !defined(__mbits_h__)
#define  __mbits_h__

#if defined(__cplusplus)
extern "C" {
#endif

/* !!in big endian order */

#define mbit_read(_buf, _index) (((((unsigned char*)(_buf))[(_index) >> 3]) >> ((_index) & 0x7)) & 0x01)
#define mbit_write_1(_buf, _index) \
    do{\
        (((unsigned char*)(_buf))[(_index) >> 3]) |= 1 << (0x7 - ((_index) & 0x7));\
    }while(0)
#define mbit_write_0(_buf, _index) \
    do{\
        (((unsigned char*)(_buf))[(_index) >> 3]) &= ~(1 << (0x7 - ((_index) & 0x7)));\
    }while(0)
#define mbit_write(_buf, _index, _value) \
    do{\
        (((unsigned char*)(_buf))[(_index) >> 3]) = ((((unsigned char*)(_buf))[(_index) >> 3]) & (~(1 << (0x7 - ((_index) & 0x7))))) | ((1 & (_value)) << (0x7 - ((_index) & 0x7)));\
    while(0)

void mbits_copy(unsigned char *src, unsigned long src_bit_index, unsigned long bits, 
                unsigned char *dst, unsigned long dst_bit_index);
unsigned long mbits_read(unsigned char *src, unsigned long bit_index, unsigned long bits);
void mbits_write(unsigned char *buf, unsigned long bit_index, unsigned long bits, unsigned long value);

long mbits_util(long argc, char *argv[]);
#if defined(__cplusplus)
}
#endif

#endif /* !defined(__mbits_h__) */
