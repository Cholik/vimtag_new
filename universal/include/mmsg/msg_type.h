/*!
\file       msg_type.h
\brief      message type unit

 ----history----
\author     chengzhiyong
\date       2007-10-10
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: msg_type.h,v 1.2 2008-09-01 11:45:04 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__message_type_h__)
#define __message_type_h__

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
/*! \brief message default size is 64k */
#define msg_default_total_size (0x10000 - 0x20 - 1)/* 1 for append end ZERO char */
#define msg_default_size (msg_default_total_size - sizeof(struct message))

#define msg_version_mask_big_endian     0x80    /* b10000000 */
#define msg_version_mask_header_size    0x7c    /* b01111100 , value directly always 4 bytes align */
#define msg_version_mask_id             0x03    /* b00000011 */
#define msg_version_id_binary           0x00
#define msg_version_id_json             0x01

#define msg_flag_mask_trace             0x0f    /* b00001111 trace flag */
#define msg_flag_mask_trace_full        0x08    /* b00001000 */
#define msg_flag_mask_trace_msg         0x04    /* b00000100 */
#define msg_flag_mask_trace_info        0x02    /* b00000010 */
#define msg_flag_mask_trace_err         0x01    /* b00000001 */
#define msg_flag_mask_bit64             0x10    /* b00010000 */
#define msg_flag_mask_encrypt           0x20    /* b0010000 */
#define msg_flag_mask_counts            0xc0    /* b11000000 */
#define msg_flag_counts_inc_value       0x20    /* b01000000 , if save then add */

#define msg_age_mask_type               0xc000  /* b11000000 00000000 */
#define msg_age_type_year               0xc000  /* b11000000 */
#define msg_age_type_day                0x8000  /* b10000000 */
#define msg_age_type_hour               0x4000  /* b01000000 */
#define msg_age_type_second             0x0000  /* b00000000 */
#define msg_age_mask_value              0x3fff  /* b00111111 11111111 */

/*! \brief message base struct */
#pragma pack(push, 1)
typedef struct message
{
    uint8_t         version;            /*!< version */
    uint8_t         flag;               /*!< flag, trace flag and counts */
    uint16_t        age;                /*!< message age, for cache */

    uint32_t        size;               /*!< total size, include self header  */

    uint32_t        check_sum;          /*!< check sum */
    uint32_t        flag_ex;            /*!< flag ex current zero */    

    int32_t         from;               /*!< from component-id, usually should be sender-id */
    int32_t         to;                 /*!< receiver id, like email's sendto */
    int32_t         from_handle;        /*!< the sender handle of the user data */
    int32_t         to_handle;          /*!< the receiver handle of the user data*/

    uint64_t        data_base_addr;     /*!< data base addr */

    uint32_t        type_magic;         /*!< type magic */
    char            type[4];            /*!< message type, include '\0', at least use 4 times bytes, */
}_message;
#pragma pack(pop)

/*! \brief message struct refer macro */
#define msg_max_header_len()                (msg_version_mask_header_size)
#define msg_sizeof_header(_type_len)        (sizeof(struct message) + ((_type_len) & 0xfffffffc))
#define msg_sizeof(_type_len, _data_len)    (msg_sizeof_header(_type_len) + (((_data_len) + 4) & 0xfffffffc))

#define msg_get_big_endian(_msg)            ((_msg)->version & msg_version_mask_big_endian)
#define msg_get_header_size(_msg)           ((_msg)->version & msg_version_mask_header_size)
#define msg_get_version_id(_msg)            ((_msg)->version & msg_version_mask_id)
#define msg_set_version(_msg, _is_big_endian, _header_size, _id) \
            (_msg)->version = (unsigned char)(((_is_big_endian)?msg_version_mask_big_endian:0)\
                             | ((_header_size) & msg_version_mask_header_size) \
                             | ((_id) & msg_version_mask_id))

#define msg_clear_flag(_msg)                (_msg)->flag = 0
#define msg_get_trace_falg(_msg)            ((_msg)->flag & msg_flag_mask_trace)
#define msg_set_trace_flag(_msg, _value)    (_msg)->flag |= ((_value) & msg_flag_mask_trace)
#define msg_get_bit64_flag(_msg)            ((_msg)->flag & msg_flag_mask_bit64)
#define msg_set_bit64_flag(_msg)            ((_msg)->flag |= msg_flag_mask_bit64)
#define msg_get_encrypt_flag(_msg)          ((_msg)->flag & msg_flag_mask_encrypt)
#define msg_set_encrypt_flag(_msg)          ((_msg)->flag |= msg_flag_mask_encrypt)
#define msg_get_counts_flag(_msg)           ((_msg)->flag & msg_flag_mask_counts)
#define msg_inc_counts_flag(_msg)           (_msg)->flag = (0xff & ((_msg)->flag + msg_flag_counts_inc_value))
#define msg_clear_counts_flag(_msg)         ((_msg)->flag -= (_msg)->flag & msg_flag_mask_counts)

#define msg_get_age(_msg)                    /* return seconds */\
            ((0 == ((_msg)->age & msg_age_mask_type))?((unsigned long)((_msg)->age & msg_age_mask_value)):\
                ((msg_age_type_hour == ((_msg)->age & msg_age_mask_type))?((unsigned long)60*60*((_msg)->age & msg_age_mask_value)):\
                    (((msg_age_type_day == ((_msg)->age & msg_age_mask_type))?((unsigned long)24*60*60*((_msg)->age & msg_age_mask_value)):\
                        ((unsigned long)365*24*60*60*((_msg)->age & msg_age_mask_value))))))
#define msg_set_age(_msg, _value/* seconds */)    \
            if((_value) <= msg_age_mask_value){(_msg)->age = (uint16_t)(_value);}\
            else if((_value) <= (60*60*msg_age_mask_value)){(_msg)->age = (uint16_t)( msg_age_type_hour | ((_value)/(60*60)));}\
            else if((_value) <= (24*60*60*msg_age_mask_value)){(_msg)->age = (uint16_t)( msg_age_type_day | ((_value)/(24*60*60)));}\
            else{(_msg)->age = (uint16_t)( msg_age_type_year | ((_value)/(365*24*60*60)));};

#define msg_get_size(_msg)		            (_msg)->size
#define msg_set_size(_msg, _value)          (_msg)->size = (_value)
#define msg_get_data_size(_msg)             ((_msg)->size - msg_get_header_size(_msg))
#define msg_get_data(_msg)                  (((char*)_msg) + msg_get_header_size(_msg))
#define msg_get_data_base_addr(_msg)        (_msg)->data_base_addr
#define msg_set_data_base_addr(_msg, _value) (_msg)->data_base_addr = (uint64_t)(unsigned long)(_value)
#define msg_set_data_end_char(_msg)         *(((char*)_msg) + msg_get_size(_msg) - 1) = 0

#define msg_get_to(_msg)                    (_msg)->to
#define msg_set_to(_msg, _value)            (_msg)->to = (_value)
#define msg_get_from(_msg)                  (_msg)->from
#define msg_set_from(_msg, _value)          (_msg)->from = (_value)
#define msg_get_from_handle(_msg)           (_msg)->from_handle
#define msg_set_from_handle(_msg, _value)   (_msg)->from_handle = (_value)
#define msg_get_to_handle(_msg)             (_msg)->to_handle
#define msg_set_to_handle(_msg, _value)     (_msg)->to_handle = (_value)

#define msg_get_check_sum(_msg)		        (_msg)->check_sum
#define msg_set_check_sum(_msg, _value)     (_msg)->check_sum = (_value)

#define msg_get_flag_ex(_msg)		        (_msg)->flag_ex
#define msg_set_flag_ex(_msg, _value)       (_msg)->flag_ex = (_value)

#define msg_get_type_magic(_msg)            (_msg)->type_magic
#define msg_set_type_magic(_msg, _value)    (_msg)->type_magic = (_value)
#define msg_get_type(_msg)                  ((char*)&(_msg)->type)
#define msg_set_type(_msg, type_str, type_str_len)   \
            do{ *(uint32_t*)&(_msg)->type[(type_str_len) & 0xfffffffc] = 0;\
                memcpy(&(_msg)->type, (type_str), (type_str_len));}while(0)
#define msg_get_type_len(_msg)               \
            (msg_get_header_size(_msg)>=sizeof(struct message))?((msg_get_header_size(_msg) - sizeof(struct message))\
                + ((0 == *(((char*)(_msg)) + msg_get_header_size(_msg) - 4))?0:\
                    ((0 == *(((char*)(_msg)) + msg_get_header_size(_msg) - 3))?1:\
                        ((0 == *(((char*)(_msg)) + msg_get_header_size(_msg) - 2))?2:3)))):0

#define msg_format_s    "%p{type[%*.*s], from[%08lx:%08lx], to[%08lx:%08lx], size[%ld{header[%ld]}], ver[%ld], big_endian[%ld], bit64[%ld]}"
#define msg_format(_msg) \
                        (_msg), (int)0, (int)((_msg)?msg_get_type_len(_msg):0), (_msg)?msg_get_type(_msg):NULL,\
                        (long)((_msg)?msg_get_from(_msg):0), (unsigned long)((_msg)?msg_get_from_handle(_msg):0),\
                        (long)((_msg)?msg_get_to(_msg):0), (long)((_msg)?msg_get_to_handle(_msg):0),\
                        (long)((_msg)?msg_get_size(_msg):0), (long)((_msg)?msg_get_header_size(_msg):0),\
                        (long)((_msg)?msg_get_version_id(_msg):0), (long)((_msg)?msg_get_big_endian(_msg):0),\
                        (long)((_msg)?msg_get_bit64_flag(_msg):0)
                        

#endif /* !defined(__message_type_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
