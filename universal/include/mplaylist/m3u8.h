/*!
\file       m3u8.h
\brief      winamp/Apple HTTP live streaming refer play list

 ----history----
\author     chengzhiyong
\date       2012-04-16
\version    0.01
\desc       create
*/

#if !defined(__m3u8_h__)
#define __m3u8_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

#include <time.h>

/* --------------------- copy from string_ex.h --------------------- */
#if !defined(__len_str_defined)
#   define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */
/* --------------------- copy from string_ex.h --------------------- */

/*! refer http://tools.ietf.org/html/draft-pantos-http-live-streaming-06 */
typedef enum m3u8_item_type
{
    epflt_ext_m3u,                  /*!< #EXTM3U */
    epflt_ext_inf,                  /*!< #EXTINF */
    epflt_ext_x_target_duration,    /*!< #EXT-X-TARGETDURATION */
    epflt_ext_x_media_sequence,     /*!< #EXT-X-MEDIA-SEQUENCE */
    epflt_ext_x_key,                /*!< #EXT-X-KEY */
    epflt_ext_x_program_date_time,  /*!< #EXT-X-PROGRAM-DATE-TIME */
    epflt_ext_x_allow_chache,       /*!< #EXT-X-ALLOW-CACHE */
    epflt_ext_x_playlist_type,      /*!< #EXT-X-PLAYLIST-TYPE */
    epflt_ext_x_endlist,            /*!< #EXT-X-ENDLIST */
    epflt_ext_x_stream_inf,         /*!< #EXT-X-STREAM-INF */
    epflt_ext_x_discontinuity,      /*!< #EXT-X-DISCONTINUITY */
    epflt_ext_x_version,            /*!< #EXT-X-VERSION */
    epflt_comment,                  /*!< comment */
    epflt_empty                     /*!< empty line */
}_m3u8_item_type;

typedef struct m3u8_item
{
    struct  
    {
        struct m3u8_item            *prev, *next;
    }in_list, in_sub_list;
    struct m3u8_list                *parent;

    enum m3u8_item_type             type;
    struct len_str                  name;

    struct
    {
        struct len_str              text;
        union  
        {
            unsigned long           l_value;
            time_t                  t_value;
            /* unsigned long        target_duration;
            unsigned long           media_sequence; 
            unsigned long           program_date_time; // convert from YYYY-MM-DDTHH:MM:SS-MM:SS
            */
            struct  
            {
                unsigned long       program_id;     /*!< option, parse from summary */
                unsigned long       band_width;     /*!< must, parse from summary */
                struct len_str      codecs;         /*!< should, parse from summary */
            }x_stream_inf;              /*!< #EXT-X-STREAM-INF */
            struct  
            {
                unsigned long       duration;   /*!< must, duration, seconds */
                struct len_str      title;      /*!< option, title */
            }inf;                               /*!< #EXTINF */
        }content;
    }desc;

    struct len_str                  url;
    struct len_str                  path;           /* just for m3u8_list load */
    struct m3u8_list                *extern_list;   /*!< sub list, content of the url. */
}_m3u8_item;

typedef struct m3u8_list
{
    struct m3u8_item                *parent;            /*!< parent item */
    struct m3u8_item                *m3u;               /*!< #EXTM3U must be fist line */
    struct  
    {
        struct m3u8_item            *media_sequence;    /*!< #EXT-X-MEDIA-SEQUENCE */
        struct m3u8_item            *target_duration;   /*!< #EXT-X-TARGETDURATION */
        struct m3u8_item            *program_date_time; /*!< #EXT-X-X-PROGRAM-DATE-TIME */
    }x;
    struct  
    {
        unsigned long               counts;
        struct m3u8_item            *list;
    }whole, inf, x_stream_inf;
    unsigned long                   desc_total_len;     /*!< desc total length */
}_m3u8_list;

/*!
func    m3u8_list_encode_get_buf_size
\brief  get encode buffer need size of list
\param  list[in]                the play list
\return size
        #>=0                    buf size
        #other                  error code
*/
long m3u8_list_encode_get_buf_size(struct m3u8_list *list);

/*!
func    m3u8_list_encode
\brief  encode m3u8 list into string
\param  list[in]                the play list
\param  buf_size[in]            the buffer size
\param  buf[out]                the buffer used to save play list string
\return string length
        #>=0                    string length
        #other                  error code
*/
long m3u8_list_encode(struct m3u8_list *list, unsigned long buf_size, unsigned char *buf);

/*!
func    m3u8_list_decode
\brief  decode string as m3u8 play list
\param  text_len[in]            the text length
\param  text[in]                the text
\return play list
        #NULL                   decode failed
        #other                  the play list
*/
struct m3u8_list *m3u8_list_decode(unsigned long text_len, unsigned char *text);

/*!
func    m3u8_list_load
\brief  load play list from file
\param  file[in]                the file name
\param  recursion[in]           recursion flag, if false(0) just load this file,
                                if true(!=0) load children-list
\return play list
        #NULL                   load failed
        #other                  the play list
*/
struct m3u8_list *m3u8_list_load(char *file, unsigned long recursion);

/*!
func    m3u8_list_save
\brief  save list into file, just save this list, will not save children's lists
\param  list[in]                the play list
\param  file[in]                the file name
\return save result
        #0                      succeed
        #other                  error code
*/
long m3u8_list_save(struct m3u8_list *list, char *file);

/*!
func    m3u8_list_create
\brief  create a play list
\param  x_target_duration[in]   the target duration
\param  x_media_sequence[in]    the media sequence
\param  x_program_date_time[in] the program date time
\return the list
        #NULL                   create failed
        #other                  the play list
*/
struct m3u8_list *m3u8_list_create(unsigned long x_target_duration, unsigned long x_media_sequence, time_t x_program_date_time);

/*!
func    m3u8_list_destroy
\brief  destroy play list
\param  list[in]                the list
\return destroy result
        #0                      succeed
        #other                  error code
*/
long m3u8_list_destroy(struct m3u8_list *list);

/*!
func    m3u8_item_destroy
\brief  destroy item
\param  item[in]                the item
\return destroy result
        #0                      succeed
        #other                  error code
*/
long m3u8_item_destroy(struct m3u8_item *item);

/*!
func    m3u8_list_add_seg
\brief  add a stream-inf seg item
\param  list[in]                the parent play list
\param  duration[in]            the item duration
\param  title_len[in]           the title length
\param  title[in]               the title
\param  url_len[in]             the url length
\param  url[in]                 the url
\return the seg item be added
        #NULL                   failed
        #other                  the seg item be added
*/
struct m3u8_item *m3u8_list_add_seg(struct m3u8_list *list,     unsigned long duration,
                                    unsigned long title_len,    char *title,
                                    unsigned long url_len,      char *url);

/*!
func    m3u8_list_add_list
\brief  add a sub stream-inf-list item
\param  list[in]                the parent play list
\param  program_id[in]          the program id
\param  band_width[in]          the band width
\param  codecs_len[in]          the codecs string length
\param  codecs[in]              the codecs string
\param  url_len[in]             the url length
\param  url[in]                 the url
\return the item be added
        #NULL                   add failed
        #other                  the item be added
*/
struct m3u8_item *m3u8_list_add_list(struct m3u8_list *list,
                                     unsigned long program_id,  unsigned long band_width,
                                     unsigned long codecs_len,  char *codecs,
                                     unsigned long url_len,     char *url);

/*!
func    m3u8_list_seek_by_time
\brief  seek item by time
\param  list[in]                the play list
\param  t_pos[in]               the position will be seek
\param  item_time[out]          the item time
\param  item_pos[out]           the item duration position, can be NULL, if NULL ignore
\return the matched item
        #NULL                   not found
        #other                  the matched item
*/
struct m3u8_item *m3u8_list_seek_by_time(struct m3u8_list *list, time_t t_pos, time_t *item_time, unsigned long *item_pos);

/*!
func    m3u8_list_seek_by_duration
\brief  seek item by duration
\param  list[in]                the play list
\param  pos[in]                 the position will be seek
\param  item_time[out]          the item time, can be NULL, if NULL ignore
\param  item_pos[out]           the item duration position
\return the matched item
        #NULL                   not found
        #other                  the matched item
*/
struct m3u8_item *m3u8_list_seek_by_duration(struct m3u8_list *list, unsigned long pos, time_t *item_time, unsigned long *item_pos);

/*!
func    m3u8_list_next
\brief  get next media-file seg item from list
\param  list[in]                the play list
\param  prev[in]                the prev item, can be NULL. if #NULL, get first item in list.
\param  prev_time[in/out]       the prev item's start time, can be NULL. if NULL, ignore.
                                [in] the prev item's start time
                                [out] the result item's start time
\param  prev_duration[in/out]   the prev item's duration pos in play list, can be NULL. if NULL, ignore.
                                [in] the prev item's duration pos in play list
                                [out] the result item's duration pos in play list
\return the next item
        #NULL                   have not next item
        #other                  the next item
*/
struct m3u8_item *m3u8_list_next(struct m3u8_list *list, struct m3u8_item *prev,
                                 time_t *prev_time, unsigned long *prev_duration);

/*!
func    m3u8_list_find
\brief  find item by url
\param  list[in]                the play list
\param  url_len[in]             the url length
\param  url[in]                 the url
\param  item_time[out]          the item's time, can be NULL, if NULL ignore
\param  item_pos[in]            the item's duration position, can be NULL, if NULL ignore
\return the matched item
        #NULL                   not found
        #other                  the matched item
*/
struct m3u8_item *m3u8_list_find(struct m3u8_list *list,
                                 unsigned long url_len, char *url,
                                 time_t *item_time,     unsigned long *item_pos);

/*!
func    m3u8_list_query
\brief  query list info
\param  list[in]                the play list
\param  start_time[out]         the start time
\param  end_time[out]           the end time
\param  duration[out]           the total duration length
\return query result
        #0                      succeed
        #other                  error code
*/
long m3u8_list_query(struct m3u8_list *list, time_t *start_time, time_t *end_time, unsigned long *duration);

/* just for test */
long m3u8_test_entity(long argc, char *arv[]);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__m3u8_h__) */
