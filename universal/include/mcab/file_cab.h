/*!
\file       file_cab.h
\brief      cab file list

\author     chengzhiyong
\date       2011-05-04
\version    0.01

*/

#ifndef __file_cab_h__
#define __file_cab_h__

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

typedef struct mcab_item
{
    struct  
    {
        struct mcab_item    *prev;
        struct mcab_item    *next;
    }in_cab;
    struct len_str          name;
    struct len_str          data;
    unsigned long           desc_size;
}_mcab_item;

typedef struct mcab
{
    unsigned long       read_only;

    unsigned long       counts;
    struct mcab_item    *list;

    unsigned long       desc_total_size;
    unsigned long       data_total_size;

    unsigned long       buf_len;
    unsigned char       *buf;
}_mcab;

struct mcab *mcab_create();
long mcab_destroy(struct mcab *cab);
long mcab_add(struct mcab *cab, struct len_str *desc_name, struct len_str *file_name);
struct mcab *mcab_decode(struct len_str *data);
long mcab_encode(struct mcab *cab, unsigned long buf_size, unsigned char *buf);
long mcab_utils_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__file_cab_h__) */
