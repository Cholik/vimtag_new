/*!
\file       mtime_ex.h
\brief      time extentional unit

 ----history----
\author     chengzhiyong
\date       2008-09-05
\version    0.01
\desc       create

\author     chengzhiyong
\date       2014-06-08
\version    0.02
\desc       rename time_xxx to mtime_xxx
*/
#if !defined(__mtime_ex_h__)
#define __mtime_ex_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include <time.h>

#if defined(__rtthread__)
struct tm;
#endif

/*! \brief time value for 2000-01-01 00:00:00 */
#define mtime_ex_2000_01_01_00_00_00_value   946656000

#define mtime_tick_sub( a, b ) (unsigned long)((a) - (b))
#define mtime_tick_add( a, b ) (unsigned long)((a) + (b))
#define mtime_tick_cmp( a, b ) (long)((mtime_tick_sub((a),(b)) > 0x80000000)?(-1):mtime_tick_sub((a),(b)))

/*!
func    mtime2s
\brief  convert time to sting, use it at once
\param  time[in]                time, if 0 get now time.
\return time string 
*/
const char *mtime2s(time_t t);

/*!
func    mtime_tick
\brief  get current tick value
\return time tick now
*/
unsigned long mtime_tick(void);

/*!
func    mtime_us
\brief  get current us tick value
\return time ustick now
*/
unsigned long mtime_us(void);

long mtime_zone(long force_refresh);

struct tm *mtime_localtime(time_t *p);
time_t mtime_mktime_ex(int year,int mon,int day,int hour,int min,int sec);
time_t mtime_mktime(struct tm *mk);


#define mtime_gmt_ms()   ((time(NULL) * 1000) + (mtime_tick() % 1000))
#define mtime_tick_s(_s) (_s = mtime_tick())

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
#endif /* !defined(__mtime_ex_h__) */
