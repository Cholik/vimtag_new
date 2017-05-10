/*!
\file       mnat_test.h
\brief      tcp socket proxy srv, used to analysis and debug network protocol

 ----history----
\author     chengzhiyong
\date       2012-04-29
\version    0.01
\desc       create
*/

#if !defined(__mnat_test_h__)
#define __mnat_test_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */


/*!
func    mnat_test_entry
\brief  nat test simple entry, function will block running until finished
\param	argc[in]            the args counts
\param  argv[in]            the args list
\return util run result
        #0                  succeed
        #other              error code
*/
long mnat_test_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */


#endif /* !defined(__mnat_test_h__) */

