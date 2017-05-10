/*!
\file       pic scale unit
\brief      pic scale unit

 ----history----
\author     chengzhiyong
\date       2011-07-06
\version    0.01
\desc       create
*/

#if !defined(__scale_h__)
#define __scale_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

struct scale_context;
typedef long (*scale_func)(struct scale_context *ctx);
#define scale_context_magic         (*(long*)"scal   ")

#if !defined(scale_area_type_defined)
#define scale_area_type_defined
typedef struct scale_area
{
    struct  
    {
        unsigned long   len;
        char            *data;
    }type;/* yuv/420p, yuv/422sp, yuv/420sp, bgr/24 */

    unsigned long           planers_counts;         /*!< planers counts */
    struct  
    {
        long                line_bytes;
        unsigned char       *data;
    }planers[4];                                   /*!< planers */

    /* rect, dst just support left:0,top:0,width:src->width,height:src->height now */
    long                left;
    long                top;
    long                width;
    long                height; 
}_scale_area;
#endif

#define scale_zoom_bits 8

typedef struct scale_context
{
    char                    magic[sizeof(long)];
    struct scale_area       src, dst;       /*!< scale areas */
    long                    radians;        /*!< yuv4202p->yuv420:support 0|90, other: only 0 */

    struct
    {
        struct  
        {
            struct
            {
                unsigned long *indexs;
                unsigned long *weights;
            }left, top, left_half, top_half/* [counts] = (counts + 1) */;
            void            *buf;
        }zoom;
        long                value1;
        long                value2;
        scale_func          do_scale;   /*!< the routine to do scale */
    }_cache;
}_scale_context;

long scale_init(struct scale_context *ctx);  /* init scale context */
long scale_uninit(struct scale_context *ctx);    /* clear resource after use finished. */
long scale_transform(struct scale_context *ctx);/* do scale */

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__scale_h__) */

