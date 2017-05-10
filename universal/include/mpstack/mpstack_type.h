/*
\file		mpstack_type.h
\brief		mining protocol stack for ARM/embed and windows system.
            provide by mining technology
 ----history----
\author     chengzhiyong
\date       2011-03-09
\version    0.01
\desc       create

$Author: chengzhiyong $
*/

#if !defined(__mpstack_type_h__)
#define  __mpstack_type_h__

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(_C166)/* in embed box */
    typedef char                        int8_t;
    typedef short int                   int16_t;
    typedef long                        int32_t;
    typedef unsigned short int          uint16_t;
    typedef unsigned long               uint32_t;
#else
#if !defined(__int8_t_defined)
#   define __int8_t_defined
    typedef char                        int8_t;
    typedef short int                   int16_t;
    typedef int                         int32_t;
#   if defined(_MSC_VER)
    typedef __int64                 int64_t;
#   else 
    typedef long long int           int64_t;
#   endif
#endif
#if !defined(__uint32_t_defined)
#   define __uint32_t_defined
    typedef unsigned char               uint8_t;
    typedef unsigned short int          uint16_t;
    typedef unsigned int                uint32_t;
#   if defined(_MSC_VER)
    typedef unsigned __int64        uint64_t;
#   else 
    typedef unsigned long long int  uint64_t;
#   endif
#   endif
#endif

#if defined(__cplusplus)
}
#endif

#endif /*!defined(__mpstack_type_h__) */