/*
\file       mevent.h
\brief      event unit

 ----history----
\author     chengzhiyong 
\date       2007-01-30
\version    0.01
\desc       create

\author     chengzhiyong 
\date       2014-06-08
\version    0.02
\desc       rename mevent_xxx to mevent_xxx
*/

#if !defined(__mevent_h__)
#define __mevent_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct mevent_obj;
struct mevent_obj_map; 

/*!
func    mevent_sizeof_obj_map
\brief  get event object map size
\param  key_len[in]         the event key len
\return the size
*/
unsigned long mevent_sizeof_obj_map(unsigned long key_len);

/*!
func    mevent_create
\brief  create event(for windows now)
\param  obj_map[in]         the event object map, if NULL will create new one
\param  key[in]             the event key. if NULL create an unnamed key
\return create a event
        #NULL               create event failed
        #other              the event object be created
*/
struct mevent_obj *mevent_create(struct mevent_obj_map *obj_map, char *key);

/*!
func    mevent_destroy
\brief  destroy event
\param  obj[in]             the event object will be destroy
\return destroy a event
        #0                  succeed
        #other              error code
*/
long mevent_destroy(struct mevent_obj *obj);

/*!
func    mevent_wait
\brief  wait event
\param  obj[in]             the event object try to enter
\param  time_out[in]        time out value(ms)
\return wait result
        #0                  succeed, will be wait here if have not event
        #other              error code
*/
long mevent_wait(struct mevent_obj *obj, unsigned long time_out);

/*!
func    mevent_set
\brief  set event
\param  obj[in]             the event object try to leave
\return set result
        #0                  succeed
        #other              error code
*/
long mevent_set(struct mevent_obj *obj);



#if defined(__cplusplus)
}
#endif

#endif /* !defined(__mevent_h__) */

