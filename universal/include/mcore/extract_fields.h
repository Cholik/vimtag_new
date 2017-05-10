/*!
\file       extract_fields.h
\brief      extract fields info from text

 ----history----
\author     chengzhiyong 
\date       2008-04-29
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: extract_fields.h,v 1.6 2008-11-27 09:09:25 chengzhiyong Exp $
*/
#if !defined(__extract_fields_h__)
#define  __extract_fields_h__

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

/*! \brief extracted fields */
typedef struct extf_field
{
    struct len_str   group;     /*!< group name */
    struct len_str   name;      /*!< name */
    struct len_str   value;     /*!< value */
}_extf_field;

typedef struct extf_statistic
{
    struct  
    {
        unsigned long   line_counts;            /*!< group counts */
        unsigned long   line_len_max;           /*!< group line max length */
        unsigned long   line_len_sum;           /*!< group line length sum */
    }group;                                 /*!< group statistic */
    struct  
    {
        unsigned long   line_counts;            /*!< field line counts */
        unsigned long   line_len_max;           /*!< field line length max */
        unsigned long   line_len_sum;           /*!< field line length sum */
    }field;                                 /*!< field statistic */
    struct  
    {
        unsigned long   line_counts;            /*!< none field lines counts */
        unsigned long   line_len_max;           /*!< max non line line */
        unsigned long   line_len_sum;           /*!< none fields lines length sum */
    }none_data;                             /*!< lines without data statistic */
    struct  
    {
        unsigned long   tab_line_counts;        /*!< table line counts */
        unsigned long   tab_counts_sum;         /*!< table char counts sum */
        unsigned long   tab_counts_max;         /*!< table char max counts in a line */

        unsigned long   colo_line_counts;       /*!< colo line counts */
        unsigned long   colo_counts_sum;        /*!< colo char counts sum, include English and Chinese colo */
        unsigned long   colo_counts_max;        /*!< colo char max counts in a line, include English and Chinese colo */

        unsigned long   mix_line_counts;        /*!< the line with both have colo and tab char counts*/
    }split;                                 /*!< split statistic */
}_extf_statistic;

/*! \brief txt fields */
typedef struct extf_fields
{
    unsigned long           counts;         /*!< fields counts */
    struct extf_field       *data;          /*!< fields list */
    struct extf_statistic   satistic;       /*!< statistic */
}_extf_fields;

/*!
func    extf_create
\brief  extract fields from text
\param  text[in]                the text
\return extract result, len-string in result have not END char.
        #NULL                   failed
        #other                  fields list
*/
struct extf_fields *extf_create(char *text);

/*!
func    extf_destroy
\brief  destroy fields
\param  fields[in]              the fields return by extf_create()
\return destroy result
        #0                      succeed
        #other                  error code
*/
long extf_destroy(struct extf_fields *fields);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__extract_fields_h__) */
