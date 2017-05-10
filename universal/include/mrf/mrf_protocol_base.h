
#ifndef __MRF_PROTOCOL_BASE_H__
#define __MRF_PROTOCOL_BASE_H__


#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#include "libjpeg/jinclude.h"
#include "mcore/mcore.h"

#if 0
#define MRF_ACTIVE
#endif 

#if 0
#define MRF_TEST 
#endif

#if 0
#define OPEN_RF_RWLOCK  
#endif
   
#define     MRF_LENGTH_PACKAGE            64
#define     MRF_LENGTH_PACKAGE_DOUB            128

#define     MRF_LENGTH_TYPE_TLV            1 
#define     MRF_LENGTH_TYPE_TLV2          2 

#define     MRF_LENGTH_TYPE_CMD            1
#define     MRF_LENGTH_ID                           4
#define     MRF_LENGTH_ID_ASK                       4
#define     MRF_LENGTH_ID_IPC                   8

#define     MRF_LENGTH_CHILD_PARAM        8


#define     MRF_LENGTH_NICK                 16

#define     MRF_LENGTH_FLASH_TYPE	        4			// add v3.8.1 yangfeicheng
#define MRF_VER "v3.3.2.1605061000"


//************************
#define MRF_LENGTH_UART_COUNTS        1
typedef unsigned char mrf_type_uart;
//*************************

typedef unsigned char    mrf_type_key;
typedef unsigned char    mrf_type_sess;

typedef unsigned char     mrf_type_cmd;
typedef unsigned char     mrf_type_tlv;
typedef unsigned short     mrf_type_tlv2;

typedef unsigned char mrf_type_alarm;
typedef unsigned char mrf_type_dev;


typedef unsigned char   mrf_type_uchar;    
typedef unsigned char   u8t;      ///< range: 0 .. 255       
typedef unsigned short  u16t;     ///< range: 0 .. 65535      
typedef unsigned int     u32t;     ///< range: 0 .. 4'294'967'295



//                         TLV  start
//_______________________________________________________________________

typedef enum mrf_tlv_type
{
    MRF_TLV_ID_FROM                             = 0x01,
    MRF_TLV_ID_TO                               = 0x02,
    MRF_TLV_SESS_ID_FROM                 = 0x03,
    MRF_TLV_SESS_ID_TO                      = 0x04,
    MRF_TLV_VIA_ID                              = 0x05,
    MRF_TLV_CMD                                 = 0x06,
    MRF_TLV_RET_CODE                        = 0x07,
    MRF_TLV_KEY                                 = 0x08,
    
    MRF_TLV_REPLY                               = 0x09,
    MRF_TLV_CHECK_SUM                       = 0x0a,                
    MRF_TLV_INFO_ACTIVE                      =0x0b,
    MRF_TLV_DEV_TYPE                            = 0x0c,
    MRF_TLV_ASK_ID                              = 0x0d,            //
    
    //add for v2.0
    MRF_TLV_ADD_NUM                          = 0x0e,//add for v2.0
    MRF_TLV_PASS                                 = 0x0f,//add for v2.0
    MRF_TLV_PASS_LOCAL                      = 0x10,//add for v2.0
    
    MRF_TLV_HOLD_TIME                        = 0x11,//add for v2.0
    MRF_TLV_HOLD_LED_TIME                   = 0x12,//add for v2.0
    MRF_TLV_ADD_TIME                            = 0x13,//add for v2.0
    MRF_TLV_ADD_LED_TIME                    = 0x14,//add for v2.0

    MRF_TLV_HOLD_LED_DARK         	= 0x15,//add for v2.9
    MRF_TLV_ADD_LED_DARK        	= 0x16,//add for v2.9


    MRF_TLV_DOOR_OPEN_STATUS            = 0x30,//add for v2.7
    MRF_TLV_DEV_TYPE_BASE           = 0x31, // add v3.8.1 yangfeicheng

    MRF_TLV_SV						= 0x81,	// software version
    MRF_TLV_LOW_VDD					= 0x82,	// add for v3.7.5
    MRF_TLV_SEND_COUNT				= 0x83,	// add for v3.9.1

    MRF_TLV_TH_DATA					= 0x90, // add for v3.9.1 hdc yangfeicheng


    MRF_TLV_NOTIFY_NUM                       = 0xa0,//add for v3.9.1 for test


    MRF_TLV_CMD_CHILD                           = 0xa1, //add for v3.10.2 app -- exdev direct cmd
    MRF_TLV_PARAM_CHILD                       = 0xa2, //add for v3.10.2 app -- exdev direct cmd
    
#if 0    
        1.INFOMATION    0x2000 ---- 0x2fff
        2.CAPT              0x3000 ---- 0x4fff
        3.CONFIG           0x5000 ---- 0x5fff
        4.VALUE             0x6000 ---- 0x7fff
#endif


    //MRF_TLV_xxx      0xb1 

    //MRF_TLV_ALARM_TYPE             = 0xc1,        //alarm type


}_mrf_tlv_type;               
//-----------------------------------------------------------------------
//                         TLV end    


//                        mrf_command start
//_______________________________________________________________________

typedef enum mrf_command
{

    MRF_CMD_ADD_DEV                    = 0x01,        //
    MRF_CMD_ACK                            = 0x02,        //
    MRF_CMD_ACTIVE                       = 0x03,        //
    MRF_CMD_MODIF_CONFIG           = 0x04,        //
    MRF_CMD_NOTIFY                       = 0x05,        //
    MRF_CMD_SEEK_DEV                   = 0x06,        //seek  new dev 
    MRF_CMD_CONTROL_DEV             = 0x07,        //
    MRF_CMD_ADD_ASK_DEV             = 0x08,
    MRF_CMD_SEARCH_DEV               = 0x09,        // search add dev inline ?
    MRF_CMD_ADD_VERIFY_DEV        = 0x0a,
    MRF_CMD_NOTIFY_ASK                = 0x0b,
    MRF_CMD_QUERY                        = 0x0c,
    MRF_CMD_HOLD                          = 0x0d,
    MRF_CMD_ADD_DEV_BACK           = 0x0e,
    MRF_CMD_HOLD_ACK                  =0x0f,
    MRF_CMD_ADD_ACK                     =0x10,	//add for v2.9

    MRF_CMD_EXIT                            =0x36,//add for v2.9
    MRF_CMD_HELLO                           =0x37,//add for v2.94
    MRF_CMD_HELLO_ACK                   =0x38,//add for v2.94

    
    MRF_CMD_QUERY_ACK               =0x80,
    MRF_CMD_INTO_ADD 			=0x81,

    MRF_CMD_FATHER   			=0x82, //add for v3.10.2 app -- exdev direct cmd
    MRF_CMD_FATHER_ACK 		=0x83, //add for v3.10.2 app -- exdev direct cmd
    
}_mrf_command;
//-----------------------------------------------------------------------
//                        mrf_command  end


//add for v3.10.2 app--exdev direct cmd
typedef enum mrf_command_child
{
    MRF_CMD_CHILD_OPEN_FEETDOG       =0x34,	//add for v3.10.2 app -- exdev direct cmd
    MRF_CMD_CHILD_CLOSE_FEETDOG      =0x35,	//add for v3.10.2 app -- exdev direct cmd
    MRF_CMD_CHILD_OPEN_FEETDOG_ACK       =0x32,       //add for v3.10.2 app -- exdev direct cmd
    MRF_CMD_CHILD_CLOSE_FEETDOG_ACK      =0x33,	//add for v3.10.2 app -- exdev direct cmd

}_mrf_command_child;

//-----------------------------------------------------------------------

typedef enum mrf_error
{
    MRF_EOR_OK                              = 0x00,  //
    
    MRF_EOR                                     = 0x01,  //
    MRF_EOR_NULL_POINTER             = 0x02,  //
    MRF_EOR_NO_FIND                     = 0x03,
    MRF_EOR_UNKNOW_DEV_TYPE     = 0x04,
    MRF_EOR_SESS_WRONG             = 0x05,
    MRF_EOR_DEV_EXIST                   = 0x06,
    MRF_EOR_NOT_RECV                 = 0x07,
    MRF_EOR_CHECK_SUM_EOR         = 0x08,
    MRF_EOR_DELAY_STATUS            = 0x09,
    MRF_EOR_DEV_NO_QUERY            = 0x0a,
    MRF_EOR_CMD                     = 0x40, //

}_mrf_error;


//                         mrf_dev_type  start
//_______________________________________________________________________

typedef enum mrf_dev_type
{
	MRF_DEV_TYPE_CAMERA                = 0x01,		// 
 	MRF_DEV_TYPE_GATEWAY             = 0x02,		// 

	MRF_DEV_TYPE_HDC                      = 0x03,		//
	MRF_DEV_TYPE_ASK_DEV              = 0x04,		// 
 	MRF_DEV_TYPE_SOSBUTTON         = 0x05,		//
	MRF_DEV_TYPE_DOOR                   = 0x06,		//
	MRF_DEV_TYPE_GIO_IN                = 0x07,		//
	MRF_DEV_TYPE_GIO_OUT             = 0x08,		//
}_mrf_dev_type;   

typedef enum mrf_dev_in_flag
{
    MRF_DEV_IN_LINE                         = 0x01,        //
    MRF_DEV_DISCOVER                    = 0x02,        //
    MRF_DEV_OUT_LINE                    = 0x03,         //
    MRF_DEV_RESERVE                     = 0x04,
  
}_mrf_dev_in_flag;   

typedef enum mrf_alarm_type
{
    MRF_ALARM_ASK_DEV = 0x01,
    MRF_ALARM_THTB = 0x02,
    MRF_ALARM_DOOR = 0x03,
    
}_mrf_alarm_type;


               
//-----------------------------------------------------------------------
//                        mrf_dev_type  end

struct mrf_tlv_flag
{
    unsigned int  sess_id_flag_from            :1;          // 1/0, send from sess id?
    unsigned int  sess_id_flag_to                :1;    // 1/0, send to sess id?  
    unsigned int  to_id_flag                    :1;          // 1/0, using to_id / using all_id
    unsigned int  reply_batt                    :1;         // 
    unsigned int  reply_key                    :1;              // 
    unsigned int  reply_pro_vision                :1;        // 1/0, send provision ? 
    unsigned int  check_sum_flag                :1;        // 1/0, yes/no     
    unsigned int  reply_check_sum_flag               :1;            // do i recv check_sum?
    unsigned int  reply_this_flag                :1;        // 1/0 , send reply asking tlv?
    unsigned int  ack_reply_flag                :1;         // 1/0, show we asking the pakage?
    unsigned int  ask_id_flag                    :1;        // show sending ask id ?
    unsigned int  reply_active_flag             :1;

    //using for new needs: notify cmd can be add requirement, cm_in_add_flag is a status of cm
    unsigned int  cm_in_add_flag             :1;
    

    unsigned int hold_time_flag                 :1; //add for v2.0
    unsigned int hold_led_time_flag            :1;//add for v2.0
    unsigned int add_time_flag                 :1;//add for v2.0
    unsigned int add_led_time_flag            :1;//add for v2.0

    unsigned int hold_led_dark_time_flag            :1;//add for v2.9
    
    unsigned int add_led_dark_time_flag            :1;//add for v2.9

    unsigned int  delay_flag                    :1;        // 1/0, what status now , if 1, we can't send package initiative any more 

    unsigned int  reply_child_cmd_flag             :1;         //add for v3.10.2 app -- exdev direct cmd

    
}_mrf_tlv_flag;


//rf
struct mrf_data
{
    unsigned char buf[MRF_LENGTH_PACKAGE];
    unsigned char child_param_buf[MRF_LENGTH_CHILD_PARAM];
    
    unsigned char value_length;
    unsigned char type_length;
    unsigned char tlv_place;
    mrf_type_tlv2 tlv_types;

    mrf_type_sess f_sess_id;
    mrf_type_sess t_sess_id;
    mrf_type_key  check_sum;
    unsigned char  yuliuxx;
    
    mrf_type_cmd   command;
    mrf_type_cmd   command_child;
    mrf_type_cmd   child_param_count;
    mrf_type_alarm    alarm_type;
    

    struct mrf_tlv_flag tlv_flag;

    mrf_type_uchar  from_id[MRF_LENGTH_ID_IPC];
    mrf_type_uchar  to_id[MRF_LENGTH_ID];
    mrf_type_uchar  ask_id[MRF_LENGTH_ID];

    u16t g_mrf_hold_status_time ;           //add for v2.0
    u16t g_mrf_hold_led_light_time ;         //add for v2.0
    u16t g_mrf_add_status_time;             //add for v2.0
    u16t g_mrf_add_led_light_time ;         //add for v2.0

    u16t g_mrf_hold_led_dark_time;         //add for v2.9
    u16t g_mrf_add_led_dark_time;         //add for v2.9

    unsigned int mrf_rf_send_num;
    unsigned int mrf_rf_recv_num;
    
    pthread_t pthid;
    struct mrf_device    *dev;
}_mrf_data;

struct mrf_device
{
    struct 
    { 
        struct mrf_device *next;
        struct mrf_device *prev;
    }node;     // node
          
    mrf_type_uchar dev_id[MRF_LENGTH_ID]; // 
    mrf_type_uchar nick[MRF_LENGTH_NICK];
    mrf_type_uchar dev_type_base[MRF_LENGTH_FLASH_TYPE];
    //unsigned char dev_key1[16];
    
    unsigned char pass_local[8];

    unsigned char key2;
    unsigned char add_num;
    unsigned char pass;
    mrf_type_sess sessid;

    unsigned short notify_num;
    unsigned short yuliu3;
    
    unsigned char reply_num;
    _mrf_dev_in_flag in_status; //
    unsigned char battery_value;
    mrf_type_dev dev_type;

    void * dev_data;
}_mrf_device;

struct mrf_dev_head
{
    unsigned long   counts;
    struct mrf_device    *list;
}_mrf_dev_head;


struct mrf_ask_dev_head
{ 
    unsigned long counts;
    struct mrf_ask_dev *list;    
}_mrf_ask_dev_head;

struct mrf_ask_dev
 { 
    struct 
    { 
        struct mrf_ask_dev *next;
        struct mrf_ask_dev *prev;
    }node;     //node 
    
    mrf_type_uchar nick[MRF_LENGTH_NICK];
    unsigned char ask_dev_id[MRF_LENGTH_ID_ASK];
    
}_mrf_ask_dev;


struct mrf_THTB_data
{  
    float temperature_value;
    float humidity_value;
}_mrf_THTB_data;

struct mrf_SOS_data
{  
    unsigned int *p;
}_mrf_SOS_data;


// dor open status... 
#define MRF_DOOR_OPEN   0
#define MRF_DOOR_CLOSE  1

struct mrf_DOOR_data
{  
    unsigned char status;
}_mrf_DOOR_data;



#ifdef MRF_ACTIVE

struct mrf_active
{
    mrf_type_cmd cmd;
    mrf_type_uchar buf_length;
    mrf_type_key def_key;
    mrf_type_uchar id[8];
    mrf_type_uchar time[12];
    mrf_type_uchar did[8];
    mrf_type_uchar key1[12];
    mrf_type_uchar key2[24];
    mrf_type_uchar pv[4];
    mrf_type_uchar fas[16];
    mrf_type_uchar capt[16];
    
    mrf_type_uchar buf[64];
}_mrf_active;
#endif

//ccm_send_hold_cmd

typedef int  (*cmp_f_p)(const void *, const void *);//
typedef void  (*notify_f_p)(void *,void *);
typedef void (*send_hold_cmd)(void *, void *);
typedef void (*add_callback)(void *, void *);
typedef void (*ack_callback)(void*, void*);
typedef void (*test_callback)(void*, void*);

typedef struct 
{
    notify_f_p set_fsk_notify;
    notify_f_p set_ask_notify;
    send_hold_cmd send_hold_cmd;
    send_hold_cmd send_active_cmd;
    add_callback send_add_callback;  
    test_callback test_callback;
    ack_callback  add_ack_callback;  
    ack_callback  exit_callback;
    ack_callback hold_callback; 
}mrf_notify_callback;



_mrf_error mrf_set_id_(mrf_type_uchar * id, u32t leng);
void mrf_mem_copy(mrf_type_uchar * from, mrf_type_uchar * to, mrf_type_uchar size);
void mrf_bzero(mrf_type_uchar *r_buf, unsigned short size);
mrf_type_uchar mrf_mem_cmp(mrf_type_uchar * from, mrf_type_uchar * to, mrf_type_uchar size);


_mrf_error mrf_search();
_mrf_error mrf_uart_init_(mrf_type_uchar * port);
void mrf_print_package(mrf_type_uchar *buf, mrf_type_uchar counts, char *mess);
int mrf_uart_recv_data2(mrf_type_uchar * buf);
 _mrf_error mrf_read_tlv_type(struct mrf_data * p);

int juge_uart_cmd(void *datas);

 _mrf_error mrf_read_tlv(struct mrf_data * p);
_mrf_error mrf_uart_send_str(mrf_type_uchar *buf, int leng);
_mrf_error mrf_write_package(struct mrf_data * p);

int mrf_get_protocol_send_num_count();

#endif








     
