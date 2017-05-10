/*!
\file       yuv-brg.h
\brief      yuv brg convert unit

 ----history----
\author     chengzhiyong
\date       2011-07-10
\version    0.01
\desc       create
*/
#if !defined(__yuv_rgb_h__)
#define __yuv_rgb_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

long scale__do_bgr24_2_yuv420p(struct scale_context *ctx);
long scale__do_bgra_2_yuv420p(struct scale_context *ctx);
long scale__do_yuv42xsp_2_yuv420p(struct scale_context *ctx);
long scale__do_yuv42xsp_2_yuv420p_zoom(struct scale_context *ctx);
long scale__do_yuv42xsp_2_yuv420p_reverse(struct scale_context *ctx);
long scale__do_yuv42p_2_yuv42xsp_zoom(struct scale_context *ctx);
long scale__do_yuv420p_2_yuv420p(struct scale_context *ctx);
long scale__do_yuv420p_2_yuv420p_zoom(struct scale_context *ctx);
long scale__do_yuvyv12_2_yuv420p(struct scale_context *ctx);
long scale__do_yxyx_2_yuv420p(struct scale_context *ctx);
long scale__do_bgr24_2_bgr24(struct scale_context *ctx);
long scale__do_yuv420p_2_bgr24(struct scale_context *ctx);
long scale__do_yuv420p_2_rgb24(struct scale_context *ctx);
long scale__do_yuv420p_2_bgr565(struct scale_context *ctx);
long scale__do_yuv420p_2_rgba32(struct scale_context *ctx);
long scale__do_yuv420p_2_bgra32(struct scale_context *ctx);
long scale__do_yuv420p_2_bgrx_zoom(struct scale_context  *ctx);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__yuv_rgb_h__) */
