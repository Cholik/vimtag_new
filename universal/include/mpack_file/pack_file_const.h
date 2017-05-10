/*!
\file       pack_file.h
\brief      pack file serieal reference utils

 ----history----
\author     chengzhiyong
\date       2012-03-07
\version    0.01
\desc       create
*/

#if !defined(__pack_file_const_h__)
#define __pack_file_const_h__

#if defined(__cplusplus)
extern "C" {
#endif

#include <stdio.h>

struct json_object;
struct pack_def;

/*!
func    pack_file_json_export_as_http_param
\brief  export json object as http param
\param  root[in]                the json node
\param  convert_char[in]        the convert char, normal is '%', mining used '_'
\param  name_split[in]          the name split char, normal is '&', mining used '-'
\param  value_split[in]         the value split char, normal is '=', mining used '-'
\param  prefix_len[in]          the prefix len, normal is 0, mining used "d" for data
\param  prefix[in]              the preifx, nrmal is NULL, mining used "d" for data
\param  buf_size[in]            the buffer size
\param  buf[in/out]             the buffer
\return save result
        #<0                     error code
        #other                  content length
*/
long pack_file_json_export_as_http_param(struct json_object *root,
                                         char convert_char, char name_split, char value_split,
                                         unsigned long prefix_len, char *prefix,
                                         unsigned long buf_size, char *buf);

/*!
func    pack_file_json_export_as_http_url
\brief  export json object as http url 
\param  srv_len[in]             the srv length
\param  srv[in]                 the srv string, can be NULL, if NULL means "/"
\param  to_len[in]              the dst component's name or id string length
\param  to[in]                  the dst component's name or id string, can be NULL, if NULL means directly to "srv"
\param  to_handle[in]           the to handle, if 0 ignore
\param  qid_len[in]             the qid length
\param  qid[in]                 the qid, if 0 ignore
\param  from_handle[in]         the from handle, if 0 ignore
\param  type_len[in]            the type string length
\param  type[in]                the type string
\param  data[in]                the json object, can be NULL, 
\param  is_static[in]           is static url, 
                                0: static(mining encoding with --_), 
                                1:dynamic stand normal url encoding with &=%
\param  buf_size[in]            the buffer size
\param  buf[in/out]             the buffer
\return save result
        #<0                     error code
        #other                  content length
*/
long pack_file_json_export_as_http_url(unsigned long srv_len, char *srv, 
                                       unsigned long to_len, char *to, long to_handle,
                                       unsigned long qid_len, char *qid, long from_handle,
                                       unsigned long type_len, char *type, struct json_object *data,
                                       long is_static,
                                       unsigned long buf_size, char *buf);

/*!
func    pack_file_json_export_as_const
\brief  export json object as const code file
\param  root[in]                the json node
\param  name_prefix[in]         the name prefix
\param  header_len[in]          the header content length
\param  header[in]              the header, can be NULL , if NULL ignore
\param  footer_len[in]          the footer content length
\param  footer[in]              the footer, can be NULL , if NULL ignore
\param  file[in]                the dst file name
\param  type[in]                the type, "java"|"c"|"json"|"sh"
\param  append[in]              is append, if 0 create new file, other keep old content
\return save result
        #0                      succeed
        #other                  error code
*/
long pack_file_json_export_as_const(struct json_object *root, char *name_prefix, 
                                    unsigned long header_len, char *header,
                                    unsigned long footer_len, char *footer,
                                    char *file, char *type/* java,c,json,sh */, long append);

/*!
func    pack_file_export_as_const
\brief  export pack-def refer data as const code file
\param  def[in]                 the pack-def
\param  data[in]                the pack data
\param  name_prefix[in]         the name prefix
\param  file[in]                the dst file name
\param  type[in]                the type, "java"|"c"|"json"|"sh"
\return save result
        #0                      succeed
        #other                  error code
*/
long pack_file_export_as_const(struct pack_def *def, void *data, char *name_prefix, char *file, char *type);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__pack_file_const_h__) */



