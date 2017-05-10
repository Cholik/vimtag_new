/*!
\file       html.h
\brief      html parse unit

 ----history----
\author     chengzhiyong 
\date       2008-04-21
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: html.h,v 1.8 2008-11-29 03:22:59 chengzhiyong Exp $
*/
#if !defined(__html_h__)
#define __html_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct html_node;

/*!\brief html parse statistic info */
typedef struct html_statistic
{
    unsigned long   node_counts;                /*!< node counts */
    unsigned long   alink_counts;               /*!< alink counts */
    unsigned long   img_counts;                 /*!< img counts */
}_html_statistic;
    
/*!
func    html_create
\brief  parse html string
\param  text[in]                html string
\return parse result
        #NULL                   parse error, malloc memory error or invalid html file
        #other                  root node
*/
struct html_node* html_create(char *text);

/*!
func    html_destroy
\brief  free html node
\param  root[in]                the root return by html_create
\return detroy result
        #0                      succeed
        #other                  error code
*/
long html_destroy(struct html_node* root);

/*!
func    html_try_statistic
\brief  statistic html node
\param  root[in]                the root return by html_create
\param  statistic[out]          the statistic info
\return void
*/
long html_try_statistic(struct html_node *root, struct html_statistic *statistic);

/*!
func    html_get_head_item
\brief  get key head item, such as title, meta, base
\param  root[in]                the html root node
\param  node_name[in]           the node name, such as title/meta/base
\param  key_attr_name[in]       the key attribute name. can be NULL(such as title/base)
\param  key_attr_value[in]      the key attribute value. ignore when key_attr_name is NULL,
                                set when get meta
\param  value_attr_name[in]     the attribute name. if title, should be NULL, will return node's text content.
                                will be set in meta
\param  value[out]              the value
\return the value length
        #>=0                    value length
        #other                  error code
*/
long html_get_head_item(struct html_node    *root,
                        char                *node_name,
                        char                *key_attr_name,
                        char                *key_attr_value,
                        char                *value_attr_name,
                        char                **value);

/*!
func    html_get_nodes
\brief  get nodes from html node tree
\param  node[in]                html node
\param  tag_name[in]            the tag name
\param  tag_name_len[in]        the tag name string length
\param  counts[in/out]          [in] is max counts, [out] is real counts
\param  result[out]             the result nodes
\return get result
        #0                      succeed
        #<0                     error code
        #>0                     1: warning, should be buffer overflow
*/
long html_get_nodes(struct html_node    *node,
                    char                *tag_name,
                    unsigned long       tag_name_len,
                    unsigned long       *counts,
                    struct html_node    **result);

/*!
func    html_get_attr
\brief  get attribute from html node
\param  node[in]                html node
\param  attr_name[in]           the attribute name string
\param  attr_name_len[in]       the attribute name string length
\param  attr_value_len[out]     the attribute value length
\return get result
        #NULL                   have not attribute
        #other                  attribute string
*/
char *html_get_attr(struct html_node     *node,
                    char                 *attr_name,
                    unsigned long        attr_name_len,
                    unsigned long        *attr_value_len);

/*!< get html text refer data */
typedef struct html_get_text_ref
{
    struct
    {
        unsigned long    disable_noise_clean;    /*!< disable noise clean */
    }flag;
}_html_get_text_ref;
/*!
func    html_get_text
\brief  get plain text by html node
\param  node[in]                html node
\param  buf[out]                the text buffer
\param  buf_size[in]            the buffer size
\param  flag[in/out]            the text get refer, if NULL ignore, default is clean noise
\return get result
        #<0                     error code, should be invalid param or buffer overflow
        #other                  the text length
*/
long html_get_text(struct html_node *node, char *buf, unsigned long buf_size, struct html_get_text_ref *ref);
long html_get_text_by_html(char *html, char *buf, unsigned long buf_size, struct html_get_text_ref *ref);
long html_get_title_by_html(char *html, char *buf, unsigned long buf_size);
long html_get_description_by_html(char *html, char *buf, unsigned long buf_size);


#if defined(__cplusplus)
}
#endif

#endif /* #if !defined(__html_h__) */
