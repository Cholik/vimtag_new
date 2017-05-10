/*!
\file       mcard_api.h
\brief      mining mcard util api

----history----
\author     kangdengli
\date       2016-08-04
\version    0.01
\desc       create
*/

#ifndef _MCARD_API_H_
#define _MCARD_API_H_

#ifdef __cplusplus
extern "C" {
#endif 

#include    "msmss/msmss.h"
#include    "msmss/smss_stor.h"
#include    "msmss/smss_dict.h"
#include    "msmss/smss_module.h"

#define MCARD_DEVID_LEN				(7)
#define MCARD_NUM					(8)
#define MCARD_SN_NUM				(8)
#define MCARD_CLS_TYPE_HD			(1)
#define MCARD_CLS_TYPE_MIN			(2)
#define MCARD_PATH_LEN				(16)

#define mcard_cstrlen(_s)								(sizeof(_s) - 1)
#define MCARD_SN_LEN									mcard_cstrlen("1jfiegxxxxxxx")
#define mcard_node_sn_data_get(_mnode, _cnt)			((_mnode) ? (_mnode)->cl_descs.sn[_cnt].data : 0)
#define mcard_ipc_list_get(_mnode)						((_mnode) ? (_mnode)->ipc_head.list : NULL)
#define mcard_smss_get(_list)							((_list)?((&((_list)->smss[MCARD_CLS_TYPE_HD]))):NULL)
#define mcard_hd_cls_counts_get(_smss)					((_smss) ? (_smss)->clusters_counts : 0)		
#define mcard_hd_last_cls_seg_counts_get(_smss)			((_smss) ? (_smss)->clusters[mcard_hd_cls_counts_get(_smss) - 1]->seg_cnt : 0)
#define mcard_1st_node_sn_data_get(_mod, _cnt)			((_mod) ? (_mod)->list->cl_descs.sn[_cnt].data : NULL)
#define mcard_1st_node_smss_get(_mnode)					((_mnode) ? (mcard_smss_get(mcard_ipc_list_get(_mnode))):NULL)
#define mcard_1st_node_cls_counts_get(_smss)			((_smss) ? ((_smss)->clusters_counts) : 0)
#define mcard_1st_node_seg_counts_get(_smss, _cnt)		((_smss) ? ((_smss)->clusters[_cnt]->seg_cnt) : 0)
#define mcard_1st_node_cls_data_size(_smss, _cnt)		((_smss) ? ((_smss)->clusters[_cnt]->data_size) : 0)

#define mcard_node_sn_num_get(_mod, _cnt)				((_mod) ? (mcard_disk_num_get(_mod) ? ((_mod)->sn_cnt[_cnt]) : 0) : 0)
#define mcard_disk_sym_get(_mod, _cnt)					((_mod) ? (mcard_disk_num_get(_mod) ? ((_mod)->disk_sym[_cnt]) : '\0') : '\0')	//Windows
#define mcard_disk_NO_get(_mod, _cnt)					((_mod) ? (mcard_disk_num_get(_mod) ? ((_mod)->disk_NO[_cnt]) : 0) : 0)			//Mac
#define mcard_disk_num_get(_mod)						((_mod) ? ((_mod)->counts): 0)

#pragma pack(push, 1)

typedef enum mcard_video_foramt
{
	h264_format = 0,
	mp4_format
} _mcard_video_foramt;

struct mcard_node_param
{
	int disk_NO;	//mac
	char sn_buf[16];
	char disk_sym;	//windows
};

typedef struct mcard_seg_head
{
	unsigned char type[4];
	unsigned char len[4];
	unsigned char t[6];
	unsigned char flag[2];
	unsigned char head_len;
	unsigned char ver;
	unsigned char rsv[2];
} _mcard_seg_head;

typedef struct mcard_media_sample
{
	struct
	{
		struct mcard_media_sample       *prev;
		struct mcard_media_sample       *next;
	}in_que;
	struct mcmedia_type             *type;
	struct
	{
		unsigned key_sample : 1;
		unsigned video : 1;
		unsigned trig_evt : 8;
		unsigned reserved : 22;
	} flag;
	unsigned long                   t_sec;
	unsigned long                   time_stamp;
	unsigned long long              ab_time;

	long                            chn;
	long                            size;
	unsigned char                   *data;
	long                            alloc_size;
}_mcard_media_sample;

typedef struct mcard_data_desc
{
	ulong		cid_start;
	ulong		cid_end;

	ulong		sid_start;
	ulong		sid_end;

	ulong		tm_min;		//Maximum duration time of each file

	uchar		path[256];	//windows or mac
	uchar		fmt[8];		//"h264" or "mp4"
}_mcard_data_desc;

typedef struct mcard_smss
{
	long						cluster_type;
	long                        clusters_counts;
	ullong						data_sz;

	struct mcard_ipc_list		*owner;
	struct smss_cluster_info    **clusters;
} _mcard_smss;

typedef struct mcard_ipc_list		
{									
	struct mcard_node *owner;

	struct
	{
		struct mcard_ipc_list *next;
		struct mcard_ipc_list *prev;
	} node;

	char sn_buf[MCARD_SN_LEN];

	struct len_str sn;								//sn
	struct mcard_smss smss[MCARD_CLS_TYPE_MIN + 1];	//cluster info
} _mcard_ipc_list;

typedef struct mcard_node
{
	struct
	{
		struct mcard_node *prev;
		struct mcard_node *next;
	}node;

	struct
	{
		struct mcard_ipc_list *list;
		long counts;	//equal to 1, differ with cls_desc.sn_cnt
	} ipc_head;


	struct
	{
		long size;
		long counts;
		struct smss_cluster_info *data;

		struct						
		{
			long cls_counts;		//cluster number of the ipc, only HD
			long len;				//sn length
			char data[MCARD_SN_LEN];//sn data
		}sn[MCARD_NUM];
		long	sn_cnt;				//0~MCARD_NUM
	} cl_descs;

	
	struct smss_stor_info			stor_info;
	struct mcard_data_desc			data_desc;
	struct smss_dev					*dev;

	uchar							disk_path[MCARD_PATH_LEN];
	int								fd;
	int								disk_NO;
	char							disk_sym;
	void							*hd;

}_mcard_node;

typedef struct mcard_mod
{
	struct mcard_node *list;
	long counts;				//0~MCARD_NUM

	char disk_sym[MCARD_NUM];
	int  disk_NO[MCARD_NUM];
	long *sn_cnt;
}_mcard_mod;

#pragma pack(pop)

/*!
func    mcard_create
\brief  create a list
\return list create result
#NULL   create failed
#other  create succeed
*/
struct mcard_mod		*mcard_create();

/*!
func    mcard_destroy
\brief  destroy a list created by mcard_create()
\return list destroy result
#0      destroy succeed
#other  destroy failed
*/
long			mcard_destroy(struct mcard_mod *mod);

/*!
func    mcard_mount
\brief  mount the disk
\param  mod[in]	the disk info
\param	param[in] the param
\return disk mount result
#NULL        mount failed
#other		 mount succeed
*/
struct mcard_node   *mcard_mount(struct mcard_mod *mod, struct mcard_node_param *param);

/*!
func    mcard_unmount
\brief  unmount the disk
\return disk unmount result
#0      unmount succeed
#other	unmount failed
*/
long mcard_unmount(struct mcard_node *mnode);

/*!
func    mcard_time_to_index
\brief  convert the date to the index of clusters and segments
\param  tm_s[in]  the start time of the day
\param	tm_e[in]  the end   time of the day
\param	data_desc[out]	the index of clusters or segments
\return time convert result
#0		convert succeed
#other	convert failed
note:	not support now
*/
long mcard_time_to_index(struct mcard_node *mnode, ullong tm_s, ullong tm_e, struct mcard_data_desc *data_desc);

/*!
\func	mcard_desc_set
\param: data_desc[in]
\		path : windows path
\		fmt : "h264" or "mp4"
\return set result
#0      set succeed
#other  set failed
*/
long	mcard_desc_set(struct mcard_node *mnode, struct mcard_data_desc	*desc);

/*!
func    mcard_data_get
\brief  dump info, format "h264"
\param  mnode[in]   the disk info
\param  cid_s[in]   start cluster id
\param	sid_s[in]	start segment id
\param	img[out]	buffer return
\return data get result
#0      get succeed
#other  get failed   
*/
long mcard_data_get(struct mcard_node *mnode, long cid_s, long sid_s, struct len_str *img);

/*!
func	mcard_data_save
\brief: save data of the sd card
\		if time difference betweem two neighbor segments is large than 30s, save a new file
\return file save result
#0      save succeed
#other  save failed
*/
long	mcard_data_save(struct mcard_node *mnode);

/*!
func	mcard_tool
\brief: test application, if macro _test_ defined
\return application test result
#0      test succeed
#other  test failed
*/
long mcard_tool(int argc, char **argv);

#ifdef __cplusplus
}
#endif/* defined(__cplusplus) */

#endif
