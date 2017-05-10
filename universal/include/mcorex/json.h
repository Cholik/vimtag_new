/*!
\file       json.h
\brief      json unit
----history----
\author     chengzhiyong
\date       2011-12-11
\version    0.01
\desc       create

$Author: chengzhiyong $
*/
#if !defined(__json_h__)
#define __json_h__

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

#define json_err_invalid_param          -1
#define json_err_buffer_overflow        -2
#define json_err_invalid_object_type    -3
#define json_err_invalid_parent_info    -4
#define json_err_invalid_integer        -5
#define json_err_invalid_number         -6
#define json_err_invalid_json_string    -7
#define json_err_not_complete           -8
#define json_err_malloc_failed          -9

#if defined(_MSC_VER)
typedef __int64 json_i64_t;
typedef unsigned __int64 json_u64_t;
#else
typedef long long json_i64_t;
typedef unsigned long long json_u64_t;
#endif


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

struct json_object  *json_create_long(struct json_object *parent, unsigned long name_len, char *name, long value); /* parent,name can be NULL */
struct json_object  *json_create_int64(struct json_object *parent, unsigned long name_len, char *name, json_i64_t value);/* parent,name can be NULL */
struct json_object  *json_create_number(struct json_object *parent, unsigned long name_len, char *name, double value);/* parent,name can be NULL */
struct json_object  *json_create_string(struct json_object *parent, unsigned long name_len, char *name, unsigned long value_len, char *value);/* parent,name can be NULL */
struct json_object  *json_create_object(struct json_object *parent, unsigned long name_len, char *name);/* parent,name can be NULL */
struct json_object  *json_create_array(struct json_object *parent, unsigned long name_len, char *name);/* parent,name can be NULL */
long                json_destroy(struct json_object *obj);

/* prev can be NULL, just for cache to serach performance */
struct json_object  *json_get_child_by_name(struct json_object *parent, struct json_object *prev, unsigned long name_len, char *name);

long                json_get_long(struct json_object *obj, long *value);
long                json_get_int64(struct json_object *obj, json_i64_t *value);
long                json_get_number(struct json_object *obj, double *value);
long                json_get_string(struct json_object *obj, struct len_str *value);

#define             json_get_child_long(_obj, _child_name_const, _out_value_pointer)    json_get_long(json_get_child_by_name(_obj, NULL, sizeof(_child_name_const) - 1, (char*)_child_name_const), _out_value_pointer)
#define             json_get_child_int64(_obj, _child_name_const, _out_value_pointer)   json_get_int64(json_get_child_by_name(_obj, NULL, sizeof(_child_name_const) - 1, (char*)_child_name_const), _out_value_pointer)
#define             json_get_child_number(_obj, _child_name_const, _out_value_pointer)  json_get_number(json_get_child_by_name(_obj, NULL, sizeof(_child_name_const) - 1, (char*)_child_name_const), _out_value_pointer)
#define             json_get_child_string(_obj, _child_name_const, _out_value_pointer)  json_get_string(json_get_child_by_name(_obj, NULL, sizeof(_child_name_const) - 1, (char*)_child_name_const), _out_value_pointer)
#define             json_del_child_by_name(_obj, _child_name_const)                     json_destroy(json_get_child_by_name(_obj, NULL, sizeof(_child_name_const) - 1, _child_name_const))

long                json_encode(struct json_object *obj, char *buf, unsigned long size);
struct json_object *json_decode(unsigned long text_len, char *text);
struct json_object *json_dup(struct json_object *parent/* can be NULL */, struct json_object *src);
long json_merge(struct json_object *dst/* can be NULL */, struct json_object *src);/* both should be object */

long                json_test_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__json_h__) */

