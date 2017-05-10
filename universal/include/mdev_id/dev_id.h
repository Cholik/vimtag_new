/*!
\file       dev_id.h
\brief      device identify information unit

----history----

\author     tangsiheng
\date       2012-03-01
\version    0.01
\desc       create

----history----
\author     chengzhiyong
\date       2012-06-07
\version    0.01
\desc       change data struct to json object
*/
#if !defined(__device_identify_h__)
#define __device_identify_h__

#if defined(__cplusplus)
extern "C" {
#endif

#define dev_id_flag_cert        1

#define dev_id_save_flag_identify           0x01
#define dev_id_save_flag_cert               0x02
#define dev_id_save_flag_write_password     0x10
#define dev_id_save_flag_secret             0x20
#define dev_id_save_flag_root_password      0x40

#define dev_id_save_flag_reset              0x100   /* reset password,root-password for debug */

#define dev_id_save_flag_fuse               0x1000  /* !!!!! if set will lock, can not write again */

#define dev_id_save_flag_link_user_rootpwd  0x2000  /* active _x_rootpwd field in json, if auto password calc mode failed try this. */
#define dev_id_save_flag_default        (dev_id_save_flag_identify | dev_id_save_flag_cert | \
                                         dev_id_save_flag_write_password | dev_id_save_flag_secret \
                                         | dev_id_save_flag_root_password)

/*!
func    dev_id_create
\brief  get device identify information refer system
\param  flag[in]                the flag, ref dev_id_flag_xxx, 
                                if ZERO just read base info
\return the device information
        #NULL                   failed
        #other                  the device information
*/
struct json_object *dev_id_create(unsigned long flag);

/*!
func    dev_id_destroy
\brief  destroy device identify information refer system
\param  id[in]                  the device identify information
\return destroy result
        #0                      succeed
        #other                  error code
*/
long dev_id_destroy(struct json_object *id);

/*!
func    dev_id_save
\brief  save device identify information into system
\param  id[in]                  the device identify information
\param  flag[in]                the flag, ref dev_id_save_flag_xxx
\return save result
        #0                      succeed
        #other                  error code
*/
long dev_id_save(struct json_object *id, unsigned long flag);

/*!
func    dev_id_to_sn
\brief  generate device serial no from device id
\param  id[in]                  the device identify information, can be NULL
                                #NULL or EMPTY, will generate a temp sn
\param  size[in]                the buffer size
\param  buf[out]                the buffer 
\return generate result
        #<0                     error code
        #other                  sn length
*/
long dev_id_to_sn(struct json_object *id, unsigned long size, unsigned char *buf);

/*!
func    dev_id_from_sn
\brief  sn from device id
\param  sn_len[in]              the serial no size
\param  sn[in]                  the serial no
\param  buf_size[in]            the buffer size
\param  buf[out]                the buffer
\return generate result
        #<0                     error code
        #other                  id length
*/
long dev_id_from_sn(unsigned long sn_len, unsigned char *sn, unsigned long buf_size, unsigned char *buf);
#define dev_id_is_tmp(_dev_id) (0xff == _dev_id[0])

/*!
func    dev_id_util
\brief  dev-id util, for command line util, "--help" to get help
\param  argc[in]                the arg counts
\param  argv[in]                the arg value
\return util run result
        #<0                     error code
        #0                      succeed
*/
long dev_id_util(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__device_identify_h__) */

