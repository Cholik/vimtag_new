/*
\file		str-num.h
\brief		string num dealwith unit, support english and chinese
 ----history----
\author     chengzhiyong
\date       2007-05-22
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: str_num.h,v 1.1.1.1 2007-11-25 15:09:18 chengzhiyong Exp $
*/
#if !defined(__str_num_h__)
#define  __str_num_h__

#if defined(__cplusplus)
extern "C" {
#endif

/*!
func    str2num
\brief  get number from string, support chinese and float
\param  str[in]                 string, should in utf-8 charset, support chinese and 0-9
\param  size[in]                the string size
\param  value[out]              output value
\return number len
        #<0                     error code
        #0                      not a number
        #>0                     number len in this string
*/
long str2num(char *str,  unsigned long str_len, double *value);
long str2num_range(char *str,  unsigned long str_len, double *value1, double *value2 );

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__str_num_h__) */
