/*!
\file       media_channel_def.h
\brief      media channel unit, channel like a water pipe, can be link 
            with each other
            don't call any media function in media channel on_destroy event
 ----history----
\author     chengzhiyong
\date       2009-09-19
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: media_channel.h,v 1.20 2009-09-19 01:46:28 chengzhiyong Exp $
*/
#if !defined(__media_channel_def_h__)
#define __media_channel_def_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct media_object; /* base media object */
struct media_type;
struct media_capability;
struct media_sample;
struct media_sample_ref;
struct media_sample_queue;
struct media_name;
struct media_params;
struct media_istream;
struct media_ostream;
struct media_channel;
struct media_channel_class;
struct media_factory;
struct media_module;
struct media_channel_desc;
struct media_module_desc;

#if !defined(__len_str_defined)
#define __len_str_defined
/*!< length string */
typedef struct len_str 
{
    unsigned long   len;            /*!< string length */
    char            *data;          /*!< string data */
}_len_str ;
#endif /* !defined(__len_str_defined) */

typedef enum media_object_class_type
{
    emoct_null,
    emoct_type,
    emoct_params,
    emoct_capability,
    emoct_name,
    emoct_module,
    emoct_factory,
    emoct_channel_class,
    emoct_channel,
    emoct_ostream,
    emoct_istream,
    emoct_sample,
    emoct_overflow
}_media_object_class_type;

typedef struct media_object_class
{
    const struct len_str                name;
    const enum media_object_class_type  type;
    const char                          *magic;        /*!< media object magic */
    const char                          *magic_free;   /*!< media object magic free */
    struct
    {
        unsigned long                   counts;
        unsigned long                   his_counts;
    }statistic;
}_media_object_class;

/*! \brief media object, all media object should use this header */
typedef struct media_object
{
    char                            magic[sizeof(long)];    /*!< media object magic */
    unsigned long                   use;                    /*!< used counts */
    const struct media_object_class *obj_class;             /*!< media object class */
    void                            *data;                  /*!< refer data for channel */
    void                            *ctl_data;              /*!< refer data for control module */
    void                            *ref_data;              /*!< reserved ref data, no using now */
}_media_object;

#define __media_event_defined
typedef struct media_event
{
    /* event[sub], create/destroy[], link[check|linked|unlinked|active], ctrl[idr|play|pause|bw|autosize], sample, call */
    struct len_str              type;               /*!< event type, create|destroy|link|ctrl */
    struct len_str              sub;                /*!< event sub type */

    union
    {
        struct media_object     *obj;
        struct media_factory    *factory;
        struct media_channel    *channel;
        struct media_istream    *istream;
        struct media_ostream    *ostream;
    }target;

    union  
    {
        struct media_object     *obj;
        struct media_factory    *factory;
        struct media_channel    *channel;
        struct media_istream    *istream;
        struct media_ostream    *ostream;
    }src;
    
    struct media_lock           *lock;              /*!< lock */
    void                        *func;              /*!< function */
    struct media_params         *params;
}_media_event;
#define media_event_finished    1
#define media_event_format_s    "%p{%*.*s.%*.*s[%*.*s->%*.*s]}"
#define media_event_format(_event) \
    (_event), \
    0, ((_event) && (_event)->type.data)?(int)(_event)->type.len:0,\
    (_event)?(_event)->type.data:NULL,\
    0, ((_event) && (_event)->sub.data)?(int)(_event)->sub.len:0,\
    (_event)?(_event)->sub.data:NULL,\
    0, ((_event) && (_event)->src.obj && (_event)->src.obj->obj_class && (_event)->src.obj->obj_class->name.data)?(int)(_event)->src.obj->obj_class->name.len:0,\
    ((_event) && (_event)->src.obj && (_event)->src.obj->obj_class && (_event)->src.obj->obj_class->name.data)?(_event)->src.obj->obj_class->name.data:0,\
    0, ((_event) && (_event)->target.obj && (_event)->target.obj->obj_class && (_event)->target.obj->obj_class->name.data)?(int)(_event)->target.obj->obj_class->name.len:0,\
    ((_event) && (_event)->target.obj && (_event)->target.obj->obj_class && (_event)->target.obj->obj_class->name.data)?(_event)->target.obj->obj_class->name.data:0

/* create|destroy|start|stop */
typedef void* (*media_factory_on_event)(struct media_factory *factory, struct media_event *event);
/* create|destroy|link|ctrl */
typedef long (*media_channel_on_event)(struct media_channel *channel, struct media_event *event);
/* <0: end with error code; >0: end with finished flowing;  0: need continue flowing if ctrl; */

#define media_object_get_ctl_data(_obj) ((struct media_object *)(_obj))->ctl_data
#define media_object_set_ctl_data(_obj, _ctl_data) (((struct media_object *)(_obj))->ctl_data = (_ctl_data))
#define media_object_get_data(_obj) ((struct media_object *)(_obj))->data
#define media_object_set_data(_obj, _data) (((struct media_object *)(_obj))->data = (_data))

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__media_channel_def_h__) */
