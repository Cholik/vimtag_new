/*!
\file       smss_api.h
\brief     

 ----history----
\author     Liuzp
\date       2014-02-25
\version    0.01
\desc       create

*/

#if !defined(__smss_api_h__)
#define __smss_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "smss_type.h"

struct smss_dev* smss_create(
    struct smss_dev_ctrl* pctrl
    );
long smss_destroy(
    struct smss_dev* dev
    );
long smss_info_get(
    struct smss_dev* dev, 
    struct smss_stor_info* pinfo
    );
long smss_format(
    struct smss_dev* dev, 
    struct smss_format_param* pparam
    );
long smss_cluster_list(
    struct smss_dev* dev, 
    ulong start_cluster,
    ulong sz,
    struct smss_cluster_info cluster_desc[],     
    ulong* pnum
    );
smss_handle smss_cluster_open(
    struct smss_dev* dev, 
    ulong cid,   /* Cluster physical id */
    ulong opt    /* r/w */
    );
long smss_cluster_close(
    struct smss_dev* dev, 
    smss_handle phdl
    );
//long smss_flush_by_desc(struct smss_dev* dev, struct smss_handle* desc); /* Flush completed segment  */
smss_handle smss_cluster_alloc(
    struct smss_dev* dev, 
    struct smss_cluster_owner* powner, 
    ulong opt
    );
long smss_cluster_info_get(
    struct smss_dev* dev,
    smss_handle phdl,
    struct smss_cluster_info* pdsc
    );
long smss_cluster_free(/*!< Release the owner right */
    struct smss_dev* dev, 
    ulong cid
    );
long smss_cluster_erase(/*!< Erase data only, keep occupy */
    struct smss_dev* dev, 
    ulong cid
    ); 
long smss_cluster_flush(/* Flush completed segment  */
    struct smss_dev* dev, 
    smss_handle phdl
    ); 
//long smss_cluster_lock(struct smss_dev* dev, struct smss_cluster_ctx*);
long smss_cluster_iterate(
    struct smss_dev* dev,
    smss_cluster_handle cluster_handler,
    void* data /* app data for <cluster_handler> */
    );
long smss_cluster_write_permit_close(
    struct smss_dev* dev
    , smss_handle phdl
    );
long smss_segment_list(
    struct smss_dev* dev, 
    smss_handle phdl, 
    ulong  start_id,              /*!< The start segment id, set to 0 at the first. */ 
    smss_segment_merger merge,
    ulong  sz,                    /*!< The size of <adesc> */
    struct smss_seg_info adesc[],
    ulong* pnum
    );
long smss_segment_write(
    struct smss_dev* dev, 
    smss_handle phdl, 
    struct smss_seg_desc* pdesc,
    char* pdata
    );
long smss_segment_direct_seek(
    struct smss_dev* dev,
    smss_handle phdl, 
    ulong sid,         /*!< Segment id */ 
    struct smss_seg_info* pseg_info
    );
#define smss_segment_first(dev, phdl, pseg_info)\
    smss_segment_direct_seek(dev\
        , phdl\
        , 0\
        , pseg_info\
        )
long smss_segment_direct_read(
    struct smss_dev* dev,
    smss_handle phdl, 
    ulong sid,         /*!< Segment id */ 
    ulong buf_sz, 
    char* data_buf, 
    ulong* data_len
    );

long smss_segment_direct_delete (
        struct smss_dev *dev,
        smss_handle phdl,
        uint32_t sid);

/*  
  function: smss_segment_seek
  \brief: seek to the first segment that satisfy the <filter> .
            if <filter> not provided, just seek to the start.
            if <filter> is null and pfiler_data is not null, make sure pfilter_data is type of <smss_time_t>
*/
long smss_segment_seek(
    struct smss_dev* dev,
    smss_handle phdl, 
    smss_segment_selector filter, 
    void* pfilter_data,
    struct smss_seg_info* pseg_info
    );
#define smss_segment_seek_by_time(dev, phdl, /* smss_time_t* */ pbase_time, pseg_info) \
     smss_segment_seek(dev\
         ,phdl\
         , NULL\
         , pbase_time\
         , pseg_info\
         )     
/* \brief: return the current segment id
 * \return: 0 on success
 *          err code on failure    
*/         
long smss_segment_current(
    struct smss_dev *dev,
    smss_handle phdl,
    unsigned long *psid,
    struct smss_seg_info* pseg_info
);
long smss_segment_delete (
        struct smss_dev *dev,
        smss_handle phdl,
        smss_segment_selector filter,
        void *filter_data);

long smss_segment_delete_by_time (
        struct smss_dev *dev,
        smss_handle phdl,
        uint64_t start_time,
        uint64_t end_time);

long smss_segment_next(
    struct smss_dev* dev,
    smss_handle phdl, 
    smss_segment_selector filter, 
    void* pfilter_data,
    struct smss_seg_info* pseg_info
    );
 long smss_segment_read(
    struct smss_dev* dev,
    smss_handle phdl,
    ulong buf_sz, 
    char* pdata_buf, 
    ulong* pdata_len
    );

 long smss_runtime_dump(
    struct smss_dev* dev,
    unsigned long     argc,
    char              *argv[],
    char              *buf,
    char              *file,
    unsigned long     start,
    unsigned long     counts,
    unsigned long     size
    );
long smss_struct_size_check(
   char              *buf,
   char              *file,
   unsigned long     start,
   unsigned long     counts,
   unsigned long     size
    );
long smss_last_err(
    struct smss_dev* dev
    );

/* smss_err2s
 *  erro code to string description
 *  in case invalid string,
 *  return "invalid error code"
*/
char* smss_err2s(
    long err_code
    );

#if defined(__cplusplus)
    }
#endif/* defined(__cplusplus) */

#endif /* !defined(__smss_api_h__) */
