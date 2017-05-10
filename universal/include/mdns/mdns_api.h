/*!
\file       mdns_api.h
\brief      mdns api header file

 ----history----
\author     dakota
\date       2013-01-15
\version    0.01
\desc       create
*/
#if !defined(__mdns_api_h__)
#define __mdns_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

struct mdns_mod;
typedef struct mdns_create_param
{
    long                    tick_expire_query; /* Timeout tick for query */
    struct mdns_mod         *mod;           /* output. module */
}_mdns_create_param;

struct mdns_get_ack_param;
typedef long (*mdns_on_get_ack)( struct mdns_get_ack_param *param );
typedef struct mdns_get_param
{
    struct mdns_mod         *mod;           /* mdns mod */
    struct len_str          domain;         /* domain name */
    long                    tick;           /* tick for time out */
    mdns_on_get_ack         on_get_ack;     /* Callback for get async */
    void                    *refer;         /* refer for get async */
    long                    status;         /* status */
    struct pack_ip          ip;             /* output. ip */
    struct len_str          ip_str;         /* output. ip string */
}_mdns_get_param;

typedef struct mdns_get_ack_param
{
    struct len_str          domain;         /* domain name */
    long                    status;         /* status */
    struct pack_ip          ip;             /* ip */
    struct len_str          ip_str;         /* ip string */
    void                    *refer;         /* refer for get async */
}_mdns_get_ack_param;

#define mdns_status_init            0
#define mdns_status_timeout         1
#define mdns_status_no_answer       2
#define mdns_status_query           3
#define mdns_status_active          4
#define mdns_status_max             mdns_status_active


long mdns_get( struct mdns_get_param *param );
long mdns_create( struct mdns_create_param *param );
long mdns_destroy( struct mdns_mod *mod );


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mdns_api_h__) */
