/*!
\file       extract_price.h
\brief      extract price from text

 ----history----
\author     chengzhiyong 
\date       2009-02-19
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: extract_price.h,v 1.19 2009-02-19 03:25:07 chengzhiyong Exp $
*/
#if !defined(__extract_price_h__)
#define __extract_price_h__

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

/*! \brief prices */
typedef struct extp_price
{
    struct extp_price   *next;          /*!< next price */
    struct extp_price   *prev;          /*!< prev price */
    struct len_str      type;           /*!< type */
    struct len_str      name;           /*!< name */
    struct len_str      value;          /*!< value */
}_extp_price;

/*! \brief prices list */
typedef struct extp_prices
{
    unsigned long       counts;         /*!< price counts */
    struct extp_price   *list;          /*!< last price */                    
}_extp_prices;

/*!
func    extp_create
\brief  extract price from text base title
\param  text[in]                the text
\return extract result
        #NULL                   failed, with out any valid price
        #other                  the price list
*/
struct extp_prices *extp_create(struct len_str *text);

/*!
func    extp_destroy
\brief  destroy prices list
\param  prices[in]              the prices list
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long extp_destroy(struct extp_prices *prices);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__extract_price_h__) */
