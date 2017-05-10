/*!
\file       xml.h 
\brief      xml parse unit

 ----history----
\author     chengzhiyong 
\date       2007-01-06
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: xml.h,v 1.6 2008-08-16 04:30:50 chengzhiyong Exp $
*/

#if !defined(__xml_h__)
#define __xml_h__

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

/*!
func    xml_create
\brief  parse xml string
\param  text[in]                xml string
\return parse result
        #NULL                   parse error, malloc memory error or invalid xml file
        #other                  root node
*/
struct xml_node* xml_create(char *text);

/*!
func    xml_destroy
\brief  free xml node
\param  root[in]                the node try free, return by xml_create
\return destroy result
        #0                      succeed
        #other                  error code
*/
long xml_destroy(struct xml_node *root);

/*!
func    xml_get_node
\brief  get xml node special xpath
\param  node[in]                the xml node
\param  path[in]                the x-path, if attributes should be "xxx[n]/ppp[m]@tttt",
                                node text is "xxx[n]/ppp[m]", if "name()" will return node'name
\param  len[out]                the text len, can be NULL,if NULL will ge ignore
\return the node
        #NULL                   node not exist
        #other                  the node
*/
struct xml_node* xml_get_node(struct xml_node *node, char *path);

/*!
func    xml_get_text
\brief  get xml node's refer text by special xpath
\param  node[in]                the xml node
\param  path[in]                the x-path, if attributes should be "xxx[n]/ppp[m]@tttt",
                                node text is "xxx[n]/ppp[m]", if "name()" will return node'name
\param  len[out]                the text len, can be NULL,if NULL will ge ignore
\return get result
        #NULL                   get error, have not exist
        #other                  text string
*/
char* xml_get_text(struct xml_node *node, char *path, unsigned long *len);

/*!
func    xml_get_counts
\brief  get node count of the xpath
\param  node[in]                the xml node
\param  path[in]                the x-path, if attributes should be "xxx[n]/ppp[0]"
\return the counts of the special path
        #<0                     error code
        #other                  node counts
*/
long xml_get_counts(struct xml_node *node, char *path);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__xml_h__) */
