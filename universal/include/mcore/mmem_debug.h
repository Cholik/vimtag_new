/*!
\file       mmem_debug.h
\brief      debug memory unit

 ----history----
\author     chengzhiyong 
\date       2007-10-13
\version    0.01
\desc       create

\author     chengzhiyong
\date       2015-12-13
\version    0.02
\desc       rename mem_xxx to mmem_xxx, to resolved RTOS conflict

*/
#if !defined(__mmem_debug_h__)
#define __mmem_debug_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if 0   /* useage, can add these code to WIN-VC++:[<malloc.h>, <stdlib.h>] LINUX-GCC:[<malloc.h>, <stdlib.h>] define _fbase_mem_debug precompile macro */
#if defined(_mmem_debug_enable) && _mmem_debug_enable
    extern void *mmem_calloc(unsigned long item_counts, unsigned long item_size, const char *file, unsigned long line);
    #undef calloc
    #define calloc(counts, item_size) mmem_calloc(counts, item_size, __FILE__, __LINE__)
    extern void *mmem_alloc(unsigned long size, const char *file, unsigned long line);
    #undef malloc
    #define malloc(size) mmem_alloc(size, __FILE__, __LINE__)
    extern void mmem_free(void *addr, const char *file, unsigned long line);
    #undef free
    #define free(addr) mmem_free(addr, __FILE__, __LINE__)
    extern void* mmem_realloc( void* addr, unsigned long size, const char *file, unsigned long line);
    #undef realloc
    #define realloc(addr, size) mmem_realloc(addr, size, __FILE__, __LINE__)
#else
#endif
#endif
#if defined(_mmem_debug_enable) && _mmem_debug_enable
#   undef calloc
#   define calloc(_counts, _item_size)  mmem_calloc(_counts, _item_size, __FILE__, __LINE__)
#   undef malloc
#   define malloc(_size)                mmem_alloc(_size, __FILE__, __LINE__)
#   undef free
#   define free(_addr)                  mmem_free(_addr, __FILE__, __LINE__)
#   undef realloc
#   define realloc(_addr, _size)        mmem_realloc(_addr, _size, __FILE__, __LINE__)
#elif defined(__linux__) && defined(__KERNEL__) && __KERNEL__
#   include <linux/slab.h>
#   define malloc(_size)                kmalloc(_size, GFP_KERNEL)
#   define calloc(_counts, _item_size)  kcalloc(_counts, _item_size, __GFP_ZERO | GFP_KERNEL)
#   define free(_addr)                  kfree(_addr)
#   define realloc(_addr, _size)        krealloc(_addr, _size)
#endif
    
/*!
func    mmem_calloc
\brief  malloc a memory
\param  item_counts[in]         the item counts
\param  item_size[in]           the size of the item
\param  file[in]                the file which alloc this space
\param  line[in]                the line of the code call this function
\return the pointer
        #NULL                   malloc failed
        #other                  the pointer
*/
void *mmem_calloc(unsigned long item_counts, unsigned long item_size, const char *file, unsigned long line);

/*!
func    mmem_alloc
\brief  malloc a memory
\param  size[in]                the size
\param  file[in]                the file which alloc this space
\param  line[in]                the line of the code call this function
\return the pointer
        #NULL                   malloc failed
        #other                  the pointer
*/
void *mmem_alloc(unsigned long size, const char *file, unsigned long line);

/*!
func    mmem_free
\brief  free a memory
\param  addr[in]                the addr
\param  file[in]                the file which alloc this space
\param  line[in]                the line of the code call this function
\return void
*/
void mmem_free(void *addr, const char *file, unsigned long line);

/*!
func    mmem_realloc
\brief  malloc a memory
\param  size[in]                the size
\param  file[in]                the file which alloc this space
\param  line[in]                the line of the code call this function
\return the pointer
        #NULL                   malloc failed
        #other                  the pointer
*/
void *mmem_realloc( void* addr, unsigned long size, const char *file, unsigned long line);


#define mmem_debug_check_flag_overflow                   0x00000001
#define mmem_debug_check_flag_statistic_active_blocks    0x00000002
#define mmem_debug_check_flag_statistic_all_blocks       0x00000004
#define mmem_debug_check_flag_detail                     0x00000008
/*!
func    mmem_debug_check
\brief  check memory or print used state
\param  flag[in]                mem_debug_check_flag_xxx
\return void
*/
void mmem_debug_check(unsigned long flag);

/*!
func    mmem_free_all
\brief  free all memory alloc by mem-debug unit
\return void
*/
void mmem_free_all(void);

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif /* !defined(__mmem_debug_h__) */
