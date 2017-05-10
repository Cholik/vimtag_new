/*!
\file       extract_keyline.h
\brief      extract article keyline by title and content

 ----history----
\author     chengzhiyong 
\date       2008-05-11
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: extract_keyline.h,v 1.2 2008-09-29 07:30:53 chengzhiyong Exp $
*/
#if !defined(__extract_keyline_h__)
#define __extract_keyline_h__

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

long extk_get_keyline(struct len_str   *text,
                      struct len_str   *title,
                      struct len_str   *caption_line,
                      struct len_str   *abstract_line);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__keyline_h__) */
