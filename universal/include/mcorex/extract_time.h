/*!
\file       extract_time.c
\brief      extract price from text

 ----history----
\author     chengzhiyong 
\date       2009-03-15
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: extract_time.c,v 1.19 2009-02-19 03:25:07 chengzhiyong Exp $
*/
#if !defined(__extract_time_h__)
#define __extract_time_h__

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

typedef struct extt_time
{
    struct extt_time        *next;          /*!< next date time */
    struct extt_time        *prev;          /*!< prev date time */
    struct len_str          date;           /*!< date part, always before time */
    struct len_str          time;           /*!< time */
}_extt_time;

/*! \brief extract result date time list */
typedef struct extt_times
{
    unsigned long           counts;     /*!< date time counts */
    struct extt_time        *list;      /*!< date time list */
}_extt_times;

/*
2009-03-11 10:21:16   2009-1-1¡¡8:53:13      2009-1-1 5:18:00     2009-02-15 13:32:02      2009-03-11 14:59           02-13 22:45
*/

/*!
func    extt_destroy
\brief  destroy prices list
\param  times[in]               the date time list
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long extt_destroy(struct extt_times *times);

/*!
func    extt_times
\brief  extract datetimes from text
\param  text[in]                the text
\return extract result
        #NULL                   failed, with out any valid dates
        #other                  the date time list
*/
struct extt_times *extt_create(struct len_str *text);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__extract_time_h__) */
