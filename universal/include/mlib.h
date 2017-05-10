/*!
\file       mlib.h
\brief      mlib include file list

 ----history----
\author     dakota
\date       2007-09-10
\version    0.01
\desc       create
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__mlib_h__)
#define __mlib_h__

#if 0 /* for memory debug, if linux do not need this */
#if defined(_WIN32) && (!defined(_mmem_debug_enable))
#define _mmem_debug_enable/*! memory hook! add by chengzhiyong 2008-07-17 fo memory debug */
#endif
#endif


#if defined(_WIN32)
#   define _CRT_SECURE_NO_WARNINGS
#   include <windows.h>
#else
#   include <sys/types.h>
#   include <sys/socket.h>
#   include <netinet/in.h>
#   include <arpa/inet.h>
#endif

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <assert.h>

#include <string.h>

#include "mcore/mcore.h"
#include "mmsg/mmsg.h"
#include "mcomp_loader/mcomp_loader.h"
#include "mdepository/mdepository.h"
#include "mhashmap/mhashmap.h"
#include "mlid/mlid.h"
#include "mmedia/mmedia.h"

#if 0
#include "msdp/msdp.h"
#include "mrtmp/mrtmp.h"
#include "mrtsp/mrtsp.h"

#include "mdsp/mdsp.h"
#include "mcam/mcam.h"
#include "mcab/mcab.h"
#endif
#endif /* !defined(__mlib_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

