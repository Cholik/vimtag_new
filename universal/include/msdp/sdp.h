/*!
\file       sdp.h
\brief      declare the parse functions 

\author     huangyifan
\date       2009-10-10
\version    0.01

*/

#ifndef __SDP_INTERFACE_H__
#define __SDP_INTERFACE_H__

#if !defined(__len_str_defined)
#define __len_str_defined
/*!< length string */
typedef struct len_str
{
    unsigned long       len;            /*!< string length */
    char                *data;          /*!< string data */
}_len_str;
#endif /* !defined(__len_str_defined) */

/*! \brief sdp's key-value   */
typedef struct sdp_field
{
    struct len_str          key;                                   		/*!<    key's name                  */
    struct len_str          value;                                 		/*!<    key's content               */
}_sdp_field;

typedef struct sdp_xfield
{
    struct  
    {
        struct sdp_xfield   *prev;
        struct sdp_xfield   *next;
    }out_list;

    struct len_str       	key;
    struct len_str       	value;
}_sdp_xfield;


/*! \brief sdp's repeat time struct  */
typedef struct repeat_time
{
    struct len_str          inveral;            /*!<    the repeat interval         */
    struct len_str          duration;           /*!<    the active duration         */
    struct len_str          offset;             /*!<    list of offsets from start-time */
}_repeat_time;


/*! \brief time node  */
typedef struct sdp_time
{
    struct  
    {
        struct sdp_time     *prev;
        struct sdp_time     *next;              
    }out_list;
                                 	
    struct len_str          start_time;         /*!<    start time                  */
    struct len_str          stop_time;          /*!<    stop time                   */
}_sdp_time;

/*! \brief sdp's connection */
typedef struct sdp_connection
{
    struct len_str          network;            /*!<    network type                */
    struct len_str          address_type;       /*!<    address type                */
    struct len_str          address;            /*!<    address                     */
}_sdp_connection;


typedef  struct sdp_media
{
    struct
    {
        struct sdp_media        *prev;
        struct sdp_media        *next;
    }out_list;
    
    struct
    {
        struct
        {
            struct len_str      media_descr;    /*!<  the media type                */
            struct len_str      port;           /*!<  transport port to which the media stream will be sent   */
            struct len_str      transport;      /*!<  transport protocol          */
            struct len_str      format;         /*!<  format                       */
        }announce;
        
        struct len_str          info;           /*!<    media information           */
        struct sdp_connection   conn;           /*!<    connection                  */
        struct sdp_field        entry_key;      /*!<   media key                  */

        struct
        {
            unsigned long       counts;
            struct sdp_xfield   *list;
        }attr;
        struct
        {
            unsigned long       counts;
            struct sdp_xfield   *list;
        }bandwidth;

    }media_layer;

}_sdp_media;

/*! \brief  main struct of sdp  */
typedef struct sdp_block
{
    struct
    {
        struct len_str           version;       /*!<   protocol version                 */
        struct len_str           session_name;  /*!<   session name                     */
        struct len_str           mail;          /*!<   mail                             */
        struct len_str           owner;         /*!<   owner/creator/session identifier */
        struct len_str           info;          /*!<   session info title               */
        struct len_str           uri;           /*!<   uri                              */
        struct len_str           cell_number;   /*!<   phone number                     */
        struct sdp_connection    conn;          /*!<   connection                       */
        struct sdp_field         entry_key;
        
        struct
        {
            unsigned long        counts;
            struct sdp_xfield    *list;
        }attributes;
        struct
        {
            unsigned long        counts;
            struct sdp_xfield    *list;
        }bandwidth;
    }session;
    
    struct
    {
        struct len_str           zone;          /*!<    zone tome change                */
        struct
        {
            unsigned long        counts;        /*!<    total number of irregular time node */
            struct sdp_time      *list;         /*!<    head of irregular time node */
        }active_zone;
        
        struct repeat_time       re_time;
    }active_time;
    
   struct
   {
        unsigned long            counts;
        struct sdp_media         *list;
   }medias;

}_sdp_block;

/*!
func    sdp_create
\brief  to create the sdp struct, and return the struct 
\return the create result
        #NULL                   failed
        #other                  success
*/
struct sdp_block* sdp_create(char *str, unsigned long len);

/*!
func    sdp_destroy
\brief  destroy the sdp_block
\param  sdp[in]             the sdp struct to be destroy
\return the processing result
        #SUCCESS                  	exec success
        #other                  	error_code
*/
long sdp_destroy(struct sdp_block *sdp);


typedef struct sdp_param
{
    struct len_str           owner;                 /* owner/creater & session id identify */
    struct len_str           sessionName;           /* session name */
    struct len_str           pps;                   /* picture serial set */
    struct len_str           sps;                   /* serial set */

    unsigned long            frameRate;             /* frame rate of media */    
    unsigned long            videoFmt;              /* format of video media */

    struct len_str           audioFmt_desc;
    unsigned long            audioFmt;


}_sdp_param;

struct mfmt_video_h264;
struct mfmt_audio_aac;
long sdp_h264_create(struct sdp_param *sdp, unsigned char **out_buf, unsigned long *out_len);
long sdp_h264_destroy(unsigned char *out_buf);

long sdp_h264_get_sps_pps(unsigned char *str, unsigned long len, struct mfmt_video_h264 *ret_fmt);
long sdp_h264_get_audio_config(char *sdp_str, unsigned long len, struct mfmt_audio_aac *audio_fmt);
struct sdp_xfield *sdp_get_media_attr( struct sdp_media *media, char *name, unsigned long len );


#endif
