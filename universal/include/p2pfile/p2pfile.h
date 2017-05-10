/*!
\file       p2pfile.h
\brief      p2p_nodejs nodejs addon

 ----history----
\author     tancan
\date       2016-10-18
\version    0.01
\desc       create

*/


#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */


#if !defined(__p2pfile_h__)
#define __p2pfile_h__

#include <stdio.h>
#include "mp2pex/p2pex.h"
#include "mp2pex/p2pex_link.h"

#define default_size_max 10240

typedef struct p2pex_client_node
{
    long        id;
	char        ip[16];
	char        p2pid[28];
	long        port;
	long        link_status;//0:break; 1:free; 2:busy
	struct      p2pex_link_cb *link;
	struct      p2pex_client_node  *next;
}_p2pex_client_node, *pNode;

typedef struct task_node {
    long        id;
    long        port;
    char        ip[16];
    char        type[9];
    char        *file_path;
    char        *save_path;
    char        *cmd;
    struct task_node *next;
}_task_node, *taskLinkList;

typedef struct result_node {
    long         handle;
    char         *data;  //result of cmd
    char         *result;//success, fail
    struct result_node *next;
}_result_node, *resultLinkList;

typedef struct p2pex_file_mod
{
    struct p2pex_cb         *cb;
    struct p2pex_link_cb    *link;
    long                    size;
	long                    file_size;
    long                    counts;
    long                    send_counts;
    long                    recv_counts;
	char                    *recv_save_path;
    char                    *buf;
    char					 *file_path;
    char                    *save_path;
    long				     flag;
    long                    option;//1:send shell 2:get file 3:send file 4:send cmd
    long                    id;//task id
    FILE					 *file_fd;
    unsigned long           crc;
	pNode                   client_list_head;
	taskLinkList            task_list_head;
	resultLinkList          result_list_head;
}_p2pex_file_mod;


typedef struct p2p_list_head
{
	pNode                   client_list_head;
	taskLinkList            task_list_head;
}_p2p_list_head;


extern long get_head_data(char *data, char *head, long n);
extern long send_data_creat(char *flag, char *data, char *read_data,long read_size);
extern long check_data_flag(char *data);
extern long get_file_size(char *path);
extern long p2pex_link_send_file(struct p2pex_file_mod *mod);
extern long p2pex_link_send_file_srv(struct p2pex_file_mod *mod);
extern long check_file_crc(struct p2pex_file_mod	*mod, long size, long unsigned md5);
extern long check_file_crc_srv(struct p2pex_file_mod	*mod, long size, long unsigned md5);
extern long save_file(FILE *file_fd, char *data, long size);
extern long p2pex_file_sender_on_link_data( struct p2pex_link_cb *link, void *refer, char *data, int len );
extern long p2pex_file_sender_on_link_notify( struct p2pex_link_cb *link, void *refer, struct p2pex_link_notify *notify);
extern long p2pex_file_recver_on_link_data( struct p2pex_link_cb *link, void *refer, char *data, int len );
extern long p2pex_file_recver_on_link_notify( struct p2pex_link_cb *link, void *refer, struct p2pex_link_notify *notify);
extern long p2pex_file_on_link_create( void *refer, struct p2pex_link_cb *link, char *data, unsigned long data_len );
extern int insertClientNode(struct p2pex_client_node* data, pNode p);
extern int insertTaskNode(taskLinkList task, struct task_node* data);
extern int insertResultNode(struct result_node* data, resultLinkList result_list_head);
extern pNode createCliLinkList();
extern taskLinkList createTaskLinkList();
extern resultLinkList createResultLinkList();
extern int traverseClientLinkList(char* p2pid, struct p2pex_client_node* p2p_client_list_head);
extern void changeNodeStatus(struct p2pex_link_cb *link, char* p2pid, int flag, pNode p2p_client_list_head);
extern int destroyClientList(pNode p2p_client_list_head);
extern int destroyTaskList(taskLinkList task_list_head);
extern int destroyResultList(resultLinkList result_list_head);
extern int srv_send_file(char* type, struct p2pex_link_cb* link, char* file_path, char* save_path);
extern int srv_get_file(struct p2pex_link_cb* link, char* file_path, char* save_path);
extern int srv_send_cmd(struct p2pex_link_cb* link, char* cmd);
extern int handle_task(struct p2pex_link_cb* link, struct task_node *node);
extern void deleteTaskNode(struct task_node *p, taskLinkList task);
extern pNode findClient(char *ip, long port, pNode p2p_client_list_head);
extern pNode getClient(char* p2pid, pNode p2p_client_list_head);
extern int get_task(pNode client_list_head, taskLinkList task_list_head);
extern void set_result(long id, char* result, char* data, resultLinkList result_list_head);
extern resultLinkList get_result(resultLinkList result_list_head);
extern int add_task(taskLinkList task_list_head, long id, char* ip, long port, char* type, char* data1, char* data2);
extern long get_head_data(char *data, char *head, long n);
extern int build_srv(pNode* const head_client, taskLinkList* const head_task, resultLinkList* const head_result, char* ip, long port);





#endif 


#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */


