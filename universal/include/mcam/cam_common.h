/*!
\file       cam_common.h
\brief      camera unit

 ----history----
\author     chengzhiyong
\date       2011-07-06
\version    0.01
\desc       create
*/
#if !defined(__cam_common_h__)
#define __cam_common_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

/*!\brief camera video format description */
typedef struct cam_video_format_desc
{
    struct  
    {
        unsigned long               len;
        char                        *data;
    }type;                                          /*!< type name, yuv/420p,rgb/24 ... */

    unsigned long                   width;          /*!< video width */
    unsigned long                   height;         /*!< video height */
    unsigned long                   fps;            /*!< frames per seconds */
}_cam_video_foramt_desc;

struct cam_video_format_ctx;
/*!\brief camera video format */
typedef struct cam_video_format
{
    struct cam_video_format_desc    desc;           /*!< desc */       
    struct cam_video_format_ctx     *ctx;           /*!< user don't changed this value */
}_cam_video_format;

/*!\brief camera device info */
typedef struct cam_device_info
{
    long                            index;          /*!< camera index */
    struct  
    {
        unsigned long               len;
        char                        *data;
    }name;                                          /*!< camera name */
    struct  
    {
        unsigned long               counts;
        struct cam_video_format     *list;
    }capability;                                    /*!< capability format list */
}_cam_device_info;

/*!\brief camera video packet */
typedef struct cam_video_pack
{
    struct  
    {
        unsigned long       len;
        char                *data;
    }type;                                          /*!< pack type. yuv/420p, yuv/422sp, yuv/420sp, bgr/24 */

    /* planners */
    unsigned long           planers_counts;         /*!< planers counts */
    struct  
    {
        unsigned long       size;
        unsigned long       line_counts;
        long                line_bytes;
        unsigned char       *data;
    }planers[4];                                   /*!< planers */

    /* rect, dst just support left:0,top:0,width:src->width,height:src->height now */
    long                    width;                      /*!< pixel width */
    long                    height;                     /*!< pixel height */

    struct cam_video_format *format;                    /*!< camera video format */
}_cam_video_pack;
#define cam_video_pack_format_s         "%p{type[%s], width[%ld], height[%ld]}"
#define cam_video_pack_format(_pack)    (_pack), ((_pack) && (_pack)->type.len)?(_pack)->type.data:NULL, (_pack)?(_pack)->width:0, (_pack)?(_pack)->height:0
/*!
func    cam_on_input
\brief  camera video frame input callback function
\param  dev[in]                 the camera device
\param  pack[in]                the video pack be captured
\param  refer[in]               the refer data be set when start
\return input result
        #0                      succeed
        #other                  error code
*/
struct cam_device;
typedef long (*cam_on_input)(struct cam_device *dev, struct cam_video_pack *pack, void *refer);

struct cam_device_ctx;
#define cam_device_magic            (*(long*)"camd    ")
#define cam_device_magic_free       (*(long*)"CAMD    ")
/*!\brief camera device */
typedef struct cam_device
{
    char                            magic[sizeof(long)];    /*!< magic to check device object is invalid */
    long                            id;                 /*!< device id(index from 0) */
    struct cam_device_info          *info;              /*!< device information, include supported formats */

    unsigned long                   status;             /*!< status */

    void                            *refer;             /* runtime data */
    cam_on_input                    on_input;           /* on input callback routine */
    struct cam_video_format         *active_format;     /* active format */
    struct cam_device_ctx           *ctx;               /* context */
}_cam_device;
#define cam_device_format_s     "%p{%ld}"
#define cam_device_format(_cam) (_cam), ((_cam) && (cam_device_magic == *(long*)&(_cam)->magic))?(_cam)->id:0

#define cam_ctrl_method_open        "open"              /* cam_ctrl_method_open_param */
#define cam_ctrl_method_close       "close"         /* ignore, param can be NULL */
typedef struct cam_ctrl_method_open_param
{
    struct cam_video_format         *format;
    cam_on_input                    on_input;
    void                            *refer;
}_cam_ctrl_method_open_param;

/*!
func    cam_get_counts
\brief  get camera counts in system
\return counts
        #>=0                    camera device counts in system
        #other                  error code
*/
long cam_get_counts();

/*!
func    cam_create
\brief  open camera device, just open device refer info,
        really open device and start input data by cam_ctrl
\param  dev_index[in]           the device index
\return camera device object
        #NULL                   failed
        #other                  the camera device object be opened
*/
struct cam_device *cam_create(long dev_index);

/*!
func    cam_destroy
\brief  destroy camera device return by cam_create
\param  dev[in]                 the device object
\return destroy result
        #0                      succeed
        #other                  the camera device object be opened
*/
long cam_destroy(struct cam_device *dev);

/*!
func    cam_ctrl
\brief  control camera
\param  dev[in]                 the device object
\param  method_len[in]          the method length
\param  method[in]              the camera control method, cam_ctrl_method_xxx
\param  param[in]               the control param, cam_ctrl_method_xxxx_param
\return destroy result
        #0                      succeed
        #other                  the camera device object be opened
*/
long cam_ctrl(struct cam_device *dev, unsigned long method_len, char *method, void *param);

/*!
func    cam_get_best_format
\brief  get best matched capture format in supported list
\param  check_counts[in]        supported format counts
\param  check_formats[in]       supported formats list array
\param  target_counts[in]       the target video formats list counts
\param  target_formats[in]      the target video formats list
\return best matched index
        #>=0                    best matched format index in check_formats
        #other                  error code
*/
long cam_get_best_format(unsigned long check_counts, struct cam_video_format *check_formats,
                         unsigned long target_counts, struct cam_video_format_desc *target_formats);


#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__cam_common_h__) */
