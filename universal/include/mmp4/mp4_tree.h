#ifndef __MP4_TREE_H__
#define __MP4_TREE_H__



#if defined(__APPLE__)
#   pragma clang diagnostic push
#   pragma clang diagnostic ignored "-Wtypedef-redefinition"
#endif

#if !defined(__int64_t_defined)
#define __int64_t_defined
#ifdef  _MSC_VER     
typedef __int64             int64_t; 
typedef unsigned __int64    uint64_t;      
#else    
typedef long long           int64_t;
typedef unsigned long long  uint64_t;       
#endif
#endif  /* !defined(__int64_t_defined) */

#if defined(__APPLE__)
#   pragma clang diagnostic pop
#endif

struct mp4_box;
struct mp4_file;
struct mp4_aac_box;
struct mp4_h264_box;

#define _LARGEFILE_SOURCE
#define _LARGEFILE64_SOURCE
#define _FILE_OFFSET_BITS 64

#define four_bytes_ntohl(buf) ((((unsigned int)(buf)[0]) << 24) | (((unsigned int)(buf)[1]) << 16) | (((unsigned int)(buf)[2]) << 8) | ((unsigned int)(buf)[3]))
#define eight_bytes_ntoint64(buf) ((((uint64_t)((buf)[0])) << 56) | (((uint64_t)((buf)[1])) << 48) | (((uint64_t)((buf)[2])) << 40) | (((uint64_t)((buf)[3])) << 32) | (((uint64_t)((buf)[4])) << 24) | (((uint64_t)((buf)[5])) << 16) | (((uint64_t)((buf)[6])) << 8) | (((uint64_t)((buf)[7]))))
#define two_bytes_ntohl(buf) ((((unsigned char)((buf)[0])) << 8) | (unsigned char)((buf)[1]))
#define four_bytes_cmp(str1, str2) (!((((unsigned char*)(str1))[0] == ((unsigned char*)(str2))[0]) && (((unsigned char*)(str1))[1] == ((unsigned char*)(str2))[1]) && (((unsigned char*)(str1))[2] == ((unsigned char*)(str2))[2]) && (((unsigned char*)(str1))[3] == ((unsigned char*)(str2))[3])))
#define long_to_network_four_bytes(value, buf)\
    do{\
        ((unsigned char*)(buf))[0] = (unsigned char)((value)>>24);\
        ((unsigned char*)(buf))[1] = (unsigned char)((value)>>16);\
        ((unsigned char*)(buf))[2] = (unsigned char)((value)>>8);\
        ((unsigned char*)(buf))[3] = (unsigned char)(value);\
    }while(0)

#define int64_to_network_eight_bytes(value, buf)\
    do{\
        ((unsigned char*)(buf))[0] = (unsigned char)((value)>>56);\
        ((unsigned char*)(buf))[1] = (unsigned char)((value)>>48);\
        ((unsigned char*)(buf))[2] = (unsigned char)((value)>>40);\
        ((unsigned char*)(buf))[3] = (unsigned char)((value)>>32);\
        ((unsigned char*)(buf))[4] = (unsigned char)((value)>>24);\
        ((unsigned char*)(buf))[5] = (unsigned char)((value)>>16);\
        ((unsigned char*)(buf))[6] = (unsigned char)((value)>>8);\
        ((unsigned char*)(buf))[7] = (unsigned char)(value);\
    }while(0)

    

#define short_to_network_two_bytes(value, buf)\
    do{\
        ((unsigned char*)(buf))[0] = (unsigned char)((value)>>8);\
        ((unsigned char*)(buf))[1] = (unsigned char)((value));\
    }while(0)

#define four_bytes_cpy(buf1, buf2)\
    do{\
        ((unsigned char*)(buf1))[0] = ((unsigned char*)(buf2))[0];\
        ((unsigned char*)(buf1))[1] = ((unsigned char*)(buf2))[1];\
        ((unsigned char*)(buf1))[2] = ((unsigned char*)(buf2))[2];\
        ((unsigned char*)(buf1))[3] = ((unsigned char*)(buf2))[3];\
    }while(0)
    


/*!
func    mp4_parse_file
\brief  get media file index tree and contain in reader
\param  reader[in]                  reader info container
\return parse result
        #0                          tree index parse succeed
        #other                      tree index parse failed 
*/
long mp4_parse_file(struct mp4_file *reader);


/*!
func    mp4_get_aac_configure
\brief  get aac configure from read index tree 
\param  root[in]                    top node of media index tree
\param  aac[in]                     container of aac configure
\return aac configure get result
        #0                          configure get succeed
        #other                      configure get failed
*/
long mp4_get_aac_configure(struct mp4_box *root, struct mp4_aac_box *aac);

/*!
func    mp4_get_h264_configure
\brief  get h264 configure from read index tree, such as sps or pps 
\param  root[in]                    top node of media index tree
\param  h264[in]                    container of h264 configure
\return h264 configure get result
        #0                          configure get succeed
        #other                      configure get failed
*/
long mp4_get_h264_configure(struct mp4_box *root, struct mp4_h264_box *h264);


/* write tree function definition */

/*!
func    mp4_file_create_file_box
\brief  create a file box which contains fixed head for unknown mp4 media file 
\param  mp4[in/out]                 struct save media index tree    
\return fixed head create result
        #0                          file box create succeed
        #other                      file box create failed
*/
long mp4_file_create_file_box(struct mp4_box **mp4);
/*!
func    mp4_destroy_file_box
\brief  destroy a media index tree
\param  mp4[in]                     media index tree    
\return destroy result
        #0                          destroy mp4 index tree succeed
        #other                      destroy mp4 index tree failed
*/
long mp4_destroy_file_box(struct mp4_box *mp4);

/*!
func    mp4_adjust_box
\brief  fill box full, and improve index tree for write in
\param  writer[in]                  write container    
\return adjust result
        #0                          adjust box succeed
        #other                      adjust box failed
*/
long mp4_adjust_box(struct mp4_file *writer);

/*!
func    mp4_new_box
\brief  new a box for index tree
\param  box[in/out]                 container of new box    
\param  parent[in]                  parent of this new box
\param  type_name[in]               box type name, 4 bytes
\param  has_version[in]             indicate this box is a full box or unfull box
\return box new result
        #0                          new box succeed
        #other                      new box failed
*/
long mp4_new_box(struct mp4_box **box, struct mp4_box *parent, unsigned char *type_name, unsigned long has_version);

/*!
func    set_tkhd_box
\brief  set a exist track head atom
\param  tkhd[in]                    this tkhd box    
\param  version[in]                 version and flag, 4 bytes, also use to indicate create time and modify time is a 64 bits or 32 bits
\param  track_id[in]                id of track, can not be zero
\param  duration[in]                total time of this track, can not be zero
\param  is_audio[in]                indicate this track is a audio track or other, 1 is audio, other is video or hint
\param  width[in]                   width of track, if the value of is_audio is 1, width should be zero
\param  height[in]                  height of track, if the value of is_audio is 1, height should be zero
\return tkhd set result
        #0                          set box succeed
        #other                      set box failed
*/
long set_tkhd_box(struct mp4_box *tkhd, unsigned long version, unsigned long track_id, unsigned long duration, unsigned long is_audio, unsigned long width,unsigned long height);

/*!
func    set_hdlr_box
\brief  set a exist handler reference atom
\param  hdlr[in]                    box to be set    
\param  version[in]                 version and flag, 4 bytes, default value is zero
\param  handler_type[in]            when present in a meta box, contains an appropriate value to indicate the format of the meta box contents
\param  name[in]                    is a null-terminated string in UTF-8 characters which gives a human-readable name for the track
                                    type (for debugging and inspection purposes).
\param  name_len[in]                length of name
\return box set result
        #0                          set box succeed
        #other                      set box failed
*/
long set_hdlr_box(struct mp4_box *hdlr, unsigned long version, unsigned char *handler_type, unsigned char *name, unsigned long name_len);

/*!
func    set_url_box
\brief  set a exist handler reference atom
\param  url[in]                     box to be set    
\param  version_flag[in]            version and flag, 4 bytes, is an integer that specifies the version of this box
\param  location[in]                a null-terminated string using UTF-8 characters.
\param  location_len[in]            length of location
\return box set result
        #0                          set box succeed
        #other                      set box failed
*/
long set_url_box (struct mp4_box *url,  unsigned long version_flag, unsigned char *location, unsigned long location_len);
/*!
func    set_stco_box
\brief  set a exist chunk offset atom
\param  stco[in]                    box to be set    
\param  chunk_offset[in]            chunk offset to be add into stco box
\return box set result
        #0                          set box succeed
        #other                      set box failed
*/
long set_stco_box(struct mp4_box *stco, unsigned long chunk_offset);
/*!
func    set_co_box
\brief  set a exist chunk offset atom
\param  co64[in]                    box to be set    
\param  chunk_offset[in]            chunk offset to be add into co64 box
\return box set result
        #0                          set box succeed
        #other                      set box failed
*/
long set_co64_box(struct mp4_box *co64, int64_t chunk_offset);
/*!
func    set_stts_box
\brief  set a exist time to sample atom
\param  stts[in]                    time to sample box to be set    
\param  chunk_offset[in]            chunk offset to be add into stco box
\return box set result
        #0                          set box succeed
        #other                      set box failed
*/
long set_stts_box(struct mp4_box *stts, unsigned long sample_count, long unsigned sample_delta);
/*!
func    set_stss_box
\brief  set a exist time to sample time table atom
\param  stss[in]                    sample time table box to be set    
\param  sample_num[in]              the no number sample contain idr 
\return box set result
        #0                          set box succeed
        #other                      set box failed
*/
long set_stss_box(struct mp4_box *stss, unsigned long sample_num);;
/*!
func    set_skip_box
\brief  set a exist skip or free atom
\param  skip[in]                    skip box to be set    
\param  data_len[in]              skip or free data size 
\return box set result
        #0                          set box succeed
        #other                      set box failed
*/
long set_skip_box(struct mp4_box *skip, unsigned data_len);
/*!
func    set_dref_box
\brief  set a exist data reference box
\param  dref[in]                    dref box to be set    
\param  data_entry[in]              a data entry which will be add into dref 
\return box set result
        #0                          set box succeed
        #other                      set box failed
*/
long set_dref_box(struct mp4_box *dref, struct mp4_box *data_entry);
/*!
func    set_stsz_box
\brief  add a sample size into box
\param  stsz[in]                    sample size box to be set    
\param  sample_size[in]             sample size to be add into box 
\return box set result
        #0                          set box succeed
        #other                      set box failed
*/
long set_stsz_box(struct mp4_box *stsz, unsigned long sample_size);

long switch_to_large_file(struct mp4_box *root);

#endif
