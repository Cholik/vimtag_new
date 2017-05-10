/*!
\file       smss_module.h
\brief     Defination for the runing time of the this moudle 

 ----history----
\author     Liuzp
\date       2014-02-25
\version    0.01
\desc       create

*/

#if !defined(__smss_module_h__)
#define __smss_module_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(mcore_inner)
#   include "mcore/mcore.h"
#else
#   include "mcrc.h"
#   include "macro_list.h"
#   include "mbytes.h"
#endif
#include "smss_cfg.h"
#include "smss_type.h"
#include "smss_stor.h"

#define smss_dev_magic       *((ulong*)"smssdev.")
#define smss_cluster_magic   *((ulong*)"smssclus")

#define smss__tlv_crc32(data)\
    mcrc_32(mcrc_32(0, (unsigned char*)data, 8), ((unsigned char*)(data)) + 12, sizeof(*(data)) - 12)
      
#define smss__crc32(data)\
    mcrc_32(0, ((unsigned char*)(data)) + 4, sizeof(*(data)) - 4)
      

#define set_magic(m, v)       *((ulong*)(m)) = (v) 
#define compare_magic(m1, m2) (*((ulong*)(m1)) == (m2))

#define aligh(v, a) (((uint32_t)(v) + ((a) - 1)) & ~((a) - 1))  
#define align_sector(v)  aligh(v, stor_sector_sz)

#ifndef max
#define max(a, b)  ((a)>(b)?(a):(b))  
#endif

#ifndef min
#define min(a, b)  ((a)<(b)?(a):(b)) 
#endif
    
#define smss_u16_read(_buf)          mbytes_read_int_big_endian_2b(_buf)
#define smss_u32_read(_buf)          mbytes_read_int_big_endian_4b(_buf)
#define smss_u48_read(_buf)          mbytes_read_int_big_endian_6b(_buf)
#define smss_u64_read(_buf)          mbytes_read_int_big_endian_8b(_buf)
#define smss_u16_write(_buf, _val)   mbytes_write_int_big_endian_2b(_buf, _val)
#define smss_u32_write(_buf, _val)   mbytes_write_int_big_endian_4b(_buf, _val)
#define smss_u48_write(_buf, _val)   mbytes_write_int_big_endian_6b(_buf, _val)
#define smss_u64_write(_buf, _val)   mbytes_write_int_big_endian_8b(_buf, _val)
    
/* stor bits order in/out macro tool */
typedef struct smss__stor_dev{
    struct smss_dev             dev_hdl;
    struct smss_dev_ctrl        ctrl;

    long                        err_code;  /* !< The error code of the last oper */
  //  ullong                      next_cluster_logic_id;  /*!< The max cluster logic id */
    struct smss_stor_info       stor_info;

    struct smss__cache* pcluster_index_cache;

    struct{
        ulong                         counts;
        struct smss__cluster     *list;
   }clusters;
    
}_smss_stor_dev;

#define smss__stor_dev_format_s "%p{dev_hdl["smss_dev_format_s"], ctrl["smss_dev_ctrl_format_s"], err_code[%ld],"\
                                "stor_info["smss_stor_info_format_s"], clusters{counts[%lu], list[%p]}}"
#define smss__stor_dev_format(_stor_dev) (_stor_dev),\
                                         smss_dev_format((struct smss_dev*)((_stor_dev)? &((_stor_dev)->dev_hdl) : 0)),\
                                         smss_dev_ctrl_format((struct smss_dev_ctrl*)((_stor_dev)? &((_stor_dev)->ctrl) : 0)),\
                                         (_stor_dev)? (_stor_dev)->err_code : 0,\
                                         smss_stor_info_format((struct smss_stor_info*)((_stor_dev)? &((_stor_dev)->stor_info) : 0)),\
                                         (_stor_dev)? (_stor_dev)->clusters.counts : 0,\
                                         (_stor_dev)? (_stor_dev)->clusters.list : 0

#define smss__malloc(dev, sz)         (dev)->ctrl.dev_malloc(&(dev)->ctrl, sz) 
#define smss__free(dev, ptr)          (dev)->ctrl.dev_free(&(dev)->ctrl, ptr)

#define smss__cluster_sz(dev)         ((dev)->stor_info.cluster_size)
#define smss__cluster_num(dev)        ((dev)->stor_info.total_cluster_num)
#define smss__free_cluster_num(dev)   ((dev)->stor_info.free_cluster_num)
#define smss__stor_size(dev)          ((dev)->stor_info.total_stor_size)
#define smss__sector_sz(dev)          ((dev)->stor_info.sector_size)  
#define smss__seg_cache_num(dev)      ((dev)->ctrl.seg_cache_num)
#define smss__seg_buff_num(dev)       ((dev)->ctrl.seg_buff_num)
#define smss__cluster_index_buff_num(dev)       ((dev)->ctrl.cluster_index_cache_num)
#define smss_stor_state(dev)          ((dev)->stor_info.state)
//#define smss__reader_max(dev)         (100)
#define smss__stor_full(dev)          (0 == smss__free_cluster_num(dev))
#define smss__cluster_id_valid(pstor_dev, cid)\
    ((cid < smss__cluster_num(pstor_dev)) && (cid >= smss_cluster_head_resv))
                                     
#if defined(__cplusplus)
    }
#endif/* defined(__cplusplus) */

#endif  /*!> __smss_module_h__*/


