/*!
\file       me_x.h
\brief      media engine x
----history----
\author     chengzhiyong
\date       2012-03-27
\version    0.01
\desc       create

$Author: chengzhiyong $
*/
#if !defined(__media_engine_x_h__)
#define __media_engine_x_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct mmex_obj;

#if !defined(__len_str_defined)
#   define __len_str_defined
    /*!< length string */
    typedef struct len_str
    {
        unsigned long       len;            /*!< string length */
        char                *data;          /*!< string data */
    }_len_str;
#endif /* !defined(__len_str_defined) */

typedef long (*mmex_on_notify)(struct mmex_obj *mme, struct len_str *type, void *refer);

typedef struct mmex_desc
{
    struct len_str      sys_params;
    struct len_str      user_params;
    struct len_str      js_on_event;
    mmex_on_notify      on_notify;
    void                *refer;
}_mmex_desc;


typedef struct mmex_native_event_win
{
    unsigned long event;
    unsigned long wParam;
    unsigned long lParam;
}_mmex_native_event_win;


struct mmex_obj *mmex_create(struct mmex_desc *desc);
long mmex_destroy(struct mmex_obj *mmex);
long mmex_chl_create(struct mmex_obj *mme, struct len_str *params);
long mmex_chl_destroy(struct mmex_obj *mme, long chl_id);
/* use mmex_event_clear to free result */
struct len_str *mmex_event_pick(struct mmex_obj *mme, unsigned long *counts/* [out] can be NULL, if NULL ignore, remained event counts */);
/* use mmex_event_clear to free result */
struct len_str *mmex_ctrl(struct mmex_obj *mme, long chl_id, struct len_str *method, struct len_str *params);
long mmex_event_clear(struct mmex_obj *mme, struct len_str *event);
long mmex_msg_proc(struct mmex_obj *mme, void *native_event);

/* tool */
long mmex_update_cab_js_build(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__media_engine_x_h__) */
