/*!
\file       msg_pack.h
\brief      message translate unit

 ----history----
\author     chengzhiyong
\date       2008-08-22
\version    0.01
\desc       split from msg_transfer unit

$Author: chengzhiyong $
$Id: msg_pack.h,v 1.2 2008-09-01 11:48:22 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__msg_pack_h__)
#define __msg_pack_h__

struct pack_def;
struct len_str;
struct message;

/*!
func    msg_on_send_pack
\brief  on send pack callback routine
\param  refer[in]               the refer object
\param  msg[in]                 the message
\param  file[in]                the code file name, should be macro __FILE__
\param  line[in]                the code file line, should be macro __LINE__
\return dealwith result
        #0                      succeed
        #other                  error code
*/
typedef long (*msg_on_send_pack)(void *refer, struct message *msg, const char *file, unsigned long line);


/*!
func    msg_create_pack
\brief  create message pack
\param  mqlst[in]               the message queue list
\param  def_name[in]            the definition type name string
\param  def_name_len[in]        the definition type name string length
\param  def_magic[in]           the definition magic value
                                # if 0 get from component
\param  size[in]                the message size, can set as msg_default_size usually
\param  file[in]                the code file name, should be macro __FILE__
\param  line[in]                the code file line, should be macro __LINE__
\return create result
        #NULL                   failed, have not enough memory
        #other                  message object
*/
struct message* msg_create_pack(struct mmq_list *mqlst,
                                char            *def_name,
                                unsigned long   def_name_len,
                                unsigned long   def_magic,
                                unsigned long   size,
                                const char      *file,
                                unsigned long   line);

/*!
func    msg_destroy_pack
\brief  destroy message
\param  mqlst[in]               the message queue list
\param  msg[in]                 the message return by msg_create
\param  file[in]                the code file name, should be macro __FILE__
\param  line[in]                the code file line, should be macro __LINE__
\return delete result
        #0                      succeed
        #other                  error code
*/
long msg_destroy_pack(struct mmq_list *mqlst, struct message *msg, const char *file, unsigned long line);

/*!
func    msg_send_pack
\brief  send out a message to special component(remote or local, sign by component id),
        this is asyn-call, the message will be saved into message queue, then
        transfer to special component(local or remote) later
\param  mqlst[in]               the message queue list
\param  from[in]                the sender component id
\param  from_handle[in]         the handle from
                                need send this value back to caller
\param  to[in]                  the receiver component id
\param  to_handle[in]           the remote handle
\param  msg[in]                 the message try to send out
\param  data_base_addr[in]      the data base address, if NULL means set it auto.
                                normal way: should set to NULL
\param  msg_on_send_pack[in]    on send event call-back routine, for trace, can be NULL
\param  refer[in]               the refer object, for trace, can be NULL
\param  file[in]                the code file name, should be macro __FILE__
\param  line[in]                the code file line, should be macro __LINE__
\return send out result
        #0                      succeed
        #other                  error code
*/
long msg_send_pack(struct mmq_list  *mqlst, 
                   long             from, 
                   long             from_handle,
                   long             to,
                   long             to_handle,
                   struct message   *msg,
                   void             *data_base_addr,
                   msg_on_send_pack on_send,
                   void             *refer,
                   const char       *file,
                   unsigned long    line);


/*!
func    msg_alloc
\brief  alloc a space from message, just modify message-self pointer
\param  msg[in]                 the message return by msg_create
\param  size[in]                the size
\return result
        #NULL                   have not enough space
        #other                  start pointer
*/
void* msg_alloc(struct message *msg, unsigned long size);

/*!
func    calloc
\brief  alloc a space from message, then clean
\param  msg[in]                 the message return by msg_create
\param  size[in]                the size
\return result
        #NULL                   have not enough space
        #other                  start pointer
*/
void* msg_calloc(struct message *msg, unsigned long size);

/*!
func    msg_save_data
\brief  save data into message, malloc a space then copy data into.
        such as len-str can use this function 
\param  msg[in]                 the message return by msg_create
\param  data[in]                the data try to save
\param  len[in]                 the data len
\return save result
        #NULL                   have not enough space to save string
        #other                  data start pointer
*/
void* msg_save_data(struct message *msg, void *data, unsigned long len);

/*!
func    msg_save_bytes
\brief  save a bytes array into message, malloc a space then copy byte array
\param  msg[in]                 the message return by msg_create, should be len-str
\param  src[in]                 the string try to save, should be a len-str
\param  dst[in]                 the dst pointer
\return save result
        #0                      succeed
        #other                  error code
*/
long msg_save_bytes(struct message *msg, struct pack_bytes *src, struct pack_bytes *dst);

/*!
func    msg_save_str
\brief  save a string into message, malloc a space then copy string
        into it with '\0'
\param  msg[in]                 the message return by msg_create
\param  str[in]                 the string try to save
\param  len[out]                the string length, if NULL ignore it
\return save result
        #NULL                   have not enough space to save string
        #other                  string start pointer
*/
char* msg_save_str(struct message *msg, char *str, uint32_t *len);

/*!
func    msg_save_lenstr
\brief  save a string into message, malloc a space then copy string
        into it with '\0'
\param  msg[in]                 the message return by msg_create, should be len-str
\param  src[in]                 the string try to save, should be a len-str
\param  dst[in]                 the dst pointer
\return save result
        #0                      succeed
        #other                  error code
*/
long msg_save_lenstr(struct message *msg, struct pack_lenstr *src, struct pack_lenstr *dst);

/*!
func    msg_save_lenstr_array
\brief  save a string into message, malloc a space then copy string
        into it with '\0'
\param  msg[in]                 the message return by msg_create, should be len-str
\param  dst[out]                the space used to save dst pack-lenstr array start pointer
\param  dst_counts[out]         dst string counts save pointer
\param  src[in]                 the src string array
\param  src_counts[in]          the src len-string counts
\return save result
        #0                      succeed
        #other                  error code
*/
long msg_save_lenstr_array(struct message       *msg, 
                           struct pack_lenstr   **dst,
                           uint32_t             *dst_counts,
                           struct len_str       *src,
                           unsigned long        src_counts);

/*!
func    msg_save_lenstr2
\brief  save a pack_lenstr into message, malloc a space then copy string
        into it with '\0'
\param  msg[in]                 the message return by msg_create, should be len-str
\param  src[in]                 the pack string try to save, should be a len-str
\param  dst[in]                 the dst pointer
\return save result
        #0                      succeed
        #other                  error code
*/
long msg_save_lenstr2(struct message *msg, struct len_str *src, struct pack_lenstr *dst);

/*!
func    msg_save_pack
\brief  save a pack into message, malloc a space then copy struct into,
        and save a pack's pointer member refer data to message ending.
\param  msg[in]                 the message return by msg_create
\param  def[in]                 the packet def
\param  dst[in]                 the dst pointer must be in buffer be
                                allocated from this message
\param  src[in]                 the src packet data
\return save result
        #0                      succeed
        #other                  error code
*/
long  msg_save_pack(struct message *msg, struct pack_def *def, void *dst, void *src);

/*!
func    msg_save_pack_array
\brief  save a pack array into message, malloc a space then copy struct into,
        and save a pack's pointer member refer data to message ending.
\param  msg[in]                 the message return by msg_create
\param  def[in]                 the packet def
\param  dst[out]                the pointer to save dest array start pointer ,
                                must be in buffer be allocated from this message,
                                should be &data->xxx
\param  dst_counts[out]         dst counts save pointer,
                                must be in buffer be allocated from this message,
                                should be &data->xxx_counts
\param  src[in]                 the source array start pointer, can be NULL,
                                NULL means empty
\param  src_counts[in]          the source array counts, if 0 means empty
\return save result
        #0                      succeed
        #other                  error code
*/
long msg_save_pack_array(struct message     *msg,
                         struct pack_def    *def,
                         void               **dst,
                         uint32_t           *dst_counts,
                         void               *src,
                         unsigned long      src_counts);

#define DS_SET_FLAG_NO_ACK                      0x00000001  /* macro for flag of struct ds_set */
#define DS_SET_FLAG_RETURN_RECORD               0x00000002  /* macro for flag of struct ds_set */
#define DS_SET_ACK_FLAG_FAIL                    0x00000001  /* macro for flag of struct ds_set_ack */
#define DS_SET_ACK_FLAG_EXIST                   0x00000002  /* macro for flag of struct ds_set_ack */

/*!
func    msg_save_serial_pack
\brief  save a pack as pack-serial data
\param  msg[in]                 the message return by msg_create
\param  def[in]                 the packet def
\param  dst[out]                the dst pack-len-string to save serial data
\param  src[in]                 the source data
\param  serial_pack_flag[in]    refer to serial_pack_flag_***, refer pack.h
\return save result
        #0                      succeed
        #other                  error code
*/
long msg_save_serial_pack(struct message        *msg,
                          struct pack_def       *def,
                          struct pack_bytes     *dst,                       
                          void                  *src,
                          unsigned long         serial_pack_flag);


/*!
func    msg_create_serial_pack_ds_set
\brief  create a serial packet ds-set message
\param  mqlst[in]               the message queue list
\param  def[in]                 the packet def
\param  counts[in]              the data counts
\param  keys[in]                the key list
\param  data[in]                the data list, NULL or (value[]==NULL) means delete
\param  set_flag[in]            the global set flag, for all records, DS_SET_FLAG_***
\param  dps_flag[in]            dps_flag, for records, enum dps_flag, refer depository.h
\param  serial_pack_flag[in]    refer to serial_pack_flag_***, refer pack.h
\return save result
        #0                      succeed
        #other                  error code
*/
struct message *msg_create_serial_pack_ds_set(struct mmq_list    *mqlst,
                                              struct pack_def    *def,
                                              unsigned long      counts,
                                              struct pack_bytes  *keys,
                                              void               **datas,
                                              unsigned long      set_flag,
                                              unsigned long      dps_flag, /* enum dps_flag */
                                              unsigned long      serial_pack_flag);

struct message * msg_create_bin_pack_by_json_pack( struct mmq_list *mqlst, struct pack_def *def, struct message *json_msg );
struct message * msg_create_json_pack_by_bin_pack( struct mmq_list *mqlst, struct pack_def *def, struct message *bin_msg );
extern long msg_save_finish( struct message *msg );
#endif /* !defined(__msg_pack_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
