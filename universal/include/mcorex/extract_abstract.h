/*!
\file       extract_abstract.h
\brief      extract article abstract by title and content

 ----history----
\author     chengzhiyong 
\date       2008-05-11
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: extract_abstract.h,v 1.2 2008-09-29 07:30:53 chengzhiyong Exp $
*/
#if !defined(__extract_abstract_h__)
#define __extract_abstractt_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/*! 
func    exta_get_abstract
\brief  get abstract from article
\param  text[in]                the text, first line should be title
\param	text_len[in]			the text len
\param	title[in]				title, if NULL set first line in text as title
\param	title_len[in]			the title len, if 0 set first line in text as title
\param  abstract[out]           the abstract line start pointer
\param  abstract_len[out]       the abstract line length
\return extract result
        #0                      succeed
        #other                  error code
*/
long exta_get_abstract(char		*text,
			          unsigned	text_len,
			          char		*title,
			          unsigned	title_len,
			          char		**abstract,
                      unsigned  *abstract_len);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__abstract_h__) */
