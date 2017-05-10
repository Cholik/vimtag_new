/*!
\file       pack_def.h
\brief      packet unit, codec packet to buffer,
            and decode packet from buffer

 ----history----
\author     chengzhiyong
\date       2012-08-02
\version    0.01
\desc       create, pull from pack.def

$Author: chengzhiyong $
$Id: pack.h,v 1.12 2012-08-02 11:22:17 chengzhiyong Exp $
*/
#if !defined(__pack_def_h__)
#define __pack_def_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/*! \brief pack field type */
typedef enum pack_def_type
{
    /* ----------system type begin----------- */
    epdt_uint8,             /*!< uint 8, unsigned char */
    epdt_int8,              /*!< int 8, char */

    epdt_uint16,            /*!< ushort 16, unsigned short */
    epdt_int16,             /*!< int 16, short */

    epdt_uint32,            /*!< uint 32, unsigned */
    epdt_int32,             /*!< int 32, long */

    epdt_uint64,            /*!< uint 64, unsigned long long, long long */
    epdt_int64,             /*!< int 64, long long */

    epdt_uint128,           /*!< uint 128, unsigned long long, long long */
    epdt_int128,            /*!< int 128, long long */

    epdt_float32,           /*!< float 32, float */
    epdt_float64,           /*!< float 64, double */
    epdt_float128,          /*!< float 128, double */

    epdt_struct,            /*!< struct */
    epdt_bytes,             /*!< bytes array with len, struct{unsigned len; char* data;};*/
    epdt_lenstr,            /*!< string with len, struct{unsigned len; char* data;} end with '0' */
    
    epdt_date,              /*!< date time, struct pack_date */
    epdt_ip,                /*!< ip address, struct ip */
    /* ----------system type end------------- */

    epdt_unknown
}_pack_def_type;

typedef struct pack_field
{
    struct
    {
        struct pack_field   *next;
        struct pack_field   *prev;
    }in_def;
    
    struct len_str          name;           /*!< member name, this name is field name */
    struct pack_def         *def;           /*!< def information */

    unsigned long           pos;            /*!< byte index from struct start */
    unsigned long           size;           /*!< field bytes size */
    unsigned long           bits_pos;       /*!< bits index from type-refer bit start */
    unsigned long           bits_size;      /*!< for bit type */
    struct
    {
        unsigned long       min;            /*!< min data unit counts */
        unsigned long       max;            /*!< max data unit counts */
        unsigned long       flag;           /*!< 1:normal(min==1&&max==1); 2:pointer(min==0&&max==1); 3:array(min==max&&min>1); 4:valiable array(min<max&&max>1)  */
    }counts;/*!< counts, if min == max will be a xx[min] array, else will be xx*, if bits counts must by 1.  */

    struct len_str          info;           /*!< info */

    void                    *user_data[2];  /*!< user data, java:cls, construct-method-id */
}_pack_field;

/*! \brief pack definition */
typedef struct pack_def
{
    struct  
    {
        struct pack_def     *prev;      /*!< prev pack-definition */
        struct pack_def     *next;      /*!< next pack-definition */
    }in_list;
    struct pack_def         *hash_next; /*!< next def in hash */

    unsigned long           type;       /*!< pack type, refer to enum pack_def_type */
    struct len_str          name;       /*!< type name */
    unsigned long           size;       /*!< type size(bytes) */
    uint32_t                magic;      /*!< type magic, build by magic data */
    uint32_t                reserved;   /*!< reserved field to align in 64bits matchine */

    struct  
    {
        unsigned long       counts;
        struct pack_field   *list;
    }fields;                            /*!< fields list */

    struct pack_def         *alias;     /*!< alias def */
    void                    *user_data[4];/*!< user data, java:cls, construct-method-id */
}_pack_def;

#define pack_def_format_s   "%p{%s:%08x}"
#define pack_def_format(_def) (_def), (_def)?(_def)->name.data:NULL, (_def)?(_def)->magic:0

/*! \brief get pack_def size */
//#define sizeof_pack_def(child_counts) (sizeof(struct pack_def) + ((((long)child_counts) -1)*sizeof(((struct pack_def*)0)->children[0])))

/*! \brief pack definition list */
typedef struct pack_def_list
{
    unsigned long       counts;     /*!< pack def counts */
    struct pack_def     *defs;      /*!< defs list  */
}_pack_def_list;


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__pack_def_h__) */
