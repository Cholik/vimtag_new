/*!
\file       pack_file.h
\brief      pack file serieal reference utils

 ----history----
\author     chengzhiyong
\date       2012-03-07
\version    0.01
\desc       create
*/
#if !defined(__pack_file_h__)
#define __pack_file_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct pack_def;
struct pack_serial;

#define pack_file_err_base                  -1
#define pack_file_err_invalid_param         (pack_file_err_base - 0)
#define pack_file_err_alloc_fail            (pack_file_err_base - 1)
#define pack_file_err_json_decode_fail      (pack_file_err_base - 2)
#define pack_file_err_type_incompatible     (pack_file_err_base - 3)

/*!
func    pack_file_load_xml_text
\brief  load data from xml text
\param  def[in]                 the pack definition
\param  node_name_len[in]       the node name length, can be 0, if 0 import def->name as node_name
\param  node_name[in]           the node name, can be NULL, if NULL import def->name as node_name
\param  text_len[in]            the json text length
\param  text[in]                the json text, {...} or xxx({...})
\return the struct data, should call pack_unload to free
        #NULL                   failed
        #other                  the struct data
*/
void *pack_file_load_xml_text(struct pack_def *def, unsigned long node_name_len, char *node_name, unsigned long text_len, char *text);

/*!
func    pack_file_load_xml
\brief  load data from xml file
\param  def[in]                 the pack definition
\param  node_name_len[in]       the node name length, can be 0, if 0 import def->name as node_name
\param  node_name[in]           the node name, can be NULL, if NULL import def->name as node_name
\param  file[in]                the xml file name
\return the struct data, should call pack_file_unload to free
        #NULL                   failed
        #other                  the struct data
*/
void *pack_file_load_xml(struct pack_def *def, unsigned long node_name_len, char *node_name, char *file);

/*!
func    pack_file_load_xml2
\brief  load data from xml file with definition string
\param  def_xml[in]             the definition xml
\param  def_name[in]            the name of the pack definition
\param  node_name[in]           the node name, can be NULL, if NULL import def->name as node_name
\param  file[in]                the xml file name
\return the struct data, should call pack_file_unload to free
        #NULL                   failed
        #other                  the struct data
*/
void *pack_file_load_xml2(char *def_xml, char *def_name, char *node_name, char *file);

/*!
func    pack_file_load_json_text
\brief  load data from json text
\param  def[in]                 the pack definition
\param  text_len[in]            the json text length
\param  text[in]                the json text, {...} or xxx({...})
\return the struct data, should call pack_file_unload to free
        #NULL                   failed
        #other                  the struct data
*/
void *pack_file_load_json_text(struct pack_def *def, unsigned long text_len, char *text);

/*!
func    pack_file_load_json
\brief  load data from json file
\param  def[in]                 the pack definition
\param  file[in]                the json file name
\return the struct data, should call pack_file_unload to free
        #NULL                   failed
        #other                  the struct data
*/
void *pack_file_load_json(struct pack_def *def, char *file);

/*!
func    pack_file_load_json2
\brief  load data from json file with definition string
\param  def_xml[in]             the definition xml
\param  def_name[in]            the name of the pack definition
\param  file[in]                the json file name
\return the struct data, should call pack_file_unload to free
        #NULL                   failed
        #other                  the struct data
*/
void *pack_file_load_json2(char *def_xml, char *def_name, char *file);

/*!
func    pack_file_save_xml
\brief  save data as xml file
\param  def[in]                 the pack definition
\param  node_name_len[in]       the node name length, can be 0, if 0 export def->name as node_name
\param  node_name[in]           the node name, can be NULL, if NULL export def->name as node_name
\param  data[in]                the data
\param  file[in]                the xml file name
\return save result
        #0                      succeed
        #other                  error code
*/
long pack_file_save_xml(struct pack_def *def, unsigned long node_name_len, char *node_name, void *data, char *file);

/*!
func    pack_file_save_xml2
\brief  save data to xml file
\param  def_xml[in]             the definition xml
\param  def_name[in]            the name of the pack definition
\param  node_name[in]           the node name, can be NULL, if NULL export def->name as node_name
\param  data[in]                the data
\param  file[in]                the xml file name
\return save result
        #0                      succeed
        #other                  error code
*/
long pack_file_save_xml2(char *def_xml, char *def_name, char *node_name, void *data, char *file);

/*!
func    pack_file_save_json
\brief  save data as json file
\param  def[in]                 the pack definition
\param  data[in]                the data
\param  file[in]                the xml file name
\return save result
        #0                      succeed
        #other                  error code
*/
long pack_file_save_json(struct pack_def *def, void *data, char *file);

/*!
func    pack_file_save_json2
\brief  save data to json file
\param  def_xml[in]             the definition xml
\param  def_name[in]            the name of the pack definition
\param  data[in]                the data
\param  file[in]                the xml file name
\return save result
        #0                      succeed
        #other                  error code
*/
long pack_file_save_json2(char *def_xml, char *def_name, void *data, char *file);

#define pack_file_load_serial_pack_flag_ignore_typename  0x01
/*!
func    pack_file_load_serial_pack
\brief  load data from serial pack with two version
\param  def[in]                 the dst def
\param  try_def[in]             try def, maybe a old version of def
\param  len[in]                 the serial pack data length
\param  data[in]                the serial pack data, should match def or try-def
\param  flag[in]                the flag, refer pack_file_load_serial_pack_flag_ignore_typename
\param  pack[out]               the pack serial info
\return convert result
        #NULL                   failed
        #other                  if(ret && (ret != pack.data)) should pack_file_unload(ret)
                                maybe return as pack.data if def-matched def
*/
void *pack_file_load_serial_pack(struct pack_def *def, struct pack_def    *try_def,
                                 unsigned long   len,  unsigned char      *data,
                                 unsigned long   flag, struct pack_serial *pack);

/*!
func    pack_file_json_convert
\brief  convert json to new json, just for def's field name restruct.
\param  def[in]                 the pack def of the src json text
\param  json_len[in]            the length of the src json text
\param  json[in]                the json text
\param  to_def[in]              the pack def of the dst json
\param  buf_size[in]            the buffer size
\param  buf[in/out]             the buffer
\param  loose_compatible[in]    loose type compatible flag, 
                                if true (int32_t == uint32_t) else must full same.
\return new json text length
        #0                      succeed
        #other                  the error code
*/
long pack_file_json_convert(struct pack_def *def, unsigned long json_len, char *json,
                            struct pack_def *to_def, unsigned long buf_size, char *buf,
                            long            loose_compatible);

/*!
func    pack_file_unload
\brief  unload data
\param  data[in]                the data return by pack_file_load_xxx
\return unload result
        #0                      succeed
        #other                  the error code
*/
long pack_file_unload(void *data);

long pack_file_test_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__pack_file_h__) */


