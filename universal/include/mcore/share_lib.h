/*!
\file       share_lib.h
\brief      the share lib unit, if windows load dll, if linux load .so

 ----history----
\author     chengzhiyong 
\date       2007-01-30
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: share_lib.h,v 1.5 2008-06-02 07:39:12 chengzhiyong Exp $
*/
#if !defined(__share_lib_h__)
#define __share_lib_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if defined(_WIN32) /* just for windows platform */
#define shl_static_init() \
    BOOL APIENTRY DllMain(HANDLE handle, DWORD  reason, LPVOID reserved)\
    {\
    switch(reason)\
    {\
        default: break;\
        }\
        return TRUE;\
    }
#elif defined(__rtthread__)
#elif defined(__ucos__)
#else
#   include <dlfcn.h>
#define shl_static_init() 
#endif

#if !defined(LIB_API) 
#   if defined(_WIN32) && defined(_MSC_VER)
#       if defined(__cplusplus)
#           define LIB_API extern "C" __declspec(dllexport)
#       else
#           define LIB_API __declspec(dllexport)
#       endif
#   else
#       define LIB_API
#   endif
#endif

/*!
func    shl_load
\brief  load libary, map to _WIN32.LoadLibary or linux.dlopen
\param  file_name[in]           the share lib(.dll/.so) name
\return load result
        #NULL                   failed
        #other                  the handle
*/
#if defined(_WIN32) /* windows */
#   ifdef WINCE
        extern void *shl_load_x( char *name );
#       define shl_load(name)  shl_load_x((name))
#   else
#       define shl_load(name)  LoadLibraryEx(name, NULL, LOAD_WITH_ALTERED_SEARCH_PATH)
#   endif
#elif defined(__rtthread__)
#   define shl_load(name)  (0)
#else /* linux */
#   define shl_load(name)  dlopen(name, RTLD_NOW)
#endif

/*!
func    shl_unload
\brief  unload libary
\param  handle[in]              the share lib(.dll/.so) handle in this process, return by shl_load()
\return load result
        #0                      succeed
        #other                  the error code
*/
#if defined(_WIN32) /* windows */
#   define shl_unload(handle)  FreeLibrary((HANDLE)handle)
#elif defined(__rtthread__)
#   define shl_unload(handle)  (0)
#else /* linux */
#   define shl_unload(handle)  dlclose((void*)handle)
#endif


/*!
func    shl_get_proc
\brief  unload libary, map to _WIN32.GetProcAddress or linux.dlsym
\param  handle[in]              the share lib(.dll/.so) handle in this process, return by shl_load()
\param  name[in]                the proc name, function name, char* type
\return load result
        #NULL                   failed
        #other                  the proc address
*/
#if defined(_WIN32) /* windows */
#   ifdef WINCE
        extern void * shl_get_proc_x( unsigned long handle, char *name );
#       define shl_get_proc(handle, name)  shl_get_proc_x((handle), (name))
#   else
#       define shl_get_proc(handle, name)  GetProcAddress((HANDLE)handle, name)
#   endif
#elif defined(__rtthread__)
#   define shl_get_proc(handle, name)  (0)
#else /* linux */
#   define shl_get_proc(handle, name)  dlsym((void*)handle, name)
#endif

/*!
func    shl_error
\brief  get share libary operation error 
\return the error string 
        #NULL                   failed
        #other                  the proc address
*/
#if defined(_WIN32) /* windows */
#   ifdef WINCE
#       define shl_error() "error" 
#   else
        char *win_strerror(unsigned long err_no);
#       define shl_error() win_strerror(GetLastError()) 
#    endif
#elif defined(__rtthread__)
#   define shl_error() "err-info-not-support" 
#else /* linux */
#   define shl_error()  dlerror()
#endif


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__share_lib_h__) */
