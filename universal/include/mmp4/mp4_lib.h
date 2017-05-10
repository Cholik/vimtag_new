/*!
\file       mp4_lib.h
\brief      declare mp4 read/write interface

  ----history----
  \author     huangyifan
  \date       2010-02-25
  \version    0.01
  \desc       create
  
*/

#ifndef __MP4_LIB_H__
#define __MP4_LIB_H__

#include "mp4_tree.h"

#define MP4_FILE_BASE_OFFSET                0x400000     /*!< file initial offset */
#define MP4_FILE_NAME_LEN                   0x100       /*!< maximum file name length */
#define MP4_BIG_FILE_CRITICAL_POINT         4200000000UL      /*!< 4G file critical point, if large than this value, use 64 bit */

#define MP4_MEDIA_END                       3           /*!< total media file read/write end */
#define MP4_SAMPLE_NO_REACH                 2           /*!< could not fetch an sample */
#define MP4_TRAK_END                        1           /*!< a track read/write end */
#define MP4_NO_ERR                          0           /*!< operation success */
#define MP4_MEM_ALLOC_ERR                   -1          /*!< alloc memory failed */
#define MP4_PARAM_NULL_ERR                  -2          /*!< function params is null */
#define MP4_PARAM_ILLEGAL_ERR               -3          /*!< function params is illegal */
#define MP4_FILE_OPEN_ERR                   -4          /*!< open file failed */
#define MP4_FILE_WRITE_ERR                  -5          /*!< write data into file failed */
#define MP4_FILE_READ_ERR                   -6          /*!< read data from file failed */
#define MP4_FILE_SEEK_ERR                   -7          /*!< seek to file position failed */
#define MP4_ATOM_NEW_ERR                    -8          /*!< new mp4 file atom failed */
#define MP4_ATOM_NO_EXIST_ERR               -9          /*!< no exist such atom */
#define MP4_ATOM_NO_RECOGNIZE_ERR           -10         /*!< atom type can not be recognize */
#define MP4_ATOM_VALUE_ILLEGAL_ERR          -11         /*!< value of atom's member is illegal */
#define MP4_GET_VALUE_ERR                   -12         /*!< get value failed */
#define MP4_COMMON_ERR                      -13         /*!< common error which not appears upwards */

#define MP4ESDescrTag                       0x03
#define MP4DecConfigDescrTag                0x04
#define MP4DecSpecificDescrTag              0x05

#define mp4_get_children(current, t_type, count)\
    while (count-- > 0)\
    {\
        if (0 == memcmp(current->type, t_type, 4))\
        {\
            break;\
        }\
        current = current->brother.next;\
        if(count <= 0)\
        {\
            count = -1;\
            break;\
        }\
    }\
    if (0 > count)\
    {\
        return -8;\
    }


#define mp4_get_children_no_return_value(current, t_type, count)\
    while (count-- > 0)\
    {\
    if (0 == memcmp(current->type, t_type, 4))\
        {\
        break;\
        }\
        current = current->brother.next;\
        if(count <= 0)\
        {\
        count = -1;\
        break;\
        }\
    }\

typedef struct mp4_box
{
    struct mp4_box      *parent;                    /*!< parent of atom */
    struct  
    {
        struct mp4_box  *prev;                      /*!< previous atom */
        struct mp4_box  *next;                      /*!< next atom */
    }brother;
    struct{
        unsigned long   counts;                     /*!< number of children */
        struct mp4_box  *list;                      /*!< first children */
    }children;

    unsigned char       type[4];                    /*!< type of atom */
    unsigned char       reserved[4];                /*!< reserved field */
    uint64_t            size;                       /*!< size of atom */

    unsigned long       version_flag;               /*!< version and flag of atom, 32 bits, version(8 bits), flag(24 bits) */
    union 
    {
        unsigned char   *bin;                       /*!< actual data of atom */
    }data;
}_mp4_box;

typedef struct mp4_h264_data
{
    struct  
    {
        struct mp4_h264_data    *prev;              /*!< previous sps or pps*/
        struct mp4_h264_data    *next;              /*!< next sps or pps */
    }node;
    
    unsigned long               width;              /*!< width of video */
    unsigned long               height;             /*!< height of video */

    unsigned long               len;                /*!< length of data */
    unsigned char               *data;              /*!< sps or pps data */
    
}_mp4_h264_data;

typedef struct mp4_h264_box
{  
    struct  
    {
        unsigned long           counts;             /*!< number of sps in a h264 description */
        struct mp4_h264_data    *list;              /*!< first sps data in sps list */
    }sps;
    struct  
    {
        unsigned long           counts;             /*!< number of pps in a h264 description */
        struct mp4_h264_data    *list;              /*!< first pps in pps list */
    }pps;
    
}_mp4_h264_box;

typedef struct mp4_aac_data
{
    struct  
    {
        struct mp4_aac_data     *prev;              /*!< previous aac */
        struct mp4_aac_data     *next;              /*!< next aac */
    }node;
    
    unsigned long               profile;            /*!< profile of aac */
    unsigned long               samp_freq_index;    /*!< sample frequency index of aac */
    unsigned long               channel_config;     /*!< audio channel configure of aac */

    unsigned long               len;                /*!< length of aac configure data */
    unsigned char               *data;              /*!< actual data of aac configure, usually 2 bytes in adts(3th and 4th byte) */

}_aac_data;

typedef struct mp4_aac_box
{
    struct  
    {
        unsigned long           counts;             /*!< number of aac configure data */
        struct mp4_aac_data     *list;              /*!< first configure data */
    }adts;
}_mp4_aac_box;



typedef struct mp4_sample
{
    unsigned long               len;                        /*!< sample data's length */
    unsigned char               *data;                      /*!< sample data */
    unsigned long               is_key_frame;               /*!< is iframe */
    unsigned long               time_stamp;                 /*!< sample time stamp */
}_mp4_sample;

typedef struct mp4_sample_read_info
{
    unsigned long               last_sample_seq;            /*!< last read sample's sequence number */
    
    struct  
    {
        unsigned long           last_entry_seq;             /*!< initial value : 0 */
        unsigned long           last_sample_count_offset;   /*!< initial value : 0 */
    }stts;

    struct  
    {
        unsigned long           last_entry_seq;             /*!< last entry sequence in stsc atom, initial value: 0 */
        unsigned long           last_inner_sample_seq;      /*!< last sample sequence in chunk, initial value: 0 */
        unsigned long           last_chunk_index;           /*!< last chunk index for stsc */
        uint64_t                last_sample_offset;
    }stsc;

}_mp4_sample_read_info;


typedef struct stss_entry
{
    unsigned long           valid;
    unsigned long           counts;

    unsigned long           index;
    unsigned long           sample_no;
}_stss_entry;

typedef struct stts_entry
{
    unsigned long       valid;
    unsigned long       counts;

    unsigned long       index;
    unsigned long       sample_counts;
    unsigned long       sample_time_stamp_delta;

    struct  
    {
        unsigned long   sample_no_start;
        unsigned long   sample_time_stamp_start;            /* time_stamp == ms * time_scale / 1000 */
    }ctx;
}_stts_entry;


typedef struct stsc_entry
{
    unsigned long       valid;
    unsigned long       counts;

    unsigned long       index;
    unsigned long       chunk_no_start;
    unsigned long       sample_counts_per_chunk;

    unsigned long       chunk_array_counts;
    struct  
    {
        unsigned long   sample_no_start;
    }ctx;
}_stsc_entry;


typedef struct mp4_sample_info
{
    unsigned long           sample_no;
    unsigned long           time_stamp;
    unsigned long           time_ms;
    unsigned long           sample_size;
    unsigned long           is_key_sample;
    unsigned long           is_end;
    uint64_t                file_offset;
}_mp4_sample_info;

typedef struct mp4_track_read_ctx
{
    unsigned long           valid;
    struct mp4_box          *mdia; /* trak[mdia[hdlr,mdhd,minf[stbl[stsd,stts,stsc,stsz,stss]]]] */
    struct mp4_box          *hdlr;
    struct mp4_box          *mdhd;
    struct mp4_box          *minf;
    struct mp4_box          *stbl;
    struct mp4_box          *stsd;
    struct mp4_box          *stts;
    struct mp4_box          *stsz;
    struct mp4_box          *stsc;
    struct mp4_box          *stco;
    struct mp4_box          *co64;
    struct mp4_box          *stss;/* key */

    unsigned long           sample_counts;
    struct  
    {
        struct stsc_entry   stsc;
        struct stts_entry   stts;
        struct stss_entry   stss;
    }entry_cache;

    struct mp4_sample_info  cache_sample;
}mp4_track_read_ctx;

#define mp4_seek_type_by_sample_no                  0
#define mp4_seek_type_by_sample_no_le_key_frame     1
#define mp4_seek_type_by_sample_no_ge_key_frame     2
#define mp4_seek_type_by_time_ms                    3
#define mp4_seek_type_by_time_ms_le_key_frame       4
#define mp4_seek_type_by_time_ms_ge_key_frame       5

typedef struct mp4_track
{
    struct  
    {
        struct mp4_track        *prev;              /*!< previous track */  
        struct mp4_track        *next;              /*!< next track */
    }node;
    struct mp4_file             *parent;            /*!< indicate owner */
    struct mp4_box              *trak;              /*!< track to be read or write */
    struct mp4_sample_read_info read_info;          /*!< keep read info */
    unsigned long               trak_end;           /*!< track end flag */
    unsigned long               last_time_stamp;    /*!< last time sample time stamp */ 
    unsigned long               start_time_stamp;   /*!< begin time sample time stamp */
    unsigned long               media_type;         /*!< track type, audio:0 or video:1 */
    long                        checkIFrame;        /*!< detect I frame is come or not */
    void                        *refer;             /*!< refer to some connect pointer */

    struct mp4_track_read_ctx   read_ctx;           /* for mp4 read */
}_mp4_track;

typedef struct mp4_file
{
    struct mp4_box          *root;              /*!< mp4 media file root atom, just a node with data */
    struct mp4_h264_box     h264;               /*!< h264 decode configure set */
    struct mp4_aac_box      aac;                /*!< aac decode configure set */
    FILE                    *fp;                /*!< read or write file pointer */
    unsigned long           open_mode;          /*!< file open mode, 0 : read' 1 : write */  
    unsigned long           is_big_file;
    struct{unsigned long len; char *data; }file_name, tmp_file_name;/*
    char                    file_name[MP4_FILE_NAME_LEN];
    char                    tmp_file_name[MP4_FILE_NAME_LEN]; */

    unsigned long           next_track_id;      /*!< next available track id */

    struct  
    {
        uint64_t            base_offset;        /*!< data start position */
        uint64_t            data_size;          /*!< whole file size */
        uint64_t            chunk_offset;       /*!< chunk's offset */
    }write;

    struct  
    {
        unsigned long       counts;             /*!< number of tracks */
        struct mp4_track    *list;              /*!< first track in tracks list */
    }tracks;

}_mp4_file;



/*!
func    mp4_file_create
\brief  create a mp4 file struct which hold read or write info
\param  file_name[in]               media file name, use to open file, can not be null
\param  open_mode[in]               file open mode, can be "rb", "wb" currently
\param  open_mode_len[in]           length of open_mode string, can not small than 1  
\return the create result
        #other                      file create succeed
        #NULL                       file create failed
*/
struct mp4_file *mp4_file_create(const char *file_name, char *open_mode, unsigned long open_mode_len);

/*!
func    mp4_file_destroy
\brief  destroy a exist mp4 read/write file struct which create by mp4_file_create func
\param  file[in]                    mp4 read/write file struct to be destroy, can not be null 
\return the destroy result
        #0                          destroy succeed
        #other                      destroy failed
*/
long mp4_file_destroy(struct mp4_file *file);

/*!
func    mp4_file_open_track
\brief  open a exist track for read by media type, for instance: aac, h264
\param  file[in]                    mp4 file info struct
\param  media_type[in]              track's type, currently support 'aac' and 'h264'
\param  type_len[in]                length of media_type string 
\return the open result
        #other                      track open succeed
        #NULL                       track open failed
*/
struct mp4_track *mp4_file_open_track(struct mp4_file *file, char *media_type, unsigned long type_len);

/*!
func    mp4_file_create_track
\brief  create a track for media data write
\param  file[in]                    mp4 file info struct
\param  h264[in]                    h264 decode info, can not be null when media_type equal 'h264'
\param  aac[in]                     aac decode info struct, can not be null when media_type equal 'aac' 
\param  media_type[in]              media_type string, indicate what kind of media will be created
\param  type_len[in]                length of media_type string 
\return the create result
        #other                      track create succeed
        #NULL                       track create failed
*/
struct mp4_track *mp4_file_create_track(struct mp4_file       *file,
                                        struct mp4_h264_box   *h264,
                                        struct mp4_aac_box    *aac,
                                        char                  *media_type, 
                                        unsigned long         type_len);

long mp4_track_sample_read(struct mp4_track *track, unsigned long sample_no, unsigned long buf_size, unsigned char *buf, struct mp4_sample_info *sample_info);
long mp4_track_sample_query(struct mp4_track *track, unsigned long seek_type, unsigned long value, struct mp4_sample_info *sample_info);

/* give uping ...... */
/*!
func    mp4_file_read_sample
\brief  read an sample from opening mp4 file,
        after use should call mp4_file_clear_sample to clear
\param  track[in]                   media track to be read, audio track or video track
\param  sample[in]                  sample struct, holds read out data
\return sample read out result
        #0                          sample read succeed
        #MP4_TRAK_END               track reach samples end
        #other                      read sample failed 
*/
long mp4_file_read_sample(struct mp4_track *track, struct mp4_sample *sample);
long mp4_file_clear_sample(struct mp4_sample *sample);

/*!
func    mp4_file_write_sample
\brief  read an sample from opening mp4 file
\param  track[in]                   media track to be write, audio track or video track
\param  sample[in]                  sample struct to be written
\return sample write result
        #0                          sample write succeed
        #other                      sample write failed 
*/
long mp4_file_write_sample(struct mp4_track *track, struct mp4_sample *sample);

/*!
func    mp4_file_write_tree
\brief  write mp4 tree index into file
\param  file[in]                    file tree index to be write in
\return tree index write result
        #0                          tree index write succeed
        #other                      tree index write failed 
*/
long mp4_file_write_tree(struct mp4_file *file);

/*!
func    mp4_file_seek
\brief  seek to a giving time stamp position, not implement currently, reserved
\param  file[in]                    file tree index struct
\param  time_stamp[in]              time stamp indicate which position to be seek
\return seek result
        #0                          tree index write succeed
        #other                      tree index write failed 
*/
long mp4_file_seek(struct mp4_file *file, unsigned long time_stamp, unsigned long *realTimeStamp);

/*!
func    mp4_file_get_duration
\brief  get mp4 file total duration, in milliseconds
\param  file[in]       file tree index struct
\return media file total duration, in milliseconds
    #negative number        get duration failed
    #other                          succeed
*/
long mp4_file_get_duration(struct mp4_file *file);

typedef struct mp4_file_info
{
    struct
    {
        unsigned long   low;
        unsigned long   hight;
    }size;
    struct  
    {
        unsigned long       duration;
        unsigned long       frames;
        unsigned long       frame_seq;
    }video;
}_mp4_file_info;

/*!
func    mp4_file_get_info
\brief  get mp4 file information
\param  file[in]       file tree index struct
\return media file total duration, in milliseconds
    #negative number        get duration failed
    #other                          succeed
*/
long mp4_file_get_info(struct mp4_file *file, struct mp4_file_info *info);

#endif
