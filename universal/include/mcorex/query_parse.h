/*!
\file       query_parse.h
\brief      user input query parse unit

 ----history----
\author     chengzhiyong 
\date       2008-02-24
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: query_parse.h,v 1.5 2008-05-31 09:27:56 chengzhiyong Exp $
*/
#if !defined(__query_parse_h__)
#define __query_parse_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__len_str_defined)
#define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */

typedef struct query_parse_result
{
    struct 
    {
        unsigned long   status;                 /* status, 0:inputting word 1:field value 2:order field 3:display field */ 
        struct len_str  word;                   /* end string, field name or key word name */ 
        struct len_str  sub_word;               /* end sub string, field value */ 
    }inputing;    /* now inputting     info */
    unsigned long       key_words_counts;
    struct len_str      *key_words;
    unsigned long       order_fields_counts;
    struct len_str      *order_fields;
    unsigned long       display_fields_counts;
    struct len_str      *display_fields;
    unsigned long       condition_counts;
    struct  
    {
        struct len_str  field;                  /* field name */ 
        unsigned long   values_counts;          /* values counts */
        struct len_str  *values;                /* value list */ 
        struct len_str  comb_value;             /* combin value in line */ 
    }*condition;
}_query_parse_result;
    
/*
query string sample:
手机
手机 厂商:诺基亚
手机 排序:厂商,型号
手机 厂商:诺基亚,TCL 排序:厂商,型号 显示:热度,价格,厂商,型号,类型,特点,摄像头
*/

#define query_info_inputting_status_inputing_word           0
#define query_info_inputting_status_inputing_field_value    1
#define query_info_inputting_status_inputing_order_field    2
#define query_info_inputting_status_inputing_display_field  3



/*! 
func    query_parse_create
\brief  parse query string
\param  str[in]                 query string 
\param  str_len[in]             query string length
\return parse result
        #NULL                   failed
        #other                  query info
 */
struct query_parse_result *query_parse_create(char *str, unsigned long str_len);

/*! 
func    query_parse_destroy
\brief  destory query info
\param  info[in]                the query info return by query create
\return void
 */
void query_parse_destroy(struct query_parse_result *info);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__query_parse_h__) */

