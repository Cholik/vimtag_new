#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

#include "mcore/string_ex.h"

/*!
func    compress_img_to_jpg_file
\brief  compress img to jpg , and save to sfile
\param  file_path [in]          the img file you would read
\param  out_path [in]           save file path
\param  gray_scale [in]         if 0: not gray scale, and 1 ,change to gray img
\param  is_resize [in]          if 0: not resize    and 1, resize the img
\return result 
        #0                      ok
        #other                  failed
*/
long mimage_compress_to_jpg_file(   char         *file_path,
                                    char         *out_path,
                                    long         gray_scale,
                                    long         is_resize,
                                    unsigned long max_width ,
                                    unsigned long max_height );


/*!
func    compress_img_to_jpg_file
\brief  compress img to jpg , and save to sfile
\param  data [in]               the img file data
\param  size [in]               data size
\param  img_type [in]           if 0: not gray scale, and 1 ,change to gray img
\param  is_resize [in]          if 0: not resize;and 1, resize the img
\param  out_data [in]           out data memory pointer, should malloc enough memory
\param  out_size [out]          out data size
\return result 
        #0                      ok
        #other                  failed
*/
long mimage_compress_to_jpg (unsigned char *data,
                             unsigned long size,
                             char          *img_type,
                             unsigned long len,
                             long          gray_scale,
                             long          is_resize,
                             unsigned char *out_data, 
                             long          *out_size,
                             unsigned long max_width,
                             unsigned long max_height);

#define img_convert_flag_gray_scale             0x01
#define img_convert_flag_bg_transparent         0x02    /* let background transparent if support, such as PNG */
#define img_convert_flag_strech                 0x04    /* auto strech to widht/height */
#define img_convert_flag_keep_range_zoom_out    0x80    /* zoom and keep width/height range */
typedef struct img_convert_param
{
    unsigned long       flag;       /*!< the flag, refer img_compress_flag_xxxx */
    unsigned long       width;      /*!< width */
    unsigned long       height;     /*!< height */
    unsigned long       quality;    /*!< 0means:default, [N]% */
}_img_convert_param;
/*!
func    img_data_convert
\brief  convert image from special format to special format,
        should use img_data_destroy to free memory resource.
\param  in_mime[in]             input data mime, such as "image/bmp"
\param  in_data[in]             the input image data
\param  out_mime[out]           the output data mime
\param  param[in]               the convert param, can be NULL, if NULL use default.
\param  out_data[out]           the output data, need call img_data_free to release
\return convert result
        #0                      succeed
        #other                  the error code
*/
long img_data_convert(struct len_str *in_mime,  struct len_str *in_data,
                      struct len_str *out_mime, struct img_convert_param *param,
                      struct len_str *out_data);

/*!
func    img_data_free
\brief  free image data
\param  data[in]                the image data return from img_data_convert 
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long img_data_free(struct len_str *data);

/*!
func    img_data_load_from_clipboard
\brief  load image data from clipboard
\param  out_mime[in]            the output mime, can be NULL, if NULL output bmp
\param  out_data[out]           the output data, need call img_data_free to release
\return image data 
        #NULL                   compress failed
        #other                  the compressed data
*/
long img_data_load_from_clipboard(struct len_str *out_mime, struct len_str *out_data);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */
