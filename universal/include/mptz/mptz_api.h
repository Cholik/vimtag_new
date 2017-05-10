#if !defined(__mptz_api_h__)
#define __mptz_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#define MPTZ_DIRECTION_LEFT     1
#define MPTZ_DIRECTION_RIGHT    2
#define MPTZ_DIRECTION_UP       3
#define MPTZ_DIRECTION_DOWN     4

#define MPTZ_MODE_SYNC          1
#define MPTZ_MODE_ASYNC         2

extern void *mptz_create();
extern long mptz_destroy( void *handle );
extern long mptz_move( void *handle, long req_x, long req_y, long us, long *move_x, long *move_y );

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif
