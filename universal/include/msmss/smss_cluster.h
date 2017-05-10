/*!
\file       smss_cluster.h
\brief     Defination for the runing time of the this moudle 

 ----history----
\author     Liuzp
\date       2014-02-25
\version    0.01
\desc       create

*/

#if !defined(__smss_cluster_h__)
#define __smss_cluster_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#include "smss_type.h"
#include "smss_io.h"

/* The segment id per cluster start from 0, 
  * the max space for store it is 32 bits.
  * the last number reserved for special use.
*/
#define smss__invalid_seg_id    (0xffffffff)
#define smss__max_seg_id        (smss__invalid_seg_id - 1)
#define smss__max_seg_num       (smss__max_seg_id + 1)

#define smss_writer_magic   *((ulong*)"writer  ")
#define smss_reader_magic   *((ulong*)"reader  ")

typedef struct smss__user{
    char    magic[sizeof(ulong)];  /*!> Read only outside smss */
    struct{    
        struct smss__user* prev, *next;  
    }in_wc;
}_smss__user;

#define smss__user_format_s  "%p{magic:%4.4s, prev[%p], next[%p]}"
#define smss__user_format(_user) (_user),\
                                 (_user)?(_user)->magic:0,\
                                 (_user)? (_user)->in_wc.prev : 0,\
                                 (_user)?(_user)->in_wc.next : 0

typedef struct smss__cluster
{
    struct{    
        struct smss__cluster* prev, *next;  
    }in_dev;

    struct{
        ulong                   counts;
        struct smss__user     *list;
        ulong                   writers, readers;
   }workers;

    /*!< All the new write segment should inherit this segment_NO.
    */
    uchar     segment_NO;   
    uchar     resv[2];
    uchar     waiting_flush;   /*!< whether the dsc need to sync to storage */
    struct smss_cluster_info    dsc;
    
    /* Writing cache */
    struct {
        ulong cnt;
        ulong start_id;
        struct smss_seg_info* head;
    }seg_index_cache_w;

}_smss__cluster;  

#define smss__cluster_format_s "%p{in_dev{prev[%p], next[%p]},workers{counts[%lu], list[%p], writers[%lu], readers[%lu]}, segment_NO[%lu],waiting_flush[%lu],"\
                                "dsc{"smss_cluster_info_format_s"}, seg_index_cache_w{cnt[%lu], start_id[%lu],"\
                                "head[%p]}}"
#define smss__cluster_format_(_cluster) (_cluster),\
                                        (_cluster)? (_cluster)->in_dev.prev : 0,\
                                        (_cluster)? (_cluster)->in_dev.next : 0,\
                                        (_cluster)? (_cluster)->workers.counts : 0,\
                                        (_cluster)? (_cluster)->workers.list : 0,\
                                        (_cluster)? (_cluster)->workers.writers : 0,\
                                        (_cluster)? (_cluster)->workers.readers : 0,\
                                        (long)((_cluster)? (_cluster)->segment_NO : 0),\
                                        (long)((_cluster)? (_cluster)->waiting_flush : 0),\
                                        smss_cluster_info_format((struct smss_cluster_info*)((_cluster)? &((_cluster)->dsc) : 0)),\
                                        (_cluster)? (_cluster)->seg_index_cache_w.cnt : 0,\
                                        (_cluster)? (_cluster)->seg_index_cache_w.start_id : 0,\
                                        (_cluster)? (_cluster)->seg_index_cache_w.head : 0
//struct smss__cluster;
//struct smss__cluster_reader;
typedef struct smss__cluster_writer{
    struct smss__user         hdl;
    struct smss__cluster*  pwc;
    
    struct smss_seg_info     curr_seg_w; 
  //  struct smss__cluster_reader* reader;  /*!< A write is allowed to contain one reader */
}_smss__cluster_writer;

#define smss__cluster_writer_format_s  "%p{hdl:"smss__user_format_s", pwc{"smss__cluster_format_s"}, curr_seg_w["smss_seg_info_format_s"]}"
#define smss__cluster_writer_format(_writer) (_writer),\
                                             smss__user_format((struct smss__user*)((_writer)? &((_writer)->hdl) : 0)),\
                                             smss__cluster_format_((struct smss__cluster*)((_writer)? (_writer)->pwc : 0)),\
                                             smss_seg_info_format((struct smss_seg_info*)((_writer)? &((_writer)->curr_seg_w) : 0))

typedef struct smss__cluster_reader{
    struct smss__user         hdl;
    struct smss__cluster*  pwc;

    ulong   remain_data;            /*!< The remaining data that hasn't been read */
    ulong   curr_offset;            /*!< The offset of the reading cousor */
    ulong    seg_id;                /*!< The current reading sid */
    struct smss_seg_info  seg_info; /*!< The current seg-info */
    
    struct smss__cache*    pcache;
}_smss__cluster_reader;

#define smss__cluster_reader_format_s "%p{hdl["smss__user_format_s"], pwc["smss__cluster_format_s"], remain_data[%lu],"\
                                      "curr_offset[%lu], seg_id[%lu], seg_info["smss_seg_info_format_s"], pcache["smss__cache_format_s"]}"
#define smss__cluster_reader_format(_reader) (_reader),\
                                             smss__user_format((struct smss__user*)((_reader)? &((_reader)->hdl) : 0)),\
                                             smss__cluster_format_((struct smss__cluster*)((_reader)? (_reader)->pwc : 0)),\
                                             (_reader)? (_reader)->remain_data : 0,\
                                             (_reader)? (_reader)->curr_offset : 0,\
                                             (_reader)? (_reader)->seg_id : 0,\
                                             smss_seg_info_format((struct smss_seg_info*)((_reader)? &((_reader)->seg_info) : 0)),\
                                             smss__cache_format((struct smss__cache*)((_reader)? (_reader)->pcache : 0))

/* return smss_err_ok to go on handle the next cluster */
typedef void (*_smss_cluster_id_handle)(
    struct smss__stor_dev* pstor_dev, 
    ulong id, 
    void* pdata
    );
long smss__cluster_open(
    struct smss__stor_dev* pstor_dev,
    ulong phy_id,
    struct smss__cluster* pwc
    );
long smss__cluster_all_visit(
    struct smss__stor_dev* pstor_dev,
    smss_cluster_handle phdl, 
    void* phandler_data
    );
long smss__cluster_list_iterate(
    struct smss__stor_dev* pstor_dev,
    smss_cluster_handle handler,
    void* data /* app data for <cluster_handler> */
    );
long smss__cluster_area_format(
    struct smss__stor_dev* pstor_dev, 
    uchar erase_data
    );
long smss__cluster_alloc(
    struct smss__stor_dev* pstor_dev,
    struct smss__cluster* pwc,
    struct smss_cluster_owner* powner
    );
long smss__cluster_info_get(
    struct smss__stor_dev * pstor_dev,
    struct smss__cluster * pwc, 
    struct smss_cluster_info* pinfo
    );
long smss__cluster_list(
    struct smss__stor_dev* pstor_dev, 
    struct smss_cluster_info cluster_desc[], 
    ulong start_cluster, 
    ulong sz,
    ulong* pnum
    );
long smss__cluster_erase(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster*  pwc
    );
long smss__cluster_flush(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster* pwc
    );
long smss__seg_write(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster_writer* pwriter, 
    struct smss_seg_desc* pdesc, 
    char* pdata
    );
long smss__cluster_workers_clear(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster*  pwc
    );
struct smss__cluster_reader* smss__reader_open(
    struct smss__stor_dev* pstor_dev,
    struct smss__cluster* pwc
    );
struct smss__cluster_writer* smss__writer_open(
    struct smss__stor_dev* pstor_dev,
    struct smss__cluster* pwc
    );
long smss__cluster_free(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster*  pwc
    );
long smss__writer_close(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster_writer* pwriter
    );
long smss__reader_close(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster_reader* preader
    );
long smss__seg_list(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster_reader* pwc, 
    ulong  start_id,
    smss_segment_merger merge,    
    ulong  sz, 
    struct smss_seg_info pseg_info[], 
    ulong* pnum
    );
long smss__seg_direct_read(
    struct smss__stor_dev* dev,
    struct smss__cluster_reader* preader, 
    ulong  sid, 
    ulong buf_sz, 
    char* pdata_buf, 
    ulong* pdata_len
    );
long smss__seg_data_get(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster_reader* preader, 
    ulong buf_sz, 
    char* pdata_buf,
    ulong* pdata_len
    );
long smss__seg_info_locate(
    struct smss__stor_dev* pstro_dev, 
    struct smss__cluster_reader* preader, 
    ulong sid,     /* The segment id */
    struct smss_seg_info* pseg_info
    );
long smss__seg_direct_delete(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster_reader* preader, 
    ulong sid);
long smss__seg_delete (
    struct smss__stor_dev* dev, 
    struct smss__cluster_reader* preader, 
    smss_segment_selector filter, 
    void* filter_data);
long smss__seg_delete_by_time (
    struct smss__stor_dev* dev, 
    struct smss__cluster_reader* preader, 
    uint64_t start_time,
    uint64_t end_time);
long smss__seg_info_seek(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster_reader* preader, 
    smss_segment_selector filter, 
    void* filter_data,
    struct smss_seg_info* pseg_info
    );
long smss__seg_info_next(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster_reader* preader, 
    smss_segment_selector filter, 
    void* filter_data,
    struct smss_seg_info* pseg_info
    );
long smss__cluster_close(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster*  pwc
    );

bool smss__cluster_is_free(
    struct smss__stor_dev* pstor_dev,
    struct smss__cluster* pwc
    );

long smss__boot_info_read(
    struct smss__stor_dev* pstor_dev
    , struct smss__stor_meta* pstor_meta
    );
long smss__cluster_wp_close(
    struct smss__stor_dev* pstor_dev, 
    struct smss__cluster_writer* pwriter
    );

#if defined(__cplusplus)
    }
#endif/* defined(__cplusplus) */

#endif  /*!> __smss_cluster_h__*/


