/*!
\file       mwificode_type.h
\brief      mining wifi-code type

 ----history----
\author     chengzhiyong
\date       2013-07-09
\version    0.01
\desc       create
*/

#if !defined(__mwificode_type_h__)
#define __mwificode_type_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

struct mwfc_runner;
struct maicodec_desc;


#define mwfc_err_base                   (-1)
#define mwfc_err_invalid_param          (mwfc_err_base - 0)
#define mwfc_err_not_support            (mwfc_err_base - 1)
#define mwfc_err_callbacking            (mwfc_err_base - 2)
#define mwfc_err_alloc_failed           (mwfc_err_base - 3)
#define mwfc_err_decoder_create_failed  (mwfc_err_base - 4)
#define mwfc_err_hash_init_failed       (mwfc_err_base - 5)
#define mwfc_err_cap_open_failed        (mwfc_err_base - 6)
#define mwfc_err_port_open_failed       (mwfc_err_base - 7)
#define mwfc_err_runner_create_failed   (mwfc_err_base - 8)
#define mwfc_err_twins_create_failed    (mwfc_err_base - 9)
#define mwfc_err_decode_push_failed     (mwfc_err_base - 10)
#define mwfc_err_callback_failed        (mwfc_err_base - 11)
#define mwfc_err_twins_not_match        (mwfc_err_base - 12)
#define mwfc_err_encode_failed          (mwfc_err_base - 13)
#define mwfc_err_unsupport_if_type      (mwfc_err_base - 14)

/*!
func    mwfc_runner_on_data
\brief  on-data callback routine, when data recved will call this function
\param  runner[in]              the runner
\param  ref[in]                 the user refer data be inputted when create.
\param  len[in]                 the data length
\param  data[in]                the data
\return callback result
        #0                      succeed
        #other                  error code
*/
typedef long (*mwfc_runner_on_data)(struct mwfc_runner* runner, void *ref, unsigned long len, unsigned char *data);


/*! \brief runner description */
typedef struct mwfc_runner_desc
{
    char                    *mode;              /*!< "sender"|"recver" */
    void                    *ref;               /*!< user refer data */
    struct maicodec_desc    *codec_desc;        /*!< codec desc */

    struct
    {
        char                *interface_name;    /*!< interface name */
        mwfc_runner_on_data on_data;            /*!< on data callback function, just for recver */
        unsigned long       size;               /*!< max data size */
        unsigned long       twins_max_counts;   /*!< max twins */
    }recver;                                    /*!< just for recver, if mode is sender, ignore this fields */
    struct
    {
        unsigned long       len;                /*!< data length */
        unsigned char       *data;              /*!< the data */
        unsigned char       ip[4];              /*!< ip address */
        unsigned char       reserved[4];        /*!< ip address */
        unsigned long       port;               /*!< port value */
        unsigned long       speed;              /*!< speed Bytes/Second */
        void(*output)(char *formats,long param1);
    }sender;                                    /*!< just for sender, if mode is recver, ignore this fields */
}_mwfc_runner_desc;
#define mwfc_runner_desc_format_s       "%p"
#define mwfc_runner_desc_format(_desc)  (_desc)

#define mwfc_push_status_succeed      0x00
#define mwfc_push_status_idle         0x01
#define mwfc_push_status_try          0x02
#define mwfc_push_status_data         0x03

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__mwificode_type_h__) */
