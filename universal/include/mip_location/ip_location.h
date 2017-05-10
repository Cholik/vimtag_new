/*!
\file       ip_location.h
\brief      define struct for ip information query 

  ----history----
  \author     huangyifan
  \date       2010-03-25
  \version    0.01
  \desc       create
  
*/

#ifndef __IP_SEARCH_H__
#define __IP_SEARCH_H__

#if !defined(__len_str_defined)
#define __len_str_defined
/*!< length string */
typedef struct len_str
{
    unsigned long       len;            /*!< string length */
    char                *data;          /*!< string data */
}_len_str;
#endif /* !defined(__len_str_defined) */

typedef struct ip_info
{ 
    unsigned long       counts;             /*!< reference counts */
    unsigned long       start_ip;           /*!< start ip */
    unsigned long       end_ip;             /*!< end ip */
    struct len_str      main_field;         /*!< main location of ip */
    struct len_str      minor_field;        /*!< detail location of ip */
}_ip_info;

typedef struct ip_range
{
    struct ip_range     *hash_next;         /*!< point to next record */
    unsigned char       ip[4];              /*!< net number */
    unsigned long       mask_bits;          /*!< bits counts */
    struct ip_info      *info;              /*!< info of ip */
}_ip_range;

typedef struct ip_mem
{
    struct ip_mem       *next;              /*!< next memory block */
    void                *buf;               /*!< memory buffer */
    unsigned long       buf_size;           /*!< memory buffer size */
    unsigned long       valid_pos;          /*!< current free position */
}_ip_mem;

typedef struct ip_location
{
    struct hash_table   *table;             /*!< ip hash table */
    struct ip_info      **bucket;           /*!< container of hash table */        
    unsigned long       hash_capacity;      /*!< hash capacity counts */
    struct ip_mem       *mem_head;          /*!< memory block head */
    struct ip_mem       *mem_tail;          /*!< memory block tail */
}_ip_location;


/*!
func    ip_location_create
\brief  create an ip_location table
\param  file[in]                    file name to be open. ip address information stores in
        #NULL                       create ip_location failed                           
        #other                      create ip_location succeed
*/
struct ip_location *ip_location_create(char *file);
/*!
func    ip_location_destroy
\brief  destroy ip_location table, release memory
\param  ip_local[in]                ip query struct, construct by ip_location_create function  
        #0                          destroy succeed
        #other                      destroy failed 
*/
long ip_location_destroy(struct ip_location *ip_local);


/*!
func    ip_location_get
\brief  query ip information
\param  ip_local[in]                ip query struct, construct by ip_location_create function  
\param  ip[in]                      ip address to be query, length should be four bytes, format is [192.168.1.100] ==> [192][168][1][100] 
        #NULL                       query ip information failed
        #other                      query succeed
*/
struct ip_range *ip_location_get(struct ip_location *ip_local, unsigned char *ip);


#endif