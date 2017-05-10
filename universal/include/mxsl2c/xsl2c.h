/*
\file       xsl2c.h
\brief      xsl translate to c

----history----
\author     zhengxianwei
\date       2009-03-17
\version    0.01
\desc       create
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#ifndef  __xsl2c_h___
#define  __xsl2c_h___
/*
func    xsl2c_gen_dll_lib_ex
\brief  generate dll[so] file from xsl
\param  xsl_fullpath[in]
\param  def[in]
\return int value
        #other              error
        #0                  success
*/
long xsl2c_gen_dll_lib_ex (const char *xsl_fullpath,
                           struct pack_def *def,
                           const char *dll_lib_path);
#endif   /* ----- #ifndef __xsl2c_h___  ----- */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
