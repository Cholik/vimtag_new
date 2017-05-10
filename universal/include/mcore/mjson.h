/*!
\file       mjson.h
\brief      mjson unit
----history----
\author     chengzhiyong
\date       2013-07-13
\version    0.01
\desc       create

$Author: chengzhiyong $
*/
#if !defined(__mjson_h__)
#define __mjson_h__

#if defined(__cplusplus)
extern "C" {
#endif

#if !defined(__len_str_defined)
#define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */

#define mjson_err_base                          -1
#define mjson_err_invalid_param                 (mjson_err_base)
#define mjson_err_invalid_object_type           (mjson_err_base - 1)
#define mjson_err_invalid_parent_info           (mjson_err_base - 2)
#define mjson_err_invalid_integer               (mjson_err_base - 3)
#define mjson_err_invalid_number                (mjson_err_base - 4)
#define mjson_err_invalid_json_string           (mjson_err_base - 5)
#define mjson_err_not_complete                  (mjson_err_base - 6)
#define mjson_err_malloc_failed                 (mjson_err_base - 7)
#define mjson_err_text_codec_disable            (mjson_err_base - 8)
#define mjson_err_mxjson_codec_disable          (mjson_err_base - 9)
#define mjson_err_buf_overflow                  (mjson_err_base - 10)
#define mjson_err_number_not_ready              (mjson_err_base - 11)
#define mjson_err_xobj_type_unknown             (mjson_err_base - 12)
#define mjson_err_xpack_type_unknown            (mjson_err_base - 13)
#define mjson_err_xpack_uncomplete              (mjson_err_base - 14)
#define mjson_err_xpack_name_len_uncomplete     (mjson_err_base - 15)
#define mjson_err_xpack_name_uncomplete         (mjson_err_base - 16)
#define mjson_err_xlen_uncomplete               (mjson_err_base - 17)
#define mjson_err_xdata_uncomplete              (mjson_err_base - 18)
#define mjson_err_xnum_len_invalid              (mjson_err_base - 19)
#define mjson_err_xobj_end_overage              (mjson_err_base - 20)
#define mjson_err_xname_type_is_not_str         (mjson_err_base - 21)
#define mjson_err_xunsupport_number_size        (mjson_err_base - 22)

#if defined(_MSC_VER)
typedef __int64 mjson_i64_t;
typedef unsigned __int64 mjson_u64_t;
#else
typedef long long mjson_i64_t;
typedef unsigned long long mjson_u64_t;
#endif


#if !defined(__mjson_obj_type_defined)
#define __mjson_obj_type_defined
typedef enum mjson_obj_type
{
    mejot_integer,
    mejot_number,
    mejot_string,
    mejot_object,
    mejot_array
}_mjson_obj_type;
#endif /* !defined(json_object_type) */

typedef enum mjson_buf_type
{
    mejbt_allocated,
    mejbt_append,
    mejbt_ref
}_mjson_buf_type;

#if !defined(__mjson_obj_defined)
#define __mjson_obj_defined
typedef struct mjson_obj
{
    struct  
    {
        struct mjson_obj        *prev;
        struct mjson_obj        *next;
        struct mjson_obj        *owner;
    }in_parent;
#if 0
    enum mjson_obj_type         type;
#else
    unsigned long               type:4;                     /*!< mjson_object_type, mejot_xxx */
    unsigned long               name_buf_type:2;            /*!< name string buffer type, mjson_buf_type mejbt_xxx */
    unsigned long               str_value_buf_type:2;       /*!< value string buffer type, mjson_buf_type mejbt_xxx */
    unsigned long               str_value_is_str:1;         /*!< str value is string */
    unsigned long               num_value_ready:1;          /*!< number value ready */
    unsigned long               reserved:22;                /* resrved field */
#endif
    struct len_str              name;
    union
    {
        struct len_str          string;
        struct
        {
            unsigned long       len;
            unsigned char       *data;
            double              value;
        }num;
        struct
        {
            unsigned long       len;
            unsigned char       *data;
            long                value;
        }integer;
        struct
        {
            unsigned long       counts;
            struct mjson_obj    *list;
        }object;
        struct  
        {
            unsigned long       counts;
            struct mjson_obj    *list;
        }array;
    }v;
}_mjson_obj;
#endif /* !defined(__mjson_obj_defined) */

/*! \brief mxjson decode context, use can deside decoder memory operations */
typedef struct mjson_ctx
{
    unsigned long               dont_copy_sdata;    /*!< dont' copy string/binary data, just refer to src buffer(just for mxjson|raw data, not for encoded text string) */
    unsigned long               dont_copy_sname;    /*!< dont' copy string/binary data, just refer to src buffer(just for mxjson|raw data, not for encoded text string) */
    struct
    {
        unsigned long           size;               /*!< buffer size */
        unsigned long           index;              /*!< buffer index */
        unsigned char           *data;              /*!< buffer start pointer */
    }buf;
    void                        *ref;               /*!< ref fo xalloc callback */
    void                        *(*xalloc)(unsigned long size, void *ref);  /*!< malloc callback function */
    void                        (*xfree)(void *pt, void *ref);  /*!< free callback function */
}_mjson_ctx;

long                mjson_string_encode(unsigned long len, char *data, unsigned long buf_size, char *buf);
long                mjson_string_decode(unsigned long len, char *data, unsigned long buf_size, char *buf);

/* follow mjson_create_xxx functions. ctx can be NULL, parent can be NULL */
struct mjson_obj    *mjson_create_long(struct mjson_ctx *ctx, struct mjson_obj *parent, unsigned long name_len, char *name, long value); /* parent,name can be NULL */
struct mjson_obj    *mjson_create_int64(struct mjson_ctx *ctx, struct mjson_obj *parent, unsigned long name_len, char *name, mjson_i64_t value);/* parent,name can be NULL */
struct mjson_obj    *mjson_create_number(struct mjson_ctx *ctx, struct mjson_obj *parent, unsigned long name_len, char *name, double value);/* parent,name can be NULL */
struct mjson_obj    *mjson_create_string(struct mjson_ctx *ctx, struct mjson_obj *parent, unsigned long name_len, char *name, unsigned long value_len, char *value);/* parent,name can be NULL */
struct mjson_obj    *mjson_create_object(struct mjson_ctx *ctx, struct mjson_obj *parent, unsigned long name_len, char *name);/* parent,name can be NULL */
struct mjson_obj    *mjson_create_array(struct mjson_ctx *ctx, struct mjson_obj *parent, unsigned long name_len, char *name);/* parent,name can be NULL */
long                mjson_destroy(struct mjson_ctx *ctx/* can be NULL */, struct mjson_obj *obj);

/* prev can be NULL, just for cache to serach performance */
struct mjson_obj    *mjson_get_child_by_name(struct mjson_obj *parent, struct mjson_obj *prev, unsigned long name_len, char *name);

long                mjson_get_long(struct mjson_obj *obj, long *value);
long                mjson_get_int64(struct mjson_obj *obj, mjson_i64_t *value);
long                mjson_get_number(struct mjson_obj *obj, double *value);
long                mjson_get_string(struct mjson_obj *obj, struct len_str *value);

#define             mjson_get_child_long(_obj, _child_name_const, _out_value_pointer)    mjson_get_long(mjson_get_child_by_name(_obj, NULL, sizeof(_child_name_const) - 1, (char*)_child_name_const), _out_value_pointer)
#define             mjson_get_child_int64(_obj, _child_name_const, _out_value_pointer)   mjson_get_int64(mjson_get_child_by_name(_obj, NULL, sizeof(_child_name_const) - 1, (char*)_child_name_const), _out_value_pointer)
#define             mjson_get_child_number(_obj, _child_name_const, _out_value_pointer)  mjson_get_number(mjson_get_child_by_name(_obj, NULL, sizeof(_child_name_const) - 1, (char*)_child_name_const), _out_value_pointer)
#define             mjson_get_child_string(_obj, _child_name_const, _out_value_pointer)  mjson_get_string(mjson_get_child_by_name(_obj, NULL, sizeof(_child_name_const) - 1, (char*)_child_name_const), _out_value_pointer)
#define             mjson_del_child_by_name(_obj, _child_name_const)                     mjson_destroy(mjson_get_child_by_name(_obj, NULL, sizeof(_child_name_const) - 1, _child_name_const))

long                mjson_encode(struct mjson_obj *obj, unsigned long size, char *buf);
struct mjson_obj    *mjson_decode(struct mjson_ctx *ctx/* can be NULL */,unsigned long text_len, char *text);
struct mjson_obj    *mjson_dup(struct mjson_ctx *ctx/* can be NULL */,struct mjson_obj *parent/* can be NULL */, struct mjson_obj *src);
long                mjson_merge(struct mjson_ctx *ctx/* can be NULL */,struct mjson_obj *dst/* can be NULL */, struct mjson_obj *src);/* both should be object */


/*!
func    mjson_x_encode
\brief  encode mining extreme object
\param  obj[in]                 the json object
\param  buf_size[in]            the buffer size
\param  buf[out]                the buffer
\return encode result
        #<0                     error code
        #other                  encoded data length
*/
long                mjson_x_encode(struct mjson_obj *obj, unsigned long buf_size, unsigned char *buf);

/*!
func    mjson_x_decode
\brief  deocde mining extreme object(binary)
\param  ctx[in/out]             the decode ctx, can be NULL
                                #NULL must call mxjson_destroy to free memory
                                #other maybe dont' call mxjson_destroy if user manange memory
\param  len[in]                 the data length
\param  data[in]                the data
\return decode result
        #NULL                   failed
        #other                  the object decoded
*/
struct mjson_obj    *mjson_x_decode(struct mjson_ctx *ctx, unsigned long len, unsigned char *data);


long                mjson_test_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__mjson_h__) */

