/*!
\file       process.h
\brief      process unit

 ----history----
\author     chengzhiyong
\date       2012-06-02
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: process.c,v 1.18 2012-06-02 03:26:06 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if defined(__rtthread__)
#   define EXIT_FAILURE (-1)
#   define EXIT_SUCCESS (0)
#   define getpid()     (0)
#   define kill(_a,_b)  (0)
#   define exit(_a)     (0)
#endif

/*!
func    process_get_path
\brief  get process path
\param  path[out]               the process path buffer
\param  size[in]                the process path buffer size
\return the path length
        #>0                     path length
        #other                  error code
*/
long process_get_path(char *path, unsigned long size);

/*!
func    process_get_module_path
\brief  get process module(dll)'s path in current process, return first matched path
\param  module_counts[in]       module counts
\param  module_names[in]        module names array
\param  path[out]               the process path array buffer, save first matched module's path
\param  size[in]                the process path buffer size
\param  index[out]              used to save the module index be found in module_names[], can be NULL, if NULL ignore
\return the path length
        #>0                     path length
        #other                  error code
*/
long process_get_module_path(unsigned long module_counts, char **module_names, char *path, unsigned long path_size, unsigned long *index);

struct process_pipe;
/*!
func    process_pipe_create
\brief  create process pipe
\param  cmd[in]                 the command line
\return pipe
        #NULL                   failed
        #other                  the pipe object
*/
struct process_pipe *process_pipe_create(char *cmd);

/*!
func    process_pipe_destroy
\brief  destroy process pipe
\param  pipe[in]                the pipe object
\return destroy result
        #0                      succeed
        #other                  error code
*/
long process_pipe_destroy(struct process_pipe *pipe);

/*!
func    process_pipe_read
\brief  read data from pipe
\param  pipe[in]                the pipe object
\param  buf_size[in]            the buffer size
\param  buf[out]                the recv buffer
\return content length
        #<0                     error code
        #other                  read length
*/
long process_pipe_read(struct process_pipe *pipe, unsigned long buf_size, unsigned char *buf);

/*!
func    process_pipe_write
\brief  read data from pipe
\param  pipe[in]                the pipe object
\param  data_len[in]            the data length
\param  data[in]                the data
\return write result
        #<0                     error code
        #other                  wrote length
*/
long process_pipe_write(struct process_pipe *pipe, unsigned long data_len, unsigned char *data);

/*!
func    process_is_root
\param  void
\return check result
        #0                      have root right
        #other                  error code 
*/
long process_check_root();

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
