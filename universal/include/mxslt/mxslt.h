/*!
\file       mxslt.h
\brief      mxslt include file list
*/
#if !defined(__mxslt_h__)
#define __mxslt_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(mframework_version_disable)
#include "mcore/mframework_version.h"
#endif

struct mxslt_cb;
struct message;
long mxslt_add_stylesheet( struct mxslt_cb *cb,
                           void *name, unsigned long name_len,
                           void *data, unsigned size, unsigned long *handle );
int mxslt_add_stylesheet_file( struct mxslt_cb *cb,
                               void *name, unsigned long name_len,
                               char *file, unsigned long *handle );
long mxslt_apply_stylesheet_pack_2_str( unsigned long handle,
                                        struct pack_def *def, void *pack, unsigned long pack_size,
                                        void *buf, unsigned long buf_size );
long mxslt_apply_stylesheet_message_2_str( unsigned long handle,
                                           struct pack_def *def, struct message *msg,
                                           void *buf, unsigned long buf_size );
struct mxslt_cb * mxslt_create();
long mxslt_del_stylesheet( struct mxslt_cb *cb, void *name, unsigned long name_len );
long mxslt_destroy( struct mxslt_cb *cb );
long mxslt_get_stylesheet( struct mxslt_cb *cb, void *name, unsigned long name_len, unsigned long *handle );

#if defined(_MSC_VER)
/* get mframework prefix */
#   undef  mlib_mframework_prefix__local
#   if !defined(mlib_mframework_prefix)
#       define mlib_mframework_prefix__local
#       define mlib_mframework_prefix   "mxslt"
#   endif
/* comment lib */
#   if defined(_LIB)
#       if defined(_DEBUG)
#           pragma comment(lib, mlib_mframework_prefix".debug.a")
#       else
#           pragma comment(lib, mlib_mframework_prefix".a")
#       endif
#   else
#       if defined(_DEBUG)
#           pragma comment(lib, mlib_mframework_prefix".debug.dll.lib")
#       else
#           pragma comment(lib, mlib_mframework_prefix".dll.lib")
#       endif
#   endif
/* clear flag */
#   if defined(mlib_mframework_prefix__local)
#       undef  mlib_mframework_prefix__local
#       undef  mlib_mframework_prefix
#   endif
#endif  /* defined(_MSC_VER) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mxslt_h__) */

