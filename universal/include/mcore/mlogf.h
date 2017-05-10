/*!
\file       mlogf.h
\brief      log print format unit

 ----history----
\author     chengzhiyong
\date       2014-05-31
\version    0.01
\desc       create

*/

#if !defined(__mlogf_h__)
#define __mlogf_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct mlogf_ctx;

/*! \biref log format description */
typedef struct mlogf_desc
{
    struct{ unsigned long len; char *data; } dir;       /*!< save directory, emtpy:crrent dir or if(type){ from get-env(type) } */
    struct{ unsigned long len; char *data; } type;      /*!< type, if empty set as NULL */
    struct{ unsigned long len; char *data; } id;        /*!< identify, if empty set as contex-create-time */
    /* filepath:<dir>/<type>-<identify|contex-create-datetime>-<log-file-create-time>.log */
    long            switch_time;                        /*!< seconds, 0:default 1day:24hours*60minutes*60seconds */
    long            switch_counts;                      /*!< switch counts, 0:default is 0x100000 */
    long            switch_size;                        /*!< switch file size, 0:default is 0x1000000 */
}_mlogf_desc;

/*!
func    mlogf_create
\brief  create log print format context
\param  desc[in]                the description
\return the context
        #NULL                   failed
        #other                  the context */
struct mlogf_ctx *mlogf_create(struct mlogf_desc *desc);

/*!
func    mlogf_destroy
\brief  destroy context
\param  ctx[in]                 the context
\return destroy result
        #0                      succeed
        #other                  the error code */
long mlogf_destroy(struct mlogf_ctx *ctx);

/*!
func    mlogf
\brief  ouput log print format
\param  ctx[in]                 the context
\param  format[in]              the format const string, if NULL will flush to disk
\return the context
        #NULL                   failed
        #other                  the context */
long mlogf(struct mlogf_ctx *ctx, const char *format, ...);


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mlogf_h__) */
