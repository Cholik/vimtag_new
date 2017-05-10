/*!
\file       margs.h
\brief      args unit

 ----history----
\author     chengzhiyong
\date       2012-12-15
\version    0.01
\desc       create

\author     chengzhiyong
\data       2014-05-31
\version    0.02
\desc       conert args_xxx to margs_xxx
*/
#if !defined(__margs_h__)
#define __margs_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/*!
func    margs_get_index
\brief  get opt index by name
\param  argc[in]                the argc
\param  argv[in]				the argv list
\param  name[in]                param name
\return 
        #<0                     not found
        #other                  the opt index
*/
long margs_get_index(long argc, char **argv, char *name);

/*!
func    margs_get_counts
\brief  check is have opt, will not check is have value, such as "--help"
\param  argc[in]                the argc
\param  argv[in]                the argv list
\param  name[in]                param name
\return
        #<0                     error code
        #other                  opt counts
*/
long margs_get_counts(long argc, char **argv, char *name);

/*!
func    margs_get_opt
\brief  get param by name
\param  argc[in]                the argc
\param  argv[in]                the argv list
\param  name[in]                param name
\return
        #NULL                   have not this param
        #other                  error code
*/
char *margs_get_opt(long argc, char **argv, char *name);

/*!
func    margs_get_opt_long
\brief  get opt long value
\param  argc[in]                the argc
\param  argv[in]                the argv list
\param  name[in]                param name
\return long value
        #0                      if user not set, return 0, maybe user set it as 0
        #other                  the value
*/
long margs_get_opt_long(long argc, char **argv, char *name);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__args_h__) */
