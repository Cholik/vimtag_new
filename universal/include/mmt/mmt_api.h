/*!
\file       mmt_api.h
\brief      media transport api unit

 ----history----
\author     chengzhiyong
\date       2014-05-11
\version    0.01
\desc       create
*/

#if !defined(__mmt_api_h__)
#define __mmt_api_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

struct mmt_mod;
struct mmt_pack;
struct mmt_pack_type;
struct len_str;

/*!
func    mmt_mod_create
\brief  create media transport module, call mmt_mod_destroy to destory when
        system halt
\param  desc[in]                the module description
\return the module
        #NULL                   failed
        #other                  the module object be created
*/
struct mmt_mod *mmt_mod_create(struct mmt_mod_desc *desc);

/*!
func    mmt_mod_destroy
\brief  destroy media transport module
\param  mod[in]                 the module return by mmt_mod_create
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long mmt_mod_destroy(struct mmt_mod *mod);

/*!
func    mmt_mod_get_ref
\brief  get refer data
\param  mod[in]                 the module return by mmt_mod_create
\return refer data
        #NULL                   refer is NULL or module is invalid
        #other                  the refer data
*/
void *mmt_mod_get_ref(struct mmt_mod *mod);

/*
func    mmt_conn_create
\brief  create connection to special uid, active-off need call 
        mmt_conn_destroy, don't mmt_conn_destroy with passive closing(notify
        closing by event).
\param  mod[in]                 the module return by mmt_mod_create
\param  desc[in]                the connection description
\return connection id
        #>0                     the connection id
        #other                  the error code
*/
long mmt_conn_create(struct mmt_mod *mod, struct mmt_conn_desc *desc);

/*!
func    mmt_conn_destroy
\brief  destroy connection, if connection be notifyed as close status, don't 
        call this function
\param  mod[in]                 the module return by mmt_mod_create
\param  conn_id[in]             the connection id return by mmt_conn_create 
\return destroy result
        #0                      succeed
        #other                  the error code
*/
long mmt_conn_destroy(struct mmt_mod *mod, long conn_id);

/*!
func    mmt_conn_set_ref
\brief  set refer data for conn
\param  mod[in]                 the module return by mmt_mod_create
\param  conn_id[in]             the connection id return by mmt_conn_create 
\param  ref[in]                 the refer data
\return set result
        #0                      succeed
        #other                  the error code
*/
long mmt_conn_set_ref(struct mmt_mod *mod, long conn_id, void *ref);

/*!
func    mmt_conn_write_data
\brief  write data to connection
\param  mod[in]                 the module return by mmt_mod_create
\param  conn_id[in]             the connection id return by mmt_conn_create 
\param  len[in]                 the data length
\param  data    [in]            the data
\return write result
        #0                      succeed
        #other                  the error code
*/
long mmt_conn_write_data(struct mmt_mod *mod, long conn_id, unsigned long len, unsigned char *data);

/*!
func    mmt_chl_create
\brief  create media transport channel for media data, active-off need call 
        mmt_chl_destroy, don't mmt_chl_destroy with passive closing(notify 
        closing by event).
\param  mod[in]                 the module return by mmt_mod_create
\param  desc[in]                the connection description
\return channel id
        #>0                     the channel id
        #other                  the error code
*/
long mmt_chl_create(struct mmt_mod *mod, struct mmt_chl_desc *desc);

/*!
func    mmt_chl_destroy
\brief  destroy channel, if channel be notifyed as close status, don't 
        call this function
\param  mod[in]                 the module return by mmt_mod_create
\param  chl_id[in]              the channel id return by mmt_conn_create 
\return destroy id
        #0                      succeed
        #other                  the error code
*/
long mmt_chl_destroy(struct mmt_mod *mod, long chl_id);

/*!
func    mmt_chl_write_pack
\brief  write media pack to channel(just for publish)
\param  mod[in]                 the module return by mmt_mod_create
\param  chl_id[in]              the channel id return by mmt_chl_create 
\param  pack[in]                the media pack
\return write result
        #0                      succeed
        #other                  the error code
*/
long mmt_chl_write_pack(struct mmt_mod *mod, long chl_id, struct mmt_pack *pack);

/*!
func    mmt_utils_entry
\brief  mmt utils entry
\param  argc[in]                the args counts
\param  argv[in]                the args array list
\return run result
        #0                      succeed
        #other                  the error code
*/
long mmt_utils_entry(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__mmt_api_h__) */

