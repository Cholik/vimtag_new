/*!
\file       at88sc.h
\brief      mining at88sc chip lib

 ----history----
\author     chengzhiyong
\date       2011-08-06
\version    0.01
\desc       create
*/

#if !defined(__at88sc_h__)
#define __at88sc_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

#define at88sc_ctx_magic    (*(long*)"at88   ")
typedef struct at88sc_ctx
{
    /* -----------system-conrol-fields,memset as 0 before at88sc_init----- */
    struct
    {
	    unsigned char   magic[sizeof(long)];
	    long            handle;
	    unsigned char   gpa[20];
	    long            gc_active_index;
	    long            pwd_active_index;
	    long            pwd_active_write;  
    }_cache;
    /* -----------system-conrol-fields,memset as 0 before at88sc_init----- */

    /* ---------------------use data-------------------------------------- */
    struct
    {
        unsigned long   authentication_enable; 
        long            gc_index;                       /*!< active authentication when init */
    }init;

    struct  
    {
        unsigned char   is_inited;
        unsigned char   reserved[3];
        unsigned char   data[8];
    }gc[4];

    struct  
    {
        struct  
        {
            unsigned char   is_inited;
            unsigned char   data[3];
        }read, write;
    }pwd[8];
    /* ---------------------use data-------------------------------------- */
}_at88sc_ctx;
#define at88sc_ctx_format_s     "%p{magic[%04s],handle[%ld]}"
#define at88sc_ctx_format(_ctx) (_ctx), (_ctx)?&(_ctx)->_cache.magic[0]:0, (_ctx)?(_ctx)->_cache.handle:0

typedef struct at88sc_info
{
    unsigned char       answer_to_reset[8];

    unsigned char       fab_code[2];
    unsigned char       mtz[2];
    unsigned char       card_manufacturer_code[4];

    unsigned char       lot_hisotry[8];

    unsigned char       dcr[1];
    unsigned char       identify[7];
 
    unsigned char       ar_pr[8];

    unsigned char       fuse[1];
    unsigned char       reserved[3];
}_at88sc_info;

long at88sc_init(struct at88sc_ctx *ctx);
long at88sc_uninit(struct at88sc_ctx *ctx);
long at88sc_info_read(struct at88sc_ctx *ctx, struct at88sc_info *info);
long at88sc_user_zone_read(struct at88sc_ctx *ctx, unsigned long zone,
                           unsigned long addr_high, unsigned long addr_low, 
                           unsigned long size, unsigned char *buf);
long at88sc_user_zone_write(struct at88sc_ctx *ctx, unsigned long zone,
                            unsigned long addr_high, unsigned long addr_low,
                            unsigned long len, unsigned char *data);
long at88sc_config_zone_read(struct at88sc_ctx *ctx, 
                             unsigned long addr_high, unsigned long addr_low, 
                             unsigned long size, unsigned char *buf);
long at88sc_config_zone_write(struct at88sc_ctx *ctx,
                              unsigned long addr_high, unsigned long addr_low,
                              unsigned long len, unsigned char *data);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__at88sc_h__) */

