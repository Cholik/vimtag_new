
#ifndef __MRF_COMMON_H__
#define __MRF_COMMON_H__


#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <pthread.h>

#include "libjpeg/jinclude.h"
#include "mcore/mcore.h"
#include "mrf_base/mrf_protocol_base.h"



#if 0
#define MRF_TEST_PTHREAD 
#endif
   

#define     MRF_LENGTH_THREAD_COUNT            1        // the 1 processing thread



//********************rf status*************

#define MRF_STATUS_NORMAL   0
#define MRF_STATUS_QUERY     1

//****************************************


#define MRF_DEV_FSK         1
#define MRF_DEV_ASK         2

 

/* add item to last
have copy to mparams.c, if changed plz change it*/
#define mrf_mlist_add(head, item, node)\
do \
{\
    if((head)->list)\
    {\
        (item)->node.prev = ((item)->node.next = (head)->list)->node.prev;\
        (head)->list->node.prev = ((head)->list->node.prev->node.next = (item));\
    }\
    else\
    {\
        (head)->list = ((item)->node.prev = ((item)->node.next = (item)));\
    }\
    ++(head)->counts;\
} while (0);


/* don't input item as head.list 
have copy to mparams.c, if changed plz change it */
#define mrf_mlist_del(head, item, node)\
do \
{\
    if((head)->list == (item))\
    {\
        (head)->list = ((item)->node.next == (item))?0:(item)->node.next;\
    }\
    (item)->node.prev->node.next = (item)->node.next;\
    (item)->node.next->node.prev = (item)->node.prev;\
    (item)->node.prev = NULL; \
    (item)->node.next = NULL; \
    --(head)->counts;\
} while (0);





#ifdef  OPEN_RF_RWLOCK 
struct mrf_pthread_rwlock
{
    pthread_rwlock_t  rwlock_list_in;
    pthread_rwlock_t  rwlock_list_dis;
    pthread_rwlock_t  rwlock_list_ask;
    pthread_rwlock_t  rwlock_data_tx;

}_mrf_pthread_rwlock;
#endif




//***********************************************

//static mrf_type_uchar mrf_mem_cmp(mrf_type_uchar * from, mrf_type_uchar * to, mrf_type_uchar size);
//static _mrf_error mrf_read_data(char * filename, struct mrf_dev_head * h);
//static _mrf_error mrf_read_data_ask(char * filename, struct mrf_ask_dev_head * h);
//static _mrf_error mrf_write_data(char * filename, struct mrf_dev_head * h);
//static _mrf_error mrf_write_data_ask(char * filename, struct mrf_ask_dev_head * h);
static _mrf_error mrf_init_mrf_(mrf_type_uchar * uart_port);

//static mrf_type_key mrf_get_check_sum(mrf_type_uchar * buf, mrf_type_uchar place, mrf_type_uchar key);
//static _mrf_error mrf_read_tlv_type(struct mrf_data * p);
static _mrf_error mrf_init_dev(struct mrf_device *dev, struct mrf_data * p);

static _mrf_error  mrf_recv_father_ack(struct mrf_data * p);
static _mrf_error  mrf_recv_query(struct mrf_data * p);
static _mrf_error mrf_recv_ack_for_search_dev(struct mrf_data * p);
static _mrf_error  mrf_recv_hold_ack(struct mrf_data * p);
static _mrf_error  mrf_recv_add_dev_back(struct mrf_data * p);
static _mrf_error mrf_recv_notify_ask(struct mrf_data * p);
static _mrf_error  mrf_recv_ack_for_add_dev_ask(struct mrf_data * p);
static _mrf_error mrf_recv_query_ack(struct mrf_data * p);
static _mrf_error mrf_recv_ack_for_seek_dev(struct mrf_data * p);
static _mrf_error mrf_recv_ack_for_add_dev(struct mrf_data * p);
static _mrf_error mrf_recv_ack_for_add_ask_dev(struct mrf_data * p);
static _mrf_error mrf_recv_ack_for_query_status(struct mrf_data * p);
static _mrf_error mrf_recv_notify(struct mrf_data * p);    
static _mrf_error mrf_read_cmd_type(struct mrf_data * p);  
//static _mrf_error mrf_read_tlv(struct mrf_data * p);
//static _mrf_error mrf_write_package(struct mrf_data * p);
//static _mrf_error mrf_add_TLV(mrf_type_uchar value_length, mrf_type_uchar type_length, mrf_type_uchar * tlv, mrf_type_uchar * value, struct mrf_data * p);

static _mrf_error mrf_init_uart(mrf_type_uchar * port);

void *mrf_pthread_uart_recv_package(void *datas);
//static _mrf_error mrf_uart_send_str(mrf_type_uchar *buf, int leng);
static _mrf_error  mrf_send_ack_notify_ask(struct  mrf_data *p );
static _mrf_error mrf_send_cmd_ask(struct  mrf_data *p );

static _mrf_error mrf_set_dev_data(struct mrf_device *p);




//                      function start
//_______________________________________________________________________  
  


_mrf_error mrf_init_mrf(mrf_type_uchar * uart_port);


//_mrf_error mrf_send_cmd_hold();
_mrf_error mrf_send_cmd_seek();
//_mrf_error mrf_send_cmd_add_dev_fsk (mrf_type_uchar *  dev_id );
_mrf_error mrf_send_cmd_add_dev_ask  (mrf_type_uchar *  dev_id );

//void mrf_close_add_status();
_mrf_error mrf_send_cmd_query(mrf_type_uchar *  dev_id);


_mrf_error mrf_delete_dev_ask_by_id(mrf_type_uchar *  dev_id);



int  mrf_cmp_id(const void *data1, const void *data2);
int  mrf_cmp_id_ask(const void *data1, const void *data2);
int  mrf_cmp_dev_type(const void *data1, const void *data2);

_mrf_error mlist_select(struct mrf_dev_head * h, void* data, cmp_f_p fun, struct mrf_device **ret);
_mrf_error mlist_move(struct mrf_dev_head * h, void* data, cmp_f_p fun, struct mrf_device ** ret);
_mrf_error mlist_select_ask(struct mrf_ask_dev_head * h , void* data, cmp_f_p fun, struct mrf_ask_dev ** ret);



struct mrf_dev_head *     mrf_get_g_list_h_in();            //FSK 
struct mrf_ask_dev_head * mrf_get_g_list_h_ask();    //ASK

struct mrf_device *     mrf_get_g_current_add_dev();    // multithreading receive data
struct mrf_ask_dev*     mrf_get_g_current_add_dev_ask();

struct mrf_data *   mrf_get_g_data_tx();        // the only tx data struct
struct mrf_device*  mrf_get_dev_by_id(mrf_type_uchar *  dev_id);




_mrf_error mrf_read_data_list_fsk(struct mrf_device * data);
_mrf_error mrf_read_data_list_ask(struct mrf_ask_dev * data);
_mrf_error mrf_get_flag_delay();
void mrf_print_list(struct mrf_device * list);
//void mrf_print_package(mrf_type_uchar *buf, mrf_type_uchar counts, char *mess);


void mrf_mem_copy(mrf_type_uchar * from, mrf_type_uchar * to, mrf_type_uchar size);
_mrf_error mrf_set_nick_ask(struct mrf_ask_dev * p, mrf_type_uchar * nick , mrf_type_uart leng );




//****************************v2.0 new function*************

extern int mrf_ok;
//init
_mrf_error mrf_init_mrf(mrf_type_uchar * uart_port);
_mrf_error mrf_set_id(mrf_type_uchar * id, u32t leng); // set ipc rf dev id;
//init end

void mrf_set_mode_in_query( );
void mrf_set_mode_in_normal( );


_mrf_error mrf_set_ccm(void * cm);
_mrf_error mrf_set_fsk_notify(notify_f_p f);
_mrf_error mrf_set_ask_notify(notify_f_p f);
_mrf_error mrf_set_hold_callback(send_hold_cmd f);
_mrf_error mrf_set_active_callback(send_hold_cmd f);
_mrf_error mrf_set_add_callback(add_callback f);
_mrf_error mrf_set_test_callback(add_callback f);
_mrf_error mrf_set_hold_cmd_callback(ack_callback f);
_mrf_error mrf_set_add_exit_callback(ack_callback f);
_mrf_error mrf_set_add_ack_callback(ack_callback f);


_mrf_error mrf_send_cmd_hold(mrf_type_uchar * to_id, int seconds, int hMicsecond_light, int hMicsecond_dark);
_mrf_error mrf_send_cmd_hold_2(mrf_type_uchar * to_id, int seconds, int hMicsecond_light, int hMicsecond_dark);

_mrf_error mrf_send_cmd_ack(struct  mrf_data *p );

struct mrf_dev_head * mrf_get_g_list_h_dis(); // get fsk dicover dev list
_mrf_error mrf_destroy_list_h_dis();  //distroy fsk dicover dev list


_mrf_error mrf_send_cmd_add_dev_fsk (mrf_type_uchar *  dev_id , int seconds, int hMicsecond_light, int hMicsecond_dark);  //add fsk dev
_mrf_error mrf_delete_dev_by_id(mrf_type_uchar *  dev_id); //delete fsk dev in list
_mrf_error mrf_set_nick_fsk(mrf_type_uchar *  dev_id, mrf_type_uchar * nick, mrf_type_uart leng ); //set fsk dev nick



// add for test rf 2.94
_mrf_error mrf_send_cmd_hello( );

// add yangfeicheng 3.8.2
_mrf_error mrf_send_cmd_into_add();


_mrf_error mrf_set_key(struct mrf_device * dev, mrf_type_key key2);



void mrf_open_rf_read();

void mrf_close_rf_read();

void mrf_get_send_recv_num(unsigned int * arg);

//add for v3.10.2 app -- exdev direct cmd
_mrf_error mrf_send_cmd_father(mrf_type_uchar * to_id, unsigned char child_cmd , unsigned char child_param_count, unsigned char * child_param);

//******************************************************



#ifdef MRF_ACTIVE
_mrf_error mrf_send_cmd_string(mrf_type_uchar * buf, int leng);
_mrf_error mrf_get_active_seek_list(mrf_type_uchar * buf);
_mrf_error mrf_send_cmd_active();

//_mrf_error mrf_send_cmd_seek();
//_mrf_error mrf_init_mrf(mrf_type_uchar * uart_port);


#endif

//-----------------------------------------------------------------------
//                      function end                       

  
#endif








     
