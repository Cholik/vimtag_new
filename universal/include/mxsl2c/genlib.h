/*
\file       genlib.h
\brief

----history----
\author     zhengxianwei
\date       2009-03-17
\version    0.01
\desc       create
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#ifndef  __genlib_h___
#define  __genlib_h___

#include	"mcore/mcore.h"

#ifdef  _MSC_VER
#define PATH_SEP        ('\\')
#define ENV_PATH_SEP    (';')
#ifndef inline
#define inline
#endif
#else      /* -----  not __WIN32__  ----- */
#define PATH_SEP        ('/')
#define ENV_PATH_SEP    (':')
#endif     /* -----  not __WIN32__  ----- */

#define EOL             ('\0')
#define BACK_SLASH      ('\\')
#define	DOUBLE_QUOT     ('"')
#define CR              (0x0D)
#define LF              (0x0A)

extern char *xsl2c_new_string (char *str);
extern void xsl2c_delete_string (char *str);

#endif   /* ----- #ifndef __genlib_h___  ----- */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
