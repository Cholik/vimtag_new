/*!
\file       data_confustion.h
\brief      data confustion unit

 ----history----
\author     chengzhiyong
\date       2012-05-06
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: base64.h,v 1.3 2008-07-11 10:43:46 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__data_confusion_h__)
#define __data_confusion_h__

#define data_confusion_magic_byte   0xb7
#define data_confusion_encode(_magic_byte, _buf, _size )\
    do\
    {\
        unsigned char   __data_confusion_decode_xxx_magic_byte = (unsigned char)(_magic_byte), \
                        *__data_confusion_decode_xxx = (unsigned char*)&(_buf)[0],\
                        *__data_confusion_decode_xxx_end = __data_confusion_decode_xxx + (_size);\
        while(__data_confusion_decode_xxx < __data_confusion_decode_xxx_end)\
        {\
            __data_confusion_decode_xxx_magic_byte ^= *__data_confusion_decode_xxx;\
            *__data_confusion_decode_xxx = __data_confusion_decode_xxx_magic_byte;\
            ++__data_confusion_decode_xxx;\
        }\
    }while(0)

#define data_confusion_decode(_magic_byte, _buf, _size )\
    do\
    {\
        unsigned char   __data_confusion_decode_xxx_magic_byte = (unsigned char)(_magic_byte), \
                        *__data_confusion_decode_xxx = (unsigned char*)&(_buf)[0],\
                        *__data_confusion_decode_xxx_end = __data_confusion_decode_xxx + (_size);\
        while(__data_confusion_decode_xxx < __data_confusion_decode_xxx_end)\
        {\
            *__data_confusion_decode_xxx ^= __data_confusion_decode_xxx_magic_byte;\
            __data_confusion_decode_xxx_magic_byte ^= *__data_confusion_decode_xxx;\
            ++__data_confusion_decode_xxx;\
        }\
    }while(0)

#define data_confusion_encode_to_file(_magic_byte, _buf, _size, _filename)\
    do\
    {\
        FILE            *__data_confusion_decode_xxx_fp = fopen(_filename, "wb");\
        unsigned char   __data_confusion_decode_xxx_magic_byte = (unsigned char)(_magic_byte), \
                        *__data_confusion_decode_xxx = (unsigned char*)&(_buf)[0],\
                        *__data_confusion_decode_xxx_end = __data_confusion_decode_xxx + (_size);\
        while(__data_confusion_decode_xxx < __data_confusion_decode_xxx_end)\
        {\
            __data_confusion_decode_xxx_magic_byte ^= *__data_confusion_decode_xxx;\
            fprintf(__data_confusion_decode_xxx_fp, "0x%02x,", __data_confusion_decode_xxx_magic_byte);\
            ++__data_confusion_decode_xxx;\
        }\
        fclose(__data_confusion_decode_xxx_fp);\
    }while(0)

#endif /* !defined(__data_confusion_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
    
