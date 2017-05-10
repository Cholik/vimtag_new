/*!
\file       extract_name.h
\brief      extract name from string list

 ----history----
\author     chengzhiyong 
\date       2008-05-11
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: extract_name.h,v 1.3 2008-09-30 08:02:23 chengzhiyong Exp $
*/
#if !defined(__extract_name_h__)
#define __extract_name_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct extn_refer;

/*!
func    extn_create
\brief  create extract name refer data
\return create result
        #NULL                   failed
        #other                  the refer object
*/
struct extn_refer *extn_create(void);

/*!
func    extn_destroy
\brief  destroy extract name refer data
\param  ref[in]                 the name refer object
\return destroy result
        #0                      succeed
        #other                  error code
*/
long extn_destroy(struct extn_refer *ref);

/*!
func    extn_train
\brief  train extract name object
\param  ref[in]                 the name refer object
\param  line[in]                the train text line, best line is TITLE
\param  len[in]                 the train text line length
\return trian result
        #0                      succeed
        #other                  error code
*/
long extn_train(struct extn_refer *ref, unsigned char *line, unsigned long len);

/*!
func    extn_get_name
\brief  train extract name object
\param  ref[in]                 the name refer object
\param  line[in]                the calculate text line, best line is TITLE
\param  len[in]                 the calculate text line length
\param  name[out]               the name, the string should without ZERO end char
\param  name_len[out]           the name length
\return extract result
        #0                      succeed
        #other                  error code
*/
long extn_get_name(struct extn_refer    *ref,
                   char                 *line,
                   unsigned long        len,
                   char                 **name,
                   unsigned long        *name_len);

/*!
func    extn_get_class
\brief  get class by extract name objects, at least two objects
\param  refs[in]                the name refer object list
\param  counts[in]              the name extract refer object counts
\param  names[out]              the names pointer array to save names for refers
\param  name_lens[out]          the name length array to save length list
\return extract result
        #0                      succeed
        #other                  error code
*/
long extn_get_class(struct extn_refer   **refs,
                    unsigned long       counts,
                    char                **names,
                    unsigned long       *name_lens);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif/* !defined(__extract_name_h__) */
