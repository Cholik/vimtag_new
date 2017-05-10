/*!
\file       mregx.h
\brief      light regular expression library 

 ----history----
\author     chengzhiyong
\date       2015-06-15
\version    0.01
\desc       create

*/
#if !defined(__mregx_h__)
#define __mregx_h__
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct mregx;

#if !defined(__len_str_defined)
#   define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */


#define mregx_err_base                  (-1)
#define mregx_err_invalid_param         (mregx_err_base - 0)
#define mregx_err_alloc                 (mregx_err_base - 1)
#define mregx_err_no_match              (mregx_err_base - 2)
#define mregx_err_unexpected_quantifier (mregx_err_base - 3)
#define mregx_err_unbalanced_brackets   (mregx_err_base - 4)
#define mregx_err_inner                 (mregx_err_base - 5)
#define mregx_err_invalid_charset       (mregx_err_base - 6)
#define mregx_err_invalid_metachar      (mregx_err_base - 7)
#define mregx_err_rets_overflow         (mregx_err_base - 8)
#define mregx_err_branches_overflow     (mregx_err_base - 9)
#define mregx_err_brackets_overflow     (mregx_err_base - 10)

#define mregx_flag_case_ignore	    0x01
/*!
func    mregx_create
\brief  create regular expression
\param  len[in]                 regx text length
\param  data[in]                regx text 
\param  flags[in]               the flags, refer to mregx_flag_xxx
\param  regx[out]               regx object
\return create result
        #0                      succeed
        #other                  error code
*/
long mregx_create(unsigned long len, char *data, unsigned long flags, struct mregx **regx);

/*!
func    mregx_destroy
\brief  destroy regular expression
\param  regx[in]                the regx object
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mregx_destroy(struct mregx *regx);

/*!
func    mregx_match
\brief  match target string
\param  regx[in]                the regx object
\param  len[in]                 the length of the matched text
\param  data[in]                the matched text
\param  max_rets[in]            the max counts of the results
\param  rets[out]               the results array
\return matched string length
        #<0                     error code
        #other                  matched string length
*/
long mregx_match(struct mregx  *regx,
                 unsigned long len,      char           *data, 
                 unsigned long max_rets, struct len_str *rets);

/*!
func    mregx_match_ex
\brief  match target string
\param  regx_len[in]            the regx text length
\param  regx[in]                the regx text
\param  flags[in]               the flags, refer mregx_flag_xxx
\param  len[in]                 the length of the matched text
\param  data[in]                the matched text
\param  max_rets[in]            the max counts of the results
\param  rets[out]               the results array
\return matched string length
        #<0                     error code
        #other                  matched string length
*/
long mregx_match_ex(unsigned long regx_len, char *regx, unsigned long flags,
                    unsigned long len,      char           *data, 
                    unsigned long max_rets, struct len_str *rets);

/*!
func    mregx_utils
\brief  utils
\param  argc[in]                the args counts
\param  artv[in]                the args
\return util run result
        #0                      succeed
        #other                  error code
*/
long mregx_utils(long argc, char *argv[]);


#ifdef __cplusplus
}
#endif

#endif  /* __mregx_h__ */
