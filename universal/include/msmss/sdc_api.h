/*!
\file       sdc_api.h
\brief     

 ----history----
\author     Liuzp
\date       2014-05-22
\version    0.01
\desc       create

*/

#if !defined(__sdc_api_h__)
#define __sdc_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/* Fixed-length type define */
#if !defined(__int8_t_defined) && !defined(_INT8_T)
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

#if !defined(__ulong_defined)
#define __ulong_defined
typedef unsigned long                   ulong;
#endif

#if !defined(__uchar_defined)
#define __uchar_defined
typedef unsigned char uchar;
#endif

#if !defined(__ushort_defined)
#define __ushort_defined
typedef unsigned short ushort;
#endif

typedef enum data_type{
    data_type_byte,
    data_type_2bytes,
    data_type_4bytes,
    data_type_8bytes
}_data_type;

//   Error code
#define sdc_ok                        (-0)
#define sdc_param_invalid             (-1)
#define sdc_buffer_insufficient       (-2)
#define sdc_base_data_invalid         (-3)
#define sdc_base_data_type_invalid    (-4)
#define sdc_base_data_len_invalid     (-5)    
#define sdc_group_data_type_invalid   (-4)
#define sdc_group_data_len_invalid    (-5) 
#define sdc_group_data_invalid        (-6)
#define sdc_delta_len_invalid         (-7) 
#define sdc_delta_incomplete          (-8)  

long sdc_encode(
    const uchar* precord,   /* The head of the records */
    ulong record_num,       /* Record number */ 
    ulong record_len,       /* Distance between two fields */
    enum data_type tp,      /* The type of the value */ 
    ulong buff_len,         /* Buffer len */
    uchar* pbuff,           /* buffer for compress result */
    ulong* poutput_len,     /* The length after compressed */
    ulong* precord_encoded  /* The record handled */
    );
long sdc_decode(
    const uchar* pcomp,     /* The compressed data */
    ulong comp_len,        /* The length of the compressed data */
    ulong record_num,      /* Record number */ 
    enum data_type tp,     /* The data type of the field */  
    uchar* precord,         /* The head of the records */
    ulong record_len,       /* The sizeof the whole record */
    ulong* precord_decoded  /* Number of records decompressed from compressed data */
    );

#if defined(__cplusplus)
    }
#endif/* defined(__cplusplus) */

#endif /* !defined(__sdc_api_h__) */


