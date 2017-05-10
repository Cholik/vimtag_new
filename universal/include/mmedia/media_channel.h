/*!
\file       media_channel.h
\brief      media channel unit, channel like a water pipe, can be link 
            with each other
            don't call any media function in media channel on_destroy event
 ----history----
\author     chengzhiyong
\date       2009-09-19
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: media_channel.h,v 1.20 2009-09-19 01:46:28 chengzhiyong Exp $
*/
#if !defined(__media_channel_h__)
#define __media_channel_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/* ---------- media object ----------------------- */
/*!
func    media_object_use
\brief  add ref counts of media-object
\param  obj[in]                 the media object
\return use result
        #0                      succeed
        #other                  error code
*/
long media_object_use(struct media_object *obj);

/*!
func    media_object_unuse
\brief  sub ref counts of media-object, if counts be ZERO and be 
        mark as free will be free and clear
\param  obj[in]                 the media object
\return use result
        #0                      succeed
        #other                  error code
*/
long media_object_unuse(struct media_object *obj);
/* ---------- media object ----------------------- */

/* ---------- media type ------------------- */
/*!
func    media_type_create
\brief  create media type
\param  major_len[in]           the major type length
\param  major[in]               the major type string such as "video" | "audio"
\param  sub_len[in]             the major type length
\param  sub[in]                 the major type string such as "h264/nal" | "pcm" | "aac/adts" 
\param  format_size[in]         format size
\param  format_len[in]          the format data length in format param
\param  format[in]              the format
\return the input stream
        #NULL                   failed
        #other                  the stream
*/
struct media_type *media_type_create(unsigned long major_len, char *major,
                                     unsigned long sub_len,   char *sub,
                                     unsigned long format_size,
                                     unsigned long format_len, unsigned char *format);

/*!
func    media_type_destroy
\brief  destroy media type
\param  type[in]                the media type
\return the input stream
        #NULL                   failed
        #other                  the stream
*/
long media_type_destroy(struct media_type *type);
/* ---------- media type ------------------- */

/* ---------- media params ----------------------- */
/*!
func    media_params_create
\brief  create media params, after use call media_params_detroy to free resource
\param  len[in]                 the text length
\param  text[in]                description, can be NULL
                                can be multi lines
                                format: xxx = xxx\r\nyyy=yyy
\brief  create media params
\return the media params
        #NULL                   failed
        #other                  the media params
*/
struct media_params *media_params_create(unsigned long len, char *text);

/*!
func    media_params_dup
\brief  dup media params from a exist media params, same as media_params_create 
        should call media_params_destroy after use
\param  prams[in]               the src media params, can be NULL
                                if NULL create a empty params
\brief  create media params
\return the media params
        #NULL                   failed
        #other                  the media params
*/
struct media_params *media_params_dup(struct media_params *params);

/*!
func    media_params_2_desc
\brief  convert media params to desc text
\param  params[in]              the media channel create parameters
\param  buf[in]                 the buffer
\param  size[in]                the buffer size.
\return encode result
        #>0                     the size
        #other                  the error code
*/
long media_params_2_text(struct media_params *params, unsigned char *buf, unsigned long size);

/*!
func    media_params_set
\brief  set media param
\param  params[in]              the media channel create parameters
\param  key_len[in]             the param name length
\param  key[in]                 the param name
\param  value_len[in]           the value string length, if 0 means delete
\param  value[in]               the param value, if NULL means delete
\return the result
        #0                      succeed
        #other                  the error code
*/
long media_params_set(struct media_params *params,
                      unsigned long key_len,    char *key,
                      unsigned long value_len,  char *value);

/*!
func    media_params_get
\brief  get media param
\param  params[in]              the media channel create parameters
\param  key_len[in]             the param name length
\param  key[in]                 the param 
\return the value
        #NULL                   not found
        #other                  the value string
*/
struct len_str  *media_params_get(struct media_params *params, unsigned long key_len, char *key);

/*!
func    media_params_set_int
\brief  set media integer param
\param  params[in]              the media channel create parameters
\param  key_len[in]             the param name length
\param  key[in]                 the param name
\param  value[in]               the param value
\return the result
        #0                      succeed
        #other                  the error code
*/
long media_params_set_int(struct media_params *params,  unsigned long key_len, char *key, long value);

/*!
func    media_params_get_int
\brief  get integer param
\param  params[in]              the media channel create parameters
\param  key_len[in]             the param name length
\param  key[in]                 the param key
\param  default_value[in]       if not exist return default value
\return the result
*/
long media_params_get_int(struct media_params *params, unsigned long key_len, char *key, long default_value);

/*!
func    media_params_destroy
\brief  destroy media params
\param  params[in]              the media channel create parameters
\return the result
        #0                      succeed
        #other                  the error code
*/
long media_params_destroy(struct media_params *params);
/* ---------- media params ----------------------- */


/* ---------- media channel class ---------------- */
/*!
func    media_channel_class_create
\brief  create media channel class, will be auto destroy when parent factory be destroy
\param  factory[in]             the factory, parent
\param  desc[in]                the description
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return the media channel
        #NULL                   failed
        #other                  the channel class
*/
struct media_channel_class *media_channel_class_create(struct media_factory *factory,
                                                       struct media_channel_desc *desc,
                                                       struct media_event   *ctx_event);

/*!
func    media_channel_class_destroy
\brief  destroy media channel class
\param  channel_class[in]       the media channel class
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return destroy result
        #0                      succeed
        #other                  error code
*/
long media_channel_class_destroy(struct media_channel_class *channel_class, struct media_event *ctx_event);
/* ---------- media channel class ---------------- */


/* ---------- media channel ---------------- */
/*!
func    media_channel_create
\brief  create media channel, will be auto destroy when parent channel-class be destroy
\param  channel_class[in]       the channel class, parent
\param  params[in]              the channel params, just for auto link. if NULL will not auto-link,
                                if not NULL will dup new one
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return the media channel
        #NULL                   failed
        #other                  the channel
*/
struct media_channel *media_channel_create(struct media_channel_class   *channel_class,
                                           struct media_params          *params,
                                           struct media_event           *ctx_event);

/*!
func    media_channel_destroy
\brief  destroy media channel
\param  channel[in]             the media channel
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long media_channel_destroy(struct media_channel *channel, struct media_event *ctx_event);

typedef long (*media_channel_callback)(struct media_channel *channel, void *data, struct media_event *event);
/*!
func    media_channel_call
\brief  call method from channel, can used to called by callback function from net/driver module
\param  channel[in]             the media channel
\param  callback[in]            the callback function
\param  param[in]               the callback param
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return call result
        #0                      succeed
        #other                  the error code
*/
long media_channel_call(struct media_channel *channel, media_channel_callback callback, void *param, struct media_event *ctx_event);

/*!
func    media_channel_call_external
\brief  call external function, for the function will call-back to channel's function
        after call, plz user media_object_check() the channel is active now.
\param  _ret[out]               the result save param
\param  _func[in]               the function name or pointer
\param  _params[in]             the params list, must include "()", such as "(conn, data)"
\param  ctx_event[in]           the context event, current event environment
\return call result
*/
#define media_channel_call_external(_ret, _func, _params, _ctx_event)\
    do \
    {\
        media_channel_leave(_ctx_event, __FILE__, __LINE__);\
        (_ret) = _func _params;\
        media_channel_enter(_ctx_event, __FILE__, __LINE__);\
    } while (0)
#define media_channel_call_external_void(_func, _params, _ctx_event)\
    do \
    {\
        media_channel_leave(_ctx_event, __FILE__, __LINE__);\
        _func _params;\
        media_channel_enter(_ctx_event, __FILE__, __LINE__);\
    } while (0)
long media_channel_leave(struct media_event *ctx_event, char *file, unsigned long line);
long media_channel_enter(struct media_event *ctx_event, char *file, unsigned long line);

/*!
func    media_channel_ctrl
\brief  control media channel, will raise channel on ctl event
\param  channel[in]             the media channel
\param  sub_len[in]             the sub event length, can not 0
\param  sub[in]                 the sub event string, "idr"|"autosize"|"play"|"stop"|"start"... can not NULL
\param  target[in]              the target object, channel|ostream|istream object, can be NULL
\param  src[in]                 the src target object, channel|ostream|istream object, can be NULL
\param  params[in/out]          the media params
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return control result
        #0                      succeed
        #other                  the error code
*/
long media_channel_ctrl(struct media_channel    *channel,
                        unsigned long           sub_len,
                        char                    *sub,
                        void                    *target/* struct media_object */,
                        void                    *src/* struct media_object */,
                        struct media_params     *params,
                        struct media_event      *ctx_event);
/* ---------- media channel ---------------- */

/* ---------- media stream ---------------- */
/*!
func    media_istream_create
\brief  create media in-stream, will be auto destroy when parent channel be destroy
\param  channel[in]             the media channel, parent
\param  type[in]                the media type, such as 
                                "video/h264" "video/x" (x is '*' here)  "audio/aac"
\param  params[in]              the params, can be NULL, if not NULL will dup new one
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return the input stream
        #NULL                   failed
        #other                  the stream
*/
struct media_istream* media_istream_create(struct media_channel *channel,
                                           struct media_type    *type,
                                           struct media_params  *params,
                                           struct media_event   *ctx_event);

/*!
func    media_istream_destroy
\brief  destroy media in-stream
\param  istream[in]             the in-stream
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long media_istream_destroy(struct media_istream *istream, struct media_event *ctx_event);

/*!
func    media_ostream_create
\brief  create media out-stream, will be auto destroy when parent channel be destroy
\param  channel[in]             the media channel, parent
\param  type[in]                the media type, such as 
                                "video/h264" "video/x" (x is '*' here) "audio/aac"
\param  params[in]              the params, can be NULL, if not NULL will dup new one
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return the media channel
        #NULL                   failed
        #other                  the stream
*/
struct media_ostream* media_ostream_create(struct media_channel *channel,
                                           struct media_type    *type,
                                           struct media_params  *params,
                                           struct media_event   *ctx_event);

/*!
func    media_ostream_destroy
\brief  destroy media out-stream
\param  ostream[in]             the out-stream
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long media_ostream_destroy(struct media_ostream *ostream, struct media_event *ctx_event);

/*!
func    media_stream_link
\brief  link stream
\param  ostream[in]             the out-stream
\param  istream[in]             the in-stream
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return link result
        #0                      succeed
        #other                  the error code
*/
long media_stream_link(struct media_ostream *ostream, struct media_istream *istream, struct media_event *ctx_event);

/*!
func    media_stream_unlink
\brief  unlink stream
\param  ostream[in]             the out-stream
\param  istream[in]             the in-stream
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return link result
        #0                      succeed
        #other                  the error code
*/
long media_stream_unlink(struct media_ostream *ostream, struct media_istream *istream, struct media_event *ctx_event);
/* ---------- media stream ---------------- */


/* ---------- media sample ---------------- */
/*!
func    media_sample_create
\brief  create media sample, after send must call media_sample_destroy to destroy.
\param  type[in]                the sample type
\param  data_size[in]           sample data size
\return the media sample
        #NULL                   failed
        #other                  the sample
*/
struct media_sample* media_sample_create(struct media_type *type, unsigned long data_size);

/*!
func    media_sample_destroy
\brief  destroy media sample
\param  sample[in]              the sample
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long media_sample_destroy(struct media_sample *sample);

/*!
func    media_sample_write_directly
\brief  write media sample directly into istream(can to without linked/ostream.)
\param  istream[in]             the input-stream
\param  sample[in]              the sample
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return write result
        #0                      succeed
        #other                  the error code
*/
long media_sample_write_directly(struct media_istream *istream, struct media_sample *sample, struct media_event *ctx_event);

/*!
func    media_sample_write
\brief  write media sample
\param  ostream[in]             loop to write sample into all valid linked istreams
\param  sample[in]              the sample
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return write result
        #0                      succeed
        #other                  the error code
*/
long media_sample_write(struct media_ostream *ostream, struct media_sample *sample, struct media_event *ctx_event);
/* ---------- media sample ---------------- */



/* ---------- media factory --------------- */
/*!
func    media_factory_create, will be auto destroy when parent module be destroy
\brief  create channel factory with share library file name
\param  mod[in]                 the media channel module, parent
\param  factory_file[in]        the factory file name
\param  entry[in]               the entity, can be NULL
                                if NULL get "media_factory_entry" proc address from factory_file(so/dll)
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return the factory
        #NULL                   failed
        #other                  the factory
*/
struct media_factory *media_factory_create(struct media_module    *mod,
                                           char                   *factory_file,
                                           media_factory_on_event entry,
                                           struct media_event     *ctx_event);

/*!
func    media_factory_destroy
\brief  destroy channel factory
\param  factory[in]             the factory
\param  ctx_event[in]           the context event, if not in media callback can be NULL
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long media_factory_destroy(struct media_factory *factory, struct media_event *ctx_event);
/* ---------- media factory --------------- */

/* ---------- media module --------------- */
/*!
func    media_module_create
\brief  create media channel module, finished should call media_module_destroy to free resource
\param  desc[in]                description, can be NULL
                                on channel create/destroy function, can change param here
                                #desc.conf the config data, multi lines
                                    format: <factory_name>.<param_name>
\return the module
        #NULL                   failed
        #other                  the module
*/
struct media_module *media_module_create(struct media_module_desc *desc);

/*!
func    media_module_destroy
\brief  destroy channel module
\param  mod[in]                 the module
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long media_module_destroy(struct media_module *mod);
/* ---------- media module --------------- */

/*!
func    media_search_channel_class
\brief  search media class by in/out media type
\param  mod[in]                 the module, can be NULL, if NULL search from factory
\param  factory[in]             the factory, can be NULL, if NULL search from whole module
\param  in_type[in]             the in type, such as "pack:video/h264/nal"
\param  out_type[in]            the out type, such as "pack:video/yuv/420p"
\return the media channel class
        #NULL                   not found
        #other                  the matched media channel class
*/
struct media_channel_class *media_search_channel_class(struct media_module  *mod,
                                                       struct media_factory *factory,
                                                       unsigned long        name_len,
                                                       char                 *name);
/*!
func    media_search_transform
\brief  search transform routine
\param  mod[in]                 the module
\param  from[in]                the src media type
\param  to[in]                  the dest media type
\param  stack_size[in]          the stack size, max transform class counts
\param  type_stack[in]          the type stack
\param  class_stack[in]         the media channel class stack
\return search result
        #>0                     transform routine counts
        #other                  error code
*/
long media_search_transform(struct media_module         *mod,
                            struct media_type           *from,
                            struct media_type           *to,
                            unsigned long               stack_size,
                            struct media_type           **type_stack,
                            struct media_channel_class  **class_stack);

/*!
func    media_name_get
\brief  get media-name from module, you can find all channel in name
\param  mod[in]                 the module
\param  name_len[in]            the name string length
\param  name[in]                the name string
\return search result
        #NULL                   not found
        #other                  the media name
*/
struct media_name *media_name_get(struct media_module   *mod,
                                  unsigned long         name_len,
                                  char                  *name);
/*!
func    media_dump
\brief  get media object refer dump info, include classes, channels
\param  mod[in]                 the module
\param  argc[in]                the arg counts
\param  argv[in]                the arg list, if(argc == 0) can be NULL if NULL default
                                --help      : get help
                                --filter    : filter string, if empty all items will be matched.
                                --type      : type list split by ","
                                    module          : output module
                                    factory         : output factory
                                    channel_class   : output channel class
                                    channel         : output channel
                                    ostream         : output ostream
                                    istream         : output istream
                                    all             : output all type
                                    default         : same as channel
\param  buf[in]                 the output buffer, can be NULL, if NULL output into file 
\param  start[in]               the start record no
\param  counts[in]              max output records counts
\param  size[in]                the buf size or max content size output to file
\return content length
        #<0                     error code
        #other                  content length
*/
long media_dump(struct media_module *mod,
                    unsigned long       argc,
                    char                *argv[],
                    char                *buf,
                    char                *file,
                    unsigned long       start,
                    unsigned long       counts,
                    unsigned long       size);


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__media_channel_h__) */
