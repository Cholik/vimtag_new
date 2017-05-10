/*!
\file       smss_type.h
\brief     

 ----history----
\author     Liuzp
\date       2014-02-25
\version    0.01
\desc       create

*/

#if !defined(__smss_type_h__)
#define __smss_type_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(mcore_inner)
#   include "mcore/mcore.h"
#else
#   define mtime2s(x) "999"
#   define time2s(x)  ""
#   include "print_utils.h"
#endif

#if !defined(__APPLE__)
typedef unsigned long bool;
#endif
typedef unsigned int  uint;

#if !defined(__ulong_defined)
#define __ulong_defined
typedef unsigned long                   ulong;
#endif

#if !defined(__uchar_defined)
#define __uchar_defined
typedef unsigned char uchar;
#endif

#if !defined(__ushort_defined)
#define __ushort_defined
typedef unsigned short ushort;
#endif

typedef unsigned long long ullong;

typedef unsigned long pos_t;

typedef ullong smss_ch_id_t;

typedef ullong smss_time_t;

typedef struct smss_time2_t
{
    ullong start_time;
    ullong end_time;
} _smss_time2_t;

typedef enum smss_stor_state{
    smss_stor_normal,           /*!> normal */
    smss_stor_unknown,           /*!> need format */
}_smss_stor_state;

typedef enum smss_format_type{
    smss_format_fast,
    smss_format_slow    
}_smss_format_type;

typedef enum smss_seg_trigger{
    smss_seg_trigger_normal = 1 << 0,      /* Normal recording */
    smss_seg_trigger_alarm = 1 << 1,    /* Alarm triggered recording */
    smss_seg_trigger_timing = 1 << 2, /* recording of preseted timing */
}_smss_seg_trigger;

//#define  smss_seg_type_video   *((ulong*)("vide"))
//#define  smss_seg_type_jpeg    *((ulong*)("jpeg"))

/* err codes
*/
#define MK_ERR(n)                          (-n)      
#define smss_err_ok                        MK_ERR(0)
#define smss_err_fail                      MK_ERR(1)
#define smss_err_malloc_fail               MK_ERR(2)
#define smss_err_seek_fail                 MK_ERR(3)
#define smss_err_write_fail                MK_ERR(4)
#define smss_err_read_fail                 MK_ERR(5)
#define smss_err_illegal_oper              MK_ERR(6)
#define smss_err_invalid_fs                MK_ERR(7)
#define smss_err_invalid_stor_info         MK_ERR(8)
#define smss_err_invalid_fs_type           MK_ERR(9)
#define smss_err_invalid_seq_no            MK_ERR(10)
#define smss_err_invalid_cluster_size      MK_ERR(11)
#define smss_err_invalid_partion_info      MK_ERR(12)
#define smss_err_invalid_pointer           MK_ERR(13) 
#define smss_err_invalid_dev               MK_ERR(14)  
#define smss_err_invalid_format_param      MK_ERR(15)  
#define smss_err_exceed_end                MK_ERR(16)  
#define smss_err_invalid_cluster_meta      MK_ERR(17)  
#define smss_err_cluster_id_mismatch       MK_ERR(18)  
#define smss_err_stor_full                 MK_ERR(19)  
#define smss_err_invalid_obj               MK_ERR(20)
#define smss_err_cluster_full              MK_ERR(21)
#define smss_err_cluster_seg_mismatch      MK_ERR(22)
#define smss_err_cluster_owner_mismatch    MK_ERR(23) 
#define smss_err_found_no_segment          MK_ERR(24)
#define smss_err_invalid_read_param        MK_ERR(25)
#define smss_err_create_cache_fail         MK_ERR(26)
#define smss_err_free_fail                 MK_ERR(27)
#define smss_err_no_seg_seeked             MK_ERR(28) 
#define smss_err_cluster_is_idle           MK_ERR(29) 
#define smss_err_cluster_phy_exception     MK_ERR(30) 
#define smss_err_cluster_locked            MK_ERR(31) 
#define smss_err_cluster_busy              MK_ERR(32) 
#define smss_err_seg_index_broken          MK_ERR(33)
#define smss_err_seg_meta_broken           MK_ERR(34)
#define smss_err_seg_not_in_cached         MK_ERR(35)
#define smss_err_seg_no_cache              MK_ERR(36)
#define smss_err_invalid_seg_id            MK_ERR(37)
#define smss_err_too_many_writers          MK_ERR(38)
#define smss_err_invalid_cluster_handle    MK_ERR(39)
#define smss_err_not_allow_write           MK_ERR(40)
#define smss_err_not_allow_read            MK_ERR(41)
#define smss_err_invalid_opt               MK_ERR(42)
#define smss_err_invalid_cluster_id        MK_ERR(43)
#define smss_err_invalid_ch                MK_ERR(44)
#define smss_err_type_illegal              MK_ERR(45)
#define smss_err_unknow_dev_state          MK_ERR(46)
#define smss_err_invalid_seg_info          MK_ERR(47)
#define smss_err_lack_seg_flag             MK_ERR(48)
#define smss_err_mem_leaked                MK_ERR(49)
#define smss_err_conflict_seg_flag_type    MK_ERR(50)
#define smss_err_cluster_is_resved            MK_ERR(51)
#define smss_err_cluster_head_broken      MK_ERR(52)
#define smss_err_cluster_not_boot_cluster   MK_ERR(53)
#define smss_err_cluster_meta_broken          MK_ERR(54)
#define smss_err_try_format_busy_dev          MK_ERR(55)

/*Be noted: modify this value after change the err code */
#define smss_err_max smss_err_try_format_busy_dev
 
#ifndef NULL
#define NULL   ((void*)0)
#endif

#define smss_stor_least_cluster_num 3

typedef void* smss_handle;

struct smss_dev_ctrl;
typedef ullong (*smss_dev_size)(struct smss_dev_ctrl *ctrl); /* Get the total size of the fd */
typedef long (*smss_dev_write)(struct smss_dev_ctrl *ctrl, ullong pos,ullong size, char *data);
typedef ulong (*smss_dev_read)(struct smss_dev_ctrl *ctrl, ullong pos, ullong size, char *data);
typedef void* (*smss_dev_malloc)(struct smss_dev_ctrl*ctrl, ulong size);
typedef long (*smss_dev_free)(struct smss_dev_ctrl*ctrl, void* ptr);
typedef struct smss_dev_ctrl
{
    void*    usr_obj;
    ulong   seg_cache_num;     /*!< The cached segment head per cluster */
    ulong   seg_buff_num;    
    ulong  cluster_index_cache_num; /* !< buffer len for cache cluster-info, each cluster-info occupy 512 bytes */
    smss_dev_write dev_write;
    smss_dev_read  dev_read;
    smss_dev_malloc dev_malloc;
    smss_dev_free dev_free;
}_smss_dev_ctrl;

#define smss_dev_ctrl_format_s  "%p{seg_cache_num[%lu], dev_write[%p], dev_read[%p],dev_malloc[%p],dev_free[%p]}"
#define smss_dev_ctrl_format(_ctrl) (_ctrl),\
                                    (_ctrl)?(_ctrl)->seg_cache_num:0,\
                                    (_ctrl)?(_ctrl)->dev_write:0,\
                                    (_ctrl)?(_ctrl)->dev_read:0,\
                                    (_ctrl)?(_ctrl)->dev_malloc:0,\
                                    (_ctrl)?(_ctrl)->dev_free:0

typedef struct smss_dev
{
    char    magic[sizeof(long)]; 
}_smss_dev;

#define smss_dev_format_s  "%p{magic[%4.4s]}"
#define smss_dev_format(_dev) (_dev), (_dev)?(_dev)->magic:0

typedef struct smss_format_param
{
   ulong  sector_size;
   // cluster size
   ulong  cluster_size;
   
   ullong total_size;
   // format type
   enum smss_format_type type;
}_smss_format_param;

#define smss_format_param_format_s  "%p{sector_size[%lu],cluster_size[%lu],total_size["u64_format_s"],type[%d]}"
#define smss_format_param_format(_param) (_param),\
                                         (_param)?(_param)->sector_size:0,\
                                         (_param)?(_param)->cluster_size:0,\
                                         (ullong)((_param)?(_param)->total_size:0),\
                                         (_param)?(_param)->type:0

typedef struct smss_stor_info{
    enum smss_stor_state state;

    /* Store info */
    ulong  sector_size;
    ulong  cluster_size;        
    ulong  total_cluster_num;   
    ulong  free_cluster_num; 
    ulong  exception_cluster_num; 
    ullong total_stor_size; 
    ullong total_data_size;  /*!< Only data, not include the additional info */
    ullong last_update_time;    
}_smss_stor_info;

#define smss_stor_info_format_s "%p{state[%ld], sector_size[%lu], cluster_size[%lu], total_cluster_num[%lu],"\
                                "free_cluster_num[%lu], exception_cluster_num[%lu],total_stor_size["u64_format_s"], total_data_size["u64_format_s"],"\
                                "last_update_time["u64_format_s"]}"
#define smss_stor_info_format(_stor_info) (_stor_info),(long)((_stor_info)?(_stor_info)->state : 0),\
                                   (ulong)((_stor_info)?(_stor_info)->sector_size : 0), (ulong)((_stor_info)?(_stor_info)->cluster_size : 0),\
                                   (ulong)((_stor_info)?(_stor_info)->total_cluster_num : 0), (ulong)((_stor_info)?(_stor_info)->free_cluster_num : 0),\
                                   (ulong)((_stor_info)?(_stor_info)->exception_cluster_num : 0),\
                                   (ullong)((_stor_info)?(_stor_info)->total_stor_size : 0), (ullong)((_stor_info)?(_stor_info)->total_data_size : 0),\
                                   (ullong)((_stor_info)?(_stor_info)->last_update_time : 0)

#define smss_refer_len_max  (12 + 4)   
typedef struct smss_seg_refer{
  //  ushort data_len;  /*!< ext: Max 512 - sizeof(struct smss__seg_meta); */
    uchar  pdata[smss_refer_len_max];     
}_smss_seg_refer;
#define smss_seg_refer_format_s  "%p{pdata[%p]}"
#define smss_seg_refer_format(refer)  (refer), (refer)? (refer)->pdata : ((uchar*)0)

typedef struct smss_seg_desc{
    ulong  data_len;
    ullong start_time;
    ullong end_time; 
    uchar  flag;       /*!< smss_seg_flag_XXX */

    uchar  data_type;  /*!< segment data type */
    uchar  trigger;    /*!< The event that triggered this segment,<enum smss_seg_trigger> */
    uchar  resv;
    uchar  refer[smss_refer_len_max];  /*!< User data */
}_smss_seg_desc;
#define smss_seg_flag_start 1        /*!< A new segment start */
#define smss_seg_flag_end   (1 << 1) /*!< The current segment complete */
#define smss_seg_falg_complete   (smss_seg_flag_start | smss_seg_flag_end)

#define smss_seg_desc_format_s "%p{data_len[%lu], start_time["u64_format_s"], end_time["u64_format_s"],flag[0x%x],"\
                               " data_type[%d], trigger[%d],resv[%c], refer["smss_seg_refer_format_s"]}"
#define smss_seg_desc_format(_seg_desc) (_seg_desc),\
                                        (_seg_desc)?(_seg_desc)->data_len   :0,\
                                        (_seg_desc)?(_seg_desc)->start_time :0,\
                                        (_seg_desc)?(_seg_desc)->end_time   :0,\
                                        (_seg_desc)?(_seg_desc)->flag       :0,\
                                        (_seg_desc)?(_seg_desc)->data_type  :0,\
                                        (_seg_desc)?(_seg_desc)->trigger    :0,\
                                        (_seg_desc)?(_seg_desc)->resv       :0,\
                                         smss_seg_refer_format((struct smss_seg_refer*)((_seg_desc)? (_seg_desc)->refer : 0))
                                         
typedef struct smss_seg_info{
    uchar  flags;       /*!< lock, book mark, delete ...... */
    uchar  data_type;   /*!< The data type of the current segment */
    uchar  trigger;     /*!< The event that triggered this segment */
    uchar  resv;
    ulong  data_len;    /*!< The data len */
    pos_t  pos;         /*!< offset in the cluster */
    ullong start_time;
    ullong end_time; 
    uchar  refer[smss_refer_len_max]; /*!< User data */
    long   seg_id;
}_smss_seg_info;

#define smss_seg_info_format_s "%p{flags[0x%x], data_type[0x%x], trigger[0x%x], resv[%d], data_len[%lu],"\
                               " pos[%lu], start_time["u64_format_s"], end_time["u64_format_s"], refer["smss_seg_refer_format_s"]}"
                               
#define smss_seg_info_format(_seg_info) (_seg_info),\
                                        (_seg_info)? (_seg_info)->flags : 0,\
                                        (_seg_info)? (_seg_info)->data_type : 0,\
                                        (_seg_info)? (_seg_info)->trigger : 0,\
                                        (_seg_info)? (_seg_info)->resv : 0,\
                                        (_seg_info)? (_seg_info)->data_len : 0,\
                                        (ulong)((_seg_info)? (_seg_info)->pos : 0),\
                                        (_seg_info)? (_seg_info)->start_time : 0,\
                                        (_seg_info)? (_seg_info)->end_time : 0,\
                                        smss_seg_refer_format((struct smss_seg_refer*)((_seg_info)? (_seg_info)->refer : 0))

#define smss_cluster_owner_id_len 12
typedef struct smss_cluster_owner{
    uchar id[smss_cluster_owner_id_len];
}_smss_cluster_owner;

#define smss_cluster_owner_format_s  "%p{id[%p]}"
#define smss_cluster_owner_format(owner)  (owner), (owner)? (owner)->id : ((uchar*)0)
                                          
#define smss_data_classic_snapshot 1
#define smss_data_classic_record   2 

typedef struct smss_cluster_info{
    struct smss_cluster_owner owner_info;
    uchar    state;
    
    //////////////////////////////////////
    
    uchar    flags;           /*!< locked, bookmarked,......*/
    uchar    write_permit;    /*!< whether this cluster allow to write */
    uchar    resv;

    ulong    phy_id;
    ulong    free_sz;
    ulong    free_data_sz;   /*!< free space could use for stor data, Don't use it internal !!!! */
    ullong   first_seg_time;
    ullong   last_seg_time;  /*!< The end time of the last segment */    
    ulong    seg_cnt;        /*!< The segment count in this cluster */
    ulong    data_size;      /*!< The total data-size in this cluster */
}_smss_cluster_info;

#define smss_cluster_info_format_s "%p{owner_info["smss_cluster_owner_format_s"], state[%d], flags[0x%x], write_permit[%d], resv[%d], phy_id[%lu], free_sz[%lu],"\
                                   "first_seg_time["u64_format_s"], last_seg_time["u64_format_s"], seg_cnt[%lu], data_size[%lu]}"

#define smss_cluster_info_format(_clus_info) (_clus_info),\
                                            smss_cluster_owner_format((struct smss_cluster_owner*)((_clus_info)? &((_clus_info)->owner_info) : 0)),\
                                            (_clus_info)? (_clus_info)->state:0,\
                                            (_clus_info)? (_clus_info)->flags:0,\
                                            (_clus_info)? (_clus_info)->write_permit:0,\
                                            (_clus_info)? (_clus_info)->resv:0,\
                                            (_clus_info)? (_clus_info)->phy_id:0,\
                                            (_clus_info)? (_clus_info)->free_sz:0,\
                                            (_clus_info)? (_clus_info)->first_seg_time:0,\
                                            (_clus_info)? (_clus_info)->last_seg_time:0,\
                                            (_clus_info)? (_clus_info)->seg_cnt:0,\
                                            (_clus_info)? (_clus_info)->data_size:0

typedef long (*smss_cluster_handle)(
    void* data, 
    struct smss_cluster_info* pinfo
    );
typedef bool (*smss_segment_selector)(
    void* filter_data, 
    struct smss_seg_info* pseg_info
    );

/*
  function: smss_segment_merger
  \brief:  merge <seg2> and <seg1> info  <seg1>.
             return !0 if merged.
             return 0  if not mergerd.
 */
typedef long (*smss_segment_merger)(
    struct smss_seg_info* seg1, 
    struct smss_seg_info* seg2,
    struct smss_seg_info* pout
    );


#if defined(__cplusplus)
    }
#endif/* defined(__cplusplus) */

#endif /* !defined(__smss_type_h__) */


