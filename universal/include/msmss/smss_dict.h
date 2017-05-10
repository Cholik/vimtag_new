/*!
\file       smss_stor.h
\brief     

 ----history----
\author     Liuzp
\date       2015-06-03
\version    0.01
\desc       create

*/

#if !defined(__smss_dict_h__)
#define __smss_dict_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/* Fixed-length type define */
#if !defined(__int8_t_defined) && !defined(_INT8_T)
#   define __int8_t_defined
    typedef char                        int8_t;
    typedef short int                   int16_t;
    typedef int                         int32_t;
#   if defined(_MSC_VER)
        typedef __int64                 int64_t;
#   else 
        typedef long long int           int64_t;
#   endif
#endif
#if !defined(__uint32_t_defined)
#   define __uint32_t_defined
    typedef unsigned char               uint8_t;
    typedef unsigned short int          uint16_t;
    typedef unsigned int                uint32_t;
#   if defined(_MSC_VER)
        typedef unsigned __int64        uint64_t;
#   else 
        typedef unsigned long long int  uint64_t;
#   endif
#   endif

#if !defined(__ulong_defined)
#define __ulong_defined
typedef unsigned long                   ulong;
#endif

#define SMSS_MAGIC_LEN sizeof(uint32_t)

#define smss_stor_info_pos 0
#define smss_stor_info_copy_num 2    /*!> two copy */
#define smss_current            -1

#define smss_owner_id_system            ((uint64_t)(0xffffffffffffffff))
#define smss_ch_id_nobody               ((uint64_t)(0xfffffffffffffffe))
#define smss_ch_id_max                  (smss_ch_id_nobody - 1)    

#define smss__valid_ch_id(ch) ((ch) < smss_ch_id_nobody)

#define smss_format_symbol   0xFF

#define seg_data_tail          0xFFFFFFFF
#define seg_data_tail_sz    4

#define smss_seg_NO_invlid     255
#define smss_seg_NO_unsure  254
#define smss_seg_NO_max       254

/* General cluster id */
#define smss_cluster_head_resv  2  /*!> Reserved cluster at the head of the stor */
#define smss_cluster_end_resv   0  /*!> Reserved cluster at the end of the stor */

typedef enum smss_data_attr{
    smss_data_normal = 1 << 0,      // read-able and write-able 
    smss_data_locked = 1 << 1,      // read only    
    smss_data_bm = 1<< 2,           // book marked
    smss_data_damaged = 1 << 3,     // phycial damaged
    smss_data_deleted = 1 << 4,     // for quicker delete
    smss_data_attr_butt
}_smss_data_attr;

#define smss_data_dirty      1
#define smss_data_consistent 0

#define smss_cluster_write_open 1
#define smss_cluster_write_close 0

#define smss_stor_type          *((uint32_t*)("stor"))
#define smss_cluster_type_data       *((uint32_t*)("clus"))
#define smss_cluster_type_boot        *((uint32_t*)("boot"))
#define smss_cluster_meta_type       *((uint32_t*)("clme"))
#define smss_cluster_info_type        *((uint32_t*)("cinf"))
#define smss_seg_type_idle      *((uint32_t*)("idle"))
#define smss_stat_type          *((uint32_t*)("stat"))  
#define smss_seg_meta_type      *((uint32_t*)("segm")) 

#define smss__resv_seg_type smss_seg_type_idle
#define smss__valid_type(t) (smss_seg_type_idle != t)

#define smss__cluster_state_busy   'b'
#define smss__cluster_state_free   'f'
#define smss__cluster_state_unkown 'u' 

#define smss__stormeta_proto_ver  (1)
#define smss__cluster_proto_ver  (1)
#define smss__segmeta_proto_ver (1)

#define stor_sector_sz   512
#define smss__seg_meta_space(dev)    smss__sector_sz(dev)
#define smss__cluster_head_len(dev)   (smss__sector_sz(dev) * 2)     /* head + meta + stat */
#define smss__cluster_index_space(dev)   smss__sector_sz(dev)
#define smss__stor_meta_offset() 

/*------------Segement ---------------*/
typedef struct smss__tlv{
    uint8_t    type[4];    //
    uint8_t    len[4];     /*!< Include self */
    uint8_t    check_sum[4];                          
    uint8_t    data[0];    /*!< Data start */
}_smss__tlv;

typedef struct smss__cluster_head{
    uint8_t    type[4];      /*!< smss_cluster_type  */
    uint8_t    len[4];       /*!< Cluster total len */
    uint8_t    check_sum[4];                          
    uint8_t    data[0];      /*!< Data or other tlv start */
}_smss__cluster_head; 

typedef struct smss__seg_meta{
    uint8_t    type[4];         /*!< smss_seg_type_XXX*/
    uint8_t    len[4];          /*!< Include self and following data */
    uint8_t    check_sum[4];     

    uint8_t    version;        /*!< The version of current cluster storage protocol */    
    uint8_t    flags;            /*!< lock, book mark, delete ...... */
    uint8_t    data_type;        /*!< Data type */
    uint8_t    trigger;          /*!< The event that triggered this segment */
    uint8_t    data_offset[4];   /*!< From this head */
    uint8_t    data_len[4];      /*!< Real data length */
    uint8_t     segment_NO; /*!< Inherit from cluster */
    uint8_t    resv;
    uint8_t    start_time[6];    /*!< First time */        
    uint8_t    time_len[4];      /*!< last time */ 
    
    uint8_t    owner_info[12];   /*!< The cluster owner info, Redandancy with cluster-meta */
    uint8_t    refer[smss_refer_len_max];
}_smss__seg_meta;

typedef struct smss__seg_index{
    uint8_t    check_sum[4];
    
    uint8_t    offset[4];        /*!< Base the cluster head. */
    uint8_t    data_len[4];      /*!< Real data length */
    uint8_t    flags;            /*!< lock, book mark, deleted ...... */
    uint8_t    data_type;        /*!< data type */
    uint8_t    trigger;          /*!< The event that triggered this segment */
    uint8_t    segment_NO; /*!< Inherit from cluster */
    uint8_t    time_len[4]; 
    uint8_t    start_time[6]; 
    uint8_t    resv1[2];
    uint8_t    refer[smss_refer_len_max];
}_smss__seg_index;

typedef struct smss__cluster_meta{
    /* Fixed base info */
    uint8_t    type[4];        /*!< smss_cluster_meta_type */
    uint8_t    len[4];         /*!< One sector */
    uint8_t    check_sum[4];
    
    /* Occupation info */
    uint8_t    version;        /*!< The version of current cluster storage protocol */
    uint8_t    state;          /*!< whether occupied by any owner or free */ 
    uint8_t    segment_NO;
    uint8_t    resv;
    uint8_t    owner_info[12]; /*!< The cluster owner info */
}_smss_cluster_meta;

/* ----------- Cluster -----------------*/
typedef struct smss__cluster_stat{
    uint8_t    type[4];      /*!< smss_stat_type */
    uint8_t    len[4];       /*!< One sector */
    uint8_t    check_sum[4];  

    /* management info */
    uint8_t    flags;        /*!< lock/book mark/delete*/           

    /* Running info */
    /*!< write_open/write_close, ,
         * If there is not enough space for the current seg, set to write_close.
         * once write_close it can only be re-write after free/erase.
         ****************************************************
         * MKAE SURE:
         * Before stor write-close into storage, must make sure all the data and 
         * seg-index are stored first.
         */ 
    uint8_t    write_permit;  
    uint8_t    segment_NO;
    uint8_t    resv;
    uint8_t    free_sz[4];
    uint8_t    first_seg_time[6];
    uint8_t    last_seg_time[6];     
    uint8_t    seg_cnt[4];       
    uint8_t    data_size[4];   /*!< Not include the segment index. */       

}_smss__cluster_stat;

struct smss__cluster_index{
    uint8_t    type[4];        /*!< smss_cluster_meta_type */
    uint8_t    len[4];         /*!< One sector */
    uint8_t    check_sum[4];

    /* Occupation info */
    uint8_t    owner_info[12]; /*!< The cluster owner info */
    uint8_t    state;          /*!< whether occupied by any owner or free */ 
    uint8_t    version;        /*!< The version of current cluster storage protocol */
    uint8_t    segment_NO;

     /*--- stat------ */
    uint8_t    flags;        /*!< lock/book mark/delete*/           
    uint8_t    write_permit;  
    uint8_t    resv[3];
    uint8_t    free_sz[4];
    uint8_t    first_seg_time[6];
    uint8_t    last_seg_time[6];     
    uint8_t    seg_cnt[4];       
    uint8_t    data_size[4];   /*!< Not include the segment index. */    
    
}_smss__cluster_info;

/*------------Storage meta information-----------*/
/* Storage filesystem info
*/
typedef struct smss__stor_meta{
    uint8_t    type[4];           /*!< smss_stor_type  */
    uint8_t    len[4];            /*!< One sector */
    uint8_t    check_sum[4];

    uint8_t vsersion;
    uint8_t resv[3];
    uint8_t  sector_size[4];
    uint8_t  cluster_size[4];        
    uint8_t  total_cluster_num[4];   
    uint8_t  total_stor_size[8];  
}_smss_stor_meta;

/* 2 sector are used for head, meta and stat.
*/
#define smss__total_data_space_sz(dev) \
     (smss__cluster_sz(dev) - smss__seg_data_offset(dev))

#define smss__cluster_meta_space(dev)\
    (smss__sector_sz(dev) - sizeof(struct smss__cluster_head))

#define smss__stor_meta_space_sz(dev) smss__sector_sz(dev)

/* Cluater space arrange:
            +------------------------------------------------------+
item:    +tlv | meta |  resv  | stat |  resv | data1 data 2   ... ...  indexn...index1  |           
size:     +------512-----|----512---|  ...    ...                                            |
            +------------------------------------------------------+ 
*/
#define smss__locate_cluster(dev, cid) (((ullong)(cid)) * smss__cluster_sz(dev))

#define smss__locate_cluster_head(dev, cid) smss__locate_cluster(dev, cid)

#define smss__locate_cluster_meta(dev, cid) \
    (smss__locate_cluster_head(dev, cid) + sizeof(struct smss__cluster_head))

/* boot cluster 
  +------------+------------+---------+
  |cluster-header  | cluster-meta  | stor-meta |
  +------------+------------+---------+
*/
#define smss__locate_stor_meta(dev, seq) \
    (smss__locate_cluster_head(dev, seq) + smss__sector_sz(dev))

#define smss__locate_cluster_index(dev, seq, cid)\
        (smss__locate_stor_meta(dev, seq) + smss__stor_meta_space_sz(dev) + ((cid -2) * smss__sector_sz(dev)))    
        
#define smss__locacte_cluster_stat(dev, cid)\
    (smss__locate_cluster(dev, cid) + smss__sector_sz(dev))
    
#define smss__seg_data_offset(dev) (2 * smss__sector_sz(dev)) 

#define smss__locate_seg_data_head(dev, cid)\
    (smss__locate_cluster(dev, cid) + smss__seg_data_offset(dev))

#define smss__per_seg_additional_info_sz(dev)\
    (smss__seg_meta_space(dev) + sizeof(struct smss__seg_index))  
    
#define smss__cluster_additional_info_sz(dev, pwc) \
    (smss__per_seg_additional_info_sz(dev) * (pwc)->dsc.seg_cnt)

#define smss__cluster_seg_meta_sz(dev, pwc)\
    (smss__seg_meta_space(dev) * (pwc)->dsc.seg_cnt)
    
#define smss__cluster_seg_index_sz(dev, pwc)\
        (sizeof(struct smss__seg_index) * (pwc)->dsc.seg_cnt)
        
/* The seg_index is added from the tail reversely to the head 
    \brief: cid, the cluster id, start from 0. 
   \ brief: sid, the seq no of the segment head, start from 0. 
*/   
#define smss__locate_seg_index(dev, cid, sid) \
    (smss__locate_cluster(dev, ((cid) + 1)) \
      - (sizeof(struct smss__seg_index) * ((sid) + 1)))

    
#if defined(__cplusplus)
    }
#endif/* defined(__cplusplus) */

#endif  /*!> __smss_stor_h__*/

