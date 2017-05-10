/*!
\file       file.h
\brief      file unit

 ----history----
\author     chengzhiyong
\date       2007-03-04
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: file.h,v 1.4 2008-09-01 11:22:17 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__file_h__)
#define __file_h__

#define file_flags_default  0x00
#define file_flags_lock     0x01

#if defined(__rtthread__) && !defined(mfile_api_disable_fake_define)
#   define mfile_api_disable_fake_define 1
#endif

#if defined(mfile_api_disable_fake_define) && mfile_api_disable_fake_define
    typedef struct _FILE {int x; } FILE;
    typedef long                   fpos_t;
#   define fopen(_a,_b)            ((void*)0)
#   define fclose(_a)              (-1)
#   define fwrite(_a,_b,_c,_d)     (-1)
#   define fread(_a,_b,_c,_d)      (-1)
#   define fseek(_a,_b,_c)         (-1)
#   define fgetpos(_a, _b)         (-1)
#   define flock(_a,_b)            (-1)
static int fprintf(FILE *stream, const char *format, ...){return -1;};
#endif


/*!
func    file_size
\brief  get file size
\param  name[in]                the file name
\param  site_bits[in]           the size bits, should be 32
\param  size[out]               the size save pointer
\return the result
        #0                      succeed
        #other                  error code */
long file_size(char *name, long size_bits, void *size);

/*!
func    file_load
\brief  load file into memory
\param  name[in]                the file name
\param  data_len[out]           the data length, if NULL ignore
\param  flags[in]               the flags, ref file_flags_xxx, default 0
\return data pointer, after using call file_unload to release
        #NULL                   failed
        #other                  file data */
void *file_load(char *name, unsigned long *len, unsigned long flags);

/*!
func    file_unload
\brief  unload file data from memory
\param  data[in]                the data return by file_load
\return unload result
        #0                      succeed
        #<0                     error code */
long file_unload(void *data);

/*!
func    file_save
\brief  save data to file, if file exists will be delete
\param  name[in]                the file name
\param  data[in]                the data, output pointer, memory alloc by file_load
                                need destroy by free
\param  size[in]                the data size
\param  flags[in]               the flags, ref file_flags_xxx, default 0
\return save result
        #0                      succeed
        #>0                     file size
        #<0                     error code */
long file_save(char *name, void *data, unsigned long size, unsigned long flags);

/*!
func    file_log_name_prepare
\brief  prepare log file name
        file-name will be [<moudle>-<YYYYMMDD>-<HHMMSS>--<obj>-<ID>-<TOTAL-COUNTS>.<type>]
        should set enviroment "evn[env_path_name]=<path>", "evn[env_module_name]=<module1>,<module2>"
\param  env_path_name[in]   env path name
\param  env_module_name[in] evn module name
\param	module[in]          module name, will check "env[env_module_name]" environment
                            if not exist this environment will do nothing and return NULL
\param  type[in]            type
\param  id[in]              id 
\param  buf_size[in]        the buffer size used to output file name
\param  buf[out]            file name buffer
\return file-path length
        #<0                 error code
        #0                  don't need log(not set by environment)
        #other              the file path length
*/
long file_log_name_prepare(char *env_path_name, char *env_module_name,
                           char *module, char *type, unsigned long id, char *file_ext,
                           unsigned long buf_size, char *buf);


#endif /* !defined(__file_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
