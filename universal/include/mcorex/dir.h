/*!
\file       dir.c
\brief      dir unit
            if WIN32 FindFirstFile,FindNextFile,FindClose
            if LINUX opendir,readdir,closedir

 ----history----
\author     chengzhiyong
\date       2007-10-23
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: dir.h,v 1.3 2008-06-14 10:31:59 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__dir_h__)
#define __dir_h__

long dir_make(char *path);

struct dir_data* dir_open(char *path);
char* dir_read(struct dir_data *dir);
long dir_close(struct dir_data *dir);
long dir_get_workdir( char *path, unsigned long size );
long dir_get_module_dir(unsigned long module_counts, char **module_names, char *path, unsigned long path_size);/* get module path in current process */

#endif

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
