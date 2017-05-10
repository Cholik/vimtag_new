/*!
\file       mpatch_api.h
\brief      mpatch api header file

 ----history----
\author     dakota
\date       2012-12-26
\version    0.01
\desc       create
*/
#if !defined(__mpatch_api_h__)
#define __mpatch_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/*!
func    mpatch_diff
\brief  build patch file according to old file and new file
\param  old_path[in]            path of old file
\param  new_path[in]            path of new file
\param  diff_path[in]           path of diff file
\return 
        #0                      succeed
        #other                  error code
*/
extern long mpatch_diff( char *old_path, char *new_path, char *diff_path, long compress_level );

/*!
func    mpatch_patch
\brief  build new file according to old file and patch file
\param  old_path[in]            path of old file
\param  new_path[in]            path of new file
\param  diff_path[in]           path of diff file
\return 
        #0                      succeed
        #other                  error code
*/
extern long mpatch_patch( char *old_path, char *new_path, char *diff_path );


extern long mpatch_diff_util(long argc, char *argv[]);
extern long mpatch_patch_util(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mpatch_api_h__) */
