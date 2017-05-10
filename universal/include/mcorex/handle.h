/*
\file		handle.h
\brief		.
 ----history----
\author     dakota
\date       2007-05-27
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: handle.h,v 1.1.1.1 2007-11-25 15:09:11 chengzhiyong Exp $
*/
#if !defined(__handle_h__)
#define  __handle_h__

#if defined(__cplusplus)
extern "C" {
#endif

#define HANDLE_SPARE_BIT    8
#define HANDLE_DIFF_BIT     8
#define HANDLE_ENTRY_BIT    8
#define HANDLE_PAGE_BIT     ( 32 - HANDLE_SPARE_BIT - HANDLE_DIFF_BIT - HANDLE_ENTRY_BIT )

#define HANDLE_SPARE_SHIFT  ( HANDLE_DIFF_BIT + HANDLE_ENTRY_BIT + HANDLE_PAGE_BIT )
#define HANDLE_DIFF_SHIFT  ( HANDLE_ENTRY_BIT + HANDLE_PAGE_BIT )
#define HANDLE_ENTRY_SHIFT  ( HANDLE_PAGE_BIT )
#define HANDLE_PAGE_SHIFT  ( 0 )

#define HANDLE_SPARE_MASK   ( ( 1 << HANDLE_SPARE_BIT ) - 1 )
#define HANDLE_DIFF_MASK   ( ( 1 << HANDLE_DIFF_BIT ) - 1 )
#define HANDLE_ENTRY_MASK   ( ( 1 << HANDLE_ENTRY_BIT ) - 1 )
#define HANDLE_PAGE_MASK   ( ( 1 << HANDLE_PAGE_BIT ) - 1 )

#define MAX_PAGE_IN_TBL     ( 1 << HANDLE_PAGE_BIT )
#define MAX_ENTRY_IN_PAGE  ( 1 << HANDLE_ENTRY_BIT )
#define MAX_DIFF_IN_ENTRY   ( ( 1 << HANDLE_DIFF_BIT ) - 1 )

#define VALVE_FREE_ENTRY    ( MAX_ENTRY_IN_PAGE / 10 )
#define NULL_HANDLE         ((int)0)

typedef int HANDLE_ID;

typedef struct tag_ST_HANDLE_ENTRY
{
    void                *pObj;                  /* 该HANDLE映射的对象地址 */
    char                ucUsedFlag;             /* 是否已经使用 */
    HANDLE_ID           handle;                 /* 该ENTRY对应的HANDLE，用于调试 */
    struct tag_ST_HANDLE_ENTRY  *pstNextEntry;  /* 下一个ENTRY，主要用于将空闲的ENTRY串起来 */
    long                dwDiff;                 /* 序号，用来鉴别HANDLE是否有效 */
}ST_HANDLE_ENTRY;

typedef struct tag_ST_HANDLE_PAGE
{
    ST_HANDLE_ENTRY         astHandleEntry[MAX_ENTRY_IN_PAGE];    /* 本页的HANDLE数组 */
    ST_HANDLE_ENTRY         *pstFirstUnusedEntry;     /* 第一个没有分配出去的ENTRY */
    ST_HANDLE_ENTRY         *pstLastUnusedEntry;     /* 最后一个没有分配出去的ENTRY */
    long                    dwEntry_used;           /* 已经分配的ENTRY数 */
}ST_HANDLE_PAGE;


typedef struct
{
    ST_HANDLE_PAGE          *apstPage[MAX_PAGE_IN_TBL]; /* 对于空白PAGE，指向下一个空闲PAGE，对于已经分配的PAGE，指向PAGE */      
    long                    entry_free;             /* 当前可分配的ENTRY数 */
    ST_HANDLE_PAGE          **ppstCurrentPage;      /* 当前用于分配ENTRY的PAGE */
    ST_HANDLE_PAGE          **ppstFirstBlankPage;  /* 第一个空白PAGE */
}ST_HANDLE_TABLE;

extern ST_HANDLE_PAGE ** Handle_AllocatePage( ST_HANDLE_TABLE *pstHandleTbl );
extern long Handle_Create( ST_HANDLE_TABLE *pstHandleTbl, void *pObj );
extern void * Handle_Validate( ST_HANDLE_TABLE *pstHandleTbl, long handle );
extern long Handle_Destroy( ST_HANDLE_TABLE *pstHandleTbl, long handle );
extern void Handle_DestroyPage( ST_HANDLE_TABLE *pstHandleTbl, ST_HANDLE_PAGE **ppstPage );

extern ST_HANDLE_PAGE **Handle_FindNextPage( ST_HANDLE_TABLE *pstHandleTbl );

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__handle_h__) */



