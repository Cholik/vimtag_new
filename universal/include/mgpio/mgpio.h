/*!
\file       mgpio.h
\brief      mgpio include file list
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__mgpio_h__)
#define __mgpio_h__

#define MGPIO_CMD_TYPE_GET_VALUE        101
#define MGPIO_CMD_TYPE_SET_VALUE        102
#define MGPIO_CMD_TYPE_DIRECTION_INPUT  103
#define MGPIO_CMD_TYPE_DIRECTION_OUTPUT 104
#define MGPIO_CMD_TYPE_BREAKIF          105
#define MGPIO_CMD_TYPE_DELAY            106
#define MGPIO_CMD_TYPE_CMD_ARRAY        110

#define MGPIO_CMD_MAX_PARAM             4

typedef struct mgpio_cmd_array_para
{
    int                     sub_cmd_counts;
    int                     repeat_counts;
    struct mgpio_sub_cmd    *sub_cmds;
    struct mgpio_cmd_array_result   *result;
}_mgpio_cmd_array_para;

typedef struct mgpio_cmd_array_result
{
    int                     repeat_counts;
    int                     sub_cmd_counts;
}_mgpio_cmd_array_result;

typedef struct mgpio_sub_cmd
{
    int                     cmd;
    int                     para[MGPIO_CMD_MAX_PARAM];
}_mgpio_sub_cmd;

#define MGPIO_ERR_OPERATE               1000
#define MGPIO_ERR_BREAK                 1001

#endif /* !defined(__mgpio_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */


