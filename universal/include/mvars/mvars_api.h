#if !defined(__mvars_api_h__)
#define __mvars_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

extern long mvars_get_all( char *buf, long buf_size, long *data_len );
extern long mvars_get_opt_long( char *name, long *value );
extern long mvars_inc_long( char *name );
extern long mvars_set_all( char *data, long data_len );
extern long mvars_set_long( char *name, long value );

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif
