/*
\file       xsl2c_parser.h
\brief      parsing xsl statment generate the xsl exp tree

----history----
\author     zhengxianwei
\date       2009-03-17
\version    0.01
\desc       create
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#ifndef  __xsl2c_parser_h__
#define  __xsl2c_parser_h__

typedef enum
{
    xsl2c_plus,                                 /* + */
    xsl2c_minus,                                /* - */
    xsl2c_times,                                /* * */
    xsl2c_div,                                  /* div */
    xsl2c_mod,                                  /* mod */
    xsl2c_equal,                                /* = */
    xsl2c_gt,                                   /* > */
    xsl2c_lt,                                   /* < */
    xsl2c_ge,                                   /* >= */
    xsl2c_le,                                   /* <= */
    xsl2c_noequal,                              /* != */
    xsl2c_path_sep                              /* / */
} xsl2c_binop;

typedef enum { xsl2c_number, xsl2c_count, xsl2c_position } xsl2c_func;
typedef struct xsl2c_exp *xsl2c_exp;

#define PARAM_NULL          (0)
#define PARAM_VOID          (1)
#define PARAM_HAVE          (2)
#define IS_PATH_EXP(exp)    ((exp)->kind == xsl2c_path_exp \
            || ((exp)->kind == xsl2c_op_exp && (exp)->u.op.oper == xsl2c_path_sep))

typedef struct xsl2c_exp
{
    enum
    {
        xsl2c_path_exp,
        xsl2c_num_exp,
        xsl2c_string_exp,
        xsl2c_op_exp,
        xsl2c_call_exp
    } kind;

    union
    {
        struct { char *id; xsl2c_exp index; } path;
        int num;
        struct { xsl2c_exp left; xsl2c_binop oper; xsl2c_exp right; } op;
        struct { xsl2c_func name; int param_type; xsl2c_exp param; } call;
        char *string;
    } u;
} _xsl2c_exp;

extern xsl2c_exp xsl2c_gen_exp_tree (char *text, unsigned len);
extern void xsl2c_delete_exp_tree (xsl2c_exp exp);
extern void xsl2c_dump_exp_tree (xsl2c_exp exp, int indent);
extern char *xsl2c_binop2str (int binop);

#endif   /* ----- #ifndef __xsl2c_parser_h__ ----- */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
