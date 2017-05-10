/*!
\file       smtp.h
\brief      smtp data structure

 ----history----
\author     wuxu
\date       2010-07-20
\version    0.01
\desc       create

$Author: wuxu $
$Id: smtp.h,v 0.1 2010-07-20 18:00:00 wuxu Exp $
*/

#if !defined(__smtp_h__)
#define __smtp_h__

#if defined(__cplusplus)
extern "c" {
#endif

#define MAX_BUF_SIZ 4096

typedef struct smtp_refer_to_query
{
    unsigned short              id;
    struct smtp_conn            *conn;
}_smtp_refer_to_query;

typedef struct smtp_data
{    
    struct  
    {
        struct smtp_data        *next;
        struct smtp_data        *prev;
    }in_mod;
    struct len_str              data;
}_smtp_data;

typedef struct smtp_conn
{
    struct 
    {
        struct smtp_mod         *owner;
        struct smtp_conn        *prev;
        struct smtp_conn        *next;
    }in_mod;

    long                        sock;              
    struct sockaddr_in          addr;  
    unsigned long               tick;

    struct 
    {
        unsigned char           buf[MAX_BUF_SIZ];
        unsigned long           size;
        unsigned long           pos;
        unsigned long           line;
    }recv;

    struct  
    {
        unsigned long           counts;
        unsigned long           ready;
        unsigned long           pos;
        struct smtp_data        *list;
    }send;
}_smtp_conn;

typedef struct smtp_mod 
{
    char                        fqdn[MAX_BUF_SIZ];
    long                        net_poll;         
    long                        sock; 
    struct sockaddr_in		    sa;
    struct smtp_refer_to_query  refer[11];
    unsigned long               max_conns;        
    unsigned long               tick;     
    struct netx_event           *events;  

    struct 
    {
        unsigned long           counts;
        struct dns_mx_query     *list;
    }query;

    struct 
    {   
        unsigned long           counts;
        struct smtp_conn        *list;
    }connection;
}_smtp_mod;

typedef struct smtp_email
{
    struct len_str              content;
    struct len_str              from;
    struct 
    {   
        unsigned long           counts;
        struct len_str          item[1];    /*maybe one more*/
    }to;                                       
}_smtp_email;

typedef struct dns_mx_query
{
    struct 
    {
        struct dns_mx_query     *next;
        struct dns_mx_query     *prev;
    }in_mod;
    
    unsigned short              trans_id;
    struct smtp_conn            *conn; 
    unsigned long               tick;

    struct  
    {
        unsigned long           counts;
        unsigned long           pos;
        struct len_str          data;
    }send;
}_dns_mx_query;
                                   
/*!
func    smtp_create
\brief  create the smtp_mod and init
\return 
        #NULL                   failed
        #other                  the created smtp_mod pointer
*/
struct smtp_mod *smtp_create(void);

/*!
func    smtp_destroy
\brief  destroy the smtp_mod
\param  mod[in]                 the mod pointer
\return 
        #0                      success
        #other                  failed
*/
long smtp_destroy(struct smtp_mod *mod);

/*!
func    smtp_wait
\brief  dispatch the events on the socket fd
\param  mod[in]                 the mod
\param  timeout[in]             the timeout
\return 
        #0                      success
        #other                  failed
*/
long smtp_wait(struct smtp_mod *mod, unsigned long timeout);

/*!
func    smtp_send_mail
\brief  sending the email
\param  mod                     the mod
\param  message                 the imf message
\return 
        #0                      success
        #other                  failed
*/
long smtp_send_mail(struct smtp_mod *mod, struct imf_message *message);

#if defined(__cplusplus)
}
#endif

#endif

