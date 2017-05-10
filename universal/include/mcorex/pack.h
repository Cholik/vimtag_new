/*!
\file       pack.h
\brief      packet unit, codec packet to buffer,
            and decode packet from buffer

 ----history----
\author     chengzhiyong
\date       2007-01-23
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: pack.h,v 1.12 2008-09-01 11:22:17 chengzhiyong Exp $
*/
#if !defined(__pack_h__)
#define __pack_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/*--------copy from string-ex.h-----------*/
#if !defined(__len_str_defined) 
#define __len_str_defined
/*!< length string */
typedef struct len_str
{
    unsigned long       len;            /*!< string length */
    char                *data;          /*!< string data */
}_len_str;
#endif /* !defined(__len_str_defined) */
/*--------copy from string-ex.h-----------*/

/*------------------just for xml type(same with xml.h)-----------------*/
/*! \brief xml_node struct */
#if !defined(__xml_node_defined)
#define __xml_node_defined
typedef struct xml_node
{
    struct xml_node             *parent;    /*!< parent */
    struct xml_node             *prev;      /*!< prev */
    struct xml_node             *next;      /*!< next */
    unsigned long               flag;       /*!< flag */
    struct  len_str             name;       /*!< name */
    struct  len_str             text;       /*!< text */
    struct
    {
        unsigned long           counts;     /*!< counts */
        struct xml_node         *list;      /*!< data */
    }attributes;                            /*!< attributes */
    struct
    {
        unsigned long           counts;     /*!< counts */
        struct xml_node         *list;      /*!< data */
    }children;                              /*!< children */
}_xml_node;
#endif /*!defined(__xml_node_defined)*/
/*------------------just for xml type(same with xml.h)-----------------*/

/*------------------just for json type(same with json.h)---------------*/
#if !defined(__json_object_type_defined)
#define __json_object_type_defined
typedef enum json_object_type
{
    ejot_integer,
    ejot_number,
    ejot_string,
    ejot_object,
    ejot_array
}_json_object_type;
#endif /* !defined(json_object_type) */

#if !defined(__json_object_defined)
#define __json_object_defined
typedef struct json_object
{
    struct  
    {
        struct json_object      *prev;
        struct json_object      *next;
        struct json_object      *owner;
    }in_parent;
    enum json_object_type       type;
    struct len_str              name;
    union
    {
        struct len_str          string;
        struct
        {
            unsigned long       counts;
            struct json_object  *list;
        }object;
        struct  
        {
            unsigned long       counts;
            struct json_object  *list;
        }array;
    }v;
}_json_object;
#endif /* !defined(__json_object_defined) */
/*------------------just for json type(same with json.h)---------------*/

/*------------------just for http-param type(same with http_param.h)-----------------*/
#if !defined(http_param_type_header)
#define http_param_flag_type_header             0x01   /* header params */
#define http_param_flag_type_data               0x02   /* data params */
#endif

#if !defined(__http_param_defined)
#define __http_param_defined
/*! \brief http field */
typedef struct http_param
{
    struct http_param       *next;          /*!< next param */
    struct http_param       *prev;          /*!< prev param */
    unsigned long           type;           /*!< param type */
    struct len_str          name;           /*!< name */
    struct len_str          value;          /*!< value */
}_http_param;
#endif /* !defined(__http_param_defined) */
/*------------------just for http-param type(same with http_param.h)-----------------*/

#if !defined(mpack_int_define_disable) || (0 == mpack_int_define_disable)
#   if !defined(__int8_t_defined) && !defined(_INT8_T)
#       define __int8_t_defined
        typedef char                        int8_t;
        typedef short int                   int16_t;
        typedef int                         int32_t;
#       if defined(_MSC_VER)
            typedef __int64                 int64_t;
#       else 
            typedef long long int           int64_t;
#       endif
#   endif
#   if !defined(__uint32_t_defined)
#       define __uint32_t_defined
        typedef unsigned char               uint8_t;
        typedef unsigned short int          uint16_t;
        typedef unsigned int                uint32_t;
#       if defined(_MSC_VER)
            typedef unsigned __int64        uint64_t;
#       else 
            typedef unsigned long long int  uint64_t;
#       endif
#   endif
#endif

#if !defined(__ulong_defined)
#   define __ulong_defined
    typedef unsigned long                   ulong;
#endif
#if !defined(__float32_t_defined)
#   define __float32_t_defined
    typedef float                       float32_t;
    typedef double                      float64_t;
#endif

#if !defined(pack_def_pointer)
#   if (__WORDSIZE == 64)|| defined(__LP64__)/*gunc*/ || defined(_WIN64)/*win64*/ || defined(__x86_64)/*gunc|osx.64*/ || defined(_M_X64)/*msc*/ /* 64bits */
#       define pack_def_pointer(_name) *_name
#   elif defined(__big_endian) || (defined(__BIG_ENDIAN) && (__BIG_ENDIAN == __BYTE_ORDER))/* bigorder bit32 */
#       define pack_def_pointer(_name) *_name##__padding[(8 - sizeof(void*))/sizeof(void*)], *_name
#   else/* little endian 32bit */
#       define pack_def_pointer(_name) *_name, *_name##__padding[(8 - sizeof(void*))/sizeof(void*)]
#   endif
#endif

#if !defined(pack_pointer_2_uint64)
#   if (__WORDSIZE == 64)|| defined(__LP64__)/*gunc*/ || defined(_WIN64)/*win64*/ || defined(__x86_64)/*gunc|osx.64*/ || defined(_M_X64)/*msc*/ /* 64bits */
#       define pack_pointer_2_uint64(_pt)   ((uint64_t)(_pt))
#       define pack_uint64_2_pointer(_u64_value)   ((void*)(_u64_value))
#   else
#       define pack_pointer_2_uint64(_pt)   ((uint64_t)(unsigned long)(_pt))
#       define pack_uint64_2_pointer(_u64_value)   ((void*)((unsigned long)(_u64_value)))
#   endif
#endif

#if !defined(__pack_lenstr_type_magic)
#define __pack_lenstr_type_magic  0xb4abdf8b
#pragma pack(push, 1)
typedef struct pack_lenstr
{
    uint32_t        len;
    char            pack_def_pointer(data);
}_pack_lenstr;
#pragma pack(pop)
#elif (__pack_lenstr_type_magic != 0xb4abdf8b)
#error pack_lenstr type defined but not match
#endif /* !defined(__dataset_conf_type_magic) */

#define pack_bytes  pack_lenstr

#if !defined(__pack_date_type_magic)
#define __pack_date_type_magic  0x0fa0f3c7
typedef struct pack_date    /*!< pack date definition */
{
    uint16_t        year;   /*!< year */
    uint8_t         mon;    /*!< month */
    uint8_t         day;    /*!< month day */
    uint8_t         hour;   /*!< hour */
    uint8_t         min;    /*!< minutes */
    uint8_t         sec;    /*!< seconds */
    uint8_t         rsv;    /*!< reserved field */
}_pack_date;
#elif (__pack_date_type_magic != 0x0fa0f3c7)
#error pack_date type defined but not match
#endif /* !defined(__dataset_conf_type_magic) */

#if !defined(__pack_ip_type_magic)
#define __pack_ip_type_magic  0x27be8cd6    /* Compatible struct in_addr */
typedef struct pack_ip
{
    uint8_t         s_b[4]; /*!< s_addr */
}_pack_ip;
#elif (__pack_ip_type_magic != 0x27be8cd6)
#error pack_ip type defined but not match
#endif /* !defined(__dataset_conf_type_magic) */

#define pack_ip_format_s    "%d.%d.%d.%d"
#define pack_ip_format( ip ) (ip)?(ip)->s_b[0]:0, (ip)?(ip)->s_b[1]:0, (ip)?(ip)->s_b[2]:0, (ip)?(ip)->s_b[3]:0

/* #pragma pack(pop) */

struct pack_field;
struct pack_def;
struct pack_def_list;

/*---------------------pack def-----------------------------------------*/
/*!
func    pack_def_list_create
\brief  create packet definition list
\param  root[in]                the xml root node
\return the packet list result
        #NULL                   create failed
        #other                  the packet list */
struct pack_def_list *pack_def_list_create(struct xml_node *root);

/*!
func    pack_def_list_append
\brief  append xml string
\param  list[in/out]            pack definition list
\param  root[in]                the xml root node
\return append result
        #0                      succeed
        #other                  error code */
long pack_def_list_append(struct pack_def_list *list, struct xml_node *root);

/*!
func    pack_destroy
\brief  destroy the packet list
\param  list[in/out]            the pack definition list
\return destroy result
        #0                      succeed
        #other                  error code
*/
long pack_def_list_destroy(struct pack_def_list *list);

/*!
func    pack_def_get
\brief  get def by name
\param  list[in]                the packet definition list
\param  type_len[in]            the packet type name length
\param  type[in]                the packet definition type name
\return the pack definition with the name
        #NULL                   not exist
        #other                  the pack-definition pointer */
struct pack_def *pack_def_get(struct pack_def_list *list, unsigned long type_len, char *type);

/*!
func    pack_def_name_fix
\brief  correct name characters, let be a valid symbol name
\param  name[in/out]            the name
\param  len[in]                 the name length, if 0xffffffff will end at '\0' char 
\return void
*/
void pack_def_name_fix(char *name, unsigned long len);

/*!
func    pack_def_get_magic
\brief  get pack-def's magic
\param  def[in]                 the pack def, if invalid pack-def will return 0
\return the magic
*/
uint32_t  pack_def_get_magic(struct pack_def *def);

/*!
func    pack_def_comp
\brief  compare def is same
\param  def1[in]                the pack def
\param  def2[in]                the other pack def
\param  loose_compatible[in]    loose compatibility type as same, such as (uint32_t == int32_t)
\return compare result
        #0                      same
        #<0                     not same
*/
long pack_def_comp(struct pack_def *def1, struct pack_def *def2, long loose_compatible);
/*---------------------pack def-----------------------------------------*/




/*---------------------pack def export as code text---------------------*/

/*!
func    pack_def_export
\brief  export pack-definition as c header, will export all refer struct
\param  def[in]                 the pack-definition
\param  buf[in/out]             the buffer used to save export string
\param  buf_size[in]            the buffer size
\param  language[in]            the language, just suport "c", "java" now
\return export string length
        #<=0                    invalid pack definition
        #other                  the content len
*/
long pack_def_export(struct pack_def *def, char *buf, unsigned long buf_size, char *language);

/*!
func    pack_def_list_export
\brief  export pack-definition list as c header
\param  list[in]                the pack-definition list
\param  buf[in/out]             the buffer used to save export string
\param  buf_size[in]            the buffer size
\param  language[in]            the language, just suport "c", "java", "xml", "json", "cdata", now 
\return export string length
        #<=0                    invalid pack definition list
        #other                  the content len
*/
long pack_def_list_export(struct pack_def_list *list, char *buf, unsigned long buf_size, char *language);
/*---------------------pack def export as code text---------------------*/



/*------------pack data decode/encode (pointer fix, bit-endian convert)-*/
/*!
func    pack_encode
\brief  encode packet to buffer
        after encode, user can not access struct directly
        then can send out this packet to remote host
\param  def[in]                 packet definition
\param  data[in/out]            the struct data
\return encode result
        #0                      succeed
        #other                  error */
long pack_encode(struct pack_def *def, void *data);

/*!
func    pack_decode
\brief  decode the packet which recv from network
        after decode, user can access struct directly
\param  def[in]                 packet definition
\param  data[in/out]            the data
\param  data_size[in]           the data size, do not include last reserved char to save '\0'
\param  is_big_endian[in]       data is save with big bytes endian,
                                if PPC or MIPS maybe true, INTEL will false
\param  is_bit64[in]            is 64bit pointer data                                
\param  base_addr[in]           base address of the packet in other process space
\return decode result
        #0                      succeed
        #other                  error */
long pack_decode(struct pack_def    *def,
                 void               *data,
                 unsigned long      data_size,
                 unsigned long      is_big_endian,
                 unsigned long      is_bit64,
                 uint64_t           base_addr);

/*!
func    pack_calc_size
\brief  calculate packet's size
\param  def[in]                 packet definition
\param  data[in]                the data
\return packet size
        #<0                     error code
        #other                  packet size */
long pack_calc_size(struct pack_def *def, void *data);

/*!
func    pack_copy
\brief  copy a packet data to special dest buffer
\param  def[in]                 packet definition
\param  dst[in/out]             dest buffer
\param  dst_base_addr[in]       the dest struct base address. normal way should same as <dst>, 
                                or wanna map to new address space, such as serial-pack 
\param  dst_size[in]            the size of the dest buffer
\param  dst_data_pt_off[in]     the data offset of the pointer in def member.
                                if 0, will save near member, else save to offset
                                position of the dst start pointer
\param	src[in]                 src packet
\param  src_base_addr[in]       the src base address, normal way should same as <src>
\return copy data len
        #<0                     error code
        #other                  data len( not include def->size self) */
long pack_copy(struct pack_def  *def,
               void             *dst,       uint64_t        dst_base_addr,
               unsigned long    dst_size,   unsigned long   dst_data_pt_off,
               void             *src,       uint64_t        src_base_addr);

/*------------pack data decode/encode (pointer fix, bit-endian convert)-*/


/*------------pack data import/export as xml/json/http -----------------*/
/*!
func    pack_export_as_xml
\brief  export packet as xml into buffer
\param  def[in]                 packet definition
\param  node_name_len[in]       the node name length, can be 0, if 0 export def->name as node_name
\param  node_name[in]           the node name, can be NULL, if NULL export def->name as node_name
\param  level[in]               the level, usually should be 0 when start
                                #>=0: insert TAB char counts before text line
                                #<=0: means don't insert TAB char, and all content in one line
\param  data[in]                can be NULL,if NULL empty, output a empty xml.
                                if the packed data, must deal with pack by 
                                pack_decode() before export,                                
\param  buf[out]                the buffer used to save export string
\param  buf_size[in]            the buffer size
\return export string length
        #<=0                    invalid pack definition or invalid pak data
        #other                  the content len */
long pack_export_as_xml(struct pack_def *def, unsigned long node_name_len, char *node_name,
                        long level, void *data, char *buf, unsigned long buf_size);

/*!
func    pack_import_from_xml
\brief  import packet from xml string
\param  def[in]                 packet definition
\param  node_name_len[in]       the node name length, can be 0, if 0 import def->name as node_name
\param  node_name[in]           the node name, can be NULL, if NULL import def->name as node_name
\param  root[in]                the xml root
\param  buf[out]                the struct packet
\param  buf_size[in]            the buffer size
\return import data len, include def refer self struct
        #>=0                    import data size
        #other                  error code */
long pack_import_from_xml(struct pack_def *def, unsigned long node_name_len, char *node_name,
                          struct xml_node *root, void *buf, unsigned long buf_size);

/*!
func    pack_export_as_json
\brief  export packet as json data
\param  def[in]                 packet definition
\param  level[in]               the level, usually should be 0 when start
                                #>=0: insert TAB char counts before text line
                                #<=0: means don't insert TAB char, and all content in one line
\param  data[in]                can be NULL,if NULL empty, output a empty json.
                                if the packed data, must deal with pack by 
                                pack_decode() before export,                                
\param  buf[in/out]             the buffer used to save export string
\param  buf_size[in]            the buffer size
\return export string length
        #<=0                    invalid pack definition or invalid pack data
        #other                  the content len */
long pack_export_as_json(struct pack_def *def, long level, void *data, char *buf, unsigned long buf_size);

/*!
func    pack_import_from_json
\brief  import packet from json string
\param  def[in]                 packet definition
\param  root[in]                the json root
\param  buf[out]                the struct packet
\param  buf_size[in]            the buffer size
\return import data len, include def refer self struct
        #>=0                    import data size
        #other                  error code */
long pack_import_from_json(struct pack_def *def, struct json_object *root, void *buf, unsigned long buf_size);
long pack_import_from_json_node(struct pack_def *def, struct json_object *root, void *buf, unsigned long buf_size);


/*!
func    pack_import_from_http
\brief  import export packet from http request
\param  def[in]                 packet definition
\param  params[in]              the http params
\return import data len
        #>=0                    import data size
        #other                  error code */
long pack_import_from_http(struct pack_def *def, struct http_param *params, void *buf, unsigned long buf_size);

/*------------pack data import/export as xml/json/http -----------------*/


/*---------------------pack data duplicate------------------------------*/
/*!
func    pack_dup_create
\brief  duplicate pack struct, after use call pack_dup_free to free resource
\param  def[in]                 packet definition
\param  data[in]                the data
\return duplicate pack data
        #NULL                   failed
        #other                  duplicated data, need free by pack_dup_free after use */
void *pack_dup_create(struct pack_def *def, void *data);

/*!
func    pack_dup_destroy
\brief  destroy duplicated pack struct
\param  data[in]                the data
\return duplicate result
        #0                      succeed
        #other                  error code */
long pack_dup_destroy(void *data);
/*---------------------pack data duplicate------------------------------*/


/*---------------------pack serial data---------------------------------*/
#define pack_serial_magic (*(long*)"paks    ")
typedef struct pack_serial
{
    char                magic[sizeof(long)];/*!< magic */
    struct                                  /*!< flag information */
    {
        unsigned long   big_endian:1,       /*!< is big endian */
                        ver:3,              /*!< version id */
                        bit64:1,            /*!< is from bit64 matchine */
                        type_name:1,        /*!< have type name information */
                        type_magic:1,       /*!< have type magic */
                        base_addr:1,        /*!< have base address */
                        reserved:24;
    }flag;
    uint32_t            type_magic;         /*!< type magic */
    struct len_str      type;
    uint64_t            base_addr;          /*!< base address pointer value*/

    unsigned char       *head;              /*!< header pointer maybe need decode */
    uint64_t            *base_addr_pt;      /*!< base address save pt */
    unsigned char       *body;              /*!< data body start pointer maybe need decode */
    unsigned long       body_size;          /*!< body size */
}_pack_serial;
#define pack_serial_flag_type_magic             0x01   /* b00000001 */
#define pack_serial_flag_type_name              0x02   /* b00000010 */
#define pack_serial_flag_type_magic_and_name    (pack_serial_flag_type_magic | pack_serial_flag_type_name)
#define pack_serial_flag_base_addr              0x04   /* b00000100 */

/*!
func    pack_serial_get_size
\brief  get the pack serial data size
\param  def[in]                 the pack def
\param  data[in]                the data
\param  flag[in]                the encode flag, refer pack_data_flag_xxxx
\return header size
        #<=0                    error code
        #other                  the encoded data length
*/
long pack_serial_get_size(struct pack_def *def, void *data, unsigned long flag);

/*!
func    pack_serial_encode
\brief  encode as native data as pack-serialize-data, serialize it
\param  def[in]                 the pack-def
\param  data[in]                the data
\param  buf[in]                 the buffer
\param  buf_size[in]            the buffer size
\param  flag[in]                the encode flag, refer pack_data_flag_xxxx
\return the encoded data length
        #<=0                    error code
        #other                  the encoded data length
*/
long pack_serial_encode(struct pack_def *def, void *data, unsigned char *buf,  unsigned long buf_size, unsigned long flag);

/*!
func    pack_serial_decode
\brief  decode pack-serial-data as native data
\param  def[in]                 the pack-def, can be NULL
                                #NULL ignore, and will not decode data, just get pack-info
                                #other check type name and magic, then decode data and save into pack->data
\param  data[in]                the data
\param  size[in]                the data size
\param  pack[out]               the pack, decoded data can use pack->data to access
\return the pack data start pointer
        #NULL                   failed
        #other                  the pack data start pointer
*/
void *pack_serial_decode(struct pack_def *def, unsigned char *data, unsigned long size, struct pack_serial *pack);
/*---------------------pack serial data---------------------------------*/



/*---------------------pack buffer--------------------------------------*/
typedef struct mpack_buf
{
    unsigned char   *start;             /*!< buffer start pointer */
    unsigned char   *end;               /*!< buffer end pointer */
    unsigned char   *index;             /*!< current index, if index == end means buffer full. plz set same as start at initting */
}_mpack_buf;
#define mpbuf_init(_pbuf, _buf_pointer, _buf_size) \
    do{\
       (_pbuf)->start = ((_pbuf)->index = (unsigned char*)(_buf_pointer));\
       (_pbuf)->end = (_pbuf)->start + (_buf_size);\
    }while(0)
#define mpbuf_init_ex(_pbuf, _buf_pointer, _buf_size) (\
    (NULL == ((_pbuf)->start = (unsigned char*)(_buf_pointer))) \
    || (NULL == ((_pbuf)->index = (_pbuf)->start)) \
    || (NULL == ((_pbuf)->end = (_pbuf)->start + (_buf_size)))) 
    

/*!
func    mpbuf_alloc
\brief  alloc sub buffer from pack buffer, return pointer will 4byte align
\param  pbuf[in]                the pack buffer
\param  size[in]                the size, can be 0
                                #0      return current buffer index
                                #other  alloc a 4 byte align buffer
\return sub buffer
        #NULL                   failed
        #other                  the result data struct pointer
*/
void *mpbuf_alloc(struct mpack_buf *pbuf, unsigned long size);

/*!
func    mpbuf_calloc
\brief  alloc sub buffer from pack buffer, and clean it to \0, return pointer will 4byte align
\param  pbuf[in]                the pack buffer
\param  size[in]                the size, can be 0
                                #0      return current buffer index
                                #other  alloc a 4 byte align buffer
\return sub buffer
        #NULL                   failed
        #other                  the result data struct pointer
*/
void *mpbuf_calloc(struct mpack_buf *pbuf, unsigned long size);

/*!
func    mpbuf_save_bytes
\brief  save bytes, dst[*].data start pointer will 4 bytes align
\param  pbuf[in]                the pack buf
\param  counts[in]              the bytes array counts
\param  src[in]                 the src bytes array
\param  dst[in]                 the dst bytes array, can be NULL
                                #NULL malloc new bytes array to save dst
\return dst array
        #NULL                   failed
        #other                  the dst array start pointer
*/
struct pack_bytes *mpbuf_save_bytes(struct mpack_buf  *pbuf, unsigned long counts, struct pack_bytes *src, struct pack_bytes *dst);

/*!
func    mpbuf_save_lenstr
\brief  save len-str, dst[*].data start pointer will not 4 bytes align
\param  pbuf[in]                the pack buf
\param  counts[in]              the bytes array counts
\param  src[in]                 the src pack-lenstr array
\param  dst[in]                 the dst pack-lenstr array, can be NULL
                                #NULL malloc new pack-lenstr array to save dst
\return dst array
        #NULL                   failed
        #other                  the dst array start pointer
*/
struct pack_lenstr *mpbuf_save_lenstr(struct mpack_buf *pbuf, unsigned long counts, struct pack_lenstr *src, struct pack_lenstr *dst);

/*!
func    mpbuf_save_lenstr2
\brief  save len-str, dst[*].data start pointer will 4 bytes align
\param  pbuf[in]                the pack buf
\param  counts[in]              the bytes array counts
\param  src[in]                 the src pack-lenstr array
\param  dst[in]                 the dst pack-lenstr array, can be NULL
                                #NULL malloc new pack-lenstr array to save dst
\return dst array
        #NULL                   failed
        #other                  the dst array start pointer
*/
struct pack_lenstr *mpbuf_save_lenstr2(struct mpack_buf *pbuf, unsigned long counts, struct len_str *src, struct pack_lenstr *dst);

/*!
func    mpbuf_save_str
\brief  save string, dst[*].data start pointer will not 4 bytes align
\param  pbuf[in]                the pack buf
\param  src_len[in]             the src length
                                #0xffffffff will calculate by strlen
\param  src[in]                 the src string
\param  save_len[out]           the pack-data total size output pointer, can be NULL.
                                #NULL ignore and output nothing
\return dst string start pointer
        #NULL                   failed
        #other                  dst string start pointer
*/
char *mpbuf_save_str(struct mpack_buf *pbuf, unsigned long str_len, char *str, uint32_t *save_len);

/*!
func    mpbuf_save_data
\brief  save pack array, 4 bytes align if dst is alloc in function
\param  pbuf[in]                the pack buf
\param  size[in]                the data size
\param  data[in]                the data pointer
\param  save_len[out]           the data length be saved, can be NULL
                                #NULL   ignore and ouput nothing
                                #other  output data length, will same as size param
\return dst start pointer
        #NULL                   failed
        #other                  the dst array start pointer
*/
void *mpbuf_save_data(struct mpack_buf *pbuf, unsigned long size, void *data, uint32_t *save_len);

/*!
func    mpbuf_save_pack
\brief  save pack array, 4 bytes align if dst is alloc in function
\param  pbuf[in]                the pack buf
\param  def[in]                 the pack definition
\param  counts[in]              the bytes array counts
\param  src[in]                 the src pack-lenstr array
\param  dst[in]                 the dst pack-lenstr array, can be NULL
                                #NULL malloc new pack-lenstr array to save dst
\return dst array
        #NULL                   failed
        #other                  the dst array start pointer
*/
void *mpbuf_save_pack(struct mpack_buf *pbuf, struct pack_def *def, unsigned long counts, void *src, void *dst);

/*!
func    mpbuf_save_serial
\brief  save a struct into pack as a encoded serial packed data, return pointer will 4 bytes align
\param  pbuf[in]                the pack buf
\param  def[in]                 the pack definition
\param  data[in]                the data
\param  flag[in]                the flag, refer pack_data_flag_xxx
\param  save_len[out]           the pack-data total size output pointer, can be NULL
                                #NULL ignore and output nothing
\return dst array
        #NULL                   failed
        #other                  the dst array start pointer
*/
void *mpbuf_save_serial(struct mpack_buf *pbuf, struct pack_def *def, void *data, unsigned long flag, uint32_t *save_len);
/*---------------------pack buffer--------------------------------------*/



/* void pack_dump( struct pack_def *def, void *data, char *filename ); */
/*! \brief str to num */
long pack_str_to_num(char *begin, char *end, int64_t *value /* [out] */);
/*! \brief string to ip */
long pack_str_to_ip(char *begin, char *end, unsigned char *ip /* [out] */);
/*! \brief string to date */
long pack_str_to_date(char *begin, char *end, struct pack_date *date /* [out] */);
long pack_u2dec(char *buf, uint32_t value);
long pack_i2dec(char *buf, int32_t value);
long pack_lu2dec(char *buf, uint64_t value);
long pack_li2dec(char *buf, int64_t value);
long pack_u2hex(char *buf, uint32_t value);
long pack_i2hex(char *buf, int32_t value);
long pack_lu2hex(char *buf, uint64_t value);
long pack_li2hex(char *buf, int64_t value);
long pack_bin2hex(char *hex_buf, unsigned long hex_buf_size, unsigned char *data, unsigned long data_len);
long pack_hex2bin(unsigned char* data_buf/* [out] */, unsigned long data_buf_size, unsigned char *hex, unsigned long hex_len);

long pack_date_cmp(struct pack_date *date1, struct pack_date *date2 );
#define pack_lenstr_cmp len_str_cmp

long pack_get_date(struct pack_date *date );

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__pack_h__) */
