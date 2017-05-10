/*!
\file       printf_ex.h
\brief      replace system printf, redirect acconrding to env

 ----history----
\author     chengzhiyong 
\date       2010-10-05
\version    0.01
\desc       create

*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__printf_ex_h__)
#define __printf_ex_h__

/*
    User module redirect stdout to file through two step:
    step 1. Redefine printf to printf_ex. There have two method to get this goal:
    (1)include printf_ex.h and link mcore lib
    (2)Replace printf in stdio.h like bollow and link mcore lib
**********************************************************
#ifdef PRINTF_EX_ENABLE
    int	 printf_ex(const char *, ...);
    #ifndef printf
    #define printf printf_ex
    #endif
#else
    _CRTIMP int __cdecl printf(const char *, ...);
#endif    
**********************************************************
    step 2. Define a printf file path to "printf_ex" in envioument setting. Printf result will be redirected into file like "printf_ex_2010.10.5_15.23.13.txt"
*/
#if defined(_mprintf_debug_enable) && _mprintf_debug_enable
#   undef printf
#   define printf printf_ex
#endif

int	printf_ex(const char *, ...);
long printf_ex_init(const char *module_name, long *level);
/* update printf level of special module runtime, module can be part of prefix name,
 if part of name will affect all module name start with it. return matched module counts. */
long printf_ex_level_set(char *module_name, long level);

#endif /* !defined(__printf_ex_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
