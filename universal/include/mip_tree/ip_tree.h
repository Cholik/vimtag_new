/*!
\file       ip_tree.h
\brief      ip tree unit, locate ip location

  ----history----
  \author     zhengxianwei
  \date       2010-03-25
  \version    0.01
  \desc       create

*/

#ifndef __ip_tree_h__
#define __ip_tree_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct ip_tree;

typedef struct ip_str {
    char *domain;
    char *sub;
} _ip_str;

struct ip_tree* ip_tree_new ();
long            ip_tree_insert (struct ip_tree *ip_tree, unsigned ip_beign, unsigned ip_end, char *domain, char *sub);
struct ip_str*  ip_tree_find (struct ip_tree *ip_tree, unsigned ip);
void            ip_tree_delete (struct ip_tree *ip_tree);
long            ip_tree_get_cts (void);
long            ip_tree_get_num_of_node (struct ip_tree *ip_tree);
long            ip_tree_load_from_data (struct ip_tree *ip_tree, char *qqwry_filename);

/* bit vector operate */

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__ip_tree_h__) */



