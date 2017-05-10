/*!
\file       mpass.h
*/
#ifndef __MPASS_H__
#define __MPASS_H__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

typedef struct mpass_calc_param
{
    struct len_str          user_id;
    struct len_str          user_ctx;
    struct len_str          manage_pass_plain;
    struct len_str          user_pass_plain;
    struct len_str          manage_pass_md5;
    struct len_str          user_pass_md5;
    struct len_str          manage_pass_mining64;
    struct len_str          user_pass_mining64;
    struct len_str          prompt;
    struct len_str          pass;
}_mpass_calc_param;

typedef struct mpass_mod
{
    char                    buf_rand[16];
    char                    buf_md5_manage[64];
    char                    buf_md5_user[64];
    char                    buf_mining64_manage[64];
    char                    buf_mining64_user[64];
    char                    buf_prompt[128];
    char                    buf_pass[64];
    char                    buf_temp[256];
}_mpass_mod;

extern long mpass_calc( struct mpass_calc_param *param );

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* defined(__MPASS_H__) */
