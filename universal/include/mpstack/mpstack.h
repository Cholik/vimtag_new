/*
\file		mpstack.h
\brief		mining protocol stack for ARM/embed and windows system.
            provide by mining technology
 ----history----
\author     chengzhiyong
\date       2011-03-09
\version    0.01
\desc       create

$Author: chengzhiyong $
*/

#if !defined(__mpstack_h__)
#define  __mpstack_h__

#if defined(__cplusplus)
extern "C" {
#endif

#include "mpstack_type.h"

#define mpstack_max_size        1400        /* max pack size, change size here */
#define mpstack_max_field_len   mpstack_max_size        
typedef struct mpstack_field                /* field */
{
    struct  
    {
        struct mpstack_field    *next;
        struct mpstack_field    *prev;
        uint32_t                index;
    }in_msg;
    struct
    {
        uint32_t                len;
        char                    *data;
    }value;                                 /* string value */
}_mpstack_field;

typedef struct mpstack_msg                  /* message */
{
    struct  
    {
        struct mpstack_msg      *next;
        struct mpstack_msg      *prev;
        unsigned int            index;
    }in_pack;
    uint32_t                    type;       /* msg type */
    struct  
    {
        uint32_t                counts;     /* fields counts */
        struct mpstack_field    *list;
        struct mpstack_field    *fetch_index;
    }fields;
}_mpstack_msg;

typedef struct mpstack_pack                 /* pack */
{
    struct  
    {
        uint32_t                len;
        char                    *data;
    }from;                                  /* from string */
    uint32_t                    trans_id;   /* trans id */
    struct
    {
        uint32_t                counts;     /* message counts */
        struct mpstack_msg      *list;
        struct mpstack_msg      *fetch_index;
    }msgs;
}_mpstack_pack;

#define mpstack_field_type_string   "S"
#define mpstack_field_type_int      "I"
#define mpstack_field_type_uint     "U"

/*!
func    mpstack_create
\brief  create pack, for sender, used to build send out packet.
        after encode and send out, please use mpstack_create to free resource whole pack
\return the pack
        #NULL                   failed, should be have not enough memory
        #other                  the pack pointer
*/
struct mpstack_pack *mpstack_create(void);

/*!
func    mpstack_destroy
\brief  destroy pack, used to free pack resource,
        both for mpstack_create and mpstack_decode
\param  pack[in]                the pack pointer, can not be NULL
\return destroy result
        #0                      succeed
        #other                  error code, should be invalid pack param
*/
int32_t mpstack_destroy(struct mpstack_pack *pack);

/*!
func    mpstack_set_from
\brief  set from
\param  pack[in]                the pack pointer, can not be NULL
\param  from_len[in]            the from length
\param  from[in]                the from string start pointer
\return destroy result
        #0                      succeed
        #other                  error code, should be invalid pack param
*/
int32_t mpstack_set_from(struct mpstack_pack *pack, uint32_t from_len, char *from);

/*!
func    mpstack_add_msg
\brief  add a message with msg-type value into pack
\param  pack[in]                the pack pointer, can not be NULL
\param  type[in]                the message type value
\return the message
        #NULL                   failed, should be have not enough memory or pack is invalid pointer
        #other                  the message be created, then can add field into this message
*/
struct mpstack_msg  *mpstack_add_msg(struct mpstack_pack *pack, uint32_t type);

/*!
func    mpstack_get_msg
\brief  get message from pack with message index
\param  pack[in]                the pack pointer, can not be NULL
\param  index[in]               the message index NO. (from 0, ++ to (pack->msgs.counts - 1))
\return the message
        #NULL                   failed, pack is invalid pointer or index NO overflow
        #other                  the message be found, used to get field.
*/
struct mpstack_msg  *mpstack_get_msg(struct mpstack_pack *pack, uint32_t index);

/*!
func    mpstack_add_field
\brief  add string field into message
\param  msg[in]                 the message pointer, can not be NULL
                                return by mpstack_add_msg()
\param  value_len[in]           the string value length, if 0, add a empty field.
\param  value[in]               the string value pointer
                                  if (value_len == 0) can be NULL
                                  other must have a valid pointer
\return the field
        #NULL                   failed, pack is invalid pointer or invalid value param or memory overflow
        #other                  the field be created
*/
struct mpstack_field *mpstack_add_field(struct mpstack_msg *msg, uint32_t value_len, char *value);

/*!
func    mpstack_get_field
\brief  get field from message with field-index NOs
\param  msg[in]                 the message pointer, can not be NULL
                                return by mpstack_get_msg()
\param  index[in]               the field index NO. (from 0, ++ to (msg->field.counts - 1))
\return the field
        #NULL                   failed, pack is invalid pointer or index NO overflow
        #other                  the field be found. can get string value by field->value
*/
struct mpstack_field *mpstack_get_field(struct mpstack_msg *msg, uint32_t index);

/*!
func    mpstack_get_int_field
\brief  get signed int value from message with field-index NO
\param  msg[in]                 the message pointer, can not be NULL
                                return by mpstack_get_msg()
\param  index[in]               the field index NO. (from 0, ++ to (msg->field.counts - 1))
\param  value[out]              the value output pointer, can not be NULL
\return get result
        #0                      succeed, and value be setted
        #other                  the error no, should be invalid param or field-index NO not exist.
*/
int32_t mpstack_get_int_field(struct mpstack_msg *msg, uint32_t index, int32_t *value/* out */);

/*!
func    mpstack_add_int_field
\brief  add a signed int value field into message
\param  msg[in]                 the message pointer, can not be NULL
                                return by mpstack_add_msg()
\param  value[in]               the value, this value will be auto convert as hex-int string
                                then add as string field.
                                recver can use mpstack_get_int_field() to get this int value
\return get result
        #0                      succeed, and value be set
        #other                  the error no, should be invalid param or field-index NO not exist.
*/
struct mpstack_field *mpstack_add_int_field(struct mpstack_msg *msg, int32_t value);

/*!
func    mpstack_get_uint_field
\brief  get unsigned int value from message with field-index NO
\param  msg[in]                 the message pointer return by mpstack_get_msg(), can not be NULL
\param  index[in]               the field index NO. (from 0, ++ to (msg->field.counts - 1))
\param  value[out]              the value output pointer, can not be NULL
\return get result
        #0                      succeed, and value be setted
        #other                  the error no, should be invalid param or field-index NO not exist.
*/
int32_t mpstack_get_uint_field(struct mpstack_msg *msg, uint32_t index, uint32_t *value/* out */);

/*!
func    mpstack_add_uint_field
\brief  add a unsigned int value field into message
\param  msg[in]                 the message pointer, can not be NULL
                                return by mpstack_add_msg()
\param  value[in]               the value, this value will be auto convert as hex-int string
                                then add as string field.
                                recver can use mpstack_get_uint_field() to get this int value
\return get result
        #0                      succeed, and value be setted
        #other                  the error no, should be invalid param or field-index NO not exist.
*/
struct mpstack_field *mpstack_add_uint_field(struct mpstack_msg *msg, uint32_t value);

/*!
func    mpstack_decode
\brief  decode pack struct from a bytes array data recved from network.
\param  len[in]                 the data length, must > 0
\param  data[in]                the data start pointer, can not be NULL
\return the pack
        #NULL                   failed, should be invalid param, or incorrect data content
        #other                  the pack be decode
*/
struct mpstack_pack *mpstack_decode(uint32_t len, char *data);

/*!
func    mpstack_encode
\brief  encode a pack struct as bytes array data, then can send on network
\param  pack[in]                the pack, can not be NULL
\param  buf_size[in]            the buffer size, must > 0 and large enough
\param  buf[out]                the buffer start pointer, can not be NULL
\return the result
        #0                      succeed
        #other                  the error code, buf overflow or invalid param.
*/
int32_t mpstack_encode(struct mpstack_pack *pack, uint32_t buf_size, char *buf);

#if defined(__cplusplus)
}
#endif 

#endif /*!defined(__mpstack_h__) */