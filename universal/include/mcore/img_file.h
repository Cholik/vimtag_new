/*!
\file       img_file.h
\brief      image file foremat unit

 ----history----
\author     chengzhiyong
\date       2008-11-13
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: img_file.h,v 1.2 2008-11-14 02:52:05 chengzhiyong Exp $
*/
#if !defined(__img_file_h__)
#define __img_file_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

typedef struct img_info
{
    struct{unsigned long len; char *data;}type;/* type, PNG, BMP, JPEG */ 
    unsigned long   width;	/* width pixels */ 
    unsigned long   height;	/* height pixels */ 
    struct{unsigned long len; char *data;}mime;/* mime */
}_img_info;

/*!
func    img_get_info
\brief  get image file information
\param  data[in]                the image file data
\param  data_size[in]           the data size
\param  info[out]               the image information
\return get result
        #0                      succeed
        #other                  the error code
*/
long img_get_info(void *data, unsigned long size, struct img_info *info);

/*!
func    img_rgb_2_yuv420
\brief  convert rgb data to yuv420 stream
\param  rgb[in]                 the rgb data
\param  width_bytes[out]        the width bytes length
\param  width[in]               image width, must 2x
\param  height[in]              image height, must 2x
\param  yuv[out]                yuv out buffer, size must enough be width * height * 3 /2 bytes
\return result
        #0                      succeed
        #other                  error code
*/
long img_rgb_2_yuv420(unsigned char *rgb, long width_bytes, 
                      unsigned long width, unsigned long height,
                      unsigned char *yuv);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__img_file_h__) */
