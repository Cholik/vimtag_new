/*!
\file       metp_ctl_codec.h
\brief      mining endpoint transport protocol, control chunk codec

 ----history----
\author     chengzhiyong
\date       2013-07-15
\version    0.01
\desc       create
*/

#if !defined(__metp_control_codec_h__)
#define __metp_control_codec_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

#if !defined(__len_str_defined)
#   define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */

struct metp_ctl;
struct metp_ctl_reg;
struct metp_ctl_reg_ack;
struct metp_ctl_unreg;
struct metp_ctl_unreg_ack;
struct metp_ctl_connect;
struct metp_ctl_connect_ack;
struct metp_ctl_connect_notify;
struct metp_ctl_connect_notify_ack;
struct metp_ctl_attach;
struct metp_ctl_attach_ack;
struct metp_ctl_dettach;
struct metp_ctl_dettach_ack;
struct metp_ctl_ctx;

/* fid  xx xx xx xx xx xx 
        00 00 0x xx xx xx : group srv reserved to allow directly connect to self.
        00 00 1x xx xx xx : group srv reserved to forward by self.
*/

#define metp_ctl_type_keepalive             0
#define metp_ctl_type_reg                   1
#define metp_ctl_type_reg_ack               2
#define metp_ctl_type_connect               3
#define metp_ctl_type_connect_ack           5
#define metp_ctl_type_connect_notify        6
#define metp_ctl_type_connect_notify_ack    7
#define metp_ctl_type_attach                8
#define metp_ctl_type_attach_ack            9
#define metp_ctl_type_dettach               10
#define metp_ctl_type_dettach_ack           11

/* send to fid=[0,0,0,0,0,0] */
typedef struct metp_ctl_reg
{
    unsigned long               seq;                /*!< request sequence number */
    struct len_str              eid;                /*!< endpoint id */
    struct len_str              key;                /*!< key */
    struct len_str              fid;                /*!< inner fid */

    struct
    {
        struct len_str          ip;                 /*!< inner ip */
        unsigned long           port;               /*!< port */
    }lan;
}_metp_ctl_reg;

/* send to fid=[0,0,0,0,0,0] */
typedef struct metp_ctl_reg_ack
{
    unsigned long               seq;                /*!< request sequence number */
    struct len_str              ret;                /*!< result */

    /* ----------------save a connect and two attach operations------------ */
    struct len_str              fid;                /*!< fid */
    struct len_str              key;                /*!< key */

    struct
    {
        struct len_str          fid;                /*!< fid for server, with fid to get a tunnel */
        struct len_str          key;                /*!< key */
    }peer;/* for server */
    /* ----------------save a connect and two attach operations------------ */

    struct
    {
        struct len_str          ip;                 /*!< inner ip */
        unsigned long           port;               /*!< port */
    }pub;
}_metp_ctl_reg_ack;

typedef struct metp_ctl_connect
{
    unsigned long               seq;                /*!< request sequence number */

    struct len_str              eid;                /*!< endpoint id, if EMPTY connect to current reciever directly */
    struct len_str              key;                /*!< peer key */
    struct len_str              fid;                /*!< inner fid */

    /* -------if connect reciever directly(epid==EMPTY), can emtpy--------- */
    struct
    {
        struct len_str          ip;                 /*!< inner ip */
        unsigned long           port;               /*!< port */
    }lan;
    /* -------if connect reciever directly(epid==EMPTY), can emtpy--------- */
}_metp_ctl_connect;

typedef struct metp_ctl_connect_ack
{
    unsigned long               seq;                /*!< request sequence number */
    struct len_str              ret;                /*!< result */

    struct len_str              fid;                /*!< forward id */
    struct len_str              key;                /*!< key */

    /* ----------------if disable forward, will empty)--------------------- */
    struct
    {
        struct len_str          ip;                 /*!< addr */
        unsigned long           port;               /*!< port */

        struct len_str          key;                /*!< key */
    }forward;
    /* ----------------if disable forward, will empty)--------------------- */

    struct
    {
        struct len_str          fid;                /*!< forward id */
        struct len_str          key;                /*!< key */

    /* ----------------for p2p(if connect directly can empty)-------------- */
        struct
        {
            struct len_str      ip;                 /*!< inner ip */
            unsigned long       port;               /*!< port */
        }lan, pub;
    /* ----------------for p2p(if connect directly can empty)-------------- */
    }peer;

    struct
    {
        struct len_str          ip;                 /*!< inner ip */
        unsigned long           port;               /*!< port */
    }pub;
}_metp_ctl_connect_ack;

typedef struct metp_ctl_connect_notify
{
    unsigned long               seq;                /*!< request sequence number */

    struct len_str              fid;                /*!< forward id */
    struct len_str              key;                /*!< key */

    /* ----------------if disable forward, will empty)--------------------- */
    struct
    {
        struct len_str          ip;                 /*!< addr */
        unsigned long           port;               /*!< port */

        struct len_str          key;                /*!< key */
    }forward;
    /* ----------------if disable forward, will empty)--------------------- */

    struct
    {
        struct len_str          fid;                /*!< forward id */
        struct len_str          key;                /*!< key */

        struct
        {
            struct len_str      ip;                 /*!< inner ip */
            unsigned long       port;               /*!< port */
        }lan, pub;
    }peer;
}_metp_ctl_connect_notify;

typedef struct metp_ctl_connect_notify_ack
{
    unsigned long               seq;                /*!< request sequence number */
    struct len_str              ret;                /*!< result */

}_metp_ctl_connect_notify_ack;

typedef struct metp_ctl_attach
{
    unsigned long               seq;                /*!< request sequence number */

    struct len_str              fid;                /*!< forward id */
    struct len_str              key;                /*!< key */
}_metp_ctl_attach;

typedef struct metp_ctl_attach_ack
{
    unsigned long               seq;                /*!< request sequence number */

    struct len_str              ret;                /*!< result */

    struct
    {
        struct len_str          ip;                 /*!< inner ip */
        unsigned long           port;               /*!< port */
    }pub;
}_metp_ctl_attach_ack;

typedef struct metp_ctl_dettach
{
    unsigned long               seq;                /*!< request sequence number */

    struct len_str              fid;                /*!< forward id */
    struct len_str              key;                /*!< key */
}metp_ctl_dettach;

typedef struct metp_ctl_dettach_ack
{
    unsigned long               seq;                /*!< request sequence number */
    struct len_str              ret;                /*!< result */
}_metp_ctl_dettach_ack;

#define metp_ctl_magic          (*(long*)"mecl    ")
typedef struct metp_ctl
{
    unsigned short                          type;               /*!< ctl type */
    unsigned short                          reserved;           /*!< 4bytes align */
    union
    {
        struct metp_ctl_reg                 reg;
        struct metp_ctl_reg_ack             reg_ack;
        struct metp_ctl_connect             connect;
        struct metp_ctl_connect_ack         connect_ack;
        struct metp_ctl_connect_notify      connect_notify;
        struct metp_ctl_connect_notify_ack  connect_notify_ack;
        struct metp_ctl_attach              attach;
        struct metp_ctl_attach_ack          attach_ack;
        struct metp_ctl_dettach             dettach;
        struct metp_ctl_dettach_ack         dettach_ack;
    }data;
}_metp_ctl;

#define metp_err_ctl_codec_base                         (-1)
#define metp_err_ctl_codec_invalid_param                (metp_err_ctl_codec_base - 1)
#define metp_err_ctl_codec_parse_content_failed         (metp_err_ctl_codec_base - 2)
#define metp_err_ctl_codec_type_unknown                 (metp_err_ctl_codec_base - 3)
#define metp_err_ctl_codec_create_mjson_obj_failed      (metp_err_ctl_codec_base - 4)
#define metp_err_ctl_codec_alloc_failed                 (metp_err_ctl_codec_base - 5)
#define metp_err_ctl_codec_mjson_encode_failed          (metp_err_ctl_codec_base - 6)

/*!
func    metp_ctl_decode
\brief  decode ctl 
\param  type[in]                the ctl type
\param  len[in]                 the data length
\param  data[in]                the data
\param  ctl[out]                the control description object
\return decode result
        #0                      succeed
        #other                  error code
*/
long metp_ctl_decode(unsigned long type, unsigned long len, unsigned char *data, struct metp_ctl *ctl);

/*!
func    metp_ctl_encode
\brief  encode ctl data
\param  ctl[in]                 the control object
\param  buf_size[in]            the buffer size
\param  buf[out]                the buffer
\return encode result
        #0                      succeed
        #other                  error code
*/
long metp_ctl_encode(struct metp_ctl *ctl, unsigned long buf_size, unsigned char *buf);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__metp_control_codec_h__) */

