/*!
\file       smss_stor.h
\brief     

 ----history----
\author     Liuzp
\date       2014-02-25
\version    0.01
\desc       create

*/

#if !defined(__smss_stor_h__)
#define __smss_stor_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "smss_dict.h"

struct smss__stor_dev;
struct smss_format_param; 
struct smss_cluster_owner;
struct smss__user;

long smss__stor_open(
    struct smss__stor_dev* dev
    );
long smss__stor_close(
    struct smss__stor_dev* dev
    );
long smss__stor_format(
    struct smss__stor_dev* dev, 
    struct smss_format_param* param  /*valid param */
    );
smss_handle smss__stor_cluster_alloc(
    struct smss__stor_dev* pstor_dev, 
    struct smss_cluster_owner* powner,
    ulong opt
    );
smss_handle smss__stor_cluster_open(
    struct smss__stor_dev* pstor_dev,
    ulong  cid,
    ulong opt
    );
long smss__stor_cluster_close(
    struct smss__stor_dev*  pstor_dev, 
    smss_handle phdl
    );
long smss__stor_cluster_free(
    struct smss__stor_dev* pstor_dev,   
    ulong cid
    );
long smss__stor_cluster_erase(
    struct smss__stor_dev* pstor_dev,   
    ulong cid
    );
struct smss__cluster* smss__work_cluster(
    struct smss__user* phdl
    );
long smss__stor_seg_write(
    struct smss__stor_dev* pstor_dev, 
    smss_handle phdl, 
    struct smss_seg_desc* pdesc,
    char* pdata
    );
struct smss__cluster* smss__work_cluster_open(
    struct smss__stor_dev* pstor_dev,
    ulong  cid
    );
long smss__cluster_try_close(
     struct smss__stor_dev*     pstor_dev, 
     struct smss__cluster* pwc
    );
ullong smss__logic_id_alloc(
    struct smss__stor_dev* pstor_dev
    );
long smss__stor_cluster_wp_close(
    struct smss__stor_dev* pstor_dev,   
    smss_handle phdl
    );    
#if defined(__cplusplus)
    }
#endif/* defined(__cplusplus) */

#endif  /*!> __smss_stor_h__*/

