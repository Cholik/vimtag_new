/*!
\file       mcanvas_api.h
\brief      mcanvas api unit
----history----
\author     chengzhiyong
\date       2013-02-23
\version    0.01
\desc       create

$Author: chengzhiyong $
*/
#if !defined(__mcanvas_api_h__)
#define __mcanvas_api_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct scale_context;

#define mcanvas_pic_flag_pos_mask               0x07
#define mcanvas_pic_flag_pos_origin             0x00
#define mcanvas_pic_flag_pos_center             0x01
#define mcanvas_pic_flag_pos_fit                0x02
#define mcanvas_pic_flag_pos_fill               0x03
#define mcanvas_pic_flag_pos_stretch            0x04
#define mcanvas_pic_flag_background_mask        0x180
#define mcanvas_pic_flag_background_none        0x000
#define mcanvas_pic_flag_background_normal      0x080
#define mcanvas_pic_flag_background_priority    0x100
#define mcanvas_pic_flag_pos_changed            0x200
#define mcanvas_pic_flag_data_changed           0x400

typedef struct mcanvas_range
{
    long left, top, width, height;
}_mcanvas_range;

#define mcanvas_pic_magic   *(long*)"mcvp   "
typedef struct mcanvas_pic
{
    char                    magic[sizeof(long)];
    struct
    {
        struct mcanvas      *owner;
        struct mcanvas_pic  *prev;
        struct mcanvas_pic  *next;
    }in_canvas;
    struct scale_context    *hold_ctx;
    unsigned long           ctx_inited;
    struct scale_context    *ctx;
    struct mcanvas_range    ctx_range;

    unsigned long           flag;

    unsigned long           buf_size;
    unsigned char           *buf;

    unsigned long           planers_counts;
    struct  
    {
        long                line_bytes;
        unsigned long       size;
        unsigned long       line_counts;
        unsigned char       *data;
    }planers[4];

    unsigned long           draw_counts;
}_mcanvas_pic;
#define mcanvas_pic_format_s        "%p{magic[%4.4s]"
#define mcanvas_pic_format(_pic)    (_pic), (_pic)?&(_pic)->magic[0]:0

typedef struct mcanvas_desc
{
    long                    small_pic_counts;       /* if 0 set as default:4 */
    long                    vertical_reverse;

    long                    width;
    long                    height;
    
    double                  aspect_tatio;
    struct
    {
        long                power_2;
        long                align;
        long                origin;
    }padding;
}_mcanvas_desc;
#define mcanvas_desc_format_s       "%p{width[%ld], height[%ld], aspect_tatio[%f], padding[{power_2[%ld], align[%ld], origin[%ld]}]}"
#define mcanvas_desc_format(_desc) (_desc), (_desc)?(_desc)->width:0, (_desc)?(_desc)->height:0,\
                                   ((_desc)?(_desc)->aspect_tatio:0.0), (_desc)?(_desc)->padding.power_2:0,\
                                   (_desc)?(_desc)->padding.align:0, (_desc)?(_desc)->padding.origin:0

#define mcanvas_magic           *(long*)"mcvs   "
typedef struct mcanvas
{
    char                    magic[sizeof(long)];
    struct {unsigned long len; char *data; } type;
    struct mcanvas_desc     desc;

    long                    width;
    long                    height;             /* include padding */
    long                    dynamic;            /*!< size is dyanmic */
    struct
    {
        long                left, top, width, height;
    }content;/* maybe not same with/height width when (padding_power_2 or padding_dividend) be setting */

    unsigned long           buf_size;
    unsigned char           *buf;

    long                    bgr_pix_size;

    unsigned long           planers_counts;
    struct  
    {
        long                line_bytes;
        long                line_bytes_out;
        unsigned long       size;
        unsigned long       line_counts;
        unsigned char       *data;
    }planers[4];
    
    struct
    {
        unsigned long       counts;
        struct mcanvas_pic  *list;
    }pics;
    long                    format_channge_counts;
    long                    draw_counts;
}_mcanvas;
#define mcanvas_format_s  "%p{magic[%4.4s], type[%s], width[%ld], height[%ld]}"
#define mcanvas_format(_canvas) (_canvas), (_canvas)?&(_canvas)->magic[0]:0, (_canvas)?(_canvas)->type.data:NULL, \
                            (_canvas)?(_canvas)->width:0, (_canvas)?(_canvas)->height:0

typedef struct mcanvas_pic_size_info
{
    unsigned long counts;
    struct  
    {
        unsigned long width, height;
    }max, min, average, background, canvass;
}_mcanvas_pic_size_info;

struct mcanvas *mcanvas_create(struct len_str *type, struct mcanvas_desc *desc);
long mcanvas_destroy(struct mcanvas *canvas);
long mcanvas_set(struct mcanvas *canvas, struct mcanvas_desc *desc);
long mcanvas_draw(struct mcanvas *canvas);
long mcanvas_pic_get_pos_type(struct len_str *clip/* can be NULL */, long default_clip);
long mcanvas_pic_get_pos(long type,/* mcanvas_pic_flag_pos_xxx */ long radians,
                      long pos_align, long size_align, 
                      struct mcanvas_range *src, struct mcanvas_range *canvas,
                      struct mcanvas_range *src_cut, struct mcanvas_range *canvas_dst/* [out] */);
struct mcanvas_pic *mcanvas_pic_create(struct mcanvas *canvas, unsigned long flag/* mcanvas_pic_flag_xxx*/);
long mcanvas_pic_destroy(struct mcanvas_pic *pic);
long mcanvas_pic_draw(struct mcanvas_pic *pic, struct scale_area *src);
long mcanvas_pic_query(struct mcanvas *canvas, struct mcanvas_pic_size_info *info);
long mcanvas_test_main(long argc, char *argv[]);
long mcanvs_update_pic_position( struct mcanvas_pic *pic, long position );
#if defined(__cplusplus)
}
#endif

#endif /* !defined(__mcanvas_api_h__) */


