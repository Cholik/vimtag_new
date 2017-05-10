/*
\file		fsm.h
\brief		.
 ----history----
\author     dakota
\date       2007-05-27
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: fsm.h,v 1.1.1.1 2007-11-25 15:09:11 chengzhiyong Exp $
*/
#if !defined(__fsm_h__)
#define  __fsm_h__

#if defined(__cplusplus)
extern "C" {
#endif

typedef enum
{
    EN_ACT_A,
    EN_ACT_B,
    EN_ACT_C,
    EN_ACT_D,
    EN_ACT_E,
    EN_ACT_F,
    EN_ACT_G,
    EN_ACT_H,
    EN_ACT_I,
    EN_ACT_J,
    EN_ACT_K,
    EN_ACT_L,
    EN_ACT_M,
    EN_ACT_N,
    EN_ACT_O,
    EN_ACT_P,
    EN_ACT_Q,
    EN_ACT_R,
    EN_ACT_S,
    EN_ACT_T,
    EN_ACT_U,
    EN_ACT_V,
    EN_ACT_W,
    EN_ACT_X,
    EN_ACT_Y,
    EN_ACT_Z,

    EN_ACT_NO,
    EN_ACT_ERR

}EN_ACT;

typedef struct
{
    long                dwNextState;
    long                dwAction;
}ST_FSM_ENTRY;

#define EXECUTE_FSM( FSM_TBL, MAX_INPUT, MAX_STATES, INPUT, STATE, ACTION ) \
                    if( MAX_INPUT < INPUT ) {IO_ASSERT( 0 );return;}\
                    if( MAX_STATES < STATE ) {IO_ASSERT( 0 );return;}\
                    ACTION = FSM_TBL[INPUT][STATE].dwAction;\
                    STATE = FSM_TBL[INPUT][STATE].dwNextState
                        
#if defined(__cplusplus)
}
#endif

#endif /* !defined(__fsm_h__) */




