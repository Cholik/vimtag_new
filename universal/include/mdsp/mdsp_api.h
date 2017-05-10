/*!
\file       mdsp_api.h
\brief      mining dsp(sound card, record/play) unit

 ----history----
\author     chengzhiyong
\date       2011-08-06
\version    0.01
\desc       create
*/

#if !defined(__mdsp_api_h__)
#define __mdsp_api_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

struct mdsp_device_ctx;
struct maud_process_desc; /* defined in maud_process/aud_process.h */

/*!\brief dsp device(sound card) info */
typedef struct mdsp_device_info
{
    long                            index;      /*!< device index */
    struct  
    {
        unsigned long               len;
        char                        *data;
    }name;                                      /*!< device name */
}_mdsp_device_info;

/*!\brief dsp device description */
typedef struct mdsp_device_desc
{
    long                            id;                     /*!< device id */
    char                            mod[4];                 /*!< open mode, "r":read, "w":write */
    long                            channels;               /*!< 0->default:1 */
    long                            sample_rate;            /*!< 0->default:16000 */
    long                            sample_bits;            /*!< 0->default:16bits    */
    long                            frame_samples;          /*!< 0->default:50ms  */
    long                            frame_counts;           /*!< 0->default:(2000ms/frame_ms), at least:2    */
    long                            frame_counts_delay;     /*!< 0->default:(0) frame-counts delay to play, just for play */
    
    struct
    {
        unsigned long               flag;       /*!< audio process flag */
        struct
        {
            unsigned long           len;
            char                    *data;      /*!< audio process session name */
        }session, debug_path;
        struct maud_process_desc    *detail;    /*!< can be NULL, if not NULL use it and ignore process.flag,
                                                     procss.session, process.debug_path params */
    }process;
}_mdsp_device_desc;

#define mdsp_device_magic            (*(long*)"dspd    ")
#define mdsp_device_magic_free       (*(long*)"DSPD    ")
typedef struct mdsp_device
{
    char                             magic[sizeof(long)];/*!< magic */
    struct mdsp_device_desc          desc;               /*!< device description */
    struct mdsp_device_info          *info;              /*!< device info */
    struct mdsp_device_ctx           *ctx;               /* context */
}_mdsp_device;

#define mdsp_device_format_s     "%p{index[%ld], mode[%0.4s], name[%s]}"
#define mdsp_device_format(_dev) (_dev), ((_dev) && (mdsp_device_magic == *(long*)&(_dev)->magic))?(_dev)->desc.id:0,\
                                ((_dev) && (mdsp_device_magic == *(long*)&(_dev)->magic))?&(_dev)->desc.mod[0]:0,\
                                ((_dev) && (mdsp_device_magic == *(long*)&(_dev)->magic) && (_dev)->info && (_dev)->info->name.len)?(_dev)->info->name.data:NULL

/*!
func    mdsp_get_counts
\brief  get dsp device counts in system
\return counts
        #>=0                    dsp device counts in system
        #other                  error code
*/
long mdsp_get_counts();

/*!
func    mdsp_info_query
\brief  query dsp device description information, the result should
        call mdsp_info_free after used.
\param  dev_index[in]           the device index, from 0
\return the information of the device
        #NULL                   failed
        #other                  the information
*/
struct mdsp_device_info *mdsp_info_query(long dev_index);

/*!
func    mdsp_info_free
\brief  free dsp info return be mdsp_info_query
\param  info[in]                the device information
\return free result
        #0                      succeed
        #other                  error code
*/
long mdsp_info_free(struct mdsp_device_info *info);

/*!
func    mdsp_create
\brief  free dsp info return be mdsp_info_query
\param  info[in]                the device information
\return free result
        #0                      succeed
        #other                  error code
*/
struct mdsp_device *mdsp_create(struct mdsp_device_desc *desc);

/*!
func    mdsp_destroy
\brief  destroy dsp device information
\param  dev[in]                 the device object 
\return destroy result
        #0                      succeed
        #other                  error code
*/
long mdsp_destroy(struct mdsp_device *dev);

#define mdsp_ctrl_method_volum_get   "volum.get"         /* param: unsigned long* */
#define mdsp_ctrl_method_volum_set   "volum.set"         /* param: unsigned long* */
/*!
func    mdsp_ctrl
\brief  ctrl device
\param  dev[in]                 the device object 
\param  method_len[in]          the method length
\param  method[in]              the method, refer dps_ctrl_method_xxx
\param  param[in]               the ctrl method
\return ctrl result
        #0                      succeed
        #other                  error code
*/
long mdsp_ctrl(struct mdsp_device *dev, unsigned long method_len, char *method, void *param);

/*!
func    mdsp_read
\brief  read a frame from dsp device, just for 'r' mod.
        if have not enough data in buffer, will block to data arrived.
\param  dev[in]                 the device object 
\param  size[in]                the frame data buffer size
\param  buf[out]                the frame data buffer
\param  tick[out]               the frame arrived tick, can be NULL, if NULL ignore
\return read result
        #0                      succeed
        #other                  error code
*/
long mdsp_read(struct mdsp_device *dev, unsigned long size, unsigned char *buf, unsigned long *tick);

/*!
func    mdsp_write
\brief  write a frame to dsp device to play, just for 'w' mode
        if write queue is full will block
\param  dev[in]                 the device object 
\param  len[in]                 the frame data size
\param  data[in]                the frame data buffer
\param  tick[in]                the frame arrived tick
\return write result
        #0                      succeed
        #other                  error code
*/
long mdsp_write(struct mdsp_device *dev, unsigned long len, unsigned char *data, unsigned long tick);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__mdsp_api_h__) */

