/*!
\file       mnvram.h
\brief      mnvram include file list
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__mnvram_h__)
#define __mnvram_h__

#define MNVRAM_CMD_TYPE_GET         101
#define MNVRAM_CMD_TYPE_SET         102

typedef struct mnvram_param_get
{
    long                    buf_size;
    char                    *buf;
    long                    *data_len;
}_mnvram_param_get;

typedef struct mnvram_param_set
{
    long                    len;
    char                    *data;
}_mnvram_param_set;

#endif /* !defined(__mnvram_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */


